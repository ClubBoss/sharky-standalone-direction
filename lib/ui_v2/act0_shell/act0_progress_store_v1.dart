import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Storage protocol only: it never merges progress, awards XP or grades evidence.
/// Two independently validated checkpoint copies hold the same immutable source
/// snapshot. The old key remains a compatibility mirror, not a progress
/// authority, and is never consulted once protected data exists.
///
/// Contract: every state a read exposes is a pure function of the durable bytes.
/// Copies that disagree are healed (higher revision wins) and verified by an
/// independent reload BEFORE the state is exposed; if that cannot be proven the
/// read fails closed. A write is acknowledged only after both copies verifiably
/// hold the new revision. A `false` result is indeterminate: the write may take
/// effect at a later read, so callers must re-load to learn the durable state.
class _CheckpointHealFailure extends FormatException {
  const _CheckpointHealFailure()
    : super('Progress checkpoints could not be healed');
}

/// Immutable inspection token. Inspection itself never heals or writes data.
class Act0RecoveryProposalV1 {
  const Act0RecoveryProposalV1._(this._snapshot);
  final String _snapshot;
}

/// Opaque deletion consent token; it exposes no damaged learner values.
class Act0RecoveryCopyV1 {
  const Act0RecoveryCopyV1._(this.exists, this.pending, this._value);
  final bool exists;
  final bool pending;
  final String _value;
}

enum Act0RecoveryConfirmationOutcomeV1 {
  completed,
  existingCopyConflict,
  notVerified,
}

class Act0RecoveryHoldV1 extends FormatException {
  const Act0RecoveryHoldV1() : super('Recovery could not be safely verified');
}

enum Act0ProgressRestoreResultV1 { committed, changed, unverified }

class Act0ProgressStoreV1 {
  Act0ProgressStoreV1({
    required this.key,
    required this.isValidPayload,
    this.debugRecoveryBoundary,
  }) : _lease = _epochs[key] ?? 0;

  // Optional observer for deterministic cuts and a separately flagged debug
  // native capture. Never supplies progress or changes the protocol's writes.
  final Future<void> Function(String)? debugRecoveryBoundary;
  static final _epochs = <String, int>{};
  final int _lease;
  bool get isWriteLeaseCurrent => _lease == (_epochs[key] ?? 0);
  static const _maxRevision = 9007199254740991;
  static final Object _absent = Object();
  String get damagedCopyKey => '${key}_damaged_copy_v1';
  String get recoveryIntentKey => '${key}_recovery_intent_v1';
  List<String> get _protectedKeys => [key, headKey, recoveryKey, backupKey];

  final String key;
  final bool Function(String) isValidPayload;
  static final _queues = <String, Future<void>>{};
  String get recoveryKey => '${key}_recovery';
  String get backupKey => '${key}_backup';
  String get headKey => '${key}_head';

  Future<T> _serial<T>(Future<T> Function() operation) {
    final result = (_queues[key] ?? Future<void>.value()).then(
      (_) => operation(),
    );
    // Failure of one operation must not poison subsequent recovery/reset work.
    final tail = result.then<void>(
      (_) {},
      onError: (Object _, StackTrace __) {},
    );
    _queues[key] = tail;
    unawaited(
      tail.then((_) {
        if (identical(_queues[key], tail)) _queues.remove(key);
      }),
    );
    return result;
  }

  /// Wait for all requests already issued against this storage key.
  Future<void> flush() => _queues[key] ?? Future<void>.value();

  Future<String?> load() async => (await loadState()).payload;

  Future<({String? payload, bool isReset})> loadState() => _serial(() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    if (prefs.containsKey(recoveryIntentKey) && !await _resumeRecovery(prefs)) {
      throw const Act0RecoveryHoldV1();
    }
    final state = await _resolve(prefs);
    return (
      payload: state.payload,
      isReset: state.revision > 0 && state.payload == null,
    );
  });

  /// Revision-aware snapshot from the canonical resolver, not a second reader.
  /// Recovery completion follows loadState; tombstone revisions are retained.
  Future<({int revision, String? payload})> readDurableSnapshot() =>
      _serial(() async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.reload();
        if (prefs.containsKey(recoveryIntentKey) &&
            !await _resumeRecovery(prefs)) {
          throw const Act0RecoveryHoldV1();
        }
        return _resolve(prefs);
      });

  /// Explicit restore only. [supportedProgressSchema] and [isValidPayload]
  /// must come from the active shell contract, never from the imported file.
  /// A commit attempt fences ALL previously constructed writers, including
  /// this instance. The route must dispose old state and construct a new store
  /// before resuming saves, also after an indeterminate result.
  Future<Act0ProgressRestoreResultV1> restoreIfUnchanged({
    required ({int revision, String? payload}) expected,
    required String incomingPayload,
    required int supportedProgressSchema,
  }) {
    try {
      final value = jsonDecode(incomingPayload);
      if (value is! Map ||
          value['schemaVersion'] != supportedProgressSchema ||
          !isValidPayload(incomingPayload)) {
        return Future.value(Act0ProgressRestoreResultV1.unverified);
      }
    } catch (_) {
      return Future.value(Act0ProgressRestoreResultV1.unverified);
    }
    return _serial(() async {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.reload();
        if (!isWriteLeaseCurrent || prefs.containsKey(recoveryIntentKey)) {
          return Act0ProgressRestoreResultV1.unverified;
        }
        final current = await _resolve(prefs);
        if (current != expected ||
            (current.payload != null && current.payload != incomingPayload)) {
          return Act0ProgressRestoreResultV1.changed;
        }
        // The controller handles alreadyPresent without a write. Do not claim
        // a new committed revision when a direct caller repeats identical data.
        if (current.payload != null) {
          return Act0ProgressRestoreResultV1.changed;
        }
        if (current.revision >= _maxRevision) {
          return Act0ProgressRestoreResultV1.unverified;
        }
        _epochs[key] = (_epochs[key] ?? 0) + 1;
        final committed = await _commit(
          prefs,
          current.revision + 1,
          incomingPayload,
          previousRaw: current.revision == 0
              ? null
              : _envelope(current.revision, current.payload),
        );
        // false/throw remains indeterminate, even if a later load can recover.
        if (!committed) return Act0ProgressRestoreResultV1.unverified;
        await prefs.reload();
        if (prefs.containsKey(recoveryIntentKey)) {
          return Act0ProgressRestoreResultV1.unverified;
        }
        final durable = await _resolve(prefs);
        return durable.revision > expected.revision &&
                durable.payload == incomingPayload
            ? Act0ProgressRestoreResultV1.committed
            : Act0ProgressRestoreResultV1.unverified;
      } catch (_) {
        return Act0ProgressRestoreResultV1.unverified;
      }
    });
  }

  Future<bool> save(String payload) => _serial(() async {
    if (!isWriteLeaseCurrent || !isValidPayload(payload)) return false;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      if (!isWriteLeaseCurrent || prefs.containsKey(recoveryIntentKey))
        return false;
      final current = await _resolve(prefs);
      if (current.revision >= _maxRevision) return false;
      return await _commit(
        prefs,
        current.revision + 1,
        payload,
        previousRaw: current.revision == 0
            ? null
            : _envelope(current.revision, current.payload),
      );
    } catch (_) {
      return false; // Preserve unreadable bytes; never replace them with defaults.
    }
  });

  /// An explicit user reset is itself an ordered durable tombstone. Removing
  /// keys one by one would allow an interrupted reset to resurrect old awards.
  Future<bool> clear() => _serial(() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      if (!isWriteLeaseCurrent || prefs.containsKey(recoveryIntentKey))
        return false;
      var revision = 0;
      String? previousRaw;
      try {
        final current = await _resolve(prefs);
        revision = current.revision;
        if (revision > 0) previousRaw = _envelope(revision, current.payload);
      } on _CheckpointHealFailure {
        // Storage refuses writes: do not destroy intact copies on a blind reset.
        return false;
      } catch (_) {
        // Explicit reset over unreadable/conflicting copies outranks them all.
        revision = _highestRevision(prefs);
      }
      if (revision >= _maxRevision) return false;
      final committed = await _commit(
        prefs,
        revision + 1,
        null,
        previousRaw: previousRaw,
      );
      if (committed) {
        try {
          await prefs.remove(key);
        } catch (_) {
          /* legacy mirror is never authoritative */
        }
      }
      return committed;
    } catch (_) {
      return false;
    }
  });

  /// No canonical writes, checkpoint healing, archive or intent creation.
  Future<Act0RecoveryProposalV1> inspectRecovery() => _serial(() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    if (!isWriteLeaseCurrent || prefs.containsKey(recoveryIntentKey))
      throw const Act0RecoveryHoldV1();
    final snapshot = _snapshot(prefs);
    if (!await _recoveryEligible(prefs, snapshot))
      throw const Act0RecoveryHoldV1();
    _targetTombstone(snapshot); // Reject revision overflow before consent.
    return Act0RecoveryProposalV1._(snapshot);
  });

  /// Only explicit confirmation calls this method. An existing different copy
  /// is never evicted; deleting it requires a separate opaque consent token.
  Future<bool> confirmRecovery(Act0RecoveryProposalV1 proposal) async =>
      await confirmRecoveryOutcome(proposal) ==
      Act0RecoveryConfirmationOutcomeV1.completed;

  /// The refusal reason is classified within the same serialized confirmation.
  /// Unreadable copy data and I/O failures never imply a proven copy conflict.
  Future<Act0RecoveryConfirmationOutcomeV1> confirmRecoveryOutcome(
    Act0RecoveryProposalV1 proposal,
  ) => _serial(() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      if (!isWriteLeaseCurrent ||
          prefs.containsKey(recoveryIntentKey) ||
          _snapshot(prefs) != proposal._snapshot ||
          !await _recoveryEligible(prefs, proposal._snapshot))
        return Act0RecoveryConfirmationOutcomeV1.notVerified;
      final target = _targetTombstone(proposal._snapshot);
      final archive = jsonEncode({
        'format': 1,
        'storeKey': key,
        'snapshot': jsonDecode(proposal._snapshot),
        'digest': _hash(jsonEncode([1, key, proposal._snapshot])),
      });
      if (prefs.containsKey(damagedCopyKey)) {
        final existing = prefs.get(damagedCopyKey);
        if (existing is! String)
          return Act0RecoveryConfirmationOutcomeV1.notVerified;
        if (_archiveSnapshot(existing) != proposal._snapshot)
          return Act0RecoveryConfirmationOutcomeV1.existingCopyConflict;
      } else if (!await _write(prefs, damagedCopyKey, archive)) {
        return Act0RecoveryConfirmationOutcomeV1.notVerified;
      }
      await prefs.reload();
      final verifiedArchive = prefs.get(damagedCopyKey);
      if (verifiedArchive is! String ||
          _archiveSnapshot(verifiedArchive) != proposal._snapshot)
        return Act0RecoveryConfirmationOutcomeV1.notVerified;
      await _boundary('archive_verified');
      await prefs.reload();
      if (!isWriteLeaseCurrent ||
          prefs.containsKey(recoveryIntentKey) ||
          _snapshot(prefs) != proposal._snapshot ||
          prefs.get(damagedCopyKey) != verifiedArchive ||
          !await _recoveryEligible(prefs, proposal._snapshot))
        return Act0RecoveryConfirmationOutcomeV1.notVerified;
      final intentFields = [
        1,
        key,
        _hash(verifiedArchive),
        _hash(proposal._snapshot),
        target,
      ];
      final intent = jsonEncode({
        'format': 1,
        'storeKey': key,
        'archiveDigest': intentFields[2],
        'snapshotDigest': intentFields[3],
        'target': target,
        'digest': _hash(jsonEncode(intentFields)),
      });
      // Fence old instances and queued saves even if the intent write's result
      // becomes indeterminate. Canonical bytes are still untouched here.
      _epochs[key] = (_epochs[key] ?? 0) + 1;
      if (!await _write(prefs, recoveryIntentKey, intent))
        return Act0RecoveryConfirmationOutcomeV1.notVerified;
      await _boundary('intent_verified');
      return await _resumeRecovery(prefs)
          ? Act0RecoveryConfirmationOutcomeV1.completed
          : Act0RecoveryConfirmationOutcomeV1.notVerified;
    } catch (_) {
      return Act0RecoveryConfirmationOutcomeV1.notVerified;
    }
  });

  // A failed I/O operation is not evidence of damaged progress. Only the
  // canonical resolver's format verdict on the exact snapshot permits reset.
  // Recheck the original even after a partial tombstone so our own writes do
  // not masquerade as newly readable progress on restart.
  Future<bool> _recoveryEligible(
    SharedPreferences prefs,
    String snapshot,
  ) async {
    try {
      await _resolve(prefs, inspection: _snapshotValues(snapshot));
      return false;
    } on FormatException {
      return true;
    }
  }

  Future<Act0RecoveryCopyV1> inspectRecoveryCopy() => _serial(() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    return Act0RecoveryCopyV1._(
      prefs.containsKey(damagedCopyKey),
      prefs.containsKey(recoveryIntentKey),
      jsonEncode(
        _typed(
          prefs.containsKey(damagedCopyKey)
              ? prefs.get(damagedCopyKey)
              : _absent,
        ),
      ),
    );
  });

  Future<bool> deleteRecoveryCopy(Act0RecoveryCopyV1 consent) =>
      _serial(() async {
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.reload();
          if (!consent.exists || prefs.containsKey(recoveryIntentKey))
            return false;
          final current = jsonEncode(
            _typed(
              prefs.containsKey(damagedCopyKey)
                  ? prefs.get(damagedCopyKey)
                  : _absent,
            ),
          );
          if (current != consent._value) return false;
          return await _removeVerified(prefs, damagedCopyKey);
        } catch (_) {
          return false;
        }
      });

  Future<bool> _resumeRecovery(SharedPreferences prefs) async {
    try {
      await prefs.reload();
      final archive = prefs.get(damagedCopyKey);
      final rawIntent = prefs.get(recoveryIntentKey);
      if (archive is! String || rawIntent is! String) return false;
      final snapshot = _archiveSnapshot(archive);
      final intent = jsonDecode(rawIntent);
      if (intent is! Map ||
          intent.length != 6 ||
          intent['format'] != 1 ||
          intent['storeKey'] != key)
        return false;
      final target = _targetTombstone(snapshot);
      final fields = [1, key, _hash(archive), _hash(snapshot), target];
      if (intent['archiveDigest'] != fields[2] ||
          intent['snapshotDigest'] != fields[3] ||
          intent['target'] != target ||
          intent['digest'] != _hash(jsonEncode(fields)) ||
          !await _recoveryEligible(prefs, snapshot))
        return false;
      _epochs[key] = (_epochs[key] ?? 0) + 1;
      // Never take _commit's corrupt-head rollback path during recovery.
      for (final entry in [
        (headKey, 'head_verified'),
        (recoveryKey, 'recovery_verified'),
        (backupKey, 'backup_verified'),
      ]) {
        await prefs.reload();
        if (prefs.get(damagedCopyKey) != archive ||
            prefs.get(recoveryIntentKey) != rawIntent ||
            !_validRecoveryPrefix(prefs, snapshot, target) ||
            !await _recoveryEligible(prefs, snapshot))
          return false;
        if (prefs.get(entry.$1) != target &&
            !await _write(prefs, entry.$1, target))
          return false;
        await _boundary(entry.$2);
      }
      await prefs.reload();
      if (prefs.get(damagedCopyKey) != archive ||
          prefs.get(recoveryIntentKey) != rawIntent ||
          !_validRecoveryPrefix(prefs, snapshot, target) ||
          !await _recoveryEligible(prefs, snapshot) ||
          ![
            headKey,
            recoveryKey,
            backupKey,
          ].every((k) => prefs.get(k) == target))
        return false;
      if (!await _removeVerified(prefs, key)) return false;
      await _boundary('legacy_removed');
      await prefs.reload();
      if (prefs.get(damagedCopyKey) != archive ||
          prefs.get(recoveryIntentKey) != rawIntent ||
          prefs.containsKey(key) ||
          ![
            headKey,
            recoveryKey,
            backupKey,
          ].every((k) => prefs.get(k) == target))
        return false;
      if (!await _removeVerified(prefs, recoveryIntentKey)) return false;
      await _boundary('intent_removed');
      await prefs.reload();
      return prefs.get(damagedCopyKey) == archive &&
          !prefs.containsKey(recoveryIntentKey) &&
          !prefs.containsKey(key) &&
          [
            headKey,
            recoveryKey,
            backupKey,
          ].every((k) => prefs.get(k) == target);
    } catch (_) {
      return false;
    }
  }

  bool _validRecoveryPrefix(
    SharedPreferences prefs,
    String snapshot,
    String target,
  ) {
    final original = _snapshotValues(snapshot);
    var originalSeen = false;
    for (final k in [headKey, recoveryKey, backupKey]) {
      final value = prefs.containsKey(k) ? prefs.get(k) : _absent;
      if (value == target) {
        if (originalSeen)
          return false; // A later stage cannot precede its fence.
      } else {
        originalSeen = true;
        if (jsonEncode(_typed(value)) != jsonEncode(_typed(original[k])))
          return false;
      }
    }
    final legacy = prefs.containsKey(key) ? prefs.get(key) : _absent;
    if (jsonEncode(_typed(legacy)) == jsonEncode(_typed(original[key])))
      return true;
    return identical(legacy, _absent) &&
        [headKey, recoveryKey, backupKey].every((k) => prefs.get(k) == target);
  }

  Future<bool> _removeVerified(SharedPreferences prefs, String target) async {
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        await prefs.remove(target);
      } catch (_) {
        /* readback decides */
      }
      try {
        await prefs.reload();
        if (!prefs.containsKey(target)) return true;
      } catch (_) {
        return false;
      }
    }
    return false;
  }

  Future<void> _boundary(String stage) async {
    await debugRecoveryBoundary?.call(stage);
  }

  static String _hash(String raw) =>
      sha256.convert(utf8.encode(raw)).toString();

  String _snapshot(SharedPreferences prefs) => jsonEncode([
    for (final k in _protectedKeys)
      [k, _typed(prefs.containsKey(k) ? prefs.get(k) : _absent)],
  ]);

  Map<String, Object?> _snapshotValues(String raw) {
    final rows = jsonDecode(raw);
    if (rows is! List || rows.length != _protectedKeys.length)
      throw const Act0RecoveryHoldV1();
    final result = <String, Object?>{};
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      if (row is! List || row.length != 2 || row[0] != _protectedKeys[i])
        throw const Act0RecoveryHoldV1();
      result[row[0] as String] = _untyped(row[1]);
    }
    return result;
  }

  String _archiveSnapshot(String raw) {
    final archive = jsonDecode(raw);
    if (archive is! Map ||
        archive.length != 4 ||
        archive['format'] != 1 ||
        archive['storeKey'] != key)
      throw const Act0RecoveryHoldV1();
    final snapshot = jsonEncode(archive['snapshot']);
    final values = _snapshotValues(snapshot);
    final canonical = jsonEncode([
      for (final k in _protectedKeys) [k, _typed(values[k])],
    ]);
    if (canonical != snapshot ||
        archive['digest'] != _hash(jsonEncode([1, key, canonical])))
      throw const Act0RecoveryHoldV1();
    return canonical;
  }

  String _targetTombstone(String snapshot) {
    var highest = 0;
    final values = _snapshotValues(snapshot);
    for (final k in [headKey, recoveryKey, backupKey]) {
      final value = values[k];
      if (value is! String) continue;
      Object? decoded;
      try {
        decoded = jsonDecode(value);
      } catch (_) {
        continue;
      }
      final revision = decoded is Map ? decoded['revision'] : null;
      if (revision is num && revision >= _maxRevision)
        throw const Act0RecoveryHoldV1();
      if (revision is int && revision > highest) highest = revision;
    }
    return _envelope(highest + 1, null);
  }

  static Map<String, Object?> _typed(Object? value) {
    if (identical(value, _absent)) return {'t': 'absent'};
    if (value is String) return {'t': 'string', 'v': value};
    if (value is bool) return {'t': 'bool', 'v': value};
    if (value is int) return {'t': 'int', 'v': value.toString()};
    if (value is double) {
      final bytes = ByteData(8)..setFloat64(0, value, Endian.big);
      return {
        't': 'double',
        'v': bytes.buffer
            .asUint8List()
            .map((b) => b.toRadixString(16).padLeft(2, '0'))
            .join(),
      };
    }
    if (value is List && value.every((v) => v is String))
      return {'t': 'strings', 'v': List<String>.from(value)};
    throw const Act0RecoveryHoldV1();
  }

  static Object? _untyped(Object? raw) {
    if (raw is! Map) throw const Act0RecoveryHoldV1();
    final type = raw['t'], v = raw['v'];
    if (type == 'absent' && raw.length == 1) return _absent;
    if (raw.length != 2) throw const Act0RecoveryHoldV1();
    if (type == 'string' && v is String) return v;
    if (type == 'bool' && v is bool) return v;
    if (type == 'int' && v is String) {
      final n = int.tryParse(v);
      if (n != null && n.toString() == v) return n;
    }
    if (type == 'double' &&
        v is String &&
        RegExp(r'^[0-9a-f]{16}$').hasMatch(v)) {
      final bytes = Uint8List.fromList([
        for (var i = 0; i < 16; i += 2)
          int.parse(v.substring(i, i + 2), radix: 16),
      ]);
      return ByteData.sublistView(bytes).getFloat64(0, Endian.big);
    }
    if (type == 'strings' && v is List && v.every((x) => x is String))
      return List<String>.from(v);
    throw const Act0RecoveryHoldV1();
  }

  Future<bool> _commit(
    SharedPreferences prefs,
    int revision,
    String? payload, {
    String? previousRaw,
  }) async {
    final raw = _envelope(revision, payload);
    // Publish the revision fence first. If a checkpoint write then fails, a
    // later read can distinguish the attempted state from an older survivor,
    // even if the only checkpoint that reached the new revision is corrupted.
    if (!await _write(prefs, headKey, raw)) {
      await _restoreHead(prefs, previousRaw);
      return false;
    }
    if (!await _write(prefs, recoveryKey, raw)) {
      // Recovery did not reach the new state; when the previous state was
      // verified, release the fence so that state remains readable.
      await _restoreHead(prefs, previousRaw);
      return false;
    }
    if (!await _write(prefs, backupKey, raw)) return false;
    if (payload != null) {
      try {
        await prefs.setString(key, payload);
      } catch (_) {
        /* compatibility mirror only */
      }
    }
    return true;
  }

  Future<void> _restoreHead(
    SharedPreferences prefs,
    String? previousRaw,
  ) async {
    if (previousRaw != null) {
      await _write(prefs, headKey, previousRaw);
      return;
    }
    try {
      await prefs.remove(headKey);
      await prefs.reload();
    } catch (_) {
      // If rollback cannot be verified, subsequent loads fail closed.
    }
  }

  /// Landed means the durable bytes equal [value], whatever the call returned.
  Future<bool> _write(
    SharedPreferences prefs,
    String target,
    String value,
  ) async {
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        await prefs.setString(target, value);
      } catch (_) {
        /* verified by reload below */
      }
      try {
        await prefs.reload();
        if (prefs.getString(target) == value) return true;
      } catch (_) {
        return false;
      }
    }
    return false;
  }

  // Test fixtures only: builds a valid checkpoint envelope.
  static String debugEnvelopeV1(int revision, String? payload) =>
      _envelope(revision, payload);

  static String _envelope(int revision, String? payload) => jsonEncode({
    'format': 1,
    'revision': revision,
    'payload': payload,
    'digest': _digest(revision, payload),
  });

  ({int revision, String? payload, String raw})? _parse(
    SharedPreferences prefs,
    String target,
  ) {
    return _parseValue(prefs.get(target));
  }

  ({int revision, String? payload, String raw})? _parseValue(Object? raw) {
    try {
      if (raw is! String) return null;
      final map = jsonDecode(raw);
      if (map is! Map || map['format'] != 1) return null;
      final revision = map['revision'];
      final payload = map['payload'];
      if (revision is! int ||
          revision < 1 ||
          revision > _maxRevision ||
          (payload != null && payload is! String) ||
          map['digest'] != _digest(revision, payload as String?) ||
          (payload != null && !isValidPayload(payload))) {
        return null;
      }
      return (revision: revision, payload: payload, raw: raw);
    } catch (_) {
      return null;
    }
  }

  /// A reset over unreadable or conflicting copies must still outrank every
  /// revision on disk, otherwise the tombstone would lose to the old copy.
  int _highestRevision(SharedPreferences prefs) {
    var highest = 0;
    for (final target in [headKey, recoveryKey, backupKey]) {
      try {
        final raw = jsonDecode(prefs.getString(target) ?? '');
        final revision = raw is Map ? raw['revision'] : null;
        if (revision is int && revision > highest) highest = revision;
      } catch (_) {}
    }
    return highest;
  }

  /// Arbitrates the two copies and returns the state only once it is safe.
  /// An immutable [inspection] uses the same selection rules without healing.
  /// Readable survivors are protected even when a later retry needs to heal.
  Future<({int revision, String? payload})> _resolve(
    SharedPreferences prefs, {
    Map<String, Object?>? inspection,
  }) async {
    final values =
        inspection ??
        {
          for (final k in _protectedKeys)
            k: prefs.containsKey(k) ? prefs.get(k) : _absent,
        };
    final head = _parseValue(values[headKey]);
    final rec = _parseValue(values[recoveryKey]);
    final bak = _parseValue(values[backupKey]);
    if (!identical(values[headKey], _absent) && head == null) {
      throw const FormatException('Invalid progress checkpoint head');
    }
    if (head != null) {
      // The head is a durable fence for the latest attempted commit. A stale
      // but valid checkpoint must never be exposed when the fenced copy was
      // lost or corrupted.
      final matching = [
        rec,
        bak,
      ].where((copy) => copy != null && copy.raw == head.raw);
      if (matching.isEmpty) {
        throw const FormatException('No checkpoint matches progress head');
      }
      if (inspection != null)
        return (revision: head.revision, payload: head.payload);
      for (final target in [recoveryKey, backupKey]) {
        if (_parse(prefs, target)?.raw != head.raw &&
            !await _write(prefs, target, head.raw)) {
          throw const _CheckpointHealFailure();
        }
      }
      if (_parse(prefs, headKey)?.raw != head.raw ||
          _parse(prefs, recoveryKey)?.raw != head.raw ||
          _parse(prefs, backupKey)?.raw != head.raw) {
        throw const _CheckpointHealFailure();
      }
      return (revision: head.revision, payload: head.payload);
    }
    if (rec != null && bak != null) {
      if (rec.revision == bak.revision) {
        if (rec.payload != bak.payload) {
          throw const FormatException('Conflicting progress checkpoints');
        }
        return (revision: rec.revision, payload: rec.payload);
      }
      // Mandatory heal: the lower copy must never be exposed or survive.
      final high = rec.revision > bak.revision ? rec : bak;
      final lowKey = identical(high, rec) ? backupKey : recoveryKey;
      if (inspection != null)
        return (revision: high.revision, payload: high.payload);
      if (!await _write(prefs, lowKey, high.raw) ||
          _parse(prefs, recoveryKey)?.raw != high.raw ||
          _parse(prefs, backupKey)?.raw != high.raw) {
        throw const _CheckpointHealFailure();
      }
      return (revision: high.revision, payload: high.payload);
    }
    final only = rec ?? bak;
    if (only != null) {
      // A surviving copy is not independently readable proof until its twin
      // has landed and been reloaded. In particular, do not expose completion
      // or XP after an interrupted legacy write if storage still refuses heal.
      final twin = identical(only, rec) ? backupKey : recoveryKey;
      // An immutable inspection only classifies a readable survivor; it never
      // writes and is not a snapshot for display (#380 + #417).
      if (inspection != null)
        return (revision: only.revision, payload: only.payload);
      if (!await _write(prefs, twin, only.raw) ||
          _parse(prefs, recoveryKey)?.raw != only.raw ||
          _parse(prefs, backupKey)?.raw != only.raw) {
        throw const _CheckpointHealFailure();
      }
      return (revision: only.revision, payload: only.payload);
    }
    if (!identical(values[recoveryKey], _absent) ||
        !identical(values[backupKey], _absent)) {
      throw const FormatException('No valid progress checkpoint');
    }
    final legacy = values[key];
    if (identical(legacy, _absent) || legacy == '')
      return (revision: 0, payload: null);
    if (legacy is! String || !isValidPayload(legacy)) {
      throw const FormatException('Invalid legacy progress');
    }
    return (revision: 0, payload: legacy);
  }

  static String _digest(int revision, String? payload) => sha256
      .convert(utf8.encode(jsonEncode([1, revision, payload])))
      .toString();
}

import 'dart:async';
import 'dart:convert';

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

class Act0ProgressStoreV1 {
  Act0ProgressStoreV1({required this.key, required this.isValidPayload});

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

  Future<String?> load() => _serial(() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload(); // Read durable platform data, not a write cache.
    return (await _resolve(prefs)).payload;
  });

  Future<bool> save(String payload) => _serial(() async {
    if (!isValidPayload(payload)) return false;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      final current = await _resolve(prefs);
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
    try {
      final raw = prefs.getString(target);
      if (raw == null) return null;
      final map = jsonDecode(raw);
      if (map is! Map || map['format'] != 1) return null;
      final revision = map['revision'];
      final payload = map['payload'];
      if (revision is! int ||
          revision < 1 ||
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
  Future<({int revision, String? payload})> _resolve(
    SharedPreferences prefs,
  ) async {
    final head = _parse(prefs, headKey);
    final rec = _parse(prefs, recoveryKey);
    final bak = _parse(prefs, backupKey);
    if (prefs.containsKey(headKey) && head == null) {
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
      if (!await _write(prefs, lowKey, high.raw) ||
          _parse(prefs, recoveryKey)?.raw != high.raw ||
          _parse(prefs, backupKey)?.raw != high.raw) {
        throw const _CheckpointHealFailure();
      }
      return (revision: high.revision, payload: high.payload);
    }
    final only = rec ?? bak;
    if (only != null) {
      // Single valid copy: nothing older can resurrect. Heal the twin if we can.
      final twin = identical(only, rec) ? backupKey : recoveryKey;
      await _write(prefs, twin, only.raw);
      return (revision: only.revision, payload: only.payload);
    }
    if (prefs.containsKey(recoveryKey) || prefs.containsKey(backupKey)) {
      throw const FormatException('No valid progress checkpoint');
    }
    final legacy = prefs.getString(key);
    if (legacy == null || legacy.isEmpty) return (revision: 0, payload: null);
    if (!isValidPayload(legacy)) {
      throw const FormatException('Invalid legacy progress');
    }
    return (revision: 0, payload: legacy);
  }

  static String _digest(int revision, String? payload) => sha256
      .convert(utf8.encode(jsonEncode([1, revision, payload])))
      .toString();
}

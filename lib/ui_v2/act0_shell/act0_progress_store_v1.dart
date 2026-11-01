import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Storage protocol only: it never merges progress, awards XP or grades evidence.
/// Two acknowledged, independently validated copies hold the same immutable
/// source snapshot. The old key remains a compatibility mirror, not a second
/// progress authority. A malformed protected store never falls back to that
/// unauthenticated mirror.
class Act0ProgressStoreV1 {
  Act0ProgressStoreV1({required this.key, required this.isValidPayload});

  final String key;
  final bool Function(String) isValidPayload;
  static final _queues = <String, Future<void>>{};
  String get recoveryKey => '${key}_recovery';
  String get backupKey => '${key}_backup';

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
    await prefs
        .reload(); // Read acknowledged platform data, not a failed-write cache.
    return _read(prefs).payload;
  });

  Future<bool> save(String payload) => _serial(() async {
    if (!isValidPayload(payload)) return false;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      final previous = _read(prefs);
      return await _commit(prefs, previous.revision + 1, payload);
    } catch (_) {
      return false; // Preserve unreadable bytes; never replace them with defaults.
    }
  });

  /// An explicit user reset is itself an ordered durable tombstone. Removing
  /// keys one by one would allow an interrupted reset to resurrect old awards.
  Future<bool> clear() => _serial(() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    var revision = 0;
    try {
      revision = _read(prefs).revision;
    } catch (_) {
      revision = _highestRevision(prefs);
    }
    final committed = await _commit(prefs, revision + 1, null);
    if (committed) await prefs.remove(key);
    return committed;
  });

  Future<bool> _commit(
    SharedPreferences prefs,
    int revision,
    String? payload,
  ) async {
    final raw = jsonEncode({
      'format': 1,
      'revision': revision,
      'payload': payload,
      'digest': _digest(revision, payload),
    });
    if (!await _put(prefs, recoveryKey, raw)) return false;
    // Once recovery is acknowledged, the transaction is durable even if a
    // crash interrupts the redundant-copy or legacy-mirror writes.
    await _put(prefs, backupKey, raw);
    if (payload != null) await _put(prefs, key, payload);
    return true;
  }

  Future<bool> _put(
    SharedPreferences prefs,
    String target,
    String value,
  ) async {
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        if (await prefs.setString(target, value)) return true;
      } catch (_) {
        /* retry same bytes */
      }
    }
    await prefs.reload();
    return false;
  }

  /// A reset over unreadable or conflicting copies must still outrank every
  /// revision on disk, otherwise the tombstone would lose to the old copy.
  int _highestRevision(SharedPreferences prefs) {
    var highest = 0;
    for (final target in [recoveryKey, backupKey]) {
      try {
        final raw = jsonDecode(prefs.getString(target) ?? '');
        final revision = raw is Map ? raw['revision'] : null;
        if (revision is int && revision > highest) highest = revision;
      } catch (_) {}
    }
    return highest;
  }

  ({int revision, String? payload}) _read(SharedPreferences prefs) {
    final candidates = <({int revision, String? payload})>[];
    var protected = false;
    for (final target in [recoveryKey, backupKey]) {
      if (!prefs.containsKey(target)) continue;
      protected = true;
      try {
        final raw = jsonDecode(prefs.getString(target)!);
        if (raw is! Map || raw['format'] != 1) continue;
        final revision = raw['revision'];
        final payload = raw['payload'];
        if (revision is! int ||
            revision < 1 ||
            (payload != null && payload is! String) ||
            raw['digest'] != _digest(revision, payload as String?) ||
            (payload != null && !isValidPayload(payload)))
          continue;
        candidates.add((revision: revision, payload: payload));
      } catch (_) {
        /* another independently valid copy may recover it */
      }
    }
    candidates.sort((a, b) => b.revision.compareTo(a.revision));
    if (candidates.isNotEmpty) {
      final latest = candidates.first;
      if (candidates.any(
        (c) => c.revision == latest.revision && c.payload != latest.payload,
      )) {
        throw const FormatException('Conflicting progress checkpoints');
      }
      return latest;
    }
    if (protected) throw const FormatException('No valid progress checkpoint');
    final legacy = prefs.getString(key);
    if (legacy == null || legacy.isEmpty) return (revision: 0, payload: null);
    if (!isValidPayload(legacy))
      throw const FormatException('Invalid legacy progress');
    return (revision: 0, payload: legacy);
  }

  static String _digest(int revision, String? payload) => sha256
      .convert(utf8.encode(jsonEncode([1, revision, payload])))
      .toString();
}

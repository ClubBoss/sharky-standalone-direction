import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

import 'cloud_retry_policy.dart';
import '../models/saved_hand.dart';
import '../models/session_log.dart';
import 'pack_launch_history_sync_service.dart';
import 'mistake_history_sync_service.dart';

class CloudSyncService {
  CloudSyncService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    bool firebaseReady = true,
  }) : _db = (CloudSyncService.isLocal || !firebaseReady)
           ? null
           : (firestore ?? FirebaseFirestore.instance),
       _auth = (CloudSyncService.isLocal || !firebaseReady)
           ? null
           : (auth ?? FirebaseAuth.instance);

  static const _cols = [
    'training_spots',
    'training_stats',
    'xp_history',
    'preferences',
    'saved_hands',
    'session_notes',
    'session_logs',
    'pinned_sessions',
    'evaluation_queue',
  ];

  final FirebaseFirestore? _db;
  final FirebaseAuth? _auth;
  late SharedPreferences _prefs;
  Box? _box;
  bool _storageReady = false;
  bool _storageDegraded = false;
  bool _storageErrorLogged = false;
  bool _initAttempted = false;
  static bool get isLocal =>
      kIsWeb ||
      (!kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.windows ||
              defaultTargetPlatform == TargetPlatform.linux ||
              defaultTargetPlatform == TargetPlatform.macOS));
  bool get _local => CloudSyncService.isLocal;
  String? get uid => _auth?.currentUser?.uid;
  bool get isEnabled => uid != null;
  final List<Map<String, dynamic>> _pending = [];
  final ValueNotifier<DateTime?> lastSync = ValueNotifier(null);
  final ValueNotifier<double> progress = ValueNotifier(0);
  final ValueNotifier<String?> syncMessage = ValueNotifier(null);
  late final Connectivity _conn;
  StreamSubscription<List<ConnectivityResult>>? _connSub;

  void _notify(String message) {
    syncMessage.value = message;
    Future.delayed(const Duration(seconds: 3), () {
      if (syncMessage.value == message) syncMessage.value = null;
    });
  }

  bool _isHiveLockError(Object error) {
    final message = error.toString().toLowerCase();
    return message.contains('errno = 35') ||
        message.contains('errno=35') ||
        message.contains('errno 35') ||
        message.contains('lock failed') ||
        message.contains('resource temporarily unavailable');
  }

  void _logStorageDegradedOnce(String reason) {
    _storageDegraded = true;
    if (_storageErrorLogged) return;
    _storageErrorLogged = true;
    debugPrint('CloudSyncService.init storage degraded: $reason');
  }

  Future<T?> _runHiveGuarded<T>(Future<T> Function() action) async {
    Object? capturedError;
    T? result;
    await runZonedGuarded(
      () async {
        try {
          result = await action();
        } catch (error) {
          capturedError = error;
        }
      },
      (error, _) {
        capturedError ??= error;
      },
    );

    final error = capturedError;
    if (error == null) return result;
    final reason = _isHiveLockError(error)
        ? 'cloud_cache lock busy; local sync cache disabled for this run.'
        : 'local sync cache disabled.';
    _logStorageDegradedOnce(reason);
    return null;
  }

  Future<Box?> _openCloudCacheBoxWithRetry() async {
    const int maxAttempts = 3;
    final hiveReady = await _runHiveGuarded<bool>(() async {
      await Hive.initFlutter();
      return true;
    });
    if (hiveReady != true) return null;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      final opened = await _runHiveGuarded<Box>(
        () => Hive.openBox('cloud_cache'),
      );
      if (opened != null) return opened;
      if (_storageDegraded || attempt == maxAttempts) return null;
      await Future.delayed(Duration(milliseconds: 200 * attempt));
    }
    return null;
  }

  Future<void> init() async {
    if (_initAttempted) return;
    _initAttempted = true;
    try {
      if (_local) {
        _box = await _openCloudCacheBoxWithRetry();
        if (_box == null) {
          _storageReady = false;
          progress.value = -1;
          if (!_storageDegraded) {
            _logStorageDegradedOnce(
              'cloud_cache lock busy; local sync cache disabled for this run.',
            );
          }
          return;
        }
        final box = _box;
        if (box != null) {
          final list = (box.get('pending_mutations') as List?) ?? [];
          _pending
            ..clear()
            ..addAll(list.cast<Map>().map(Map<String, dynamic>.from));
          final ts = box.get('last_sync') as String?;
          if (ts != null) lastSync.value = DateTime.tryParse(ts);
        }
      } else {
        _prefs = await SharedPreferences.getInstance();
        final db = _db;
        if (db != null) {
          db.settings = const Settings(persistenceEnabled: true);
        }
        final list = _prefs.getStringList('pending_mutations') ?? [];
        _pending
          ..clear()
          ..addAll(list.map((e) => jsonDecode(e) as Map<String, dynamic>));
        final ts = _prefs.getString('last_sync');
        if (ts != null) lastSync.value = DateTime.tryParse(ts);
      }
      _storageReady = true;
    } catch (error) {
      _storageReady = false;
      progress.value = -1;
      final lockReason = _isHiveLockError(error)
          ? 'cloud_cache lock busy; local sync cache disabled for this run.'
          : 'local sync cache disabled.';
      _logStorageDegradedOnce(lockReason);
      return;
    }
    _conn = Connectivity();
    _connSub = _conn.onConnectivityChanged.listen((r) async {
      try {
        final hasConnection =
            r.isNotEmpty && !r.contains(ConnectivityResult.none);
        if (hasConnection && _pending.isNotEmpty) await syncUp();
        if (hasConnection &&
            (lastSync.value == null ||
                DateTime.now().difference(lastSync.value!) >
                    const Duration(hours: 6))) {
          await syncDown();
        }
      } catch (error) {
        if (_isHiveLockError(error)) {
          _logStorageDegradedOnce(
            'cloud_cache lock busy; local sync cache disabled for this run.',
          );
        }
      }
    });

    final firebaseReady =
        !_local && Firebase.apps.isNotEmpty && _db != null && _auth != null;
    if (!firebaseReady) return;
    await PackLaunchHistorySyncService(
      uid: uid,
      firebaseReady: firebaseReady,
    ).sync();
    await MistakeHistorySyncService(
      uid: uid,
      firebaseReady: firebaseReady,
    ).sync();
  }

  Future<void> syncUp() async {
    if (!_storageReady || _storageDegraded || _pending.isEmpty || uid == null) {
      return;
    }
    progress.value = 1;
    if (_local) {
      final box = _box;
      if (box == null) return;
      try {
        for (final m in _pending) {
          await box.put('${m['col']}_${m['id']}', m['data']);
          await box.put('cached_${m['col']}', m['data']);
        }
        _pending.clear();
        await box.put('pending_mutations', _pending);
        lastSync.value = DateTime.now();
        await box.put('last_sync', lastSync.value!.toIso8601String());
      } catch (error) {
        if (_isHiveLockError(error)) {
          _storageReady = false;
          _logStorageDegradedOnce(
            'cloud_cache lock busy; local sync cache disabled for this run.',
          );
        }
        return;
      }
      _notify('Synced changes to cloud');
      return;
    }
    final db = _db;
    if (db == null) return;
    final user = db.collection('users').doc(uid);
    final batch = db.batch();
    for (final m in _pending) {
      final ref = user.collection(m['col'] as String).doc(m['id'] as String);
      batch.set(
        ref,
        m['data'] as Map<String, dynamic>,
        SetOptions(merge: true),
      );
    }
    try {
      await batch.commit();
      _pending.clear();
      await _prefs.setStringList('pending_mutations', []);
      lastSync.value = DateTime.now();
      await _prefs.setString('last_sync', lastSync.value!.toIso8601String());
    } catch (_) {
      progress.value = -1;
      return;
    }
    progress.value = 0;
    _notify('Synced changes to cloud');
  }

  Future<void> syncDown() async {
    if (!_storageReady || _storageDegraded || uid == null) return;
    progress.value = 1;
    if (_local) {
      final box = _box;
      if (box == null) return;
      String? ts;
      try {
        ts = box.get('last_sync') as String?;
      } catch (error) {
        if (_isHiveLockError(error)) {
          _storageReady = false;
          _logStorageDegradedOnce(
            'cloud_cache lock busy; local sync cache disabled for this run.',
          );
        }
        return;
      }
      if (ts != null) lastSync.value = DateTime.tryParse(ts);
      progress.value = 0;
      _notify('Loaded latest from cloud');
      return;
    }
    try {
      final db = _db;
      if (db == null) return;
      await CloudRetryPolicy.execute<void>(() async {
        final user = db.collection('users').doc(uid);
        final futures = [
          for (final c in _cols) user.collection(c).doc('main').get(),
        ];
        final snaps = await Future.wait(futures);
        for (var i = 0; i < snaps.length; i++) {
          final col = _cols[i];
          final snap = snaps[i];
          if (!snap.exists) continue;
          final remote = snap.data();
          final localStr = _prefs.getString('cached_$col');
          final local = localStr != null
              ? jsonDecode(localStr) as Map<String, dynamic>
              : null;
          final remoteAt =
              DateTime.tryParse(remote?['updatedAt'] as String? ?? '') ??
              DateTime.fromMillisecondsSinceEpoch(0);
          final localAt =
              DateTime.tryParse(local?['updatedAt'] as String? ?? '') ??
              DateTime.fromMillisecondsSinceEpoch(0);
          if (remoteAt.isAfter(localAt)) {
            await _prefs.setString('cached_$col', jsonEncode(remote));
          }
        }
        final ts = _prefs.getString('last_sync');
        if (ts != null) lastSync.value = DateTime.tryParse(ts);
      });
    } catch (_) {
      progress.value = -1;
      return;
    }
    progress.value = 0;
    _notify('Loaded latest from cloud');
  }

  Future<void> queueMutation(
    String col,
    String id,
    Map<String, dynamic> data,
  ) async {
    if (!_storageReady || _storageDegraded) return;
    _pending.removeWhere((e) => e['col'] == col && e['id'] == id);
    _pending.add({'col': col, 'id': id, 'data': data});
    if (_local) {
      final box = _box;
      if (box == null) return;
      try {
        await box.put('pending_mutations', _pending);
        await box.put('cached_$col', data);
      } catch (error) {
        if (_isHiveLockError(error)) {
          _storageReady = false;
          _logStorageDegradedOnce(
            'cloud_cache lock busy; local sync cache disabled for this run.',
          );
        }
      }
    } else {
      await _prefs.setStringList(
        'pending_mutations',
        _pending.map(jsonEncode).toList(),
      );
      await _prefs.setString('cached_$col', jsonEncode(data));
    }
  }

  Map<String, dynamic>? getCached(String col) {
    if (!_storageReady || _storageDegraded) return null;
    if (_local) {
      final box = _box;
      if (box == null) return null;
      dynamic val;
      try {
        val = box.get('cached_$col');
      } catch (error) {
        if (_isHiveLockError(error)) {
          _storageReady = false;
          _logStorageDegradedOnce(
            'cloud_cache lock busy; local sync cache disabled for this run.',
          );
        }
        return null;
      }
      if (val is Map) return Map<String, dynamic>.from(val);
      if (val is String) return jsonDecode(val) as Map<String, dynamic>;
      return null;
    }
    final str = _prefs.getString('cached_$col');
    return str != null ? jsonDecode(str) as Map<String, dynamic> : null;
  }

  void watchChanges() {
    if (!_storageReady || _local || uid == null) return;
    final db = _db;
    if (db == null) return;
    for (final col in _cols) {
      db
          .collection('users')
          .doc(uid)
          .collection(col)
          .doc('main')
          .snapshots()
          .listen((snap) async {
            if (!snap.exists) return;
            await _prefs.setString('cached_$col', jsonEncode(snap.data()));
            lastSync.value = DateTime.now();
            await _prefs.setString(
              'last_sync',
              lastSync.value!.toIso8601String(),
            );
          });
    }
  }

  void dispose() {
    _connSub?.cancel();
  }

  Future<void> save(String key, String value) async {
    if (!_storageReady || _storageDegraded) return;
    if (_local) {
      final box = _box;
      if (box == null) return;
      try {
        await box.put(key, value);
      } catch (error) {
        if (_isHiveLockError(error)) {
          _storageReady = false;
          _logStorageDegradedOnce(
            'cloud_cache lock busy; local sync cache disabled for this run.',
          );
        }
      }
      return;
    }
    final db = _db;
    if (db == null) return;
    await _prefs.setString(key, value);
    if (uid == null) return;
    await CloudRetryPolicy.execute(
      () => db.collection('users').doc(uid).collection('prefs').doc(key).set({
        'v': value,
      }),
    );
  }

  Future<String?> load(String key) async {
    if (!_storageReady || _storageDegraded) return null;
    if (_local) {
      final box = _box;
      if (box == null) return null;
      dynamic val;
      try {
        val = box.get(key);
      } catch (error) {
        if (_isHiveLockError(error)) {
          _storageReady = false;
          _logStorageDegradedOnce(
            'cloud_cache lock busy; local sync cache disabled for this run.',
          );
        }
        return null;
      }
      if (val is String) return val;
      return null;
    }
    final db = _db;
    if (db == null) return _prefs.getString(key);
    final local = _prefs.getString(key);
    if (uid == null) return local;
    try {
      final snap = await CloudRetryPolicy.execute(
        () =>
            db.collection('users').doc(uid).collection('prefs').doc(key).get(),
      );
      final data = snap.data();
      if (data != null && data['v'] is String) {
        final v = data['v'] as String;
        await _prefs.setString(key, v);
        return v;
      }
    } catch (_) {}
    return local;
  }

  Future<void> uploadHands(List<SavedHand> hands) async {
    await queueMutation('saved_hands', 'main', {
      'hands': [for (final h in hands) h.toJson()],
      'updatedAt': DateTime.now().toIso8601String(),
    });
    await syncUp();
  }

  Future<List<SavedHand>> downloadHands() async {
    final db = _db;
    if (!_storageReady || db == null || uid == null) return [];
    final snap = await CloudRetryPolicy.execute(
      () => db
          .collection('users')
          .doc(uid)
          .collection('saved_hands')
          .doc('main')
          .get(),
    );
    if (!snap.exists) return [];
    final data = snap.data();
    final list = data?['hands'];
    if (list is List) {
      return [
        for (final e in list)
          if (e is Map) SavedHand.fromJson(Map<String, dynamic>.from(e)),
      ];
    }
    return [];
  }

  Future<List<SavedHand>> loadHands() async {
    if (!_storageReady) return [];
    final cached = getCached('saved_hands');
    var hands = <SavedHand>[];
    var localAt = DateTime.fromMillisecondsSinceEpoch(0);
    if (cached != null) {
      final list = cached['hands'];
      if (list is List) {
        hands = [
          for (final e in list)
            if (e is Map) SavedHand.fromJson(Map<String, dynamic>.from(e)),
        ];
      }
      localAt =
          DateTime.tryParse(cached['updatedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0);
    }
    if (uid == null) return hands;
    final db = _db;
    if (db == null) return hands;
    final snap = await CloudRetryPolicy.execute(
      () => db
          .collection('users')
          .doc(uid)
          .collection('saved_hands')
          .doc('main')
          .get(),
    );
    if (snap.exists) {
      final remote = snap.data();
      final remoteAt =
          DateTime.tryParse(remote?['updatedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0);
      if (remoteAt.isAfter(localAt)) {
        final list = remote?['hands'];
        if (list is List) {
          hands = [
            for (final e in list)
              if (e is Map) SavedHand.fromJson(Map<String, dynamic>.from(e)),
          ];
          if (_local) {
            final box = _box;
            if (box != null) {
              try {
                await box.put('cached_saved_hands', remote);
              } catch (error) {
                if (_isHiveLockError(error)) {
                  _storageReady = false;
                  _logStorageDegradedOnce(
                    'cloud_cache lock busy; local sync cache disabled for this run.',
                  );
                }
              }
            }
          } else {
            await _prefs.setString('cached_saved_hands', jsonEncode(remote));
          }
        }
      } else if (localAt.isAfter(remoteAt)) {
        await uploadHands(hands);
      }
    }
    return hands;
  }

  Future<void> uploadSessionNotes(Map<int, String> notes) async {
    await queueMutation('session_notes', 'main', {
      'notes': {for (final e in notes.entries) e.key.toString(): e.value},
      'updatedAt': DateTime.now().toIso8601String(),
    });
    await syncUp();
  }

  Future<Map<int, String>> downloadSessionNotes() async {
    final db = _db;
    if (!_storageReady || db == null || uid == null) return {};
    final snap = await db
        .collection('users')
        .doc(uid)
        .collection('session_notes')
        .doc('main')
        .get();
    if (!snap.exists) return {};
    final data = snap.data();
    final map = <int, String>{};
    if (data?['notes'] is Map) {
      (data!['notes'] as Map).forEach((k, v) {
        map[int.parse(k as String)] = v as String;
      });
    }
    return map;
  }

  Future<void> uploadSessionLogs(List<SessionLog> logs) async {
    await queueMutation('session_logs', 'main', {
      'logs': [for (final l in logs) l.toJson()],
      'updatedAt': DateTime.now().toIso8601String(),
    });
    await syncUp();
  }

  Future<List<SessionLog>> downloadSessionLogs() async {
    final db = _db;
    if (!_storageReady || db == null || uid == null) return [];
    final snap = await db
        .collection('users')
        .doc(uid)
        .collection('session_logs')
        .doc('main')
        .get();
    if (!snap.exists) return [];
    final data = snap.data();
    final list = data?['logs'];
    if (list is List) {
      return [
        for (final e in list)
          if (e is Map) SessionLog.fromJson(Map<String, dynamic>.from(e)),
      ];
    }
    return [];
  }

  Future<void> uploadPinned(Set<int> ids) async {
    await queueMutation('pinned_sessions', 'main', {
      'ids': [for (final i in ids) i],
      'updatedAt': DateTime.now().toIso8601String(),
    });
    await syncUp();
  }

  Future<Set<int>> downloadPinned() async {
    final db = _db;
    if (!_storageReady || db == null || uid == null) return {};
    final snap = await db
        .collection('users')
        .doc(uid)
        .collection('pinned_sessions')
        .doc('main')
        .get();
    if (!snap.exists) return {};
    final data = snap.data();
    final list = data?['ids'];
    if (list is List) return {for (final i in list) (i as num).toInt()};
    return {};
  }

  Future<void> uploadQueue(Map<String, dynamic> queue) async {
    await queueMutation('evaluation_queue', 'main', {
      ...queue,
      'updatedAt': DateTime.now().toIso8601String(),
    });
    await syncUp();
  }

  Future<Map<String, dynamic>?> downloadQueue() async {
    final db = _db;
    if (!_storageReady || db == null || uid == null) return null;
    final snap = await db
        .collection('users')
        .doc(uid)
        .collection('evaluation_queue')
        .doc('main')
        .get();
    if (!snap.exists) return null;
    return snap.data();
  }

  Future<void> uploadTrainingStats(Map<String, dynamic> stats) async {
    await queueMutation('training_stats', 'main', stats);
    await syncUp();
  }

  Future<Map<String, dynamic>?> downloadTrainingStats() async {
    final db = _db;
    if (!_storageReady || db == null || uid == null) return null;
    final snap = await db
        .collection('users')
        .doc(uid)
        .collection('training_stats')
        .doc('main')
        .get();
    if (!snap.exists) return null;
    return snap.data();
  }

  Future<void> uploadXp(Map<String, dynamic> data) async {
    await queueMutation('xp_history', 'main', data);
    await syncUp();
  }

  Future<Map<String, dynamic>?> downloadXp() async {
    final db = _db;
    if (!_storageReady || db == null || uid == null) return null;
    final snap = await db
        .collection('users')
        .doc(uid)
        .collection('xp_history')
        .doc('main')
        .get();
    if (!snap.exists) return null;
    return snap.data();
  }
}

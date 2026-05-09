import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/training_history_entry_v2.dart';
import 'cloud_retry_policy.dart';
import 'training_history_service_v2.dart';

class PackLaunchHistorySyncService {
  final FirebaseFirestore? _db;
  final FirebaseAuth? _auth;
  final String? _uidOverride;
  String? get _uid => _uidOverride ?? _auth?.currentUser?.uid;

  PackLaunchHistorySyncService({
    FirebaseFirestore? firestore,
    String? uid,
    bool firebaseReady = true,
  }) : _db = firebaseReady && Firebase.apps.isNotEmpty
           ? (firestore ?? FirebaseFirestore.instance)
           : null,
       _auth = firebaseReady && Firebase.apps.isNotEmpty
           ? FirebaseAuth.instance
           : null,
       _uidOverride = uid;

  Future<void> uploadHistory(List<TrainingHistoryEntryV2> history) async {
    final db = _db;
    if (db == null || _uid == null) return;
    await CloudRetryPolicy.execute(
      () => db.collection('launchHistory').doc(_uid).set({
        'history': [for (final h in history.take(100)) h.toJson()],
        'updatedAt': DateTime.now().toIso8601String(),
      }),
    );
  }

  Future<List<TrainingHistoryEntryV2>> downloadHistory() async {
    final db = _db;
    if (db == null || _uid == null) return [];
    final snap = await CloudRetryPolicy.execute(
      () => db.collection('launchHistory').doc(_uid).get(),
    );
    if (!snap.exists) return [];
    final data = snap.data();
    final list = data?['history'];
    if (list is List) {
      return [
        for (final e in list)
          if (e is Map)
            TrainingHistoryEntryV2.fromJson(Map<String, dynamic>.from(e)),
      ];
    }
    return [];
  }

  Future<void> sync() async {
    final local = await TrainingHistoryServiceV2.getHistory(limit: 100);
    final remote = await downloadHistory();
    final map = <String, TrainingHistoryEntryV2>{};
    for (final e in local) {
      map[e.id] = e;
    }
    for (final e in remote) {
      final existing = map[e.id];
      if (existing == null || e.timestamp.isAfter(existing.timestamp)) {
        map[e.id] = e;
      }
    }
    var merged = map.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    if (merged.length > 100) merged = merged.sublist(0, 100);
    await TrainingHistoryServiceV2.replaceHistory(merged);
    await uploadHistory(merged);
  }
}

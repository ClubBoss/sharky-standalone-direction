import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'cloud_retry_policy.dart';
import 'training_stats_service.dart';

class MistakeHistorySyncService {
  final FirebaseFirestore? _db;
  final FirebaseAuth? _auth;
  final String? _uidOverride;
  String? get _uid => _uidOverride ?? _auth?.currentUser?.uid;

  MistakeHistorySyncService({
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

  Future<void> uploadMistakes(Map<String, int> mistakeCounts) async {
    final db = _db;
    if (db == null || _uid == null) return;
    await CloudRetryPolicy.execute(
      () => db.collection('mistakeHistory').doc(_uid).set({
        'counts': mistakeCounts,
        'updatedAt': DateTime.now().toIso8601String(),
      }),
    );
  }

  Future<Map<String, int>> downloadMistakes() async {
    final db = _db;
    if (db == null || _uid == null) return {};
    final snap = await CloudRetryPolicy.execute(
      () => db.collection('mistakeHistory').doc(_uid).get(),
    );
    if (!snap.exists) return {};
    final data = snap.data();
    final result = <String, int>{};
    final counts = data?['counts'];
    if (counts is Map) {
      counts.forEach((key, value) {
        result[key.toString()] = (value as num).toInt();
      });
    }
    return result;
  }

  Future<void> sync() async {
    final local = TrainingStatsService.instance?.mistakeCounts ?? {};
    final remote = await downloadMistakes();
    final merged = <String, int>{};
    for (final key in {...local.keys, ...remote.keys}) {
      final lv = local[key] ?? 0;
      final rv = remote[key] ?? 0;
      merged[key] = lv > rv ? lv : rv;
    }
    await TrainingStatsService.instance?.overwriteMistakeCounts(merged);
    await uploadMistakes(merged);
  }
}

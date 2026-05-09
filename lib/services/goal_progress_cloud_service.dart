import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'cloud_retry_policy.dart';

class GoalProgressCloudService {
  GoalProgressCloudService({bool firebaseReady = true})
    : _db = firebaseReady ? FirebaseFirestore.instance : null,
      _auth = firebaseReady ? FirebaseAuth.instance : null;

  final FirebaseFirestore? _db;
  final FirebaseAuth? _auth;
  String? get _uid => _auth?.currentUser?.uid;

  Future<List<Map<String, dynamic>>> loadGoals() async {
    final db = _db;
    if (db == null || _uid == null) return [];
    final snap = await db
        .collection('progress')
        .doc(_uid)
        .collection('goals')
        .get();
    return [for (final d in snap.docs) d.data()];
  }

  Future<void> saveProgress(Map<String, dynamic> data) async {
    final db = _db;
    if (db == null || _uid == null) return;
    final id = '${data['templateId']}_${data['goal']}'.replaceAll('/', '_');
    await CloudRetryPolicy.execute(
      () => db
          .collection('progress')
          .doc(_uid)
          .collection('goals')
          .doc(id)
          .set(data),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'cloud_retry_policy.dart';

import '../models/mistake_pack.dart';

class MistakePackCloudService {
  MistakePackCloudService({bool firebaseReady = true})
    : _db = firebaseReady ? FirebaseFirestore.instance : null,
      _auth = firebaseReady ? FirebaseAuth.instance : null;

  final FirebaseFirestore? _db;
  final FirebaseAuth? _auth;
  String? get _uid => _auth?.currentUser?.uid;

  Future<List<MistakePack>> loadPacks() async {
    final db = _db;
    if (db == null || _uid == null) return [];
    final snap = await db
        .collection('mistakes')
        .doc(_uid)
        .collection('packs')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();
    return [
      for (final d in snap.docs)
        MistakePack.fromJson({...d.data(), 'id': d.id}),
    ];
  }

  Future<void> savePack(MistakePack pack) async {
    final db = _db;
    if (db == null || _uid == null) return;
    await CloudRetryPolicy.execute(
      () => db
          .collection('mistakes')
          .doc(_uid)
          .collection('packs')
          .doc(pack.id)
          .set(pack.toJson()),
    );
  }

  Future<void> deletePack(String id) async {
    final db = _db;
    if (db == null || _uid == null) return;
    await CloudRetryPolicy.execute(
      () => db
          .collection('mistakes')
          .doc(_uid)
          .collection('packs')
          .doc(id)
          .delete(),
    );
  }

  Future<void> deleteOlderThan(DateTime cutoff) async {
    final db = _db;
    if (db == null || _uid == null) return;
    await CloudRetryPolicy.execute<void>(() async {
      final col = db.collection('mistakes').doc(_uid).collection('packs');
      final snap = await col
          .where('createdAt', isLessThan: cutoff.toIso8601String())
          .get();
      final batch = db.batch();
      for (final d in snap.docs) {
        batch.delete(col.doc(d.id));
      }
      await batch.commit();
    });
  }
}

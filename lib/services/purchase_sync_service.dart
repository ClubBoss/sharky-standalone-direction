import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../payments/payment_service.dart';
import 'auth_service.dart';
import 'user_action_logger.dart';

/// Syncs purchases to Firebase Firestore for cross-device access.
class PurchaseSyncService {
  PurchaseSyncService._();
  static final PurchaseSyncService _instance = PurchaseSyncService._();
  static PurchaseSyncService get instance => _instance;
  factory PurchaseSyncService() => _instance;

  static const String _collectionPurchases = 'purchases';

  /// Sync local purchases to Firestore.
  Future<void> syncToCloud() async {
    try {
      final authService = AuthService();
      if (!authService.isSignedIn || authService.uid == null) {
        debugPrint('PurchaseSyncService: User not signed in, skipping sync');
        return;
      }

      final userId = authService.uid!;
      final paymentService = PaymentService.instance;
      final purchases = paymentService.purchasedProductIds;

      if (purchases.isEmpty) {
        debugPrint('PurchaseSyncService: No purchases to sync');
        return;
      }

      final batch = FirebaseFirestore.instance.batch();
      for (final productId in purchases) {
        final docRef = FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection(_collectionPurchases)
            .doc(productId);

        batch.set(docRef, {
          'product_id': productId,
          'purchased_at': FieldValue.serverTimestamp(),
          'platform': defaultTargetPlatform.name,
          'synced_at': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      await batch.commit();
      await UserActionLogger.instance.logEvent({
        'event': 'purchases_synced_to_cloud',
        'count': purchases.length,
      });

      debugPrint('PurchaseSyncService: Synced ${purchases.length} purchases');
    } catch (e, stackTrace) {
      debugPrint('PurchaseSyncService: Error syncing to cloud: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// Load purchases from Firestore.
  Future<Set<String>> loadFromCloud() async {
    try {
      final authService = AuthService();
      if (!authService.isSignedIn || authService.uid == null) {
        debugPrint('PurchaseSyncService: User not signed in, skipping load');
        return {};
      }

      final userId = authService.uid!;
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection(_collectionPurchases)
          .get();

      final purchases = snapshot.docs
          .map((doc) => doc.data()['product_id'] as String?)
          .whereType<String>()
          .toSet();

      await UserActionLogger.instance.logEvent({
        'event': 'purchases_loaded_from_cloud',
        'count': purchases.length,
      });

      debugPrint(
        'PurchaseSyncService: Loaded ${purchases.length} purchases from cloud',
      );
      return purchases;
    } catch (e, stackTrace) {
      debugPrint('PurchaseSyncService: Error loading from cloud: $e');
      debugPrint('Stack trace: $stackTrace');
      return {};
    }
  }

  /// Sync purchases bidirectionally (merge local and cloud).
  Future<void> sync() async {
    try {
      // Load from cloud
      final cloudPurchases = await loadFromCloud();

      // Get local purchases
      final paymentService = PaymentService.instance;
      final localPurchases = paymentService.purchasedProductIds;

      // Merge: add cloud purchases to local if not present
      bool needsLocalUpdate = false;
      for (final productId in cloudPurchases) {
        if (!localPurchases.contains(productId)) {
          needsLocalUpdate = true;
          debugPrint('PurchaseSyncService: Adding cloud purchase: $productId');
        }
      }

      // Sync local to cloud
      await syncToCloud();

      if (needsLocalUpdate) {
        // Trigger payment service to reload/restore purchases
        await paymentService.restorePurchases();
      }

      await UserActionLogger.instance.log(
        'purchases_bidirectional_sync_complete',
      );
    } catch (e, stackTrace) {
      debugPrint('PurchaseSyncService: Error during sync: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }
}

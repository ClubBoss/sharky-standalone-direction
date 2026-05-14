import 'package:flutter/foundation.dart';
import 'package:poker_analyzer/payments/payment_service.dart';
import 'package:poker_analyzer/services/release_premium_offer_scope_v1.dart';

@immutable
class ReleaseCommerceAvailabilityStateV1 {
  const ReleaseCommerceAvailabilityStateV1({
    required this.isStoreAvailable,
    required this.hasPremiumProduct,
    required this.canRestore,
    required this.canUpgrade,
    required this.offerScope,
    this.message,
  });

  final bool isStoreAvailable;
  final bool hasPremiumProduct;
  final bool canRestore;
  final bool canUpgrade;
  final ReleasePremiumOfferScopeV1 offerScope;
  final String? message;
}

class ReleaseCommerceAvailabilityServiceV1 {
  ReleaseCommerceAvailabilityServiceV1._();

  @visibleForTesting
  static Future<ReleaseCommerceAvailabilityStateV1> Function()?
  debugOverrideReadV1;

  static Future<ReleaseCommerceAvailabilityStateV1> readV1() async {
    final override = debugOverrideReadV1;
    if (override != null) {
      return override();
    }

    final paymentService = PaymentService();
    await paymentService.initialize();
    final isStoreAvailable = paymentService.isAvailable;
    final productIds = paymentService.products
        .map((product) => product.id)
        .toSet();
    final hasPremiumProduct =
        productIds.contains(PaymentService.productProSubscription) ||
        productIds.contains(PaymentService.productPremiumPack);

    if (!isStoreAvailable) {
      return const ReleaseCommerceAvailabilityStateV1(
        isStoreAvailable: false,
        hasPremiumProduct: false,
        canRestore: false,
        canUpgrade: false,
        offerScope: ReleasePremiumOfferScopeV1(
          kind: ReleasePremiumOfferKindV1.unavailable,
          canUpgrade: false,
          upgradeLabel: 'Premium unavailable',
        ),
        message: 'Purchases are unavailable on this device right now.',
      );
    }

    final offerScope = ReleasePremiumOfferScopeServiceV1.fromProductIdsV1(
      productIds,
    );

    if (!hasPremiumProduct) {
      return ReleaseCommerceAvailabilityStateV1(
        isStoreAvailable: true,
        hasPremiumProduct: false,
        canRestore: true,
        canUpgrade: false,
        offerScope: offerScope,
        message: 'Premium purchase products are not configured on this build.',
      );
    }

    return ReleaseCommerceAvailabilityStateV1(
      isStoreAvailable: true,
      hasPremiumProduct: true,
      canRestore: true,
      canUpgrade: offerScope.canUpgrade,
      offerScope: offerScope,
      message: offerScope.message,
    );
  }

  @visibleForTesting
  static void debugResetOverrideV1() {
    debugOverrideReadV1 = null;
  }
}

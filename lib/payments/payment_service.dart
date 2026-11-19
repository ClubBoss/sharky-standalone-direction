import 'package:flutter/foundation.dart';
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';

import '../services/entitlement_ledger_v1.dart';
import '../services/premium_service.dart';

/// Legacy purchase policy and local entitlement convergence.
abstract final class PaymentService {
  /// Product IDs for the shop.
  /// These must match the IDs configured in Google Play Console and App Store Connect.
  static const String productPremiumPack = 'premium_pack';
  static const String productProSubscription = 'pro_subscription_monthly';
  static const String productProSubscriptionAnnual = 'pro_subscription_annual';
  static const String productXpBooster = 'xp_booster';
  static const String productCoinsPackSmall = 'coins_pack_small';
  static const String productCoinsPackMedium = 'coins_pack_medium';
  static const String productCoinsPackLarge = 'coins_pack_large';

  static bool isVerifiedEntitlementV1(PurchaseDetails purchaseDetails) {
    return purchaseDetails.status == PurchaseStatus.purchased ||
        purchaseDetails.status == PurchaseStatus.restored;
  }

  static bool _isPremiumEntitlementProductV1(String productId) {
    return productId == productPremiumPack ||
        productId == productProSubscription ||
        productId == productProSubscriptionAnnual;
  }

  @visibleForTesting
  static Future<void> syncCanonicalEntitlementForProductV1(
    String productId,
  ) async {
    final grantsPremium = _isPremiumEntitlementProductV1(productId);
    if (_isPremiumEntitlementProductV1(productId)) {
      await PremiumService().enablePremium();
    }
    await EntitlementLedgerServiceV1.instance.recordLocalProductConvergenceV1(
      productId: productId,
      grantsPremium: grantsPremium,
      nowEpochMs: DateTime.now().toUtc().millisecondsSinceEpoch,
    );
  }
}

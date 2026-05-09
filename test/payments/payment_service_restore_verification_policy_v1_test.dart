import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/payments/payment_service.dart';
import 'package:poker_analyzer/services/entitlement_ssot_v1.dart';
import 'package:poker_analyzer/services/premium_service.dart';

PurchaseDetails _purchaseDetailsV1({
  required String productId,
  required PurchaseStatus status,
}) {
  return PurchaseDetails(
    productID: productId,
    verificationData: PurchaseVerificationData(
      localVerificationData: 'local',
      serverVerificationData: 'server',
      source: 'test',
    ),
    transactionDate: '1700000000000',
    status: status,
  );
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await PremiumService().clear();
  });

  test(
    'restore purchased premium product converges entitlement to true',
    () async {
      final restoredPurchase = _purchaseDetailsV1(
        productId: PaymentService.productPremiumPack,
        status: PurchaseStatus.restored,
      );
      final verified = PaymentService.isVerifiedEntitlementV1(restoredPurchase);
      expect(verified, isTrue);
      await PaymentService.syncCanonicalEntitlementForProductV1(
        restoredPurchase.productID,
      );

      final entitled = await EntitlementSSOTV1.instance.isEntitledToPremiumV1(
        nowEpochMs: 1700000000000,
      );
      expect(entitled, isTrue);
    },
  );

  test(
    'restore purchased pro subscription converges entitlement to true',
    () async {
      final restoredPurchase = _purchaseDetailsV1(
        productId: PaymentService.productProSubscription,
        status: PurchaseStatus.restored,
      );
      final verified = PaymentService.isVerifiedEntitlementV1(restoredPurchase);
      expect(verified, isTrue);
      await PaymentService.syncCanonicalEntitlementForProductV1(
        restoredPurchase.productID,
      );

      final entitled = await EntitlementSSOTV1.instance.isEntitledToPremiumV1(
        nowEpochMs: 1700000000000,
      );
      expect(entitled, isTrue);
    },
  );

  test('restore non-entitlement product does not grant premium', () async {
    final restoredPurchase = _purchaseDetailsV1(
      productId: PaymentService.productCoinsPackSmall,
      status: PurchaseStatus.restored,
    );
    final verified = PaymentService.isVerifiedEntitlementV1(restoredPurchase);
    expect(verified, isTrue);
    await PaymentService.syncCanonicalEntitlementForProductV1(
      restoredPurchase.productID,
    );

    final entitled = await EntitlementSSOTV1.instance.isEntitledToPremiumV1(
      nowEpochMs: 1700000000000,
    );
    expect(entitled, isFalse);
  });

  test(
    'restore none keeps entitlement false unless premium or trial is active',
    () async {
      var entitled = await EntitlementSSOTV1.instance.isEntitledToPremiumV1(
        nowEpochMs: 1700000000000,
      );
      expect(entitled, isFalse);

      await PremiumService().enablePremium();
      entitled = await EntitlementSSOTV1.instance.isEntitledToPremiumV1(
        nowEpochMs: 1700000000000,
      );
      expect(entitled, isTrue);

      await PremiumService().disablePremium();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'trial_entitlement_v1',
        jsonEncode(<String, int>{
          'schemaVersion': 1,
          'startEpochMs': 1699999900000,
          'durationDays': 7,
        }),
      );
      entitled = await EntitlementSSOTV1.instance.isEntitledToPremiumV1(
        nowEpochMs: 1700000000000,
      );
      expect(entitled, isTrue);
    },
  );

  test('restore error keeps entitlement unchanged', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'trial_entitlement_v1',
      jsonEncode(<String, int>{
        'schemaVersion': 1,
        'startEpochMs': 1699999900000,
        'durationDays': 7,
      }),
    );
    final before = await EntitlementSSOTV1.instance.isEntitledToPremiumV1(
      nowEpochMs: 1700000000000,
    );
    final erroredPurchase = _purchaseDetailsV1(
      productId: PaymentService.productPremiumPack,
      status: PurchaseStatus.error,
    );
    final verified = PaymentService.isVerifiedEntitlementV1(erroredPurchase);
    expect(verified, isFalse);
    if (verified) {
      await PaymentService.syncCanonicalEntitlementForProductV1(
        erroredPurchase.productID,
      );
    }

    final after = await EntitlementSSOTV1.instance.isEntitledToPremiumV1(
      nowEpochMs: 1700000000000,
    );
    expect(before, isTrue);
    expect(after, before);
  });
}

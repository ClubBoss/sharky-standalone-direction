import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/payments/payment_service.dart';
import 'package:poker_analyzer/services/release_premium_offer_scope_v1.dart';

void main() {
  test('classifies subscription plus legacy pack as launch-compatible', () {
    final scope = ReleasePremiumOfferScopeServiceV1.fromProductIdsV1({
      PaymentService.productProSubscription,
      PaymentService.productProSubscriptionAnnual,
      PaymentService.productPremiumPack,
    });

    expect(
      scope.kind,
      ReleasePremiumOfferKindV1.annualAndMonthlyWithLegacyPack,
    );
    expect(scope.canUpgrade, isTrue);
    expect(scope.upgradeLabel, 'Start Premium');
    expect(scope.message, isNull);
  });

  test('classifies annual plus monthly scope as launch-compatible', () {
    final scope = ReleasePremiumOfferScopeServiceV1.fromProductIdsV1({
      PaymentService.productProSubscription,
      PaymentService.productProSubscriptionAnnual,
    });

    expect(scope.kind, ReleasePremiumOfferKindV1.annualAndMonthly);
    expect(scope.canUpgrade, isTrue);
    expect(scope.upgradeLabel, 'Start Premium');
    expect(scope.message, isNull);
  });

  test('classifies monthly-only scope as launch-incomplete but purchasable', () {
    final scope = ReleasePremiumOfferScopeServiceV1.fromProductIdsV1({
      PaymentService.productProSubscription,
    });

    expect(scope.kind, ReleasePremiumOfferKindV1.monthlyOnly);
    expect(scope.canUpgrade, isTrue);
    expect(scope.upgradeLabel, 'Start Premium');
    expect(
      scope.message,
      'Premium is purchasable on this build, but the annual default offer is missing.',
    );
  });

  test('classifies annual-only scope as launch-incomplete but purchasable', () {
    final scope = ReleasePremiumOfferScopeServiceV1.fromProductIdsV1({
      PaymentService.productProSubscriptionAnnual,
    });

    expect(scope.kind, ReleasePremiumOfferKindV1.annualOnly);
    expect(scope.canUpgrade, isTrue);
    expect(scope.upgradeLabel, 'Start Premium');
    expect(
      scope.message,
      'Premium is purchasable on this build, but the monthly fallback offer is missing.',
    );
  });

  test('classifies legacy-pack-only scope as not launch-compatible', () {
    final scope = ReleasePremiumOfferScopeServiceV1.fromProductIdsV1({
      PaymentService.productPremiumPack,
    });

    expect(scope.kind, ReleasePremiumOfferKindV1.legacyPackOnly);
    expect(scope.canUpgrade, isFalse);
    expect(scope.upgradeLabel, 'Premium unavailable');
    expect(
      scope.message,
      'Premium subscription is unavailable on this build right now.',
    );
  });

  test('classifies empty scope as unavailable', () {
    final scope = ReleasePremiumOfferScopeServiceV1.fromProductIdsV1({});

    expect(scope.kind, ReleasePremiumOfferKindV1.unavailable);
    expect(scope.canUpgrade, isFalse);
    expect(scope.upgradeLabel, 'Premium unavailable');
    expect(
      scope.message,
      'Premium purchases are unavailable on this device right now.',
    );
  });
}

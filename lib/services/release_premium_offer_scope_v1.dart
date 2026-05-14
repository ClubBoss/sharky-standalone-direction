import 'package:flutter/foundation.dart';
import 'package:poker_analyzer/payments/payment_service.dart';

enum ReleasePremiumOfferKindV1 {
  unavailable,
  legacyPackOnly,
  monthlyOnly,
  annualOnly,
  annualAndMonthly,
  annualAndMonthlyWithLegacyPack,
}

@immutable
class ReleasePremiumOfferScopeV1 {
  const ReleasePremiumOfferScopeV1({
    required this.kind,
    required this.canUpgrade,
    required this.upgradeLabel,
    this.message,
  });

  final ReleasePremiumOfferKindV1 kind;
  final bool canUpgrade;
  final String upgradeLabel;
  final String? message;
}

class ReleasePremiumOfferScopeServiceV1 {
  ReleasePremiumOfferScopeServiceV1._();

  static ReleasePremiumOfferScopeV1 fromProductIdsV1(Set<String> productIds) {
    final hasLegacyPack = productIds.contains(
      PaymentService.productPremiumPack,
    );
    final hasMonthlySubscription = productIds.contains(
      PaymentService.productProSubscription,
    );
    final hasAnnualSubscription = productIds.contains(
      PaymentService.productProSubscriptionAnnual,
    );

    if (hasAnnualSubscription && hasMonthlySubscription && hasLegacyPack) {
      return const ReleasePremiumOfferScopeV1(
        kind: ReleasePremiumOfferKindV1.annualAndMonthlyWithLegacyPack,
        canUpgrade: true,
        upgradeLabel: 'Start Premium',
      );
    }

    if (hasAnnualSubscription && hasMonthlySubscription) {
      return const ReleasePremiumOfferScopeV1(
        kind: ReleasePremiumOfferKindV1.annualAndMonthly,
        canUpgrade: true,
        upgradeLabel: 'Start Premium',
      );
    }

    if (hasMonthlySubscription) {
      return const ReleasePremiumOfferScopeV1(
        kind: ReleasePremiumOfferKindV1.monthlyOnly,
        canUpgrade: true,
        upgradeLabel: 'Start Premium',
        message:
            'Premium is purchasable on this build, but the annual default offer is missing.',
      );
    }

    if (hasAnnualSubscription) {
      return const ReleasePremiumOfferScopeV1(
        kind: ReleasePremiumOfferKindV1.annualOnly,
        canUpgrade: true,
        upgradeLabel: 'Start Premium',
        message:
            'Premium is purchasable on this build, but the monthly fallback offer is missing.',
      );
    }

    if (hasLegacyPack) {
      return const ReleasePremiumOfferScopeV1(
        kind: ReleasePremiumOfferKindV1.legacyPackOnly,
        canUpgrade: false,
        upgradeLabel: 'Premium unavailable',
        message: 'Premium subscription is unavailable on this build right now.',
      );
    }

    return const ReleasePremiumOfferScopeV1(
      kind: ReleasePremiumOfferKindV1.unavailable,
      canUpgrade: false,
      upgradeLabel: 'Premium unavailable',
      message: 'Premium purchases are unavailable on this device right now.',
    );
  }
}

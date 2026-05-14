import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/release_commerce_availability_v1.dart';
import 'package:poker_analyzer/services/release_premium_offer_scope_v1.dart';

void main() {
  tearDown(() {
    ReleaseCommerceAvailabilityServiceV1.debugResetOverrideV1();
  });

  test(
    'reports store unavailable as non-purchasable and non-restorable',
    () async {
      ReleaseCommerceAvailabilityServiceV1.debugOverrideReadV1 = () async =>
          const ReleaseCommerceAvailabilityStateV1(
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

      final state = await ReleaseCommerceAvailabilityServiceV1.readV1();

      expect(state.isStoreAvailable, isFalse);
      expect(state.hasPremiumProduct, isFalse);
      expect(state.canRestore, isFalse);
      expect(state.canUpgrade, isFalse);
      expect(
        state.message,
        'Purchases are unavailable on this device right now.',
      );
      expect(state.offerScope.kind, ReleasePremiumOfferKindV1.unavailable);
    },
  );

  test('reports configured store as purchasable', () async {
    ReleaseCommerceAvailabilityServiceV1.debugOverrideReadV1 = () async =>
        const ReleaseCommerceAvailabilityStateV1(
          isStoreAvailable: true,
          hasPremiumProduct: true,
          canRestore: true,
          canUpgrade: true,
          offerScope: ReleasePremiumOfferScopeV1(
            kind: ReleasePremiumOfferKindV1.annualAndMonthlyWithLegacyPack,
            canUpgrade: true,
            upgradeLabel: 'Start Premium',
          ),
        );

    final state = await ReleaseCommerceAvailabilityServiceV1.readV1();

    expect(state.isStoreAvailable, isTrue);
    expect(state.hasPremiumProduct, isTrue);
    expect(state.canRestore, isTrue);
    expect(state.canUpgrade, isTrue);
    expect(state.message, isNull);
    expect(
      state.offerScope.kind,
      ReleasePremiumOfferKindV1.annualAndMonthlyWithLegacyPack,
    );
  });

  test(
    'reports configured store without premium product as non-upgradable',
    () async {
      ReleaseCommerceAvailabilityServiceV1.debugOverrideReadV1 = () async =>
          const ReleaseCommerceAvailabilityStateV1(
            isStoreAvailable: true,
            hasPremiumProduct: false,
            canRestore: true,
            canUpgrade: false,
            offerScope: ReleasePremiumOfferScopeV1(
              kind: ReleasePremiumOfferKindV1.legacyPackOnly,
              canUpgrade: false,
              upgradeLabel: 'Premium unavailable',
            ),
            message:
                'Premium purchase products are not configured on this build.',
          );

      final state = await ReleaseCommerceAvailabilityServiceV1.readV1();

      expect(state.isStoreAvailable, isTrue);
      expect(state.hasPremiumProduct, isFalse);
      expect(state.canRestore, isTrue);
      expect(state.canUpgrade, isFalse);
      expect(
        state.message,
        'Premium purchase products are not configured on this build.',
      );
      expect(state.offerScope.kind, ReleasePremiumOfferKindV1.legacyPackOnly);
    },
  );
}

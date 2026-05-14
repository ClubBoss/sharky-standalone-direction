import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/services/premium_service.dart';
import 'package:poker_analyzer/services/release_commerce_availability_v1.dart';
import 'package:poker_analyzer/services/release_premium_offer_scope_v1.dart';
import 'package:poker_analyzer/services/release_premium_access_action_v1.dart';
import 'package:poker_analyzer/services/subscription_status_v1.dart';
import 'package:poker_analyzer/ui_v2/ui_v2_premium_hub.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await PremiumService().clear();
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
  });

  tearDown(() {
    ReleaseCommerceAvailabilityServiceV1.debugResetOverrideV1();
    ReleasePremiumAccessActionV1.debugResetOverridesV1();
  });

  const freeStatus = SubscriptionStatusV1(
    isPremium: false,
    isEntitled: false,
    isTrialActive: false,
    trialRemainingDays: 0,
    source: SubscriptionSourceV1.none,
    accessState: SubscriptionAccessStateV1.free,
  );

  testWidgets(
    'premium hub keeps trial distinct from premium and refreshes after upgrade',
    (tester) async {
      final nowEpochMs = DateTime.now().toUtc().millisecondsSinceEpoch;
      SharedPreferences.setMockInitialValues(<String, Object>{
        'premium_is_active': false,
        'trial_entitlement_v1': jsonEncode(<String, int>{
          'schemaVersion': 1,
          'startEpochMs': nowEpochMs - 1000,
          'durationDays': 7,
        }),
      });

      await tester.pumpWidget(const MaterialApp(home: UiV2PremiumHub()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.byKey(const Key('premium_hub_status_label_v1')),
        findsOneWidget,
      );
      expect(
        find.text(
          'Trial active: premium-target Today routes and World 5+ stay open during the active trial.',
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          'Your account is on trial now. Premium keeps the same premium-target access after the trial ends.',
        ),
        findsOneWidget,
      );
      expect(find.text('Premium is ACTIVE'), findsNothing);
      expect(find.text('Upgrade to Premium'), findsOneWidget);

      await PremiumService().enablePremium();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.text(
          'Premium active: premium-target Today routes and World 5+ are unlocked.',
        ),
        findsOneWidget,
      );
      expect(
        find.text('Your account already has premium access on current main.'),
        findsOneWidget,
      );
      expect(find.text('Upgrade to Premium'), findsNothing);
      expect(find.text('Premium Activated'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('premium hub refreshes visible access state after lifecycle resume', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'premium_is_active': false,
    });

    await tester.pumpWidget(const MaterialApp(home: UiV2PremiumHub()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      find.text(
        'Free access stays on the opening path plus one Today route per UTC day.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Premium adds premium-target Today routes and World 5+ progression on current main.',
      ),
      findsOneWidget,
    );

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(const Duration(milliseconds: 40));
    await PremiumService().enablePremium();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));

    expect(
      find.text(
        'Premium active: premium-target Today routes and World 5+ are unlocked.',
      ),
      findsOneWidget,
    );
    expect(find.text('Premium Activated'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'premium hub gives premium precedence over an active trial from first load',
    (tester) async {
      final nowEpochMs = DateTime.now().toUtc().millisecondsSinceEpoch;
      SharedPreferences.setMockInitialValues(<String, Object>{
        'trial_entitlement_v1': jsonEncode(<String, int>{
          'schemaVersion': 1,
          'startEpochMs': nowEpochMs - 1000,
          'durationDays': 7,
        }),
      });
      await PremiumService().enablePremium();

      await tester.pumpWidget(const MaterialApp(home: UiV2PremiumHub()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.text(
          'Premium active: premium-target Today routes and World 5+ are unlocked.',
        ),
        findsOneWidget,
      );
      expect(find.textContaining('Trial active:'), findsNothing);
      expect(
        find.text('Your account already has premium access on current main.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'premium hub drops from trial to free after lifecycle resume when trial expires',
    (tester) async {
      final nowEpochMs = DateTime.now().toUtc().millisecondsSinceEpoch;
      SharedPreferences.setMockInitialValues(<String, Object>{
        'premium_is_active': false,
        'trial_entitlement_v1': jsonEncode(<String, int>{
          'schemaVersion': 1,
          'startEpochMs': nowEpochMs - 1000,
          'durationDays': 7,
        }),
      });

      await tester.pumpWidget(const MaterialApp(home: UiV2PremiumHub()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('Trial active:'), findsOneWidget);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'trial_entitlement_v1',
        jsonEncode(<String, int>{
          'schemaVersion': 1,
          'startEpochMs': nowEpochMs - (9 * 24 * 60 * 60 * 1000),
          'durationDays': 7,
        }),
      );
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));

      expect(find.textContaining('Trial active:'), findsNothing);
      expect(
        find.text(
          'Free access stays on the opening path plus one Today route per UTC day.',
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          'Premium adds premium-target Today routes and World 5+ progression on current main.',
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'premium hub shows unavailable-store note and disables premium actions',
    (tester) async {
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

      await tester.pumpWidget(const MaterialApp(home: UiV2PremiumHub()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.byKey(const Key('premium_hub_store_note_v1')),
        findsOneWidget,
      );
      expect(
        find.text('Purchases are unavailable on this device right now.'),
        findsOneWidget,
      );

      final restoreButton = tester.widget<OutlinedButton>(
        find.byKey(const Key('premium_hub_restore_cta_v1')),
      );
      final upgradeButton = tester.widget<ElevatedButton>(
        find.byKey(const Key('premium_hub_upgrade_cta_v1')),
      );
      expect(restoreButton.onPressed, isNull);
      expect(upgradeButton.onPressed, isNull);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'premium hub restore surfaces no-purchase-found message on the active route',
    (tester) async {
      ReleasePremiumAccessActionV1.debugOverrideRestoreV1 = () async =>
          const ReleasePremiumAccessActionResultV1(
            status: ReleasePremiumAccessActionStatusV1.noPurchaseFound,
            subscriptionStatus: freeStatus,
            message:
                'No past Premium Access purchase was found for this store account, so access stays on its current path.',
          );

      await tester.pumpWidget(const MaterialApp(home: UiV2PremiumHub()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(
        find.byKey(const Key('premium_hub_restore_cta_v1')),
        warnIfMissed: false,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.byKey(const Key('premium_hub_restore_status_v1')),
        findsOneWidget,
      );
      expect(
        find.textContaining('No past Premium Access purchase was found'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'premium hub upgrade surfaces purchase failure message on the active route',
    (tester) async {
      ReleasePremiumAccessActionV1.debugOverrideUpgradeV1 = () async =>
          const ReleasePremiumAccessActionResultV1(
            status: ReleasePremiumAccessActionStatusV1.failed,
            subscriptionStatus: freeStatus,
            message: 'Purchase failed',
          );

      await tester.pumpWidget(const MaterialApp(home: UiV2PremiumHub()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(
        find.byKey(const Key('premium_hub_upgrade_cta_v1')),
        warnIfMissed: false,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Purchase failed'), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );
}

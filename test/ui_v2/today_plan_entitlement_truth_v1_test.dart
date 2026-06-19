import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/infra/telemetry.dart';
import 'package:poker_analyzer/services/premium_service.dart';
import 'package:poker_analyzer/services/release_commerce_availability_v1.dart';
import 'package:poker_analyzer/services/release_premium_offer_scope_v1.dart';
import 'package:poker_analyzer/services/release_premium_access_action_v1.dart';
import 'package:poker_analyzer/services/subscription_status_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/universal_intake_plan_screen.dart';

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
    'trial-active today plan stays trial-labeled and preview copy matches package truth',
    (tester) async {
      final events = <Map<String, dynamic>>[];
      Telemetry.overrideLogHandler((name, payload) async {
        events.add(<String, dynamic>{'name': name, 'payload': payload ?? {}});
      });
      addTearDown(() => Telemetry.overrideLogHandler(null));

      final nowEpochMs = DateTime.now().toUtc().millisecondsSinceEpoch;
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'chips_balance_v1': 5,
        'premium_is_active': false,
        'trial_entitlement_v1': jsonEncode(<String, int>{
          'schemaVersion': 1,
          'startEpochMs': nowEpochMs - 1000,
          'durationDays': 7,
        }),
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_completed_packs_v1': '',
      });

      await tester.pumpWidget(
        const MaterialApp(home: UniversalIntakePlanScreen()),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      final statusFinder = find.byKey(const Key('today_plan_trial_status_v1'));
      expect(statusFinder, findsOneWidget);
      final statusText = (tester.widget<Text>(statusFinder).data ?? '').trim();
      expect(statusText, contains('Trial active:'));
      expect(statusText, contains('optional table-clue practice'));
      expect(statusText, contains('free foundation'));
      expect(statusText, isNot(contains('Premium active')));
      final previewCta = find.byKey(
        const Key('today_plan_premium_preview_cta_v1'),
      );
      expect(previewCta, findsOneWidget);
      expect(find.text('See premium access'), findsOneWidget);
      await tester.ensureVisible(previewCta);

      await tester.tap(previewCta, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('today_plan_premium_preview_title_v1')),
        findsOneWidget,
      );
      final previewStatusFinder = find.byKey(
        const Key('today_plan_premium_preview_status_line_v1'),
      );
      expect(previewStatusFinder, findsOneWidget);
      final previewStatusText =
          (tester.widget<Text>(previewStatusFinder).data ?? '').trim();
      expect(previewStatusText, contains('Trial is active now.'));
      expect(previewStatusText, contains('optional table-clue practice'));
      expect(
        find.byKey(const Key('today_plan_premium_preview_free_line_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('today_plan_premium_preview_unlock_line_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('today_plan_premium_preview_restore_line_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('today_plan_premium_preview_restore_cta_v1')),
        findsOneWidget,
      );

      final previewEvents = events
          .where((event) => event['name'] == 'premium_preview_opened_v1')
          .toList(growable: false);
      expect(previewEvents, isNotEmpty);
      final payload = Map<String, dynamic>.from(
        previewEvents.last['payload'] as Map,
      );
      expect(payload['status'], 'trial');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'today plan refreshes premium entry state after entitlement changes',
    (tester) async {
      final nowEpochMs = DateTime.now().toUtc().millisecondsSinceEpoch;
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'chips_balance_v1': 5,
        'premium_is_active': false,
        'trial_entitlement_v1': jsonEncode(<String, int>{
          'schemaVersion': 1,
          'startEpochMs': nowEpochMs - 1000,
          'durationDays': 7,
        }),
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_completed_packs_v1': '',
      });

      await tester.pumpWidget(
        const MaterialApp(home: UniversalIntakePlanScreen()),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.textContaining('Trial active'), findsOneWidget);
      expect(
        find.textContaining('optional table-clue practice'),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('today_plan_premium_preview_cta_v1')),
        findsOneWidget,
      );

      await PremiumService().enablePremium();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.textContaining(
          'Premium active: extra table-clue practice is available after the free foundation.',
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('today_plan_premium_manage_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('today_plan_premium_preview_cta_v1')),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('expired trial today plan falls back to free access copy', (
    tester,
  ) async {
    final nowEpochMs = DateTime.now().toUtc().millisecondsSinceEpoch;
    SharedPreferences.setMockInitialValues(<String, Object>{
      'onboardingCompleted': true,
      'intake_completed_v1': true,
      'chips_balance_v1': 5,
      'premium_is_active': false,
      'trial_entitlement_v1': jsonEncode(<String, int>{
        'schemaVersion': 1,
        'startEpochMs': nowEpochMs - (9 * 24 * 60 * 60 * 1000),
        'durationDays': 7,
      }),
      'spine_campaign_active_pack_id_v1': '',
      'spine_campaign_next_hand_index_v1': 0,
      'spine_campaign_completed_packs_v1': '',
    });

    await tester.pumpWidget(
      const MaterialApp(home: UniversalIntakePlanScreen()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.textContaining('Trial active:'), findsNothing);
    expect(
      find.text('Free keeps the opening path and first useful hand open.'),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('today_plan_premium_preview_cta_v1')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('today plan refreshes premium entry state after lifecycle resume', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'onboardingCompleted': true,
      'intake_completed_v1': true,
      'chips_balance_v1': 5,
      'premium_is_active': false,
      'spine_campaign_active_pack_id_v1': '',
      'spine_campaign_next_hand_index_v1': 0,
      'spine_campaign_completed_packs_v1': '',
    });

    await tester.pumpWidget(
      const MaterialApp(home: UniversalIntakePlanScreen()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.textContaining('Premium active'), findsNothing);
    expect(find.byKey(const Key('today_plan_premium_manage_v1')), findsNothing);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(const Duration(milliseconds: 40));
    await PremiumService().enablePremium();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));

    expect(
      find.textContaining(
        'Premium active: extra table-clue practice is available after the free foundation.',
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('today_plan_premium_manage_v1')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'today plan shows main trial cta only after first useful loop proof',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'chips_balance_v1': 5,
        'premium_is_active': false,
        'trial_placement_completed_v1': true,
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_completed_packs_v1': '',
      });

      await tester.pumpWidget(
        const MaterialApp(home: UniversalIntakePlanScreen()),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(
        find.byKey(const Key('today_plan_trial_start_cta_v1')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('today_plan_premium_preview_cta_v1')),
        findsOneWidget,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'spine_campaign_active_pack_id_v1',
        'world1_spine_campaign_v1',
      );
      await prefs.setInt('spine_campaign_next_hand_index_v1', 1);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump(const Duration(milliseconds: 40));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 160));

      expect(
        find.byKey(const Key('today_plan_trial_start_cta_v1')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'today plan drops from trial to free after lifecycle resume when trial expires',
    (tester) async {
      final nowEpochMs = DateTime.now().toUtc().millisecondsSinceEpoch;
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'chips_balance_v1': 5,
        'premium_is_active': false,
        'trial_entitlement_v1': jsonEncode(<String, int>{
          'schemaVersion': 1,
          'startEpochMs': nowEpochMs - 1000,
          'durationDays': 7,
        }),
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_completed_packs_v1': '',
      });

      await tester.pumpWidget(
        const MaterialApp(home: UniversalIntakePlanScreen()),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

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
        find.text('Free keeps the opening path and first useful hand open.'),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('today_plan_premium_preview_cta_v1')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'today plan premium preview shows unavailable-store note and disables restore',
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

      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'chips_balance_v1': 5,
        'premium_is_active': false,
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_completed_packs_v1': '',
      });

      await tester.pumpWidget(
        const MaterialApp(home: UniversalIntakePlanScreen()),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      final previewCta = find.byKey(
        const Key('today_plan_premium_preview_cta_v1'),
      );
      await tester.ensureVisible(previewCta);
      await tester.tap(previewCta, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('today_plan_premium_preview_title_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('today_plan_premium_preview_store_note_v1')),
        findsOneWidget,
      );
      expect(
        find.text('Purchases are unavailable on this device right now.'),
        findsOneWidget,
      );
      final restoreButton = tester.widget<TextButton>(
        find.byKey(const Key('today_plan_premium_preview_restore_cta_v1')),
      );
      expect(restoreButton.onPressed, isNull);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'today plan premium preview surfaces no-purchase-found restore truth',
    (tester) async {
      ReleasePremiumAccessActionV1.debugOverrideRestoreV1 = () async =>
          const ReleasePremiumAccessActionResultV1(
            status: ReleasePremiumAccessActionStatusV1.noPurchaseFound,
            subscriptionStatus: freeStatus,
            message:
                'No past Premium Access purchase was found for this store account, so access stays on its current path.',
          );

      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'chips_balance_v1': 5,
        'premium_is_active': false,
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_completed_packs_v1': '',
      });

      await tester.pumpWidget(
        const MaterialApp(home: UniversalIntakePlanScreen()),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      final previewCta = find.byKey(
        const Key('today_plan_premium_preview_cta_v1'),
      );
      await tester.ensureVisible(previewCta);
      await tester.tap(previewCta, warnIfMissed: false);
      await tester.pumpAndSettle();

      final restoreCta = find.byKey(
        const Key('today_plan_premium_preview_restore_cta_v1'),
      );
      await tester.ensureVisible(restoreCta);
      await tester.tap(restoreCta, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('today_plan_premium_preview_restore_status_v1')),
        findsOneWidget,
      );
      expect(
        find.textContaining('No past Premium Access purchase was found'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
}

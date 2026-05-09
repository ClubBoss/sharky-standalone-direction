import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/infra/telemetry.dart';
import 'package:poker_analyzer/services/premium_service.dart';
import 'package:poker_analyzer/ui_v2/screens/universal_intake_plan_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await PremiumService().clear();
  });

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
      expect(statusText, contains('premium-target Today routes'));
      expect(statusText, contains('World 5+'));
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
      expect(previewStatusText, contains('World 5+'));
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
        find.textContaining('premium-target Today routes'),
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
          'Premium active: premium-target Today routes and World 5+ are unlocked.',
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
        'Premium active: premium-target Today routes and World 5+ are unlocked.',
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('today_plan_premium_manage_v1')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}

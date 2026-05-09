import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/ui_v2/app_root.dart';
import 'package:poker_analyzer/ui_v2/screens/world1_foundations_microtask_runner_screen.dart';

import '_harness/ui_v2_guard_harness_v1.dart';

String _readExpectedTarget(WidgetTester tester) {
  final finder = find.byKey(
    const Key('spine_contract_expected_target'),
    skipOffstage: false,
  );
  final raw = tester.widget<Text>(finder.first).data ?? '';
  final match = RegExp(r'^target=(.+)$').firstMatch(raw.trim());
  return (match?.group(1) ?? 'seat_btn').trim();
}

String _pickWrongTarget(String expected) {
  const candidates = <String>[
    'seat_btn',
    'seat_sb',
    'seat_bb',
    'seat_co',
    'seat_hj',
  ];
  for (final token in candidates) {
    if (token != expected) return token;
  }
  return 'seat_sb';
}

Future<void> _applyWrongAnswer(WidgetTester tester) async {
  final expected = _readExpectedTarget(tester);
  final wrongToken = _pickWrongTarget(expected);
  final target = find.byKey(Key('spine_contract_target_$wrongToken'));
  expect(target, findsOneWidget);
  await tester.tap(target.first, warnIfMissed: false);
  await tester.pump(const Duration(milliseconds: 90));
  final check = find.byKey(const Key('microtask_check_cta'));
  expect(check, findsOneWidget);
  await tester.tap(check.first, warnIfMissed: false);
  await tester.pump(const Duration(milliseconds: 240));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('campaign bust exposes get backed and cooldown block', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1366, 900);
    tester.view.devicePixelRatio = 1.0;
    SharedPreferences.setMockInitialValues(<String, Object>{
      'onboardingCompleted': false,
      'intake_completed_v1': true,
      'intake_profile_v1':
          '{"version":"v1","focusLabel":"baseline","skillBand":"beginner","placementScore":0}',
      'spine_campaign_completed_packs_v1':
          'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow',
      'spine_campaign_active_pack_id_v1': '',
      'spine_campaign_next_hand_index_v1': 0,
      'spine_calibration_completed_v1': false,
      'spine_calibration_band_v1': 0,
      'campaign_bankroll_balance_v1': 6,
    });
    ProgressService.debugNowOverride = () => DateTime.utc(2026, 2, 14, 12, 0);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      ProgressService.debugNowOverride = null;
      ProgressService.world1DailyCompletionInSession.value = false;
    });

    await tester.pumpWidget(const AppRoot());
    await tester.pumpAndSettle();

    final start = find.byKey(const Key('today_plan_start_cta'));
    expect(start, findsOneWidget);
    await tester.tap(start.first, warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.byType(World1FoundationsMicroTaskRunnerScreen), findsOneWidget);

    await _applyWrongAnswer(tester);
    expect(find.textContaining('Bankroll: 0'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(findWorldCampaignBustPanel(), findsOneWidget);
    expect(findWorldCampaignBackerCta(), findsOneWidget);
    await tester.tap(findWorldCampaignBackerCta().first, warnIfMissed: false);
    await tester.pumpAndSettle();
    if (find
        .byType(World1FoundationsMicroTaskRunnerScreen)
        .evaluate()
        .isEmpty) {
      final start = find.byKey(const Key('today_plan_start_cta'));
      if (start.evaluate().isNotEmpty) {
        await tester.tap(start.first, warnIfMissed: false);
        await tester.pumpAndSettle();
      }
    }
    expect(find.byType(World1FoundationsMicroTaskRunnerScreen), findsOneWidget);

    await _applyWrongAnswer(tester);
    await _applyWrongAnswer(tester);
    await _applyWrongAnswer(tester);
    await _applyWrongAnswer(tester);
    expect(find.textContaining('Bankroll: 0'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(findWorldCampaignBustPanel(), findsOneWidget);
    expect(
      find.byKey(const Key('today_plan_start_blocked_reason')),
      findsOneWidget,
    );
  });
}

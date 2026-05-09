import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/ui_v2/app_root.dart';
import 'package:poker_analyzer/ui_v2/screens/universal_intake_plan_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/world1_foundations_microtask_runner_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('campaign surfaces stay campaign-only across entry states', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'onboardingCompleted': true,
      'intake_completed_v1': true,
      'intake_profile_v1':
          '{"version":"v1","focusLabel":"baseline","skillBand":"beginner","placementScore":0}',
      'spine_campaign_active_pack_id_v1': '',
      'spine_campaign_next_hand_index_v1': 0,
      'spine_calibration_completed_v1': false,
      'spine_calibration_band_v1': 0,
      'campaign_bankroll_balance_v1': 80,
    });
    ProgressService.world1DailyCompletionInSession.value = false;

    await tester.pumpWidget(const AppRoot());
    await tester.pumpAndSettle();

    final start = find.byKey(const Key('today_plan_start_cta'));
    expect(start, findsOneWidget);
    expect(find.text('START CAMPAIGN'), findsOneWidget);
    expect(find.textContaining('(intro_'), findsNothing);
    expect(find.textContaining('(core_'), findsNothing);
    expect(find.byType(World1FoundationsMicroTaskRunnerScreen), findsNothing);

    await tester.ensureVisible(start.first);
    await tester.tap(start.first, warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.byType(World1FoundationsMicroTaskRunnerScreen), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();

    SharedPreferences.setMockInitialValues(<String, Object>{
      'onboardingCompleted': true,
      'intake_completed_v1': true,
      'intake_profile_v1':
          '{"version":"v1","focusLabel":"baseline","skillBand":"beginner","placementScore":0}',
      'spine_campaign_completed_packs_v1':
          'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow,world1_spine_campaign_v1,world1_spine_followup_v1_b2',
      'spine_campaign_active_pack_id_v1': '',
      'spine_campaign_next_hand_index_v1': 0,
      'spine_calibration_completed_v1': true,
      'spine_calibration_band_v1': ProgressService.spineCalibrationBandAdvanced,
      'campaign_bankroll_balance_v1': 80,
    });

    await tester.pumpWidget(const AppRoot());
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('world1_state_current')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('today_plan_start_cta')), findsNothing);

    await tester.pumpWidget(
      const MaterialApp(home: UniversalIntakePlanScreen()),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('today_plan_start_cta')), findsOneWidget);
    expect(find.text('REPLAY CAMPAIGN'), findsOneWidget);
    expect(find.textContaining('(intro_'), findsNothing);
    expect(find.textContaining('(core_'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

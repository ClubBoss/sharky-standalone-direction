import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/ui_v2/app_root.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('campaign incomplete cold boot lands on plan', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'onboardingCompleted': true,
      'intake_completed_v1': true,
      'intake_profile_v1':
          '{"version":"v1","focusLabel":"baseline","skillBand":"beginner","placementScore":0}',
      'spine_campaign_completed_packs_v1':
          'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow,world1_spine_campaign_v1',
      'spine_campaign_active_pack_id_v1': '',
      'spine_campaign_next_hand_index_v1': 0,
      'spine_calibration_completed_v1': true,
      'spine_calibration_band_v1': ProgressService.spineCalibrationBandAdvanced,
    });
    ProgressService.world1DailyCompletionInSession.value = false;

    await tester.pumpWidget(const AppRoot());
    for (var i = 0; i < 80; i++) {
      if (find.byKey(const Key('today_plan_start_cta')).evaluate().isNotEmpty) {
        break;
      }
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.byKey(const Key('today_plan_start_cta')), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('world1_state_current')),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('campaign complete boots to map and not plan', (tester) async {
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
    });
    ProgressService.world1DailyCompletionInSession.value = false;

    await tester.pumpWidget(const AppRoot());
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('world1_state_current')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('today_plan_start_cta')), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

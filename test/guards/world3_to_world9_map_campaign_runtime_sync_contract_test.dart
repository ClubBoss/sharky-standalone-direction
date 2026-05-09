import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '_harness/canonical_direct_session_launch_contract_harness_v1.dart';
import 'package:poker_analyzer/ui_v2/map/ui_v2_progress_map_screen_v2.dart';
import 'package:poker_analyzer/ui_v2/screens/world1_foundations_microtask_runner_screen.dart';

Future<void> _pumpUntilAny(
  WidgetTester tester,
  List<Finder> finders, {
  int maxTicks = 180,
  Duration step = const Duration(milliseconds: 50),
}) async {
  for (var i = 0; i < maxTicks; i++) {
    for (final finder in finders) {
      if (finder.evaluate().isNotEmpty) {
        return;
      }
    }
    await tester.pump(step);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'map world3 followup launch normalizes to the direct session runtime',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'chips_balance_v1': 5,
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_completed_packs_v1':
            'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow,world1_spine_campaign_v1,world1_spine_followup_v1_b2,world2_spine_followup_v1_b2',
        'spine_calibration_completed_v1': true,
        'spine_calibration_band_v1': 2,
        'world2_calibration_completed_v1': true,
        'world3_calibration_completed_v1': false,
      });

      await tester.pumpWidget(
        const MaterialApp(home: UiV2ProgressMapScreenV2()),
      );
      await tester.pump(const Duration(milliseconds: 200));

      final mapState =
          tester.state(find.byType(UiV2ProgressMapScreenV2)) as dynamic;
      mapState.debugLaunchCampaignPackForTestV1('world3_spine_followup_v1_b2');
      await tester.pump();

      await _pumpUntilAny(tester, <Finder>[
        findCanonicalDirectSessionSurfaceV1(),
        find.byType(World1FoundationsMicroTaskRunnerScreen),
      ], maxTicks: 240);

      expectCanonicalDirectSessionLaunchV1(tester, 'w3.s01');
      expect(find.byType(World1FoundationsMicroTaskRunnerScreen), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'map world9 followup launch normalizes to the direct session runtime',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'chips_balance_v1': 5,
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_completed_packs_v1':
            'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow,world1_spine_campaign_v1,world1_spine_followup_v1_b2,world2_spine_followup_v1_b2,world3_spine_followup_v1_b2,world4_spine_followup_v1_b2,world5_spine_followup_v1_b2,world6_spine_followup_v1_b2,world7_spine_followup_v1_b2,world8_spine_followup_v1_b2',
        'spine_calibration_completed_v1': true,
        'spine_calibration_band_v1': 2,
        'world2_calibration_completed_v1': true,
        'world3_calibration_completed_v1': true,
        'world4_calibration_completed_v1': true,
        'world5_calibration_completed_v1': true,
        'world6_calibration_completed_v1': true,
        'world7_calibration_completed_v1': true,
        'world8_calibration_completed_v1': true,
        'world9_calibration_completed_v1': false,
      });

      await tester.pumpWidget(
        const MaterialApp(home: UiV2ProgressMapScreenV2()),
      );
      await tester.pump(const Duration(milliseconds: 200));

      final mapState =
          tester.state(find.byType(UiV2ProgressMapScreenV2)) as dynamic;
      mapState.debugLaunchCampaignPackForTestV1('world9_spine_followup_v1_b2');
      await tester.pump();

      await _pumpUntilAny(tester, <Finder>[
        findCanonicalDirectSessionSurfaceV1(),
        find.byType(World1FoundationsMicroTaskRunnerScreen),
      ], maxTicks: 240);

      expectCanonicalDirectSessionLaunchV1(tester, 'w9.s01');
      expect(find.byType(World1FoundationsMicroTaskRunnerScreen), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}

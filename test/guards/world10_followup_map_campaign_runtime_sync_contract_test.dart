import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/ui_v2/map/ui_v2_progress_map_screen_v2.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('map world10 followup b0 resolves to the cash track root session', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'onboardingCompleted': true,
      'intake_completed_v1': true,
      'chips_balance_v1': 5,
      'spine_campaign_active_pack_id_v1': '',
      'spine_campaign_next_hand_index_v1': 0,
      'spine_campaign_completed_packs_v1':
          'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow,world1_spine_campaign_v1,world1_spine_followup_v1_b2,world2_spine_campaign_v1,world2_spine_followup_v1_b2,world3_spine_campaign_v1,world3_spine_followup_v1_b2,world4_spine_campaign_v1,world4_spine_followup_v1_b2,world5_spine_campaign_v1,world5_spine_followup_v1_b2,world6_spine_campaign_v1,world6_spine_followup_v1_b2,world7_spine_campaign_v1,world7_spine_followup_v1_b2,world8_spine_campaign_v1,world8_spine_followup_v1_b2,world9_spine_campaign_v1,world9_spine_followup_v1_b2,world10_spine_campaign_v1',
      'spine_calibration_completed_v1': true,
      'spine_calibration_band_v1': 2,
      'world10_calibration_completed_v1': true,
    });

    await tester.pumpWidget(const MaterialApp(home: UiV2ProgressMapScreenV2()));
    await tester.pump(const Duration(milliseconds: 200));

    final mapState =
        tester.state(find.byType(UiV2ProgressMapScreenV2)) as dynamic;
    final resolved = await mapState.debugResolveCampaignLaunchTargetForTestV1(
      'world10_spine_followup_v1_b0',
    );
    expect(resolved, 'cash.s01');
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'map world10 followup b1 resolves to the tournament track root session',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'chips_balance_v1': 5,
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_completed_packs_v1':
            'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow,world1_spine_campaign_v1,world1_spine_followup_v1_b2,world2_spine_campaign_v1,world2_spine_followup_v1_b2,world3_spine_campaign_v1,world3_spine_followup_v1_b2,world4_spine_campaign_v1,world4_spine_followup_v1_b2,world5_spine_campaign_v1,world5_spine_followup_v1_b2,world6_spine_campaign_v1,world6_spine_followup_v1_b2,world7_spine_campaign_v1,world7_spine_followup_v1_b2,world8_spine_campaign_v1,world8_spine_followup_v1_b2,world9_spine_campaign_v1,world9_spine_followup_v1_b2,world10_spine_campaign_v1',
        'spine_calibration_completed_v1': true,
        'spine_calibration_band_v1': 2,
        'world10_calibration_completed_v1': true,
      });

      await tester.pumpWidget(
        const MaterialApp(home: UiV2ProgressMapScreenV2()),
      );
      await tester.pump(const Duration(milliseconds: 200));

      final mapState =
          tester.state(find.byType(UiV2ProgressMapScreenV2)) as dynamic;
      final resolved = await mapState.debugResolveCampaignLaunchTargetForTestV1(
        'world10_spine_followup_v1_b1',
      );
      expect(resolved, 'tournament.s01');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'map world10 followup b2 resolves to the mixed track root session',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'chips_balance_v1': 5,
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_completed_packs_v1':
            'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow,world1_spine_campaign_v1,world1_spine_followup_v1_b2,world2_spine_campaign_v1,world2_spine_followup_v1_b2,world3_spine_campaign_v1,world3_spine_followup_v1_b2,world4_spine_campaign_v1,world4_spine_followup_v1_b2,world5_spine_campaign_v1,world5_spine_followup_v1_b2,world6_spine_campaign_v1,world6_spine_followup_v1_b2,world7_spine_campaign_v1,world7_spine_followup_v1_b2,world8_spine_campaign_v1,world8_spine_followup_v1_b2,world9_spine_campaign_v1,world9_spine_followup_v1_b2,world10_spine_campaign_v1',
        'spine_calibration_completed_v1': true,
        'spine_calibration_band_v1': 2,
        'world10_calibration_completed_v1': true,
      });

      await tester.pumpWidget(
        const MaterialApp(home: UiV2ProgressMapScreenV2()),
      );
      await tester.pump(const Duration(milliseconds: 200));

      final mapState =
          tester.state(find.byType(UiV2ProgressMapScreenV2)) as dynamic;
      final resolved = await mapState.debugResolveCampaignLaunchTargetForTestV1(
        'world10_spine_followup_v1_b2',
      );
      expect(resolved, 'mixed.s01');
      expect(tester.takeException(), isNull);
    },
  );
}

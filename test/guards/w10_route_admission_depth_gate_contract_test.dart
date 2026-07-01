import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart';
import 'package:poker_analyzer/services/progress_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const w10RouteEntryPacks = <String>{
    'world10_spine_campaign_v1',
    'world10_spine_followup_v1_b0',
    'world10_spine_followup_v1_b1',
    'world10_spine_followup_v1_b2',
  };

  test('W9 completion can route to W10 when W10 is incomplete', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'onboardingCompleted': true,
      'intake_completed_v1': true,
      'intake_profile_v1':
          '{"version":"v1","focusLabel":"baseline","skillBand":"advanced","placementScore":3}',
      'spine_campaign_active_pack_id_v1': '',
      'spine_campaign_next_hand_index_v1': 0,
      'spine_campaign_completed_packs_v1':
          'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow,world1_spine_campaign_v1,world1_spine_followup_v1_b2,world2_spine_followup_v1_b2,world3_spine_followup_v1_b2,world4_spine_followup_v1_b2,world5_spine_followup_v1_b2,world6_spine_campaign_v1,world6_spine_followup_v1_b2,world7_spine_campaign_v1,world7_spine_followup_v1_b2,world8_spine_campaign_v1,world8_spine_followup_v1_b2,world9_spine_campaign_v1,world9_spine_followup_v1_b2',
      'spine_calibration_completed_v1': true,
      'spine_calibration_band_v1': 2,
      'world2_calibration_completed_v1': true,
      'world3_calibration_completed_v1': true,
      'world4_calibration_completed_v1': true,
      'world5_calibration_completed_v1': true,
      'world6_calibration_completed_v1': true,
      'world7_calibration_completed_v1': true,
      'world8_calibration_completed_v1': true,
      'world9_calibration_completed_v1': true,
      'world10_calibration_completed_v1': false,
    });

    final nextPack = await ProgressService.getNextSpinePackToRunV1();

    expect(nextPack, 'world10_spine_campaign_v1');
  });

  test(
    'active W10 pack state resumes W10 under admitted stale policy',
    () async {
      for (final activePack in w10RouteEntryPacks) {
        SharedPreferences.setMockInitialValues(<String, Object>{
          'onboardingCompleted': true,
          'intake_completed_v1': true,
          'spine_campaign_active_pack_id_v1': activePack,
          'spine_campaign_next_hand_index_v1': 1,
        });

        final nextPack = await ProgressService.getNextSpinePackToRunV1();

        expect(nextPack, activePack, reason: activePack);
      }
    },
  );

  test('W10 completion does not open W11', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'onboardingCompleted': true,
      'intake_completed_v1': true,
      'intake_profile_v1':
          '{"version":"v1","focusLabel":"baseline","skillBand":"advanced","placementScore":3}',
      'spine_campaign_active_pack_id_v1': '',
      'spine_campaign_next_hand_index_v1': 0,
      'spine_campaign_completed_packs_v1':
          'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow,world1_spine_campaign_v1,world1_spine_followup_v1_b2,world2_spine_followup_v1_b2,world3_spine_followup_v1_b2,world4_spine_followup_v1_b2,world5_spine_followup_v1_b2,world6_spine_campaign_v1,world6_spine_followup_v1_b2,world7_spine_campaign_v1,world7_spine_followup_v1_b2,world8_spine_campaign_v1,world8_spine_followup_v1_b2,world9_spine_campaign_v1,world9_spine_followup_v1_b2,world10_spine_campaign_v1,world10_spine_followup_v1_b2',
      'spine_calibration_completed_v1': true,
      'spine_calibration_band_v1': 2,
      'world2_calibration_completed_v1': true,
      'world3_calibration_completed_v1': true,
      'world4_calibration_completed_v1': true,
      'world5_calibration_completed_v1': true,
      'world6_calibration_completed_v1': true,
      'world7_calibration_completed_v1': true,
      'world8_calibration_completed_v1': true,
      'world9_calibration_completed_v1': true,
      'world10_calibration_completed_v1': true,
    });

    final nextPack = await ProgressService.getNextSpinePackToRunV1();

    expect(nextPack, ProgressService.w7W10LearnerRouteGateTerminalPackIdV1);
  });

  test('W10 route packs teach value versus stronger-hands-fold purpose', () {
    for (final packId in w10RouteEntryPacks) {
      final pack = kCampaignPacksV1[packId];
      expect(pack, isNotNull, reason: packId);
      expect(pack, isNotEmpty, reason: packId);

      final copy = pack!
          .map(
            (step) => <String>[
              step.prompt,
              step.hint,
              step.contextText ?? '',
              step.tradeoffText ?? '',
              step.consequenceText ?? '',
              step.insightText ?? '',
            ].join(' '),
          )
          .join(' ')
          .toLowerCase();

      expect(copy, contains('bet purpose'), reason: packId);
      expect(copy, contains('value'), reason: packId);
      expect(copy, contains('worse hands'), reason: packId);
      expect(copy, contains('stronger hands'), reason: packId);
      expect(copy, contains('fold'), reason: packId);
      expect(copy, isNot(contains('seat label')), reason: packId);
      expect(copy, isNot(contains('thin value')), reason: packId);
      expect(copy, isNot(contains('fold pressure')), reason: packId);
      expect(copy, isNot(contains('solver')), reason: packId);
      expect(copy, isNot(contains('gto')), reason: packId);
      expect(copy, isNot(contains('mastered')), reason: packId);
      expect(copy, isNot(contains('guaranteed')), reason: packId);
      expect(copy, isNot(contains('public')), reason: packId);
      expect(copy, isNot(contains('playable')), reason: packId);
    }
  });
}

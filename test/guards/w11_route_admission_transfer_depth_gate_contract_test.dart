import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart';
import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w11_board_texture_hidden_runtime_session_owner_v1.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const w11RouteEntryPacks = <String>{
    'world11_spine_campaign_v1',
    'world11_spine_followup_v1_b0',
    'world11_spine_followup_v1_b1',
    'world11_spine_followup_v1_b2',
  };

  test('W10 completion can route to W11 when W11 is incomplete', () async {
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
      'world11_calibration_completed_v1': false,
    });

    final nextPack = await ProgressService.getNextSpinePackToRunV1();

    expect(nextPack, 'world11_spine_campaign_v1');
  });

  test(
    'active W11 pack state resumes W11 under admitted stale policy',
    () async {
      for (final activePack in w11RouteEntryPacks) {
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

  test('W11 completion does not open W12', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'onboardingCompleted': true,
      'intake_completed_v1': true,
      'intake_profile_v1':
          '{"version":"v1","focusLabel":"baseline","skillBand":"advanced","placementScore":3}',
      'spine_campaign_active_pack_id_v1': '',
      'spine_campaign_next_hand_index_v1': 0,
      'spine_campaign_completed_packs_v1':
          'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow,world1_spine_campaign_v1,world1_spine_followup_v1_b2,world2_spine_followup_v1_b2,world3_spine_followup_v1_b2,world4_spine_followup_v1_b2,world5_spine_followup_v1_b2,world6_spine_campaign_v1,world6_spine_followup_v1_b2,world7_spine_campaign_v1,world7_spine_followup_v1_b2,world8_spine_campaign_v1,world8_spine_followup_v1_b2,world9_spine_campaign_v1,world9_spine_followup_v1_b2,world10_spine_campaign_v1,world10_spine_followup_v1_b2,world11_spine_campaign_v1,world11_spine_followup_v1_b2',
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
      'world11_calibration_completed_v1': true,
    });

    final nextPack = await ProgressService.getNextSpinePackToRunV1();

    expect(nextPack, ProgressService.w7W10LearnerRouteGateTerminalPackIdV1);
    expect(nextPack, isNot(startsWith('world12_')));
  });

  test('W11 route packs teach source-owned texture and danger transfer', () {
    final sourceTaskIds = act0W11BoardTextureHiddenTaskSpecsV1
        .map((spec) => spec.taskId)
        .toSet();
    expect(sourceTaskIds, contains('dry_board_texture_recognition_intro'));
    expect(
      sourceTaskIds,
      contains('connected_board_texture_recognition_intro'),
    );
    expect(sourceTaskIds, contains('suited_texture_pressure_lite'));
    expect(sourceTaskIds, contains('one_pair_board_danger_transfer_check'));

    for (final packId in w11RouteEntryPacks) {
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

      expect(copy, contains('texture'), reason: packId);
      expect(copy, contains('danger'), reason: packId);
      expect(copy, contains('dry board'), reason: packId);
      expect(copy, contains('connected'), reason: packId);
      expect(copy, contains('suited'), reason: packId);
      expect(copy, contains('one pair'), reason: packId);
      expect(copy, isNot(contains('seat label')), reason: packId);
      expect(copy, isNot(contains('solver')), reason: packId);
      expect(copy, isNot(contains('gto')), reason: packId);
      expect(copy, isNot(contains('mastered')), reason: packId);
      expect(copy, isNot(contains('guaranteed')), reason: packId);
      expect(copy, isNot(contains('public')), reason: packId);
      expect(copy, isNot(contains('playable')), reason: packId);
      expect(copy, isNot(contains('world12')), reason: packId);
      expect(copy, isNot(contains('w12')), reason: packId);
    }
  });

  test('W11 admission keeps W12 unregistered and Practice absent', () {
    expect(
      kCampaignPackIdsV1.where((id) => id.startsWith('world12_')),
      isEmpty,
    );
    expect(
      kCampaignPackIdsV1.where((id) => id.startsWith('world11_')).toSet(),
      w11RouteEntryPacks,
    );

    const owner = Act0W11BoardTextureHiddenRuntimeSessionOwnerV1();
    expect(owner.practiceLaunchRequest, isNull);
    for (final spec in act0W11BoardTextureHiddenTaskSpecsV1) {
      expect(spec.practiceCtaAllowed, isFalse);
      expect(spec.mapperNoTargetReason, contains('no_safe_practice_target'));
    }
  });
}

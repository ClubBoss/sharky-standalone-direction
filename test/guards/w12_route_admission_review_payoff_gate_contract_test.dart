import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart';
import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w12_review_decision_hidden_runtime_session_owner_v1.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const w12RouteEntryPacks = <String>{
    'world12_spine_campaign_v1',
    'world12_spine_followup_v1_b0',
    'world12_spine_followup_v1_b1',
    'world12_spine_followup_v1_b2',
  };

  test('W11 completion can route to W12 when W12 is incomplete', () async {
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
      'world12_calibration_completed_v1': false,
    });

    final nextPack = await ProgressService.getNextSpinePackToRunV1();

    expect(nextPack, 'world12_spine_campaign_v1');
  });

  test(
    'active W12 pack state resumes W12 under admitted stale policy',
    () async {
      for (final activePack in w12RouteEntryPacks) {
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

  test('W12 completion does not open W13', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'onboardingCompleted': true,
      'intake_completed_v1': true,
      'intake_profile_v1':
          '{"version":"v1","focusLabel":"baseline","skillBand":"advanced","placementScore":3}',
      'spine_campaign_active_pack_id_v1': '',
      'spine_campaign_next_hand_index_v1': 0,
      'spine_campaign_completed_packs_v1':
          'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow,world1_spine_campaign_v1,world1_spine_followup_v1_b2,world2_spine_followup_v1_b2,world3_spine_followup_v1_b2,world4_spine_followup_v1_b2,world5_spine_followup_v1_b2,world6_spine_campaign_v1,world6_spine_followup_v1_b2,world7_spine_campaign_v1,world7_spine_followup_v1_b2,world8_spine_campaign_v1,world8_spine_followup_v1_b2,world9_spine_campaign_v1,world9_spine_followup_v1_b2,world10_spine_campaign_v1,world10_spine_followup_v1_b2,world11_spine_campaign_v1,world11_spine_followup_v1_b2,world12_spine_campaign_v1,world12_spine_followup_v1_b2',
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
      'world12_calibration_completed_v1': true,
    });

    final nextPack = await ProgressService.getNextSpinePackToRunV1();

    expect(nextPack, ProgressService.w7W10LearnerRouteGateTerminalPackIdV1);
    expect(nextPack, isNot(startsWith('world13_')));
  });

  test('W12 route packs are review/payoff packs with concrete cue repair', () {
    final sourceTaskIds = act0W12ReviewDecisionHiddenTaskSpecsV1
        .map((spec) => spec.taskId)
        .toSet();
    expect(sourceTaskIds, contains('main_clue_identification_intro'));
    expect(sourceTaskIds, contains('turn_card_change_recognition_intro'));
    expect(sourceTaskIds, contains('safe_beginner_explanation_choice_lite'));
    expect(sourceTaskIds, contains('combined_decision_read_transfer_check'));

    for (final packId in w12RouteEntryPacks) {
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

      expect(copy, contains('review'), reason: packId);
      expect(copy, contains('checkpoint'), reason: packId);
      expect(copy, contains('visible cards'), reason: packId);
      expect(copy, contains('range'), reason: packId);
      expect(copy, contains('draw'), reason: packId);
      expect(copy, contains('call price'), reason: packId);
      expect(copy, contains('bet purpose'), reason: packId);
      expect(copy, contains('texture'), reason: packId);
      expect(copy, contains('explanation'), reason: packId);
      expect(copy, contains('missed cue'), reason: packId);
      expect(copy, isNot(contains('seat label')), reason: packId);
      expect(copy, isNot(contains('solver')), reason: packId);
      expect(copy, isNot(contains('gto')), reason: packId);
      expect(copy, isNot(contains('mastered')), reason: packId);
      expect(copy, isNot(contains('guaranteed')), reason: packId);
      expect(copy, isNot(contains('proven improvement')), reason: packId);
      expect(copy, isNot(contains('public')), reason: packId);
      expect(copy, isNot(contains('launch')), reason: packId);
      expect(copy, isNot(contains('10/10')), reason: packId);
      expect(copy, isNot(contains('top-1')), reason: packId);
      expect(copy, isNot(contains('world13')), reason: packId);
      expect(copy, isNot(contains('w13')), reason: packId);
    }
  });

  test('W12 admission keeps W13 absent and Practice absent', () {
    expect(
      kCampaignPackIdsV1.where((id) => id.startsWith('world12_')).toSet(),
      w12RouteEntryPacks,
    );
    expect(
      kCampaignPackIdsV1.where((id) => id.startsWith('world13_')),
      isEmpty,
    );

    const owner = Act0W12ReviewDecisionHiddenRuntimeSessionOwnerV1();
    expect(owner.practiceLaunchRequest, isNull);
    for (final spec in act0W12ReviewDecisionHiddenTaskSpecsV1) {
      expect(spec.practiceCtaAllowed, isFalse);
      expect(spec.mapperNoTargetReason, contains('no_safe_practice_target'));
    }
  });
}

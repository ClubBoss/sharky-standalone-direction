import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart';
import 'package:poker_analyzer/canonical/canonical_truth_map_v1.dart';
import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w8_stack_depth_hidden_runtime_session_owner_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w9_tournament_pressure_hidden_runtime_session_owner_v1.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('canonical W8 and W9 identity remains locked', () {
    final w8 = canonicalTruthWorldIdentityForWorldIdV1('world_8')!;
    final w9 = canonicalTruthWorldIdentityForWorldIdV1('world_9')!;

    expect(w8.learnerMeaning, 'Stack Depth And Risk');
    expect(w8.skillFamily, 'stack_depth_and_risk_control');
    expect(w8.retiredMeanings, contains('Draws as W8 primary route'));

    expect(w9.learnerMeaning, 'Tournament Pressure');
    expect(w9.skillFamily, 'tournament_pressure_and_risk_premium');
    expect(
      w9.retiredMeanings,
      contains('Price and Pot Odds as W9 primary route'),
    );
  });

  test('W8 active campaign route is stack-depth owned, not draw-owned', () {
    for (final packId in const <String>[
      'world8_spine_campaign_v1',
      'world8_spine_followup_v1_b0',
      'world8_spine_followup_v1_b1',
      'world8_spine_followup_v1_b2',
    ]) {
      final copy = _copyForPack(packId);

      expect(copy, contains('stack'), reason: packId);
      expect(copy, contains('risk'), reason: packId);
      expect(copy, contains('all-in'), reason: packId);

      for (final retired in const <String>[
        'draw',
        'flush draw',
        'open-ended',
        'gutshot',
        'outs',
        'future card',
      ]) {
        expect(copy, isNot(contains(retired)), reason: '$packId: $retired');
      }
    }
  });

  test(
    'W9 active campaign route is tournament-pressure owned, not price-owned',
    () {
      for (final packId in const <String>[
        'world9_spine_campaign_v1',
        'world9_spine_followup_v1_b0',
        'world9_spine_followup_v1_b1',
        'world9_spine_followup_v1_b2',
      ]) {
        final copy = _copyForPack(packId);

        expect(copy, contains('tournament'), reason: packId);
        expect(copy, contains('pressure'), reason: packId);
        expect(copy, contains('survival'), reason: packId);

        for (final retired in const <String>[
          'call price',
          'pot odds',
          'cheap call',
          'expensive call',
          'price check',
          'worth paying',
        ]) {
          expect(copy, isNot(contains(retired)), reason: '$packId: $retired');
        }
      }
    },
  );

  test('hidden W8/W9 owners emit canonical evidence families only', () {
    final w8Owner = const Act0W8StackDepthHiddenRuntimeSessionOwnerV1();
    final w9Owner = const Act0W9TournamentPressureHiddenRuntimeSessionOwnerV1();

    expect(
      w8Owner.taskSpecs.map((task) => task.conceptFamilyId).toSet(),
      <String>{'w8_stack_depth_risk_control'},
    );
    expect(
      w9Owner.taskSpecs.map((task) => task.conceptFamilyId).toSet(),
      <String>{'w9_tournament_pressure_risk_premium'},
    );

    for (final task in w8Owner.taskSpecs) {
      expect(task.lessonId, 'stack_depth_risk_control_lite');
      expect(task.repairFocusId, startsWith('w8_stack_depth_'));
      expect(task.skillAtomId, startsWith('w8_stack_depth_'));
      expect(task.learningPurpose.toLowerCase(), contains('stack'));
    }
    for (final task in w9Owner.taskSpecs) {
      expect(task.lessonId, 'tournament_pressure_lite');
      expect(task.repairFocusId, startsWith('w9_tournament_pressure_'));
      expect(task.skillAtomId, startsWith('w9_tournament_pressure_'));
      expect(task.learningPurpose.toLowerCase(), contains('tournament'));
    }
  });

  test(
    'ProgressService route transitions enter canonical W8 then canonical W9',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'intake_profile_v1':
            '{"version":"v1","focusLabel":"baseline","skillBand":"advanced","placementScore":3}',
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_completed_packs_v1':
            'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow,world1_spine_campaign_v1,world1_spine_followup_v1_b2,world2_spine_followup_v1_b2,world3_spine_followup_v1_b2,world4_spine_followup_v1_b2,world5_spine_followup_v1_b2,world6_spine_campaign_v1,world6_spine_followup_v1_b2,world7_spine_campaign_v1,world7_spine_followup_v1_b2',
        'spine_calibration_completed_v1': true,
        'spine_calibration_band_v1': 2,
        'world2_calibration_completed_v1': true,
        'world3_calibration_completed_v1': true,
        'world4_calibration_completed_v1': true,
        'world5_calibration_completed_v1': true,
        'world6_calibration_completed_v1': true,
        'world7_calibration_completed_v1': true,
        'world8_calibration_completed_v1': false,
      });

      final w8Next = await ProgressService.getNextSpinePackToRunV1();
      expect(w8Next, 'world8_spine_campaign_v1');
      expect(_copyForPack(w8Next), contains('stack'));

      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'intake_profile_v1':
            '{"version":"v1","focusLabel":"baseline","skillBand":"advanced","placementScore":3}',
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_completed_packs_v1':
            'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow,world1_spine_campaign_v1,world1_spine_followup_v1_b2,world2_spine_followup_v1_b2,world3_spine_followup_v1_b2,world4_spine_followup_v1_b2,world5_spine_followup_v1_b2,world6_spine_campaign_v1,world6_spine_followup_v1_b2,world7_spine_campaign_v1,world7_spine_followup_v1_b2,world8_spine_campaign_v1,world8_spine_followup_v1_b2',
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

      final w9Next = await ProgressService.getNextSpinePackToRunV1();
      expect(w9Next, 'world9_spine_campaign_v1');
      expect(_copyForPack(w9Next), contains('tournament'));
    },
  );
}

String _copyForPack(String packId) {
  final pack = kCampaignPacksV1[packId];
  expect(pack, isNotNull, reason: packId);
  return pack!
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
}

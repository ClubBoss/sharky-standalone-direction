import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/ui_v2/act0_shell/act0_concept_candidate_practice_mapper_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_concept_family_repair_memory_v1.dart';
import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const w7RouteEntryPacks = <String>{
    'world7_spine_campaign_v1',
    'world7_spine_followup_v1_b0',
    'world7_spine_followup_v1_b1',
    'world7_spine_followup_v1_b2',
  };

  const blockedW9W10Packs = <String>{
    'world9_spine_campaign_v1',
    'world9_spine_followup_v1_b0',
    'world9_spine_followup_v1_b1',
    'world9_spine_followup_v1_b2',
    'world10_spine_campaign_v1',
    'world10_spine_followup_v1_b0',
    'world10_spine_followup_v1_b1',
    'world10_spine_followup_v1_b2',
  };

  test('Act0 keeps W7-W12 world cards locked and non-selectable', () {
    for (var worldNumber = 7; worldNumber <= 12; worldNumber++) {
      final world = Act0ShellStateV1.sample.worldById('world_$worldNumber');

      expect(world.isLocked, isTrue, reason: 'world_$worldNumber locked');
      expect(
        world.isSelectable,
        isFalse,
        reason: 'world_$worldNumber non-selectable',
      );
    }
  });

  test('W7 route-facing card copy uses approved title while locked', () {
    final world7 = Act0ShellStateV1.sample.worldById('world_7');

    expect(world7.title, 'Visible Cards Change Ranges');
    expect(
      world7.subtitle,
      'Use visible cards to narrow what hands can still be there.',
    );
    expect(world7.status, Act0WorldStateV1.locked);
    expect(world7.isLocked, isTrue);
    expect(world7.isSelectable, isFalse);
    expect(world7.progressLabel, 'Later in Volume I');
    expect(world7.primaryCtaLabel, 'View route');
    expect(world7.unlockLabel, 'Finish Range Thinking to open this world.');
    expect(world7.title, isNot(contains('Lite')));
    expect(world7.subtitle, isNot(contains('solver')));

    final world8 = Act0ShellStateV1.sample.worldById('world_8');
    expect(
      world8.unlockLabel,
      'Finish Visible Cards Change Ranges to open this world.',
    );
  });

  test('W7 route-facing card copy avoids pre-route forbidden claims', () {
    final world7 = Act0ShellStateV1.sample.worldById('world_7');
    final routeCopy = <String>[
      world7.title,
      world7.subtitle,
      world7.progressLabel,
      world7.primaryCtaLabel,
      world7.unlockLabel,
    ].join(' ').toLowerCase();

    for (final forbidden in const <String>[
      'range thinking lite',
      'combo density',
      'card removal',
      'world7_',
      'w7_',
      'solver',
      'gto',
      'mastered',
      'fixed forever',
      'human qa',
      'launch-ready',
      '9.0',
      'learning effect',
    ]) {
      expect(routeCopy, isNot(contains(forbidden)));
    }
  });

  test('mapper still returns no target for W7 route-locked target', () {
    final result = mapAct0ConceptCandidateToPracticeLaunchRequestV1(
      const Act0ConceptFamilyRepairCandidateV1(
        conceptFamilyId: 'no_bet_yet',
        repairFocusId: 'no_bet_yet',
        skillAtomId: 'action_read',
        errorType: 'missed_action_read',
        incorrectCount: 1,
        correctCount: 0,
        latestIncorrectOrder: 1,
        selectionReasonCode: 'latest_incorrect_family',
      ),
      allowlist: const <Act0ConceptCandidatePracticeTargetSpecV1>[
        Act0ConceptCandidatePracticeTargetSpecV1(
          mappingId: 'locked_w7',
          conceptFamilyId: 'no_bet_yet',
          repairFocusId: 'no_bet_yet',
          skillAtomId: 'action_read',
          errorType: 'missed_action_read',
          sourceTaskId: 'actions_legal_context',
          targetWorldId: 'world_7',
          targetLessonId: 'w7_visible_cards_intro',
          targetTaskId: 'w7_visible_cards_task',
        ),
      ],
    );

    expect(result.isMapped, isFalse);
    expect(result.request, isNull);
    expect(
      result.reasonCode,
      act0ConceptCandidatePracticeNoTargetRouteLockedV1,
    );
  });

  test('mapper still returns no target for W8-W12 route-locked targets', () {
    for (final worldId in const <String>[
      'world_8',
      'world_9',
      'world_10',
      'world_11',
      'world_12',
    ]) {
      final result = mapAct0ConceptCandidateToPracticeLaunchRequestV1(
        const Act0ConceptFamilyRepairCandidateV1(
          conceptFamilyId: 'no_bet_yet',
          repairFocusId: 'no_bet_yet',
          skillAtomId: 'action_read',
          errorType: 'missed_action_read',
          incorrectCount: 1,
          correctCount: 0,
          latestIncorrectOrder: 1,
          selectionReasonCode: 'latest_incorrect_family',
        ),
        allowlist: <Act0ConceptCandidatePracticeTargetSpecV1>[
          Act0ConceptCandidatePracticeTargetSpecV1(
            mappingId: 'locked_$worldId',
            conceptFamilyId: 'no_bet_yet',
            repairFocusId: 'no_bet_yet',
            skillAtomId: 'action_read',
            errorType: 'missed_action_read',
            sourceTaskId: 'actions_legal_context',
            targetWorldId: worldId,
            targetLessonId: '${worldId}_visible_locked_preview',
            targetTaskId: '${worldId}_task',
          ),
        ],
      );

      expect(result.isMapped, isFalse, reason: worldId);
      expect(result.request, isNull, reason: worldId);
      expect(
        result.reasonCode,
        act0ConceptCandidatePracticeNoTargetRouteLockedV1,
        reason: worldId,
      );
    }
  });

  test(
    'learner-facing progression promotes W7 campaign after W6 completion',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'intake_profile_v1':
            '{"version":"v1","focusLabel":"baseline","skillBand":"advanced","placementScore":3}',
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_completed_packs_v1':
            'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow,world1_spine_campaign_v1,world1_spine_followup_v1_b2,world2_spine_followup_v1_b2,world3_spine_followup_v1_b2,world4_spine_followup_v1_b2,world5_spine_followup_v1_b2,world6_spine_campaign_v1,world6_spine_followup_v1_b2',
        'spine_calibration_completed_v1': true,
        'spine_calibration_band_v1': 2,
        'world2_calibration_completed_v1': true,
        'world3_calibration_completed_v1': true,
        'world4_calibration_completed_v1': true,
        'world5_calibration_completed_v1': true,
        'world6_calibration_completed_v1': true,
        'world7_calibration_completed_v1': false,
      });

      final nextPack = await ProgressService.getNextSpinePackToRunV1();

      expect(nextPack, 'world7_spine_campaign_v1');
    },
  );

  test('active W7 pack state resumes W7 under admitted stale policy', () async {
    for (final activePack in w7RouteEntryPacks) {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'spine_campaign_active_pack_id_v1': activePack,
        'spine_campaign_next_hand_index_v1': 2,
      });

      final nextPack = await ProgressService.getNextSpinePackToRunV1();

      expect(nextPack, activePack);
    }
  });

  test('W7 completion opens W8 after separate route admission', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'onboardingCompleted': true,
      'intake_completed_v1': true,
      'intake_profile_v1':
          '{"version":"v1","focusLabel":"baseline","skillBand":"advanced","placementScore":3}',
      'spine_campaign_active_pack_id_v1': '',
      'spine_campaign_next_hand_index_v1': 0,
      'spine_campaign_completed_packs_v1':
          'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow,world1_spine_campaign_v1,world1_spine_followup_v1_b2,world2_spine_followup_v1_b2,world3_spine_followup_v1_b2,world4_spine_followup_v1_b2,world5_spine_followup_v1_b2,world6_spine_campaign_v1,world6_spine_followup_v1_b2,world7_spine_campaign_v1',
      'spine_calibration_completed_v1': true,
      'spine_calibration_band_v1': 2,
      'world2_calibration_completed_v1': true,
      'world3_calibration_completed_v1': true,
      'world4_calibration_completed_v1': true,
      'world5_calibration_completed_v1': true,
      'world6_calibration_completed_v1': true,
      'world7_calibration_completed_v1': false,
      'world8_calibration_completed_v1': false,
    });

    final nextPack = await ProgressService.getNextSpinePackToRunV1();

    expect(nextPack, 'world8_spine_campaign_v1');
  });

  test(
    'stale active W9-W10 pack state is not returned to learner route',
    () async {
      for (final activePack in blockedW9W10Packs) {
        SharedPreferences.setMockInitialValues(<String, Object>{
          'onboardingCompleted': true,
          'intake_completed_v1': true,
          'spine_campaign_active_pack_id_v1': activePack,
          'spine_campaign_next_hand_index_v1': 0,
        });

        final nextPack = await ProgressService.getNextSpinePackToRunV1();

        expect(
          nextPack,
          isNot(activePack),
          reason: '$activePack must not bypass the W8-W10 learner gate',
        );
        expect(nextPack, 'world6_spine_followup_v1_b2');
      }
    },
  );
}

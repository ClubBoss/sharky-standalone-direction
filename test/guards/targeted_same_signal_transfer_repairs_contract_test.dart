import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_concept_candidate_practice_mapper_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_concept_family_repair_memory_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w10_bet_purpose_hidden_runtime_session_owner_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w11_board_texture_hidden_runtime_session_owner_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w12_review_decision_hidden_runtime_session_owner_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w7_visible_ace_hidden_runtime_session_owner_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w8_stack_depth_hidden_runtime_session_owner_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w9_tournament_pressure_hidden_runtime_session_owner_v1.dart';

import '../../tools/content_schema_l2_l3_validator_v1.dart';

void main() {
  test('W7-W12 hidden tasks vary answer position to reduce memorization', () {
    final arcs = <String, List<dynamic>>{
      'W7': act0W7VisibleAceHiddenTaskSpecsV1,
      'W8': act0W8StackDepthHiddenTaskSpecsV1,
      'W9': act0W9TournamentPressureHiddenTaskSpecsV1,
      'W10': act0W10BetPurposeHiddenTaskSpecsV1,
      'W11': act0W11BoardTextureHiddenTaskSpecsV1,
      'W12': act0W12ReviewDecisionHiddenTaskSpecsV1,
    };

    final allIndexes = <int>[];
    for (final entry in arcs.entries) {
      final taskIds = <String>{};
      final prompts = <String>{};
      final purposes = <String>{};
      final indexes = <int>[];

      for (final dynamic spec in entry.value) {
        final taskId = spec.taskId as String;
        final expectedChoiceId = spec.expectedChoiceId as String;
        final choiceIds = (spec.choiceIds as List).cast<String>();
        taskIds.add(taskId);
        prompts.add(spec.learnerPrompt as String);
        purposes.add(spec.learningPurpose as String);

        expect(choiceIds, contains(expectedChoiceId), reason: taskId);
        indexes.add(choiceIds.indexOf(expectedChoiceId));
      }

      expect(taskIds, hasLength(entry.value.length), reason: entry.key);
      expect(prompts, hasLength(entry.value.length), reason: entry.key);
      expect(purposes, hasLength(entry.value.length), reason: entry.key);
      expect(
        indexes.toSet(),
        hasLength(greaterThanOrEqualTo(2)),
        reason: '${entry.key} must not teach a same-slot answer pattern.',
      );
      allIndexes.addAll(indexes);
    }

    expect(allIndexes.toSet(), containsAll(<int>{0, 1, 2}));
  });

  test('W3 W5 and W6 keep bounded same-signal and transfer coverage', () {
    final w3 = validateContentSchemaL2L3FixturePathsV1(const <String>[
      'test/fixtures/content_factory_mvp/'
          'w3_canonical_certification_pilot_v1.json',
      'test/fixtures/content_factory_mvp/'
          'w3_hand_bucket_action_frame_canonical_pr2_v1.json',
    ]);
    expect(w3.isValid, isTrue, reason: w3.errors.join('\n'));
    final w3Report = w3.worldReports['world_3']!;
    expect(w3Report.totalTasks, 12);
    expect(w3Report.sameSignalGroupCounts, hasLength(2));
    expect(w3Report.sameSignalGroupCounts.values, everyElement(6));
    expect(w3Report.transferSurfaceCounts, hasLength(greaterThanOrEqualTo(4)));

    final w5 = validateContentSchemaL2L3FixturePathsV1([
      ...w4W5CanonicalPilotFixturePathsV1,
      ...w4W5CanonicalCoveragePr2FixturePathsV1,
      ...w5PrerequisiteChainRepairFixturePathsV1,
    ]);
    expect(w5.isValid, isTrue, reason: w5.errors.join('\n'));
    final w5Report = w5.worldReports['world_5']!;
    expect(
      w5Report.sameSignalGroupCounts,
      containsPair('w5.board_awareness.basic_outs_awareness', 6),
    );
    expect(
      w5Report.transferSurfaceCounts.keys.join(' '),
      allOf(contains('flush'), contains('open_ended'), contains('gutshot')),
    );

    final w6 = validateContentSchemaL2L3FixturePathsV1(
      w6CanonicalCoveragePr2FixturePathsV1,
    );
    expect(w6.isValid, isTrue, reason: w6.errors.join('\n'));
    final w6Report = w6.worldReports['world_6']!;
    expect(w6Report.totalTasks, 12);
    expect(w6Report.sameSignalGroupCounts, hasLength(2));
    expect(w6Report.sameSignalGroupCounts.values, everyElement(6));
    expect(w6Report.transferSurfaceCounts, hasLength(greaterThanOrEqualTo(4)));
  });

  test(
    'W7-W12 Practice mapper remains explicitly deferred without targets',
    () {
      final specs = <dynamic>[
        ...act0W7VisibleAceHiddenTaskSpecsV1,
        ...act0W8StackDepthHiddenTaskSpecsV1,
        ...act0W9TournamentPressureHiddenTaskSpecsV1,
        ...act0W10BetPurposeHiddenTaskSpecsV1,
        ...act0W11BoardTextureHiddenTaskSpecsV1,
        ...act0W12ReviewDecisionHiddenTaskSpecsV1,
      ];

      for (final dynamic spec in specs) {
        expect(spec.practiceCtaAllowed, isFalse, reason: spec.taskId as String);
        expect(
          spec.mapperNoTargetReason as String,
          contains('no_safe_practice_target'),
          reason: spec.taskId as String,
        );

        final result = mapAct0ConceptCandidateToPracticeLaunchRequestV1(
          Act0ConceptFamilyRepairCandidateV1(
            conceptFamilyId: spec.conceptFamilyId as String,
            repairFocusId: spec.repairFocusId as String,
            skillAtomId: spec.skillAtomId as String,
            errorType: spec.errorType as String,
            incorrectCount: 1,
            correctCount: 0,
            latestIncorrectOrder: 1,
            selectionReasonCode: 'targeted_same_signal_transfer_repairs_v1',
          ),
        );

        expect(result.isMapped, isFalse, reason: spec.taskId as String);
        expect(
          result.reasonCode,
          act0ConceptCandidatePracticeNoTargetUnknownConceptV1,
          reason: spec.taskId as String,
        );
      }
    },
  );

  test('W11 and W12 registry parity is explicit while W13 remains blocked', () {
    expect(
      kCampaignPackIdsV1.where((id) => id.startsWith('world11_')).toSet(),
      const <String>{
        'world11_spine_campaign_v1',
        'world11_spine_followup_v1_b0',
        'world11_spine_followup_v1_b1',
        'world11_spine_followup_v1_b2',
      },
    );
    expect(
      kCampaignPackIdsV1.where((id) => id.startsWith('world12_')).toSet(),
      const <String>{
        'world12_spine_campaign_v1',
        'world12_spine_followup_v1_b0',
        'world12_spine_followup_v1_b1',
        'world12_spine_followup_v1_b2',
      },
    );
    expect(
      kCampaignPackIdsV1.where((id) => id.startsWith('world13_')),
      isEmpty,
    );
  });
}

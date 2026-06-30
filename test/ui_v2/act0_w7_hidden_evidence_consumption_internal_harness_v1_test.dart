import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_concept_candidate_practice_mapper_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_concept_family_repair_memory_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_practice_action_transfer_join_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_transfer_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w7_visible_ace_hidden_evidence_harness_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w7_visible_ace_hidden_runtime_session_owner_v1.dart';

void main() {
  group('W7 hidden evidence consumption', () {
    const owner = Act0W7VisibleAceHiddenRuntimeSessionOwnerV1();

    test('projection stack reads hidden W7 concept family evidence', () {
      final history = owner.appendChoiceEvidence(
        history: const Act0LearningEvidenceHistoryV1(),
        selectedChoiceId: 'ace_combos_unchanged',
        attemptKey: 'w7_hidden_miss_1',
        decisionTimeBucket: '3_to_10s',
      );

      final memory = Act0ConceptFamilyRepairMemoryV1.fromLearningEvidence(
        history,
      );
      final candidate = memory.nextRepairCandidate;
      expect(candidate, isNotNull);
      expect(
        candidate!.conceptFamilyId,
        'w7_combo_density_visible_card_removal',
      );
      expect(candidate.repairFocusId, 'w7_visible_card_combo_reduction');
      expect(candidate.skillAtomId, 'w7_combo_density_card_removal');
      expect(candidate.errorType, 'missed_visible_card_combo_reduction');

      final transfer = Act0RepairTransferProjectionV1.fromLearningEvidence(
        history,
      );
      final transferSignal = transfer.signalForConcept(
        'w7_combo_density_visible_card_removal',
      );
      expect(transferSignal.state, act0RepairTransferMissStillActiveV1);
      expect(transferSignal.incorrectCount, 1);

      final mapperResult = mapAct0ConceptCandidateToPracticeLaunchRequestV1(
        candidate,
      );
      expect(mapperResult.isMapped, isFalse);
      expect(mapperResult.request, isNull);
      expect(
        mapperResult.reasonCode,
        act0ConceptCandidatePracticeNoTargetUnknownConceptV1,
      );
    });

    test('later correct hidden W7 evidence is proof-compatible non-causal', () {
      var history = owner.appendChoiceEvidence(
        history: const Act0LearningEvidenceHistoryV1(),
        selectedChoiceId: 'ace_combos_impossible',
        attemptKey: 'w7_hidden_miss_1',
        decisionTimeBucket: '3_to_10s',
      );
      history = owner.appendChoiceEvidence(
        history: history,
        selectedChoiceId: 'ace_combos_reduced',
        attemptKey: 'w7_hidden_correct_2',
        decisionTimeBucket: 'under_3s',
      );

      final memory = Act0ConceptFamilyRepairMemoryV1.fromLearningEvidence(
        history,
      );
      final family = memory.families.singleWhere(
        (item) =>
            item.conceptFamilyId == 'w7_combo_density_visible_card_removal',
      );
      expect(family.resolutionState, act0RepairCandidateResolutionClearedV1);
      expect(memory.nextRepairCandidate, isNull);

      final transfer = Act0RepairTransferProjectionV1.fromLearningEvidence(
        history,
      );
      final transferSignal = transfer.signalForConcept(
        'w7_combo_density_visible_card_removal',
      );
      expect(transferSignal.state, act0RepairTransferLaterCorrectSignalV1);
      expect(transferSignal.priorMissOrder, 1);
      expect(transferSignal.laterCorrectOrder, 2);

      final join = Act0PracticeActionTransferJoinProjectionV1.fromEvidence(
        history,
      );
      final joinSignal = join.signalForConcept(
        'w7_combo_density_visible_card_removal',
      );
      expect(
        joinSignal.state,
        act0PracticeActionTransferLaterCorrectWithoutPracticeEvidenceV1,
      );
      expect(joinSignal.practiceEvidenceOrder, isNull);
    });

    test('projection stack still falls back when concept family is absent', () {
      final history = Act0LearningEvidenceHistoryV1(
        records: <Act0LearningEvidenceRecordV1>[
          _recordWithoutConceptFamily(order: 1),
          _recordWithoutConceptFamily(
            order: 2,
            isCorrect: true,
            errorType: 'none',
            resultKind: 'correct',
          ),
        ],
      );

      final memory = Act0ConceptFamilyRepairMemoryV1.fromLearningEvidence(
        history,
      );
      expect(memory.families.single.conceptFamilyId, 'legacy_focus');

      final transfer = Act0RepairTransferProjectionV1.fromLearningEvidence(
        history,
      );
      expect(
        transfer.signalForConcept('legacy_focus').state,
        act0RepairTransferLaterCorrectSignalV1,
      );
    });

    test('hidden evidence sources stay route and claim safe', () {
      final ownerSource = File(
        'lib/ui_v2/act0_shell/'
        'act0_w7_visible_ace_hidden_runtime_session_owner_v1.dart',
      ).readAsStringSync();

      for (final forbidden in <String>[
        'Navigator',
        'MaterialPageRoute',
        'ProgressService',
        'mapAct0ConceptCandidateToPracticeLaunchRequestV1',
        'Act0PracticeRepairQueueLaunchRequestV1',
        'GTO',
        'solver',
        'optimal',
        'perfect',
        'mastered',
        'fixed',
        'guaranteed improvement',
        'AI leak',
      ]) {
        expect(ownerSource, isNot(contains(forbidden)));
      }
    });
  });

  group('W7 hidden internal harness', () {
    const harness = Act0W7VisibleAceHiddenEvidenceHarnessV1();

    test('invokes exactly one supported W7 task end to end', () {
      final history = harness.submitChoice(
        history: const Act0LearningEvidenceHistoryV1(),
        worldId: 'world_7',
        lessonId: 'range_thinking_lite_combo_density',
        taskId: 'visible_ace_combo_reduction_intro',
        selectedChoiceId: 'ace_combos_unchanged',
        attemptKey: 'harness_miss_1',
        decisionTimeBucket: '3_to_10s',
      );

      expect(history.records, hasLength(1));
      final record = history.records.single;
      expect(record.worldId, 'world_7');
      expect(record.taskId, 'visible_ace_combo_reduction_intro');
      expect(record.conceptFamilyId, 'w7_combo_density_visible_card_removal');
      expect(record.isCorrect, isFalse);
      expect(record.runKind, 'w7_hidden_runtime_session_owner_v1');
    });

    test('rejects all other task ids and exposes no Practice request', () {
      expect(
        () => harness.submitChoice(
          history: const Act0LearningEvidenceHistoryV1(),
          worldId: 'world_7',
          lessonId: 'range_thinking_lite_combo_density',
          taskId: 'other_w7_task',
          selectedChoiceId: 'ace_combos_reduced',
          attemptKey: 'bad_task',
          decisionTimeBucket: 'under_3s',
        ),
        throwsArgumentError,
      );
      expect(
        () => harness.submitChoice(
          history: const Act0LearningEvidenceHistoryV1(),
          worldId: 'world_6',
          lessonId: 'range_thinking_lite_combo_density',
          taskId: 'visible_ace_combo_reduction_intro',
          selectedChoiceId: 'ace_combos_reduced',
          attemptKey: 'bad_world',
          decisionTimeBucket: 'under_3s',
        ),
        throwsArgumentError,
      );
      expect(harness.practiceLaunchRequest, isNull);
    });

    test('harness source stays internal and route safe', () {
      final harnessSource = File(
        'lib/ui_v2/act0_shell/'
        'act0_w7_visible_ace_hidden_evidence_harness_v1.dart',
      ).readAsStringSync();

      for (final forbidden in <String>[
        'Navigator',
        'MaterialPageRoute',
        'ProgressService',
        'mapAct0ConceptCandidateToPracticeLaunchRequestV1',
        'Act0PracticeRepairQueueLaunchRequestV1',
        'package:flutter/',
      ]) {
        expect(harnessSource, isNot(contains(forbidden)));
      }
    });
  });
}

Act0LearningEvidenceRecordV1 _recordWithoutConceptFamily({
  required int order,
  bool isCorrect = false,
  String errorType = 'missed_legacy_focus',
  String resultKind = 'incorrect',
}) {
  return Act0LearningEvidenceRecordV1(
    recordId: 'legacy_$order',
    createdOrder: order,
    worldId: 'world_1',
    lessonId: 'legacy_lesson',
    taskId: 'legacy_task',
    choiceId: isCorrect ? 'correct_choice' : 'wrong_choice',
    expectedChoiceId: 'correct_choice',
    isCorrect: isCorrect,
    errorType: errorType,
    repairFocusId: 'legacy_focus',
    skillAtomId: 'legacy_skill',
    decisionTimeBucket: 'under_3s',
    resultKind: resultKind,
  );
}

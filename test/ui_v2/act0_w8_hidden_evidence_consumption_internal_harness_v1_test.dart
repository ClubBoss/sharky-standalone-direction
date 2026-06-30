import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_concept_candidate_practice_mapper_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_concept_family_repair_memory_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_practice_action_transfer_join_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_transfer_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w8_draws_hidden_evidence_harness_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w8_draws_hidden_runtime_session_owner_v1.dart';

void main() {
  group('W8 hidden evidence consumption', () {
    const owner = Act0W8DrawsHiddenRuntimeSessionOwnerV1();

    test('projection stack reads hidden W8 concept family evidence', () {
      final history = owner.appendChoiceEvidence(
        history: const Act0LearningEvidenceHistoryV1(),
        selectedChoiceId: 'flush_draw_no_improvement',
        attemptKey: 'w8_hidden_miss_1',
        decisionTimeBucket: '3_to_10s',
      );

      final memory = Act0ConceptFamilyRepairMemoryV1.fromLearningEvidence(
        history,
      );
      final candidate = memory.nextRepairCandidate;
      expect(candidate, isNotNull);
      expect(candidate!.conceptFamilyId, 'w8_draw_improvement_potential');
      expect(candidate.repairFocusId, 'w8_flush_draw_recognition');
      expect(candidate.skillAtomId, 'w8_draw_improvement_recognition');
      expect(candidate.errorType, 'missed_flush_draw_improvement');

      final transfer = Act0RepairTransferProjectionV1.fromLearningEvidence(
        history,
      );
      final transferSignal = transfer.signalForConcept(
        'w8_draw_improvement_potential',
      );
      expect(transferSignal.state, act0RepairTransferMissStillActiveV1);
      expect(transferSignal.incorrectCount, 1);

      final mapperResult = mapAct0ConceptCandidateToPracticeLaunchRequestV1(
        candidate,
      );
      expect(mapperResult.isMapped, isFalse);
      expect(mapperResult.request, isNull);
    });

    test('later correct hidden W8 evidence is proof-compatible non-causal', () {
      var history = owner.appendChoiceEvidence(
        history: const Act0LearningEvidenceHistoryV1(),
        selectedChoiceId: 'flush_draw_no_improvement',
        attemptKey: 'w8_hidden_miss_1',
        decisionTimeBucket: '3_to_10s',
      );
      history = owner.appendChoiceEvidence(
        history: history,
        selectedChoiceId: 'flush_draw_can_improve',
        attemptKey: 'w8_hidden_correct_2',
        decisionTimeBucket: 'under_3s',
      );

      final memory = Act0ConceptFamilyRepairMemoryV1.fromLearningEvidence(
        history,
      );
      final family = memory.families.singleWhere(
        (item) => item.conceptFamilyId == 'w8_draw_improvement_potential',
      );
      expect(family.resolutionState, act0RepairCandidateResolutionClearedV1);
      expect(memory.nextRepairCandidate, isNull);

      final transfer = Act0RepairTransferProjectionV1.fromLearningEvidence(
        history,
      );
      final transferSignal = transfer.signalForConcept(
        'w8_draw_improvement_potential',
      );
      expect(transferSignal.state, act0RepairTransferLaterCorrectSignalV1);

      final join = Act0PracticeActionTransferJoinProjectionV1.fromEvidence(
        history,
      );
      final joinSignal = join.signalForConcept('w8_draw_improvement_potential');
      expect(
        joinSignal.state,
        act0PracticeActionTransferLaterCorrectWithoutPracticeEvidenceV1,
      );
      expect(joinSignal.practiceEvidenceOrder, isNull);
    });

    test('hidden evidence sources stay route and claim safe', () {
      final ownerSource = File(
        'lib/ui_v2/act0_shell/'
        'act0_w8_draws_hidden_runtime_session_owner_v1.dart',
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

  group('W8 hidden internal harness', () {
    const harness = Act0W8DrawsHiddenEvidenceHarnessV1();

    test('invokes one supported W8 task end to end', () {
      final history = harness.submitChoice(
        history: const Act0LearningEvidenceHistoryV1(),
        worldId: 'world_8',
        lessonId: 'draws_equity_intuition_lite',
        taskId: 'flush_draw_recognition_intro',
        selectedChoiceId: 'flush_draw_no_improvement',
        attemptKey: 'harness_miss_1',
        decisionTimeBucket: '3_to_10s',
      );

      expect(history.records, hasLength(1));
      final record = history.records.single;
      expect(record.worldId, 'world_8');
      expect(record.taskId, 'flush_draw_recognition_intro');
      expect(record.conceptFamilyId, 'w8_draw_improvement_potential');
      expect(record.isCorrect, isFalse);
      expect(record.runKind, 'w8_hidden_runtime_session_owner_v1');
    });

    test('rejects other ids and exposes no Practice request', () {
      expect(
        () => harness.submitChoice(
          history: const Act0LearningEvidenceHistoryV1(),
          worldId: 'world_8',
          lessonId: 'draws_equity_intuition_lite',
          taskId: 'other_w8_task',
          selectedChoiceId: 'flush_draw_can_improve',
          attemptKey: 'bad_task',
          decisionTimeBucket: 'under_3s',
        ),
        throwsArgumentError,
      );
      expect(
        () => harness.submitChoice(
          history: const Act0LearningEvidenceHistoryV1(),
          worldId: 'world_7',
          lessonId: 'draws_equity_intuition_lite',
          taskId: 'flush_draw_recognition_intro',
          selectedChoiceId: 'flush_draw_can_improve',
          attemptKey: 'bad_world',
          decisionTimeBucket: 'under_3s',
        ),
        throwsArgumentError,
      );
      expect(harness.practiceLaunchRequest, isNull);
    });

    test('harness source stays internal and route safe', () {
      final harnessSource = File(
        'lib/ui_v2/act0_shell/act0_w8_draws_hidden_evidence_harness_v1.dart',
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

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_concept_candidate_practice_mapper_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_concept_family_repair_memory_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_practice_action_transfer_join_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_transfer_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w11_board_texture_hidden_evidence_harness_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w11_board_texture_hidden_runtime_session_owner_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w12_review_decision_hidden_evidence_harness_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w12_review_decision_hidden_runtime_session_owner_v1.dart';

void main() {
  group('W11 hidden evidence consumption', () {
    const owner = Act0W11BoardTextureHiddenRuntimeSessionOwnerV1();

    test('projection stack reads hidden W11 concept family evidence', () {
      final history = owner.appendChoiceEvidence(
        history: const Act0LearningEvidenceHistoryV1(),
        selectedChoiceId: 'connected_board_more_dangerous',
        attemptKey: 'w11_hidden_miss_1',
        decisionTimeBucket: '3_to_10s',
      );

      _expectActiveMissProjection(
        history: history,
        conceptFamilyId: 'w11_board_texture_danger_awareness',
        repairFocusId: 'w11_dry_board_texture_recognition',
        skillAtomId: 'w11_board_texture_read',
        errorType: 'missed_dry_board_texture',
      );
    });

    test(
      'later correct hidden W11 evidence is proof-compatible non-causal',
      () {
        var history = owner.appendChoiceEvidence(
          history: const Act0LearningEvidenceHistoryV1(),
          selectedChoiceId: 'connected_board_more_dangerous',
          attemptKey: 'w11_hidden_miss_1',
          decisionTimeBucket: '3_to_10s',
        );
        history = owner.appendChoiceEvidence(
          history: history,
          selectedChoiceId: 'dry_board_fewer_clear_connections',
          attemptKey: 'w11_hidden_correct_2',
          decisionTimeBucket: 'under_3s',
        );

        _expectLaterCorrectNonCausal(
          history: history,
          conceptFamilyId: 'w11_board_texture_danger_awareness',
        );
      },
    );
  });

  group('W12 hidden evidence consumption', () {
    const owner = Act0W12ReviewDecisionHiddenRuntimeSessionOwnerV1();

    test('projection stack reads hidden W12 concept family evidence', () {
      final history = owner.appendChoiceEvidence(
        history: const Act0LearningEvidenceHistoryV1(),
        selectedChoiceId: 'bet_purpose_clue',
        attemptKey: 'w12_hidden_miss_1',
        decisionTimeBucket: '3_to_10s',
      );

      _expectActiveMissProjection(
        history: history,
        conceptFamilyId: 'w12_review_decision_intuition',
        repairFocusId: 'w12_main_clue_identification',
        skillAtomId: 'w12_spot_clue_read',
        errorType: 'missed_main_clue_identification',
      );
    });

    test(
      'later correct hidden W12 evidence is proof-compatible non-causal',
      () {
        var history = owner.appendChoiceEvidence(
          history: const Act0LearningEvidenceHistoryV1(),
          selectedChoiceId: 'bet_purpose_clue',
          attemptKey: 'w12_hidden_miss_1',
          decisionTimeBucket: '3_to_10s',
        );
        history = owner.appendChoiceEvidence(
          history: history,
          selectedChoiceId: 'board_texture_clue',
          attemptKey: 'w12_hidden_correct_2',
          decisionTimeBucket: 'under_3s',
        );

        _expectLaterCorrectNonCausal(
          history: history,
          conceptFamilyId: 'w12_review_decision_intuition',
        );
      },
    );
  });

  group('W11/W12 hidden internal harnesses', () {
    const w11Harness = Act0W11BoardTextureHiddenEvidenceHarnessV1();
    const w12Harness = Act0W12ReviewDecisionHiddenEvidenceHarnessV1();

    test('invoke one supported task end to end', () {
      final w11History = w11Harness.submitChoice(
        history: const Act0LearningEvidenceHistoryV1(),
        worldId: 'world_11',
        lessonId: 'board_texture_danger_awareness_lite',
        taskId: 'dry_board_texture_recognition_intro',
        selectedChoiceId: 'connected_board_more_dangerous',
        attemptKey: 'w11_harness_miss_1',
        decisionTimeBucket: '3_to_10s',
      );
      expect(w11History.records.single.worldId, 'world_11');
      expect(
        w11History.records.single.conceptFamilyId,
        'w11_board_texture_danger_awareness',
      );
      expect(
        w11History.records.single.runKind,
        'w11_hidden_runtime_session_owner_v1',
      );

      final w12History = w12Harness.submitChoice(
        history: const Act0LearningEvidenceHistoryV1(),
        worldId: 'world_12',
        lessonId: 'review_decision_intuition_lite',
        taskId: 'main_clue_identification_intro',
        selectedChoiceId: 'bet_purpose_clue',
        attemptKey: 'w12_harness_miss_1',
        decisionTimeBucket: '3_to_10s',
      );
      expect(w12History.records.single.worldId, 'world_12');
      expect(
        w12History.records.single.conceptFamilyId,
        'w12_review_decision_intuition',
      );
      expect(
        w12History.records.single.runKind,
        'w12_hidden_runtime_session_owner_v1',
      );
    });

    test('reject other ids and expose no Practice request', () {
      expect(
        () => w11Harness.submitChoice(
          history: const Act0LearningEvidenceHistoryV1(),
          worldId: 'world_11',
          lessonId: 'board_texture_danger_awareness_lite',
          taskId: 'other_w11_task',
          selectedChoiceId: 'dry_board_fewer_clear_connections',
          attemptKey: 'bad_w11_task',
          decisionTimeBucket: 'under_3s',
        ),
        throwsArgumentError,
      );
      expect(
        () => w12Harness.submitChoice(
          history: const Act0LearningEvidenceHistoryV1(),
          worldId: 'world_11',
          lessonId: 'review_decision_intuition_lite',
          taskId: 'main_clue_identification_intro',
          selectedChoiceId: 'board_texture_clue',
          attemptKey: 'bad_w12_world',
          decisionTimeBucket: 'under_3s',
        ),
        throwsArgumentError,
      );
      expect(w11Harness.practiceLaunchRequest, isNull);
      expect(w12Harness.practiceLaunchRequest, isNull);
    });

    test('hidden evidence sources stay route and claim safe', () {
      final sourceFiles = <String>[
        'lib/ui_v2/act0_shell/act0_w11_board_texture_hidden_runtime_session_owner_v1.dart',
        'lib/ui_v2/act0_shell/act0_w11_board_texture_hidden_evidence_harness_v1.dart',
        'lib/ui_v2/act0_shell/act0_w12_review_decision_hidden_runtime_session_owner_v1.dart',
        'lib/ui_v2/act0_shell/act0_w12_review_decision_hidden_evidence_harness_v1.dart',
      ];

      for (final path in sourceFiles) {
        final source = File(path).readAsStringSync();
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
          expect(source, isNot(contains(forbidden)));
        }
        if (path.endsWith('evidence_harness_v1.dart')) {
          expect(source, isNot(contains('package:flutter/')));
        }
      }
    });
  });
}

void _expectActiveMissProjection({
  required Act0LearningEvidenceHistoryV1 history,
  required String conceptFamilyId,
  required String repairFocusId,
  required String skillAtomId,
  required String errorType,
}) {
  final memory = Act0ConceptFamilyRepairMemoryV1.fromLearningEvidence(history);
  final candidate = memory.nextRepairCandidate;
  expect(candidate, isNotNull);
  expect(candidate!.conceptFamilyId, conceptFamilyId);
  expect(candidate.repairFocusId, repairFocusId);
  expect(candidate.skillAtomId, skillAtomId);
  expect(candidate.errorType, errorType);

  final transfer = Act0RepairTransferProjectionV1.fromLearningEvidence(history);
  final transferSignal = transfer.signalForConcept(conceptFamilyId);
  expect(transferSignal.state, act0RepairTransferMissStillActiveV1);
  expect(transferSignal.incorrectCount, 1);

  final mapperResult = mapAct0ConceptCandidateToPracticeLaunchRequestV1(
    candidate,
  );
  expect(mapperResult.isMapped, isFalse);
  expect(mapperResult.request, isNull);
}

void _expectLaterCorrectNonCausal({
  required Act0LearningEvidenceHistoryV1 history,
  required String conceptFamilyId,
}) {
  final memory = Act0ConceptFamilyRepairMemoryV1.fromLearningEvidence(history);
  final family = memory.families.singleWhere(
    (item) => item.conceptFamilyId == conceptFamilyId,
  );
  expect(family.resolutionState, act0RepairCandidateResolutionClearedV1);
  expect(memory.nextRepairCandidate, isNull);

  final transfer = Act0RepairTransferProjectionV1.fromLearningEvidence(history);
  final transferSignal = transfer.signalForConcept(conceptFamilyId);
  expect(transferSignal.state, act0RepairTransferLaterCorrectSignalV1);

  final join = Act0PracticeActionTransferJoinProjectionV1.fromEvidence(history);
  final joinSignal = join.signalForConcept(conceptFamilyId);
  expect(
    joinSignal.state,
    act0PracticeActionTransferLaterCorrectWithoutPracticeEvidenceV1,
  );
  expect(joinSignal.practiceEvidenceOrder, isNull);
}

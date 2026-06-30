import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_concept_candidate_practice_mapper_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_concept_family_repair_memory_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_practice_action_transfer_join_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_transfer_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w10_bet_purpose_hidden_evidence_harness_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w10_bet_purpose_hidden_runtime_session_owner_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w9_price_hidden_evidence_harness_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w9_price_hidden_runtime_session_owner_v1.dart';

void main() {
  group('W9 hidden evidence consumption', () {
    const owner = Act0W9PriceHiddenRuntimeSessionOwnerV1();

    test('projection stack reads hidden W9 concept family evidence', () {
      final history = owner.appendChoiceEvidence(
        history: const Act0LearningEvidenceHistoryV1(),
        selectedChoiceId: 'cheap_call_large_price',
        attemptKey: 'w9_hidden_miss_1',
        decisionTimeBucket: '3_to_10s',
      );

      _expectActiveMissProjection(
        history: history,
        conceptFamilyId: 'w9_price_intuition_call_price',
        repairFocusId: 'w9_cheap_call_price_recognition',
        skillAtomId: 'w9_call_price_size_read',
        errorType: 'missed_cheap_call_price',
      );
    });

    test('later correct hidden W9 evidence is proof-compatible non-causal', () {
      var history = owner.appendChoiceEvidence(
        history: const Act0LearningEvidenceHistoryV1(),
        selectedChoiceId: 'cheap_call_large_price',
        attemptKey: 'w9_hidden_miss_1',
        decisionTimeBucket: '3_to_10s',
      );
      history = owner.appendChoiceEvidence(
        history: history,
        selectedChoiceId: 'cheap_call_small_price',
        attemptKey: 'w9_hidden_correct_2',
        decisionTimeBucket: 'under_3s',
      );

      _expectLaterCorrectNonCausal(
        history: history,
        conceptFamilyId: 'w9_price_intuition_call_price',
      );
    });
  });

  group('W10 hidden evidence consumption', () {
    const owner = Act0W10BetPurposeHiddenRuntimeSessionOwnerV1();

    test('projection stack reads hidden W10 concept family evidence', () {
      final history = owner.appendChoiceEvidence(
        history: const Act0LearningEvidenceHistoryV1(),
        selectedChoiceId: 'bet_to_make_better_fold',
        attemptKey: 'w10_hidden_miss_1',
        decisionTimeBucket: '3_to_10s',
      );

      _expectActiveMissProjection(
        history: history,
        conceptFamilyId: 'w10_bet_purpose_value_bluff',
        repairFocusId: 'w10_clear_value_bet_recognition',
        skillAtomId: 'w10_bet_purpose_value_read',
        errorType: 'missed_clear_value_bet',
      );
    });

    test(
      'later correct hidden W10 evidence is proof-compatible non-causal',
      () {
        var history = owner.appendChoiceEvidence(
          history: const Act0LearningEvidenceHistoryV1(),
          selectedChoiceId: 'bet_to_make_better_fold',
          attemptKey: 'w10_hidden_miss_1',
          decisionTimeBucket: '3_to_10s',
        );
        history = owner.appendChoiceEvidence(
          history: history,
          selectedChoiceId: 'bet_for_value_called_by_worse',
          attemptKey: 'w10_hidden_correct_2',
          decisionTimeBucket: 'under_3s',
        );

        _expectLaterCorrectNonCausal(
          history: history,
          conceptFamilyId: 'w10_bet_purpose_value_bluff',
        );
      },
    );
  });

  group('W9/W10 hidden internal harnesses', () {
    const w9Harness = Act0W9PriceHiddenEvidenceHarnessV1();
    const w10Harness = Act0W10BetPurposeHiddenEvidenceHarnessV1();

    test('invoke one supported task end to end', () {
      final w9History = w9Harness.submitChoice(
        history: const Act0LearningEvidenceHistoryV1(),
        worldId: 'world_9',
        lessonId: 'pot_odds_price_intuition_lite',
        taskId: 'cheap_call_price_recognition_intro',
        selectedChoiceId: 'cheap_call_large_price',
        attemptKey: 'w9_harness_miss_1',
        decisionTimeBucket: '3_to_10s',
      );
      expect(w9History.records.single.worldId, 'world_9');
      expect(
        w9History.records.single.conceptFamilyId,
        'w9_price_intuition_call_price',
      );
      expect(
        w9History.records.single.runKind,
        'w9_hidden_runtime_session_owner_v1',
      );

      final w10History = w10Harness.submitChoice(
        history: const Act0LearningEvidenceHistoryV1(),
        worldId: 'world_10',
        lessonId: 'value_bluff_intuition_lite',
        taskId: 'clear_value_bet_recognition_intro',
        selectedChoiceId: 'bet_to_make_better_fold',
        attemptKey: 'w10_harness_miss_1',
        decisionTimeBucket: '3_to_10s',
      );
      expect(w10History.records.single.worldId, 'world_10');
      expect(
        w10History.records.single.conceptFamilyId,
        'w10_bet_purpose_value_bluff',
      );
      expect(
        w10History.records.single.runKind,
        'w10_hidden_runtime_session_owner_v1',
      );
    });

    test('reject other ids and expose no Practice request', () {
      expect(
        () => w9Harness.submitChoice(
          history: const Act0LearningEvidenceHistoryV1(),
          worldId: 'world_9',
          lessonId: 'pot_odds_price_intuition_lite',
          taskId: 'other_w9_task',
          selectedChoiceId: 'cheap_call_small_price',
          attemptKey: 'bad_w9_task',
          decisionTimeBucket: 'under_3s',
        ),
        throwsArgumentError,
      );
      expect(
        () => w10Harness.submitChoice(
          history: const Act0LearningEvidenceHistoryV1(),
          worldId: 'world_9',
          lessonId: 'value_bluff_intuition_lite',
          taskId: 'clear_value_bet_recognition_intro',
          selectedChoiceId: 'bet_for_value_called_by_worse',
          attemptKey: 'bad_w10_world',
          decisionTimeBucket: 'under_3s',
        ),
        throwsArgumentError,
      );
      expect(w9Harness.practiceLaunchRequest, isNull);
      expect(w10Harness.practiceLaunchRequest, isNull);
    });

    test('hidden evidence sources stay route and claim safe', () {
      final sourceFiles = <String>[
        'lib/ui_v2/act0_shell/act0_w9_price_hidden_runtime_session_owner_v1.dart',
        'lib/ui_v2/act0_shell/act0_w9_price_hidden_evidence_harness_v1.dart',
        'lib/ui_v2/act0_shell/act0_w10_bet_purpose_hidden_runtime_session_owner_v1.dart',
        'lib/ui_v2/act0_shell/act0_w10_bet_purpose_hidden_evidence_harness_v1.dart',
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

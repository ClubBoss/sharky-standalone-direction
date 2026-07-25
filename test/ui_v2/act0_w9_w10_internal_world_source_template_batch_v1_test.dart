import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_concept_candidate_practice_mapper_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_concept_family_repair_memory_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_transfer_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w10_bet_purpose_hidden_evidence_harness_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w10_bet_purpose_hidden_runtime_session_owner_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w9_tournament_pressure_hidden_evidence_harness_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w9_tournament_pressure_hidden_runtime_session_owner_v1.dart';

void main() {
  group('W9 internal world source template', () {
    const owner = Act0W9TournamentPressureHiddenRuntimeSessionOwnerV1();
    const harness = Act0W9TournamentPressureHiddenEvidenceHarnessV1();

    test('contains a coherent four-task hidden learning arc', () {
      expect(owner.taskSpecs, hasLength(4));
      expect(owner.taskSpecs.map((task) => task.taskId), <String>[
        'bubble_survival_pressure_intro',
        'risk_premium_medium_stack_intro',
        'short_stack_ladder_pressure_lite',
        'pressure_transfer_check',
      ]);

      final purposes = owner.taskSpecs
          .map((task) => task.learningPurpose)
          .toSet();
      expect(purposes, hasLength(4));
      for (final task in owner.taskSpecs) {
        expect(task.worldId, 'world_9');
        expect(task.lessonId, 'tournament_pressure_lite');
        expect(task.conceptFamilyId, 'w9_tournament_pressure_risk_premium');
        expect(task.practiceCtaAllowed, isFalse);
        expect(
          task.mapperNoTargetReason,
          'w9_route_locked_no_safe_practice_target_v1',
        );
      }
    });

    test('supports only admitted W9 tasks', () {
      for (final task in owner.taskSpecs) {
        expect(
          owner.supports(
            worldId: task.worldId,
            lessonId: task.lessonId,
            taskId: task.taskId,
          ),
          isTrue,
        );
      }
      expect(
        owner.supports(
          worldId: 'world_9',
          lessonId: 'tournament_pressure_lite',
          taskId: 'unowned_w9_task',
        ),
        isFalse,
      );
      expect(
        owner.supports(
          worldId: 'world_8',
          lessonId: 'tournament_pressure_lite',
          taskId: owner.taskSpecs.first.taskId,
        ),
        isFalse,
      );
    });

    test('each task writes correct and incorrect consumable evidence', () {
      var history = const Act0LearningEvidenceHistoryV1();
      for (final task in owner.taskSpecs) {
        final wrongChoice = task.choiceIds.firstWhere(
          (choiceId) => choiceId != task.expectedChoiceId,
        );
        history = harness.submitChoice(
          history: history,
          worldId: task.worldId,
          lessonId: task.lessonId,
          taskId: task.taskId,
          selectedChoiceId: wrongChoice,
          attemptKey: '${task.taskId}_miss',
          decisionTimeBucket: '3_to_10s',
        );
        history = harness.submitChoice(
          history: history,
          worldId: task.worldId,
          lessonId: task.lessonId,
          taskId: task.taskId,
          selectedChoiceId: task.expectedChoiceId,
          attemptKey: '${task.taskId}_correct',
          decisionTimeBucket: 'under_3s',
        );
      }

      _expectConsumableEvidence(
        history: history,
        taskSpecs: owner.taskSpecs,
        conceptFamilyId: 'w9_tournament_pressure_risk_premium',
      );
    });

    test('rejects unknown choices and exposes no Practice launch request', () {
      expect(
        () => harness.submitChoice(
          history: const Act0LearningEvidenceHistoryV1(),
          worldId: 'world_9',
          lessonId: 'tournament_pressure_lite',
          taskId: 'short_stack_ladder_pressure_lite',
          selectedChoiceId: 'unknown_choice',
          attemptKey: 'unknown_choice_attempt',
          decisionTimeBucket: 'under_3s',
        ),
        throwsArgumentError,
      );
      expect(harness.practiceLaunchRequest, isNull);

      final candidate = Act0ConceptFamilyRepairMemoryV1.fromLearningEvidence(
        harness.submitChoice(
          history: const Act0LearningEvidenceHistoryV1(),
          worldId: 'world_9',
          lessonId: 'tournament_pressure_lite',
          taskId: 'short_stack_ladder_pressure_lite',
          selectedChoiceId: 'ladder_pressure_ignores_survival',
          attemptKey: 'pressure_miss',
          decisionTimeBucket: 'under_3s',
        ),
      ).nextRepairCandidate;
      final mapped = mapAct0ConceptCandidateToPracticeLaunchRequestV1(
        candidate,
      );
      expect(mapped.isMapped, isFalse);
      expect(mapped.request, isNull);
    });

    test('learning arc copy is beginner readable and claim safe', () {
      _expectCopySafe(owner.taskSpecs);
    });
  });

  group('W10 internal world source template', () {
    const owner = Act0W10BetPurposeHiddenRuntimeSessionOwnerV1();
    const harness = Act0W10BetPurposeHiddenEvidenceHarnessV1();

    test('contains a coherent four-task hidden learning arc', () {
      expect(owner.taskSpecs, hasLength(4));
      expect(owner.taskSpecs.map((task) => task.taskId), <String>[
        'w10_player_tendency_tag_hidden',
        'w10_adjustment_lever_hidden',
        'w10_sample_guardrail_hidden',
        'w10_player_adjustment_transfer_hidden',
      ]);

      final purposes = owner.taskSpecs
          .map((task) => task.learningPurpose)
          .toSet();
      expect(purposes, hasLength(4));
      for (final task in owner.taskSpecs) {
        expect(task.worldId, 'world_10');
        expect(task.conceptFamilyId, 'w10_player_adjustment');
        expect(task.practiceCtaAllowed, isTrue);
        expect(task.mapperNoTargetReason, isEmpty);
      }
    });

    test('supports only admitted W10 tasks', () {
      for (final task in owner.taskSpecs) {
        expect(
          owner.supports(
            worldId: task.worldId,
            lessonId: task.lessonId,
            taskId: task.taskId,
          ),
          isTrue,
        );
      }
      expect(
        owner.supports(
          worldId: 'world_10',
          lessonId: 'value_bluff_intuition_lite',
          taskId: 'unowned_w10_task',
        ),
        isFalse,
      );
      expect(
        owner.supports(
          worldId: 'world_9',
          lessonId: owner.taskSpecs.first.lessonId,
          taskId: owner.taskSpecs.first.taskId,
        ),
        isFalse,
      );
      expect(
        owner.supports(
          worldId: 'world_10',
          lessonId: 'wrong_w10_lesson',
          taskId: owner.taskSpecs.first.taskId,
        ),
        isFalse,
      );
      expect(
        owner.supports(
          worldId: 'world_10',
          lessonId: owner.taskSpecs.first.lessonId,
          taskId: 'unowned_w10_task',
        ),
        isFalse,
      );
    });

    test('each task writes correct and incorrect consumable evidence', () {
      var history = const Act0LearningEvidenceHistoryV1();
      for (final task in owner.taskSpecs) {
        final wrongChoice = task.choiceIds.firstWhere(
          (choiceId) => choiceId != task.expectedChoiceId,
        );
        history = harness.submitChoice(
          history: history,
          worldId: task.worldId,
          lessonId: task.lessonId,
          taskId: task.taskId,
          selectedChoiceId: wrongChoice,
          attemptKey: '${task.taskId}_miss',
          decisionTimeBucket: '3_to_10s',
        );
        history = harness.submitChoice(
          history: history,
          worldId: task.worldId,
          lessonId: task.lessonId,
          taskId: task.taskId,
          selectedChoiceId: task.expectedChoiceId,
          attemptKey: '${task.taskId}_correct',
          decisionTimeBucket: 'under_3s',
        );
      }

      _expectConsumableEvidence(
        history: history,
        taskSpecs: owner.taskSpecs,
        conceptFamilyId: 'w10_player_adjustment',
      );
    });

    test('rejects unknown choices and exposes no Practice launch request', () {
      expect(
        () => harness.submitChoice(
          history: const Act0LearningEvidenceHistoryV1(),
          worldId: 'world_10',
          lessonId: 'player_type_basics',
          taskId: 'w10_player_tendency_tag_hidden',
          selectedChoiceId: 'unknown_choice',
          attemptKey: 'unknown_choice_attempt',
          decisionTimeBucket: 'under_3s',
        ),
        throwsArgumentError,
      );
      expect(harness.practiceLaunchRequest, isNull);

      final candidate = Act0ConceptFamilyRepairMemoryV1.fromLearningEvidence(
        harness.submitChoice(
          history: const Act0LearningEvidenceHistoryV1(),
          worldId: 'world_10',
          lessonId: 'player_type_basics',
          taskId: 'w10_player_tendency_tag_hidden',
          selectedChoiceId: 'loose_passive_caller',
          attemptKey: 'purpose_miss',
          decisionTimeBucket: 'under_3s',
        ),
      ).nextRepairCandidate;
      final mapped = mapAct0ConceptCandidateToPracticeLaunchRequestV1(
        candidate,
      );
      expect(mapped.isMapped, isTrue);
      expect(mapped.request?.targetTaskId, 'w10_loose_passive_tag');
    });

    test('rejects an admitted task outside its authored route', () {
      final task = owner.taskSpecs.first;
      for (final route in <({String worldId, String lessonId, String taskId})>[
        (
          worldId: 'world_9',
          lessonId: task.lessonId,
          taskId: task.taskId,
        ),
        (
          worldId: task.worldId,
          lessonId: 'wrong_w10_lesson',
          taskId: task.taskId,
        ),
        (
          worldId: task.worldId,
          lessonId: task.lessonId,
          taskId: 'unowned_w10_task',
        ),
      ]) {
        expect(
          () => harness.submitChoice(
            history: const Act0LearningEvidenceHistoryV1(),
            worldId: route.worldId,
            lessonId: route.lessonId,
            taskId: route.taskId,
            selectedChoiceId: task.expectedChoiceId,
            attemptKey: 'invalid_route_attempt',
            decisionTimeBucket: 'under_3s',
          ),
          throwsArgumentError,
        );
      }
    });

    test('learning arc copy is beginner readable and claim safe', () {
      _expectCopySafe(owner.taskSpecs);
    });
  });
}

void _expectConsumableEvidence({
  required Act0LearningEvidenceHistoryV1 history,
  required List<dynamic> taskSpecs,
  required String conceptFamilyId,
}) {
  expect(history.records, hasLength(taskSpecs.length * 2));
  for (final dynamic task in taskSpecs) {
    final records = history.records
        .where((record) => record.taskId == task.taskId)
        .toList();
    expect(records, hasLength(2));
    expect(records.first.isCorrect, isFalse);
    expect(records.first.errorType, task.errorType);
    expect(records.last.isCorrect, isTrue);
    expect(records.last.errorType, 'none');
    for (final record in records) {
      expect(record.conceptFamilyId, task.conceptFamilyId);
      expect(record.repairFocusId, task.repairFocusId);
      expect(record.skillAtomId, task.skillAtomId);
      expect(record.expectedChoiceId, task.expectedChoiceId);
    }
  }

  final memory = Act0ConceptFamilyRepairMemoryV1.fromLearningEvidence(history);
  expect(memory.families.single.conceptFamilyId, conceptFamilyId);
  expect(
    memory.families.single.resolutionState,
    act0RepairCandidateResolutionClearedV1,
  );

  final transfer = Act0RepairTransferProjectionV1.fromLearningEvidence(history);
  expect(
    transfer.signalForConcept(conceptFamilyId).state,
    act0RepairTransferLaterCorrectSignalV1,
  );
}

void _expectCopySafe(List<dynamic> taskSpecs) {
  final encoded = jsonEncode(
    taskSpecs
        .map(
          (dynamic task) => <String>[
            task.learnerPrompt as String,
            ...(task.choiceLabels as Map<String, String>).values,
            task.feedbackReason as String,
            ...(task.incorrectFeedback as Map<String, String>).values,
            task.boardContext as String,
            task.learningPurpose as String,
          ],
        )
        .toList(),
  ).toLowerCase();
  for (final forbidden in <String>[
    'gto',
    'solver',
    'optimal',
    'perfect',
    'mastered',
    'fixed',
    'guaranteed improvement',
    'proven improvement',
    'ai leak',
    'win-rate',
    'public',
    'playable',
    'lite',
    'combo density',
    'card removal',
    'gutshot',
    'thin value',
    'fold pressure',
    'suited texture pressure',
    'put it all together',
    'build winning habits',
    'develop your reads',
    'now you know',
    'you mastered',
  ]) {
    expect(encoded, isNot(contains(forbidden)));
  }
  for (final dynamic task in taskSpecs) {
    expect(task.learnerPrompt, isNot(contains(task.taskId)));
    expect(task.feedbackReason, isNot(contains(task.taskId)));
  }
}

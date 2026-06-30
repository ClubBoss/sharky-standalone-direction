import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_concept_candidate_practice_mapper_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_concept_family_repair_memory_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_transfer_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w11_board_texture_hidden_evidence_harness_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w11_board_texture_hidden_runtime_session_owner_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w12_review_decision_hidden_evidence_harness_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w12_review_decision_hidden_runtime_session_owner_v1.dart';

void main() {
  group('W11 internal world source template', () {
    const owner = Act0W11BoardTextureHiddenRuntimeSessionOwnerV1();
    const harness = Act0W11BoardTextureHiddenEvidenceHarnessV1();

    test('contains a coherent four-task hidden learning arc', () {
      expect(owner.taskSpecs, hasLength(4));
      expect(owner.taskSpecs.map((task) => task.taskId), <String>[
        'dry_board_texture_recognition_intro',
        'connected_board_texture_recognition_intro',
        'suited_texture_pressure_lite',
        'one_pair_board_danger_transfer_check',
      ]);

      _expectWorldTemplate(
        taskSpecs: owner.taskSpecs,
        worldId: 'world_11',
        lessonId: 'board_texture_danger_awareness_lite',
        conceptFamilyId: 'w11_board_texture_danger_awareness',
        mapperNoTargetReason: 'w11_route_locked_no_safe_practice_target_v1',
      );
    });

    test('supports only admitted W11 tasks', () {
      _expectSupportGate(
        owner: owner,
        taskSpecs: owner.taskSpecs,
        wrongWorldId: 'world_10',
        wrongTaskId: 'unowned_w11_task',
      );
    });

    test('each task writes correct and incorrect consumable evidence', () {
      final history = _appendAllTaskEvidence(harness, owner.taskSpecs);
      _expectConsumableEvidence(
        history: history,
        taskSpecs: owner.taskSpecs,
        conceptFamilyId: 'w11_board_texture_danger_awareness',
      );
    });

    test('rejects unknown choices and exposes no Practice launch request', () {
      _expectRejectsUnknownChoiceAndNoPractice(
        harness: harness,
        worldId: 'world_11',
        lessonId: 'board_texture_danger_awareness_lite',
        taskId: 'connected_board_texture_recognition_intro',
        wrongChoiceId: 'dry_board_safer_texture',
        attemptKey: 'texture_miss',
      );
    });

    test('learning arc copy is beginner readable and claim safe', () {
      _expectCopySafe(owner.taskSpecs);
    });
  });

  group('W12 internal world source template', () {
    const owner = Act0W12ReviewDecisionHiddenRuntimeSessionOwnerV1();
    const harness = Act0W12ReviewDecisionHiddenEvidenceHarnessV1();

    test('contains a coherent four-task hidden learning arc', () {
      expect(owner.taskSpecs, hasLength(4));
      expect(owner.taskSpecs.map((task) => task.taskId), <String>[
        'main_clue_identification_intro',
        'turn_card_change_recognition_intro',
        'safe_beginner_explanation_choice_lite',
        'combined_decision_read_transfer_check',
      ]);

      _expectWorldTemplate(
        taskSpecs: owner.taskSpecs,
        worldId: 'world_12',
        lessonId: 'review_decision_intuition_lite',
        conceptFamilyId: 'w12_review_decision_intuition',
        mapperNoTargetReason: 'w12_route_locked_no_safe_practice_target_v1',
      );
    });

    test('supports only admitted W12 tasks', () {
      _expectSupportGate(
        owner: owner,
        taskSpecs: owner.taskSpecs,
        wrongWorldId: 'world_11',
        wrongTaskId: 'unowned_w12_task',
      );
    });

    test('each task writes correct and incorrect consumable evidence', () {
      final history = _appendAllTaskEvidence(harness, owner.taskSpecs);
      _expectConsumableEvidence(
        history: history,
        taskSpecs: owner.taskSpecs,
        conceptFamilyId: 'w12_review_decision_intuition',
      );
    });

    test('rejects unknown choices and exposes no Practice launch request', () {
      _expectRejectsUnknownChoiceAndNoPractice(
        harness: harness,
        worldId: 'world_12',
        lessonId: 'review_decision_intuition_lite',
        taskId: 'main_clue_identification_intro',
        wrongChoiceId: 'bet_purpose_clue',
        attemptKey: 'review_miss',
      );
    });

    test('learning arc copy is beginner readable and claim safe', () {
      _expectCopySafe(owner.taskSpecs);
    });
  });
}

void _expectWorldTemplate({
  required List<dynamic> taskSpecs,
  required String worldId,
  required String lessonId,
  required String conceptFamilyId,
  required String mapperNoTargetReason,
}) {
  final purposes = taskSpecs
      .map((dynamic task) => task.learningPurpose)
      .toSet();
  expect(purposes, hasLength(4));
  for (final dynamic task in taskSpecs) {
    expect(task.worldId, worldId);
    expect(task.lessonId, lessonId);
    expect(task.conceptFamilyId, conceptFamilyId);
    expect(task.practiceCtaAllowed, isFalse);
    expect(task.mapperNoTargetReason, mapperNoTargetReason);
  }
}

void _expectSupportGate({
  required dynamic owner,
  required List<dynamic> taskSpecs,
  required String wrongWorldId,
  required String wrongTaskId,
}) {
  for (final dynamic task in taskSpecs) {
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
      worldId: taskSpecs.first.worldId,
      lessonId: taskSpecs.first.lessonId,
      taskId: wrongTaskId,
    ),
    isFalse,
  );
  expect(
    owner.supports(
      worldId: wrongWorldId,
      lessonId: taskSpecs.first.lessonId,
      taskId: taskSpecs.first.taskId,
    ),
    isFalse,
  );
}

Act0LearningEvidenceHistoryV1 _appendAllTaskEvidence(
  dynamic harness,
  List<dynamic> taskSpecs,
) {
  var history = const Act0LearningEvidenceHistoryV1();
  for (final dynamic task in taskSpecs) {
    final wrongChoice = task.choiceIds.firstWhere(
      (dynamic choiceId) => choiceId != task.expectedChoiceId,
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
  return history;
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

void _expectRejectsUnknownChoiceAndNoPractice({
  required dynamic harness,
  required String worldId,
  required String lessonId,
  required String taskId,
  required String wrongChoiceId,
  required String attemptKey,
}) {
  expect(
    () => harness.submitChoice(
      history: const Act0LearningEvidenceHistoryV1(),
      worldId: worldId,
      lessonId: lessonId,
      taskId: taskId,
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
      worldId: worldId,
      lessonId: lessonId,
      taskId: taskId,
      selectedChoiceId: wrongChoiceId,
      attemptKey: attemptKey,
      decisionTimeBucket: 'under_3s',
    ),
  ).nextRepairCandidate;
  final mapped = mapAct0ConceptCandidateToPracticeLaunchRequestV1(candidate);
  expect(mapped.isMapped, isFalse);
  expect(mapped.request, isNull);
}

void _expectCopySafe(List<dynamic> taskSpecs) {
  final encoded = jsonEncode(
    taskSpecs.map((dynamic task) => task.copySafetyPayload).toList(),
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
    'integrated mastery',
  ]) {
    expect(encoded, isNot(contains(forbidden)));
  }
  for (final dynamic task in taskSpecs) {
    expect(task.learnerPrompt, isNot(contains(task.taskId)));
    expect(task.feedbackReason, isNot(contains(task.taskId)));
  }
}

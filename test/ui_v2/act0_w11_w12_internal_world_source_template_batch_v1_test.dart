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
        'w11_session_plan_hidden',
        'w11_table_trigger_hidden',
        'w11_review_loop_hidden',
        'w11_real_play_loop_hidden',
      ]);

      _expectWorldTemplate(
        taskSpecs: owner.taskSpecs,
        worldId: 'world_11',
        conceptFamilyId: 'w11_real_play_transfer',
        practiceCtaAllowed: true,
        mapperNoTargetReason: '',
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

    test('canonical task writes correct and incorrect consumable evidence', () {
      final history = _appendCanonicalTaskEvidence(harness, owner.taskSpec);
      _expectConsumableEvidence(
        history: history,
        taskSpecs: <dynamic>[owner.taskSpec],
        conceptFamilyId: 'w11_real_play_transfer',
      );
    });

    test(
      'rejects unknown choices and maps admitted Practice launch request',
      () {
        _expectRejectsUnknownChoiceAndMapsPractice(
          harness: harness,
          worldId: 'world_11',
          lessonId: owner.taskSpec.lessonId,
          taskId: owner.taskSpec.taskId,
          wrongChoiceId:
              owner.taskSpec.choiceIds.firstWhere(
                    (dynamic choiceId) =>
                        choiceId != owner.taskSpec.expectedChoiceId,
                  )
                  as String,
          attemptKey: 'w11_hidden_miss',
        );
      },
    );

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
        'w12_tilt_reset_hidden',
        'w12_process_quality_hidden',
        'w12_confidence_discipline_hidden',
        'w12_mindset_bridge_loop_hidden',
      ]);

      _expectWorldTemplate(
        taskSpecs: owner.taskSpecs,
        worldId: 'world_12',
        conceptFamilyId: 'w12_mindset_bridge',
        practiceCtaAllowed: true,
        mapperNoTargetReason: '',
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

    test('canonical task writes correct and incorrect consumable evidence', () {
      final history = _appendCanonicalTaskEvidence(harness, owner.taskSpec);
      _expectConsumableEvidence(
        history: history,
        taskSpecs: <dynamic>[owner.taskSpec],
        conceptFamilyId: 'w12_mindset_bridge',
      );
    });

    test(
      'rejects unknown choices and maps admitted Practice launch request',
      () {
        _expectRejectsUnknownChoiceAndMapsPractice(
          harness: harness,
          worldId: 'world_12',
          lessonId: owner.taskSpec.lessonId,
          taskId: owner.taskSpec.taskId,
          wrongChoiceId:
              owner.taskSpec.choiceIds.firstWhere(
                    (dynamic choiceId) =>
                        choiceId != owner.taskSpec.expectedChoiceId,
                  )
                  as String,
          attemptKey: 'w12_hidden_miss',
        );
      },
    );

    test('learning arc copy is beginner readable and claim safe', () {
      _expectCopySafe(owner.taskSpecs);
    });
  });
}

void _expectWorldTemplate({
  required List<dynamic> taskSpecs,
  required String worldId,
  required String conceptFamilyId,
  required bool practiceCtaAllowed,
  required String mapperNoTargetReason,
}) {
  final purposes = taskSpecs
      .map((dynamic task) => task.learningPurpose)
      .toSet();
  expect(purposes, hasLength(4));
  for (final dynamic task in taskSpecs) {
    expect(task.worldId, worldId);
    expect((task.lessonId as String).trim(), isNotEmpty);
    expect(task.conceptFamilyId, conceptFamilyId);
    expect(task.practiceCtaAllowed, practiceCtaAllowed);
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

Act0LearningEvidenceHistoryV1 _appendCanonicalTaskEvidence(
  dynamic harness,
  dynamic task,
) {
  var history = const Act0LearningEvidenceHistoryV1();
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

void _expectRejectsUnknownChoiceAndMapsPractice({
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
  expect(mapped.isMapped, isTrue);
  expect(mapped.request, isNotNull);
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
    'integrated mastery',
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

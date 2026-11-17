// SIMULATED pure-contract evidence on actual authored tasks. This supplies no
// app state, application/elapsed proof, native traversal or alternate validator.
import 'dart:convert';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';

import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_learning_time_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_practice_repair_queue_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_queue_resolution_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_outcome_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

Act0LessonTaskV1 act0AuthoredRepairFixtureTaskV1(
  String worldId,
  String lessonId,
  String taskId,
) => Act0ShellStateV1.sample
    .worldById(worldId)
    .lessons
    .singleWhere((lesson) => lesson.lessonId == lessonId)
    .taskList
    .singleWhere((task) => task.taskId == taskId);

String? act0AuthoredRepairFixtureFingerprintV1({
  required String worldId,
  required String lessonId,
  required String taskId,
}) {
  for (final world in Act0ShellStateV1.sample.worlds) {
    if (world.worldId != worldId) continue;
    for (final lesson in world.lessons) {
      if (lesson.lessonId != lessonId) continue;
      for (final task in lesson.taskList) {
        if (task.taskId == taskId)
          return act0AuthoredSourceFingerprintV1(
            worldId: worldId,
            lessonId: lessonId,
            task: task,
          );
      }
    }
  }
  return null;
}

class Act0AuthoredRepairGoalFixtureV1 {
  Act0AuthoredRepairGoalFixtureV1.noBet({
    String choiceId = 'fold',
    String occurrenceId = 'source_miss_A',
  }) : intent = _intent(
         'world_1',
         'fold_check_call_raise',
         'actions_legal_context',
         choiceId,
         occurrenceId,
       );

  Act0AuthoredRepairGoalFixtureV1.rank({
    String occurrenceId = 'source_miss_rank',
  }) : intent = _intent(
         'world_1',
         'cards_ranks_suits',
         'cards_ranks_suits_rank_drill',
         'king',
         occurrenceId,
       );

  Act0AuthoredRepairGoalFixtureV1.w24({String occurrenceId = 'source_miss_W24'})
    : intent = _intent(
        'world_3',
        'same_hand_different_seat',
        'same_hand_different_seat_w3_same_hand_recap',
        'one_answer',
        occurrenceId,
      );

  final Act0RepairIntentV1 intent;
  String get queueItemId => queueItemIdForAct0RepairIntentV1(intent);

  static Act0RepairIntentV1 _intent(
    String world,
    String lesson,
    String taskId,
    String choiceId,
    String occurrenceId,
  ) {
    final task = act0AuthoredRepairFixtureTaskV1(world, lesson, taskId);
    final choice = task.runner.options.singleWhere((o) => o.id == choiceId);
    if (choice.isCorrect)
      throw StateError('Fixture requires an actual wrong choice');
    final built = buildAct0RepairIntentV1(
      sourceWorldId: world,
      sourceLessonId: lesson,
      sourceTaskId: taskId,
      runner: task.runner,
      selectedOption: choice,
      currentFingerprintForIdentity: act0AuthoredRepairFixtureFingerprintV1,
    );
    if (built == null)
      throw StateError('Authored source did not create an intent');
    return Act0RepairIntentV1.tryParse({
      ...built.toPayload(),
      'repairOccurrenceId': occurrenceId,
    })!;
  }

  Act0RepairOutcomeV1 outcome({
    int sequence = 3,
    bool isCorrect = true,
    String? attemptId,
    String sessionId = 'repair-session',
  }) {
    final target = act0AuthoredRepairFixtureTaskV1(
      intent.targetWorldId,
      intent.targetLessonId,
      intent.targetTaskId,
    );
    final correct = target.runner.options.singleWhere((o) => o.isCorrect);
    final selected = isCorrect
        ? correct
        : target.runner.options.firstWhere((o) => !o.isCorrect);
    return Act0RepairOutcomeV1(
      repairIntent: intent,
      repairOccurrenceId: intent.repairOccurrenceId,
      repairAttemptId: attemptId ?? 'repair_attempt_$sequence',
      sourceTaskId: intent.sourceTaskId,
      repairTaskId: intent.targetTaskId,
      repairFocusKey: repairQueueIdentityKeyForAct0RepairIntentV1(intent),
      queueItemId: queueItemId,
      targetWorldId: intent.targetWorldId,
      targetLessonId: intent.targetLessonId,
      targetTaskId: intent.targetTaskId,
      selectedChoiceId: selected.id,
      correctChoiceId: correct.id,
      isCorrect: selected.isCorrect,
      outcomeState: selected.isCorrect
          ? act0RepairOutcomeStateCorrectV1
          : act0RepairOutcomeStateStillNeedsRepV1,
      sequence: sequence,
      sourceType: act0PracticeRepairQueueSourceActiveRepairV1,
      sessionId: sessionId,
    );
  }
}

Act0LearningEvidenceRecordV1 act0AuthoredRepairFixtureSourceV1(
  Act0RepairIntentV1 intent, {
  int order = 1,
}) {
  final task = act0AuthoredRepairFixtureTaskV1(
    intent.sourceWorldId,
    intent.sourceLessonId,
    intent.sourceTaskId,
  );
  final choice = task.runner.options.singleWhere(
    (o) => o.id == intent.choiceId,
  );
  final correct = task.runner.options.singleWhere((o) => o.isCorrect);
  if (choice.isCorrect || intent.repairOccurrenceId.isEmpty)
    throw StateError('No source miss');
  return Act0LearningEvidenceRecordV1(
    recordId: intent.repairOccurrenceId,
    createdOrder: order,
    worldId: intent.sourceWorldId,
    lessonId: intent.sourceLessonId,
    taskId: intent.sourceTaskId,
    sourceTaskId: intent.sourceTaskId,
    choiceId: choice.id,
    expectedChoiceId: correct.id,
    isCorrect: choice.isCorrect,
    errorType: intent.errorType,
    conceptFamilyId: intent.missedSignalId,
    repairFocusId: intent.missedSignalId,
    skillAtomId: intent.skillAtomId,
    decisionTimeBucket: '3_to_10s',
    resultKind: choice.quality == Act0FeedbackQualityV1.suboptimal
        ? 'suboptimal'
        : 'incorrect',
    runId: 'source-run-${intent.repairOccurrenceId}',
    runKind: 'lesson',
    runOrdinal: 1,
    sessionId: 'source-session',
    recordedAtUtc: DateTime.utc(2026, 11, 17),
    reviewKind: Act0ReviewKindV1.initialAssessment,
    assistanceKind: Act0DecisionAssistanceV1.none,
    authoredSourceFingerprint: act0AuthoredRepairFixtureFingerprintV1(
      worldId: intent.sourceWorldId,
      lessonId: intent.sourceLessonId,
      taskId: intent.sourceTaskId,
    )!,
  );
}

Act0LearningEvidenceRecordV1 act0AuthoredRepairFixtureAttemptV1(
  Act0RepairOutcomeV1 outcome, {
  required int order,
}) {
  final intent = outcome.repairIntent;
  if (intent == null || outcome.repairAttemptId.isEmpty)
    throw StateError('Explicit fixture witness required');
  // Canonical task/choice owns truth. Never generate a new source/goal, an
  // invented target grade or an application role from the outer outcome.
  final task = act0AuthoredRepairFixtureTaskV1(
    intent.targetWorldId,
    intent.targetLessonId,
    intent.targetTaskId,
  );
  final choice = task.runner.options.singleWhere(
    (o) => o.id == outcome.selectedChoiceId,
  );
  final correct = task.runner.options.singleWhere((o) => o.isCorrect);
  return Act0LearningEvidenceRecordV1(
    recordId: outcome.repairAttemptId,
    createdOrder: order,
    worldId: intent.targetWorldId,
    lessonId: intent.targetLessonId,
    taskId: intent.targetTaskId,
    sourceTaskId: intent.targetTaskId,
    choiceId: choice.id,
    expectedChoiceId: correct.id,
    isCorrect: choice.isCorrect,
    errorType: choice.isCorrect ? 'none' : intent.errorType,
    conceptFamilyId: intent.missedSignalId,
    repairFocusId: intent.missedSignalId,
    skillAtomId: intent.skillAtomId,
    decisionTimeBucket: '3_to_10s',
    resultKind: choice.isCorrect
        ? 'correct'
        : choice.quality == Act0FeedbackQualityV1.suboptimal
        ? 'suboptimal'
        : 'incorrect',
    runId: 'repair-run-${outcome.repairAttemptId}',
    runKind: 'repair',
    runOrdinal: 2,
    sessionId: outcome.sessionId,
    recordedAtUtc: DateTime.utc(2026, 11, 17, 0, 1),
    reviewKind: act0IsExactRepairMappingTypeV1(intent.mappingType)
        ? Act0ReviewKindV1.exactReplay
        : Act0ReviewKindV1.alternateSameSignal,
    assistanceKind: Act0DecisionAssistanceV1.none,
    authoredSourceFingerprint: act0AuthoredRepairFixtureFingerprintV1(
      worldId: intent.targetWorldId,
      lessonId: intent.targetLessonId,
      taskId: intent.targetTaskId,
    )!,
  );
}

Act0LearningEvidenceHistoryV1 act0AuthoredRepairFixtureHistoryV1({
  Iterable<Act0RepairIntentV1> intents = const [],
  Iterable<Act0RepairOutcomeV1> outcomes = const [],
}) {
  final sources = <String, Act0RepairIntentV1>{};
  for (final intent in intents) {
    if (intent.repairOccurrenceId.isNotEmpty)
      sources[intent.repairOccurrenceId] = intent;
  }
  for (final outcome in outcomes) {
    final witness = outcome.repairIntent;
    if (witness != null)
      sources.putIfAbsent(witness.repairOccurrenceId, () => witness);
  }
  final records = <String, Act0LearningEvidenceRecordV1>{};
  void add(Act0LearningEvidenceRecordV1 record) {
    final old = records[record.recordId];
    if (old != null &&
        jsonEncode(old.toPayload()) != jsonEncode(record.toPayload())) {
      throw StateError(
        'Conflicting fixture event; supply explicit evidence for this negative',
      );
    }
    records[record.recordId] = record;
  }

  var order = 0;
  for (final intent in sources.values)
    add(act0AuthoredRepairFixtureSourceV1(intent, order: ++order));
  final base = order + 10;
  for (final outcome in outcomes)
    add(
      act0AuthoredRepairFixtureAttemptV1(
        outcome,
        order: base + outcome.sequence,
      ),
    );
  final ordered = records.values.toList()
    ..sort(
      (a, b) => a.createdOrder != b.createdOrder
          ? a.createdOrder.compareTo(b.createdOrder)
          : a.recordId.compareTo(b.recordId),
    );
  return Act0LearningEvidenceHistoryV1(records: ordered);
}

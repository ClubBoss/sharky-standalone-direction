// SIMULATED contract controls on current authored tasks; no native/Human proof.
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_achievement_seed_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_retention_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_profile_evidence_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_concept_family_state_foundation_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_learning_time_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_receipt_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_fix_proof_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_multi_repair_queue_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_practice_repair_queue_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_queue_resolution_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_outcome_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_outcome_consumer_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_mistake_history_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_resolution_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

typedef _Subject = ({String world, String lesson, String task, String choice});

const _bad = <_Subject>[
  (
    world: "world_1",
    lesson: "what_poker_is",
    task: "what_poker_is_find_hero",
    choice: "random",
  ),
  (
    world: 'world_2',
    lesson: 'hand_discipline_buckets',
    task: 'hand_discipline_buckets_premium',
    choice: 'medium',
  ),
  (
    world: 'world_2',
    lesson: 'continue_or_let_go',
    task: 'continue_or_let_go_premium_continue',
    choice: 'medium',
  ),
  (
    world: 'world_2',
    lesson: 'discipline_checkpoint',
    task: 'discipline_checkpoint_checkpoint_premium',
    choice: 'medium',
  ),
  (
    world: 'world_4',
    lesson: 'small_half_pot',
    task: 'w4_half_pot_bet',
    choice: 'two',
  ),
  (
    world: 'world_4',
    lesson: 'small_half_pot',
    task: 'w4_half_pot_bet',
    choice: 'six',
  ),
  (
    world: 'world_1',
    lesson: 'your_first_hand',
    task: 'your_first_hand_showdown',
    choice: 'first_actor',
  ),
  (
    world: 'world_1',
    lesson: 'your_first_hand',
    task: 'your_first_hand_showdown',
    choice: 'hero_cards_only',
  ),
];
const _rehearsals = <_Subject>[
  (
    world: "world_1",
    lesson: "cards_ranks_suits",
    task: "cards_ranks_suits_rank_drill",
    choice: "king",
  ),
  (
    world: "world_1",
    lesson: "cards_ranks_suits",
    task: "cards_ranks_suits_rank_drill",
    choice: "suit",
  ),
  (
    world: "world_1",
    lesson: "fold_check_call_raise",
    task: "actions_check_drill",
    choice: "pay_small_blind",
  ),
  (
    world: "world_1",
    lesson: "fold_check_call_raise",
    task: "actions_check_drill",
    choice: "pay_big_blind",
  ),
  (
    world: 'world_1',
    lesson: 'fold_check_call_raise',
    task: 'actions_legal_context',
    choice: 'fold',
  ),
  (
    world: 'world_1',
    lesson: 'fold_check_call_raise',
    task: 'actions_legal_context',
    choice: 'call',
  ),
  (
    world: 'world_3',
    lesson: 'same_hand_different_seat',
    task: 'same_hand_different_seat_w3_same_hand_recap',
    choice: 'one_answer',
  ),
  (
    world: "world_1",
    lesson: "what_poker_is",
    task: "what_poker_is_find_hero",
    choice: "top",
  ),
];

Act0LessonTaskV1 _task(String world, String lesson, String task) =>
    Act0ShellStateV1.sample
        .worldById(world)
        .lessons
        .singleWhere((value) => value.lessonId == lesson)
        .taskList
        .singleWhere((value) => value.taskId == task);

String? _fingerprint({
  required String worldId,
  required String lessonId,
  required String taskId,
}) {
  for (final world in Act0ShellStateV1.sample.worlds) {
    if (world.worldId != worldId) continue;
    for (final lesson in world.lessons) {
      if (lesson.lessonId != lessonId) continue;
      for (final task in lesson.taskList) {
        if (task.taskId == taskId) {
          return act0AuthoredSourceFingerprintV1(
            worldId: worldId,
            lessonId: lessonId,
            task: task,
          );
        }
      }
    }
  }
  return null;
}

Act0RepairIntentV1 _intent(_Subject source) {
  final task = _task(source.world, source.lesson, source.task);
  final wrong = task.runner.options.singleWhere(
    (option) => option.id == source.choice,
  );
  expect(wrong.isCorrect, isFalse);
  final intent = buildAct0RepairIntentV1(
    sourceWorldId: source.world,
    sourceLessonId: source.lesson,
    sourceTaskId: source.task,
    runner: task.runner,
    selectedOption: wrong,
    mapSameSignalRep: act0FirstValueSameSignalRepMappingV1,
    currentFingerprintForIdentity: _fingerprint,
  )!;
  return Act0RepairIntentV1.tryParse({
    ...intent.toPayload(),
    'repairOccurrenceId': 'miss-${source.task}-${source.choice}',
  })!;
}

Act0LearningEvidenceRecordV1 _sourceRecord(Act0RepairIntentV1 intent) {
  final task = _task(
    intent.sourceWorldId,
    intent.sourceLessonId,
    intent.sourceTaskId,
  );
  return Act0LearningEvidenceRecordV1(
    recordId: intent.repairOccurrenceId,
    createdOrder: 1,
    worldId: intent.sourceWorldId,
    lessonId: intent.sourceLessonId,
    taskId: intent.sourceTaskId,
    sourceTaskId: intent.sourceTaskId,
    choiceId: intent.choiceId,
    expectedChoiceId: task.runner.options
        .firstWhere((option) => option.isCorrect)
        .id,
    isCorrect: false,
    errorType: intent.errorType,
    conceptFamilyId: intent.missedSignalId,
    repairFocusId: intent.missedSignalId,
    skillAtomId: intent.skillAtomId,
    decisionTimeBucket: '3_to_10s',
    resultKind: 'incorrect',
    runId: 'source-run',
    runKind: 'lesson',
    runOrdinal: 1,
    sessionId: 'source-session',
    recordedAtUtc: DateTime.utc(2026, 11, 17),
    reviewKind: Act0ReviewKindV1.initialAssessment,
    assistanceKind: Act0DecisionAssistanceV1.none,
    authoredSourceFingerprint: _fingerprint(
      worldId: intent.sourceWorldId,
      lessonId: intent.sourceLessonId,
      taskId: intent.sourceTaskId,
    )!,
  );
}

Act0LearningEvidenceHistoryV1 _history(Act0RepairIntentV1 intent) =>
    Act0LearningEvidenceHistoryV1(records: [_sourceRecord(intent)]);

Act0ReviewMistakeHistoryV1 _reviewHistory(
  Act0LearningEvidenceRecordV1 source,
) => Act0ReviewMistakeHistoryV1(
  records: [
    Act0ReviewMistakeRecordV1(
      recordId: 'review-${source.recordId}',
      sourceDecisionId: source.recordId,
      createdOrder: source.createdOrder,
      updatedOrder: source.createdOrder,
      worldId: source.worldId,
      lessonId: source.lessonId,
      decisionTaskId: source.taskId,
      sourceTaskId: source.taskId,
      decisionKind:
          _task(
            source.worldId,
            source.lessonId,
            source.taskId,
          ).runner.sizingConfig.isEnabled
          ? 'sizing'
          : 'actionList',
      selectedId: source.choiceId,
      expectedId: source.expectedChoiceId,
      resultKind: source.resultKind,
      errorType: source.errorType,
      skillAtomId: source.skillAtomId,
      repairFocusId: source.repairFocusId,
      runId: source.runId,
      runKind: source.runKind,
      runOrdinal: source.runOrdinal,
      attemptRecordIds: [source.recordId],
      dedupUsesFallback: false,
    ),
  ],
);

// SIMULATED canonical append using actual task options/grades/fingerprints.
({Act0LearningEvidenceHistoryV1 history, Act0CompletedDecisionV1 decision})
_appendAuthoredDiagnosticControl({
  required Act0LearningEvidenceHistoryV1 history,
  required Act0RepairIntentV1 focus,
  required _Subject subject,
  required String attemptId,
  required String runKind,
  Act0ReviewKindV1 reviewKind = Act0ReviewKindV1.initialAssessment,
}) {
  final task = _task(subject.world, subject.lesson, subject.task);
  final selected = task.runner.options.singleWhere(
    (o) => o.id == subject.choice,
  );
  final correct = task.runner.options.singleWhere((o) => o.isCorrect);
  final decision = Act0CompletedDecisionV1(
    attemptKey: attemptId,
    worldId: subject.world,
    lessonId: subject.lesson,
    taskId: subject.task,
    sourceTaskId: subject.task,
    decisionKind: Act0CompletedDecisionKindV1.actionList,
    selectedId: selected.id,
    expectedId: correct.id,
    isCorrect: selected.isCorrect,
    decisionTimeBucket: '3_to_10s',
    taskFamily: task.resolvedTaskFamily,
    resultKind: selected.isCorrect
        ? 'correct'
        : selected.quality == Act0FeedbackQualityV1.suboptimal
        ? 'suboptimal'
        : 'incorrect',
    errorType: selected.isCorrect ? 'none' : focus.errorType,
    conceptFamilyId: focus.missedSignalId,
    repairFocusId: focus.missedSignalId,
    skillAtomId: focus.skillAtomId,
    missedSignalId: focus.missedSignalId,
    assistanceKind: Act0DecisionAssistanceV1.none,
  );
  final order =
      history.provenanceRecords.fold<int>(
        0,
        (value, record) =>
            record.createdOrder > value ? record.createdOrder : value,
      ) +
      1;
  return (
    decision: decision,
    history: history.appendCompletedDecision(
      decision,
      authoredSourceFingerprint: _fingerprint(
        worldId: subject.world,
        lessonId: subject.lesson,
        taskId: subject.task,
      )!,
      runKey: Act0EvidenceRunKeyV1(
        runId: 'control-$attemptId',
        worldId: subject.world,
        lessonId: subject.lesson,
        runOrdinal: order,
        runKind: runKind,
        startedBy: runKind == act0DiagnosticLearningEntryRunKindV1
            ? 'placement_learning_entry'
            : 'simulated_authored_repair',
      ),
      sessionId: 'session-$attemptId',
      recordedAtUtc: DateTime.utc(2026, 11, 17).add(Duration(minutes: order)),
      reviewKind: reviewKind,
    ),
  );
}

void main() {
  test(
    'diagnostic teaching keeps actual correct grade but cannot mint independent proof',
    () {
      final intent = _intent(
        _rehearsals[4],
      ); // Actual legal-context fold -> Check.
      const target = (
        world: 'world_1',
        lesson: 'fold_check_call_raise',
        task: 'actions_check_drill',
        choice: 'check',
      );
      final added = _appendAuthoredDiagnosticControl(
        history: const Act0LearningEvidenceHistoryV1(),
        focus: intent,
        subject: target,
        attemptId: 'guided-check',
        runKind: act0DiagnosticLearningEntryRunKindV1,
      );
      final restored = Act0LearningEvidenceHistoryV1.tryParseStorageString(
        added.history.toStorageString(),
      )!;
      final raw = restored.records.single;
      expect(raw.toPayload(), added.history.records.single.toPayload());
      expect(raw.choiceId, 'check');
      expect(raw.expectedChoiceId, 'check');
      expect(raw.isCorrect, isTrue);
      expect(raw.resultKind, 'correct');
      expect(raw.assistanceKind, Act0DecisionAssistanceV1.none);
      expect(raw.isDiagnosticLearningEntry, isTrue);
      expect(raw.isPlacementAssessment, isFalse);
      expect(raw.isIndependentCorrect, isFalse);
      expect(restored.sourceAnchors, isEmpty);
      expect(restored.latestRunSummary(), isNull);
      expect(act0CurrentAuthoredSourceProofV1(raw), isNull);
      final profile =
          Act0ProfileEvidenceProjectionV1.fromLearningEvidenceHistory(
            restored,
            nowUtc: DateTime.utc(2026, 11, 17, 1),
          );
      expect(profile.signals, isEmpty);
      expect(profile.practiceStates, isEmpty);
      expect(profile.hasUnverifiedPractice, isFalse);
      final seeds = Act0AchievementSeedProjectionV1.fromSources(
        learningEvidenceHistory: restored,
      );
      final first = seeds.seedForId(act0AchievementSeedFirstCorrectReadV1);
      expect(first.earned, isFalse);
      expect(first.sourceSummary, isEmpty);
      expect(
        seeds.seedForId(act0AchievementSeedFirstSessionCompleteV1).earned,
        isFalse,
      );
      expect(
        Act0DurableRetentionHistoryV1.fromLearningEvidence(restored).families,
        isEmpty,
      );
      expect(
        Act0ConceptFamilyStateHistoryV1.fromLearningEvidence(restored).families,
        isEmpty,
      );
      expect(
        const Act0ReviewMistakeHistoryV1()
            .appendCompletedDecision(
              added.decision,
              runId: raw.runId,
              runKind: raw.runKind,
              runOrdinal: raw.runOrdinal,
            )
            .records,
        isEmpty,
      );
      expect(
        Act0FixProofProjectionV1.fromSources(
          repairOutcomeProjection: const Act0RepairOutcomeProjectionV1(),
          reviewResolutionReceiptHistory:
              const Act0ReviewResolutionReceiptHistoryV1(),
          learningEvidenceHistory: restored,
          currentFingerprintForIdentity: _fingerprint,
        ).proofs,
        isEmpty,
      );

      // Same actual target/grade/current FP after an authentic source occurrence
      // still cannot impersonate the existing independent repair attempt role.
      final source = _sourceRecord(intent);
      final withSource = _appendAuthoredDiagnosticControl(
        history: Act0LearningEvidenceHistoryV1(records: [source]),
        focus: intent,
        subject: target,
        attemptId: 'guided-after-real-miss',
        runKind: act0DiagnosticLearningEntryRunKindV1,
        reviewKind: Act0ReviewKindV1.immediateRepair,
      );
      final guided = withSource.history.records.last;
      final fakeRepair = Act0RepairOutcomeV1(
        repairIntent: intent,
        repairOccurrenceId: intent.repairOccurrenceId,
        repairAttemptId: guided.recordId,
        sourceTaskId: intent.sourceTaskId,
        repairTaskId: intent.targetTaskId,
        repairFocusKey: intent.missedSignalId,
        queueItemId: queueItemIdForAct0RepairIntentV1(intent),
        targetWorldId: intent.targetWorldId,
        targetLessonId: intent.targetLessonId,
        targetTaskId: intent.targetTaskId,
        selectedChoiceId: 'check',
        correctChoiceId: 'check',
        isCorrect: true,
        outcomeState: act0RepairOutcomeStateCorrectV1,
        sequence: 1,
        sourceType: act0PracticeRepairQueueSourceActiveRepairV1,
        sessionId: guided.sessionId,
      );
      expect(
        act0RepairGoalResolutionForIntentV1(
          intent,
          learningEvidence: withSource.history,
          currentFingerprintForIdentity: _fingerprint,
        ).canLaunch,
        isTrue,
      );
      expect(
        act0RepairGoalOutcomeIsEligibleV1(
          intent: intent,
          outcome: fakeRepair,
          learningEvidence: withSource.history,
          currentFingerprintForIdentity: _fingerprint,
        ),
        isFalse,
      );
      expect(
        Act0QueueResolutionStateV1.fromSources(
          activeRepairIntents: [intent],
          repairOutcomeProjection: Act0RepairOutcomeProjectionV1(
            outcomes: [fakeRepair],
          ),
          learningEvidenceHistory: withSource.history,
          currentFingerprintForIdentity: _fingerprint,
        ).resolutions.single.resolutionState,
        isNot(act0QueueResolutionStateResolvedV1),
      );
      expect(
        Act0ReviewResolutionStateV1.fromSources(
          reviewMistakeHistory: _reviewHistory(source),
          activeRepairIntents: [intent],
          repairOutcomeProjection: Act0RepairOutcomeProjectionV1(
            outcomes: [fakeRepair],
          ),
          learningEvidenceHistory: withSource.history,
          currentFingerprintForIdentity: _fingerprint,
        ).resolutions.single.reviewState,
        isNot(act0ReviewResolutionStateResolvedV1),
      );
    },
  );

  test(
    'guided Check answers cannot alter existing due or cap a genuine source repair',
    () {
      // The guided Check destination genuinely coincides with this existing
      // ordinary repair's original source, exercising the prior-proof cap seam.
      final intent = _intent(_rehearsals[2]); // Check cost -> legal context.
      final source = _sourceRecord(intent);
      final target = _task(
        intent.targetWorldId,
        intent.targetLessonId,
        intent.targetTaskId,
      );
      final correct = target.runner.options.singleWhere((o) => o.isCorrect).id;
      final normal = _appendAuthoredDiagnosticControl(
        history: Act0LearningEvidenceHistoryV1(records: [source]),
        focus: intent,
        subject: (
          world: intent.targetWorldId,
          lesson: intent.targetLessonId,
          task: intent.targetTaskId,
          choice: correct,
        ),
        attemptId: 'genuine-ordinary-repair',
        runKind: 'repair',
        reviewKind: Act0ReviewKindV1.alternateSameSignal,
      );
      var history = normal.history;
      final attempt = history.records.last;
      final outcome = Act0RepairOutcomeV1(
        repairIntent: intent,
        repairOccurrenceId: intent.repairOccurrenceId,
        repairAttemptId: attempt.recordId,
        sourceTaskId: intent.sourceTaskId,
        repairTaskId: intent.targetTaskId,
        repairFocusKey: intent.missedSignalId,
        queueItemId: queueItemIdForAct0RepairIntentV1(intent),
        targetWorldId: intent.targetWorldId,
        targetLessonId: intent.targetLessonId,
        targetTaskId: intent.targetTaskId,
        selectedChoiceId: correct,
        correctChoiceId: correct,
        isCorrect: true,
        outcomeState: act0RepairOutcomeStateCorrectV1,
        sequence: 1,
        sourceType: act0PracticeRepairQueueSourceActiveRepairV1,
        sessionId: attempt.sessionId,
      );
      expect(
        act0RepairGoalOutcomeIsEligibleV1(
          intent: intent,
          outcome: outcome,
          learningEvidence: history,
          currentFingerprintForIdentity: _fingerprint,
        ),
        isTrue,
      );
      final outcomes = Act0RepairOutcomeProjectionV1(outcomes: [outcome]);
      final review = _reviewHistory(source);
      final receipts = reviewResolutionReceiptHistoryFromSourcesV1(
        reviewMistakeHistory: review,
        activeRepairIntents: [intent],
        repairOutcomeProjection: outcomes,
        existingReceiptHistory: const Act0ReviewResolutionReceiptHistoryV1(),
        learningEvidenceHistory: history,
        currentFingerprintForIdentity: _fingerprint,
      );
      final banked = Act0FixProofProjectionV1.fromSources(
        repairOutcomeProjection: outcomes,
        reviewResolutionReceiptHistory: receipts,
        learningEvidenceHistory: history,
        currentFingerprintForIdentity: _fingerprint,
      );
      expect(banked.proofs, hasLength(1));
      final durable = Act0DurableRetentionHistoryV1.fromLearningEvidence(
        history,
      );
      expect(durable.families, isNotEmpty);
      expect(durable.families.any((f) => f.nextDueAtUtc != null), isTrue);
      final concepts = Act0ConceptFamilyStateHistoryV1.fromLearningEvidence(
        history,
      );
      final anchorBytes = history.sourceAnchors
          .map((r) => r.toPayload())
          .toList();
      final firstRead = Act0AchievementSeedProjectionV1.fromSources(
        learningEvidenceHistory: history,
      ).seedForId(act0AchievementSeedFirstCorrectReadV1);
      expect(firstRead.earned, isTrue);
      expect(firstRead.sourceSummary['completedCorrectDecisions'], 1);
      for (final choice in ['check', 'pay_small_blind']) {
        final next = _appendAuthoredDiagnosticControl(
          history: history,
          focus: intent,
          subject: (
            world: 'world_1',
            lesson: 'fold_check_call_raise',
            task: 'actions_check_drill',
            choice: choice,
          ),
          attemptId: 'guided-source-$choice',
          runKind: act0DiagnosticLearningEntryRunKindV1,
        );
        history = next.history;
        final raw = history.records.last;
        expect(raw.isCorrect, choice == 'check');
        expect(raw.assistanceKind, Act0DecisionAssistanceV1.none);
        expect(raw.isIndependentCorrect, isFalse);
        expect(
          history.sourceAnchors.map((r) => r.toPayload()).toList(),
          anchorBytes,
        );
        expect(
          Act0DurableRetentionHistoryV1.fromLearningEvidence(
            history,
          ).toPayload(),
          durable.toPayload(),
        );
        final currentConcepts =
            Act0ConceptFamilyStateHistoryV1.fromLearningEvidence(history);
        expect(currentConcepts.toPayload(), concepts.toPayload());
        expect(currentConcepts.appliedSourceIds, concepts.appliedSourceIds);
        expect(
          review
              .appendCompletedDecision(
                next.decision,
                runId: raw.runId,
                runKind: raw.runKind,
                runOrdinal: raw.runOrdinal,
              )
              .toPayload(),
          review.toPayload(),
        );
        final currentSeeds = Act0AchievementSeedProjectionV1.fromSources(
          learningEvidenceHistory: history,
        );
        expect(
          currentSeeds
              .seedForId(act0AchievementSeedFirstCorrectReadV1)
              .sourceSummary,
          firstRead.sourceSummary,
        );
        final currentProof = Act0FixProofProjectionV1.fromSources(
          repairOutcomeProjection: outcomes,
          reviewResolutionReceiptHistory: receipts,
          learningEvidenceHistory: history,
          currentFingerprintForIdentity: _fingerprint,
        );
        expect(currentProof.toPayload(), banked.toPayload());
        expect(
          Act0RepairOutcomeConsumerV1.fromProjection(
            outcomes,
            fixProofProjection: currentProof,
            learningEvidenceHistory: history,
            currentFingerprintForIdentity: _fingerprint,
          ).proof?.title,
          'Fix landed',
        );
        expect(
          Act0LearningReceiptV1.fromEvidence(
            focusLabel: 'Checking for free',
            sourceTaskId: intent.sourceTaskId,
            repairOutcomes: outcomes.outcomes,
            learningEvidence: history,
            currentFingerprintForIdentity: _fingerprint,
          ).level,
          Act0LearningReceiptLevelV1.sameClueRepaired,
        );
      }
      expect(
        history.records.map((r) => r.recordId),
        containsAll([
          source.recordId,
          attempt.recordId,
          'guided-source-check',
          'guided-source-pay_small_blind',
        ]),
      );
      expect(history.records.first.toPayload(), source.toPayload());
      expect(outcomes.outcomes, hasLength(1));
    },
  );

  for (final diagnostic in [
    (
      id: 'board_private_cards',
      index: 2,
      choice: 'hero_private_cards',
      expected: 'board_cards',
      target: 'cards_ranks_suits_private_board',
    ),
    (
      id: 'action_basics',
      index: 3,
      choice: 'not_sure_yet',
      expected: 'check',
      target: 'actions_check_drill',
    ),
  ]) {
    test(
      '${diagnostic.id}: label-only variant changes invalidate persisted teaching navigation',
      () {
        final source = _task(
          'world_1',
          'what_poker_is',
          'what_poker_is_table_read_transfer',
        );
        final base = _fingerprint(
          worldId: 'world_1',
          lessonId: 'what_poker_is',
          taskId: source.taskId,
        );
        final runner = placementQuickCheckRunnerV1(
          source.runner,
          signalId: diagnostic.id,
          checkIndex: diagnostic.index,
          checkCount: 3,
          isRu: false,
        );
        final selected = runner.options.singleWhere(
          (o) => o.id == diagnostic.choice,
        );
        final changed = runner.copyWith(
          options: [
            for (final o in runner.options)
              if (o.id != selected.id)
                o
              else
                Act0RunnerOptionV1(
                  id: o.id,
                  label: '${o.label} changed',
                  isCorrect: o.isCorrect,
                  preferredLabel: o.preferredLabel,
                  betterAnswerLabel: o.betterAnswerLabel,
                  quality: o.quality,
                  feedbackTitle: o.feedbackTitle,
                  feedbackReason: o.feedbackReason,
                  amountLabel: o.amountLabel,
                  seatId: o.seatId,
                  repairFocusSeatIds: o.repairFocusSeatIds,
                  repairFocusCardIds: o.repairFocusCardIds,
                  repairFocusLabels: o.repairFocusLabels,
                ),
          ],
        );
        String? variant(Act0RunnerStateV1 value) =>
            act0PlacementDiagnosticFingerprintV1(
              worldId: 'world_1',
              lessonId: 'what_poker_is',
              diagnosticVariantId: diagnostic.id,
              sourceTask: source,
              diagnosticRunner: value,
            );
        final before = variant(runner);
        final after = variant(changed);
        expect(
          variant(runner.copyWith(phase: Act0LessonPhaseV1.drill)),
          variant(runner.copyWith(phase: Act0LessonPhaseV1.review)),
          reason:
              'Runtime feedback phase is not a diagnostic content revision.',
        );
        expect(before, isNotNull);
        expect(after, isNot(before));
        expect(
          _fingerprint(
            worldId: 'world_1',
            lessonId: 'what_poker_is',
            taskId: source.taskId,
          ),
          base,
        );
        Act0LessonTaskV1 hashView(Act0RunnerStateV1 value) => Act0LessonTaskV1(
          taskId: source.taskId,
          title: source.title,
          phase: source.phase,
          runner: value,
          rewardXp: source.rewardXp,
          stepKind: source.stepKind,
          taskFamily: source.taskFamily,
          tablePresentation: source.tablePresentation,
          summary: source.summary,
          lockedSummary: source.lockedSummary,
        );
        expect(
          act0AuthoredSourceFingerprintV1(
            worldId: 'world_1',
            lessonId: 'what_poker_is',
            task: hashView(runner),
          ),
          act0AuthoredSourceFingerprintV1(
            worldId: 'world_1',
            lessonId: 'what_poker_is',
            task: hashView(changed),
          ),
          reason: 'Ordinary fingerprint label policy remains unchanged.',
        );
        String? current({
          required String worldId,
          required String lessonId,
          required String taskId,
          required String diagnosticVariantId,
        }) =>
            worldId == 'world_1' &&
                lessonId == 'what_poker_is' &&
                taskId == source.taskId &&
                diagnosticVariantId == diagnostic.id
            ? before
            : null;
        final built = buildAct0RepairIntentV1(
          sourceWorldId: 'world_1',
          sourceLessonId: 'what_poker_is',
          sourceTaskId: source.taskId,
          runner: runner,
          selectedOption: selected,
          sourceTask: source,
          diagnosticVariantId: diagnostic.id,
          currentFingerprintForIdentity: _fingerprint,
          currentDiagnosticVariantFingerprint: current,
        )!;
        final intent = Act0RepairIntentV1.tryParse({
          ...built.toPayload(),
          'repairOccurrenceId': 'actual-${diagnostic.id}',
        })!;
        final event = Act0LearningEvidenceRecordV1.tryParse({
          ..._sourceRecord(intent).toPayload(),
          'runKind': act0PlacementAssessmentRunKindV1,
          'expectedChoiceId': diagnostic.expected,
          'resultKind': intent.result,
          'authoredSourceFingerprint': base,
        })!;
        final history = Act0LearningEvidenceHistoryV1(records: [event]);
        final review = _reviewHistory(event);
        final fresh = act0DiagnosticLearningEntryForIntentV1(
          intent,
          learningEvidence: history,
          reviewMistakeHistory: review,
          currentFingerprintForIdentity: _fingerprint,
          currentDiagnosticVariantFingerprint: current,
        );
        expect(fresh?.targetTaskId, diagnostic.target);
        expect(fresh?.canLaunchTeaching, isTrue);
        expect(fresh?.canClaimRepairClosure, isFalse);
        expect(
          intent.relationRevision,
          diagnostic.id == 'action_basics' ? 3 : 1,
        );
        if (diagnostic.id == 'action_basics') {
          for (final patch in <Map<String, Object?>>[
            {'relationRevision': 1},
            {'relationRevision': 2},
            {
              'targetFingerprint':
                  '45f862c2af3aa0be312896d02a20391e432d349fd42a074228b3a32205905205',
            },
            {
              'relationRevision': 1,
              'targetFingerprint':
                  '45f862c2af3aa0be312896d02a20391e432d349fd42a074228b3a32205905205',
            },
          ]) {
            final bytes = jsonEncode({...intent.toPayload(), ...patch});
            final old = Act0RepairIntentV1.tryParse(jsonDecode(bytes))!;
            expect(jsonEncode(old.toPayload()), bytes);
            expect(
              act0DiagnosticLearningEntryForIntentV1(
                old,
                learningEvidence: history,
                reviewMistakeHistory: review,
                currentFingerprintForIdentity: _fingerprint,
                currentDiagnosticVariantFingerprint: current,
              ),
              isNull,
            );
          }
        }

        expect(
          act0RepairGoalResolutionForIntentV1(
            intent,
            learningEvidence: history,
            currentFingerprintForIdentity: _fingerprint,
          ).canLaunch,
          isFalse,
        );
        expect(
          act0DiagnosticLearningEntryForIntentV1(
            intent,
            learningEvidence: history,
            reviewMistakeHistory: review,
            currentFingerprintForIdentity: _fingerprint,
            currentDiagnosticVariantFingerprint:
                ({
                  required String worldId,
                  required String lessonId,
                  required String taskId,
                  required String diagnosticVariantId,
                }) => after,
          ),
          isNull,
        );
        final legacy = Act0RepairIntentV1.tryParse({
          ...intent.toPayload(),
          'sourceFingerprint': base,
        })!;
        expect(
          act0DiagnosticLearningEntryForIntentV1(
            legacy,
            learningEvidence: history,
            reviewMistakeHistory: review,
            currentFingerprintForIdentity: _fingerprint,
            currentDiagnosticVariantFingerprint: current,
          ),
          isNull,
        );
      },
    );
  }

  for (final source in _bad) {
    test(
      '${source.task}/${source.choice}: familiar repair is available with a current witness',
      () {
        final intent = _intent(source);
        final history = _history(intent);
        final goal = act0RepairGoalResolutionForIntentV1(
          intent,
          learningEvidence: history,
          currentFingerprintForIdentity: _fingerprint,
        );
        expect(goal.isHeld, isFalse);
        expect(goal.canLaunch, isTrue);
        expect(
          act0RepairGoalResolutionForIntentV1(
            intent,
            learningEvidence: const Act0LearningEvidenceHistoryV1(),
            currentFingerprintForIdentity: _fingerprint,
          ).canLaunch,
          isFalse,
        );
        expect(goal.canClaimIndependentApplication, isFalse);
        final expectedGoal = source.world == 'world_2'
            ? 'starting_hand_premium_bucket'
            : source.world == 'world_4'
            ? 'half_pot_fraction'
            : source.task == 'what_poker_is_find_hero'
            ? 'shared_board_vs_private_cards'
            : 'showdown_best_five';
        expect(goal.goalId, expectedGoal);
        final resolution = Act0QueueResolutionStateV1.fromSources(
          activeRepairIntents: [intent],
          learningEvidenceHistory: history,
          currentFingerprintForIdentity: _fingerprint,
        );
        expect(resolution.resolutions.single.isActionable, isTrue);
        final queue = const Act0MultiRepairQueueV1()
            .upsertIntent(intent, order: 1)
            .prunedWithResolution(resolution);
        expect(
          Act0MultiRepairQueueV1.tryParse(
            queue.toPayload(),
          ).activeRepairIntents(),
          hasLength(1),
        );
        final practice = Act0PracticeRepairQueueProjectionV1.fromSources(
          activeRepairIntents: [intent],
          learningEvidenceHistory: history,
          currentFingerprintForIdentity: _fingerprint,
        );
        expect(practice.items, hasLength(1));
        expect(practice.items.single.launchTarget.isLaunchable, isTrue);
        expect(practice.items.single.launchRequest, isNotNull);
      },
    );
  }
  for (final source in _rehearsals) {
    test(
      '${source.task}/${source.choice}: declared familiar practice is not independent application',
      () {
        final intent = _intent(source);
        final history = _history(intent);
        final goal = act0RepairGoalResolutionForIntentV1(
          intent,
          learningEvidence: history,
          currentFingerprintForIdentity: _fingerprint,
        );
        expect(goal.canLaunch, isTrue);
        expect(goal.isHeld, isFalse);
        expect(goal.canClaimIndependentApplication, isFalse);
        if (const {
          'actions_check_drill',
          'actions_legal_context',
        }.contains(source.task)) {
          const oldFp = <String, String>{
            'actions_check_drill':
                '45f862c2af3aa0be312896d02a20391e432d349fd42a074228b3a32205905205',
            'actions_legal_context':
                'd889c669abcb49a96b62c12447888f10e8e262e3a2f663b8d2e700010686cad4',
          };
          expect(intent.relationRevision, 3);
          expect(intent.sourceFingerprint, isNot(oldFp[source.task]));
          expect(intent.targetFingerprint, isNot(oldFp[intent.targetTaskId]));
          for (final patch in <Map<String, Object?>>[
            {'relationRevision': 1},
            {'relationRevision': 2},
            {'sourceFingerprint': oldFp[source.task]},
            {'targetFingerprint': oldFp[intent.targetTaskId]},
            {
              'relationRevision': 1,
              'sourceFingerprint': oldFp[source.task],
              'targetFingerprint': oldFp[intent.targetTaskId],
            },
          ]) {
            final payload = {...intent.toPayload(), ...patch};
            final bytes = jsonEncode(payload);
            final legacy = Act0RepairIntentV1.tryParse(jsonDecode(bytes))!;
            expect(jsonEncode(legacy.toPayload()), bytes);
            expect(
              act0RepairGoalResolutionForIntentV1(
                legacy,
                learningEvidence: history,
                currentFingerprintForIdentity: _fingerprint,
              ).canLaunch,
              isFalse,
            );
          }
          final sourceRecord = _sourceRecord(intent);
          final oldPayload = {
            ...sourceRecord.toPayload(),
            'authoredSourceFingerprint': oldFp[source.task],
          };
          final oldBytes = jsonEncode(oldPayload);
          final oldRecord = Act0LearningEvidenceRecordV1.tryParse(
            jsonDecode(oldBytes),
          )!;
          expect(jsonEncode(oldRecord.toPayload()), oldBytes);
          expect(
            act0RepairGoalResolutionForIntentV1(
              intent,
              learningEvidence: Act0LearningEvidenceHistoryV1(
                records: [oldRecord],
              ),
              currentFingerprintForIdentity: _fingerprint,
            ).canLaunch,
            isFalse,
          );
        }

        expect(
          act0RepairGoalResolutionForIntentV1(
            intent,
            learningEvidence: history,
            currentFingerprintForIdentity:
                ({required worldId, required lessonId, required taskId}) =>
                    'changed-authored-source',
          ).canLaunch,
          isFalse,
        );
        final malformedRevision = Act0RepairIntentV1.tryParse({
          ...intent.toPayload(),
          'relationRevision': -1,
        })!;
        expect(
          act0RepairGoalResolutionForIntentV1(
            malformedRevision,
            learningEvidence: history,
            currentFingerprintForIdentity: _fingerprint,
          ).canLaunch,
          isFalse,
        );
        final erasedWitness = Act0RepairIntentV1.tryParse({
          ...intent.toPayload(),
          'goalId': null,
          'relationId': null,
          'sourceFingerprint': null,
          'targetFingerprint': null,
          'relationRevision': null,
        })!;
        expect(
          act0RepairGoalResolutionForIntentV1(
            erasedWitness,
            learningEvidence: history,
            currentFingerprintForIdentity: _fingerprint,
          ).canLaunch,
          isFalse,
        );
        expect(
          act0RepairGoalResolutionForIntentV1(
            intent,
            learningEvidence: const Act0LearningEvidenceHistoryV1(),
            currentFingerprintForIdentity: _fingerprint,
          ).canLaunch,
          isFalse,
        );
        final pending = Act0QueueResolutionStateV1.fromSources(
          activeRepairIntents: [intent],
          learningEvidenceHistory: history,
          currentFingerprintForIdentity: _fingerprint,
        );
        expect(
          pending.resolutions.single.resolutionState,
          isNot(act0QueueResolutionStateResolvedV1),
        );
      },
    );
  }
  test(
    'missing validation context never closes debt from a raw successful outcome',
    () {
      final intent = _intent(_rehearsals.first);
      final correct = _task(
        intent.targetWorldId,
        intent.targetLessonId,
        intent.targetTaskId,
      ).runner.options.firstWhere((option) => option.isCorrect).id;
      final raw = Act0RepairOutcomeV1(
        sourceTaskId: intent.sourceTaskId,
        repairTaskId: intent.targetTaskId,
        repairFocusKey: intent.missedSignalId,
        queueItemId: queueItemIdForAct0RepairIntentV1(intent),
        repairOccurrenceId: intent.repairOccurrenceId,
        targetWorldId: intent.targetWorldId,
        targetLessonId: intent.targetLessonId,
        targetTaskId: intent.targetTaskId,
        selectedChoiceId: correct,
        correctChoiceId: correct,
        isCorrect: true,
        outcomeState: act0RepairOutcomeStateCorrectV1,
        sequence: 1,
        sourceType: act0PracticeRepairQueueSourceActiveRepairV1,
      );
      final resolution = Act0QueueResolutionStateV1.fromSources(
        activeRepairIntents: [intent],
        repairOutcomeProjection: Act0RepairOutcomeProjectionV1(outcomes: [raw]),
      );
      expect(resolution.resolutions.single.isActionable, isTrue);
      expect(
        resolution.resolutions.single.resolutionState,
        isNot(act0QueueResolutionStateResolvedV1),
      );
      expect(
        Act0RepairOutcomeV1.tryParse(raw.toPayload())!.toPayload(),
        raw.toPayload(),
      );
    },
  );
  for (final source in _rehearsals) {
    test(
      '${source.task}: only the actual independent target attempt can close familiar practice',
      () {
        final intent = _intent(source);
        final target = _task(
          intent.targetWorldId,
          intent.targetLessonId,
          intent.targetTaskId,
        );
        final correct = target.runner.options
            .firstWhere((option) => option.isCorrect)
            .id;
        final record = Act0LearningEvidenceRecordV1(
          recordId: 'target-attempt',
          createdOrder: 2,
          worldId: intent.targetWorldId,
          lessonId: intent.targetLessonId,
          taskId: intent.targetTaskId,
          sourceTaskId: intent.targetTaskId,
          choiceId: correct,
          expectedChoiceId: correct,
          isCorrect: true,
          errorType: 'none',
          conceptFamilyId: intent.missedSignalId,
          repairFocusId: intent.missedSignalId,
          skillAtomId: intent.skillAtomId,
          decisionTimeBucket: '3_to_10s',
          resultKind: 'correct',
          runId: 'repair-run',
          runKind: 'repair',
          runOrdinal: 2,
          sessionId: 'repair-session',
          recordedAtUtc: DateTime.utc(2026, 11, 17, 0, 1),
          reviewKind: act0IsExactRepairMappingTypeV1(intent.mappingType)
              ? Act0ReviewKindV1.exactReplay
              : Act0ReviewKindV1.alternateSameSignal,
          assistanceKind: Act0DecisionAssistanceV1.none,
          authoredSourceFingerprint: _fingerprint(
            worldId: intent.targetWorldId,
            lessonId: intent.targetLessonId,
            taskId: intent.targetTaskId,
          )!,
        );
        final outcome = Act0RepairOutcomeV1(
          repairIntent: intent,
          repairAttemptId: record.recordId,
          sourceTaskId: intent.sourceTaskId,
          repairTaskId: intent.targetTaskId,
          repairFocusKey: intent.missedSignalId,
          queueItemId: queueItemIdForAct0RepairIntentV1(intent),
          repairOccurrenceId: intent.repairOccurrenceId,
          targetWorldId: intent.targetWorldId,
          targetLessonId: intent.targetLessonId,
          targetTaskId: intent.targetTaskId,
          selectedChoiceId: correct,
          correctChoiceId: correct,
          isCorrect: true,
          outcomeState: act0RepairOutcomeStateCorrectV1,
          sequence: 1,
          sourceType: act0PracticeRepairQueueSourceActiveRepairV1,
          sessionId: record.sessionId,
        );
        final history = Act0LearningEvidenceHistoryV1(
          records: [_sourceRecord(intent), record],
        );
        bool eligible(
          Act0RepairOutcomeV1 value,
          Act0LearningEvidenceHistoryV1 evidence,
        ) => act0RepairGoalOutcomeIsEligibleV1(
          intent: intent,
          outcome: value,
          learningEvidence: evidence,
          currentFingerprintForIdentity: _fingerprint,
        );
        expect(eligible(outcome, history), isTrue);
        final anchored = Act0LearningEvidenceHistoryV1(
          records: [record],
          sourceAnchors: [_sourceRecord(intent)],
        );
        expect(eligible(outcome, anchored), isTrue);
        final conflictingSource = Act0LearningEvidenceRecordV1.tryParse({
          ..._sourceRecord(intent).toPayload(),
          'choiceId': 'conflicting-choice',
        })!;
        expect(
          eligible(
            outcome,
            Act0LearningEvidenceHistoryV1(
              records: history.records,
              sourceAnchors: [conflictingSource],
            ),
          ),
          isFalse,
        );
        final nextIntent = Act0RepairIntentV1.tryParse({
          ...intent.toPayload(),
          'repairOccurrenceId': 'newer-source-miss',
        })!;
        final nextSource = Act0LearningEvidenceRecordV1.tryParse({
          ..._sourceRecord(nextIntent).toPayload(),
          'createdOrder': 2,
        })!;
        final laterTarget = Act0LearningEvidenceRecordV1.tryParse({
          ...record.toPayload(),
          'createdOrder': 3,
        })!;
        final relabeled = Act0RepairOutcomeV1.tryParse({
          ...outcome.toPayload(),
          'repairOccurrenceId': nextIntent.repairOccurrenceId,
        })!;
        final conflictingHistory = Act0LearningEvidenceHistoryV1(
          records: [_sourceRecord(intent), nextSource, laterTarget],
        );
        expect(
          act0RepairGoalOutcomeIsEligibleV1(
            intent: nextIntent,
            outcome: relabeled,
            learningEvidence: conflictingHistory,
            currentFingerprintForIdentity: _fingerprint,
          ),
          isFalse,
        );
        expect(
          Act0QueueResolutionStateV1.fromSources(
            activeRepairIntents: [nextIntent],
            repairOutcomeProjection: Act0RepairOutcomeProjectionV1(
              outcomes: [relabeled],
            ),
            learningEvidenceHistory: conflictingHistory,
            currentFingerprintForIdentity: _fingerprint,
          ).resolutions.single.resolutionState,
          isNot(act0QueueResolutionStateResolvedV1),
        );
        expect(
          Act0ReviewResolutionStateV1.fromSources(
            reviewMistakeHistory: _reviewHistory(nextSource),
            activeRepairIntents: [nextIntent],
            repairOutcomeProjection: Act0RepairOutcomeProjectionV1(
              outcomes: [relabeled],
            ),
            learningEvidenceHistory: conflictingHistory,
            currentFingerprintForIdentity: _fingerprint,
          ).resolutions.single.reviewState,
          isNot(act0ReviewResolutionStateResolvedV1),
        );
        expect(
          Act0QueueResolutionStateV1.fromSources(
            activeRepairIntents: [intent],
            repairOutcomeProjection: Act0RepairOutcomeProjectionV1(
              outcomes: [outcome],
            ),
            learningEvidenceHistory: history,
            currentFingerprintForIdentity: _fingerprint,
          ).resolutions.single.resolutionState,
          act0QueueResolutionStateResolvedV1,
        );
        final projection = Act0RepairOutcomeProjectionV1(outcomes: [outcome]);
        final rawReview = _reviewHistory(_sourceRecord(intent));
        final reviewBytes = rawReview.toStorageString();
        // Model ordinary persistence after Preview prunes the resolved intent.
        // Raw history is retained; cached receipt flags cannot close a miss.
        final restoredReview = Act0ReviewMistakeHistoryV1.tryParseStorageString(
          reviewBytes,
        )!;
        final restoredEvidence =
            Act0LearningEvidenceHistoryV1.tryParseStorageString(
              history.toStorageString(),
            )!;
        final restoredProjection = Act0RepairOutcomeProjectionV1.tryParse(
          projection.toPayload(),
        );
        Act0PracticeRepairQueueProjectionV1 practiceAfterPrune({
          Act0LearningEvidenceHistoryV1? evidence,
          Act0RepairOutcomeProjectionV1? outcomes,
          Act0ReviewMistakeHistoryV1? review,
          bool validateSources = true,
        }) => Act0PracticeRepairQueueProjectionV1.fromSources(
          reviewMistakeHistory: review ?? restoredReview,
          repairOutcomeProjection: outcomes ?? restoredProjection,
          learningEvidenceHistory: evidence ?? restoredEvidence,
          currentFingerprintForIdentity: validateSources ? _fingerprint : null,
        );
        expect(practiceAfterPrune().items, isEmpty);
        expect(restoredReview.toStorageString(), reviewBytes);
        final heldReview = _reviewHistory(_sourceRecord(_intent(_bad.first)));
        final mixedReview = Act0ReviewMistakeHistoryV1(
          records: [...restoredReview.records, ...heldReview.records],
        );
        expect(
          practiceAfterPrune(review: mixedReview).items.single.sourceRecordId,
          heldReview.records.single.recordId,
        );
        expect(practiceAfterPrune(validateSources: false).items, hasLength(1));
        expect(
          practiceAfterPrune(
            outcomes: const Act0RepairOutcomeProjectionV1(),
          ).items,
          hasLength(1),
        );
        expect(
          practiceAfterPrune(review: _reviewHistory(nextSource)).items,
          hasLength(1),
          reason: 'A resolved prior occurrence cannot hide a new miss.',
        );
        final staleEvidence = Act0LearningEvidenceHistoryV1(
          records: [
            _sourceRecord(intent),
            Act0LearningEvidenceRecordV1.tryParse({
              ...record.toPayload(),
              'authoredSourceFingerprint': 'stale-source-fingerprint',
            })!,
          ],
        );
        expect(practiceAfterPrune(evidence: staleEvidence).items, hasLength(1));
        final receipts = reviewResolutionReceiptHistoryFromSourcesV1(
          reviewMistakeHistory: _reviewHistory(_sourceRecord(intent)),
          activeRepairIntents: [intent],
          repairOutcomeProjection: projection,
          existingReceiptHistory: const Act0ReviewResolutionReceiptHistoryV1(),
          learningEvidenceHistory: history,
          currentFingerprintForIdentity: _fingerprint,
        );
        expect(receipts.receipts, hasLength(1));
        final banked = Act0FixProofProjectionV1.fromSources(
          repairOutcomeProjection: projection,
          reviewResolutionReceiptHistory: receipts,
          learningEvidenceHistory: history,
          currentFingerprintForIdentity: _fingerprint,
        );
        expect(banked.proofs, hasLength(1));
        expect(banked.proofs.single.isReinforced, isFalse);
        final currentConsumer = Act0RepairOutcomeConsumerV1.fromProjection(
          projection,
          fixProofProjection: banked,
          learningEvidenceHistory: history,
          currentFingerprintForIdentity: _fingerprint,
        );
        expect(currentConsumer.proof?.title, 'Fix landed');
        expect(currentConsumer.sessionReceipt?.isBankedFixProof, isTrue);
        final currentReceipt = Act0LearningReceiptV1.fromEvidence(
          focusLabel: 'Same learning goal',
          sourceTaskId: intent.sourceTaskId,
          repairOutcomes: projection.outcomes,
          learningEvidence: history,
          currentFingerprintForIdentity: _fingerprint,
          isExactReplay: act0IsExactRepairMappingTypeV1(intent.mappingType),
        );
        expect(
          currentReceipt.level,
          Act0LearningReceiptLevelV1.sameClueRepaired,
        );
        expect(
          currentReceipt.nextEvidenceRequirement,
          contains('new hand without help'),
        );
        expect(
          banked.proofs.single.copyLine,
          contains('new hand without help'),
        );
        final legacyPayload = Map<String, Object?>.of(outcome.toPayload())
          ..remove('repairIntent');
        final legacy = Act0RepairOutcomeV1.tryParse(legacyPayload)!;
        expect(legacy.toPayload(), legacyPayload);
        expect(eligible(legacy, history), isTrue);
        final wrongReceipt = Act0ReviewResolutionReceiptHistoryV1.tryParse([
          {
            ...receipts.receipts.single.toPayload(),
            'learningEvidenceId': 'another-miss',
          },
        ]);
        expect(
          Act0FixProofProjectionV1.fromSources(
            repairOutcomeProjection: projection,
            reviewResolutionReceiptHistory: wrongReceipt,
            learningEvidenceHistory: history,
            currentFingerprintForIdentity: _fingerprint,
          ).proofs,
          isEmpty,
        );
        final laterAssistedTarget = Act0LearningEvidenceRecordV1.tryParse({
          ...record.toPayload(),
          'recordId': 'later-target',
          'createdOrder': 3,
          'runId': 'later-repair-run',
          'runOrdinal': 3,
          'assistanceKind': 'quickHint',
        })!;
        final laterHistory = Act0LearningEvidenceHistoryV1(
          records: [...history.records, laterAssistedTarget],
        );
        expect(
          practiceAfterPrune(evidence: laterHistory).items,
          isEmpty,
          reason: 'Extra assisted practice does not reopen the resolved miss.',
        );
        expect(
          Act0RepairOutcomeConsumerV1.fromProjection(
            projection,
            learningEvidenceHistory: laterHistory,
            currentFingerprintForIdentity: _fingerprint,
          ).proof,
          isNull,
        );
        expect(
          Act0LearningReceiptV1.fromEvidence(
            focusLabel: 'Same learning goal',
            sourceTaskId: intent.sourceTaskId,
            repairOutcomes: projection.outcomes,
            learningEvidence: laterHistory,
            currentFingerprintForIdentity: _fingerprint,
          ).level,
          Act0LearningReceiptLevelV1.attempted,
        );
        if (intent.sourceTaskId != intent.targetTaskId) {
          final unrelatedPractice = Act0LearningEvidenceRecordV1.tryParse({
            ...laterAssistedTarget.toPayload(),
            'runKind': 'practice',
          })!;
          expect(
            Act0RepairOutcomeConsumerV1.fromProjection(
              projection,
              learningEvidenceHistory: Act0LearningEvidenceHistoryV1(
                records: [...history.records, unrelatedPractice],
              ),
              currentFingerprintForIdentity: _fingerprint,
            ).proof,
            isNotNull,
          );
        }
        for (final corruptSnapshot in <Object?>[
          null,
          {'broken': true},
          {...intent.toPayload(), 'relationRevision': null},
        ]) {
          final rawLatest = <String, Object?>{
            ...outcome.toPayload(),
            'repairIntent': corruptSnapshot,
            'repairAttemptId': laterAssistedTarget.recordId,
            'sequence': 2,
          };
          final restored = Act0RepairOutcomeProjectionV1.tryParse([
            outcome.toPayload(),
            rawLatest,
          ]);
          expect(restored.outcomes, hasLength(2));
          expect(restored.toPayload().last, rawLatest);
          expect(restored.outcomes.last.repairIntentIsUnconfirmed, isTrue);
          expect(
            practiceAfterPrune(
              evidence: laterHistory,
              outcomes: restored,
            ).items,
            isEmpty,
            reason: 'Keep the genuine earlier resolution historical.',
          );
          expect(
            Act0RepairOutcomeConsumerV1.fromProjection(
              restored,
              learningEvidenceHistory: laterHistory,
              currentFingerprintForIdentity: _fingerprint,
            ).proof,
            isNull,
          );
          expect(
            Act0LearningReceiptV1.fromEvidence(
              focusLabel: 'Same learning goal',
              sourceTaskId: intent.sourceTaskId,
              repairOutcomes: restored.outcomes,
              learningEvidence: laterHistory,
              currentFingerprintForIdentity: _fingerprint,
            ).level,
            Act0LearningReceiptLevelV1.attempted,
          );
          expect(
            Act0FixProofProjectionV1.fromSources(
              repairOutcomeProjection: restored,
              reviewResolutionReceiptHistory: receipts,
              learningEvidenceHistory: laterHistory,
              currentFingerprintForIdentity: _fingerprint,
            ).proofs,
            hasLength(1),
            reason: 'The genuine earlier banked item remains historical.',
          );
        }
        final assisted = Act0LearningEvidenceRecordV1.tryParse({
          ...record.toPayload(),
          'assistanceKind': 'quickHint',
        })!;
        expect(
          practiceAfterPrune(
            evidence: Act0LearningEvidenceHistoryV1(
              records: [_sourceRecord(intent), assisted],
            ),
          ).items,
          hasLength(1),
        );
        expect(
          eligible(
            outcome,
            Act0LearningEvidenceHistoryV1(
              records: [_sourceRecord(intent), assisted],
            ),
          ),
          isFalse,
        );
        final staleOccurrence = Act0RepairOutcomeV1.tryParse({
          ...outcome.toPayload(),
          'repairOccurrenceId': 'other-source-miss',
        })!;
        expect(eligible(staleOccurrence, history), isFalse);
        expect(
          practiceAfterPrune(
            outcomes: Act0RepairOutcomeProjectionV1(
              outcomes: [staleOccurrence],
            ),
          ).items,
          hasLength(1),
        );
        final otherTarget = Act0RepairOutcomeV1.tryParse({
          ...outcome.toPayload(),
          'targetWorldId': 'world_9',
        })!;
        expect(eligible(otherTarget, history), isFalse);
        final missingEvent = Act0LearningEvidenceHistoryV1(
          records: [_sourceRecord(intent)],
        );
        expect(eligible(outcome, missingEvent), isFalse);
        expect(practiceAfterPrune(evidence: missingEvent).items, hasLength(1));
        final wrongChoice = target.runner.options
            .firstWhere((option) => !option.isCorrect)
            .id;
        final forged = Act0RepairOutcomeV1.tryParse({
          ...outcome.toPayload(),
          'selectedChoiceId': wrongChoice,
        })!;
        expect(eligible(forged, history), isFalse);
        expect(
          Act0RepairOutcomeV1.tryParse(outcome.toPayload())!.toPayload(),
          outcome.toPayload(),
        );
      },
    );
  }
}

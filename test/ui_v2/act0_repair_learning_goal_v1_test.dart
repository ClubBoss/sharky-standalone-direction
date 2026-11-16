// SIMULATED contract controls on current authored tasks; no native/Human proof.
import 'package:flutter_test/flutter_test.dart';
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
    choice: "top",
  ),
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
    choice: "fold",
  ),
  (
    world: "world_1",
    lesson: "fold_check_call_raise",
    task: "actions_check_drill",
    choice: "call",
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
      decisionKind: 'choice',
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

void main() {
  for (final source in _bad) {
    test(
      '${source.task}/${source.choice}: unrelated scene route holds the real miss',
      () {
        final intent = _intent(source);
        final history = _history(intent);
        final goal = act0RepairGoalResolutionForIntentV1(
          intent,
          learningEvidence: history,
          currentFingerprintForIdentity: _fingerprint,
        );
        expect(goal.isHeld, isTrue);
        expect(goal.canLaunch, isFalse);
        expect(goal.canClaimIndependentApplication, isFalse);
        final expectedGoal = source.world == 'world_2'
            ? 'starting_hand_premium_bucket'
            : source.world == 'world_4'
            ? 'half_pot_fraction'
            : source.task == 'what_poker_is_find_hero'
            ? 'player_identity_and_seat_role'
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
        expect(practice.items.single.launchTarget.isLaunchable, isFalse);
        expect(practice.items.single.launchRequest, isNull);
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
          contains('separate application check'),
        );
        expect(
          banked.proofs.single.copyLine,
          contains('separate application check'),
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
        final otherTarget = Act0RepairOutcomeV1.tryParse({
          ...outcome.toPayload(),
          'targetWorldId': 'world_9',
        })!;
        expect(eligible(otherTarget, history), isFalse);
        final missingEvent = Act0LearningEvidenceHistoryV1(
          records: [_sourceRecord(intent)],
        );
        expect(eligible(outcome, missingEvent), isFalse);
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

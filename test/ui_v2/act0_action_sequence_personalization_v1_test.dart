import 'package:flutter_test/flutter_test.dart';
import '../support/act0_authored_repair_goal_fixture_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_outcome_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_queue_resolution_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_action_session_payoff_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_action_learning_sequence_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_action_sequence_personalization_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';

void main() {
  Act0CompletedDecisionV1 decision({
    required String id,
    required bool correct,
    String bucket = '3_to_10s',
    Act0DecisionAssistanceV1 assistance = Act0DecisionAssistanceV1.none,
  }) => Act0CompletedDecisionV1(
    attemptKey: id,
    worldId: 'world_1',
    lessonId: 'fold_check_call_raise',
    taskId: 'actions_check_drill',
    sourceTaskId: 'actions_check_drill',
    decisionKind: Act0CompletedDecisionKindV1.actionList,
    selectedId: correct ? 'check' : 'call',
    expectedId: 'check',
    isCorrect: correct,
    decisionTimeBucket: bucket,
    taskFamily: null,
    resultKind: correct ? 'correct' : 'incorrect',
    assistanceKind: assistance,
  );

  Act0ActionSequenceLearnerStateV1 append(
    Act0ActionSequenceLearnerStateV1 state,
    String id,
    bool correct,
    Act0ActionSequenceStageV1 stage, {
    String bucket = '3_to_10s',
    Act0DecisionAssistanceV1 assistance = Act0DecisionAssistanceV1.none,
  }) => Act0ActionSequencePersonalizationPolicyV1.deriveState(
    current: state,
    decision: decision(
      id: id,
      correct: correct,
      bucket: bucket,
      assistance: assistance,
    ),
    stage: stage,
  );

  test('correct initial Action read continues canonical progression', () {
    final state = append(
      Act0ActionSequencePersonalizationPolicyV1.initialState(),
      'one',
      true,
      Act0ActionSequenceStageV1.decision,
    );
    final recommendation = Act0ActionSequencePersonalizationPolicyV1.evaluate(
      state,
    );
    expect(
      recommendation.reason,
      Act0ActionRecommendationReasonV1.normalProgression,
    );
    expect(recommendation.blocksNormalProgression, isFalse);
  });

  test('wrong then incomplete repair recommends immediate repair', () {
    var state = Act0ActionSequencePersonalizationPolicyV1.initialState();
    state = append(state, 'one', false, Act0ActionSequenceStageV1.decision);
    state = append(state, 'two', false, Act0ActionSequenceStageV1.repair);
    final recommendation = Act0ActionSequencePersonalizationPolicyV1.evaluate(
      state,
    );
    expect(
      recommendation.reason,
      Act0ActionRecommendationReasonV1.repairIncomplete,
    );
    expect(recommendation.target, Act0ActionRecommendationTargetV1.repair);
  });

  test('successful repair and recheck reports recovered skill', () {
    var state = Act0ActionSequencePersonalizationPolicyV1.initialState();
    state = append(state, 'one', false, Act0ActionSequenceStageV1.decision);
    state = append(state, 'two', true, Act0ActionSequenceStageV1.repair);
    state = append(state, 'three', true, Act0ActionSequenceStageV1.recheck);
    final recommendation = Act0ActionSequencePersonalizationPolicyV1.evaluate(
      state,
    );
    expect(
      recommendation.reason,
      Act0ActionRecommendationReasonV1.recoveredAfterRecheck,
    );
    expect(recommendation.blocksNormalProgression, isFalse);
  });

  test('repeated missed action read takes precedence over other rules', () {
    var state = Act0ActionSequencePersonalizationPolicyV1.initialState();
    state = append(state, 'one', false, Act0ActionSequenceStageV1.decision);
    state = append(state, 'two', true, Act0ActionSequenceStageV1.repair);
    state = append(state, 'three', false, Act0ActionSequenceStageV1.recheck);
    final recommendation = Act0ActionSequencePersonalizationPolicyV1.evaluate(
      state,
    );
    expect(
      recommendation.reason,
      Act0ActionRecommendationReasonV1.repeatedError,
    );
  });

  test('slow correct is not classified as conceptual failure', () {
    final state = append(
      Act0ActionSequencePersonalizationPolicyV1.initialState(),
      'one',
      true,
      Act0ActionSequenceStageV1.decision,
      bucket: 'over_10s',
    );
    final recommendation = Act0ActionSequencePersonalizationPolicyV1.evaluate(
      state,
    );
    expect(
      recommendation.reason,
      Act0ActionRecommendationReasonV1.normalProgression,
    );
    expect(
      recommendation.sourceEvidenceSummary,
      contains('conceptual_failure=false'),
    );
  });

  test('unmapped task is a deterministic no-op safe fallback', () {
    final initial = Act0ActionSequencePersonalizationPolicyV1.initialState();
    final unmapped = Act0CompletedDecisionV1(
      attemptKey: 'unmapped',
      worldId: 'world_1',
      lessonId: 'fold_check_call_raise',
      taskId: 'actions_fold_drill',
      sourceTaskId: 'actions_fold_drill',
      decisionKind: Act0CompletedDecisionKindV1.actionList,
      selectedId: 'call',
      expectedId: 'fold',
      isCorrect: false,
      decisionTimeBucket: 'under_3s',
      taskFamily: null,
      resultKind: 'incorrect',
    );

    final derived = Act0ActionSequencePersonalizationPolicyV1.deriveState(
      current: initial,
      decision: unmapped,
      stage: Act0ActionSequenceStageV1.decision,
    );

    expect(derived, same(initial));
    expect(
      Act0ActionSequencePersonalizationPolicyV1.evaluate(derived).reason,
      Act0ActionRecommendationReasonV1.normalProgression,
    );
  });
  // SIMULATED finite policy controls; canonical mapped-attempt and AppRoot
  // integration remain separate owners. No native/application/elapsed proof.
  test('later successful current repair clears earlier repair failure', () {
    var state = Act0ActionSequencePersonalizationPolicyV1.initialState();
    state = append(
      state,
      'source_A',
      false,
      Act0ActionSequenceStageV1.decision,
    );
    state = append(
      state,
      'repair_bad',
      false,
      Act0ActionSequenceStageV1.repair,
    );
    state = append(
      state,
      'repair_good',
      true,
      Act0ActionSequenceStageV1.repair,
    );
    expect(state.hasRepairFailure, isFalse);
    expect(state.repairSucceeded, isTrue);
    expect(state.recheckSucceeded, isFalse);
    state = append(
      state,
      'recheck_good',
      true,
      Act0ActionSequenceStageV1.recheck,
    );
    expect(state.outcomes.map((outcome) => outcome.attemptKey), [
      'source_A',
      'repair_bad',
      'repair_good',
      'recheck_good',
    ]);
    expect(state.missedActionReadCount, 2);
    final recommendation = Act0ActionSequencePersonalizationPolicyV1.evaluate(
      state,
    );
    expect(
      recommendation.reason,
      Act0ActionRecommendationReasonV1.recoveredAfterRecheck,
    );
    expect(recommendation.blocksNormalProgression, isFalse);
    expect(
      Act0ActionSessionPayoffPolicyV1.evaluate(
        learnerState: state,
        recommendation: recommendation,
      ).type,
      Act0ActionPayoffTypeV1.recoveredSuccess,
    );
  });

  for (final assistance in Act0DecisionAssistanceV1.values) {
    if (assistance == Act0DecisionAssistanceV1.none) continue;
    test(
      'new $assistance source recheck keeps raw correct and caps old recovery',
      () {
        var state = Act0ActionSequencePersonalizationPolicyV1.initialState();
        state = append(
          state,
          'source_A',
          false,
          Act0ActionSequenceStageV1.decision,
        );
        state = append(
          state,
          'repair_A',
          true,
          Act0ActionSequenceStageV1.repair,
        );
        state = append(
          state,
          'recheck_A',
          true,
          Act0ActionSequenceStageV1.recheck,
        );
        expect(state.recheckSucceeded, isTrue);
        state = append(
          state,
          'assisted_B',
          true,
          Act0ActionSequenceStageV1.recheck,
          assistance: assistance,
        );
        expect(state.outcomes.last.isCorrect, isTrue);
        expect(state.outcomes.last.assistanceKind, assistance);
        expect(state.currentInitialOutcome!.attemptKey, 'assisted_B');
        expect(state.repairSucceeded, isFalse);
        expect(state.recheckSucceeded, isFalse);
        expect(state.outcomes, hasLength(4));
        final recommendation =
            Act0ActionSequencePersonalizationPolicyV1.evaluate(state);
        expect(recommendation.blocksNormalProgression, isTrue);
        expect(
          Act0ActionSessionPayoffPolicyV1.evaluate(
            learnerState: state,
            recommendation: recommendation,
          ).type,
          Act0ActionPayoffTypeV1.unresolvedSkill,
        );
      },
    );
  }

  test(
    'new wrong recheck cannot borrow prior repair and requires its own chain',
    () {
      var state = Act0ActionSequencePersonalizationPolicyV1.initialState();
      state = append(
        state,
        'source_A',
        false,
        Act0ActionSequenceStageV1.decision,
      );
      state = append(state, 'repair_A', true, Act0ActionSequenceStageV1.repair);
      state = append(
        state,
        'recheck_A',
        true,
        Act0ActionSequenceStageV1.recheck,
      );
      state = append(
        state,
        'wrong_B',
        false,
        Act0ActionSequenceStageV1.recheck,
      );
      expect(state.currentInitialOutcome!.attemptKey, 'wrong_B');
      expect(state.hasRepairFailure, isFalse);
      expect(state.repairSucceeded, isFalse);
      expect(state.recheckSucceeded, isFalse);
      expect(state.missedActionReadCount, 2);
      expect(
        Act0ActionSequencePersonalizationPolicyV1.evaluate(state).reason,
        Act0ActionRecommendationReasonV1.repeatedError,
      );
      state = append(state, 'repair_B', true, Act0ActionSequenceStageV1.repair);
      expect(state.recheckSucceeded, isFalse);
      state = append(
        state,
        'recheck_B',
        true,
        Act0ActionSequenceStageV1.recheck,
      );
      expect(state.recheckSucceeded, isTrue);
      expect(state.outcomes, hasLength(6));
      expect(
        Act0ActionSequencePersonalizationPolicyV1.evaluate(state).reason,
        Act0ActionRecommendationReasonV1.recoveredAfterRecheck,
      );
    },
  );

  test('new source decision cannot inherit an older recovered payoff', () {
    var state = Act0ActionSequencePersonalizationPolicyV1.initialState();
    state = append(
      state,
      'source_A',
      false,
      Act0ActionSequenceStageV1.decision,
    );
    state = append(state, 'repair_A', true, Act0ActionSequenceStageV1.repair);
    state = append(state, 'recheck_A', true, Act0ActionSequenceStageV1.recheck);
    state = append(
      state,
      'source_B',
      false,
      Act0ActionSequenceStageV1.decision,
    );
    expect(state.currentInitialOutcome!.attemptKey, 'source_B');
    expect(state.repairSucceeded, isFalse);
    expect(state.recheckSucceeded, isFalse);
    final recommendation = Act0ActionSequencePersonalizationPolicyV1.evaluate(
      state,
    );
    expect(recommendation.blocksNormalProgression, isTrue);
    expect(
      Act0ActionSessionPayoffPolicyV1.evaluate(
        learnerState: state,
        recommendation: recommendation,
      ).type,
      Act0ActionPayoffTypeV1.unresolvedSkill,
    );
    expect(state.missedActionReadCount, 2);
    expect(Act0ActionSequencePersonalizationPolicyV1.repeatedMissThreshold, 2);
  });

  test('duplicate source callback does not invent a repeated miss', () {
    var state = Act0ActionSequencePersonalizationPolicyV1.initialState();
    state = append(
      state,
      'source_A',
      false,
      Act0ActionSequenceStageV1.decision,
    );
    final duplicate = append(
      state,
      'source_A',
      false,
      Act0ActionSequenceStageV1.decision,
    );
    expect(duplicate, same(state));
    expect(duplicate.missedActionReadCount, 1);
  });

  test(
    'new correct source cycle keeps historical misses without borrowed recovery',
    () {
      var state = Act0ActionSequencePersonalizationPolicyV1.initialState();
      state = append(
        state,
        'source_A',
        false,
        Act0ActionSequenceStageV1.decision,
      );
      state = append(
        state,
        'repair_bad_A',
        false,
        Act0ActionSequenceStageV1.repair,
      );
      state = append(
        state,
        'repair_good_A',
        true,
        Act0ActionSequenceStageV1.repair,
      );
      state = append(
        state,
        'recheck_A',
        true,
        Act0ActionSequenceStageV1.recheck,
      );
      state = append(
        state,
        'source_B',
        true,
        Act0ActionSequenceStageV1.decision,
      );
      expect(state.missedActionReadCount, 2);
      expect(
        Act0ActionSequencePersonalizationPolicyV1.repeatedMissThreshold,
        2,
      );
      expect(state.currentInitialOutcome!.attemptKey, 'source_B');
      expect(state.repairSucceeded, isFalse);
      expect(state.recheckSucceeded, isFalse);
      final recommendation = Act0ActionSequencePersonalizationPolicyV1.evaluate(
        state,
      );
      expect(
        recommendation.reason,
        Act0ActionRecommendationReasonV1.normalProgression,
      );
      expect(
        Act0ActionSessionPayoffPolicyV1.evaluate(
          learnerState: state,
          recommendation: recommendation,
        ).type,
        Act0ActionPayoffTypeV1.cleanSuccess,
      );
    },
  );

  test(
    'mapped bridge joins current canonical Legal attempt and caps unproven latest activity',
    () {
      final task = act0AuthoredRepairFixtureTaskV1(
        'world_1',
        'fold_check_call_raise',
        'actions_check_drill',
      );
      final built = buildAct0RepairIntentV1(
        sourceWorldId: 'world_1',
        sourceLessonId: 'fold_check_call_raise',
        sourceTaskId: task.taskId,
        runner: task.runner,
        selectedOption: task.runner.options.singleWhere(
          (option) => option.id == 'pay_small_blind',
        ),
        currentFingerprintForIdentity: act0AuthoredRepairFixtureFingerprintV1,
      )!;
      final intent = Act0RepairIntentV1.tryParse({
        ...built.toPayload(),
        'repairOccurrenceId': 'source_A',
      })!;
      final outcome = Act0RepairOutcomeV1(
        repairIntent: intent,
        repairOccurrenceId: intent.repairOccurrenceId,
        repairAttemptId: 'legal_correct_A',
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
        sequence: 3,
        sourceType: 'active_repair_v1',
        sessionId: 'repair-session',
      );
      final history = act0AuthoredRepairFixtureHistoryV1(
        intents: [intent],
        outcomes: [outcome],
      );
      final source = history.records.first;
      final target = history.records.last;
      Act0CompletedDecisionV1 fromRecord(Act0LearningEvidenceRecordV1 record) =>
          Act0CompletedDecisionV1(
            attemptKey: record.recordId,
            worldId: record.worldId,
            lessonId: record.lessonId,
            taskId: record.taskId,
            sourceTaskId: record.sourceTaskId,
            decisionKind: Act0CompletedDecisionKindV1.actionList,
            selectedId: record.choiceId,
            expectedId: record.expectedChoiceId,
            isCorrect: record.isCorrect,
            decisionTimeBucket: record.decisionTimeBucket,
            taskFamily: act0AuthoredRepairFixtureTaskV1(
              record.worldId,
              record.lessonId,
              record.taskId,
            ).resolvedTaskFamily,
            resultKind: record.resultKind,
            assistanceKind: record.assistanceKind,
          );
      var state = Act0ActionSequencePersonalizationPolicyV1.deriveState(
        current: Act0ActionSequencePersonalizationPolicyV1.initialState(),
        decision: fromRecord(source),
        stage: Act0ActionSequenceStageV1.decision,
      );
      final mapped =
          Act0ActionSequencePersonalizationPolicyV1.deriveMappedRepairState(
            current: state,
            decision: fromRecord(target),
            intent: intent,
            outcome: outcome,
            learningEvidence: history,
            currentFingerprintForIdentity:
                act0AuthoredRepairFixtureFingerprintV1,
          );
      expect(mapped.outcomes.last.attemptKey, target.recordId);
      expect(mapped.outcomes.last.sourceAttemptKey, source.recordId);
      expect(target.taskId, 'actions_legal_context');
      expect(mapped.repairSucceeded, isTrue);
      expect(mapped.recheckSucceeded, isFalse);
      expect(
        Act0ActionSequencePersonalizationPolicyV1.deriveMappedRepairState(
          current: mapped,
          decision: fromRecord(target),
          intent: intent,
          outcome: outcome,
          learningEvidence: history,
          currentFingerprintForIdentity: act0AuthoredRepairFixtureFingerprintV1,
        ),
        same(mapped),
      );

      // New canonical target teaching retains correct=true but cannot inherit
      // the earlier qualified repair. Assisted producer creates no repair outcome.
      final assisted = Act0LearningEvidenceRecordV1.tryParse({
        ...target.toPayload(),
        'recordId': 'legal_assisted_A',
        'createdOrder': target.createdOrder + 1,
        'assistanceKind': 'quickHint',
      })!;
      final withAssisted = Act0LearningEvidenceHistoryV1(
        records: [...history.records, assisted],
      );
      final capped =
          Act0ActionSequencePersonalizationPolicyV1.deriveMappedRepairState(
            current: mapped,
            decision: fromRecord(assisted),
            intent: intent,
            outcome: null,
            learningEvidence: withAssisted,
            currentFingerprintForIdentity:
                act0AuthoredRepairFixtureFingerprintV1,
          );
      expect(capped.outcomes.last.isCorrect, isTrue);
      expect(
        capped.outcomes.last.assistanceKind,
        Act0DecisionAssistanceV1.quickHint,
      );
      expect(capped.outcomes.last.qualifiesForProof, isFalse);
      expect(capped.repairSucceeded, isFalse);
      expect(capped.hasRepairFailure, isTrue);
      expect(capped.outcomes, hasLength(3));
      expect(capped.missedActionReadCount, 1);

      final unconfirmed = Act0LearningEvidenceRecordV1.tryParse({
        ...target.toPayload(),
        'recordId': 'legal_unconfirmed_A',
        'createdOrder': target.createdOrder + 1,
      })!;
      final withUnconfirmed = Act0LearningEvidenceHistoryV1(
        records: [...history.records, unconfirmed],
      );
      final missingOutcome =
          Act0ActionSequencePersonalizationPolicyV1.deriveMappedRepairState(
            current: mapped,
            decision: fromRecord(unconfirmed),
            intent: intent,
            outcome: null,
            learningEvidence: withUnconfirmed,
            currentFingerprintForIdentity:
                act0AuthoredRepairFixtureFingerprintV1,
          );
      expect(missingOutcome.outcomes.last.isCorrect, isTrue);
      expect(missingOutcome.outcomes.last.qualifiesForProof, isFalse);
      expect(missingOutcome.repairSucceeded, isFalse);
      expect(missingOutcome.hasRepairFailure, isTrue);

      // A newer real Check source boundary cannot bind an older occurrence A.
      final intentB = Act0RepairIntentV1.tryParse({
        ...intent.toPayload(),
        'repairOccurrenceId': 'source_B',
      })!;
      final sourceB = act0AuthoredRepairFixtureSourceV1(intentB, order: 2);
      state = Act0ActionSequencePersonalizationPolicyV1.deriveState(
        current: mapped,
        decision: fromRecord(sourceB),
        stage: Act0ActionSequenceStageV1.decision,
      );
      final freshOldA = Act0RepairOutcomeV1.tryParse({
        ...outcome.toPayload(),
        'repairAttemptId': 'fresh_target_for_old_A',
        'sequence': 4,
      })!;
      final freshTarget = act0AuthoredRepairFixtureAttemptV1(
        freshOldA,
        order: target.createdOrder + 2,
      );
      final withB = Act0LearningEvidenceHistoryV1(
        records: [source, sourceB, target, freshTarget],
      );
      // Historical eligibility stays true: only the current policy-source join rejects A.
      expect(
        act0RepairGoalOutcomeIsEligibleV1(
          intent: intent,
          outcome: freshOldA,
          learningEvidence: withB,
          currentFingerprintForIdentity: act0AuthoredRepairFixtureFingerprintV1,
        ),
        isTrue,
      );
      expect(
        Act0ActionSequencePersonalizationPolicyV1.deriveMappedRepairState(
          current: state,
          decision: fromRecord(freshTarget),
          intent: intent,
          outcome: freshOldA,
          learningEvidence: withB,
          currentFingerprintForIdentity: act0AuthoredRepairFixtureFingerprintV1,
        ),
        same(state),
      );
      expect(state.repairSucceeded, isFalse);
      expect(state.recheckSucceeded, isFalse);
      expect(state.outcomes.first.attemptKey, 'source_A');
      expect(state.latestSourceOutcome!.attemptKey, 'source_B');
      expect(state.missedActionReadCount, 2);
    },
  );
}

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_action_learning_sequence_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_action_sequence_personalization_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';

void main() {
  Act0CompletedDecisionV1 decision({
    required String id,
    required bool correct,
    String bucket = '3_to_10s',
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
  );

  Act0ActionSequenceLearnerStateV1 append(
    Act0ActionSequenceLearnerStateV1 state,
    String id,
    bool correct,
    Act0ActionSequenceStageV1 stage, {
    String bucket = '3_to_10s',
  }) => Act0ActionSequencePersonalizationPolicyV1.deriveState(
    current: state,
    decision: decision(id: id, correct: correct, bucket: bucket),
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
}

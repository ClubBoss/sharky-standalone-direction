import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_action_learning_sequence_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_action_sequence_personalization_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_action_session_payoff_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';

void main() {
  Act0CompletedDecisionV1 decision(String id, bool correct, String bucket) =>
      Act0CompletedDecisionV1(
        attemptKey: id,
        worldId: 'world_1',
        lessonId: 'fold_check_call_raise',
        taskId: 'actions_check_drill',
        sourceTaskId: 'actions_check_drill',
        decisionKind: Act0CompletedDecisionKindV1.actionList,
        selectedId: correct ? 'check' : 'fold',
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
    decision: decision(id, correct, bucket),
    stage: stage,
  );

  Act0ActionSessionPayoffV1 payoff(Act0ActionSequenceLearnerStateV1 state) =>
      Act0ActionSessionPayoffPolicyV1.evaluate(
        learnerState: state,
        recommendation: Act0ActionSequencePersonalizationPolicyV1.evaluate(
          state,
        ),
      );

  test(
    'clean success acknowledges the correct read without improvement claim',
    () {
      final result = payoff(
        append(
          Act0ActionSequencePersonalizationPolicyV1.initialState(),
          'clean',
          true,
          Act0ActionSequenceStageV1.decision,
        ),
      );
      expect(result.type, Act0ActionPayoffTypeV1.cleanSuccess);
      expect(result.primaryActionLabel, 'Continue');
      expect(result.proofStatement, 'You read the action correctly.');
    },
  );

  test('recovered success proves miss, repair, and recheck', () {
    var state = Act0ActionSequencePersonalizationPolicyV1.initialState();
    state = append(state, 'miss', false, Act0ActionSequenceStageV1.decision);
    state = append(state, 'repair', true, Act0ActionSequenceStageV1.repair);
    state = append(state, 'recheck', true, Act0ActionSequenceStageV1.recheck);
    final result = payoff(state);
    expect(result.type, Act0ActionPayoffTypeV1.recoveredSuccess);
    expect(result.repairSucceeded, isTrue);
    expect(result.recheckSucceeded, isTrue);
  });

  test('unresolved and repeated errors keep repair primary', () {
    var state = Act0ActionSequencePersonalizationPolicyV1.initialState();
    state = append(state, 'miss', false, Act0ActionSequenceStageV1.decision);
    state = append(state, 'repair', false, Act0ActionSequenceStageV1.repair);
    final result = payoff(state);
    expect(result.type, Act0ActionPayoffTypeV1.unresolvedSkill);
    expect(result.primaryActionLabel, 'Repair now');
    expect(result.blocksNormalProgression, isTrue);
  });

  test('slow correct remains clean success, not a conceptual failure', () {
    final result = payoff(
      append(
        Act0ActionSequencePersonalizationPolicyV1.initialState(),
        'slow',
        true,
        Act0ActionSequenceStageV1.decision,
        bucket: 'over_10s',
      ),
    );
    expect(result.type, Act0ActionPayoffTypeV1.cleanSuccess);
    expect(result.meaningStatement, contains('took time'));
  });
}

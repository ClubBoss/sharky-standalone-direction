import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_action_sequence_personalization_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_action_session_payoff_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_sharky_presentation_state_v1.dart';

void main() {
  const clean = Act0ActionSessionPayoffV1(
    sequenceId: 'w1_action_words_check_v1',
    conceptId: 'action_words_no_bet_read',
    type: Act0ActionPayoffTypeV1.cleanSuccess,
    initialOutcome: 'correct',
    errorType: 'none',
    repairEntered: false,
    repairSucceeded: false,
    recheckSucceeded: false,
    recommendationReason: Act0ActionRecommendationReasonV1.normalProgression,
    proofStatement: 'proof',
    meaningStatement: 'meaning',
    primaryActionLabel: 'Continue',
    blocksNormalProgression: false,
  );
  const recovered = Act0ActionSessionPayoffV1(
    sequenceId: 'w1_action_words_check_v1',
    conceptId: 'action_words_no_bet_read',
    type: Act0ActionPayoffTypeV1.recoveredSuccess,
    initialOutcome: 'incorrect',
    errorType: 'missed_action_read',
    repairEntered: true,
    repairSucceeded: true,
    recheckSucceeded: true,
    recommendationReason:
        Act0ActionRecommendationReasonV1.recoveredAfterRecheck,
    proofStatement: 'proof',
    meaningStatement: 'meaning',
    primaryActionLabel: 'Continue',
    blocksNormalProgression: false,
  );
  const unresolved = Act0ActionSessionPayoffV1(
    sequenceId: 'w1_action_words_check_v1',
    conceptId: 'action_words_no_bet_read',
    type: Act0ActionPayoffTypeV1.unresolvedSkill,
    initialOutcome: 'incorrect',
    errorType: 'missed_action_read',
    repairEntered: true,
    repairSucceeded: false,
    recheckSucceeded: false,
    recommendationReason: Act0ActionRecommendationReasonV1.repairIncomplete,
    proofStatement: 'proof',
    meaningStatement: 'meaning',
    primaryActionLabel: 'Repair now',
    blocksNormalProgression: true,
  );

  Act0SharkyPresentationStateV1 derive({
    bool welcome = false,
    bool teaching = false,
    bool complete = false,
    Act0ActionSessionPayoffV1? payoff,
  }) => deriveAct0SharkyPresentationStateV1(
    Act0SharkyPresentationInputV1(
      isWelcome: welcome,
      isTeaching: teaching,
      isSequenceCompletion: complete,
      payoff: payoff,
    ),
  );

  test('maps welcome and teaching without copy parsing', () {
    expect(
      derive(welcome: true),
      Act0SharkyPresentationStateV1.neutralGuidance,
    );
    expect(
      derive(teaching: true),
      Act0SharkyPresentationStateV1.teachingAttention,
    );
  });

  test('maps unresolved Action payoff to supportive repair', () {
    expect(
      derive(payoff: unresolved),
      Act0SharkyPresentationStateV1.supportiveRepair,
    );
  });

  test('maps recovered payoff to acknowledgement', () {
    expect(
      derive(payoff: recovered),
      Act0SharkyPresentationStateV1.recoveredAcknowledgement,
    );
  });

  test('maps only an earned clean completion to completion', () {
    expect(
      derive(payoff: clean),
      isNot(Act0SharkyPresentationStateV1.earnedCompletion),
    );
    expect(
      derive(payoff: clean, complete: true),
      Act0SharkyPresentationStateV1.earnedCompletion,
    );
  });
}

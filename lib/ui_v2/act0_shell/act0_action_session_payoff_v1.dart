import 'package:poker_analyzer/ui_v2/act0_shell/act0_action_sequence_personalization_v1.dart';

enum Act0ActionPayoffTypeV1 { cleanSuccess, recoveredSuccess, unresolvedSkill }

class Act0ActionSessionPayoffV1 {
  const Act0ActionSessionPayoffV1({
    required this.sequenceId,
    required this.conceptId,
    required this.type,
    required this.initialOutcome,
    required this.errorType,
    required this.repairEntered,
    required this.repairSucceeded,
    required this.recheckSucceeded,
    required this.recommendationReason,
    required this.proofStatement,
    required this.meaningStatement,
    required this.primaryActionLabel,
    required this.blocksNormalProgression,
  });

  final String sequenceId;
  final String conceptId;
  final Act0ActionPayoffTypeV1 type;
  final String initialOutcome;
  final String errorType;
  final bool repairEntered;
  final bool repairSucceeded;
  final bool recheckSucceeded;
  final Act0ActionRecommendationReasonV1 recommendationReason;
  final String proofStatement;
  final String meaningStatement;
  final String primaryActionLabel;
  final bool blocksNormalProgression;
}

/// Deterministic closure policy for the admitted W1 Action sequence.
class Act0ActionSessionPayoffPolicyV1 {
  static Act0ActionSessionPayoffV1 evaluate({
    required Act0ActionSequenceLearnerStateV1 learnerState,
    required Act0ActionRecommendationV1 recommendation,
  }) {
    final initial = learnerState.outcomes.isEmpty
        ? null
        : learnerState.outcomes.first;
    final initialMissed = initial != null && !initial.isCorrect;
    if (learnerState.repairSucceeded && learnerState.recheckSucceeded) {
      return _result(
        learnerState: learnerState,
        recommendation: recommendation,
        type: Act0ActionPayoffTypeV1.recoveredSuccess,
        initialOutcome: 'incorrect',
        errorType: 'missed_action_read',
        proofStatement:
            'You missed the no-bet read, repaired it, and passed the recheck.',
        meaningStatement:
            'The correction is supported by the successful recheck.',
        primaryActionLabel: 'Continue',
      );
    }
    if (!initialMissed && learnerState.latestOutcome?.isCorrect == true) {
      return _result(
        learnerState: learnerState,
        recommendation: recommendation,
        type: Act0ActionPayoffTypeV1.cleanSuccess,
        initialOutcome: 'correct',
        errorType: 'none',
        proofStatement: 'You read the action correctly.',
        meaningStatement: learnerState.hasSlowCorrect
            ? 'You took time to read the spot. Continue when ready.'
            : 'No repair was needed for this read.',
        primaryActionLabel: 'Continue',
      );
    }
    final repeated =
        recommendation.reason == Act0ActionRecommendationReasonV1.repeatedError;
    return _result(
      learnerState: learnerState,
      recommendation: recommendation,
      type: Act0ActionPayoffTypeV1.unresolvedSkill,
      initialOutcome: initialMissed ? 'incorrect' : 'unknown',
      errorType: initialMissed ? 'missed_action_read' : 'none',
      proofStatement: repeated
          ? 'The no-bet read was missed again.'
          : 'The no-bet read is not stable yet.',
      meaningStatement: repeated
          ? 'Reinforce action order before moving on.'
          : 'Repair this signal before moving on.',
      primaryActionLabel: 'Repair now',
    );
  }

  static Act0ActionSessionPayoffV1 _result({
    required Act0ActionSequenceLearnerStateV1 learnerState,
    required Act0ActionRecommendationV1 recommendation,
    required Act0ActionPayoffTypeV1 type,
    required String initialOutcome,
    required String errorType,
    required String proofStatement,
    required String meaningStatement,
    required String primaryActionLabel,
  }) => Act0ActionSessionPayoffV1(
    sequenceId: learnerState.sequenceId,
    conceptId: learnerState.conceptId,
    type: type,
    initialOutcome: initialOutcome,
    errorType: errorType,
    repairEntered: learnerState.outcomes.any(
      (outcome) => outcome.stage.name == 'repair',
    ),
    repairSucceeded: learnerState.repairSucceeded,
    recheckSucceeded: learnerState.recheckSucceeded,
    recommendationReason: recommendation.reason,
    proofStatement: proofStatement,
    meaningStatement: meaningStatement,
    primaryActionLabel: primaryActionLabel,
    blocksNormalProgression: recommendation.blocksNormalProgression,
  );
}

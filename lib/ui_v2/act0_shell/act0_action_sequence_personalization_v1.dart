import 'package:poker_analyzer/ui_v2/act0_shell/act0_action_learning_sequence_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';

/// Source-owned, session-scoped outcome record for the admitted W1 Action
/// sequence. It is derived from runner decisions; it never reads widget copy.
class Act0ActionSequenceLearnerStateV1 {
  const Act0ActionSequenceLearnerStateV1({
    required this.sequenceId,
    required this.conceptId,
    required this.outcomes,
  });

  final String sequenceId;
  final String conceptId;
  final List<Act0ActionSequenceOutcomeV1> outcomes;

  int get missedActionReadCount => outcomes
      .where(
        (outcome) =>
            !outcome.isCorrect &&
            outcome.errorType == act0ActionLearningSequenceV1.repairErrorType,
      )
      .length;

  Act0ActionSequenceOutcomeV1? get latestOutcome =>
      outcomes.isEmpty ? null : outcomes.last;

  bool get hasRepairFailure => outcomes.any(
    (outcome) =>
        outcome.stage == Act0ActionSequenceStageV1.repair && !outcome.isCorrect,
  );

  bool get repairSucceeded => outcomes.any(
    (outcome) =>
        outcome.stage == Act0ActionSequenceStageV1.repair && outcome.isCorrect,
  );

  bool get recheckSucceeded => outcomes.any(
    (outcome) =>
        outcome.stage == Act0ActionSequenceStageV1.recheck && outcome.isCorrect,
  );

  bool get hasSlowCorrect => outcomes.any(
    (outcome) => outcome.isCorrect && outcome.decisionTimeBucket == 'over_10s',
  );

  Act0ActionSequenceLearnerStateV1 append(
    Act0ActionSequenceOutcomeV1 outcome,
  ) => Act0ActionSequenceLearnerStateV1(
    sequenceId: sequenceId,
    conceptId: conceptId,
    outcomes: List<Act0ActionSequenceOutcomeV1>.unmodifiable(
      <Act0ActionSequenceOutcomeV1>[...outcomes, outcome],
    ),
  );
}

class Act0ActionSequenceOutcomeV1 {
  const Act0ActionSequenceOutcomeV1({
    required this.attemptKey,
    required this.stage,
    required this.isCorrect,
    required this.errorType,
    required this.decisionTimeBucket,
  });

  final String attemptKey;
  final Act0ActionSequenceStageV1 stage;
  final bool isCorrect;
  final String errorType;
  final String decisionTimeBucket;
}

enum Act0ActionRecommendationReasonV1 {
  recentError,
  repeatedError,
  repairIncomplete,
  recoveredAfterRecheck,
  normalProgression,
}

enum Act0ActionRecommendationTargetV1 { repair, nextCanonicalStep }

class Act0ActionRecommendationV1 {
  const Act0ActionRecommendationV1({
    required this.id,
    required this.target,
    required this.reason,
    required this.explanation,
    required this.sourceEvidenceSummary,
    required this.blocksNormalProgression,
  });

  final String id;
  final Act0ActionRecommendationTargetV1 target;
  final Act0ActionRecommendationReasonV1 reason;
  final String explanation;
  final String sourceEvidenceSummary;
  final bool blocksNormalProgression;
}

/// Small deterministic policy for the one admitted Action sequence only.
/// Constants are named policy decisions, not a scoring system.
class Act0ActionSequencePersonalizationPolicyV1 {
  static const int repeatedMissThreshold = 2;

  static Act0ActionSequenceLearnerStateV1 initialState() =>
      const Act0ActionSequenceLearnerStateV1(
        sequenceId: 'w1_action_words_check_v1',
        conceptId: 'action_words_no_bet_read',
        outcomes: <Act0ActionSequenceOutcomeV1>[],
      );

  static Act0ActionSequenceLearnerStateV1 deriveState({
    required Act0ActionSequenceLearnerStateV1 current,
    required Act0CompletedDecisionV1 decision,
    required Act0ActionSequenceStageV1 stage,
  }) {
    if (decision.taskId != act0ActionLearningSequenceV1.practiceTaskId) {
      return current;
    }
    return current.append(
      Act0ActionSequenceOutcomeV1(
        attemptKey: decision.attemptKey,
        stage: stage,
        isCorrect: decision.isCorrect,
        errorType: decision.isCorrect
            ? 'none'
            : act0ActionLearningSequenceV1.repairErrorType,
        decisionTimeBucket: decision.decisionTimeBucket,
      ),
    );
  }

  static Act0ActionRecommendationV1 evaluate(
    Act0ActionSequenceLearnerStateV1 state,
  ) {
    if (state.hasRepairFailure) {
      return _repair(
        Act0ActionRecommendationReasonV1.repairIncomplete,
        'The no-bet read still needs one clean retry. Repair it before moving on.',
        'repair_result=incomplete',
      );
    }
    if (state.repairSucceeded && state.recheckSucceeded) {
      return _next(
        Act0ActionRecommendationReasonV1.recoveredAfterRecheck,
        'You corrected the no-bet read on recheck. Continue while the pattern is fresh.',
        'repair=correct;recheck=correct',
      );
    }
    if (state.missedActionReadCount >= repeatedMissThreshold) {
      return _repair(
        Act0ActionRecommendationReasonV1.repeatedError,
        'You missed the no-bet read again. Reinforce action order before moving on.',
        'misread_action_legality_count=${state.missedActionReadCount}',
      );
    }
    final latest = state.latestOutcome;
    if (latest != null && !latest.isCorrect) {
      return _repair(
        Act0ActionRecommendationReasonV1.recentError,
        'You missed the no-bet read. Repair it now while the clue is fresh.',
        'error_type=${act0ActionLearningSequenceV1.repairErrorType}',
      );
    }
    return _next(
      Act0ActionRecommendationReasonV1.normalProgression,
      'You read the no-bet spot correctly. Continue to the next step.',
      state.hasSlowCorrect
          ? 'correct=slow;conceptual_failure=false'
          : 'correct=true;repair=false',
    );
  }

  static Act0ActionRecommendationV1 _repair(
    Act0ActionRecommendationReasonV1 reason,
    String explanation,
    String evidence,
  ) => Act0ActionRecommendationV1(
    id: 'w1_action_repair_${reason.name}_v1',
    target: Act0ActionRecommendationTargetV1.repair,
    reason: reason,
    explanation: explanation,
    sourceEvidenceSummary: evidence,
    blocksNormalProgression: true,
  );

  static Act0ActionRecommendationV1 _next(
    Act0ActionRecommendationReasonV1 reason,
    String explanation,
    String evidence,
  ) => Act0ActionRecommendationV1(
    id: 'w1_action_next_${reason.name}_v1',
    target: Act0ActionRecommendationTargetV1.nextCanonicalStep,
    reason: reason,
    explanation: explanation,
    sourceEvidenceSummary: evidence,
    blocksNormalProgression: false,
  );
}

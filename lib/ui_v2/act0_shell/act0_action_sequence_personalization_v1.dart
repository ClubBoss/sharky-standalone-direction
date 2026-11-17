import 'package:poker_analyzer/ui_v2/act0_shell/act0_action_learning_sequence_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_outcome_projection_v1.dart';

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

  // A new source decision, or a failed/unconfirmed source recheck, opens
  // the current obligation. Historical outcomes and miss count stay intact.
  int get _currentCycleStart {
    for (var i = outcomes.length - 1; i >= 0; i--) {
      final outcome = outcomes[i];
      if (outcome.stage == Act0ActionSequenceStageV1.decision ||
          (outcome.stage == Act0ActionSequenceStageV1.recheck &&
              (!outcome.isCorrect || !outcome.isProofEligible)))
        return i;
    }
    return 0;
  }

  Act0ActionSequenceOutcomeV1? get currentInitialOutcome =>
      outcomes.isEmpty ? null : outcomes[_currentCycleStart];

  Act0ActionSequenceOutcomeV1? get latestSourceOutcome {
    for (final outcome in outcomes.reversed) {
      if (outcome.stage == Act0ActionSequenceStageV1.decision ||
          outcome.stage == Act0ActionSequenceStageV1.recheck)
        return outcome;
    }
    return null;
  }

  Act0ActionSequenceOutcomeV1? _latestCurrentStage(
    Act0ActionSequenceStageV1 stage,
  ) {
    for (var i = outcomes.length - 1; i >= _currentCycleStart; i--) {
      if (outcomes[i].stage == stage) return outcomes[i];
    }
    return null;
  }

  Act0ActionSequenceOutcomeV1? get currentRepairOutcome =>
      _latestCurrentStage(Act0ActionSequenceStageV1.repair);

  bool get hasRepairFailure {
    final repair = currentRepairOutcome;
    return repair != null && (!repair.isCorrect || !repair.isProofEligible);
  }

  bool get repairSucceeded {
    final repair = currentRepairOutcome;
    return repair != null && repair.isCorrect && repair.isProofEligible;
  }

  bool get recheckSucceeded {
    final repair = currentRepairOutcome;
    final recheck = _latestCurrentStage(Act0ActionSequenceStageV1.recheck);
    if (!repairSucceeded ||
        repair == null ||
        recheck == null ||
        !identical(latestOutcome, recheck) ||
        !recheck.isCorrect ||
        !recheck.isProofEligible)
      return false;
    // Positional ordering is the original policy record order, never time.
    return outcomes.indexOf(recheck) > outcomes.indexOf(repair) &&
        recheck.sourceAttemptKey == repair.sourceAttemptKey;
  }

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
    this.sourceAttemptKey = '',
    this.assistanceKind = Act0DecisionAssistanceV1.none,
    this.qualifiesForProof = true,
  });

  final String attemptKey;
  final Act0ActionSequenceStageV1 stage;
  final bool isCorrect;
  final String errorType;
  final String decisionTimeBucket;
  final String sourceAttemptKey;
  final Act0DecisionAssistanceV1 assistanceKind;
  final bool qualifiesForProof;
  bool get isProofEligible =>
      qualifiesForProof && assistanceKind == Act0DecisionAssistanceV1.none;
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
    if (decision.taskId != act0ActionLearningSequenceV1.practiceTaskId ||
        current.outcomes.any(
          (prior) => prior.attemptKey == decision.attemptKey,
        )) {
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
        sourceAttemptKey: stage == Act0ActionSequenceStageV1.decision
            ? decision.attemptKey
            : (current.currentRepairOutcome?.sourceAttemptKey ??
                  current.latestSourceOutcome?.attemptKey ??
                  ''),
        assistanceKind: decision.assistanceKind,
        qualifiesForProof:
            decision.assistanceKind == Act0DecisionAssistanceV1.none,
      ),
    );
  }

  /// Observes a real mapped attempt without changing its task or grade.
  /// Only shared eligibility grants repair proof. Authentic assisted or
  /// unconfirmed target activity is retained and caps older current success.
  static Act0ActionSequenceLearnerStateV1 deriveMappedRepairState({
    required Act0ActionSequenceLearnerStateV1 current,
    required Act0CompletedDecisionV1 decision,
    required Act0RepairIntentV1 intent,
    required Act0RepairOutcomeV1? outcome,
    required Act0LearningEvidenceHistoryV1 learningEvidence,
    required Act0RepairFingerprintResolverV1 currentFingerprintForIdentity,
  }) {
    final sequence = act0ActionLearningSequenceV1;
    final latestSource = current.latestSourceOutcome;
    if (current.sequenceId != sequence.sequenceId ||
        intent.sourceWorldId != 'world_1' ||
        intent.sourceLessonId != 'fold_check_call_raise' ||
        intent.sourceTaskId != sequence.practiceTaskId ||
        intent.targetWorldId != 'world_1' ||
        intent.targetLessonId != 'fold_check_call_raise' ||
        intent.targetTaskId != 'actions_legal_context' ||
        decision.worldId != intent.targetWorldId ||
        decision.lessonId != intent.targetLessonId ||
        decision.taskId != intent.targetTaskId ||
        decision.sourceTaskId != intent.targetTaskId ||
        latestSource == null ||
        latestSource.isCorrect ||
        latestSource.attemptKey != intent.repairOccurrenceId ||
        current.outcomes.any(
          (prior) => prior.attemptKey == decision.attemptKey,
        )) {
      return current;
    }
    final goal = act0RepairGoalResolutionForIntentV1(
      intent,
      learningEvidence: learningEvidence,
      currentFingerprintForIdentity: currentFingerprintForIdentity,
    );
    if (!goal.canLaunch || goal.contract == null) return current;
    // Reuse existing canonical source proof for own-task authenticity; this
    // does not make an assisted/missing-outcome attempt repair-eligible.
    final attempts = act0RepairEvidenceRecordsForIdV1(
      learningEvidence,
      decision.attemptKey,
    );
    final sources = act0RepairEvidenceRecordsForIdV1(
      learningEvidence,
      intent.repairOccurrenceId,
    );
    if (attempts.length != 1 || sources.length != 1) return current;
    final attempt = attempts.single;
    final ownProof = act0CurrentAuthoredSourceProofV1(attempt);
    if (ownProof == null ||
        ownProof.isCurrentlyCorrect != decision.isCorrect ||
        attempt.worldId != decision.worldId ||
        attempt.lessonId != decision.lessonId ||
        attempt.taskId != decision.taskId ||
        attempt.sourceTaskId != decision.taskId ||
        attempt.choiceId != decision.selectedId ||
        attempt.expectedChoiceId != decision.expectedId ||
        attempt.expectedChoiceId != goal.contract!.targetCorrectChoiceId ||
        attempt.isCorrect != decision.isCorrect ||
        attempt.assistanceKind != decision.assistanceKind ||
        attempt.runKind != 'repair' ||
        attempt.isPlacementAssessment ||
        !const {
          'alternateSameSignal',
          'immediateRepair',
        }.contains(attempt.reviewKind.name) ||
        attempt.createdOrder <= sources.single.createdOrder ||
        attempt.authoredSourceFingerprint != goal.contract!.targetFingerprint)
      return current;
    final eligible =
        outcome != null &&
        decision.attemptKey == outcome.repairAttemptId &&
        decision.selectedId == outcome.selectedChoiceId &&
        decision.expectedId == outcome.correctChoiceId &&
        decision.isCorrect == outcome.isCorrect &&
        act0RepairGoalOutcomeIsEligibleV1(
          intent: intent,
          outcome: outcome,
          learningEvidence: learningEvidence,
          currentFingerprintForIdentity: currentFingerprintForIdentity,
        );
    return current.append(
      Act0ActionSequenceOutcomeV1(
        attemptKey: decision.attemptKey,
        stage: Act0ActionSequenceStageV1.repair,
        isCorrect: decision.isCorrect,
        errorType: decision.isCorrect ? 'none' : sequence.repairErrorType,
        decisionTimeBucket: decision.decisionTimeBucket,
        sourceAttemptKey: intent.repairOccurrenceId,
        assistanceKind: decision.assistanceKind,
        qualifiesForProof: eligible,
      ),
    );
  }

  static Act0ActionRecommendationV1 evaluate(
    Act0ActionSequenceLearnerStateV1 state,
  ) {
    if (state.hasRepairFailure ||
        (state.currentInitialOutcome != null &&
            !state.currentInitialOutcome!.isProofEligible &&
            !state.recheckSucceeded)) {
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
    final currentInitial = state.currentInitialOutcome;
    if (currentInitial != null &&
        identical(state.latestOutcome, currentInitial) &&
        currentInitial.stage == Act0ActionSequenceStageV1.decision &&
        currentInitial.isCorrect &&
        currentInitial.isProofEligible) {
      return _next(
        Act0ActionRecommendationReasonV1.normalProgression,
        'You read the no-bet spot correctly. Continue to the next step.',
        state.hasSlowCorrect
            ? 'correct=slow;conceptual_failure=false'
            : 'correct=true;repair=false',
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

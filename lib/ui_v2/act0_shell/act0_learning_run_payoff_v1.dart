import 'package:flutter/material.dart';

/// A run is intentionally local to one continuous visit through Learn. It is
/// not persisted and must never be read as long-term learner state.
enum Act0LearningRunFinalOutcomeV1 {
  masteredFirstTry,
  recoveredAfterRepair,
  stillNeedsPractice,
  incomplete,
}

class Act0LearningRunOutcomeV1 {
  const Act0LearningRunOutcomeV1({
    required this.outcomeId,
    required this.lessonId,
    required this.taskId,
    required this.skillId,
    required this.firstAttemptCorrect,
    required this.errorType,
    required this.repairAttempted,
    required this.recheckResult,
    required this.finalOutcome,
    required this.missedSignal,
    required this.recommendationSignal,
    required this.eventOrder,
  });

  final String outcomeId;
  final String lessonId;
  final String taskId;
  final String skillId;
  final bool firstAttemptCorrect;
  final String errorType;
  final bool repairAttempted;
  final bool? recheckResult;
  final Act0LearningRunFinalOutcomeV1 finalOutcome;
  final String missedSignal;
  final String recommendationSignal;
  final int eventOrder;

  bool get isMeaningful =>
      finalOutcome != Act0LearningRunFinalOutcomeV1.incomplete;

  Act0LearningRunOutcomeV1 mergedWith(Act0LearningRunOutcomeV1 newer) {
    if (outcomeId != newer.outcomeId) {
      return this;
    }
    return Act0LearningRunOutcomeV1(
      outcomeId: outcomeId,
      lessonId: newer.lessonId,
      taskId: newer.taskId,
      skillId: newer.skillId,
      firstAttemptCorrect: firstAttemptCorrect,
      errorType: newer.errorType,
      repairAttempted: newer.repairAttempted,
      recheckResult: newer.recheckResult,
      finalOutcome: newer.finalOutcome,
      missedSignal: newer.missedSignal,
      recommendationSignal: newer.recommendationSignal,
      // First observation is the stable canonical ordering anchor.
      eventOrder: eventOrder < newer.eventOrder ? eventOrder : newer.eventOrder,
    );
  }
}

class Act0LearningRunStateV1 {
  const Act0LearningRunStateV1({
    required this.runId,
    required this.startedAtMilliseconds,
    this.outcomes = const <Act0LearningRunOutcomeV1>[],
    this.closureReason = '',
    this.finalizedAtMilliseconds,
    this.payoffViewed = false,
    this.payoffCompleted = false,
  });

  final String runId;
  final int startedAtMilliseconds;
  final List<Act0LearningRunOutcomeV1> outcomes;
  final String closureReason;
  final int? finalizedAtMilliseconds;
  final bool payoffViewed;
  final bool payoffCompleted;

  int get meaningfulAttemptCount =>
      outcomes.where((outcome) => outcome.isMeaningful).length;

  Set<String> get lessonIds =>
      outcomes.map((outcome) => outcome.lessonId).toSet();
  Set<String> get skillIds =>
      outcomes.map((outcome) => outcome.skillId).toSet();
  bool get isPayoffEligible => meaningfulAttemptCount >= 2;

  Act0LearningRunStateV1 record(Act0LearningRunOutcomeV1 outcome) {
    final next = <Act0LearningRunOutcomeV1>[...outcomes];
    final index = next.indexWhere(
      (item) => item.outcomeId == outcome.outcomeId,
    );
    if (index >= 0) {
      next[index] = next[index].mergedWith(outcome);
    } else {
      next.add(outcome);
    }
    next.sort((a, b) {
      final order = a.eventOrder.compareTo(b.eventOrder);
      return order != 0 ? order : a.outcomeId.compareTo(b.outcomeId);
    });
    return Act0LearningRunStateV1(
      runId: runId,
      startedAtMilliseconds: startedAtMilliseconds,
      outcomes: List<Act0LearningRunOutcomeV1>.unmodifiable(next),
      closureReason: closureReason,
      finalizedAtMilliseconds: finalizedAtMilliseconds,
      payoffViewed: payoffViewed,
      payoffCompleted: payoffCompleted,
    );
  }

  Act0LearningRunStateV1 close({
    required String reason,
    required int finalizedAtMilliseconds,
  }) => Act0LearningRunStateV1(
    runId: runId,
    startedAtMilliseconds: startedAtMilliseconds,
    outcomes: outcomes,
    closureReason: reason,
    finalizedAtMilliseconds: finalizedAtMilliseconds,
    payoffViewed: payoffViewed,
    payoffCompleted: payoffCompleted,
  );

  Act0LearningRunStateV1 markPayoffViewed() => Act0LearningRunStateV1(
    runId: runId,
    startedAtMilliseconds: startedAtMilliseconds,
    outcomes: outcomes,
    closureReason: closureReason,
    finalizedAtMilliseconds: finalizedAtMilliseconds,
    payoffViewed: true,
    payoffCompleted: payoffCompleted,
  );

  Act0LearningRunStateV1 markPayoffCompleted() => Act0LearningRunStateV1(
    runId: runId,
    startedAtMilliseconds: startedAtMilliseconds,
    outcomes: outcomes,
    closureReason: closureReason,
    finalizedAtMilliseconds: finalizedAtMilliseconds,
    payoffViewed: payoffViewed,
    payoffCompleted: true,
  );
}

class Act0LearningRunPayoffV1 {
  const Act0LearningRunPayoffV1({
    required this.strength,
    required this.recovered,
    required this.unresolved,
    required this.nextClue,
    required this.nextPractice,
  });

  final Act0LearningRunOutcomeV1? strength;
  final Act0LearningRunOutcomeV1? recovered;
  final Act0LearningRunOutcomeV1? unresolved;
  final String nextClue;
  final String nextPractice;
}

/// Family-owned descriptors let the run policy stay generic as deterministic
/// personalization families are admitted. Unknown future skills retain a safe
/// generic label and recommendation instead of receiving a false named claim.
class Act0LearningRunSkillDescriptorV1 {
  const Act0LearningRunSkillDescriptorV1({
    required this.label,
    required this.nextClue,
    required this.nextPractice,
  });

  final String label;
  final String nextClue;
  final String nextPractice;
}

class Act0LearningRunPayoffPolicyV1 {
  static Act0LearningRunPayoffV1? evaluate(Act0LearningRunStateV1 run) {
    if (!run.isPayoffEligible) return null;
    final ordered = <Act0LearningRunOutcomeV1>[...run.outcomes]..sort(_compare);
    final unresolved = _first(
      ordered,
      Act0LearningRunFinalOutcomeV1.stillNeedsPractice,
    );
    final recovered = _first(
      ordered,
      Act0LearningRunFinalOutcomeV1.recoveredAfterRepair,
    );
    final clean = _first(
      ordered,
      Act0LearningRunFinalOutcomeV1.masteredFirstTry,
    );
    final focus = unresolved ?? recovered ?? clean;
    if (focus == null) return null;
    return Act0LearningRunPayoffV1(
      strength: clean ?? recovered,
      recovered: recovered,
      unresolved: unresolved,
      nextClue: _clueFor(focus),
      nextPractice: _practiceFor(focus),
    );
  }

  static Act0LearningRunOutcomeV1? _first(
    List<Act0LearningRunOutcomeV1> outcomes,
    Act0LearningRunFinalOutcomeV1 kind,
  ) {
    for (final outcome in outcomes) {
      if (outcome.finalOutcome == kind) return outcome;
    }
    return null;
  }

  static int _compare(Act0LearningRunOutcomeV1 a, Act0LearningRunOutcomeV1 b) {
    final priority = _priority(
      a.finalOutcome,
    ).compareTo(_priority(b.finalOutcome));
    if (priority != 0) return priority;
    final skill = a.skillId.compareTo(b.skillId);
    return skill != 0 ? skill : a.eventOrder.compareTo(b.eventOrder);
  }

  static int _priority(Act0LearningRunFinalOutcomeV1 outcome) =>
      switch (outcome) {
        Act0LearningRunFinalOutcomeV1.stillNeedsPractice => 0,
        Act0LearningRunFinalOutcomeV1.recoveredAfterRepair => 1,
        Act0LearningRunFinalOutcomeV1.masteredFirstTry => 2,
        Act0LearningRunFinalOutcomeV1.incomplete => 3,
      };

  static String skillLabel(Act0LearningRunOutcomeV1 outcome) =>
      _descriptorFor(outcome).label;

  static String outcomeLine(Act0LearningRunOutcomeV1 outcome) =>
      switch (outcome.finalOutcome) {
        Act0LearningRunFinalOutcomeV1.masteredFirstTry =>
          'You read ${skillLabel(outcome)} correctly.',
        Act0LearningRunFinalOutcomeV1.recoveredAfterRepair =>
          'You repaired ${skillLabel(outcome)} and passed the recheck.',
        Act0LearningRunFinalOutcomeV1.stillNeedsPractice =>
          '${skillLabel(outcome)} still needs one more careful rep.',
        Act0LearningRunFinalOutcomeV1.incomplete => '',
      };

  static String _clueFor(Act0LearningRunOutcomeV1 outcome) =>
      _descriptorFor(outcome).nextClue;

  static String _practiceFor(Act0LearningRunOutcomeV1 outcome) =>
      _descriptorFor(outcome).nextPractice;

  static Act0LearningRunSkillDescriptorV1 _descriptorFor(
    Act0LearningRunOutcomeV1 outcome,
  ) => _skillDescriptors[outcome.skillId] ?? _genericDescriptor;

  static const Map<String, Act0LearningRunSkillDescriptorV1> _skillDescriptors =
      <String, Act0LearningRunSkillDescriptorV1>{
        'action_read': Act0LearningRunSkillDescriptorV1(
          label: 'the action',
          nextClue: 'Check whether a bet is already in front of you.',
          nextPractice: 'Practice one more action-order read next.',
        ),
        'table_position_read': Act0LearningRunSkillDescriptorV1(
          label: 'table position',
          nextClue: 'Find the Button before judging who acts late.',
          nextPractice: 'Practice one more Button read next.',
        ),
        'price_read': Act0LearningRunSkillDescriptorV1(
          label: 'the price',
          nextClue: 'Compare the pot with the amount you must call.',
          nextPractice: 'Practice one more pot-versus-call read next.',
        ),
      };

  static const Act0LearningRunSkillDescriptorV1 _genericDescriptor =
      Act0LearningRunSkillDescriptorV1(
        label: 'this clue',
        nextClue: 'Inspect the same table clue before choosing again.',
        nextPractice: 'Practice the same clue once more next.',
      );
}

class Act0LearningRunPayoffSheetV1 extends StatelessWidget {
  const Act0LearningRunPayoffSheetV1({
    super.key,
    required this.payoff,
    required this.onComplete,
  });

  final Act0LearningRunPayoffV1 payoff;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.black54,
    child: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440, maxHeight: 680),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Material(
              color: const Color(0xFF152331),
              borderRadius: BorderRadius.circular(24),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  key: const Key('act0_learning_run_payoff'),
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your learning run',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (payoff.strength != null)
                      _line(
                        'Strength',
                        Act0LearningRunPayoffPolicyV1.outcomeLine(
                          payoff.strength!,
                        ),
                      ),
                    if (payoff.recovered != null)
                      _line(
                        'Recovered',
                        Act0LearningRunPayoffPolicyV1.outcomeLine(
                          payoff.recovered!,
                        ),
                      ),
                    if (payoff.unresolved != null)
                      _line(
                        'Still developing',
                        Act0LearningRunPayoffPolicyV1.outcomeLine(
                          payoff.unresolved!,
                        ),
                      ),
                    _line('Next clue', payoff.nextClue),
                    _line('Practice next', payoff.nextPractice),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        key: const Key('act0_learning_run_payoff_complete_cta'),
                        onPressed: onComplete,
                        child: const Text('Back to Home'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _line(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF9DD6FF),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(value, style: const TextStyle(color: Colors.white, height: 1.3)),
      ],
    ),
  );
}

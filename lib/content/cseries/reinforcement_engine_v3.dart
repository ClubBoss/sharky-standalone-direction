/// Deterministic weighted reinforcement logic.
class ReinforcementEngineV3 {
  const ReinforcementEngineV3();

  Map<String, Object?> compute({
    required Map<String, Object?> evaluationResult,
    required Map<String, Object?> scoringResult,
  }) {
    final int evalScore = evaluationResult['difficulty_hint'] as int? ?? 1;
    final int scorePrimary = scoringResult['score_primary'] as int? ?? 2;
    const int wEval = 2;
    const int wScore = 3;
    final int weighted = (evalScore * wEval) + (scorePrimary * wScore);
    final String action = weighted > 7
        ? 'review_immediately'
        : 'review_normally';
    final int priority = weighted;
    final String nextReview = weighted > 7 ? 'soon' : 'later';
    return Map.unmodifiable(<String, Object?>{
      'version': 'v3',
      'eval_score': evalScore,
      'score_primary': scorePrimary,
      'weighted_score': weighted,
      'recommended_action': action,
      'priority': priority,
      'next_review_time': nextReview,
      'note':
          'Deterministic weighted logic; no persona/SRS/adaptive computations.',
    });
  }
}

ReinforcementEngineV3 buildReinforcementEngineV3() =>
    const ReinforcementEngineV3();

class ScoringLockInV1 {
  const ScoringLockInV1();

  static Map<String, Object?> lockIn({
    required Map<String, num> domainScores,
    required Map<String, num> personaScores,
  }) {
    return {
      "present": true,
      "stage": "scoring_lockin_v1",
      "domain_scores_seen": domainScores.keys.toList(),
      "persona_scores_seen": personaScores.keys.toList(),
      "locked_in": false,
    };
  }
}

class AdaptiveUxHooks {
  AdaptiveUxHooks();

  void requestHint() {}
  void requestLightHint() {}
  void requestReinforcement() {}
  void requestDifficultyUp() {}
  void requestDifficultyDown() {}
  void requestTempoUp() {}
  void requestTempoDown() {}
  void requestAdaptiveBranch() {}

  // hint patterns
  String generateHintPatternPrimary() => '';
  String generateHintPatternSecondary() => '';

  // reinforcement cues
  void emitReinforcementSoft() {}
  void emitReinforcementStrong() {}

  // difficulty shaping
  String computeDifficultySoft() => '';
  String computeDifficultyHard() => '';

  // tempo adjustment
  void adjustTempoUp() {}
  void adjustTempoDown() {}

  // branch selection
  String selectBranchPrimary() => '';
  String selectBranchSecondary() => '';
}

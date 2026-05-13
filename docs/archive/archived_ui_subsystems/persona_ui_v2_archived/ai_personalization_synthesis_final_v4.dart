class AIPersonalizationSynthesisFinalV4 {
  AIPersonalizationSynthesisFinalV4({
    required Map<String, Object?> synthesis,
    required Map<String, Object?> merged,
  }) : _synthesis = Map.of(synthesis),
       _merged = Map.of(merged),
       finalState = (_toScore(synthesis) >= 0.75) ? 'ok' : 'warn';

  final Map<String, Object?> _synthesis;
  final Map<String, Object?> _merged;
  final String finalState;

  static double _toScore(Map<String, Object?> synthesis) {
    final total = synthesis['synthTotalScore'];
    if (total is num) return total.toDouble();
    return 0.0;
  }

  Map<String, Object?> asReadOnlyMap() => {
    'finalState': finalState,
    'synthSeedScore': _synthesis['synthSeedScore'],
    'synthVectorScore': _synthesis['synthVectorScore'],
    'synthTotalScore': _synthesis['synthTotalScore'],
    'finalSeedLogic': _synthesis['finalSeedLogic'],
    'finalVectorLogic': _synthesis['finalVectorLogic'],
    'finalPairLogic': _synthesis['finalPairLogic'],
    'finalTierBLogic': _synthesis['finalTierBLogic'],
    'synthesis': _synthesis,
    'merged': _merged,
  };
}

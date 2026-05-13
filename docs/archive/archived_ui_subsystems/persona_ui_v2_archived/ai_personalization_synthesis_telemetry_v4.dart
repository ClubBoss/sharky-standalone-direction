class AIPersonalizationSynthesisTelemetryV4 {
  AIPersonalizationSynthesisTelemetryV4({
    required Map<String, Object?> finalSynthesis,
  }) : _finalSynthesis = Map.of(finalSynthesis);

  final Map<String, Object?> _finalSynthesis;

  double? _readDouble(String key) {
    final value = _finalSynthesis[key];
    if (value is num) return value.toDouble();
    return null;
  }

  Map<String, Object?> asReadOnlyMap() => {
    'synthSeedScore': _readDouble('synthSeedScore'),
    'synthVectorScore': _readDouble('synthVectorScore'),
    'synthTotalScore': _readDouble('synthTotalScore'),
    'finalSeedLogic': _readDouble('finalSeedLogic'),
    'finalVectorLogic': _readDouble('finalVectorLogic'),
    'finalPairLogic': _readDouble('finalPairLogic'),
    'finalTierBLogic': _readDouble('finalTierBLogic'),
    'finalState': _finalSynthesis['finalState'],
  };
}

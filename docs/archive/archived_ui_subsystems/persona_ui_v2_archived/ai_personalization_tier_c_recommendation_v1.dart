/// Tier-C recommendation engine (Phi-39.4).
class AIPersonalizationTierCRecommendationV1 {
  const AIPersonalizationTierCRecommendationV1(this.tierCGateMap);

  final Map<String, Object> tierCGateMap;

  Map<String, Object> asReadOnlyMap() {
    final bool gateReady = tierCGateMap['gate_ready'] == true;
    Map<String, Object>? signals;
    if (tierCGateMap['input'] is Map) {
      final Map<Object?, Object?> rawInput =
          tierCGateMap['input'] as Map<Object?, Object?>;
      if (rawInput['signals'] is Map) {
        signals = (rawInput['signals'] as Map).cast<String, Object>();
      }
    }

    double _parseFactor(Object? value) {
      if (value is num) return value.toDouble();
      if (value is String) {
        final double? parsed = double.tryParse(value);
        if (parsed != null) return parsed;
      }
      return 0.0;
    }

    final double personaFactor = _parseFactor(signals?['persona_factor']);
    final double deviceFactor = _parseFactor(signals?['device_factor']);
    final double contextFactor = _parseFactor(signals?['context_factor']);

    String personaMode;
    if (personaFactor > 0.66) {
      personaMode = 'aggressive';
    } else if (personaFactor < 0.33) {
      personaMode = 'conservative';
    } else {
      personaMode = 'stable';
    }

    final double intensity =
        (personaFactor + deviceFactor + contextFactor) / 3.0;

    final bool recommendationValid = gateReady;
    final Map<String, Object> recommendation = <String, Object>{
      'persona_mode': personaMode,
      'intensity': recommendationValid ? intensity : 0.0,
      'valid': recommendationValid,
    };

    final bool recommendationReady = gateReady && recommendationValid;

    return <String, Object>{
      'input': tierCGateMap,
      'recommendation': recommendation,
      'recommendation_ready': recommendationReady,
    };
  }

  Map<String, Object> run() => asReadOnlyMap();
}

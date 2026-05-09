/// Tier-C style adapter (Phi-39.5).
class AIPersonalizationTierCStyleAdapterV1 {
  const AIPersonalizationTierCStyleAdapterV1(this.tierCRecommendationMap);

  final Map<String, Object> tierCRecommendationMap;

  Map<String, Object> asReadOnlyMap() {
    final bool recommendationReady =
        tierCRecommendationMap['recommendation_ready'] == true;
    Map<String, Object>? recommendation;
    if (tierCRecommendationMap['recommendation'] is Map) {
      recommendation = (tierCRecommendationMap['recommendation'] as Map)
          .cast<String, Object>();
    }

    double _parseIntensity(Object? value) {
      if (value is num) return value.toDouble();
      if (value is String) {
        final double? parsed = double.tryParse(value);
        if (parsed != null) return parsed;
      }
      return 0.0;
    }

    final double intensity = _parseIntensity(recommendation?['intensity']);
    final String personaMode =
        (recommendation?['persona_mode'] as String?) ?? 'stable';

    String emphasis;
    if (intensity > 0.66) {
      emphasis = 'high';
    } else if (intensity < 0.33) {
      emphasis = 'low';
    } else {
      emphasis = 'medium';
    }

    String tone;
    if (personaMode == 'aggressive') {
      tone = 'excited';
    } else if (personaMode == 'conservative') {
      tone = 'calm';
    } else {
      tone = 'neutral';
    }

    final bool styleValid = recommendationReady;
    final Map<String, Object> style = <String, Object>{
      'text_scale': styleValid ? 1.0 + (intensity * 0.1) : 1.0,
      'emphasis': emphasis,
      'tone': tone,
      'valid': styleValid,
    };

    final bool styleReady = recommendationReady && styleValid;

    return <String, Object>{
      'input': tierCRecommendationMap,
      'style': style,
      'style_ready': styleReady,
    };
  }

  Map<String, Object> run() => asReadOnlyMap();
}

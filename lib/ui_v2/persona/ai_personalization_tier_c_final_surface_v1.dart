/// Tier-C final persona surface (Phi-39.6).
class AIPersonalizationTierCFinalSurfaceV1 {
  const AIPersonalizationTierCFinalSurfaceV1(
    this.tierCGateMap,
    this.tierCRecommendationMap,
    this.tierCStyleAdapterMap,
  );

  final Map<String, Object> tierCGateMap;
  final Map<String, Object> tierCRecommendationMap;
  final Map<String, Object> tierCStyleAdapterMap;

  Map<String, Object> asReadOnlyMap() {
    final bool gateReady = tierCGateMap['gate_ready'] == true;
    final bool recommendationReady =
        tierCRecommendationMap['recommendation_ready'] == true;
    final bool styleReady = tierCStyleAdapterMap['style_ready'] == true;

    Map<String, Object>? recommendation;
    if (tierCRecommendationMap['recommendation'] is Map) {
      recommendation = (tierCRecommendationMap['recommendation'] as Map)
          .cast<String, Object>();
    }
    Map<String, Object>? style;
    if (tierCStyleAdapterMap['style'] is Map) {
      style = (tierCStyleAdapterMap['style'] as Map).cast<String, Object>();
    }

    double _parseDouble(Object? value) {
      if (value is num) return value.toDouble();
      if (value is String) {
        final double? parsed = double.tryParse(value);
        if (parsed != null) return parsed;
      }
      return 0.0;
    }

    final double intensity = _parseDouble(recommendation?['intensity']);
    final String personaMode =
        (recommendation?['persona_mode'] as String?) ?? 'stable';
    final Object? textScaleValue = style?['text_scale'];
    final double textScale;
    if (textScaleValue is num) {
      textScale = textScaleValue.toDouble();
    } else if (textScaleValue is String) {
      textScale = double.tryParse(textScaleValue) ?? 1.0;
    } else {
      textScale = 1.0;
    }
    final String emphasis = (style?['emphasis'] as String?) ?? 'medium';
    final String tone = (style?['tone'] as String?) ?? 'neutral';

    final bool surfaceValid = gateReady && recommendationReady && styleReady;
    final Map<String, Object> personaSurface = <String, Object>{
      'text_scale': textScale,
      'emphasis': emphasis,
      'tone': tone,
      'persona_mode': personaMode,
      'intensity': intensity,
      'valid': surfaceValid,
    };

    return <String, Object>{
      'tier_c': <String, Object>{
        'gate': tierCGateMap,
        'recommendation': tierCRecommendationMap,
        'style': tierCStyleAdapterMap,
      },
      'persona_surface': personaSurface,
      'surface_ready': surfaceValid,
    };
  }

  Map<String, Object> run() => asReadOnlyMap();
}

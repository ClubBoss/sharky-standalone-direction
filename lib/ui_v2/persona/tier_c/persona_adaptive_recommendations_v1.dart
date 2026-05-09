class PersonaAdaptiveRecommendationsV1 {
  const PersonaAdaptiveRecommendationsV1({
    this.personaMicroScoreMap = const <String, Object>{},
    this.personaMicroSegmentsMap = const <String, Object>{},
    this.personaBiasMap = const <String, Object>{},
    this.personaStyleAdaptiveTextMap = const <String, Object>{},
  });

  PersonaAdaptiveRecommendationsV1.fromInputs({
    Map<String, Object?>? personaMicroScoreMap,
    Map<String, Object?>? personaMicroSegmentsMap,
    Map<String, Object?>? personaBiasMap,
    Map<String, Object?>? personaStyleAdaptiveTextMap,
  }) : this(
         personaMicroScoreMap: _safe(personaMicroScoreMap),
         personaMicroSegmentsMap: _safe(personaMicroSegmentsMap),
         personaBiasMap: _safe(personaBiasMap),
         personaStyleAdaptiveTextMap: _safe(personaStyleAdaptiveTextMap),
       );

  final Map<String, Object> personaMicroScoreMap;
  final Map<String, Object> personaMicroSegmentsMap;
  final Map<String, Object> personaBiasMap;
  final Map<String, Object> personaStyleAdaptiveTextMap;

  Map<String, Object> build() {
    final double score = _extractScore();
    final String tone = _extractTone();
    final String tag;
    if (score >= 0.7) {
      tag = 'aggressive_push';
    } else if (tone == 'sharp') {
      tag = 'precision_focus';
    } else if (tone == 'soft') {
      tag = 'calm_value';
    } else {
      tag = 'neutral_standard';
    }
    return <String, Object>{
      'persona_adaptive_recommendations_v1': <String, Object>{
        'tag': tag,
        'ready': true,
      },
    };
  }

  double _extractScore() {
    final Map<String, Object?> scoreBody =
        personaMicroScoreMap['persona_micro_scoring_v1']
            as Map<String, Object?>? ??
        <String, Object?>{};
    return _toDouble(scoreBody['score']);
  }

  String _extractTone() {
    final Map<String, Object?> styleBody =
        personaStyleAdaptiveTextMap['persona_style_adaptive_text_v1']
            as Map<String, Object?>? ??
        <String, Object?>{};
    return (styleBody['tone'] as String? ?? 'neutral').toLowerCase();
  }

  static double _toDouble(Object? raw) {
    if (raw is num) return raw.toDouble();
    if (raw is String) {
      final double? parsed = double.tryParse(raw);
      if (parsed != null) return parsed;
    }
    return 0.0;
  }

  static Map<String, Object> _safe(Map<String, Object?>? source) {
    if (source == null) return const <String, Object>{};
    final Map<String, Object> target = <String, Object>{};
    for (final MapEntry<String, Object?> entry in source.entries) {
      target[entry.key] = entry.value ?? '';
    }
    return target;
  }
}

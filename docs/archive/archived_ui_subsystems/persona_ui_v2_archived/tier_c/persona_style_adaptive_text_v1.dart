class PersonaStyleAdaptiveTextV1 {
  const PersonaStyleAdaptiveTextV1({
    this.personaMicroScoreMap = const <String, Object>{},
    this.personaMicroSegmentsMap = const <String, Object>{},
    this.personaBiasMap = const <String, Object>{},
  });

  PersonaStyleAdaptiveTextV1.fromInputs({
    Map<String, Object?>? personaMicroScoreMap,
    Map<String, Object?>? personaMicroSegmentsMap,
    Map<String, Object?>? personaBiasMap,
  }) : this(
         personaMicroScoreMap: _safe(personaMicroScoreMap),
         personaMicroSegmentsMap: _safe(personaMicroSegmentsMap),
         personaBiasMap: _safe(personaBiasMap),
       );

  final Map<String, Object> personaMicroScoreMap;
  final Map<String, Object> personaMicroSegmentsMap;
  final Map<String, Object> personaBiasMap;

  Map<String, Object> build() {
    final double score = _extractScore();
    final String tone = _extractTone();
    final double weightDelta = score * 0.15;
    final double alphaDelta = score * 0.10;
    return <String, Object>{
      'persona_style_adaptive_text_v1': <String, Object>{
        'tone': tone,
        'weight_delta': weightDelta,
        'alpha_delta': alphaDelta,
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
    final Map<String, Object?> biasBody =
        personaBiasMap['persona_bias_map_v1'] as Map<String, Object?>? ??
        <String, Object?>{};
    return (biasBody['bias_tone'] as String? ?? 'neutral').toLowerCase();
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

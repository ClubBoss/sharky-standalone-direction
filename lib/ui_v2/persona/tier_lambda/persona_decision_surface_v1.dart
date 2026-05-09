class PersonaDecisionSurfaceV1 {
  const PersonaDecisionSurfaceV1({
    this.personaDirectionalRouterMap = const <String, Object>{},
    this.personaAggregationGatewayMap = const <String, Object>{},
  });

  PersonaDecisionSurfaceV1.fromInputs({
    Map<String, Object?>? personaDirectionalRouterMap,
    Map<String, Object?>? personaAggregationGatewayMap,
  }) : this(
         personaDirectionalRouterMap: _safe(personaDirectionalRouterMap),
         personaAggregationGatewayMap: _safe(personaAggregationGatewayMap),
       );

  final Map<String, Object> personaDirectionalRouterMap;
  final Map<String, Object> personaAggregationGatewayMap;

  Map<String, Object> build() {
    final String directionalTag = _extractTag(
      personaDirectionalRouterMap,
      'direction_tag',
    );
    final double routerConfidence = _extract(
      personaDirectionalRouterMap,
      'confidence',
    );
    final double aggScore = _extract(personaAggregationGatewayMap, 'agg_score');

    double decisionScore = (aggScore * 0.7) + (routerConfidence * 0.3);
    decisionScore = decisionScore.clamp(0.0, 1.0);

    String decisionTag = 'neutral';
    if (directionalTag == 'learn' && aggScore > 0.6)
      decisionTag = 'learn';
    else if (directionalTag == 'challenge' && aggScore > 0.5)
      decisionTag = 'challenge';
    else if (directionalTag == 'review')
      decisionTag = 'review';
    else if (aggScore > 0.75)
      decisionTag = 'focus';

    final Map<String, Object> payload = <String, Object>{};
    payload['decision_score'] = decisionScore;
    payload['decision_tag'] = _ascii(decisionTag);
    payload['ready'] = true;

    return Map<String, Object>.unmodifiable(<String, Object>{
      'persona_decision_surface_v1': Map<String, Object>.unmodifiable(payload),
    });
  }

  static double _extract(Map<String, Object> map, String key) {
    final Object? value = map[key];
    if (value is num) return value.toDouble();
    if (value is String) {
      final double? parsed = double.tryParse(value);
      if (parsed != null) return parsed;
    }
    return 0.0;
  }

  static String _extractTag(Map<String, Object> map, String key) =>
      (map[key] as String?)?.trim() ?? '';

  static Map<String, Object> _safe(Map<String, Object?>? source) {
    if (source == null) return const <String, Object>{};
    final Map<String, Object> cleaned = <String, Object>{};
    for (final MapEntry<String, Object?> entry in source.entries) {
      cleaned[entry.key] = entry.value ?? '';
    }
    return cleaned;
  }

  static String _ascii(String input) => String.fromCharCodes(
    input.codeUnits.where((unit) => unit >= 0 && unit < 128),
  );
}

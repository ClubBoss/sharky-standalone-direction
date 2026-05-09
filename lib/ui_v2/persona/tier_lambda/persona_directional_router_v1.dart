class PersonaDirectionalRouterV1 {
  const PersonaDirectionalRouterV1({
    this.personaAggregationGatewayMap = const <String, Object>{},
  });

  PersonaDirectionalRouterV1.fromInputs({
    Map<String, Object?>? personaAggregationGatewayMap,
  }) : this(personaAggregationGatewayMap: _safe(personaAggregationGatewayMap));

  final Map<String, Object> personaAggregationGatewayMap;

  Map<String, Object> build() {
    final double aggScore = _extract(personaAggregationGatewayMap, 'agg_score');
    final String aggTag = _extractTag(personaAggregationGatewayMap, 'agg_tag');

    String directionTag = 'neutral';
    if (aggTag == 'growth' || aggTag == 'focus') {
      directionTag = 'learn';
    } else if (aggTag == 'aggr' || aggTag == 'driver') {
      directionTag = 'challenge';
    } else if (aggTag == 'calm') {
      directionTag = 'review';
    } else if (aggScore > 0.75) {
      directionTag = 'focus';
    }

    final double confidence = aggScore.abs().clamp(0.0, 1.0);
    return <String, Object>{
      'persona_directional_router_v1': <String, Object>{
        'direction_tag': _ascii(directionTag),
        'confidence': confidence,
        'ready': true,
      },
    };
  }

  static double _extract(Map<String, Object> map, String key) {
    final Object? raw = map[key];
    if (raw is num) return raw.toDouble();
    if (raw is String) {
      final double? parsed = double.tryParse(raw);
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

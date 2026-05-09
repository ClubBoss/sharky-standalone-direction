class TableAdaptationSeedV1 {
  const TableAdaptationSeedV1({
    this.personaDecisionSurfaceMap = const <String, Object>{},
    this.personaDirectionalRouterMap = const <String, Object>{},
    this.personaAggregationGatewayMap = const <String, Object>{},
  });

  TableAdaptationSeedV1.fromInputs({
    Map<String, Object?>? personaDecisionSurfaceMap,
    Map<String, Object?>? personaDirectionalRouterMap,
    Map<String, Object?>? personaAggregationGatewayMap,
  }) : this(
         personaDecisionSurfaceMap: _safe(personaDecisionSurfaceMap),
         personaDirectionalRouterMap: _safe(personaDirectionalRouterMap),
         personaAggregationGatewayMap: _safe(personaAggregationGatewayMap),
       );

  final Map<String, Object> personaDecisionSurfaceMap;
  final Map<String, Object> personaDirectionalRouterMap;
  final Map<String, Object> personaAggregationGatewayMap;

  Map<String, Object> build() {
    final double decisionScore = _extractNested(
      personaDecisionSurfaceMap,
      'persona_decision_surface_v1',
      'decision_score',
    );
    final double routerConfidence = _extractNested(
      personaDirectionalRouterMap,
      'persona_directional_router_v1',
      'confidence',
    );
    final double aggScore = _extractNested(
      personaAggregationGatewayMap,
      'persona_aggregation_gateway_v1',
      'agg_score',
    );

    double adaptationScore =
        (decisionScore * 0.5) + (routerConfidence * 0.3) + (aggScore * 0.2);
    adaptationScore = adaptationScore.clamp(0.0, 1.0);

    String adaptationTag = _extractNestedTag(
      personaDecisionSurfaceMap,
      'persona_decision_surface_v1',
      'decision_tag',
    );
    if (adaptationTag.isEmpty || adaptationTag == 'neutral') {
      adaptationTag = _extractNestedTag(
        personaAggregationGatewayMap,
        'persona_aggregation_gateway_v1',
        'agg_tag',
      );
    }
    if (adaptationTag.isEmpty) {
      adaptationTag = _extractNestedTag(
        personaDirectionalRouterMap,
        'persona_directional_router_v1',
        'direction_tag',
      );
    }
    if (adaptationTag.isEmpty) adaptationTag = 'adaptive';

    final Map<String, Object> payload = <String, Object>{
      'adaptation_score': adaptationScore,
      'adaptation_tag': _ascii(adaptationTag),
      'ready': true,
    };

    return Map<String, Object>.unmodifiable(<String, Object>{
      'table_adaptation_seed_v1': Map<String, Object>.unmodifiable(payload),
    });
  }

  static double _extractNested(
    Map<String, Object> map,
    String sectionKey,
    String entryKey,
  ) {
    final Object? section = map[sectionKey];
    if (section is Map<String, Object>) {
      return _extract(section, entryKey);
    }
    return 0.0;
  }

  static String _extractNestedTag(
    Map<String, Object> map,
    String sectionKey,
    String entryKey,
  ) {
    final Object? section = map[sectionKey];
    if (section is Map<String, Object>) {
      return _extractTag(section, entryKey);
    }
    return '';
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
      if (entry.value == null) continue;
      cleaned[entry.key] = entry.value!;
    }
    return cleaned;
  }

  static String _ascii(String input) => String.fromCharCodes(
    input.codeUnits.where((unit) => unit >= 0 && unit < 128),
  );
}

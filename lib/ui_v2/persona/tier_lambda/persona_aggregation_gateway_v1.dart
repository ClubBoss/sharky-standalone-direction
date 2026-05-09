class PersonaAggregationGatewayV1 {
  const PersonaAggregationGatewayV1({
    this.personaMasterBundleMap = const <String, Object>{},
    this.personaGlobalV1Map = const <String, Object>{},
    this.personaGlobalBridgeMap = const <String, Object>{},
  });

  PersonaAggregationGatewayV1.fromInputs({
    Map<String, Object?>? personaMasterBundleMap,
    Map<String, Object?>? personaGlobalV1Map,
    Map<String, Object?>? personaGlobalBridgeMap,
  }) : this(
         personaMasterBundleMap: _safe(personaMasterBundleMap),
         personaGlobalV1Map: _safe(personaGlobalV1Map),
         personaGlobalBridgeMap: _safe(personaGlobalBridgeMap),
       );

  final Map<String, Object> personaMasterBundleMap;
  final Map<String, Object> personaGlobalV1Map;
  final Map<String, Object> personaGlobalBridgeMap;

  Map<String, Object> build() {
    final double masterScore = _extract(personaMasterBundleMap, 'master_score');
    final double globalScore = _extract(personaGlobalV1Map, 'global_score');
    final double bridgeValue = _extract(personaGlobalBridgeMap, 'bridge_value');
    final String masterTag = _extractTag(personaMasterBundleMap, 'master_tag');
    final String globalTag = _extractTag(personaGlobalV1Map, 'global_tag');
    final String bridgeTag = _extractTag(personaGlobalBridgeMap, 'bridge_tag');

    double aggScore =
        (masterScore * 0.6) + (globalScore * 0.3) + (bridgeValue * 0.1);
    aggScore = aggScore.clamp(0.0, 1.0);

    final String aggTag = masterTag.isNotEmpty
        ? _ascii(masterTag)
        : globalTag.isNotEmpty
        ? _ascii(globalTag)
        : _ascii(bridgeTag);

    return <String, Object>{
      'persona_aggregation_gateway_v1': <String, Object>{
        'agg_score': aggScore,
        'agg_tag': aggTag,
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

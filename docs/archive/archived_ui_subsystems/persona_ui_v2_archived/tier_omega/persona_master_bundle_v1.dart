class PersonaMasterBundleV1 {
  const PersonaMasterBundleV1({
    this.personaGlobalV1Map = const <String, Object>{},
    this.personaGlobalBridgeV1Map = const <String, Object>{},
    this.personaGlobalConsolidatorV1Map = const <String, Object>{},
    this.strategyFlowSurfaceMap = const <String, Object>{},
    this.sessionStrategyBehaviorSurfaceMap = const <String, Object>{},
    this.strategySurfaceMap = const <String, Object>{},
    this.sessionFlowSurfaceMap = const <String, Object>{},
  });

  PersonaMasterBundleV1.fromInputs({
    Map<String, Object?>? personaGlobalV1Map,
    Map<String, Object?>? personaGlobalBridgeV1Map,
    Map<String, Object?>? personaGlobalConsolidatorV1Map,
    Map<String, Object?>? strategyFlowSurfaceMap,
    Map<String, Object?>? sessionStrategyBehaviorSurfaceMap,
    Map<String, Object?>? strategySurfaceMap,
    Map<String, Object?>? sessionFlowSurfaceMap,
  }) : this(
         personaGlobalV1Map: _safe(personaGlobalV1Map),
         personaGlobalBridgeV1Map: _safe(personaGlobalBridgeV1Map),
         personaGlobalConsolidatorV1Map: _safe(personaGlobalConsolidatorV1Map),
         strategyFlowSurfaceMap: _safe(strategyFlowSurfaceMap),
         sessionStrategyBehaviorSurfaceMap: _safe(
           sessionStrategyBehaviorSurfaceMap,
         ),
         strategySurfaceMap: _safe(strategySurfaceMap),
         sessionFlowSurfaceMap: _safe(sessionFlowSurfaceMap),
       );

  final Map<String, Object> personaGlobalV1Map;
  final Map<String, Object> personaGlobalBridgeV1Map;
  final Map<String, Object> personaGlobalConsolidatorV1Map;
  final Map<String, Object> strategyFlowSurfaceMap;
  final Map<String, Object> sessionStrategyBehaviorSurfaceMap;
  final Map<String, Object> strategySurfaceMap;
  final Map<String, Object> sessionFlowSurfaceMap;

  Map<String, Object> build() {
    final double globalValue = _extract(personaGlobalV1Map, 'global_score');
    final String globalTag = _extractTag(personaGlobalV1Map, 'global_tag');
    final double bridgeValue = _extract(
      personaGlobalBridgeV1Map,
      'bridge_value',
    );
    final double consolidatorValue = _extract(
      personaGlobalConsolidatorV1Map,
      'consolidated_value',
    );
    final double strategyFlowValue = _extract(
      strategyFlowSurfaceMap,
      'surface_value',
    );
    final double behaviorValue = _extract(
      sessionStrategyBehaviorSurfaceMap,
      'final_strength',
    );
    final double strategyValue = _extract(strategySurfaceMap, 'flow_value');
    final double flowValue = _extract(sessionFlowSurfaceMap, 'flow_value');

    double masterScore =
        (globalValue * 0.4) +
        (strategyFlowValue * 0.2) +
        (behaviorValue * 0.15) +
        (strategyValue * 0.15) +
        (flowValue * 0.1);
    masterScore = masterScore.clamp(0.0, 1.0);

    final String tag = globalTag.isNotEmpty
        ? _ascii(globalTag)
        : _fallbackTag(
            _extractTag(personaGlobalBridgeV1Map, 'bridge_tag'),
            _extractTag(personaGlobalConsolidatorV1Map, 'consolidated_tag'),
            strategyFlowSurfaceMap,
            sessionStrategyBehaviorSurfaceMap,
            strategySurfaceMap,
            sessionFlowSurfaceMap,
          );

    return <String, Object>{
      'persona_master_bundle_v1': <String, Object>{
        'master_score': masterScore,
        'master_tag': tag,
        'ready': true,
      },
    };
  }

  static String _fallbackTag(
    String bridgeTag,
    String consolidatorTag,
    Map<String, Object> strategyFlowSurfaceMap,
    Map<String, Object> behaviorSurfaceMap,
    Map<String, Object> strategySurfaceMap,
    Map<String, Object> flowSurfaceMap,
  ) {
    if (bridgeTag.isNotEmpty) return _ascii(bridgeTag);
    if (consolidatorTag.isNotEmpty) return _ascii(consolidatorTag);
    final String flowTag = _extractTag(strategyFlowSurfaceMap, 'surface_tag');
    if (flowTag.isNotEmpty) return _ascii(flowTag);
    final String behaviorTag = _extractTag(behaviorSurfaceMap, 'final_route');
    if (behaviorTag.isNotEmpty) return _ascii(behaviorTag);
    final String strategyTag = _extractTag(strategySurfaceMap, 'flow_tag');
    if (strategyTag.isNotEmpty) return _ascii(strategyTag);
    final String flowSurfaceTag = _extractTag(flowSurfaceMap, 'flow_tag');
    return _ascii(flowSurfaceTag);
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

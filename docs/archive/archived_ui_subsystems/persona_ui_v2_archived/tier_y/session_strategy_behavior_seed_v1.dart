class SessionStrategyBehaviorSeedV1 {
  const SessionStrategyBehaviorSeedV1({
    this.strategyRouterMap = const <String, Object>{},
    this.strategyBridgeMap = const <String, Object>{},
    this.sessionFlowSurfaceMap = const <String, Object>{},
  });

  SessionStrategyBehaviorSeedV1.fromInputs({
    Map<String, Object?>? strategyRouterMap,
    Map<String, Object?>? strategyBridgeMap,
    Map<String, Object?>? sessionFlowSurfaceMap,
  }) : this(
         strategyRouterMap: _safe(strategyRouterMap),
         strategyBridgeMap: _safe(strategyBridgeMap),
         sessionFlowSurfaceMap: _safe(sessionFlowSurfaceMap),
       );

  final Map<String, Object> strategyRouterMap;
  final Map<String, Object> strategyBridgeMap;
  final Map<String, Object> sessionFlowSurfaceMap;

  Map<String, Object> build() {
    final double routerValue = _extract(strategyRouterMap, 'route_value');
    final double bridgeValue = _extract(strategyBridgeMap, 'bridge_value');
    final double flowValue = _extract(sessionFlowSurfaceMap, 'flow_value');
    final String routerTag = (_extractTag(strategyRouterMap, 'route_tag'));
    final String bridgeTag = (_extractTag(strategyBridgeMap, 'bridge_tag'));

    double seedValue =
        (routerValue * 0.5) + (bridgeValue * 0.3) + (flowValue * 0.2);
    seedValue = seedValue.clamp(0.0, 1.0);

    final String seedTag = '${_ascii(routerTag)}_${_ascii(bridgeTag)}'
        .replaceAll('__', '_')
        .trim();

    return <String, Object>{
      'session_strategy_behavior_seed_v1': <String, Object>{
        'seed_value': seedValue,
        'seed_tag': seedTag.isEmpty ? '' : seedTag,
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

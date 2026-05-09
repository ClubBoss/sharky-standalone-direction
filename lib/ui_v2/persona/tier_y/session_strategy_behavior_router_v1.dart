class SessionStrategyBehaviorRouterV1 {
  const SessionStrategyBehaviorRouterV1({
    this.strategyBehaviorBridgeMap = const <String, Object>{},
    this.strategyRouterMap = const <String, Object>{},
    this.sessionFlowRouterMap = const <String, Object>{},
  });

  SessionStrategyBehaviorRouterV1.fromInputs({
    Map<String, Object?>? strategyBehaviorBridgeMap,
    Map<String, Object?>? strategyRouterMap,
    Map<String, Object?>? sessionFlowRouterMap,
  }) : this(
         strategyBehaviorBridgeMap: _safe(strategyBehaviorBridgeMap),
         strategyRouterMap: _safe(strategyRouterMap),
         sessionFlowRouterMap: _safe(sessionFlowRouterMap),
       );

  final Map<String, Object> strategyBehaviorBridgeMap;
  final Map<String, Object> strategyRouterMap;
  final Map<String, Object> sessionFlowRouterMap;

  Map<String, Object> build() {
    final double bridgeValue = _extract(strategyBehaviorBridgeMap, 'value');
    final double strategyStrength = _extract(strategyRouterMap, 'route_value');
    final double flowStrength = _extract(
      sessionFlowRouterMap,
      'route_strength',
    );
    final String bridgeTag = _extractTag(strategyBehaviorBridgeMap, 'tag');
    final String strategyRoute = _extractTag(strategyRouterMap, 'route_tag');
    final String flowRoute = _extractTag(sessionFlowRouterMap, 'route_tag');

    double behaviorStrength =
        (bridgeValue * 0.5) + (strategyStrength * 0.3) + (flowStrength * 0.2);
    behaviorStrength = behaviorStrength.clamp(0.0, 1.0);

    final String behaviorRoute = [
      _ascii(bridgeTag),
      _ascii(strategyRoute),
      _ascii(flowRoute),
    ].where((part) => part.isNotEmpty).join('_').replaceAll('__', '_');

    return <String, Object>{
      'session_strategy_behavior_router_v1': <String, Object>{
        'behavior_strength': behaviorStrength,
        'behavior_route': behaviorRoute,
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

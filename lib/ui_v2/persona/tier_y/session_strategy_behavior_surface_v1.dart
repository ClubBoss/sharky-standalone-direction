class SessionStrategyBehaviorSurfaceV1 {
  const SessionStrategyBehaviorSurfaceV1({
    this.strategyBehaviorRouterMap = const <String, Object>{},
    this.strategyBehaviorBridgeMap = const <String, Object>{},
  });

  SessionStrategyBehaviorSurfaceV1.fromInputs({
    Map<String, Object?>? strategyBehaviorRouterMap,
    Map<String, Object?>? strategyBehaviorBridgeMap,
  }) : this(
         strategyBehaviorRouterMap: _safe(strategyBehaviorRouterMap),
         strategyBehaviorBridgeMap: _safe(strategyBehaviorBridgeMap),
       );

  final Map<String, Object> strategyBehaviorRouterMap;
  final Map<String, Object> strategyBehaviorBridgeMap;

  Map<String, Object> build() {
    final double behaviorStrength = _extract(
      strategyBehaviorRouterMap,
      'behavior_strength',
    );
    final double bridgeValue = _extract(strategyBehaviorBridgeMap, 'value');
    final String behaviorRoute = _extractTag(
      strategyBehaviorRouterMap,
      'behavior_route',
    );
    final String bridgeTag = _extractTag(strategyBehaviorBridgeMap, 'tag');

    double finalStrength = (behaviorStrength * 0.6) + (bridgeValue * 0.4);
    finalStrength = finalStrength.clamp(0.0, 1.0);

    final String finalRoute = '${_ascii(behaviorRoute)}_${_ascii(bridgeTag)}'
        .replaceAll('__', '_')
        .trim();

    return <String, Object>{
      'session_strategy_behavior_surface_v1': <String, Object>{
        'final_strength': finalStrength,
        'final_route': finalRoute,
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

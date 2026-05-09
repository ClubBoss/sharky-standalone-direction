class SessionStrategyBehaviorBridgeV1 {
  const SessionStrategyBehaviorBridgeV1({
    this.strategyBehaviorConsolidatorMap = const <String, Object>{},
    this.sessionFlowRouterMap = const <String, Object>{},
    this.strategyRouterMap = const <String, Object>{},
  });

  SessionStrategyBehaviorBridgeV1.fromInputs({
    Map<String, Object?>? strategyBehaviorConsolidatorMap,
    Map<String, Object?>? sessionFlowRouterMap,
    Map<String, Object?>? strategyRouterMap,
  }) : this(
         strategyBehaviorConsolidatorMap: _safe(
           strategyBehaviorConsolidatorMap,
         ),
         sessionFlowRouterMap: _safe(sessionFlowRouterMap),
         strategyRouterMap: _safe(strategyRouterMap),
       );

  final Map<String, Object> strategyBehaviorConsolidatorMap;
  final Map<String, Object> sessionFlowRouterMap;
  final Map<String, Object> strategyRouterMap;

  Map<String, Object> build() {
    final double consolidatorValue = _extract(
      strategyBehaviorConsolidatorMap,
      'value',
    );
    final double flowRouterStrength = _extract(
      sessionFlowRouterMap,
      'route_strength',
    );
    final double strategyRouterStrength = _extract(
      strategyRouterMap,
      'route_value',
    );
    final String consolidatorTag = _extractTag(
      strategyBehaviorConsolidatorMap,
      'tag',
    );
    final String flowRoute = _extractTag(sessionFlowRouterMap, 'route_tag');
    final String strategyRoute = _extractTag(strategyRouterMap, 'route_tag');

    double value =
        (consolidatorValue * 0.5) +
        (flowRouterStrength * 0.3) +
        (strategyRouterStrength * 0.2);
    value = value.clamp(0.0, 1.0);

    final String tag =
        '${_ascii(consolidatorTag)}_${_ascii(flowRoute)}_${_ascii(strategyRoute)}'
            .replaceAll('__', '_')
            .trim();

    return <String, Object>{
      'session_strategy_behavior_bridge_v1': <String, Object>{
        'value': value,
        'tag': tag.isEmpty ? '' : tag,
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

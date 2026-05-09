class SessionStrategyBehaviorEnvelopeV1 {
  const SessionStrategyBehaviorEnvelopeV1({
    this.strategyBehaviorSeedMap = const <String, Object>{},
    this.strategyRouterMap = const <String, Object>{},
    this.sessionFlowSurfaceMap = const <String, Object>{},
  });

  SessionStrategyBehaviorEnvelopeV1.fromInputs({
    Map<String, Object?>? strategyBehaviorSeedMap,
    Map<String, Object?>? strategyRouterMap,
    Map<String, Object?>? sessionFlowSurfaceMap,
  }) : this(
         strategyBehaviorSeedMap: _safe(strategyBehaviorSeedMap),
         strategyRouterMap: _safe(strategyRouterMap),
         sessionFlowSurfaceMap: _safe(sessionFlowSurfaceMap),
       );

  final Map<String, Object> strategyBehaviorSeedMap;
  final Map<String, Object> strategyRouterMap;
  final Map<String, Object> sessionFlowSurfaceMap;

  Map<String, Object> build() {
    final double seedValue = _extract(strategyBehaviorSeedMap, 'seed_value');
    final double routerValue = _extract(strategyRouterMap, 'route_value');
    final double flowValue = _extract(sessionFlowSurfaceMap, 'flow_value');
    final String seedTag = _extractTag(strategyBehaviorSeedMap, 'seed_tag');
    final String routerTag = _extractTag(strategyRouterMap, 'route_tag');

    double envelopeValue =
        (seedValue * 0.6) + (routerValue * 0.25) + (flowValue * 0.15);
    envelopeValue = envelopeValue.clamp(0.0, 1.0);
    final String envelopeTag = '${_ascii(seedTag)}_${_ascii(routerTag)}'
        .replaceAll('__', '_')
        .trim();

    return <String, Object>{
      'session_strategy_behavior_envelope_v1': <String, Object>{
        'envelope_value': envelopeValue,
        'envelope_tag': envelopeTag,
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

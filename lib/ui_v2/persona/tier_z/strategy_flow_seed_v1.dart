class StrategyFlowSeedV1 {
  const StrategyFlowSeedV1({
    this.sessionStrategyBehaviorSurfaceMap = const <String, Object>{},
    this.sessionStrategySurfaceMap = const <String, Object>{},
    this.sessionFlowSurfaceMap = const <String, Object>{},
  });

  StrategyFlowSeedV1.fromInputs({
    Map<String, Object?>? sessionStrategyBehaviorSurfaceMap,
    Map<String, Object?>? sessionStrategySurfaceMap,
    Map<String, Object?>? sessionFlowSurfaceMap,
  }) : this(
         sessionStrategyBehaviorSurfaceMap: _safe(
           sessionStrategyBehaviorSurfaceMap,
         ),
         sessionStrategySurfaceMap: _safe(sessionStrategySurfaceMap),
         sessionFlowSurfaceMap: _safe(sessionFlowSurfaceMap),
       );

  final Map<String, Object> sessionStrategyBehaviorSurfaceMap;
  final Map<String, Object> sessionStrategySurfaceMap;
  final Map<String, Object> sessionFlowSurfaceMap;

  Map<String, Object> build() {
    final double behaviorStrength = _extract(
      sessionStrategyBehaviorSurfaceMap,
      'final_strength',
    );
    final String behaviorRoute = _extractTag(
      sessionStrategyBehaviorSurfaceMap,
      'final_route',
    );
    final double strategyValue = _extract(
      sessionStrategySurfaceMap,
      'flow_value',
    );
    final String strategyTag = _extractTag(
      sessionStrategySurfaceMap,
      'flow_tag',
    );
    final double flowValue = _extract(sessionFlowSurfaceMap, 'flow_value');
    final String flowTag = _extractTag(sessionFlowSurfaceMap, 'flow_tag');

    double value =
        (behaviorStrength * 0.5) + (strategyValue * 0.3) + (flowValue * 0.2);
    value = value.clamp(0.0, 1.0);

    final String tag =
        '${_ascii(behaviorRoute)}_${_ascii(strategyTag)}_${_ascii(flowTag)}'
            .replaceAll('__', '_')
            .trim();

    return <String, Object>{
      'strategy_flow_seed_v1': <String, Object>{
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

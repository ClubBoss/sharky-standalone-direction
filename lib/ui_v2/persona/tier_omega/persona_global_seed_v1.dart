class PersonaGlobalSeedV1 {
  const PersonaGlobalSeedV1({
    this.strategyFlowSurfaceMap = const <String, Object>{},
    this.sessionStrategyBehaviorSurfaceMap = const <String, Object>{},
    this.sessionStrategySurfaceMap = const <String, Object>{},
  });

  PersonaGlobalSeedV1.fromInputs({
    Map<String, Object?>? strategyFlowSurfaceMap,
    Map<String, Object?>? sessionStrategyBehaviorSurfaceMap,
    Map<String, Object?>? sessionStrategySurfaceMap,
  }) : this(
         strategyFlowSurfaceMap: _safe(strategyFlowSurfaceMap),
         sessionStrategyBehaviorSurfaceMap: _safe(
           sessionStrategyBehaviorSurfaceMap,
         ),
         sessionStrategySurfaceMap: _safe(sessionStrategySurfaceMap),
       );

  final Map<String, Object> strategyFlowSurfaceMap;
  final Map<String, Object> sessionStrategyBehaviorSurfaceMap;
  final Map<String, Object> sessionStrategySurfaceMap;

  Map<String, Object> build() {
    final double zValue = _extract(strategyFlowSurfaceMap, 'surface_value');
    final String zTag = _extractTag(strategyFlowSurfaceMap, 'surface_tag');
    final double yValue = _extract(
      sessionStrategyBehaviorSurfaceMap,
      'final_strength',
    );
    final String yTag = _extractTag(
      sessionStrategyBehaviorSurfaceMap,
      'final_route',
    );
    final double vValue = _extract(sessionStrategySurfaceMap, 'flow_value');
    final String vTag = _extractTag(sessionStrategySurfaceMap, 'flow_tag');

    double value = (zValue * 0.5) + (yValue * 0.3) + (vValue * 0.2);
    value = value.clamp(0.0, 1.0);

    final String tag = zTag.isNotEmpty
        ? _ascii(zTag)
        : yTag.isNotEmpty
        ? _ascii(yTag)
        : _ascii(vTag);

    return <String, Object>{
      'persona_global_seed_v1': <String, Object>{
        'global_tag': tag,
        'global_value': value,
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

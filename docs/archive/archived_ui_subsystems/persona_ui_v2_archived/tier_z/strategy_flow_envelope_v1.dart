class StrategyFlowEnvelopeV1 {
  const StrategyFlowEnvelopeV1({
    this.strategyFlowSeedMap = const <String, Object>{},
    this.sessionFlowSurfaceMap = const <String, Object>{},
    this.sessionStrategySurfaceMap = const <String, Object>{},
  });

  StrategyFlowEnvelopeV1.fromInputs({
    Map<String, Object?>? strategyFlowSeedMap,
    Map<String, Object?>? sessionFlowSurfaceMap,
    Map<String, Object?>? sessionStrategySurfaceMap,
  }) : this(
         strategyFlowSeedMap: _safe(strategyFlowSeedMap),
         sessionFlowSurfaceMap: _safe(sessionFlowSurfaceMap),
         sessionStrategySurfaceMap: _safe(sessionStrategySurfaceMap),
       );

  final Map<String, Object> strategyFlowSeedMap;
  final Map<String, Object> sessionFlowSurfaceMap;
  final Map<String, Object> sessionStrategySurfaceMap;

  Map<String, Object> build() {
    final double seedValue = _extract(strategyFlowSeedMap, 'value');
    final String seedTag = _extractTag(strategyFlowSeedMap, 'tag');
    final double flowValue = _extract(sessionFlowSurfaceMap, 'flow_value');
    final String flowTag = _extractTag(sessionFlowSurfaceMap, 'flow_tag');
    final double strategyValue = _extract(
      sessionStrategySurfaceMap,
      'flow_value',
    );
    final String strategyTag = _extractTag(
      sessionStrategySurfaceMap,
      'flow_tag',
    );

    double value =
        (seedValue * 0.5) + (flowValue * 0.3) + (strategyValue * 0.2);
    value = value.clamp(0.0, 1.0);
    final String tag =
        '${_ascii(seedTag)}_${_ascii(flowTag)}_${_ascii(strategyTag)}'
            .replaceAll('__', '_')
            .trim();

    return <String, Object>{
      'strategy_flow_envelope_v1': <String, Object>{
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

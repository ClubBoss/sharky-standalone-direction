class StrategyConsolidatorV1 {
  const StrategyConsolidatorV1({
    this.adaptiveStrategySeedMap = const <String, Object>{},
    this.strategyEnvelopeMap = const <String, Object>{},
    this.sessionStrategyConsolidatorMap = const <String, Object>{},
  });

  StrategyConsolidatorV1.fromInputs({
    Map<String, Object?>? adaptiveStrategySeedMap,
    Map<String, Object?>? strategyEnvelopeMap,
    Map<String, Object?>? sessionStrategyConsolidatorMap,
  }) : this(
         adaptiveStrategySeedMap: _safe(adaptiveStrategySeedMap),
         strategyEnvelopeMap: _safe(strategyEnvelopeMap),
         sessionStrategyConsolidatorMap: _safe(sessionStrategyConsolidatorMap),
       );

  final Map<String, Object> adaptiveStrategySeedMap;
  final Map<String, Object> strategyEnvelopeMap;
  final Map<String, Object> sessionStrategyConsolidatorMap;

  Map<String, Object> build() {
    final double adaptiveValue = _extract(
      adaptiveStrategySeedMap,
      'seed_value',
    );
    final double envelopeValue = _extract(strategyEnvelopeMap, 'value');
    final double consolidatorValue = _extract(
      sessionStrategyConsolidatorMap,
      'consolidated_value',
    );

    double value =
        (adaptiveValue * 0.4) +
        (envelopeValue * 0.4) +
        (consolidatorValue * 0.2);
    value = value.clamp(0.0, 1.0);
    String tag = 'low';
    if (value >= 0.75) {
      tag = 'high';
    } else if (value >= 0.45) {
      tag = 'mid';
    }

    return <String, Object>{
      'strategy_consolidator_v1': <String, Object>{
        'value': value,
        'tag': _ascii(tag),
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

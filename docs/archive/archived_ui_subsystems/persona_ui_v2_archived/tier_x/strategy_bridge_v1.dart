class StrategyBridgeV1 {
  const StrategyBridgeV1({
    this.strategyConsolidatorMap = const <String, Object>{},
    this.strategyEnvelopeMap = const <String, Object>{},
    this.adaptiveStrategySeedMap = const <String, Object>{},
  });

  StrategyBridgeV1.fromInputs({
    Map<String, Object?>? strategyConsolidatorMap,
    Map<String, Object?>? strategyEnvelopeMap,
    Map<String, Object?>? adaptiveStrategySeedMap,
  }) : this(
         strategyConsolidatorMap: _safe(strategyConsolidatorMap),
         strategyEnvelopeMap: _safe(strategyEnvelopeMap),
         adaptiveStrategySeedMap: _safe(adaptiveStrategySeedMap),
       );

  final Map<String, Object> strategyConsolidatorMap;
  final Map<String, Object> strategyEnvelopeMap;
  final Map<String, Object> adaptiveStrategySeedMap;

  Map<String, Object> build() {
    final double consolidatorValue = _extract(strategyConsolidatorMap, 'value');
    final double envelopeValue = _extract(strategyEnvelopeMap, 'value');
    final double seedValue = _extract(adaptiveStrategySeedMap, 'seed_value');

    double bridgeValue =
        (consolidatorValue * 0.5) + (envelopeValue * 0.3) + (seedValue * 0.2);
    bridgeValue = bridgeValue.clamp(0.0, 1.0);

    String tag = 'bridge_low';
    if (bridgeValue >= 0.75) {
      tag = 'bridge_high';
    } else if (bridgeValue >= 0.45) {
      tag = 'bridge_mid';
    }

    return <String, Object>{
      'strategy_bridge_v1': <String, Object>{
        'bridge_value': bridgeValue,
        'bridge_tag': _ascii(tag),
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

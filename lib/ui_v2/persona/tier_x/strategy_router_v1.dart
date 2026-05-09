class StrategyRouterV1 {
  const StrategyRouterV1({
    this.strategyBridgeMap = const <String, Object>{},
    this.strategyConsolidatorMap = const <String, Object>{},
    this.sessionStrategyEnvelopeMap = const <String, Object>{},
  });

  StrategyRouterV1.fromInputs({
    Map<String, Object?>? strategyBridgeMap,
    Map<String, Object?>? strategyConsolidatorMap,
    Map<String, Object?>? sessionStrategyEnvelopeMap,
  }) : this(
         strategyBridgeMap: _safe(strategyBridgeMap),
         strategyConsolidatorMap: _safe(strategyConsolidatorMap),
         sessionStrategyEnvelopeMap: _safe(sessionStrategyEnvelopeMap),
       );

  final Map<String, Object> strategyBridgeMap;
  final Map<String, Object> strategyConsolidatorMap;
  final Map<String, Object> sessionStrategyEnvelopeMap;

  Map<String, Object> build() {
    final double bridgeValue = _extract(strategyBridgeMap, 'bridge_value');
    final double consolidatorValue = _extract(strategyConsolidatorMap, 'value');
    final double envelopeValue = _extract(sessionStrategyEnvelopeMap, 'value');
    final String bridgeTag = _extractTag(strategyBridgeMap, 'bridge_tag');
    final String envelopeTag = _extractTag(sessionStrategyEnvelopeMap, 'tag');

    double routeValue =
        (bridgeValue * 0.5) + (consolidatorValue * 0.3) + (envelopeValue * 0.2);
    routeValue = routeValue.clamp(0.0, 1.0);

    final String routeTag = '${_ascii(bridgeTag)}_${_ascii(envelopeTag)}'
        .replaceAll('__', '_');

    return <String, Object>{
      'strategy_router_v1': <String, Object>{
        'route_tag': routeTag,
        'route_value': routeValue,
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

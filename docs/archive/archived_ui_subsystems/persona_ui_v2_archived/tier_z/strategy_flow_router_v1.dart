class StrategyFlowRouterV1 {
  const StrategyFlowRouterV1({
    this.strategyFlowBridgeMap = const <String, Object>{},
    this.strategyFlowConsolidatorMap = const <String, Object>{},
    this.strategyFlowEnvelopeMap = const <String, Object>{},
  });

  StrategyFlowRouterV1.fromInputs({
    Map<String, Object?>? strategyFlowBridgeMap,
    Map<String, Object?>? strategyFlowConsolidatorMap,
    Map<String, Object?>? strategyFlowEnvelopeMap,
  }) : this(
         strategyFlowBridgeMap: _safe(strategyFlowBridgeMap),
         strategyFlowConsolidatorMap: _safe(strategyFlowConsolidatorMap),
         strategyFlowEnvelopeMap: _safe(strategyFlowEnvelopeMap),
       );

  final Map<String, Object> strategyFlowBridgeMap;
  final Map<String, Object> strategyFlowConsolidatorMap;
  final Map<String, Object> strategyFlowEnvelopeMap;

  Map<String, Object> build() {
    final double bridgeValue = _extract(strategyFlowBridgeMap, 'value');
    final double consolidatorValue = _extract(
      strategyFlowConsolidatorMap,
      'value',
    );
    final double envelopeValue = _extract(strategyFlowEnvelopeMap, 'value');
    final String bridgeTag = _extractTag(strategyFlowBridgeMap, 'tag');
    final String consolidatorTag = _extractTag(
      strategyFlowConsolidatorMap,
      'tag',
    );
    final String envelopeTag = _extractTag(strategyFlowEnvelopeMap, 'tag');

    double routeStrength =
        (bridgeValue * 0.5) + (consolidatorValue * 0.3) + (envelopeValue * 0.2);
    routeStrength = routeStrength.clamp(0.0, 1.0);

    final String routeTag = [
      _ascii(bridgeTag),
      _ascii(consolidatorTag),
      _ascii(envelopeTag),
    ].where((part) => part.isNotEmpty).join('_').replaceAll('__', '_');

    return <String, Object>{
      'strategy_flow_router_v1': <String, Object>{
        'route_tag': routeTag,
        'route_strength': routeStrength,
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

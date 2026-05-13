class StrategyFlowConsolidatorV1 {
  const StrategyFlowConsolidatorV1({
    this.strategyFlowSeedMap = const <String, Object>{},
    this.strategyFlowEnvelopeMap = const <String, Object>{},
  });

  StrategyFlowConsolidatorV1.fromInputs({
    Map<String, Object?>? strategyFlowSeedMap,
    Map<String, Object?>? strategyFlowEnvelopeMap,
  }) : this(
         strategyFlowSeedMap: _safe(strategyFlowSeedMap),
         strategyFlowEnvelopeMap: _safe(strategyFlowEnvelopeMap),
       );

  final Map<String, Object> strategyFlowSeedMap;
  final Map<String, Object> strategyFlowEnvelopeMap;

  Map<String, Object> build() {
    final double seedValue = _extract(strategyFlowSeedMap, 'value');
    final double envelopeValue = _extract(strategyFlowEnvelopeMap, 'value');
    final String envelopeTag = _extractTag(strategyFlowEnvelopeMap, 'tag');
    final String seedTag = _extractTag(strategyFlowSeedMap, 'tag');

    double value = (seedValue * 0.4) + (envelopeValue * 0.6);
    value = value.clamp(0.0, 1.0);

    final String tag = envelopeTag.isNotEmpty
        ? _ascii(envelopeTag)
        : _ascii(seedTag);

    return <String, Object>{
      'strategy_flow_consolidator_v1': <String, Object>{
        'value': value,
        'tag': tag,
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

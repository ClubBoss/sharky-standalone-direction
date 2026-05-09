class SessionStrategyBehaviorConsolidatorV1 {
  const SessionStrategyBehaviorConsolidatorV1({
    this.strategyBehaviorSeedMap = const <String, Object>{},
    this.strategyBehaviorEnvelopeMap = const <String, Object>{},
  });

  SessionStrategyBehaviorConsolidatorV1.fromInputs({
    Map<String, Object?>? strategyBehaviorSeedMap,
    Map<String, Object?>? strategyBehaviorEnvelopeMap,
  }) : this(
         strategyBehaviorSeedMap: _safe(strategyBehaviorSeedMap),
         strategyBehaviorEnvelopeMap: _safe(strategyBehaviorEnvelopeMap),
       );

  final Map<String, Object> strategyBehaviorSeedMap;
  final Map<String, Object> strategyBehaviorEnvelopeMap;

  Map<String, Object> build() {
    final double seedValue = _extract(strategyBehaviorSeedMap, 'seed_value');
    final double envelopeValue = _extract(
      strategyBehaviorEnvelopeMap,
      'envelope_value',
    );
    final String seedTag = _extractTag(strategyBehaviorSeedMap, 'seed_tag');
    final String envelopeTag = _extractTag(
      strategyBehaviorEnvelopeMap,
      'envelope_tag',
    );

    double value = (seedValue * 0.5) + (envelopeValue * 0.5);
    value = value.clamp(0.0, 1.0);
    final String tag = '${_ascii(seedTag)}_${_ascii(envelopeTag)}'
        .replaceAll('__', '_')
        .trim();

    return <String, Object>{
      'session_strategy_behavior_consolidator_v1': <String, Object>{
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

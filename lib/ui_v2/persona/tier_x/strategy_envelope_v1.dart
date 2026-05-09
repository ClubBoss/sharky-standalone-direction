class StrategyEnvelopeV1 {
  const StrategyEnvelopeV1({
    this.adaptiveStrategySeedMap = const <String, Object>{},
    this.sessionStrategyEnvelopeMap = const <String, Object>{},
    this.sessionStrategySeedMap = const <String, Object>{},
  });

  StrategyEnvelopeV1.fromInputs({
    Map<String, Object?>? adaptiveStrategySeedMap,
    Map<String, Object?>? sessionStrategyEnvelopeMap,
    Map<String, Object?>? sessionStrategySeedMap,
  }) : this(
         adaptiveStrategySeedMap: _safe(adaptiveStrategySeedMap),
         sessionStrategyEnvelopeMap: _safe(sessionStrategyEnvelopeMap),
         sessionStrategySeedMap: _safe(sessionStrategySeedMap),
       );

  final Map<String, Object> adaptiveStrategySeedMap;
  final Map<String, Object> sessionStrategyEnvelopeMap;
  final Map<String, Object> sessionStrategySeedMap;

  Map<String, Object> build() {
    final double adaptiveValue = _extract(
      adaptiveStrategySeedMap,
      'seed_value',
    );
    final double envelopeValue = _extract(
      sessionStrategyEnvelopeMap,
      'envelope_value',
    );
    final double seedValue = _extract(sessionStrategySeedMap, 'seed_value');

    double value =
        (adaptiveValue * 0.5) + (envelopeValue * 0.3) + (seedValue * 0.2);
    value = value.clamp(0.0, 1.0);

    String tag = 'low';
    if (value >= 0.75) {
      tag = 'high';
    } else if (value >= 0.45) {
      tag = 'mid';
    }

    return <String, Object>{
      'strategy_envelope_v1': <String, Object>{
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

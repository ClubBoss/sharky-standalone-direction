class AdaptiveStrategySeedV1 {
  const AdaptiveStrategySeedV1({
    this.strategySurfaceMap = const <String, Object>{},
    this.sessionFlowSurfaceMap = const <String, Object>{},
    this.adaptiveFrequencyMap = const <String, Object>{},
  });

  AdaptiveStrategySeedV1.fromInputs({
    Map<String, Object?>? strategySurfaceMap,
    Map<String, Object?>? sessionFlowSurfaceMap,
    Map<String, Object?>? adaptiveFrequencyMap,
  }) : this(
         strategySurfaceMap: _safe(strategySurfaceMap),
         sessionFlowSurfaceMap: _safe(sessionFlowSurfaceMap),
         adaptiveFrequencyMap: _safe(adaptiveFrequencyMap),
       );

  final Map<String, Object> strategySurfaceMap;
  final Map<String, Object> sessionFlowSurfaceMap;
  final Map<String, Object> adaptiveFrequencyMap;

  Map<String, Object> build() {
    final double strategyValue = _extractScore(
      strategySurfaceMap['session_strategy_surface_v1']
          as Map<String, Object?>?,
      'flow_value',
    );
    final double sessionFlowValue = _extractScore(
      sessionFlowSurfaceMap['session_flow_surface_v1'] as Map<String, Object?>?,
      'flow_value',
    );
    final double frequencyValue = _extractScore(
      adaptiveFrequencyMap['adaptive_frequency_v1'] as Map<String, Object?>?,
      'frequency_value',
    );

    double seedValue =
        (strategyValue * 0.5) +
        (sessionFlowValue * 0.3) +
        (frequencyValue * 0.2);
    seedValue = seedValue.clamp(0.0, 1.0);

    String seedTag = 'low';
    if (seedValue >= 0.7) {
      seedTag = 'high';
    } else if (seedValue >= 0.4) {
      seedTag = 'mid';
    }

    return <String, Object>{
      'adaptive_strategy_seed_v1': <String, Object>{
        'seed_value': seedValue,
        'seed_tag': _ascii(seedTag),
        'ready': true,
      },
    };
  }

  static double _extractScore(Map<String, Object?>? body, String key) {
    if (body == null) return 0.0;
    final Object? raw = body[key];
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

class SessionFlowSeedV1 {
  const SessionFlowSeedV1({
    this.timingBridgeMap = const <String, Object>{},
    this.adaptiveFrequencyMap = const <String, Object>{},
    this.rhythmConsolidatorMap = const <String, Object>{},
  });

  SessionFlowSeedV1.fromInputs({
    Map<String, Object?>? timingBridgeMap,
    Map<String, Object?>? adaptiveFrequencyMap,
    Map<String, Object?>? rhythmConsolidatorMap,
  }) : this(
         timingBridgeMap: _safe(timingBridgeMap),
         adaptiveFrequencyMap: _safe(adaptiveFrequencyMap),
         rhythmConsolidatorMap: _safe(rhythmConsolidatorMap),
       );

  final Map<String, Object> timingBridgeMap;
  final Map<String, Object> adaptiveFrequencyMap;
  final Map<String, Object> rhythmConsolidatorMap;

  Map<String, Object> build() {
    final double timingValue = _extractScore(
      timingBridgeMap['timing_bridge_v1'] as Map<String, Object?>?,
      'bridge_value',
    );
    final double frequencyValue = _extractScore(
      adaptiveFrequencyMap['adaptive_frequency_v1'] as Map<String, Object?>?,
      'frequency_value',
    );
    final double rhythmValue = _extractScore(
      rhythmConsolidatorMap['rhythm_consolidator_v1'] as Map<String, Object?>?,
      'consolidated_value',
    );

    double seedValue =
        (timingValue * 0.4) + (frequencyValue * 0.3) + (rhythmValue * 0.3);
    seedValue = seedValue.clamp(0.0, 1.0);

    String seedTag = 'flow_slow';
    if (seedValue >= 0.75) {
      seedTag = 'flow_fast';
    } else if (seedValue >= 0.40) {
      seedTag = 'flow_balanced';
    }

    return <String, Object>{
      'session_flow_seed_v1': <String, Object>{
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

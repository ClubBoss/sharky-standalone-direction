class SessionStrategySeedV1 {
  const SessionStrategySeedV1({
    this.sessionFlowSurfaceMap = const <String, Object>{},
    this.adaptiveFrequencyMap = const <String, Object>{},
    this.personaRhythmSignalMap = const <String, Object>{},
    this.timingConsolidatorMap = const <String, Object>{},
  });

  SessionStrategySeedV1.fromInputs({
    Map<String, Object?>? sessionFlowSurfaceMap,
    Map<String, Object?>? adaptiveFrequencyMap,
    Map<String, Object?>? personaRhythmSignalMap,
    Map<String, Object?>? timingConsolidatorMap,
  }) : this(
         sessionFlowSurfaceMap: _safe(sessionFlowSurfaceMap),
         adaptiveFrequencyMap: _safe(adaptiveFrequencyMap),
         personaRhythmSignalMap: _safe(personaRhythmSignalMap),
         timingConsolidatorMap: _safe(timingConsolidatorMap),
       );

  final Map<String, Object> sessionFlowSurfaceMap;
  final Map<String, Object> adaptiveFrequencyMap;
  final Map<String, Object> personaRhythmSignalMap;
  final Map<String, Object> timingConsolidatorMap;

  Map<String, Object> build() {
    final double flow = _extractScore(
      sessionFlowSurfaceMap['session_flow_surface_v1'] as Map<String, Object?>?,
      'flow_value',
    );
    final double frequency = _extractScore(
      adaptiveFrequencyMap['adaptive_frequency_v1'] as Map<String, Object?>?,
      'frequency_value',
    );
    final double rhythm = _extractScore(
      personaRhythmSignalMap['persona_rhythm_signal_v1']
          as Map<String, Object?>?,
      'rhythm_intensity',
    );
    final double timing = _extractScore(
      timingConsolidatorMap['timing_consolidator_v1'] as Map<String, Object?>?,
      'consolidated_value',
    );

    double seedValue =
        (flow * 0.35) + (frequency * 0.25) + (rhythm * 0.20) + (timing * 0.20);
    seedValue = seedValue.clamp(0.0, 1.0);

    String seedTag = 'low';
    if (seedValue >= 0.70) {
      seedTag = 'high';
    } else if (seedValue >= 0.40) {
      seedTag = 'mid';
    }

    return <String, Object>{
      'session_strategy_seed_v1': <String, Object>{
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

class SessionStrategyEnvelopeV1 {
  const SessionStrategyEnvelopeV1({
    this.sessionStrategySeedMap = const <String, Object>{},
    this.adaptiveFrequencyMap = const <String, Object>{},
    this.personaRhythmSignalMap = const <String, Object>{},
    this.timingEnvelopeMap = const <String, Object>{},
  });

  SessionStrategyEnvelopeV1.fromInputs({
    Map<String, Object?>? sessionStrategySeedMap,
    Map<String, Object?>? adaptiveFrequencyMap,
    Map<String, Object?>? personaRhythmSignalMap,
    Map<String, Object?>? timingEnvelopeMap,
  }) : this(
         sessionStrategySeedMap: _safe(sessionStrategySeedMap),
         adaptiveFrequencyMap: _safe(adaptiveFrequencyMap),
         personaRhythmSignalMap: _safe(personaRhythmSignalMap),
         timingEnvelopeMap: _safe(timingEnvelopeMap),
       );

  final Map<String, Object> sessionStrategySeedMap;
  final Map<String, Object> adaptiveFrequencyMap;
  final Map<String, Object> personaRhythmSignalMap;
  final Map<String, Object> timingEnvelopeMap;

  Map<String, Object> build() {
    final double seedValue = _extractScore(
      sessionStrategySeedMap['session_strategy_seed_v1']
          as Map<String, Object?>?,
      'seed_value',
    );
    final double frequencyValue = _extractScore(
      adaptiveFrequencyMap['adaptive_frequency_v1'] as Map<String, Object?>?,
      'frequency_value',
    );
    final double rhythmValue = _extractScore(
      personaRhythmSignalMap['persona_rhythm_signal_v1']
          as Map<String, Object?>?,
      'rhythm_intensity',
    );
    final double timingValue = _extractScore(
      timingEnvelopeMap['timing_envelope_v1'] as Map<String, Object?>?,
      'envelope_value',
    );

    double envelopeValue =
        (seedValue * 0.5) +
        (frequencyValue * 0.2) +
        (rhythmValue * 0.15) +
        (timingValue * 0.15);
    envelopeValue = envelopeValue.clamp(0.0, 1.0);

    String envelopeTag = 'low';
    if (envelopeValue >= 0.70) {
      envelopeTag = 'high';
    } else if (envelopeValue >= 0.40) {
      envelopeTag = 'mid';
    }

    return <String, Object>{
      'session_strategy_envelope_v1': <String, Object>{
        'envelope_value': envelopeValue,
        'envelope_tag': _ascii(envelopeTag),
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

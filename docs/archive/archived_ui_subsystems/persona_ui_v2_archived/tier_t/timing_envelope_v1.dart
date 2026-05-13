class TimingEnvelopeV1 {
  const TimingEnvelopeV1({
    this.timingSeedMap = const <String, Object>{},
    this.adaptiveFrequencyMap = const <String, Object>{},
    this.personaInfluenceSurfaceMap = const <String, Object>{},
  });

  TimingEnvelopeV1.fromInputs({
    Map<String, Object?>? timingSeedMap,
    Map<String, Object?>? adaptiveFrequencyMap,
    Map<String, Object?>? personaInfluenceSurfaceMap,
  }) : this(
         timingSeedMap: _safe(timingSeedMap),
         adaptiveFrequencyMap: _safe(adaptiveFrequencyMap),
         personaInfluenceSurfaceMap: _safe(personaInfluenceSurfaceMap),
       );

  final Map<String, Object> timingSeedMap;
  final Map<String, Object> adaptiveFrequencyMap;
  final Map<String, Object> personaInfluenceSurfaceMap;

  Map<String, Object> build() {
    final double seedValue = _extractScore(
      timingSeedMap['timing_seed_v1'] as Map<String, Object?>?,
      'seed_value',
    );
    final double adaptiveValue = _extractScore(
      adaptiveFrequencyMap['adaptive_frequency_v1'] as Map<String, Object?>?,
      'frequency_value',
    );
    final double influenceStrength = _extractScore(
      personaInfluenceSurfaceMap['persona_influence_surface_v1']
          as Map<String, Object?>?,
      'influence_strength',
    );

    double envelopeValue =
        (seedValue * 0.6) + (adaptiveValue * 0.25) + (influenceStrength * 0.15);
    envelopeValue = envelopeValue.clamp(0.0, 1.0);

    String envelopeTag = 'timing_soft';
    if (envelopeValue >= 0.80) {
      envelopeTag = 'timing_sharp';
    } else if (envelopeValue >= 0.45) {
      envelopeTag = 'timing_balanced';
    }

    return <String, Object>{
      'timing_envelope_v1': <String, Object>{
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

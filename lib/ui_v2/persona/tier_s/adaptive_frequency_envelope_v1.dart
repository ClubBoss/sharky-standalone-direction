class AdaptiveFrequencyEnvelopeV1 {
  const AdaptiveFrequencyEnvelopeV1({
    this.adaptiveFrequencyMap = const <String, Object>{},
    this.personaInfluenceSurfaceMap = const <String, Object>{},
    this.personaGrowthProfileMap = const <String, Object>{},
  });

  AdaptiveFrequencyEnvelopeV1.fromInputs({
    Map<String, Object?>? adaptiveFrequencyMap,
    Map<String, Object?>? personaInfluenceSurfaceMap,
    Map<String, Object?>? personaGrowthProfileMap,
  }) : this(
         adaptiveFrequencyMap: _safe(adaptiveFrequencyMap),
         personaInfluenceSurfaceMap: _safe(personaInfluenceSurfaceMap),
         personaGrowthProfileMap: _safe(personaGrowthProfileMap),
       );

  final Map<String, Object> adaptiveFrequencyMap;
  final Map<String, Object> personaInfluenceSurfaceMap;
  final Map<String, Object> personaGrowthProfileMap;

  Map<String, Object> build() {
    final double frequencyValue = _extractScore(
      adaptiveFrequencyMap['adaptive_frequency_v1'] as Map<String, Object?>?,
      'frequency_value',
    );
    final double influenceStrength = _extractScore(
      personaInfluenceSurfaceMap['persona_influence_surface_v1']
          as Map<String, Object?>?,
      'influence_strength',
    );
    final double growthScore = _extractScore(
      personaGrowthProfileMap['persona_growth_profile_v1']
          as Map<String, Object?>?,
      'profile_score',
    );

    double envelopeIntensity =
        (frequencyValue * 0.55) +
        (influenceStrength * 0.25) +
        (growthScore * 0.20);
    envelopeIntensity = envelopeIntensity.clamp(0.0, 1.0);

    String envelopeTag = 'envelope_low';
    if (envelopeIntensity >= 0.80) {
      envelopeTag = 'envelope_peak';
    } else if (envelopeIntensity >= 0.45) {
      envelopeTag = 'envelope_mid';
    }

    return <String, Object>{
      'adaptive_frequency_envelope_v1': <String, Object>{
        'envelope_intensity': envelopeIntensity,
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

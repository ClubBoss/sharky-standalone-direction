class PersonaAdaptiveSchedulerV1 {
  const PersonaAdaptiveSchedulerV1({
    this.personaInfluenceSurfaceMap = const <String, Object>{},
    this.personaGrowthProfileMap = const <String, Object>{},
    this.personaDifficultyBiasMap = const <String, Object>{},
  });

  PersonaAdaptiveSchedulerV1.fromInputs({
    Map<String, Object?>? personaInfluenceSurfaceMap,
    Map<String, Object?>? personaGrowthProfileMap,
    Map<String, Object?>? personaDifficultyBiasMap,
  }) : this(
         personaInfluenceSurfaceMap: _safe(personaInfluenceSurfaceMap),
         personaGrowthProfileMap: _safe(personaGrowthProfileMap),
         personaDifficultyBiasMap: _safe(personaDifficultyBiasMap),
       );

  final Map<String, Object> personaInfluenceSurfaceMap;
  final Map<String, Object> personaGrowthProfileMap;
  final Map<String, Object> personaDifficultyBiasMap;

  Map<String, Object> build() {
    final Map<String, Object?> influenceBody =
        personaInfluenceSurfaceMap['persona_influence_surface_v1']
            as Map<String, Object?>? ??
        <String, Object?>{};
    final Map<String, Object?> growthBody =
        personaGrowthProfileMap['persona_growth_profile_v1']
            as Map<String, Object?>? ??
        <String, Object?>{};
    final Map<String, Object?> difficultyBody =
        personaDifficultyBiasMap['persona_difficulty_bias_v1']
            as Map<String, Object?>? ??
        <String, Object?>{};

    final double influenceStrength = _extractScore(
      influenceBody,
      'influence_strength',
    );
    final double growthScore = _extractScore(growthBody, 'profile_score');
    final double difficultyScore = _extractScore(difficultyBody, 'difficulty');

    String mode = 'neutral';
    if (influenceStrength > 0.7) {
      mode = 'accelerate';
    } else if (difficultyScore > 0.6) {
      mode = 'assist';
    } else if (growthScore > 0.5) {
      mode = 'expand';
    }

    double intensity =
        (influenceStrength * 0.6) +
        (difficultyScore * 0.2) +
        (growthScore * 0.2);
    intensity = intensity.clamp(0.0, 1.0);

    return <String, Object>{
      'persona_adaptive_scheduler_v1': <String, Object>{
        'schedule_mode': _ascii(mode),
        'schedule_intensity': intensity,
        'ready': true,
      },
    };
  }

  static double _extractScore(Map<String, Object?> body, String key) {
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

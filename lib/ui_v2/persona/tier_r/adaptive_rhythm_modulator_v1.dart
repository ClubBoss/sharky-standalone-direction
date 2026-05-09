class AdaptiveRhythmModulatorV1 {
  const AdaptiveRhythmModulatorV1({
    this.personaRhythmSignalMap = const <String, Object>{},
    this.personaInfluenceSurfaceMap = const <String, Object>{},
    this.personaAdaptiveSchedulerMap = const <String, Object>{},
    this.personaGrowthProfileMap = const <String, Object>{},
  });

  AdaptiveRhythmModulatorV1.fromInputs({
    Map<String, Object?>? personaRhythmSignalMap,
    Map<String, Object?>? personaInfluenceSurfaceMap,
    Map<String, Object?>? personaAdaptiveSchedulerMap,
    Map<String, Object?>? personaGrowthProfileMap,
  }) : this(
         personaRhythmSignalMap: _safe(personaRhythmSignalMap),
         personaInfluenceSurfaceMap: _safe(personaInfluenceSurfaceMap),
         personaAdaptiveSchedulerMap: _safe(personaAdaptiveSchedulerMap),
         personaGrowthProfileMap: _safe(personaGrowthProfileMap),
       );

  final Map<String, Object> personaRhythmSignalMap;
  final Map<String, Object> personaInfluenceSurfaceMap;
  final Map<String, Object> personaAdaptiveSchedulerMap;
  final Map<String, Object> personaGrowthProfileMap;

  Map<String, Object> build() {
    final double rhythmIntensity = _extractScore(
      personaRhythmSignalMap['persona_rhythm_signal_v1']
          as Map<String, Object?>?,
      'rhythm_intensity',
    );
    final double influenceStrength = _extractScore(
      personaInfluenceSurfaceMap['persona_influence_surface_v1']
          as Map<String, Object?>?,
      'influence_strength',
    );
    final double schedulerIntensity = _extractScore(
      personaAdaptiveSchedulerMap['persona_adaptive_scheduler_v1']
          as Map<String, Object?>?,
      'schedule_intensity',
    );
    final double growthScore = _extractScore(
      personaGrowthProfileMap['persona_growth_profile_v1']
          as Map<String, Object?>?,
      'profile_score',
    );

    double modulatedRhythm =
        (rhythmIntensity * 0.4) +
        (influenceStrength * 0.3) +
        (schedulerIntensity * 0.2) +
        (growthScore * 0.1);
    modulatedRhythm = modulatedRhythm.clamp(0.0, 1.0);

    String modulatedTag = 'low_rhythm';
    if (modulatedRhythm >= 0.75) {
      modulatedTag = 'peak_rhythm';
    } else if (modulatedRhythm >= 0.45) {
      modulatedTag = 'stable_rhythm';
    }

    return <String, Object>{
      'adaptive_rhythm_modulator_v1': <String, Object>{
        'modulated_rhythm': modulatedRhythm,
        'modulated_tag': _ascii(modulatedTag),
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

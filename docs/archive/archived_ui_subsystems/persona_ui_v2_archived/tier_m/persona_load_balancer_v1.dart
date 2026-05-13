class PersonaLoadBalancerV1 {
  const PersonaLoadBalancerV1({
    this.personaAdaptiveSchedulerMap = const <String, Object>{},
    this.personaGrowthProfileMap = const <String, Object>{},
    this.personaDifficultyBiasMap = const <String, Object>{},
  });

  PersonaLoadBalancerV1.fromInputs({
    Map<String, Object?>? personaAdaptiveSchedulerMap,
    Map<String, Object?>? personaGrowthProfileMap,
    Map<String, Object?>? personaDifficultyBiasMap,
  }) : this(
         personaAdaptiveSchedulerMap: _safe(personaAdaptiveSchedulerMap),
         personaGrowthProfileMap: _safe(personaGrowthProfileMap),
         personaDifficultyBiasMap: _safe(personaDifficultyBiasMap),
       );

  final Map<String, Object> personaAdaptiveSchedulerMap;
  final Map<String, Object> personaGrowthProfileMap;
  final Map<String, Object> personaDifficultyBiasMap;

  Map<String, Object> build() {
    final Map<String, Object?> schedulerBody =
        personaAdaptiveSchedulerMap['persona_adaptive_scheduler_v1']
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

    final String mode =
        (schedulerBody['schedule_mode'] as String?)?.trim() ?? '';
    final double intensity = _extractScore(schedulerBody, 'schedule_intensity');
    final double growthScore = _extractScore(growthBody, 'profile_score');
    final double difficultyScore = _extractScore(difficultyBody, 'difficulty');

    String loadMode = 'neutral';
    if (mode == 'accelerate') {
      loadMode = 'high';
    } else if (mode == 'assist') {
      loadMode = 'medium';
    } else if (mode == 'expand') {
      loadMode = 'low';
    }

    double loadValue =
        (intensity * 0.5) + (difficultyScore * 0.3) + (growthScore * 0.2);
    loadValue = loadValue.clamp(0.0, 1.0);

    return <String, Object>{
      'persona_load_balancer_v1': <String, Object>{
        'load_mode': _ascii(loadMode),
        'load_value': loadValue,
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

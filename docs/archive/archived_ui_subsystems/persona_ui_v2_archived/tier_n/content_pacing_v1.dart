class ContentPacingV1 {
  const ContentPacingV1({
    this.personaLoadBalancerMap = const <String, Object>{},
    this.personaAdaptiveSchedulerMap = const <String, Object>{},
    this.personaDifficultyBiasMap = const <String, Object>{},
  });

  ContentPacingV1.fromInputs({
    Map<String, Object?>? personaLoadBalancerMap,
    Map<String, Object?>? personaAdaptiveSchedulerMap,
    Map<String, Object?>? personaDifficultyBiasMap,
  }) : this(
         personaLoadBalancerMap: _safe(personaLoadBalancerMap),
         personaAdaptiveSchedulerMap: _safe(personaAdaptiveSchedulerMap),
         personaDifficultyBiasMap: _safe(personaDifficultyBiasMap),
       );

  final Map<String, Object> personaLoadBalancerMap;
  final Map<String, Object> personaAdaptiveSchedulerMap;
  final Map<String, Object> personaDifficultyBiasMap;

  Map<String, Object> build() {
    final Map<String, Object?> loadBody =
        personaLoadBalancerMap['persona_load_balancer_v1']
            as Map<String, Object?>? ??
        <String, Object?>{};
    final Map<String, Object?> schedulerBody =
        personaAdaptiveSchedulerMap['persona_adaptive_scheduler_v1']
            as Map<String, Object?>? ??
        <String, Object?>{};
    final Map<String, Object?> difficultyBody =
        personaDifficultyBiasMap['persona_difficulty_bias_v1']
            as Map<String, Object?>? ??
        <String, Object?>{};

    final String loadMode = (loadBody['load_mode'] as String?)?.trim() ?? '';
    final double loadValue = _extractScore(loadBody, 'load_value');
    final double schedulerIntensity = _extractScore(
      schedulerBody,
      'schedule_intensity',
    );
    final double difficultyScore = _extractScore(difficultyBody, 'difficulty');

    String paceMode = 'neutral';
    if (loadMode == 'high') {
      paceMode = 'fast';
    } else if (loadMode == 'medium') {
      paceMode = 'normal';
    } else if (loadMode == 'low') {
      paceMode = 'slow';
    }

    double paceValue =
        (loadValue * 0.5) +
        (schedulerIntensity * 0.3) +
        (difficultyScore * 0.2);
    paceValue = paceValue.clamp(0.0, 1.0);

    return <String, Object>{
      'content_pacing_v1': <String, Object>{
        'pace_mode': _ascii(paceMode),
        'pace_value': paceValue,
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

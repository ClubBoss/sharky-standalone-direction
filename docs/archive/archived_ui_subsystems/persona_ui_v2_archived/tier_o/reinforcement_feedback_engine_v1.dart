class ReinforcementFeedbackEngineV1 {
  const ReinforcementFeedbackEngineV1({
    this.adaptiveReinforcementRouterMap = const <String, Object>{},
    this.personaReinforcementMap = const <String, Object>{},
    this.personaDifficultyBiasMap = const <String, Object>{},
  });

  ReinforcementFeedbackEngineV1.fromInputs({
    Map<String, Object?>? adaptiveReinforcementRouterMap,
    Map<String, Object?>? personaReinforcementMap,
    Map<String, Object?>? personaDifficultyBiasMap,
  }) : this(
         adaptiveReinforcementRouterMap: _safe(adaptiveReinforcementRouterMap),
         personaReinforcementMap: _safe(personaReinforcementMap),
         personaDifficultyBiasMap: _safe(personaDifficultyBiasMap),
       );

  final Map<String, Object> adaptiveReinforcementRouterMap;
  final Map<String, Object> personaReinforcementMap;
  final Map<String, Object> personaDifficultyBiasMap;

  Map<String, Object> build() {
    final Map<String, Object?> routerBody =
        adaptiveReinforcementRouterMap['adaptive_reinforcement_router_v1']
            as Map<String, Object?>? ??
        <String, Object?>{};
    final Map<String, Object?> reinforcementBody =
        personaReinforcementMap['persona_reinforcement_map_v1']
            as Map<String, Object?>? ??
        <String, Object?>{};
    final Map<String, Object?> difficultyBody =
        personaDifficultyBiasMap['persona_difficulty_bias_v1']
            as Map<String, Object?>? ??
        <String, Object?>{};

    final String route = (routerBody['route'] as String?)?.trim() ?? '';
    final double routeStrength = _extractScore(routerBody, 'route_strength');
    final double reinforcementScore = _extractScore(
      reinforcementBody,
      'reinforcement_score',
    );
    final double difficultyScore = _extractScore(difficultyBody, 'difficulty');

    String feedbackTag = 'neutral';
    if (route == 'intensify') {
      feedbackTag = 'push';
    } else if (route == 'support') {
      feedbackTag = 'assist';
    } else if (route == 'mitigate') {
      feedbackTag = 'ease';
    }

    double feedbackStrength =
        (routeStrength * 0.6) +
        (reinforcementScore * 0.3) +
        (difficultyScore * 0.1);
    feedbackStrength = feedbackStrength.clamp(0.0, 1.0);

    return <String, Object>{
      'reinforcement_feedback_engine_v1': <String, Object>{
        'feedback_tag': _ascii(feedbackTag),
        'feedback_strength': feedbackStrength,
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

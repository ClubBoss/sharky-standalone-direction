class AdaptiveReinforcementRouterV1 {
  const AdaptiveReinforcementRouterV1({
    this.reinforcementSyncMap = const <String, Object>{},
    this.personaReinforcementMap = const <String, Object>{},
    this.personaDifficultyBiasMap = const <String, Object>{},
  });

  AdaptiveReinforcementRouterV1.fromInputs({
    Map<String, Object?>? reinforcementSyncMap,
    Map<String, Object?>? personaReinforcementMap,
    Map<String, Object?>? personaDifficultyBiasMap,
  }) : this(
         reinforcementSyncMap: _safe(reinforcementSyncMap),
         personaReinforcementMap: _safe(personaReinforcementMap),
         personaDifficultyBiasMap: _safe(personaDifficultyBiasMap),
       );

  final Map<String, Object> reinforcementSyncMap;
  final Map<String, Object> personaReinforcementMap;
  final Map<String, Object> personaDifficultyBiasMap;

  Map<String, Object> build() {
    final Map<String, Object?> syncBody =
        reinforcementSyncMap['reinforcement_sync_v1']
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

    final String syncMode = (syncBody['sync_mode'] as String?)?.trim() ?? '';
    final double syncValue = _extractScore(syncBody, 'sync_value');
    final double reinforcementScore = _extractScore(
      reinforcementBody,
      'reinforcement_score',
    );
    final double difficultyScore = _extractScore(difficultyBody, 'difficulty');
    final String difficultyTag =
        (difficultyBody['tag'] as String?)?.trim() ?? '';

    String route = 'neutral';
    if (syncMode == 'boost') {
      route = 'intensify';
    } else if (syncMode == 'assist') {
      route = 'support';
    } else if (difficultyTag == 'hard') {
      route = 'mitigate';
    }

    double routeStrength =
        (reinforcementScore * 0.6) +
        (syncValue * 0.3) +
        (difficultyScore * 0.1);
    routeStrength = routeStrength.clamp(0.0, 1.0);

    return <String, Object>{
      'adaptive_reinforcement_router_v1': <String, Object>{
        'route': _ascii(route),
        'route_strength': routeStrength,
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

class PersonaInfluenceSurfaceV1 {
  const PersonaInfluenceSurfaceV1({
    this.personaIdentityFinalizerMap = const <String, Object>{},
    this.personaGrowthConsolidatedMap = const <String, Object>{},
    this.personaReinforcementMap = const <String, Object>{},
    this.personaDifficultyBiasMap = const <String, Object>{},
  });

  PersonaInfluenceSurfaceV1.fromInputs({
    Map<String, Object?>? personaIdentityFinalizerMap,
    Map<String, Object?>? personaGrowthConsolidatedMap,
    Map<String, Object?>? personaReinforcementMap,
    Map<String, Object?>? personaDifficultyBiasMap,
  }) : this(
         personaIdentityFinalizerMap: _safe(personaIdentityFinalizerMap),
         personaGrowthConsolidatedMap: _safe(personaGrowthConsolidatedMap),
         personaReinforcementMap: _safe(personaReinforcementMap),
         personaDifficultyBiasMap: _safe(personaDifficultyBiasMap),
       );

  final Map<String, Object> personaIdentityFinalizerMap;
  final Map<String, Object> personaGrowthConsolidatedMap;
  final Map<String, Object> personaReinforcementMap;
  final Map<String, Object> personaDifficultyBiasMap;

  Map<String, Object> build() {
    final Map<String, Object?> identityBody =
        personaIdentityFinalizerMap['persona_identity_finalizer_v1']
            as Map<String, Object?>? ??
        <String, Object?>{};
    final Map<String, Object?> growthBody =
        personaGrowthConsolidatedMap['persona_growth_consolidated_v1']
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

    final String identityTag =
        (identityBody['identity_tag'] as String?)?.trim() ?? '';
    final String consolidatedTag =
        (growthBody['master_tag'] as String?)?.trim() ?? '';
    final String reinforcementTag =
        (reinforcementBody['reinforcement_tag'] as String?)?.trim() ?? '';
    final double identityScore = _extractScore(identityBody, 'identity_score');
    final double growthScore = _extractScore(growthBody, 'master_score');
    final double reinforcementScore = _extractScore(
      reinforcementBody,
      'reinforcement_score',
    );
    final double difficultyScore = _extractScore(difficultyBody, 'difficulty');

    String influenceTag = 'influence_neutral';
    if (identityTag.isNotEmpty && identityTag != 'review_identity') {
      influenceTag = identityTag;
    } else if (consolidatedTag.isNotEmpty) {
      influenceTag = consolidatedTag;
    } else if (reinforcementTag.isNotEmpty) {
      influenceTag = reinforcementTag;
    }

    double influenceStrength =
        (identityScore * 0.55) +
        (growthScore * 0.20) +
        (reinforcementScore * 0.15) +
        (difficultyScore * 0.10);
    influenceStrength = influenceStrength.clamp(0.0, 1.0);

    return <String, Object>{
      'persona_influence_surface_v1': <String, Object>{
        'influence_tag': _ascii(influenceTag),
        'influence_strength': influenceStrength,
        'ready': true,
      },
    };
  }

  static double _extractScore(Map<String, Object?> body, String key) {
    final Object? scoreRaw = body[key];
    if (scoreRaw is num) return scoreRaw.toDouble();
    if (scoreRaw is String) {
      final double? parsed = double.tryParse(scoreRaw);
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

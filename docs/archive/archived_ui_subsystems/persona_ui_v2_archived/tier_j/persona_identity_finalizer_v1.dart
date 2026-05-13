class PersonaIdentityFinalizerV1 {
  const PersonaIdentityFinalizerV1({
    this.personaConsolidatedMap = const <String, Object>{},
    this.personaMetaPersonaMap = const <String, Object>{},
    this.personaGrowthConsolidatedMap = const <String, Object>{},
    this.personaReinforcementMap = const <String, Object>{},
    this.personaDifficultyBiasMap = const <String, Object>{},
    this.personaMicroScoreMap = const <String, Object>{},
  });

  PersonaIdentityFinalizerV1.fromInputs({
    Map<String, Object?>? personaConsolidatedMap,
    Map<String, Object?>? personaMetaPersonaMap,
    Map<String, Object?>? personaGrowthConsolidatedMap,
    Map<String, Object?>? personaReinforcementMap,
    Map<String, Object?>? personaDifficultyBiasMap,
    Map<String, Object?>? personaMicroScoreMap,
  }) : this(
         personaConsolidatedMap: _safe(personaConsolidatedMap),
         personaMetaPersonaMap: _safe(personaMetaPersonaMap),
         personaGrowthConsolidatedMap: _safe(personaGrowthConsolidatedMap),
         personaReinforcementMap: _safe(personaReinforcementMap),
         personaDifficultyBiasMap: _safe(personaDifficultyBiasMap),
         personaMicroScoreMap: _safe(personaMicroScoreMap),
       );

  final Map<String, Object> personaConsolidatedMap;
  final Map<String, Object> personaMetaPersonaMap;
  final Map<String, Object> personaGrowthConsolidatedMap;
  final Map<String, Object> personaReinforcementMap;
  final Map<String, Object> personaDifficultyBiasMap;
  final Map<String, Object> personaMicroScoreMap;

  Map<String, Object> build() {
    final String identityTag = _resolveTag();
    final double metaPersonaScore = _extractScore(
      personaMetaPersonaMap['persona_meta_persona_v1'] as Map<String, Object?>?,
      'score',
    );
    final double consolidatedScore = _extractScore(
      personaConsolidatedMap['persona_consolidated_v1']
          as Map<String, Object?>?,
      'identity_score',
    );
    final double growthScore = _extractScore(
      personaGrowthConsolidatedMap['persona_growth_consolidated_v1']
          as Map<String, Object?>?,
      'master_score',
    );
    final double reinforcementScore = _extractScore(
      personaReinforcementMap['persona_reinforcement_map_v1']
          as Map<String, Object?>?,
      'reinforcement_score',
    );
    final double difficultyScore = _extractScore(
      personaDifficultyBiasMap['persona_difficulty_bias_v1']
          as Map<String, Object?>?,
      'difficulty',
    );
    final double microScore = _extractScore(
      personaMicroScoreMap['persona_micro_scoring_v1'] as Map<String, Object?>?,
      'score',
    );
    double identityScore =
        (metaPersonaScore * 0.35) +
        (consolidatedScore * 0.30) +
        (growthScore * 0.15) +
        (reinforcementScore * 0.10) +
        (difficultyScore * 0.05) +
        (microScore * 0.05);
    identityScore = identityScore.clamp(0.0, 1.0);
    return <String, Object>{
      'persona_identity_finalizer_v1': <String, Object>{
        'identity_tag': _ascii(identityTag),
        'identity_score': identityScore,
        'ready': true,
      },
    };
  }

  String _resolveTag() {
    final String? metaPersonaTag =
        (personaMetaPersonaMap['persona_meta_persona_v1']
                as Map<String, Object?>?)?['persona_tag']
            as String?;
    if (metaPersonaTag != null && metaPersonaTag.isNotEmpty) {
      return metaPersonaTag;
    }
    final String? consolidatedTag =
        (personaConsolidatedMap['persona_consolidated_v1']
                as Map<String, Object?>?)?['persona_tag']
            as String?;
    if (consolidatedTag != null && consolidatedTag.isNotEmpty) {
      return consolidatedTag;
    }
    final String? reinforcementTag =
        (personaReinforcementMap['persona_reinforcement_map_v1']
                as Map<String, Object?>?)?['reinforcement_tag']
            as String?;
    if (reinforcementTag != null && reinforcementTag.isNotEmpty) {
      return reinforcementTag;
    }
    final String? difficultyTag =
        (personaDifficultyBiasMap['persona_difficulty_bias_v1']
                as Map<String, Object?>?)?['tag']
            as String?;
    if (difficultyTag != null && difficultyTag.isNotEmpty) {
      return difficultyTag;
    }
    return 'review_identity';
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

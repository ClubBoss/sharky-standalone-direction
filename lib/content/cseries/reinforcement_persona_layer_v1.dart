/// Static deterministic persona weight adjustments for reinforcement results.
class ReinforcementPersonaLayerV1 {
  const ReinforcementPersonaLayerV1();

  Map<String, Object?> applyPersona({
    required String personaTier,
    required Map<String, Object?> engineV3Result,
  }) {
    const personaWeights = <String, int>{
      'tier_a': 1,
      'tier_b': 2,
      'tier_c': 3,
      'tier_pro': 4,
    };
    final int weight = personaWeights[personaTier] ?? 1;
    final int weightedScore = engineV3Result['weighted_score'] as int? ?? 0;
    final int adjusted = weightedScore * weight;
    return Map.unmodifiable(<String, Object?>{
      'version': 'v1',
      'persona_tier': personaTier,
      'persona_weight': weight,
      'base_weighted_score': weightedScore,
      'persona_adjusted_score': adjusted,
      'note': 'Static persona tier adjustment; no adaptive/emotional logic.',
    });
  }
}

ReinforcementPersonaLayerV1 buildReinforcementPersonaLayerV1() =>
    const ReinforcementPersonaLayerV1();

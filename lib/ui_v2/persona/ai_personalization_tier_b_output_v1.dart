/// Passive Tier-B personality output generator (Phi-11).
class AIPersonalizationTierBOutputV1 {
  const AIPersonalizationTierBOutputV1({
    required this.tierBConsistencyMap,
    required this.tierBAggregate,
    required this.personaBundle,
    required this.tierAContext,
  });

  final Map<String, Object> tierBConsistencyMap;
  final Map<String, Object> tierBAggregate;
  final Map<String, Object> personaBundle;
  final Map<String, Object> tierAContext;

  Map<String, Object> run() {
    final bool hasConsistency = tierBConsistencyMap.isNotEmpty;
    final bool hasAggregate = tierBAggregate.isNotEmpty;
    final bool hasPersonaBundle = personaBundle.isNotEmpty;
    final bool hasTierA = tierAContext.isNotEmpty;

    final Map<String, Object> personalityOutputMap = <String, Object>{
      'out_persona': personaBundle,
      'out_consistency': tierBConsistencyMap,
      'out_aggregate': tierBAggregate,
      'out_tier_a': tierAContext,
    };

    final bool outputReady =
        hasConsistency && hasAggregate && hasPersonaBundle && hasTierA;

    return <String, Object>{
      'has_consistency': hasConsistency,
      'has_aggregate': hasAggregate,
      'has_persona_bundle': hasPersonaBundle,
      'has_tier_a': hasTierA,
      'personality_output_map': personalityOutputMap,
      'output_ready': outputReady,
    };
  }
}

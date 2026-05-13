/// Passive Tier-A adapter for AI personalization (Phi-7).
class AIPersonalizationTierAAdapterV1 {
  const AIPersonalizationTierAAdapterV1(
    this.visualIntegrityMap,
    this.personaBundle,
  );

  final Map<String, Object> visualIntegrityMap;
  final Map<String, Object> personaBundle;

  Map<String, Object> run() {
    final bool hasVisualIntegrity = visualIntegrityMap.isNotEmpty;
    final bool hasPersonaBundle = personaBundle.isNotEmpty;

    final Map<String, Object> tierAContext = <String, Object>{};
    void _pick(String sourceKey, String targetKey) {
      if (visualIntegrityMap.containsKey(sourceKey)) {
        final Object value = visualIntegrityMap[sourceKey] as Object;
        tierAContext[targetKey] = value;
      }
    }

    _pick('tokens', 'v_tokens');
    _pick('theme_deltas', 'v_theme');
    _pick('surface_polish', 'v_surface');
    _pick('activation', 'v_activation');
    _pick('binding', 'v_binding');

    final bool adapterReady =
        hasVisualIntegrity && hasPersonaBundle && tierAContext.isNotEmpty;

    return <String, Object>{
      'has_visual_integrity': hasVisualIntegrity,
      'has_persona_bundle': hasPersonaBundle,
      'tier_a_context': tierAContext,
      'adapter_ready': adapterReady,
    };
  }
}

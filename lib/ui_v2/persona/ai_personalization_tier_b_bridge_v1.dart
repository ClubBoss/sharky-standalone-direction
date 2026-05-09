/// Passive Tier-B synthesis bridge for AI personalization (Phi-8).
class AIPersonalizationTierBBridgeV1 {
  const AIPersonalizationTierBBridgeV1({
    required this.tierAContext,
    required this.personaBundle,
    this.telemetry,
    this.emotionalState,
  });

  final Map<String, Object> tierAContext;
  final Map<String, Object> personaBundle;
  final Map<String, Object>? telemetry;
  final Map<String, Object>? emotionalState;

  Map<String, Object> run() {
    final bool hasTierA = tierAContext.isNotEmpty;
    final bool hasPersonaBundle = personaBundle.isNotEmpty;
    final bool hasTelemetry = telemetry != null && telemetry!.isNotEmpty;
    final bool hasEmotion =
        emotionalState != null && emotionalState!.isNotEmpty;

    final Map<String, Object> tierBBridgeMap = <String, Object>{};
    void _copy(String sourceKey, String targetKey) {
      if (tierAContext.containsKey(sourceKey)) {
        tierBBridgeMap[targetKey] = tierAContext[sourceKey] as Object;
      }
    }

    _copy('v_tokens', 'a_tokens');
    _copy('v_theme', 'a_theme');
    _copy('v_surface', 'a_surface');
    _copy('v_activation', 'a_activation');
    _copy('v_binding', 'a_binding');

    if (personaBundle.isNotEmpty) {
      tierBBridgeMap['p_profile'] = personaBundle;
      if (personaBundle.containsKey('traits')) {
        tierBBridgeMap['p_traits'] = personaBundle['traits'] as Object;
      }
    }

    if (hasTelemetry) tierBBridgeMap['t_metrics'] = telemetry!;
    if (hasEmotion) tierBBridgeMap['e_state'] = emotionalState!;

    final bool bridgeReady = hasTierA && hasPersonaBundle;

    return <String, Object>{
      'has_tier_a': hasTierA,
      'has_persona_bundle': hasPersonaBundle,
      'has_telemetry': hasTelemetry,
      'has_emotion': hasEmotion,
      'tier_b_bridge_map': tierBBridgeMap,
      'bridge_ready': bridgeReady,
    };
  }
}

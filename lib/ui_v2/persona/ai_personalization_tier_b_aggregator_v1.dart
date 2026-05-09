/// Passive Tier-B aggregator for AI personalization (Phi-9).
class AIPersonalizationTierBAggregatorV1 {
  const AIPersonalizationTierBAggregatorV1({
    required this.tierBBridge,
    required this.tierAContext,
    required this.personaBundle,
    required this.visualIntegrity,
    this.telemetry,
    this.emotionalState,
  });

  final Map<String, Object> tierBBridge;
  final Map<String, Object> tierAContext;
  final Map<String, Object> personaBundle;
  final Map<String, Object> visualIntegrity;
  final Map<String, Object>? telemetry;
  final Map<String, Object>? emotionalState;

  Map<String, Object> run() {
    final bool hasBridge = tierBBridge.isNotEmpty;
    final bool hasTierA = tierAContext.isNotEmpty;
    final bool hasPersonaBundle = personaBundle.isNotEmpty;
    final bool hasVisualIntegrity = visualIntegrity.isNotEmpty;
    final bool hasTelemetry = telemetry != null && telemetry!.isNotEmpty;
    final bool hasEmotion =
        emotionalState != null && emotionalState!.isNotEmpty;

    final Map<String, Object> aggregate = <String, Object>{
      'b_bridge': tierBBridge,
      'b_tier_a': tierAContext,
      'b_persona': personaBundle,
      'b_visual': visualIntegrity,
    };
    if (hasTelemetry) aggregate['b_telemetry'] = telemetry!;
    if (hasEmotion) aggregate['b_emotion'] = emotionalState!;

    final bool aggregateReady =
        hasBridge && hasTierA && hasPersonaBundle && hasVisualIntegrity;

    return <String, Object>{
      'has_bridge': hasBridge,
      'has_tier_a': hasTierA,
      'has_persona_bundle': hasPersonaBundle,
      'has_visual_integrity': hasVisualIntegrity,
      'has_telemetry': hasTelemetry,
      'has_emotion': hasEmotion,
      'tier_b_aggregate_map': aggregate,
      'aggregate_ready': aggregateReady,
    };
  }
}

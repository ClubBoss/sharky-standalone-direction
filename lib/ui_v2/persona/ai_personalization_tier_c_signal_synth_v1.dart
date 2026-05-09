/// Tier-C signal synthesizer (Phi-39.2).
class AIPersonalizationTierCSignalSynthV1 {
  const AIPersonalizationTierCSignalSynthV1(this.tierCInputBridge);

  final Map<String, Object> tierCInputBridge;

  Map<String, Object> asReadOnlyMap() {
    final bool bridgeReady = tierCInputBridge['bridge_ready'] == true;
    final Map<String, Object>? personaContext =
        tierCInputBridge['persona_context'] is Map
        ? tierCInputBridge['persona_context'] as Map<String, Object>
        : null;
    final Map<String, Object>? tableContext =
        tierCInputBridge['table_context'] is Map
        ? tierCInputBridge['table_context'] as Map<String, Object>
        : null;

    final bool personaHasId =
        personaContext != null && personaContext['persona_id'] != null;
    final bool tableHasTokens =
        tableContext != null && tableContext['view_shell_tokens'] != null;

    final bool synthReady = bridgeReady && personaHasId && tableHasTokens;

    final Map<String, Object> signals = <String, Object>{
      'device_factor': tableContext?['device_class'] ?? 'device_default',
      'persona_factor': personaContext?['persona_id'] ?? 'persona_default',
      'context_factor': synthReady ? 'context_ready' : 'context_pending',
    };

    return <String, Object>{
      'input': tierCInputBridge,
      'signals': signals,
      'synth_ready': synthReady,
    };
  }

  Map<String, Object> run() => asReadOnlyMap();
}

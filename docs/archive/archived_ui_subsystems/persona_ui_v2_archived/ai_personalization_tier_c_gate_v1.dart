/// Tier-C personalization gate (Phi-39.3).
class AIPersonalizationTierCGateV1 {
  const AIPersonalizationTierCGateV1(this.tierCSignalSynth);

  final Map<String, Object> tierCSignalSynth;

  Map<String, Object> asReadOnlyMap() {
    final Map<String, Object>? signals = tierCSignalSynth['signals'] is Map
        ? (tierCSignalSynth['signals'] as Map).cast<String, Object>()
        : null;
    final Map<String, Object>? bridgeInput = tierCSignalSynth['input'] is Map
        ? (tierCSignalSynth['input'] as Map).cast<String, Object>()
        : null;
    final Map<String, Object>? personaContext =
        bridgeInput != null && bridgeInput['persona_context'] is Map
        ? (bridgeInput['persona_context'] as Map).cast<String, Object>()
        : null;

    final bool deviceOk = signals?.containsKey('device_factor') == true;
    final bool personaOk =
        signals?.containsKey('persona_factor') == true &&
        personaContext != null &&
        personaContext['persona_id'] != null;
    final bool contextOk = signals?.containsKey('context_factor') == true;

    final bool gateReady =
        deviceOk &&
        personaOk &&
        contextOk &&
        tierCSignalSynth['synth_ready'] == true;

    return <String, Object>{
      'input': tierCSignalSynth,
      'gate': <String, Object>{
        'device_ok': deviceOk,
        'persona_ok': personaOk,
        'context_ok': contextOk,
      },
      'gate_ready': gateReady,
    };
  }

  Map<String, Object> run() => asReadOnlyMap();
}

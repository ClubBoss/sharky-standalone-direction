/// Tier-B system verdict adapter (Phi-32.20).
class AIPersonalizationTierBSystemVerdictAdapterV1 {
  const AIPersonalizationTierBSystemVerdictAdapterV1({
    required this.masterSystemBundle,
    required this.systemBridge,
    required this.tierBOutput,
    required this.personaHints,
  });

  final Object masterSystemBundle;
  final Object systemBridge;
  final Object tierBOutput;
  final Object personaHints;

  Map<String, Object> asReadOnlyMap() {
    final Map<dynamic, dynamic>? master = masterSystemBundle is Map
        ? masterSystemBundle as Map
        : null;
    final Map<dynamic, dynamic>? bridge = systemBridge is Map
        ? systemBridge as Map
        : null;
    final Map<dynamic, dynamic>? output = tierBOutput is Map
        ? tierBOutput as Map
        : null;
    final Map<dynamic, dynamic>? hints = personaHints is Map
        ? personaHints as Map
        : null;

    final bool masterReady =
        master != null && master.isNotEmpty && master['bundle_ready'] == true;
    final bool bridgeReady =
        bridge != null && bridge.isNotEmpty && bridge['bridge_ready'] == true;
    final bool outputReady = output != null && output.isNotEmpty;
    final bool hintsReady = hints != null && hints.isNotEmpty;

    final bool verdictReady =
        masterReady && bridgeReady && outputReady && hintsReady;

    return <String, Object>{
      'verdict_ready': verdictReady,
      'master': masterReady ? master : <Object>{},
      'bridge': bridgeReady ? bridge : <Object>{},
      'output': outputReady ? output : <Object>{},
      'hints': hintsReady ? hints : <Object>{},
    };
  }

  Map<String, Object> run() => asReadOnlyMap();
}

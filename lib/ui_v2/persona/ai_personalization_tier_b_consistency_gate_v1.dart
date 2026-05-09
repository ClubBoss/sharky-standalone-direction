/// Tier-B consistency gate (Phi-38.11).
class AIPersonalizationTierBConsistencyGateV1 {
  const AIPersonalizationTierBConsistencyGateV1(
    this.tierBOutput,
    this.tierBHints,
    this.systemVerdict,
    this.tierBConsolidator,
  );

  final Map<String, Object> tierBOutput;
  final Map<String, Object> tierBHints;
  final Map<String, Object> systemVerdict;
  final Map<String, Object> tierBConsolidator;

  Map<String, Object> asReadOnlyMap() {
    final bool outputReady = tierBOutput.isNotEmpty;
    final bool hintsReady = tierBHints.isNotEmpty;
    final bool verdictReady =
        systemVerdict.isNotEmpty && systemVerdict['verdict_ready'] == true;
    final bool consolidatorReady =
        tierBConsolidator.isNotEmpty &&
        tierBConsolidator['consolidated_ready'] == true;

    bool personaMatch = true;
    if (outputReady &&
        hintsReady &&
        tierBOutput.containsKey('persona_id') &&
        tierBHints.containsKey('persona_id')) {
      personaMatch = tierBOutput['persona_id'] == tierBHints['persona_id'];
    }

    final bool consistencyReady =
        outputReady &&
        hintsReady &&
        verdictReady &&
        consolidatorReady &&
        personaMatch;

    return <String, Object>{
      'tier_b_output': outputReady ? tierBOutput : <Object>{},
      'tier_b_hints': hintsReady ? tierBHints : <Object>{},
      'system_verdict': verdictReady ? systemVerdict : <Object>{},
      'tier_b_consolidator': consolidatorReady ? tierBConsolidator : <Object>{},
      'consistency_ready': consistencyReady,
    };
  }

  Map<String, Object> run() => asReadOnlyMap();
}

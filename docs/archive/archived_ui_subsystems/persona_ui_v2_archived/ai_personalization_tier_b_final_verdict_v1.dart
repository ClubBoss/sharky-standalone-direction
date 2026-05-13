/// Tier-B final verdict gate (Phi-38.12).
class AIPersonalizationTierBFinalVerdictV1 {
  const AIPersonalizationTierBFinalVerdictV1(
    this.tierBOutput,
    this.tierBHints,
    this.systemVerdict,
    this.tierBConsolidator,
    this.tierBConsistency,
  );

  final Map<String, Object> tierBOutput;
  final Map<String, Object> tierBHints;
  final Map<String, Object> systemVerdict;
  final Map<String, Object> tierBConsolidator;
  final Map<String, Object> tierBConsistency;

  Map<String, Object> asReadOnlyMap() {
    final bool outputReady = tierBOutput.isNotEmpty;
    final bool hintsReady = tierBHints.isNotEmpty;
    final bool verdictReady =
        systemVerdict.isNotEmpty && systemVerdict['verdict_ready'] == true;
    final bool consolidatorReady =
        tierBConsolidator.isNotEmpty &&
        tierBConsolidator['consolidated_ready'] == true;
    final bool consistencyReady =
        tierBConsistency.isNotEmpty &&
        tierBConsistency['consistency_ready'] == true;

    bool personaMatch = true;
    if (outputReady &&
        hintsReady &&
        tierBOutput.containsKey('persona_id') &&
        tierBHints.containsKey('persona_id')) {
      personaMatch = tierBOutput['persona_id'] == tierBHints['persona_id'];
    }

    final bool verdictFinal =
        outputReady &&
        hintsReady &&
        verdictReady &&
        consolidatorReady &&
        consistencyReady &&
        personaMatch;

    return <String, Object>{
      'tier_b_output': outputReady ? tierBOutput : <Object>{},
      'tier_b_hints': hintsReady ? tierBHints : <Object>{},
      'system_verdict': verdictReady ? systemVerdict : <Object>{},
      'tier_b_consolidator': consolidatorReady ? tierBConsolidator : <Object>{},
      'tier_b_consistency': consistencyReady ? tierBConsistency : <Object>{},
      'verdict_ready': verdictFinal,
    };
  }

  Map<String, Object> run() => asReadOnlyMap();
}

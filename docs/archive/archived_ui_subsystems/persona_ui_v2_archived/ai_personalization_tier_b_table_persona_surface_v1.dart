/// Tier-B table persona surface (Phi-38.13).
class AIPersonalizationTierBTablePersonaSurfaceV1 {
  const AIPersonalizationTierBTablePersonaSurfaceV1(
    this.tierBOutput,
    this.tierBHints,
    this.tierBFinalVerdict,
  );

  final Map<String, Object> tierBOutput;
  final Map<String, Object> tierBHints;
  final Map<String, Object> tierBFinalVerdict;

  Map<String, Object> asReadOnlyMap() {
    final bool outputReady = tierBOutput.isNotEmpty;
    final bool hintsReady = tierBHints.isNotEmpty;
    final bool verdictReady =
        tierBFinalVerdict.isNotEmpty &&
        tierBFinalVerdict['verdict_ready'] == true;

    bool personaMatch = true;
    if (outputReady &&
        hintsReady &&
        tierBOutput.containsKey('persona_id') &&
        tierBHints.containsKey('persona_id')) {
      personaMatch = tierBOutput['persona_id'] == tierBHints['persona_id'];
    }

    final bool surfaceReady =
        outputReady && hintsReady && verdictReady && personaMatch;

    return <String, Object>{
      'tier_b_output': outputReady ? tierBOutput : <Object>{},
      'tier_b_hints': hintsReady ? tierBHints : <Object>{},
      'tier_b_final_verdict': verdictReady ? tierBFinalVerdict : <Object>{},
      'surface_ready': surfaceReady,
    };
  }

  Map<String, Object> run() => asReadOnlyMap();
}

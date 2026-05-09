/// Static SRS schedule metadata surface for persona-adjusted reinforcement.
class SRSLayerV1 {
  const SRSLayerV1();

  Map<String, Object?> build({
    required Map<String, Object?> personaAdjustedResult,
    required Map<String, Object?> integratorV2Result,
  }) {
    final intervals = Map.unmodifiable(<String, int>{
      'interval_1': 1,
      'interval_2': 8,
      'interval_3': 24,
      'interval_4': 72,
      'interval_5': 168,
    });
    final int score =
        personaAdjustedResult['persona_adjusted_score'] as int? ?? 0;
    final String band = score >= 40
        ? 'deep'
        : score >= 20
        ? 'standard'
        : 'light';
    return Map.unmodifiable(<String, Object?>{
      'version': 'v1',
      'persona_adjusted_score': score,
      'srs_band': band,
      'intervals': intervals,
      'persona_adjusted_result': personaAdjustedResult,
      'integrator_v2_result': integratorV2Result,
      'note': 'Static SRS schedule v1; no adaptive difficulty.',
    });
  }
}

SRSLayerV1 buildSRSLayerV1() => const SRSLayerV1();

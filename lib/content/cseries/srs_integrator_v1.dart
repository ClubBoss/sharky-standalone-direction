/// Metadata integrator combining the static SRS schedule with persona results.
class SRSIntegratorV1 {
  const SRSIntegratorV1();

  Map<String, Object?> integrate({
    required Map<String, Object?> srsLayerV1Result,
    required Map<String, Object?> personaAdjustedResult,
    required Map<String, Object?> integratorV2Result,
  }) {
    final Map<String, int> intervals =
        (srsLayerV1Result['intervals'] as Map?)?.cast<String, int>() ??
        const <String, int>{};
    final String srsBand = srsLayerV1Result['srs_band'] as String? ?? 'light';
    final int personaScore =
        personaAdjustedResult['persona_adjusted_score'] as int? ?? 0;
    final int srsWeight = srsBand == 'deep'
        ? 3
        : srsBand == 'standard'
        ? 2
        : 1;
    return Map.unmodifiable(<String, Object?>{
      'version': 'v1',
      'srs_band': srsBand,
      'srs_intervals': Map.unmodifiable(intervals),
      'srs_weight': srsWeight,
      'persona_adjusted_score': personaScore,
      'srs_layer_result': srsLayerV1Result,
      'persona_adjusted_result': personaAdjustedResult,
      'integrator_v2_result': integratorV2Result,
      'note': 'Deterministic SRS integrator v1; no adaptive difficulty.',
    });
  }
}

SRSIntegratorV1 buildSRSIntegratorV1() => const SRSIntegratorV1();

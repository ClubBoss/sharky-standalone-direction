/// Deterministic integrator combining adaptive schedule, SRS, and persona metadata.
class AdaptiveIntegratorV1 {
  const AdaptiveIntegratorV1();

  Map<String, Object?> integrate({
    required Map<String, Object?> adaptiveScheduleV1Result,
    required Map<String, Object?> srsIntegratorV1Result,
    required Map<String, Object?> personaAdjustedResult,
  }) {
    final String adaptiveBand =
        adaptiveScheduleV1Result['adaptive_band'] as String? ?? 'unchanged';
    final int delta = adaptiveScheduleV1Result['delta'] as int? ?? 0;
    final Map<String, int> adjusted =
        (adaptiveScheduleV1Result['adjusted_intervals'] as Map?)
            ?.cast<String, int>() ??
        const <String, int>{};
    final int personaScore =
        personaAdjustedResult['persona_adjusted_score'] as int? ?? 0;
    final String srsBand =
        srsIntegratorV1Result['srs_band'] as String? ?? 'light';
    final String finalBand = personaScore >= 40
        ? 'persona_strong_adaptive'
        : personaScore >= 20
        ? 'persona_moderate_adaptive'
        : 'persona_light_adaptive';
    return Map.unmodifiable(<String, Object?>{
      'version': 'v1',
      'adaptive_band': adaptiveBand,
      'delta': delta,
      'adjusted_intervals': Map.unmodifiable(adjusted),
      'srs_band': srsBand,
      'persona_adjusted_score': personaScore,
      'final_band': finalBand,
      'adaptive_schedule_result': adaptiveScheduleV1Result,
      'srs_integrator_result': srsIntegratorV1Result,
      'persona_adjusted_result': personaAdjustedResult,
      'note':
          'Deterministic Adaptive Integrator v1; no ML or dynamic difficulty.',
    });
  }
}

AdaptiveIntegratorV1 buildAdaptiveIntegratorV1() =>
    const AdaptiveIntegratorV1();

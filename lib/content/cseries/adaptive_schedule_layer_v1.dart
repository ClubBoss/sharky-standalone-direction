/// Rule-based adjustments on top of the static SRS schedule.
class AdaptiveScheduleLayerV1 {
  const AdaptiveScheduleLayerV1();

  Map<String, Object?> build({
    required Map<String, Object?> srsIntegratorV1Result,
    required Map<String, Object?> personaAdjustedResult,
  }) {
    final Map<String, int> intervals =
        (srsIntegratorV1Result['srs_intervals'] as Map?)?.cast<String, int>() ??
        const <String, int>{};
    final int personaScore =
        personaAdjustedResult['persona_adjusted_score'] as int? ?? 0;
    final int delta = personaScore >= 40
        ? -2
        : personaScore >= 20
        ? -1
        : 0;
    final Map<String, int> adjusted = <String, int>{};
    intervals.forEach((key, value) {
      adjusted[key] = value + delta;
    });
    final String adaptiveBand = personaScore >= 40
        ? 'tightened'
        : personaScore >= 20
        ? 'slightly_tightened'
        : 'unchanged';
    return Map.unmodifiable(<String, Object?>{
      'version': 'v1',
      'adaptive_band': adaptiveBand,
      'delta': delta,
      'adjusted_intervals': Map.unmodifiable(adjusted),
      'srs_integrator_result': srsIntegratorV1Result,
      'persona_adjusted_result': personaAdjustedResult,
      'note':
          'Deterministic adaptive schedule v1; no ML or adaptive difficulty.',
    });
  }
}

AdaptiveScheduleLayerV1 buildAdaptiveScheduleLayerV1() =>
    const AdaptiveScheduleLayerV1();

/// Persona-aware integrator that merges persona adjusted data with weighted logic.
class ReinforcementPersonaIntegratorV1 {
  const ReinforcementPersonaIntegratorV1();

  Map<String, Object?> integrate({
    required Map<String, Object?> personaAdjustedResult,
    required Map<String, Object?> engineV3Result,
    required Map<String, Object?> evaluationResult,
    required Map<String, Object?> scoringResult,
    required Map<String, Object?> pipelineDescriptor,
    required Map<String, Object?> executorResult,
    required Map<String, Object?> finalizerResult,
  }) {
    final int adjusted =
        personaAdjustedResult['persona_adjusted_score'] as int? ?? 0;
    final String personaBand = adjusted >= 20
        ? 'pro'
        : adjusted >= 10
        ? 'strong'
        : 'basic';
    return Map.unmodifiable(<String, Object?>{
      'version': 'v1',
      'persona_adjusted_score': adjusted,
      'persona_band': personaBand,
      'persona_adjusted_result': personaAdjustedResult,
      'engine_v3_result': engineV3Result,
      'evaluation_result': evaluationResult,
      'scoring_result': scoringResult,
      'pipeline_descriptor': pipelineDescriptor,
      'executor_result': executorResult,
      'finalizer_result': finalizerResult,
      'note':
          'Deterministic persona-aware integration v1; no adaptive/SRS/emotional logic.',
    });
  }
}

ReinforcementPersonaIntegratorV1 buildReinforcementPersonaIntegratorV1() =>
    const ReinforcementPersonaIntegratorV1();

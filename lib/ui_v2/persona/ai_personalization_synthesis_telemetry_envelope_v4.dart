class AIPersonalizationSynthesisTelemetryEnvelopeV4 {
  AIPersonalizationSynthesisTelemetryEnvelopeV4({
    required Map<String, Object?> finalSynthesis,
    required Map<String, Object?> telemetry,
  }) : _finalSynthesis = Map.of(finalSynthesis),
       _telemetry = Map.of(telemetry);

  final Map<String, Object?> _finalSynthesis;
  final Map<String, Object?> _telemetry;

  Map<String, Object?> asReadOnlyMap() => {
    'tier_b_final_synthesis_v4': _finalSynthesis,
    'tier_b_telemetry_map_v4': _telemetry,
  };
}

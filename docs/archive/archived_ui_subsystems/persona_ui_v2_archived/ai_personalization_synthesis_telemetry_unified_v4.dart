class AIPersonalizationSynthesisTelemetryUnifiedV4 {
  AIPersonalizationSynthesisTelemetryUnifiedV4({
    required Map<String, Object?> telemetryEnvelope,
    required Map<String, Object?> telemetryMap,
  }) : _telemetryEnvelope = Map.of(telemetryEnvelope),
       _telemetryMap = Map.of(telemetryMap);

  final Map<String, Object?> _telemetryEnvelope;
  final Map<String, Object?> _telemetryMap;

  Map<String, Object?> asReadOnlyMap() => {
    'tier_b_telemetry_envelope_v4': _telemetryEnvelope,
    'tier_b_telemetry_map_v4': _telemetryMap,
  };
}

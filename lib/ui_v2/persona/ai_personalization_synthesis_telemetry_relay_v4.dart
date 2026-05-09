class AIPersonalizationSynthesisTelemetryRelayV4 {
  AIPersonalizationSynthesisTelemetryRelayV4({
    required Map<String, Object?> telemetryEnvelope,
    required Map<String, Object?> telemetryMap,
  }) : _telemetryEnvelope = Map.of(telemetryEnvelope),
       _telemetryMap = Map.of(telemetryMap);

  final Map<String, Object?> _telemetryEnvelope;
  final Map<String, Object?> _telemetryMap;

  Map<String, Object?> asReadOnlyMap() => {
    'relay_envelope': _telemetryEnvelope,
    'relay_map': _telemetryMap,
  };
}

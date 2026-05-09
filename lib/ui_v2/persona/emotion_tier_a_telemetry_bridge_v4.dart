class EmotionTierATelemetryBridgeV4 {
  EmotionTierATelemetryBridgeV4({
    required Map<String, Object?> envelope,
    required Map<String, Object?> telemetry,
  }) : _envelope = Map.of(envelope),
       _telemetry = Map.of(telemetry);

  final Map<String, Object?> _envelope;
  final Map<String, Object?> _telemetry;

  Map<String, Object?> asUnifiedMap() => {
    'tier_a_envelope_v4': _envelope,
    'tier_a_telemetry_v4': _telemetry,
  };
}

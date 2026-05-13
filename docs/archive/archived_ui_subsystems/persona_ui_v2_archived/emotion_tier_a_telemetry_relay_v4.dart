class EmotionTierATelemetryRelayV4 {
  EmotionTierATelemetryRelayV4({
    required Map<String, Object?> envelope,
    required Map<String, Object?> telemetry,
  }) : _envelope = Map.of(envelope),
       _telemetry = Map.of(telemetry);

  final Map<String, Object?> _envelope;
  final Map<String, Object?> _telemetry;

  Map<String, Object?> asRelayMap() => {
    'tier_a_relay_envelope_v4': _envelope,
    'tier_a_relay_telemetry_v4': _telemetry,
  };
}

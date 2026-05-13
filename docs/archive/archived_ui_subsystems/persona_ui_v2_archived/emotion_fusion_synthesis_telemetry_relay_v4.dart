class EmotionFusionSynthesisTelemetryRelayV4 {
  const EmotionFusionSynthesisTelemetryRelayV4({
    required this.envelope,
    required this.telemetry,
  });

  final Map<String, Object?> envelope;
  final Map<String, Object?> telemetry;

  Map<String, Object?> asReadOnlyMap() => {
    'fusion_telemetry_relay_v4': {'envelope': envelope, 'telemetry': telemetry},
  };
}

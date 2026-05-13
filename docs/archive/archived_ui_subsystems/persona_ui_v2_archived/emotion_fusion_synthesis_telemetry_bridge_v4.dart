class EmotionFusionSynthesisTelemetryBridgeV4 {
  const EmotionFusionSynthesisTelemetryBridgeV4({
    required this.envelope,
    required this.telemetry,
  });

  final Map<String, Object?> envelope;
  final Map<String, Object?> telemetry;

  Map<String, Object?> asUnifiedMap() => {
    'fusion_synthesis_envelope_v4': envelope,
    'fusion_synthesis_telemetry_v4': telemetry,
  };
}

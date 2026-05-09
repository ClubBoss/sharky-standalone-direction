class EmotionFusionSynthesisTelemetryEnvelopeV4 {
  EmotionFusionSynthesisTelemetryEnvelopeV4({
    required this.telemetry,
    required this.envelope,
  });

  final Map<String, Object?> telemetry;
  final Map<String, Object?> envelope;

  Map<String, Object?> asReadOnlyMap() => {
    'fusion_synthesis_v4': envelope,
    'fusion_synthesis_telemetry_v4': telemetry,
  };
}

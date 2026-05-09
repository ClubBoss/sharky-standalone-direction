class EmotionFusionSynthesisTelemetryUnifiedEnvelopeV4 {
  EmotionFusionSynthesisTelemetryUnifiedEnvelopeV4({
    required this.envelope,
    required this.telemetry,
  });

  final Map<String, Object?> envelope;
  final Map<String, Object?> telemetry;

  Map<String, Object?> asReadOnlyMap() => {
    'fusion_telemetry_unified_v4': {
      'envelope': envelope,
      'telemetry': telemetry,
    },
  };
}

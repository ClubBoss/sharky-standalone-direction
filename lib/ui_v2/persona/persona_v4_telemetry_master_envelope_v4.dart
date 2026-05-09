class PersonaV4TelemetryMasterEnvelopeV4 {
  PersonaV4TelemetryMasterEnvelopeV4({
    required this.activationTelemetry,
    required this.emotionTelemetry,
    required this.fusionTelemetry,
  });

  final Map<String, Object?> activationTelemetry;
  final Map<String, Object?> emotionTelemetry;
  final Map<String, Object?> fusionTelemetry;

  Map<String, Object?> asReadOnlyMap() => {
    'activation_v4': activationTelemetry,
    'emotion_v4': emotionTelemetry,
    'fusion_v4': fusionTelemetry,
  };

  Map<String, Object?> harmonizedMasterRelay() => {
    'activation_v4': activationTelemetry,
    'emotion_v4': emotionTelemetry,
    'fusion_v4': fusionTelemetry,
  };
}

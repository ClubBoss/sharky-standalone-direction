class PersonaV4TelemetryUnifiedBundleV4 {
  PersonaV4TelemetryUnifiedBundleV4({
    required this.activation,
    required this.emotion,
    required this.fusion,
  });

  final Map<String, Object?> activation;
  final Map<String, Object?> emotion;
  final Map<String, Object?> fusion;

  Map<String, Object?> asReadOnlyMap() => {
    'persona_v4_telemetry_unified': {
      'activation': activation,
      'emotion': emotion,
      'fusion': fusion,
    },
  };
}

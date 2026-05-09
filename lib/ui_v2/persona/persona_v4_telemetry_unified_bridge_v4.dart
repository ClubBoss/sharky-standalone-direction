class PersonaV4TelemetryUnifiedBridgeV4 {
  PersonaV4TelemetryUnifiedBridgeV4({
    required Map<String, Object?> activation,
    required Map<String, Object?> emotion,
    required Map<String, Object?> fusion,
    required Map<String, Object?> tierB,
  }) : _activation = Map.of(activation),
       _emotion = Map.of(emotion),
       _fusion = Map.of(fusion),
       _tierB = Map.of(tierB);

  final Map<String, Object?> _activation;
  final Map<String, Object?> _emotion;
  final Map<String, Object?> _fusion;
  final Map<String, Object?> _tierB;

  Map<String, Object?> asReadOnlyMap() => {
    'persona_v4_activation': _activation,
    'persona_v4_emotion': _emotion,
    'persona_v4_fusion': _fusion,
    'persona_v4_tier_b': _tierB,
  };
}

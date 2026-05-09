class AIPersonalizationTierBTelemetryEnvelopeV4 {
  AIPersonalizationTierBTelemetryEnvelopeV4({
    required Map<String, Object?> telemetry,
    required Map<String, Object?> relay,
    required Map<String, Object?> masterBundle,
  }) : _telemetry = Map.of(telemetry),
       _relay = Map.of(relay),
       _masterBundle = Map.of(masterBundle);

  final Map<String, Object?> _telemetry;
  final Map<String, Object?> _relay;
  final Map<String, Object?> _masterBundle;

  Map<String, Object?> asReadOnlyMap() => {
    'tier_b_telemetry_map_v4': _telemetry,
    'tier_b_telemetry_relay_v4': _relay,
    'tier_b_master_bundle_v4': _masterBundle,
  };
}

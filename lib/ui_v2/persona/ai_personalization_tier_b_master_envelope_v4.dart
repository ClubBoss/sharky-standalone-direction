class AIPersonalizationTierBMasterEnvelopeV4 {
  AIPersonalizationTierBMasterEnvelopeV4({
    required Map<String, Object?> telemetryBridge,
    required Map<String, Object?> telemetryUnified,
  }) : _telemetryBridge = Map.of(telemetryBridge),
       _telemetryUnified = Map.of(telemetryUnified);

  final Map<String, Object?> _telemetryBridge;
  final Map<String, Object?> _telemetryUnified;

  Map<String, Object?> asReadOnlyMap() => {
    'tier_b_telemetry_bridge_v4': _telemetryBridge,
    'tier_b_telemetry_unified_v4': _telemetryUnified,
  };
}

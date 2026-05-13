class AIPersonalizationTierBTelemetryBridgeV4 {
  AIPersonalizationTierBTelemetryBridgeV4({
    required Map<String, Object?> telemetryUnified,
    required Map<String, Object?> telemetryMap,
  }) : _telemetryUnified = Map.of(telemetryUnified),
       _telemetryMap = Map.of(telemetryMap);

  final Map<String, Object?> _telemetryUnified;
  final Map<String, Object?> _telemetryMap;

  Map<String, Object?> asReadOnlyMap() => {
    'tier_b_telemetry_unified_v4': _telemetryUnified,
    'tier_b_telemetry_map_v4': _telemetryMap,
  };
}

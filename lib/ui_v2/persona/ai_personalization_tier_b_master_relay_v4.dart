class AIPersonalizationTierBMasterRelayV4 {
  AIPersonalizationTierBMasterRelayV4({
    required Map<String, Object?> masterEnvelope,
    required Map<String, Object?> telemetryMap,
  }) : _masterEnvelope = Map.of(masterEnvelope),
       _telemetryMap = Map.of(telemetryMap);

  final Map<String, Object?> _masterEnvelope;
  final Map<String, Object?> _telemetryMap;

  Map<String, Object?> asReadOnlyMap() => {
    'tier_b_master_envelope_v4': _masterEnvelope,
    'tier_b_telemetry_map_v4': _telemetryMap,
  };
}

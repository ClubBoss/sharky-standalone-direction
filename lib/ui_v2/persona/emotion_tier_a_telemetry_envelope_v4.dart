class EmotionTierATelemetryEnvelopeV4 {
  EmotionTierATelemetryEnvelopeV4({
    required Map<String, Object?> finalBundle,
    required Map<String, Object?> telemetryMap,
  }) : _finalBundle = Map.of(finalBundle),
       _telemetryMap = Map.of(telemetryMap);

  final Map<String, Object?> _finalBundle;
  final Map<String, Object?> _telemetryMap;

  Map<String, Object?> asReadOnlyMap() => {
    'tier_a_final_bundle_v4': _finalBundle,
    'tier_a_telemetry_v4': _telemetryMap,
  };
}

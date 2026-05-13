class EmotionTierAMasterBundleV4 {
  EmotionTierAMasterBundleV4({
    required Map<String, Object?> finalBundle,
    required Map<String, Object?> telemetry,
    required Map<String, Object?> relay,
  }) : _finalBundle = Map.of(finalBundle),
       _telemetry = Map.of(telemetry),
       _relay = Map.of(relay);

  final Map<String, Object?> _finalBundle;
  final Map<String, Object?> _telemetry;
  final Map<String, Object?> _relay;

  Map<String, Object?> asReadOnlyMap() => {
    'emotion_tier_a_final_bundle_v4': _finalBundle,
    'emotion_tier_a_telemetry_v4': _telemetry,
    'emotion_tier_a_relay_v4': _relay,
  };
}

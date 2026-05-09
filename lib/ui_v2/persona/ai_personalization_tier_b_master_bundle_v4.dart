class AIPersonalizationTierBMasterBundleV4 {
  AIPersonalizationTierBMasterBundleV4({
    required Map<String, Object?> finalSynthesis,
    required Map<String, Object?> telemetry,
    required Map<String, Object?> relay,
  }) : _finalSynthesis = Map.unmodifiable(finalSynthesis),
       _telemetry = Map.unmodifiable(telemetry),
       _relay = Map.unmodifiable(relay);

  final Map<String, Object?> _finalSynthesis;
  final Map<String, Object?> _telemetry;
  final Map<String, Object?> _relay;

  Map<String, Object?> asReadOnlyMap() => {
    'final_synthesis': _finalSynthesis,
    'telemetry': _telemetry,
    'relay': _relay,
  };
}

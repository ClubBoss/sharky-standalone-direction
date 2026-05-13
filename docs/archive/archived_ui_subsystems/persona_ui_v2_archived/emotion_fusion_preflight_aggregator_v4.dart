class EmotionFusionPreflightAggregatorV4 {
  EmotionFusionPreflightAggregatorV4({
    required this.fusionSynthesis,
    required this.fusionPreflight,
    required this.fusionConsistency,
    required this.fusionDelta,
  });

  final Map<String, Object?> fusionSynthesis;
  final Map<String, Object?> fusionPreflight;
  final Map<String, Object?> fusionConsistency;
  final Map<String, Object?> fusionDelta;

  Map<String, Object?> asReadOnlyMap() => {
    'synthesis': fusionSynthesis,
    'preflight': fusionPreflight,
    'consistency': fusionConsistency,
    'delta': fusionDelta,
  };
}

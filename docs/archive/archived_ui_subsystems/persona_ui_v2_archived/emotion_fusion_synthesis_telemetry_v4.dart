class EmotionFusionSynthesisTelemetryV4 {
  EmotionFusionSynthesisTelemetryV4({
    required this.finalSynthesis,
    required this.merged,
  });

  final Map<String, Object?> finalSynthesis;
  final Map<String, Object?> merged;

  Map<String, Object?> asReadOnlyMap() => {
    'final_synthesis_fusion_v4': finalSynthesis,
    'merged_fusion_v4': merged,
  };
}

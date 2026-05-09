class EmotionFusionSynthesisEnvelopeV4 {
  EmotionFusionSynthesisEnvelopeV4({
    required this.finalSynthesis,
    required this.merged,
  });

  final Map<String, Object?> finalSynthesis;
  final Map<String, Object?> merged;

  Map<String, Object?> asReadOnlyMap() => {
    'finalSynthesis': finalSynthesis,
    'merged': merged,
  };
}

class EmotionSynthesisEnvelopeV4 {
  const EmotionSynthesisEnvelopeV4({
    required this.finalLayer,
    required this.synthesis,
  });

  final Map<String, Object?> finalLayer;
  final Map<String, Object?> synthesis;

  Map<String, Object?> asReadOnlyMap() => {
    'finalLayer': finalLayer,
    'synthesis': synthesis,
  };
}

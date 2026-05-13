class EmotionSynthesisFinalV4 {
  const EmotionSynthesisFinalV4({
    required this.synthesis,
    required this.finalState,
  });

  final Map<String, Object?> synthesis;
  final String finalState;

  Map<String, Object?> asReadOnlyMap() => {
    'synthesis': synthesis,
    'finalState': finalState,
  };
}

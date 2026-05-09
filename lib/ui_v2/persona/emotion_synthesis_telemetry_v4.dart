class EmotionSynthesisTelemetryV4 {
  const EmotionSynthesisTelemetryV4({required this.envelope});

  final Map<String, Object?> envelope;

  Map<String, Object?> asTelemetryMap() => {
    'emotion_final_v4': envelope['finalLayer'],
    'emotion_synthesis_v4': envelope['synthesis'],
  };
}

class EmotionFusionPreflightGateV4 {
  const EmotionFusionPreflightGateV4({
    required this.moodReady,
    required this.toneReady,
    required this.arousalReady,
    required this.valenceReady,
  });

  final bool moodReady;
  final bool toneReady;
  final bool arousalReady;
  final bool valenceReady;

  Map<String, Object?> asReadOnlyMap() => {
    'moodReady': moodReady,
    'toneReady': toneReady,
    'arousalReady': arousalReady,
    'valenceReady': valenceReady,
  };
}

class EmotionFusionPreflightGateConsistencyV4 {
  const EmotionFusionPreflightGateConsistencyV4({
    required this.moodConsistent,
    required this.toneConsistent,
    required this.arousalConsistent,
    required this.valenceConsistent,
  });

  final bool moodConsistent;
  final bool toneConsistent;
  final bool arousalConsistent;
  final bool valenceConsistent;

  Map<String, Object?> asReadOnlyMap() => {
    'moodConsistent': moodConsistent,
    'toneConsistent': toneConsistent,
    'arousalConsistent': arousalConsistent,
    'valenceConsistent': valenceConsistent,
  };
}

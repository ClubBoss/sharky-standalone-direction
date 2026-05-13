class EmotionTierAReadinessMatrixV4 {
  EmotionTierAReadinessMatrixV4({required Map<String, Object?> synthesisMap})
    : _synthesisMap = Map.of(synthesisMap);

  final Map<String, Object?> _synthesisMap;

  Map<String, Object?> asReadOnlyMap() => {
    'mood_ready': _synthesisMap['mood'] != null,
    'tone_ready': _synthesisMap['tone'] != null,
    'arousal_ready': _synthesisMap['arousal'] != null,
    'valence_ready': _synthesisMap['valence'] != null,
  };
}

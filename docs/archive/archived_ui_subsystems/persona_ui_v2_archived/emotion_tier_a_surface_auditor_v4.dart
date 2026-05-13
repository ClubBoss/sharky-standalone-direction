class EmotionTierASurfaceAuditorV4 {
  EmotionTierASurfaceAuditorV4({required Map<String, Object?> synthesisMap})
    : _synthesisMap = Map.of(synthesisMap);

  final Map<String, Object?> _synthesisMap;

  Map<String, Object?> asReadOnlyMap() => {
    'mood_present': _synthesisMap['mood'] != null,
    'tone_present': _synthesisMap['tone'] != null,
    'arousal_present': _synthesisMap['arousal'] != null,
    'valence_present': _synthesisMap['valence'] != null,
  };
}

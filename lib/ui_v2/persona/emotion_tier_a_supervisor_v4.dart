class EmotionTierASupervisorV4 {
  EmotionTierASupervisorV4({required Map<String, Object?> readinessMatrix})
    : _readinessMatrix = Map.of(readinessMatrix);

  final Map<String, Object?> _readinessMatrix;

  Map<String, Object?> asReadOnlyMap() => {
    'mood_supervised': _readinessMatrix['mood_ready'] == true,
    'tone_supervised': _readinessMatrix['tone_ready'] == true,
    'arousal_supervised': _readinessMatrix['arousal_ready'] == true,
    'valence_supervised': _readinessMatrix['valence_ready'] == true,
  };
}

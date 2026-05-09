class EmotionTierAOutcomeResolverV4 {
  EmotionTierAOutcomeResolverV4({
    required Map<String, Object?> readinessMatrix,
    required Map<String, Object?> supervisor,
  }) : _readinessMatrix = Map.of(readinessMatrix),
       _supervisor = Map.of(supervisor);

  final Map<String, Object?> _readinessMatrix;
  final Map<String, Object?> _supervisor;

  Map<String, Object?> asReadOnlyMap() {
    final moodOk =
        _readinessMatrix['mood_ready'] == true &&
        _supervisor['mood_supervised'] == true;
    final toneOk =
        _readinessMatrix['tone_ready'] == true &&
        _supervisor['tone_supervised'] == true;
    final arousalOk =
        _readinessMatrix['arousal_ready'] == true &&
        _supervisor['arousal_supervised'] == true;
    final valenceOk =
        _readinessMatrix['valence_ready'] == true &&
        _supervisor['valence_supervised'] == true;
    final allOk = moodOk && toneOk && arousalOk && valenceOk;
    return {
      'tier_a_outcome': allOk ? 'ok' : 'warn',
      'mood_ok': moodOk,
      'tone_ok': toneOk,
      'arousal_ok': arousalOk,
      'valence_ok': valenceOk,
    };
  }
}

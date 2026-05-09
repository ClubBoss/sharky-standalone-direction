class EmotionTierAFinalBundleV4 {
  EmotionTierAFinalBundleV4({
    required Map<String, Object?> readinessMatrix,
    required Map<String, Object?> supervisor,
    required Map<String, Object?> outcome,
    required Map<String, Object?> synthesis,
  }) : _readinessMatrix = Map.of(readinessMatrix),
       _supervisor = Map.of(supervisor),
       _outcome = Map.of(outcome),
       _synthesis = Map.of(synthesis),
       tierAState = _computeTierAState(synthesis);

  final Map<String, Object?> _readinessMatrix;
  final Map<String, Object?> _supervisor;
  final Map<String, Object?> _outcome;
  final Map<String, Object?> _synthesis;
  final String tierAState;

  static String _computeTierAState(Map<String, Object?> synthesis) {
    final mood = _readDouble(synthesis['synthesizedMood']);
    final tone = _readDouble(synthesis['synthesizedTone']);
    final arousal = _readDouble(synthesis['synthesizedArousal']);
    final valence = _readDouble(synthesis['synthesizedValence']);
    final stability = [
      _readDouble(synthesis['moodStabilityScore']),
      _readDouble(synthesis['toneStabilityScore']),
      _readDouble(synthesis['arousalStabilityScore']),
      _readDouble(synthesis['valenceStabilityScore']),
    ];
    final allStable = stability.every((value) => value != null && value >= 0.7);
    return allStable ? 'ok' : 'warn';
  }

  static double? _readDouble(Object? value) {
    if (value is num) return value.toDouble();
    return null;
  }

  Map<String, Object?> asReadOnlyMap() => {
    'tier_a_state': tierAState,
    'finalMood': _synthesis['synthesizedMood'],
    'finalTone': _synthesis['synthesizedTone'],
    'finalArousal': _synthesis['synthesizedArousal'],
    'finalValence': _synthesis['synthesizedValence'],
    'finalMoodStability': _synthesis['moodStabilityScore'],
    'finalToneStability': _synthesis['toneStabilityScore'],
    'finalArousalStability': _synthesis['arousalStabilityScore'],
    'finalValenceStability': _synthesis['valenceStabilityScore'],
    'readiness': Map.of(_readinessMatrix),
    'supervisor': Map.of(_supervisor),
    'outcome': Map.of(_outcome),
  };
}

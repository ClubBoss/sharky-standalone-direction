class EmotionTierAFinalEnvelopeV4 {
  EmotionTierAFinalEnvelopeV4({required Map<String, Object?> synthesis})
    : _synthesis = Map.of(synthesis);

  final Map<String, Object?> _synthesis;

  Map<String, Object?> asReadOnlyMap() => {
    'finalMood': _synthesis['synthesizedMood'],
    'finalTone': _synthesis['synthesizedTone'],
    'finalArousal': _synthesis['synthesizedArousal'],
    'finalValence': _synthesis['synthesizedValence'],
    'finalMoodStability': _synthesis['moodStability'],
    'finalToneStability': _synthesis['toneStability'],
    'finalArousalStability': _synthesis['arousalStability'],
    'finalValenceStability': _synthesis['valenceStability'],
  };
}

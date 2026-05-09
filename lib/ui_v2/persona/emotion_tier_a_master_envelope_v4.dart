class EmotionTierAMasterEnvelopeV4 {
  EmotionTierAMasterEnvelopeV4({
    required Map<String, Object?> finalBundle,
    required Map<String, Object?> synthesis,
  }) : _finalBundle = Map.of(finalBundle),
       _synthesis = Map.of(synthesis);

  final Map<String, Object?> _finalBundle;
  final Map<String, Object?> _synthesis;

  Map<String, Object?> asReadOnlyMap() => {
    'tierAState': _finalBundle['tier_a_state'],
    'finalMood': _finalBundle['finalMood'],
    'finalTone': _finalBundle['finalTone'],
    'finalArousal': _finalBundle['finalArousal'],
    'finalValence': _finalBundle['finalValence'],
    'synthesizedMood': _synthesis['synthesizedMood'],
    'synthesizedTone': _synthesis['synthesizedTone'],
    'synthesizedArousal': _synthesis['synthesizedArousal'],
    'synthesizedValence': _synthesis['synthesizedValence'],
    'stabilityMood': _finalBundle['finalMoodStability'],
    'stabilityTone': _finalBundle['finalToneStability'],
    'stabilityArousal': _finalBundle['finalArousalStability'],
    'stabilityValence': _finalBundle['finalValenceStability'],
    'coherenceScore': _finalBundle['coherenceScore'],
    'tierAFinalFlag': _finalBundle['tierAFinalFlag'],
    'finalBundle': Map.of(_finalBundle),
    'synthesis': Map.of(_synthesis),
  };
}

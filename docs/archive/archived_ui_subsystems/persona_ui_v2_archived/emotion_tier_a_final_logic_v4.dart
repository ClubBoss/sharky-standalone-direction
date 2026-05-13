class EmotionTierAFinalLogicV4 {
  EmotionTierAFinalLogicV4({required Map<String, Object?> synthesis})
    : _synthesis = Map.of(synthesis),
      coherenceScore = _computeCoherence(synthesis),
      tierAFinalFlag = _computeCoherence(synthesis) >= 0.75,
      finalTierAState = _deriveState(synthesis);

  final Map<String, Object?> _synthesis;
  final double coherenceScore;
  final bool tierAFinalFlag;
  final String finalTierAState;

  static String _deriveState(Map<String, Object?> synthesis) {
    final bool? moodStable = synthesis['moodStable'] as bool?;
    final bool? toneStable = synthesis['toneStable'] as bool?;
    final bool? arousalStable = synthesis['arousalStable'] as bool?;
    final bool? valenceStable = synthesis['valenceStable'] as bool?;
    final allStable = [
      moodStable == true,
      toneStable == true,
      arousalStable == true,
      valenceStable == true,
    ].every((value) => value);
    return allStable ? 'ok' : 'warn';
  }

  static double _computeCoherence(Map<String, Object?> synthesis) {
    final values = [
      synthesis['moodStabilityScore'],
      synthesis['toneStabilityScore'],
      synthesis['arousalStabilityScore'],
      synthesis['valenceStabilityScore'],
    ];
    final nums = values
        .whereType<num>()
        .map((value) => value.toDouble())
        .toList(growable: false);
    if (nums.isEmpty) return 0.0;
    final sum = nums.reduce((a, b) => a + b);
    return sum / nums.length;
  }

  Map<String, Object?> asReadOnlyMap() => {
    'finalMood': _synthesis['synthesizedMood'],
    'finalTone': _synthesis['synthesizedTone'],
    'finalArousal': _synthesis['synthesizedArousal'],
    'finalValence': _synthesis['synthesizedValence'],
    'finalMoodStability': _synthesis['moodStabilityScore'],
    'finalToneStability': _synthesis['toneStabilityScore'],
    'finalArousalStability': _synthesis['arousalStabilityScore'],
    'finalValenceStability': _synthesis['valenceStabilityScore'],
    'finalTierAState': finalTierAState,
    'coherenceScore': coherenceScore,
    'tierAFinalFlag': tierAFinalFlag,
    'finalLogic': Map.of(_synthesis),
  };
}

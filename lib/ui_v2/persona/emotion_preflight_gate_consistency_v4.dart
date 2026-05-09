class EmotionPreflightGateConsistencyV4 {
  const EmotionPreflightGateConsistencyV4({
    required this.isConsistentMood,
    required this.isConsistentTone,
    required this.isConsistentArousal,
    required this.isConsistentValence,
  });

  final bool isConsistentMood;
  final bool isConsistentTone;
  final bool isConsistentArousal;
  final bool isConsistentValence;

  Map<String, Object?> asReadOnlyMap() => {
    'isConsistentMood': isConsistentMood,
    'isConsistentTone': isConsistentTone,
    'isConsistentArousal': isConsistentArousal,
    'isConsistentValence': isConsistentValence,
  };
}

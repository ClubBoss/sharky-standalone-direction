class EmotionPreflightGateV4 {
  const EmotionPreflightGateV4({
    required this.isReadyMood,
    required this.isReadyTone,
    required this.isReadyArousal,
    required this.isReadyValence,
  });

  final bool isReadyMood;
  final bool isReadyTone;
  final bool isReadyArousal;
  final bool isReadyValence;

  Map<String, Object?> asReadOnlyMap() => {
    'isReadyMood': isReadyMood,
    'isReadyTone': isReadyTone,
    'isReadyArousal': isReadyArousal,
    'isReadyValence': isReadyValence,
  };
}

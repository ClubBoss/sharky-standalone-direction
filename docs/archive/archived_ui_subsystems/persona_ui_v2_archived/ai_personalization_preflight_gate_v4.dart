class AIPersonalizationPreflightGateV4 {
  const AIPersonalizationPreflightGateV4({
    required this.isSeedReady,
    required this.isVectorReady,
  });

  final bool isSeedReady;
  final bool isVectorReady;

  Map<String, Object?> asReadOnlyMap() => {
    'isSeedReady': isSeedReady,
    'isVectorReady': isVectorReady,
  };
}

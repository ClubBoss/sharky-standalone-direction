class AIPersonalizationDeltaV4 {
  AIPersonalizationDeltaV4({
    required this.seedDelta,
    required this.vectorDelta,
  });

  final bool seedDelta;
  final bool vectorDelta;

  Map<String, Object?> asReadOnlyMap() => {
    'seedDelta': seedDelta,
    'vectorDelta': vectorDelta,
  };
}

class AIPersonalizationPreflightDeltaV4 {
  AIPersonalizationPreflightDeltaV4({
    required bool hasSeed,
    required bool hasVector,
    required bool seedConsistent,
    required bool vectorConsistent,
  }) : seedDelta = hasSeed != seedConsistent,
       vectorDelta = hasVector != vectorConsistent;

  final bool seedDelta;
  final bool vectorDelta;

  Map<String, Object?> asReadOnlyMap() => {
    'seedDelta': seedDelta,
    'vectorDelta': vectorDelta,
  };
}

class AIPersonalizationPreflightV4 {
  AIPersonalizationPreflightV4({
    required this.hasSeed,
    required this.hasVector,
  });

  final bool hasSeed;
  final bool hasVector;

  Map<String, Object?> asReadOnlyMap() => {
    'hasSeed': hasSeed,
    'hasVector': hasVector,
  };
}

class AIPersonalizationSeedV4 {
  const AIPersonalizationSeedV4({
    this.learningRate,
    this.adaptationRate,
    this.stabilityFactor,
    this.confidenceFactor,
  });

  final double? learningRate;
  final double? adaptationRate;
  final double? stabilityFactor;
  final double? confidenceFactor;

  Map<String, Object?> asReadOnlyMap() => {
    'learningRate': learningRate,
    'adaptationRate': adaptationRate,
    'stabilityFactor': stabilityFactor,
    'confidenceFactor': confidenceFactor,
  };
}

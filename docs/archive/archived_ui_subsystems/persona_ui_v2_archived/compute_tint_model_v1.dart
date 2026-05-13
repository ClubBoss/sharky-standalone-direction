class ComputeTintModelV1 {
  const ComputeTintModelV1({this.warmth, this.sharpness, this.intensity});

  final double? warmth;
  final double? sharpness;
  final double? intensity;

  double computeTintStrength() {
    if (intensity == null) return 0.0;
    final v = intensity!.clamp(0.0, 1.0);
    return (v * 0.5);
  }

  double computeWarmthFactor() {
    // TODO Phase-4 warmth logic
    return (warmth ?? 0.0).clamp(0.0, 1.0);
  }

  double computeSharpnessFactor() {
    // TODO Phase-4 sharpness logic
    return (sharpness ?? 0.0).clamp(0.0, 1.0);
  }
}

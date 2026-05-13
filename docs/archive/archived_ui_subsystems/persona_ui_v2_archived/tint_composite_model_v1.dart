class TintCompositeModelV1 {
  const TintCompositeModelV1({this.intensity, this.warmth, this.sharpness});

  final double? intensity;
  final double? warmth;
  final double? sharpness;

  double computeCompositeStrength() {
    final wi = (intensity ?? 0.0).clamp(0.0, 1.0);
    final ww = (warmth ?? 0.0).clamp(0.0, 1.0);
    final ws = (sharpness ?? 0.0).clamp(0.0, 1.0);

    final composite = (wi * 0.5) + (ww * 0.3) + (ws * 0.2);
    return composite.clamp(0.0, 1.0);
  }
}

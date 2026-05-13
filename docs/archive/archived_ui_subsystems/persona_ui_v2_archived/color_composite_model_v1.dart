class ColorCompositeModelV1 {
  const ColorCompositeModelV1({
    this.hueShift,
    this.saturationBoost,
    this.contrastBoost,
  });

  final double? hueShift;
  final double? saturationBoost;
  final double? contrastBoost;

  double computeCompositeStrength() {
    // TODO Phase-5 composite v2
    final h = (hueShift ?? 0.0).clamp(0.0, 1.0);
    final s = (saturationBoost ?? 0.0).clamp(0.0, 1.0);
    final c = (contrastBoost ?? 0.0).clamp(0.0, 1.0);

    final h2 = (h * 0.6 + h * h * 0.4);
    final s2 = (s * 0.5 + s * s * 0.5);
    final c2 = (c * 0.4 + c * c * 0.6);

    final blend = h2 * 0.5 + s2 * 0.3 + c2 * 0.2;
    return blend.clamp(0.0, 1.0);
  }
}

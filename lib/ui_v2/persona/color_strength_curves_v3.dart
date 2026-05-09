class ColorStrengthCurvesV3 {
  const ColorStrengthCurvesV3({
    required this.hue,
    required this.saturation,
    required this.contrast,
  });

  final double hue;
  final double saturation;
  final double contrast;

  double applyHueCurve() {
    // TODO Phase-5: V3 hue curve
    return hue.clamp(0.0, 1.0);
  }

  double applySaturationCurve() {
    // TODO Phase-5: V3 saturation curve
    return saturation.clamp(0.0, 1.0);
  }

  double applyContrastCurve() {
    // TODO Phase-5: V3 contrast curve
    return contrast.clamp(0.0, 1.0);
  }
}

class TypographyPolishEntry {
  const TypographyPolishEntry({
    required this.resolvedFontSize,
    required this.resolvedSpacing,
    required this.resolvedWeight,
    required this.ready,
  });

  final double resolvedFontSize;
  final double resolvedSpacing;
  final double resolvedWeight;
  final bool ready;
}

class TypographyV4PolishV1 {
  const TypographyV4PolishV1();

  static TypographyPolishEntry buildTypographyPolish({
    required double scale,
    required double baseFontSize,
    required double letterSpacing,
    required double weightBias,
  }) {
    final double safeScale = scale.isFinite && scale >= 0 ? scale : 0.0;
    final double safeBase = baseFontSize.isFinite && baseFontSize >= 0
        ? baseFontSize
        : 0.0;
    final double safeSpacing = letterSpacing.isFinite && letterSpacing >= 0
        ? letterSpacing
        : 0.0;
    final double safeBias = weightBias.isFinite
        ? weightBias.clamp(0.0, 1.0)
        : 0.0;
    final double fontSize = safeBase * safeScale;
    final double spacing = safeSpacing * safeScale;
    final double weight = (400 + (300 * safeBias)).clamp(400.0, 700.0);
    return TypographyPolishEntry(
      resolvedFontSize: fontSize,
      resolvedSpacing: spacing,
      resolvedWeight: weight,
      ready: true,
    );
  }
}

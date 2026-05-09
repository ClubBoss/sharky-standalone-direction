class DynamicThemeSpec {
  const DynamicThemeSpec({
    required this.accentHex,
    required this.spacingScale,
    required this.typographyWeight,
    required this.overlayStrength,
    required this.brightness,
    required this.densityDelta,
    required this.recommendation,
  });

  final String accentHex;
  final double spacingScale;
  final double typographyWeight;
  final double overlayStrength;
  final String brightness;
  final double densityDelta;
  final String recommendation;

  double spacingMultiplier(double baseValue) => baseValue * spacingScale;

  Map<String, Object?> toJson() => <String, Object?>{
    'accent_hex': accentHex,
    'spacing_scale': spacingScale,
    'typography_weight': typographyWeight,
    'overlay_strength': overlayStrength,
    'brightness': brightness,
    'density_delta': densityDelta,
  };
}

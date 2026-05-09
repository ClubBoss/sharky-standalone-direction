class VisualIdentityV4Kernel {
  const VisualIdentityV4Kernel({
    required this.baseRadius,
    required this.baseShadowStrength,
    required this.baseContrastLevel,
  });

  final double baseRadius;
  final double baseShadowStrength;
  final double baseContrastLevel;

  Map<String, double> exportBase() {
    // TODO Phase-7: visual identity V4 export logic
    return {
      'radius': baseRadius,
      'shadow': baseShadowStrength,
      'contrast': baseContrastLevel,
    };
  }
}

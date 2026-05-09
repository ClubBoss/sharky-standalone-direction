class V4IdentityEffectiveStyle {
  final double radius;
  final double shadow;
  final double contrast;
  final double colorStrength;

  const V4IdentityEffectiveStyle({
    required this.radius,
    required this.shadow,
    required this.contrast,
    required this.colorStrength,
  });

  Map<String, dynamic> export() {
    return {
      'radius': radius,
      'shadow': shadow,
      'contrast': contrast,
      'colorStrength': colorStrength,
    };
  }

  static V4IdentityEffectiveStyle fromSources({
    double baseRadius = 0.0,
    double baseShadow = 0.0,
    double baseContrast = 1.0,
    double baseColorStrength = 0.0,
    double descRadiusDelta = 0.0,
    double descShadowDelta = 0.0,
    double descContrastDelta = 0.0,
    double descColorDelta = 0.0,
    double tierRadius = 0.0,
    double tierShadow = 0.0,
    double tierContrast = 0.0,
    double tierColor = 0.0,
  }) {
    return V4IdentityEffectiveStyle(
      radius: baseRadius + tierRadius + descRadiusDelta,
      shadow: baseShadow + tierShadow + descShadowDelta,
      contrast: baseContrast + tierContrast + descContrastDelta,
      colorStrength: baseColorStrength + tierColor + descColorDelta,
    );
  }
}

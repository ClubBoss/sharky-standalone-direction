class V4IdentityPreviewEnforcement {
  final double radius;
  final double shadowBlur;
  final double contrast;
  final double colorStrength;

  const V4IdentityPreviewEnforcement({
    required this.radius,
    required this.shadowBlur,
    required this.contrast,
    required this.colorStrength,
  });

  Map<String, dynamic> export() {
    return {
      'radius': radius,
      'shadowBlur': shadowBlur,
      'contrast': contrast,
      'colorStrength': colorStrength,
    };
  }
}

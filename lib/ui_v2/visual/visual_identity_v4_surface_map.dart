class VisualIdentityV4SurfaceMap {
  const VisualIdentityV4SurfaceMap({
    required this.v3Surface,
    required this.v4Surface,
    required this.radiusTier,
    required this.shadowTier,
    required this.contrastTier,
  });

  final String v3Surface;
  final String v4Surface;
  final double radiusTier;
  final double shadowTier;
  final double contrastTier;

  Map<String, Object> exportMap() {
    // TODO Phase-8: surface remapping logic
    return {
      'v3': v3Surface,
      'v4': v4Surface,
      'radius': radiusTier,
      'shadow': shadowTier,
      'contrast': contrastTier,
    };
  }
}

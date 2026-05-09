class VisualIdentityV4ApplicationKernel {
  const VisualIdentityV4ApplicationKernel({
    required this.v4Role,
    required this.radiusTier,
    required this.shadowTier,
    required this.contrastTier,
  });

  final String v4Role;
  final double radiusTier;
  final double shadowTier;
  final double contrastTier;

  Map<String, Object> exportApplication() {
    // TODO Phase-8: application logic
    return {
      'role': v4Role,
      'radius': radiusTier,
      'shadow': shadowTier,
      'contrast': contrastTier,
    };
  }
}

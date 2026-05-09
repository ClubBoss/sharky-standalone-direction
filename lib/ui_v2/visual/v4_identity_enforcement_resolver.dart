class V4IdentityEnforcementResolver {
  final dynamic unifiedBundle;
  final dynamic mergedSkeleton;
  final dynamic mergedOverrides;

  V4IdentityEnforcementResolver({
    this.unifiedBundle,
    this.mergedSkeleton,
    this.mergedOverrides,
  });

  bool isReady() =>
      unifiedBundle != null &&
      mergedSkeleton != null &&
      mergedOverrides != null;

  Map<String, dynamic> resolve() => const {};

  Map<String, dynamic> export() => {
    'hasUnified': unifiedBundle != null,
    'hasSkeleton': mergedSkeleton != null,
    'hasOverrides': mergedOverrides != null,
    'ready': isReady(),
  };
}

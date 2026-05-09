class V4TokenLiftSkeletonV1 {
  const V4TokenLiftSkeletonV1({
    required this.themeLiftStructuralBinderSnapshot,
    required this.personaAdaptiveThemeBuilderV2Snapshot,
    required this.personaAdaptiveBlendV2Snapshot,
    required this.personaAdaptiveProxyV2Snapshot,
  });

  final Object themeLiftStructuralBinderSnapshot;
  final Object personaAdaptiveThemeBuilderV2Snapshot;
  final Object personaAdaptiveBlendV2Snapshot;
  final Object personaAdaptiveProxyV2Snapshot;

  Map<String, String> asReadOnlyMap() => {
    'token_lift': '<opaque>',
    'binder': '<opaque>',
    'builder_v2': '<opaque>',
    'blend_v2': '<opaque>',
    'proxy_v2': '<opaque>',
  };
}

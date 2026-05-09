class AdaptiveRenderingPreviewSnapshotV1 {
  const AdaptiveRenderingPreviewSnapshotV1({
    required this.visualMergeLayerSnapshot,
    required this.personaAdaptiveTokenMappingSnapshot,
    required this.tokenLiftSkeletonSnapshot,
    required this.themeLiftStructuralBinderSnapshot,
    required this.personaAdaptiveThemeBuilderV2Snapshot,
    required this.personaAdaptiveBlendV2Snapshot,
    required this.personaAdaptiveProxyV2Snapshot,
  });

  final Object visualMergeLayerSnapshot;
  final Object personaAdaptiveTokenMappingSnapshot;
  final Object tokenLiftSkeletonSnapshot;
  final Object themeLiftStructuralBinderSnapshot;
  final Object personaAdaptiveThemeBuilderV2Snapshot;
  final Object personaAdaptiveBlendV2Snapshot;
  final Object personaAdaptiveProxyV2Snapshot;

  Map<String, String> asReadOnlyMap() => {
    'preview': '<opaque>',
    'merge': '<opaque>',
    'token_mapping': '<opaque>',
    'token_lift': '<opaque>',
    'binder': '<opaque>',
    'builder_v2': '<opaque>',
    'blend_v2': '<opaque>',
    'proxy_v2': '<opaque>',
  };
}

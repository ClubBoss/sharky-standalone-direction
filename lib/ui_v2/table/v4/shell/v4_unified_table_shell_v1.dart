class V4UnifiedTableShellV1 {
  const V4UnifiedTableShellV1({
    required this.renderingPassSnapshot,
    required this.interactionAggregatorSnapshot,
    required this.visualFusionSnapshot,
    required this.depthSnapshot,
    required this.fpsSnapshot,
    required this.cohesionV4Snapshot,
  });

  final Object renderingPassSnapshot;
  final Object interactionAggregatorSnapshot;
  final Object visualFusionSnapshot;
  final Object depthSnapshot;
  final Object fpsSnapshot;
  final Object cohesionV4Snapshot;

  Map<String, String> asReadOnlyMap() => {
    'shell': '<opaque>',
    'rendering': '<opaque>',
    'interaction': '<opaque>',
    'fusion': '<opaque>',
    'depth': '<opaque>',
    'fps': '<opaque>',
    'cohesion': '<opaque>',
  };
}

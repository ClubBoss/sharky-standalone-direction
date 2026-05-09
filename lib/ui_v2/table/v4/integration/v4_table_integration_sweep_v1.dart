class V4TableIntegrationSweepV1 {
  const V4TableIntegrationSweepV1({
    required this.unifiedShellSnapshot,
    required this.renderingPassSnapshot,
    required this.interactionAggregatorSnapshot,
    required this.visualFusionSnapshot,
    required this.depthSnapshot,
    required this.fpsSnapshot,
    required this.cohesionV4Snapshot,
  });

  final Object unifiedShellSnapshot;
  final Object renderingPassSnapshot;
  final Object interactionAggregatorSnapshot;
  final Object visualFusionSnapshot;
  final Object depthSnapshot;
  final Object fpsSnapshot;
  final Object cohesionV4Snapshot;

  Map<String, String> asReadOnlyMap() => {
    'integration': '<opaque>',
    'shell': '<opaque>',
    'rendering': '<opaque>',
    'interaction': '<opaque>',
    'fusion': '<opaque>',
    'depth': '<opaque>',
    'fps': '<opaque>',
    'cohesion': '<opaque>',
  };
}

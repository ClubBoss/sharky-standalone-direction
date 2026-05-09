class V4TableRenderingPassV1 {
  const V4TableRenderingPassV1({
    required this.interactionAggregatorSnapshot,
    required this.depthSnapshot,
    required this.fpsSnapshot,
    required this.fusionSnapshot,
    required this.cohesionV4Snapshot,
  });

  final Object interactionAggregatorSnapshot;
  final Object depthSnapshot;
  final Object fpsSnapshot;
  final Object fusionSnapshot;
  final Object cohesionV4Snapshot;

  Map<String, String> asReadOnlyMap() => {
    'rendering_pass': '<opaque>',
    'interaction': '<opaque>',
    'depth': '<opaque>',
    'fps': '<opaque>',
    'fusion': '<opaque>',
    'cohesion': '<opaque>',
  };
}

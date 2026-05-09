class V4TableVisualFusionV1 {
  const V4TableVisualFusionV1({
    required this.depthSnapshot,
    required this.fpsSnapshot,
    required this.cohesionV4Snapshot,
    required this.visualLayerBindSnapshot,
  });

  final Object depthSnapshot;
  final Object fpsSnapshot;
  final Object cohesionV4Snapshot;
  final Object visualLayerBindSnapshot;

  Map<String, String> asReadOnlyMap() => {
    'fusion': '<opaque>',
    'depth': '<opaque>',
    'fps': '<opaque>',
    'cohesion': '<opaque>',
    'layer': '<opaque>',
  };
}

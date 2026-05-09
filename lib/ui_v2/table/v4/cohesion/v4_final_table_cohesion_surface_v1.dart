class V4FinalTableCohesionSurfaceV1 {
  const V4FinalTableCohesionSurfaceV1({
    required this.integrationSweepSnapshot,
    required this.unifiedShellSnapshot,
    required this.renderingPassSnapshot,
    required this.visualFusionSnapshot,
    required this.cohesionV4Snapshot,
    required this.depthSnapshot,
    required this.fpsSnapshot,
  });

  final Object integrationSweepSnapshot;
  final Object unifiedShellSnapshot;
  final Object renderingPassSnapshot;
  final Object visualFusionSnapshot;
  final Object cohesionV4Snapshot;
  final Object depthSnapshot;
  final Object fpsSnapshot;

  Map<String, String> asReadOnlyMap() => {
    'surface': '<opaque>',
    'integration': '<opaque>',
    'shell': '<opaque>',
    'rendering': '<opaque>',
    'fusion': '<opaque>',
    'cohesion': '<opaque>',
    'depth': '<opaque>',
    'fps': '<opaque>',
  };
}

class V4TableInteractionSkeletonV1 {
  const V4TableInteractionSkeletonV1({
    required this.depthSnapshot,
    required this.fpsSnapshot,
    required this.fusionSnapshot,
    required this.cohesionV4Snapshot,
  });

  final Object depthSnapshot;
  final Object fpsSnapshot;
  final Object fusionSnapshot;
  final Object cohesionV4Snapshot;

  Map<String, String> asReadOnlyMap() => {
    'interaction_skeleton': '<opaque>',
    'depth': '<opaque>',
    'fps': '<opaque>',
    'fusion': '<opaque>',
    'cohesion': '<opaque>',
  };
}

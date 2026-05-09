class V4TableInteractionBinderV1 {
  const V4TableInteractionBinderV1({
    required this.interactionSkeletonSnapshot,
    required this.depthSnapshot,
    required this.fpsSnapshot,
    required this.fusionSnapshot,
    required this.cohesionV4Snapshot,
  });

  final Object interactionSkeletonSnapshot;
  final Object depthSnapshot;
  final Object fpsSnapshot;
  final Object fusionSnapshot;
  final Object cohesionV4Snapshot;

  Map<String, String> asReadOnlyMap() => {
    'interaction_binder': '<opaque>',
    'skeleton': '<opaque>',
    'depth': '<opaque>',
    'fps': '<opaque>',
    'fusion': '<opaque>',
    'cohesion': '<opaque>',
  };
}

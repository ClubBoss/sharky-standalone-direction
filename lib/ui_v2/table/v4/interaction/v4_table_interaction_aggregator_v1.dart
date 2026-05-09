class V4TableInteractionAggregatorV1 {
  const V4TableInteractionAggregatorV1({
    required this.interactionSkeletonSnapshot,
    required this.interactionBinderSnapshot,
    required this.depthSnapshot,
    required this.fpsSnapshot,
    required this.fusionSnapshot,
    required this.cohesionV4Snapshot,
  });

  final Object interactionSkeletonSnapshot;
  final Object interactionBinderSnapshot;
  final Object depthSnapshot;
  final Object fpsSnapshot;
  final Object fusionSnapshot;
  final Object cohesionV4Snapshot;

  Map<String, String> asReadOnlyMap() => {
    'interaction_aggregator': '<opaque>',
    'skeleton': '<opaque>',
    'binder': '<opaque>',
    'depth': '<opaque>',
    'fps': '<opaque>',
    'fusion': '<opaque>',
    'cohesion': '<opaque>',
  };
}

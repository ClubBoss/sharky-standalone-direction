class V4TableMountAggregatorV1 {
  const V4TableMountAggregatorV1({
    required this.mountingBinderSnapshot,
    required this.mountingBridgeSnapshot,
    required this.gestureSkeletonSnapshot,
    required this.motionBridgeSnapshot,
    required this.uiRenderSnapshot,
  });

  final Object mountingBinderSnapshot;
  final Object mountingBridgeSnapshot;
  final Object gestureSkeletonSnapshot;
  final Object motionBridgeSnapshot;
  final Object uiRenderSnapshot;

  Map<String, String> asReadOnlyMap() => {
    'mount_aggregator_ok': 'true',
    'binder': mountingBinderSnapshot.toString(),
    'bridge': mountingBridgeSnapshot.toString(),
    'gesture': gestureSkeletonSnapshot.toString(),
    'motion': motionBridgeSnapshot.toString(),
    'render': uiRenderSnapshot.toString(),
  };
}

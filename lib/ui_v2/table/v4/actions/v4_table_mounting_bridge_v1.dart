class V4TableMountingBridgeV1 {
  const V4TableMountingBridgeV1({
    required this.gestureSkeletonSnapshot,
    required this.motionBridgeSnapshot,
    required this.uiRenderSnapshot,
    required this.hitZonesSnapshot,
  });

  final Object gestureSkeletonSnapshot;
  final Object motionBridgeSnapshot;
  final Object uiRenderSnapshot;
  final Object hitZonesSnapshot;

  Map<String, String> asReadOnlyMap() => {
    'mount_ready': 'true',
    'gesture': gestureSkeletonSnapshot.toString(),
    'motion': motionBridgeSnapshot.toString(),
    'render': uiRenderSnapshot.toString(),
    'hitzones': hitZonesSnapshot.toString(),
  };
}

class V4TableMountingBinderV1 {
  const V4TableMountingBinderV1({
    required this.mountingBridgeSnapshot,
    required this.gestureSkeletonSnapshot,
    required this.motionBridgeSnapshot,
    required this.uiRenderSnapshot,
  });

  final Object mountingBridgeSnapshot;
  final Object gestureSkeletonSnapshot;
  final Object motionBridgeSnapshot;
  final Object uiRenderSnapshot;

  Map<String, String> asReadOnlyMap() => {
    'binder_ok': 'true',
    'bridge': mountingBridgeSnapshot.toString(),
    'gesture': gestureSkeletonSnapshot.toString(),
    'motion': motionBridgeSnapshot.toString(),
    'render': uiRenderSnapshot.toString(),
  };
}

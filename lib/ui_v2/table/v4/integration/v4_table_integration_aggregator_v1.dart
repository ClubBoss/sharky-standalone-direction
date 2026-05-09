class V4TableIntegrationAggregatorV1 {
  const V4TableIntegrationAggregatorV1({
    required this.integrationBinderSnapshot,
    required this.integrationSweepSnapshot,
    required this.layoutFinalizerSnapshot,
    required this.layoutRouterSnapshot,
    required this.layoutHubSnapshot,
    required this.layoutMountSnapshot,
    required this.layoutBridgeSnapshot,
    required this.layoutFrameSnapshot,
    required this.containerBoxSnapshot,
    required this.uiShellSnapshot,
  });

  final Object integrationBinderSnapshot;
  final Object integrationSweepSnapshot;
  final Object layoutFinalizerSnapshot;
  final Object layoutRouterSnapshot;
  final Object layoutHubSnapshot;
  final Object layoutMountSnapshot;
  final Object layoutBridgeSnapshot;
  final Object layoutFrameSnapshot;
  final Object containerBoxSnapshot;
  final Object uiShellSnapshot;

  Map<String, String> asReadOnlyMap() => {
    'table_integration_aggregator_ok': 'true',
    'binder': integrationBinderSnapshot.toString(),
    'sweep': integrationSweepSnapshot.toString(),
    'finalizer': layoutFinalizerSnapshot.toString(),
    'router': layoutRouterSnapshot.toString(),
    'hub': layoutHubSnapshot.toString(),
    'mount': layoutMountSnapshot.toString(),
    'bridge': layoutBridgeSnapshot.toString(),
    'frame': layoutFrameSnapshot.toString(),
    'container': containerBoxSnapshot.toString(),
    'shell': uiShellSnapshot.toString(),
  };
}

class V4ActionSurfaceIntegrationFinalizerV1 {
  const V4ActionSurfaceIntegrationFinalizerV1({
    required this.mergeBridgeSnapshot,
    required this.visualPrepSnapshot,
    required this.bindingBridgeSnapshot,
    required this.contextAdapterSnapshot,
    required this.mountAggregatorSnapshot,
  });

  final Object mergeBridgeSnapshot;
  final Object visualPrepSnapshot;
  final Object bindingBridgeSnapshot;
  final Object contextAdapterSnapshot;
  final Object mountAggregatorSnapshot;

  Map<String, String> asReadOnlyMap() => {
    'integration_finalizer_ok': 'true',
    'merge': mergeBridgeSnapshot.toString(),
    'visual': visualPrepSnapshot.toString(),
    'binding': bindingBridgeSnapshot.toString(),
    'context': contextAdapterSnapshot.toString(),
    'mount': mountAggregatorSnapshot.toString(),
  };
}

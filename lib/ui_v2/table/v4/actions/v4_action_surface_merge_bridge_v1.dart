class V4ActionSurfaceMergeBridgeV1 {
  const V4ActionSurfaceMergeBridgeV1({
    required this.visualPrepSnapshot,
    required this.bindingBridgeSnapshot,
    required this.contextAdapterSnapshot,
    required this.mountAggregatorSnapshot,
  });

  final Object visualPrepSnapshot;
  final Object bindingBridgeSnapshot;
  final Object contextAdapterSnapshot;
  final Object mountAggregatorSnapshot;

  Map<String, String> asReadOnlyMap() => {
    'merge_bridge_ok': 'true',
    'visual': visualPrepSnapshot.toString(),
    'binding': bindingBridgeSnapshot.toString(),
    'context': contextAdapterSnapshot.toString(),
    'mount': mountAggregatorSnapshot.toString(),
  };
}

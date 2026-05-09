class V4ActionSurfaceBindingBridgeV1 {
  const V4ActionSurfaceBindingBridgeV1({
    required this.contextAdapterSnapshot,
    required this.mountAggregatorSnapshot,
    required this.personaSnapshot,
    required this.tierASnapshot,
    required this.tierBSnapshot,
  });

  final Object contextAdapterSnapshot;
  final Object mountAggregatorSnapshot;
  final Object personaSnapshot;
  final Object tierASnapshot;
  final Object tierBSnapshot;

  Map<String, String> asReadOnlyMap() => {
    'binding_ok': 'true',
    'context': contextAdapterSnapshot.toString(),
    'mount': mountAggregatorSnapshot.toString(),
    'persona': personaSnapshot.toString(),
    'tier_a': tierASnapshot.toString(),
    'tier_b': tierBSnapshot.toString(),
  };
}

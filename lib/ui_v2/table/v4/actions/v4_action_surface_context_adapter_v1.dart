class V4ActionSurfaceContextAdapterV1 {
  const V4ActionSurfaceContextAdapterV1({
    required this.mountAggregatorSnapshot,
    required this.personaSnapshot,
    required this.tierASnapshot,
    required this.tierBSnapshot,
  });

  final Object mountAggregatorSnapshot;
  final Object personaSnapshot;
  final Object tierASnapshot;
  final Object tierBSnapshot;

  Map<String, String> asReadOnlyMap() => {
    'context_adapter_ok': 'true',
    'mount': mountAggregatorSnapshot.toString(),
    'persona': personaSnapshot.toString(),
    'tier_a': tierASnapshot.toString(),
    'tier_b': tierBSnapshot.toString(),
  };
}

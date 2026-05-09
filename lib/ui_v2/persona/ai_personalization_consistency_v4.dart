class AIPersonalizationConsistencyV4 {
  AIPersonalizationConsistencyV4({
    required Map<String, Object?> seed,
    required Map<String, Object?> vector,
  }) : _seed = Map.of(seed),
       _vector = Map.of(vector),
       seedPresent = seed.isNotEmpty,
       vectorPresent = vector.isNotEmpty,
       seedVectorConsistent = seed.isNotEmpty == vector.isNotEmpty;

  final Map<String, Object?> _seed;
  final Map<String, Object?> _vector;
  final bool seedPresent;
  final bool vectorPresent;
  final bool seedVectorConsistent;

  Map<String, Object?> asReadOnlyMap() => {
    'seedPresent': seedPresent,
    'vectorPresent': vectorPresent,
    'seedVectorConsistent': seedVectorConsistent,
  };
}

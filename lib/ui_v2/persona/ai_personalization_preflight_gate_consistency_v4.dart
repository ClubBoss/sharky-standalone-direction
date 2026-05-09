class AIPersonalizationPreflightGateConsistencyV4 {
  const AIPersonalizationPreflightGateConsistencyV4({
    required this.seedConsistent,
    required this.vectorConsistent,
  });

  final bool seedConsistent;
  final bool vectorConsistent;

  Map<String, Object?> asReadOnlyMap() => {
    'seedConsistent': seedConsistent,
    'vectorConsistent': vectorConsistent,
  };
}

class CanonicalAtomMappingInputV1 {
  const CanonicalAtomMappingInputV1({
    required this.sourceFamily,
    required this.sourceWorld,
    required this.sourceSessionId,
    required this.exactTargetId,
    required this.signalFamilyId,
  });

  final String sourceFamily;
  final String sourceWorld;
  final String sourceSessionId;
  final String exactTargetId;
  final String signalFamilyId;

  String get normalizedTupleKey => <String>[
    sourceFamily,
    sourceWorld,
    sourceSessionId,
    exactTargetId,
    signalFamilyId,
  ].map((value) => value.trim().toLowerCase()).join('|');
}

class CanonicalAtomMappingRegistryV1 {
  const CanonicalAtomMappingRegistryV1();

  /// This table is intentionally empty until a reviewed source tuple proves an
  /// Act0 <-> W5/W6 atom equivalence. Unknown tuples fail closed to null.
  static const Map<String, String> _approvedCanonicalAtomIdsByTupleV1 =
      <String, String>{};

  String? resolve(CanonicalAtomMappingInputV1 input) {
    return _approvedCanonicalAtomIdsByTupleV1[input.normalizedTupleKey];
  }
}

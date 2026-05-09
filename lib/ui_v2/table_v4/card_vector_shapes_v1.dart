/// Passive card vector shapes layer (Phi-57.4).
class CardVectorShapesV1 {
  const CardVectorShapesV1(this.primitivesMap, this.accentRouting);

  final Object primitivesMap;
  final Object accentRouting;

  Map<String, Object> asReadOnlyMap() {
    final Object primitivesCandidate = primitivesMap;
    final Object accentCandidate = accentRouting;
    final bool hasPrimitives =
        primitivesCandidate is Map && primitivesCandidate.isNotEmpty;
    final bool hasAccent = accentCandidate is Map && accentCandidate.isNotEmpty;
    final List<String> missing = <String>[];
    if (!hasPrimitives) missing.add('primitives');
    if (!hasAccent) missing.add('accent');
    final Map<String, Object> rankShapes = <String, Object>{
      'paths': <String>['M0,0 L1,1', 'M1,0 L0,1'],
    };
    final Map<String, Object> suitShapes = <String, Object>{
      'paths': <String>['M0,0 L0.5,1 L1,0 Z'],
    };
    final Map<String, Object> cornerDecals = <String, Object>{
      'paths': <String>['M0,0 L0.2,0 L0.2,0.2 L0,0.2 Z'],
    };
    final bool readiness = missing.isEmpty;
    return <String, Object>{
      'rank_shapes': rankShapes,
      'suit_shapes': suitShapes,
      'corner_decals': cornerDecals,
      'readiness': readiness,
      'missing': missing,
    };
  }
}

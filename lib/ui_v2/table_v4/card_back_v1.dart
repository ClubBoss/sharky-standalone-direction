/// Passive card back composition V1 (Phi-57.6).
class CardBackV1 {
  const CardBackV1(this.primitivesMap, this.shapesMap, this.renderParamsMap);

  final Object primitivesMap;
  final Object shapesMap;
  final Object renderParamsMap;

  Map<String, Object> asReadOnlyMap() {
    final Object primitivesCandidate = primitivesMap;
    final Object shapesCandidate = shapesMap;
    final Object paramsCandidate = renderParamsMap;
    final bool hasPrimitives =
        primitivesCandidate is Map && primitivesCandidate.isNotEmpty;
    final bool hasShapes = shapesCandidate is Map && shapesCandidate.isNotEmpty;
    final bool hasParams = paramsCandidate is Map && paramsCandidate.isNotEmpty;
    final List<String> missing = <String>[];
    if (!hasPrimitives) missing.add('primitives');
    if (!hasShapes) missing.add('shapes');
    if (!hasParams) missing.add('render_params');
    final Map<String, Object> backComp = <String, Object>{
      'pattern': <String>['M0,0 L1,0 L1,1 L0,1 Z'],
      'frame': hasPrimitives
          ? (primitivesCandidate as Map)['outline_path'] ?? <Object>{}
          : <Object>{},
      'center_mark': hasShapes
          ? (shapesCandidate as Map)['corner_decals'] ?? <Object>[]
          : <Object>[],
    };
    final bool readiness = missing.isEmpty;
    return <String, Object>{
      'back_comp': backComp,
      'readiness': readiness,
      'missing': missing,
    };
  }
}

/// Passive card face composer V1 (Phi-57.5).
class CardFaceComposerV1 {
  const CardFaceComposerV1(
    this.shapesMap,
    this.primitivesMap,
    this.renderParamsMap,
  );

  final Object shapesMap;
  final Object primitivesMap;
  final Object renderParamsMap;

  Map<String, Object> asReadOnlyMap() {
    final Object shapesCandidate = shapesMap;
    final Object primitivesCandidate = primitivesMap;
    final Object paramsCandidate = renderParamsMap;
    final bool hasShapes = shapesCandidate is Map && shapesCandidate.isNotEmpty;
    final bool hasPrimitives =
        primitivesCandidate is Map && primitivesCandidate.isNotEmpty;
    final bool hasParams = paramsCandidate is Map && paramsCandidate.isNotEmpty;
    final List<String> missing = <String>[];
    if (!hasShapes) missing.add('shapes');
    if (!hasPrimitives) missing.add('primitives');
    if (!hasParams) missing.add('render_params');
    final Map<String, Object> faceComp = <String, Object>{
      'rank_shape': hasShapes
          ? (shapesCandidate as Map)['rank_shapes'] ?? <Object>[]
          : <Object>[],
      'suit_shape': hasShapes
          ? (shapesCandidate as Map)['suit_shapes'] ?? <Object>[]
          : <Object>[],
      'corner_decals': hasShapes
          ? (shapesCandidate as Map)['corner_decals'] ?? <Object>[]
          : <Object>[],
      'center_geometry': hasPrimitives
          ? (primitivesCandidate as Map)['pip_box_center'] ?? <Object>{}
          : <Object>{},
    };
    final bool readiness = missing.isEmpty;
    return <String, Object>{
      'face_comp': faceComp,
      'readiness': readiness,
      'missing': missing,
    };
  }
}

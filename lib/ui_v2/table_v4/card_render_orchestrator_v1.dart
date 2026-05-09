/// Passive card render orchestrator V1 (Phi-57.7).
class CardRenderOrchestratorV1 {
  const CardRenderOrchestratorV1(
    this.faceMap,
    this.backMap,
    this.layoutMap,
    this.renderParamsMap,
  );

  final Object faceMap;
  final Object backMap;
  final Object layoutMap;
  final Object renderParamsMap;

  Map<String, Object> asReadOnlyMap() {
    final Object faceCandidate = faceMap;
    final Object backCandidate = backMap;
    final Object layoutCandidate = layoutMap;
    final Object paramsCandidate = renderParamsMap;
    final bool hasFace = faceCandidate is Map && faceCandidate.isNotEmpty;
    final bool hasBack = backCandidate is Map && backCandidate.isNotEmpty;
    final bool hasLayout = layoutCandidate is Map && layoutCandidate.isNotEmpty;
    final bool hasParams = paramsCandidate is Map && paramsCandidate.isNotEmpty;
    final List<String> missing = <String>[];
    if (!hasFace) missing.add('face');
    if (!hasBack) missing.add('back');
    if (!hasLayout) missing.add('layout');
    if (!hasParams) missing.add('params');
    final Map<String, Object> renderOrchestrator = <String, Object>{
      'face': hasFace
          ? (faceCandidate as Map)['face_comp'] ?? <Object>{}
          : <Object>{},
      'back': hasBack
          ? (backCandidate as Map)['back_comp'] ?? <Object>{}
          : <Object>{},
      'layout': hasLayout
          ? (layoutCandidate as Map)['layout'] ?? <Object>{}
          : <Object>{},
      'params': hasParams
          ? (paramsCandidate as Map)['params'] ?? <Object>{}
          : <Object>{},
    };
    final bool readiness = missing.isEmpty;
    return <String, Object>{
      'render_orchestrator': renderOrchestrator,
      'readiness': readiness,
      'missing': missing,
    };
  }
}

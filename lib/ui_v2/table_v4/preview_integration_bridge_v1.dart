/// Passive preview integration bridge V1 (Phi-57.9).
class PreviewIntegrationBridgeV1 {
  const PreviewIntegrationBridgeV1(this.previewMap, this.orchestratorMap);

  final Object previewMap;
  final Object orchestratorMap;

  Map<String, Object> asReadOnlyMap() {
    final Object previewCandidate = previewMap;
    final Object orchestratorCandidate = orchestratorMap;
    final bool hasPreview =
        previewCandidate is Map && previewCandidate.isNotEmpty;
    final bool hasOrchestrator =
        orchestratorCandidate is Map && orchestratorCandidate.isNotEmpty;
    final List<String> missing = <String>[];
    if (!hasPreview) missing.add('preview');
    if (!hasOrchestrator) missing.add('orchestrator');
    final Map<String, Object> previewBridge = <String, Object>{
      'face': hasPreview
          ? (((previewCandidate as Map)['preview'] as Map?)?['sample_face'] ??
                <Object>{})
          : <Object>{},
      'back': hasPreview
          ? (((previewCandidate as Map)['preview'] as Map?)?['sample_back'] ??
                <Object>{})
          : <Object>{},
      'layout_rect': hasPreview
          ? (((previewCandidate as Map)['preview'] as Map?)?['card_rect'] ??
                <Object>{})
          : <Object>{},
      'orchestrator': hasOrchestrator
          ? (orchestratorCandidate as Map)['render_orchestrator'] ?? <Object>{}
          : <Object>{},
    };
    final bool readiness = missing.isEmpty;
    return <String, Object>{
      'preview_bridge': previewBridge,
      'readiness': readiness,
      'missing': missing,
    };
  }
}

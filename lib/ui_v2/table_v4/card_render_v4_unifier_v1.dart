class CardRenderV4UnifierV1 {
  CardRenderV4UnifierV1(
    this.cardLayoutV2Map,
    this.cardRenderParamsV1Map,
    this.cardVectorPrimitivesV1Map,
    this.cardVectorShapesV1Map,
    this.cardFaceComposerV1Map,
    this.cardBackV1Map,
    this.cardRenderOrchestratorV1Map,
  );

  final Object cardLayoutV2Map;
  final Object cardRenderParamsV1Map;
  final Object cardVectorPrimitivesV1Map;
  final Object cardVectorShapesV1Map;
  final Object cardFaceComposerV1Map;
  final Object cardBackV1Map;
  final Object cardRenderOrchestratorV1Map;

  Map<String, Object> asReadOnlyMap() {
    final Map<String, Object> domains = <String, Object>{
      'layout': cardLayoutV2Map,
      'params': cardRenderParamsV1Map,
      'primitives': cardVectorPrimitivesV1Map,
      'shapes': cardVectorShapesV1Map,
      'face': cardFaceComposerV1Map,
      'back': cardBackV1Map,
      'orchestrator': cardRenderOrchestratorV1Map,
    };
    final List<String> missing = <String>[];
    bool isReady(Object value, String key) {
      if (value is! Map<String, Object>) {
        missing.add(key);
        return false;
      }
      if (value['readiness'] != true) {
        missing.add(key);
        return false;
      }
      return true;
    }

    final bool unifyReady = domains.entries.every(
      (entry) => isReady(entry.value, entry.key),
    );

    return <String, Object>{
      'card_render_v4_unifier_v1': <String, Object>{
        'domains': domains,
        'missing': missing,
        'unify_ready': unifyReady,
      },
      'readiness': unifyReady,
    };
  }
}

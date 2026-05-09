class SystemQAConsolidatorV1 {
  const SystemQAConsolidatorV1(
    Object? systemQAStabilityCrownV1Map,
    Object? systemRenderAlignmentSealV1Map,
    Object? runtimeFinalSealV4GateV1Map,
    Object? runtimeGlobalVerdictV1Map,
    Object? runtimeSystemFusionSurfaceV1Map,
    Object? runtimeTeachOutSnapshotV1Map,
    Object? runtimeGlobalQABridgeV1Map,
  ) : _systemCrown = systemQAStabilityCrownV1Map,
      _renderAlignment = systemRenderAlignmentSealV1Map,
      _runtimeSeal = runtimeFinalSealV4GateV1Map,
      _runtimeVerdict = runtimeGlobalVerdictV1Map,
      _runtimeSurface = runtimeSystemFusionSurfaceV1Map,
      _runtimeTeachOut = runtimeTeachOutSnapshotV1Map,
      _runtimeBridge = runtimeGlobalQABridgeV1Map;

  final Object? _systemCrown,
      _renderAlignment,
      _runtimeSeal,
      _runtimeVerdict,
      _runtimeSurface,
      _runtimeTeachOut,
      _runtimeBridge;

  Map<String, Object> asReadOnlyMap() {
    final Map<String, Object?> domains = {
      'runtime_final_seal': _runtimeSeal,
      'runtime_global_qa_bridge': _runtimeBridge,
      'runtime_global_verdict': _runtimeVerdict,
      'runtime_system_fusion_surface': _runtimeSurface,
      'runtime_teachout_snapshot': _runtimeTeachOut,
      'system_render_alignment': _renderAlignment,
      'system_stability_crown': _systemCrown,
    };
    final List<String> missing = <String>[];
    bool systemReady = true;
    final Map<String, Object> status = <String, Object>{};
    for (final String key in (domains.keys.toList()..sort())) {
      final Object? value = domains[key];
      final bool exists = value != null;
      final bool isMap = value is Map;
      final bool nonEmpty = isMap && value.isNotEmpty;
      final bool ready = isMap && value['readiness'] == true;
      if (!(exists && isMap && nonEmpty && ready)) {
        missing.add(key);
        systemReady = false;
      }
      status[key] = {
        'exists': exists,
        'is_map': isMap,
        'non_empty': nonEmpty,
        'ready': ready,
      };
    }
    return {
      'system_qa_consolidator_v1': {
        'domains': status,
        'missing': missing,
        'system_ready': systemReady,
      },
      'readiness': systemReady,
    };
  }
}

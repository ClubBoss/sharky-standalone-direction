class RuntimeSystemFusionGateV1 {
  const RuntimeSystemFusionGateV1(
    Object? runtimeFinalVerdictV4GateV1Map,
    Object? runtimeColdPathQAGateV1Map,
    Object? runtimeWarmPathQAGateV1Map,
    Object? runtimeHotPathQAGateV1Map,
    Object? renderQAV4FinalVerdictV1Map,
    Object? tableV4FinalReadinessGateV1Map,
    Object? tableV4RuntimeBundleConsolidatorV1Map,
    Object? tableV4ViewportIntegrityGuardV1Map,
  ) : _runtimeFinalVerdictV4GateV1Map = runtimeFinalVerdictV4GateV1Map,
      _runtimeColdPathQAGateV1Map = runtimeColdPathQAGateV1Map,
      _runtimeWarmPathQAGateV1Map = runtimeWarmPathQAGateV1Map,
      _runtimeHotPathQAGateV1Map = runtimeHotPathQAGateV1Map,
      _renderQAV4FinalVerdictV1Map = renderQAV4FinalVerdictV1Map,
      _tableV4FinalReadinessGateV1Map = tableV4FinalReadinessGateV1Map,
      _tableV4RuntimeBundleConsolidatorV1Map =
          tableV4RuntimeBundleConsolidatorV1Map,
      _tableV4ViewportIntegrityGuardV1Map = tableV4ViewportIntegrityGuardV1Map;

  final Object? _runtimeFinalVerdictV4GateV1Map;
  final Object? _runtimeColdPathQAGateV1Map;
  final Object? _runtimeWarmPathQAGateV1Map;
  final Object? _runtimeHotPathQAGateV1Map;
  final Object? _renderQAV4FinalVerdictV1Map;
  final Object? _tableV4FinalReadinessGateV1Map;
  final Object? _tableV4RuntimeBundleConsolidatorV1Map;
  final Object? _tableV4ViewportIntegrityGuardV1Map;

  Map<String, Object> asReadOnlyMap() {
    final Map<String, Object?> domains = <String, Object?>{
      'cold_path_gate': _runtimeColdPathQAGateV1Map,
      'final_readiness_gate_v4': _tableV4FinalReadinessGateV1Map,
      'hot_path_gate': _runtimeHotPathQAGateV1Map,
      'render_qav4_final_verdict': _renderQAV4FinalVerdictV1Map,
      'runtime_bundle_consolidator_v4': _tableV4RuntimeBundleConsolidatorV1Map,
      'runtime_final_verdict_v4': _runtimeFinalVerdictV4GateV1Map,
      'viewport_integrity_guard_v4': _tableV4ViewportIntegrityGuardV1Map,
      'warm_path_gate': _runtimeWarmPathQAGateV1Map,
    };
    final List<String> keys = domains.keys.toList()..sort();
    final Map<String, Object> domainData = <String, Object>{};
    final List<String> missing = <String>[];
    bool fusionReady = true;

    for (final String key in keys) {
      final Object? value = domains[key];
      final bool exists = value != null;
      final bool isMap = value is Map;
      final bool nonEmpty = isMap && value.isNotEmpty;
      final bool ready = isMap && value['readiness'] == true;
      if (!exists || !isMap || !nonEmpty || !ready) {
        fusionReady = false;
        missing.add(key);
      }
      domainData[key] = <String, Object>{
        'exists': exists,
        'is_map': isMap,
        'non_empty': nonEmpty,
        'ready': ready,
      };
    }

    return <String, Object>{
      'runtime_system_fusion_gate_v1': <String, Object>{
        'domains': domainData,
        'missing': missing,
        'fusion_ready': fusionReady,
      },
      'readiness': fusionReady,
    };
  }
}

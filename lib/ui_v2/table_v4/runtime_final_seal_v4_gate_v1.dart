class RuntimeFinalSealV4GateV1 {
  const RuntimeFinalSealV4GateV1(
    Object? runtimeTeachOutSnapshotV1Map,
    Object? runtimeSystemFusionSurfaceV1Map,
    Object? runtimeGlobalVerdictV1Map,
    Object? runtimeSystemFusionGateV1Map,
    Object? runtimeFinalVerdictV4GateV1Map,
    Object? runtimeGlobalQABridgeV1Map,
    Object? systemRuntimeVerdictBindingV1Map,
  ) : _teachOut = runtimeTeachOutSnapshotV1Map,
      _fusionSurface = runtimeSystemFusionSurfaceV1Map,
      _globalVerdict = runtimeGlobalVerdictV1Map,
      _fusionGate = runtimeSystemFusionGateV1Map,
      _finalVerdict = runtimeFinalVerdictV4GateV1Map,
      _globalBridge = runtimeGlobalQABridgeV1Map,
      _systemBinding = systemRuntimeVerdictBindingV1Map;

  final Object? _teachOut,
      _fusionSurface,
      _globalVerdict,
      _fusionGate,
      _finalVerdict,
      _globalBridge,
      _systemBinding;

  Map<String, Object> asReadOnlyMap() {
    final Map<String, Object?> domains = {
      'global_bridge': _globalBridge,
      'global_verdict': _globalVerdict,
      'runtime_final_verdict': _finalVerdict,
      'runtime_fusion_gate': _fusionGate,
      'runtime_fusion_surface': _fusionSurface,
      'system_binding': _systemBinding,
      'teachout_snapshot': _teachOut,
    };
    final List<String> missing = <String>[];
    bool sealReady = true;
    final Map<String, Object> status = <String, Object>{};
    for (final String key in (domains.keys.toList()..sort())) {
      final Object? value = domains[key];
      final bool exists = value != null;
      final bool isMap = value is Map;
      final bool nonEmpty = isMap && value.isNotEmpty;
      final bool ready = isMap && value['readiness'] == true;
      if (!(exists && isMap && nonEmpty && ready)) {
        missing.add(key);
        sealReady = false;
      }
      status[key] = {
        'exists': exists,
        'is_map': isMap,
        'non_empty': nonEmpty,
        'ready': ready,
      };
    }
    return {
      'runtime_final_seal_v4_gate_v1': {
        'domains': status,
        'missing': missing,
        'seal_ready': sealReady,
      },
      'readiness': sealReady,
    };
  }
}

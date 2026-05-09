class SystemQAConsistencyGateV1 {
  const SystemQAConsistencyGateV1(
    Object? systemQAFusionBridgeV1Map,
    Object? runtimeGlobalVerdictV1Map,
    Object? runtimeGlobalQABridgeV1Map,
    Object? systemRuntimeVerdictBindingV1Map,
    Object? runtimeSystemFusionGateV1Map,
    Object? runtimeFinalSealV4GateV1Map,
  ) : _fusionBridge = systemQAFusionBridgeV1Map,
      _globalVerdict = runtimeGlobalVerdictV1Map,
      _globalBridge = runtimeGlobalQABridgeV1Map,
      _runtimeBinding = systemRuntimeVerdictBindingV1Map,
      _fusionGate = runtimeSystemFusionGateV1Map,
      _finalSeal = runtimeFinalSealV4GateV1Map;

  final Object? _fusionBridge,
      _globalVerdict,
      _globalBridge,
      _runtimeBinding,
      _fusionGate,
      _finalSeal;

  Map<String, Object> asReadOnlyMap() {
    final Map<String, Object?> domains = {
      'final_seal': _finalSeal,
      'fusion_bridge': _fusionBridge,
      'fusion_gate': _fusionGate,
      'global_bridge': _globalBridge,
      'global_verdict': _globalVerdict,
      'runtime_binding': _runtimeBinding,
    };
    final List<String> missing = <String>[];
    bool consistencyReady = true;
    final Map<String, Object> status = <String, Object>{};
    for (final String key in (domains.keys.toList()..sort())) {
      final Object? value = domains[key];
      final bool exists = value != null;
      final bool isMap = value is Map;
      final bool nonEmpty = isMap && value.isNotEmpty;
      final bool ready = isMap && value['readiness'] == true;
      if (!(exists && isMap && nonEmpty && ready)) {
        missing.add(key);
        consistencyReady = false;
      }
      status[key] = {
        'exists': exists,
        'is_map': isMap,
        'non_empty': nonEmpty,
        'ready': ready,
      };
    }
    return {
      'system_qa_consistency_gate_v1': {
        'domains': status,
        'missing': missing,
        'consistency_ready': consistencyReady,
      },
      'readiness': consistencyReady,
    };
  }
}

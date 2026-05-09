class SystemQAStabilityCrownV1 {
  const SystemQAStabilityCrownV1(
    Object? systemQAFusionBridgeV1Map,
    Object? systemQAConsistencyGateV1Map,
    Object? runtimeSystemFusionGateV1Map,
    Object? runtimeFinalSealV4GateV1Map,
    Object? runtimeTeachOutSnapshotV1Map,
    Object? runtimeGlobalVerdictV1Map,
  ) : _fusionBridge = systemQAFusionBridgeV1Map,
      _consistencyGate = systemQAConsistencyGateV1Map,
      _fusionGate = runtimeSystemFusionGateV1Map,
      _finalSeal = runtimeFinalSealV4GateV1Map,
      _teachOut = runtimeTeachOutSnapshotV1Map,
      _globalVerdict = runtimeGlobalVerdictV1Map;

  final Object? _fusionBridge,
      _consistencyGate,
      _fusionGate,
      _finalSeal,
      _teachOut,
      _globalVerdict;

  Map<String, Object> asReadOnlyMap() {
    final Map<String, Object?> domains = {
      'consistency_gate': _consistencyGate,
      'final_seal': _finalSeal,
      'fusion_bridge': _fusionBridge,
      'fusion_gate': _fusionGate,
      'global_verdict': _globalVerdict,
      'teachout_snapshot': _teachOut,
    };
    final List<String> missing = <String>[];
    bool stabilityReady = true;
    final Map<String, Object> status = <String, Object>{};
    for (final String key in (domains.keys.toList()..sort())) {
      final Object? value = domains[key];
      final bool exists = value != null;
      final bool isMap = value is Map;
      final bool nonEmpty = isMap && value.isNotEmpty;
      final bool ready = isMap && value['readiness'] == true;
      if (!(exists && isMap && nonEmpty && ready)) {
        missing.add(key);
        stabilityReady = false;
      }
      status[key] = {
        'exists': exists,
        'is_map': isMap,
        'non_empty': nonEmpty,
        'ready': ready,
      };
    }
    return {
      'system_qa_stability_crown_v1': {
        'domains': status,
        'missing': missing,
        'stability_ready': stabilityReady,
      },
      'readiness': stabilityReady,
    };
  }
}

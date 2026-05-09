class RuntimeTeachOutSnapshotV1 {
  const RuntimeTeachOutSnapshotV1(
    Object? runtimeSystemFusionSurfaceV1Map,
    Object? runtimeGlobalVerdictV1Map,
    Object? runtimeGlobalQABridgeV1Map,
    Object? systemRuntimeVerdictBindingV1Map,
    Object? runtimeSystemFusionGateV1Map,
    Object? runtimeFinalVerdictV4GateV1Map,
    Object? runtimeHotPathQAGateV1Map,
    Object? runtimeWarmPathQAGateV1Map,
    Object? runtimeColdPathQAGateV1Map,
    Object? renderQAV4SystemVerdictGateV1Map,
    Object? renderQAV4FinalVerdictV1Map,
  ) : _fusionSurface = runtimeSystemFusionSurfaceV1Map,
      _globalVerdict = runtimeGlobalVerdictV1Map,
      _globalBridge = runtimeGlobalQABridgeV1Map,
      _systemBinding = systemRuntimeVerdictBindingV1Map,
      _fusionGate = runtimeSystemFusionGateV1Map,
      _finalRuntime = runtimeFinalVerdictV4GateV1Map,
      _hot = runtimeHotPathQAGateV1Map,
      _warm = runtimeWarmPathQAGateV1Map,
      _cold = runtimeColdPathQAGateV1Map,
      _renderSystem = renderQAV4SystemVerdictGateV1Map,
      _renderFinal = renderQAV4FinalVerdictV1Map;

  final Object? _fusionSurface,
      _globalVerdict,
      _globalBridge,
      _systemBinding,
      _fusionGate,
      _finalRuntime,
      _hot,
      _warm,
      _cold,
      _renderSystem,
      _renderFinal;

  Map<String, Object> asReadOnlyMap() {
    final Map<String, Object?> domains = {
      'cold': _cold,
      'final_runtime': _finalRuntime,
      'fusion_gate': _fusionGate,
      'fusion_surface': _fusionSurface,
      'global_bridge': _globalBridge,
      'global_verdict': _globalVerdict,
      'hot': _hot,
      'render_final': _renderFinal,
      'render_system': _renderSystem,
      'system_binding': _systemBinding,
      'warm': _warm,
    };
    bool snapshotReady = true;
    final List<String> missing = <String>[];
    final Map<String, Object> status = Map<String, Object>.fromEntries(
      (domains.keys.toList()..sort()).map((key) {
        final Object? value = domains[key];
        final bool exists = value != null;
        final bool isMap = value is Map;
        final bool nonEmpty = isMap && value.isNotEmpty;
        final bool ready = isMap && value['readiness'] == true;
        if (!(exists && isMap && nonEmpty && ready)) {
          snapshotReady = false;
          missing.add(key);
        }
        return MapEntry<String, Object>(key, {
          'exists': exists,
          'is_map': isMap,
          'non_empty': nonEmpty,
          'ready': ready,
        });
      }),
    );
    return {
      'runtime_teachout_snapshot_v1': {
        'domains': status,
        'missing': missing,
        'snapshot_ready': snapshotReady,
      },
      'readiness': snapshotReady,
    };
  }
}

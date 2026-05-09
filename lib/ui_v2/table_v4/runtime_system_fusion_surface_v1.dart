class RuntimeSystemFusionSurfaceV1 {
  const RuntimeSystemFusionSurfaceV1(
    Object? runtimeGlobalVerdictV1Map,
    Object? runtimeGlobalQABridgeV1Map,
    Object? systemRuntimeVerdictBindingV1Map,
    Object? runtimeSystemFusionGateV1Map,
    Object? runtimeFinalVerdictV4GateV1Map,
    Object? renderQAV4SystemVerdictGateV1Map,
    Object? renderQAV4FinalVerdictV1Map,
  ) : _globalVerdict = runtimeGlobalVerdictV1Map,
      _globalBridge = runtimeGlobalQABridgeV1Map,
      _systemBinding = systemRuntimeVerdictBindingV1Map,
      _fusionGate = runtimeSystemFusionGateV1Map,
      _finalRuntime = runtimeFinalVerdictV4GateV1Map,
      _renderSystem = renderQAV4SystemVerdictGateV1Map,
      _renderFinal = renderQAV4FinalVerdictV1Map;

  final Object? _globalVerdict,
      _globalBridge,
      _systemBinding,
      _fusionGate,
      _finalRuntime,
      _renderSystem,
      _renderFinal;

  Map<String, Object> asReadOnlyMap() {
    final Map<String, Object?> domains = {
      'final_runtime': _finalRuntime,
      'fusion_gate': _fusionGate,
      'global_bridge': _globalBridge,
      'global_verdict': _globalVerdict,
      'render_final': _renderFinal,
      'render_system': _renderSystem,
      'system_binding': _systemBinding,
    };
    final List<String> missing = <String>[];
    final Map<String, Object> status = <String, Object>{};
    bool surfaceReady = true;
    for (final String key in (domains.keys.toList()..sort())) {
      final Object? value = domains[key];
      final bool exists = value != null;
      final bool isMap = value is Map;
      final bool nonEmpty = isMap && value.isNotEmpty;
      final bool ready = isMap && value['readiness'] == true;
      if (!(exists && isMap && nonEmpty && ready)) {
        surfaceReady = false;
        missing.add(key);
      }
      status[key] = {
        'exists': exists,
        'is_map': isMap,
        'non_empty': nonEmpty,
        'ready': ready,
      };
    }
    return {
      'runtime_system_fusion_surface_v1': {
        'domains': status,
        'missing': missing,
        'surface_ready': surfaceReady,
      },
      'readiness': surfaceReady,
    };
  }
}

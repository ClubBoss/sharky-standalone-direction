class RuntimeGlobalVerdictV1 {
  const RuntimeGlobalVerdictV1(
    Object? runtimeGlobalQABridgeV1Map,
    Object? systemRuntimeVerdictBindingV1Map,
    Object? runtimeSystemFusionGateV1Map,
    Object? runtimeFinalVerdictV4GateV1Map,
    Object? runtimeHotPathQAGateV1Map,
    Object? runtimeWarmPathQAGateV1Map,
    Object? runtimeColdPathQAGateV1Map,
    Object? renderQAV4SystemVerdictGateV1Map,
    Object? renderQAV4FinalVerdictV1Map,
  ) : _bridge = runtimeGlobalQABridgeV1Map,
      _binding = systemRuntimeVerdictBindingV1Map,
      _fusion = runtimeSystemFusionGateV1Map,
      _finalRuntime = runtimeFinalVerdictV4GateV1Map,
      _hot = runtimeHotPathQAGateV1Map,
      _warm = runtimeWarmPathQAGateV1Map,
      _cold = runtimeColdPathQAGateV1Map,
      _renderSystem = renderQAV4SystemVerdictGateV1Map,
      _renderFinal = renderQAV4FinalVerdictV1Map;

  final Object? _bridge;
  final Object? _binding;
  final Object? _fusion;
  final Object? _finalRuntime;
  final Object? _hot;
  final Object? _warm;
  final Object? _cold;
  final Object? _renderSystem;
  final Object? _renderFinal;

  Map<String, Object> asReadOnlyMap() {
    final Map<String, Object?> domains = {
      'cold': _cold,
      'final_runtime': _finalRuntime,
      'fusion_gate': _fusion,
      'global_bridge': _bridge,
      'hot': _hot,
      'render_final': _renderFinal,
      'render_system': _renderSystem,
      'system_binding': _binding,
      'warm': _warm,
    };
    final List<String> missing = <String>[];
    bool verdictReady = true;
    final Map<String, Object> status = <String, Object>{};
    for (final String key in domains.keys.toList()..sort()) {
      final Object? value = domains[key];
      final bool exists = value != null;
      final bool isMap = value is Map;
      final bool nonEmpty = isMap && value.isNotEmpty;
      final bool ready = isMap && value['readiness'] == true;
      if (!(exists && isMap && nonEmpty && ready)) {
        verdictReady = false;
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
      'runtime_global_verdict_v1': {
        'domains': status,
        'missing': missing,
        'verdict_ready': verdictReady,
      },
      'readiness': verdictReady,
    };
  }
}

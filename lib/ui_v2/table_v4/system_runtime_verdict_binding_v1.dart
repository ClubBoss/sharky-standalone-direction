class SystemRuntimeVerdictBindingV1 {
  const SystemRuntimeVerdictBindingV1(
    Object? runtimeSystemFusionGateV1Map,
    Object? renderQAV4SystemVerdictGateV1Map,
    Object? tableV4SystemBridgeV1Map,
    Object? tableV4SystemVerdictAdapterV1Map,
    Object? renderQAV4SystemBinderV1Map,
    Object? renderQAV4IntegrationGlueV1Map,
    Object? runtimeFinalVerdictV4GateV1Map,
  ) : _runtimeSystemFusionGateV1Map = runtimeSystemFusionGateV1Map,
      _renderQAV4SystemVerdictGateV1Map = renderQAV4SystemVerdictGateV1Map,
      _tableV4SystemBridgeV1Map = tableV4SystemBridgeV1Map,
      _tableV4SystemVerdictAdapterV1Map = tableV4SystemVerdictAdapterV1Map,
      _renderQAV4SystemBinderV1Map = renderQAV4SystemBinderV1Map,
      _renderQAV4IntegrationGlueV1Map = renderQAV4IntegrationGlueV1Map,
      _runtimeFinalVerdictV4GateV1Map = runtimeFinalVerdictV4GateV1Map;

  final Object? _runtimeSystemFusionGateV1Map;
  final Object? _renderQAV4SystemVerdictGateV1Map;
  final Object? _tableV4SystemBridgeV1Map;
  final Object? _tableV4SystemVerdictAdapterV1Map;
  final Object? _renderQAV4SystemBinderV1Map;
  final Object? _renderQAV4IntegrationGlueV1Map;
  final Object? _runtimeFinalVerdictV4GateV1Map;

  Map<String, Object> asReadOnlyMap() {
    final Map<String, Object?> domains = <String, Object?>{
      'render_integration_glue': _renderQAV4IntegrationGlueV1Map,
      'render_system_binder': _renderQAV4SystemBinderV1Map,
      'render_system_verdict_gate': _renderQAV4SystemVerdictGateV1Map,
      'runtime_final_verdict_v4': _runtimeFinalVerdictV4GateV1Map,
      'runtime_system_fusion': _runtimeSystemFusionGateV1Map,
      'system_bridge_v4': _tableV4SystemBridgeV1Map,
      'system_verdict_adapter_v4': _tableV4SystemVerdictAdapterV1Map,
    };
    final List<String> keys = domains.keys.toList()..sort();
    final Map<String, Object> domainData = <String, Object>{};
    final List<String> missing = <String>[];
    bool bindingReady = true;

    for (final String key in keys) {
      final Object? value = domains[key];
      final bool exists = value != null;
      final bool isMap = value is Map;
      final bool nonEmpty = isMap && value.isNotEmpty;
      final bool ready = isMap && value['readiness'] == true;
      if (!exists || !isMap || !nonEmpty || !ready) {
        bindingReady = false;
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
      'system_runtime_verdict_binding_v1': <String, Object>{
        'domains': domainData,
        'missing': missing,
        'binding_ready': bindingReady,
      },
      'readiness': bindingReady,
    };
  }
}

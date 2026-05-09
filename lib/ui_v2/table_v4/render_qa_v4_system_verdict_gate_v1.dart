class RenderQAV4SystemVerdictGateV1 {
  const RenderQAV4SystemVerdictGateV1(
    Object? renderQAV4SystemBinderV1Map,
    Object? tableV4SystemVerdictAdapterV1Map,
    Object? tableV4SystemBridgeV1Map,
    Object? tableV4FinalReadinessGateV1Map,
    Object? tableV4RuntimeBundleConsolidatorV1Map,
    Object? tableV4ViewportIntegrityGuardV1Map,
    Object? tableV4DeviceFusionValidatorV1Map,
  ) : _renderQAV4SystemBinderV1Map = renderQAV4SystemBinderV1Map,
      _tableV4SystemVerdictAdapterV1Map = tableV4SystemVerdictAdapterV1Map,
      _tableV4SystemBridgeV1Map = tableV4SystemBridgeV1Map,
      _tableV4FinalReadinessGateV1Map = tableV4FinalReadinessGateV1Map,
      _tableV4RuntimeBundleConsolidatorV1Map =
          tableV4RuntimeBundleConsolidatorV1Map,
      _tableV4ViewportIntegrityGuardV1Map = tableV4ViewportIntegrityGuardV1Map,
      _tableV4DeviceFusionValidatorV1Map = tableV4DeviceFusionValidatorV1Map;

  final Object? _renderQAV4SystemBinderV1Map;
  final Object? _tableV4SystemVerdictAdapterV1Map;
  final Object? _tableV4SystemBridgeV1Map;
  final Object? _tableV4FinalReadinessGateV1Map;
  final Object? _tableV4RuntimeBundleConsolidatorV1Map;
  final Object? _tableV4ViewportIntegrityGuardV1Map;
  final Object? _tableV4DeviceFusionValidatorV1Map;

  Map<String, Object> asReadOnlyMap() {
    final Map<String, Object?> domains = <String, Object?>{
      'device_fusion_validator': _tableV4DeviceFusionValidatorV1Map,
      'final_readiness_gate': _tableV4FinalReadinessGateV1Map,
      'runtime_bundle_consolidator': _tableV4RuntimeBundleConsolidatorV1Map,
      'system_binder': _renderQAV4SystemBinderV1Map,
      'system_bridge': _tableV4SystemBridgeV1Map,
      'system_verdict_adapter': _tableV4SystemVerdictAdapterV1Map,
      'viewport_integrity_guard': _tableV4ViewportIntegrityGuardV1Map,
    };
    final List<String> keys = domains.keys.toList()..sort();
    final Map<String, Object> domainData = <String, Object>{};
    final List<String> missing = <String>[];
    bool verdictReady = true;

    for (final String key in keys) {
      final Object? value = domains[key];
      final bool exists = value != null;
      final bool isMap = value is Map;
      final bool nonEmpty = isMap && value.isNotEmpty;
      final bool ready = isMap && value['readiness'] == true;
      if (!exists || !isMap || !nonEmpty || !ready) {
        verdictReady = false;
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
      'render_qa_v4_system_verdict_gate_v1': <String, Object>{
        'domains': domainData,
        'missing': missing,
        'verdict_ready': verdictReady,
      },
      'readiness': verdictReady,
    };
  }
}

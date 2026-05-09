class RuntimeFinalVerdictV4GateV1 {
  const RuntimeFinalVerdictV4GateV1(
    Object? runtimeColdPathQAGateV1Map,
    Object? runtimeWarmPathQAGateV1Map,
    Object? runtimeHotPathQAGateV1Map,
    Object? tableFinalRenderEnvelopeFusionV4Map,
    Object? tableFinalVisualFusionV4Map,
    Object? tableRenderSurfaceV4Map,
    Object? tableVisualSurfaceV4Map,
    Object? tableRenderEnvelopeV2Map,
    Object? unifiedRenderBundleV1Map,
    Object? tableV4FinalReadinessGateV1Map,
  ) : _runtimeColdPathQAGateV1Map = runtimeColdPathQAGateV1Map,
      _runtimeWarmPathQAGateV1Map = runtimeWarmPathQAGateV1Map,
      _runtimeHotPathQAGateV1Map = runtimeHotPathQAGateV1Map,
      _tableFinalRenderEnvelopeFusionV4Map =
          tableFinalRenderEnvelopeFusionV4Map,
      _tableFinalVisualFusionV4Map = tableFinalVisualFusionV4Map,
      _tableRenderSurfaceV4Map = tableRenderSurfaceV4Map,
      _tableVisualSurfaceV4Map = tableVisualSurfaceV4Map,
      _tableRenderEnvelopeV2Map = tableRenderEnvelopeV2Map,
      _unifiedRenderBundleV1Map = unifiedRenderBundleV1Map,
      _tableV4FinalReadinessGateV1Map = tableV4FinalReadinessGateV1Map;

  final Object? _runtimeColdPathQAGateV1Map;
  final Object? _runtimeWarmPathQAGateV1Map;
  final Object? _runtimeHotPathQAGateV1Map;
  final Object? _tableFinalRenderEnvelopeFusionV4Map;
  final Object? _tableFinalVisualFusionV4Map;
  final Object? _tableRenderSurfaceV4Map;
  final Object? _tableVisualSurfaceV4Map;
  final Object? _tableRenderEnvelopeV2Map;
  final Object? _unifiedRenderBundleV1Map;
  final Object? _tableV4FinalReadinessGateV1Map;

  Map<String, Object> asReadOnlyMap() {
    final Map<String, Object?> domains = <String, Object?>{
      'cold_path_gate': _runtimeColdPathQAGateV1Map,
      'final_readiness_gate_v4': _tableV4FinalReadinessGateV1Map,
      'final_render_fusion_v4': _tableFinalRenderEnvelopeFusionV4Map,
      'final_visual_fusion_v4': _tableFinalVisualFusionV4Map,
      'hot_path_gate': _runtimeHotPathQAGateV1Map,
      'render_envelope_v2': _tableRenderEnvelopeV2Map,
      'render_surface_v4': _tableRenderSurfaceV4Map,
      'unified_render_bundle_v1': _unifiedRenderBundleV1Map,
      'visual_surface_v4': _tableVisualSurfaceV4Map,
      'warm_path_gate': _runtimeWarmPathQAGateV1Map,
    };
    final List<String> keys = domains.keys.toList()..sort();
    final Map<String, Object> domainData = <String, Object>{};
    final List<String> missing = <String>[];
    bool runtimeReady = true;

    for (final String key in keys) {
      final Object? value = domains[key];
      final bool exists = value != null;
      final bool isMap = value is Map;
      final bool nonEmpty = isMap && value.isNotEmpty;
      final bool ready = isMap && value['readiness'] == true;
      if (!exists || !isMap || !nonEmpty || !ready) {
        runtimeReady = false;
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
      'runtime_final_verdict_v4_gate_v1': <String, Object>{
        'domains': domainData,
        'missing': missing,
        'runtime_ready': runtimeReady,
      },
      'readiness': runtimeReady,
    };
  }
}

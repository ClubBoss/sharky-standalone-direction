class RuntimeHotPathQAGateV1 {
  const RuntimeHotPathQAGateV1(
    Object? tableUIHotPathGateV1Map,
    Object? tableUIWarmPathGateV1Map,
    Object? tableUIColdPathGateV1Map,
    Object? tableRenderEnvelopeV2Map,
    Object? unifiedRenderBundleV1Map,
    Object? tableRenderSurfaceV4Map,
    Object? tableVisualSurfaceV4Map,
    Object? tableFinalRenderEnvelopeFusionV4Map,
    Object? tableFinalVisualFusionV4Map,
    Object? tableV4FinalReadinessGateV1Map,
  ) : _tableUIHotPathGateV1Map = tableUIHotPathGateV1Map,
      _tableUIWarmPathGateV1Map = tableUIWarmPathGateV1Map,
      _tableUIColdPathGateV1Map = tableUIColdPathGateV1Map,
      _tableRenderEnvelopeV2Map = tableRenderEnvelopeV2Map,
      _unifiedRenderBundleV1Map = unifiedRenderBundleV1Map,
      _tableRenderSurfaceV4Map = tableRenderSurfaceV4Map,
      _tableVisualSurfaceV4Map = tableVisualSurfaceV4Map,
      _tableFinalRenderEnvelopeFusionV4Map =
          tableFinalRenderEnvelopeFusionV4Map,
      _tableFinalVisualFusionV4Map = tableFinalVisualFusionV4Map,
      _tableV4FinalReadinessGateV1Map = tableV4FinalReadinessGateV1Map;

  final Object? _tableUIHotPathGateV1Map;
  final Object? _tableUIWarmPathGateV1Map;
  final Object? _tableUIColdPathGateV1Map;
  final Object? _tableRenderEnvelopeV2Map;
  final Object? _unifiedRenderBundleV1Map;
  final Object? _tableRenderSurfaceV4Map;
  final Object? _tableVisualSurfaceV4Map;
  final Object? _tableFinalRenderEnvelopeFusionV4Map;
  final Object? _tableFinalVisualFusionV4Map;
  final Object? _tableV4FinalReadinessGateV1Map;

  Map<String, Object> asReadOnlyMap() {
    final Map<String, Object?> domains = <String, Object?>{
      'final_readiness_gate_v4': _tableV4FinalReadinessGateV1Map,
      'final_render_fusion_v4': _tableFinalRenderEnvelopeFusionV4Map,
      'final_visual_fusion_v4': _tableFinalVisualFusionV4Map,
      'render_envelope_v2': _tableRenderEnvelopeV2Map,
      'render_surface_v4': _tableRenderSurfaceV4Map,
      'ui_cold_path_gate': _tableUIColdPathGateV1Map,
      'ui_hot_path_gate': _tableUIHotPathGateV1Map,
      'ui_warm_path_gate': _tableUIWarmPathGateV1Map,
      'unified_render_bundle': _unifiedRenderBundleV1Map,
      'visual_surface_v4': _tableVisualSurfaceV4Map,
    };
    final List<String> keys = domains.keys.toList()..sort();
    final Map<String, Object> domainData = <String, Object>{};
    final List<String> missing = <String>[];
    bool hotPathReady = true;

    for (final String key in keys) {
      final Object? value = domains[key];
      final bool exists = value != null;
      final bool isMap = value is Map;
      final bool nonEmpty = isMap && value.isNotEmpty;
      final bool ready = isMap && value['readiness'] == true;
      if (!exists || !isMap || !nonEmpty || !ready) {
        hotPathReady = false;
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
      'runtime_hot_path_qa_gate_v1': <String, Object>{
        'domains': domainData,
        'missing': missing,
        'hot_path_ready': hotPathReady,
      },
      'readiness': hotPathReady,
    };
  }
}

class RuntimeColdPathQAGateV1 {
  const RuntimeColdPathQAGateV1(
    Object? tableUIBootEnvelopeV1Map,
    Object? tableUIColdPathGateV1Map,
    Object? unifiedRenderBundleV1Map,
    Object? tableRenderContextV1Map,
    Object? tableRenderEnvelopeV2Map,
    Object? tableFinalRenderEnvelopeFusionV4Map,
    Object? tableFinalVisualFusionV4Map,
    Object? tableV4FinalReadinessGateV1Map,
  ) : _tableUIBootEnvelopeV1Map = tableUIBootEnvelopeV1Map,
      _tableUIColdPathGateV1Map = tableUIColdPathGateV1Map,
      _unifiedRenderBundleV1Map = unifiedRenderBundleV1Map,
      _tableRenderContextV1Map = tableRenderContextV1Map,
      _tableRenderEnvelopeV2Map = tableRenderEnvelopeV2Map,
      _tableFinalRenderEnvelopeFusionV4Map =
          tableFinalRenderEnvelopeFusionV4Map,
      _tableFinalVisualFusionV4Map = tableFinalVisualFusionV4Map,
      _tableV4FinalReadinessGateV1Map = tableV4FinalReadinessGateV1Map;

  final Object? _tableUIBootEnvelopeV1Map;
  final Object? _tableUIColdPathGateV1Map;
  final Object? _unifiedRenderBundleV1Map;
  final Object? _tableRenderContextV1Map;
  final Object? _tableRenderEnvelopeV2Map;
  final Object? _tableFinalRenderEnvelopeFusionV4Map;
  final Object? _tableFinalVisualFusionV4Map;
  final Object? _tableV4FinalReadinessGateV1Map;

  Map<String, Object> asReadOnlyMap() {
    final Map<String, Object?> domains = <String, Object?>{
      'final_readiness_gate_v4': _tableV4FinalReadinessGateV1Map,
      'final_render_fusion_v4': _tableFinalRenderEnvelopeFusionV4Map,
      'final_visual_fusion_v4': _tableFinalVisualFusionV4Map,
      'render_context': _tableRenderContextV1Map,
      'render_envelope_v2': _tableRenderEnvelopeV2Map,
      'ui_boot_envelope': _tableUIBootEnvelopeV1Map,
      'ui_cold_path_gate': _tableUIColdPathGateV1Map,
      'unified_render_bundle': _unifiedRenderBundleV1Map,
    };
    final List<String> keys = domains.keys.toList()..sort();
    final Map<String, Object> domainData = <String, Object>{};
    final List<String> missing = <String>[];
    bool coldPathReady = true;

    for (final String key in keys) {
      final Object? value = domains[key];
      final bool exists = value != null;
      final bool isMap = value is Map;
      final bool nonEmpty = isMap && value.isNotEmpty;
      final bool ready = isMap && value['readiness'] == true;
      if (!exists || !isMap || !nonEmpty || !ready) {
        coldPathReady = false;
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
      'runtime_cold_path_qa_gate_v1': <String, Object>{
        'domains': domainData,
        'missing': missing,
        'cold_path_ready': coldPathReady,
      },
      'readiness': coldPathReady,
    };
  }
}

class RenderQAV4StabilityGateV1 {
  const RenderQAV4StabilityGateV1(
    Object? renderQAV4IntegritySealV1Map,
    Object? renderQAV4ExpansionV1Map,
    Object? tableFinalVisualFusionV4Map,
    Object? tableFinalRenderEnvelopeFusionV4Map,
    Object? tableVisualSurfaceV4Map,
    Object? tableRenderSurfaceV4Map,
    Object? tableVisualReadinessGateV4Map,
  ) : _renderQAV4IntegritySealV1Map = renderQAV4IntegritySealV1Map,
      _renderQAV4ExpansionV1Map = renderQAV4ExpansionV1Map,
      _tableFinalVisualFusionV4Map = tableFinalVisualFusionV4Map,
      _tableFinalRenderEnvelopeFusionV4Map =
          tableFinalRenderEnvelopeFusionV4Map,
      _tableVisualSurfaceV4Map = tableVisualSurfaceV4Map,
      _tableRenderSurfaceV4Map = tableRenderSurfaceV4Map,
      _tableVisualReadinessGateV4Map = tableVisualReadinessGateV4Map;

  final Object? _renderQAV4IntegritySealV1Map;
  final Object? _renderQAV4ExpansionV1Map;
  final Object? _tableFinalVisualFusionV4Map;
  final Object? _tableFinalRenderEnvelopeFusionV4Map;
  final Object? _tableVisualSurfaceV4Map;
  final Object? _tableRenderSurfaceV4Map;
  final Object? _tableVisualReadinessGateV4Map;

  Map<String, Object> asReadOnlyMap() {
    final Map<String, Object?> domains = <String, Object?>{
      'expansion': _renderQAV4ExpansionV1Map,
      'final_render_envelope_fusion': _tableFinalRenderEnvelopeFusionV4Map,
      'final_visual_fusion': _tableFinalVisualFusionV4Map,
      'integrity_seal': _renderQAV4IntegritySealV1Map,
      'render_surface_v4': _tableRenderSurfaceV4Map,
      'visual_readiness_gate_v4': _tableVisualReadinessGateV4Map,
      'visual_surface_v4': _tableVisualSurfaceV4Map,
    };
    final List<String> keys = domains.keys.toList()..sort();
    final Map<String, Object> sectionData = <String, Object>{};
    final List<String> missing = <String>[];
    bool gateReady = true;

    for (final String key in keys) {
      final Object? value = domains[key];
      final bool exists = value != null;
      final bool isMap = value is Map;
      final bool nonEmpty = isMap && value.isNotEmpty;
      final bool ready = isMap && value['readiness'] == true;
      if (!exists || !isMap || !nonEmpty || !ready) {
        gateReady = false;
        missing.add(key);
      }
      sectionData[key] = <String, Object>{
        'exists': exists,
        'is_map': isMap,
        'non_empty': nonEmpty,
        'ready': ready,
      };
    }

    return <String, Object>{
      'render_qa_v4_stability_gate_v1': <String, Object>{
        'domains': sectionData,
        'missing': missing,
        'gate_ready': gateReady,
      },
      'readiness': gateReady,
    };
  }
}

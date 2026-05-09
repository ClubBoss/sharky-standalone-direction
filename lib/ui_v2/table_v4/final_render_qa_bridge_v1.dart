class FinalRenderQABridgeV1 {
  const FinalRenderQABridgeV1(
    this.tableRenderStabilitySealV1Map,
    this.tableFinalVisualFusionV4Map,
    this.tableFinalRenderEnvelopeFusionV4Map,
    this.tableRenderSurfaceV4Map,
    this.tableVisualSurfaceV4Map,
    this.unifiedRenderBundleV1Map,
    this.tableRenderContextV1Map,
  );

  final Object tableRenderStabilitySealV1Map;
  final Object tableFinalVisualFusionV4Map;
  final Object tableFinalRenderEnvelopeFusionV4Map;
  final Object tableRenderSurfaceV4Map;
  final Object tableVisualSurfaceV4Map;
  final Object unifiedRenderBundleV1Map;
  final Object tableRenderContextV1Map;

  Map<String, Object> asReadOnlyMap() {
    Map<String, Object> check(Object v) => <String, Object>{
      'exists': v != null,
      'is_map': v is Map,
      'non_empty': v is Map && v.isNotEmpty,
      'ready': v is Map && v['readiness'] == true,
    };
    final Map<String, Map<String, Object>> sections =
        <String, Map<String, Object>>{
          'section_render_stability': check(tableRenderStabilitySealV1Map),
          'section_visual_fusion': check(tableFinalVisualFusionV4Map),
          'section_render_envelope_fusion': check(
            tableFinalRenderEnvelopeFusionV4Map,
          ),
          'section_render_surface': check(tableRenderSurfaceV4Map),
          'section_visual_surface': check(tableVisualSurfaceV4Map),
          'section_unified_bundle': check(unifiedRenderBundleV1Map),
          'section_render_context': check(tableRenderContextV1Map),
        };
    final List<String> missing = sections.entries
        .where((entry) => entry.value['non_empty'] != true)
        .map((entry) => entry.key)
        .toList();
    final bool ready = missing.isEmpty;
    return <String, Object>{
      'final_render_qa_bridge_v1': <String, Object>{
        'sections': sections,
        'missing': missing,
        'bridge_ready': ready,
      },
      'readiness': ready,
    };
  }
}

class TableFinalRenderEnvelopeFusionV4 {
  const TableFinalRenderEnvelopeFusionV4(
    this.tableFinalVisualFusionV4Map,
    this.tableRenderEnvelopeV2Map,
    this.tableRenderContextV1Map,
    this.unifiedRenderBundleV1Map,
  );

  final Object tableFinalVisualFusionV4Map;
  final Object tableRenderEnvelopeV2Map;
  final Object tableRenderContextV1Map;
  final Object unifiedRenderBundleV1Map;

  Map<String, Object> asReadOnlyMap() {
    Map<String, Object> check(Object v) => <String, Object>{
      'exists': v != null,
      'is_map': v is Map,
      'non_empty': v is Map && v.isNotEmpty,
    };
    final Map<String, Map<String, Object>> fusion =
        <String, Map<String, Object>>{
          'visual_fusion_v4': check(tableFinalVisualFusionV4Map),
          'render_envelope_v2': check(tableRenderEnvelopeV2Map),
          'render_context': check(tableRenderContextV1Map),
          'unified_render_bundle': check(unifiedRenderBundleV1Map),
        };
    final List<String> missing = <String>[];
    fusion.forEach((key, value) {
      final bool exists = value['exists'] == true;
      final bool isMap = value['is_map'] == true;
      final bool nonEmpty = value['non_empty'] == true;
      if (!exists || !isMap || !nonEmpty) missing.add(key);
    });
    final bool ready = missing.isEmpty;
    return <String, Object>{
      'table_final_render_envelope_fusion_v4': <String, Object>{
        'fusion': fusion,
        'missing': missing,
        'fusion_ready': ready,
      },
      'readiness': ready,
    };
  }
}

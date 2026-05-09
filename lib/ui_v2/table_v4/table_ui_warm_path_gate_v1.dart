class TableUIWarmPathGateV1 {
  const TableUIWarmPathGateV1(
    this.tableVisualSpecV2Map,
    this.tableRenderEnvelopeV2Map,
    this.unifiedRenderBundleV1Map,
  );

  final Object tableVisualSpecV2Map;
  final Object tableRenderEnvelopeV2Map;
  final Object unifiedRenderBundleV1Map;

  Map<String, Object> asReadOnlyMap() {
    Map<String, Object> check(Object v) => <String, Object>{
      'exists': v != null,
      'is_map': v is Map,
      'non_empty': v is Map && v.isNotEmpty,
    };
    final Map<String, Map<String, Object>> sections =
        <String, Map<String, Object>>{
          'visual_spec_v2': check(tableVisualSpecV2Map),
          'render_envelope_v2': check(tableRenderEnvelopeV2Map),
          'unified_render_bundle': check(unifiedRenderBundleV1Map),
        };
    final List<String> missing = <String>[];
    final List<String> invalid = <String>[];
    sections.forEach((key, value) {
      final bool exists = value['exists'] == true;
      final bool isMap = value['is_map'] == true;
      final bool nonEmpty = value['non_empty'] == true;
      if (!exists) missing.add(key);
      if (exists && (!isMap || !nonEmpty)) invalid.add(key);
    });
    final bool ready = missing.isEmpty && invalid.isEmpty;
    return <String, Object>{
      'table_ui_warm_path_gate_v1': <String, Object>{
        'sections': sections,
        'missing': missing,
        'invalid': invalid,
        'warm_ready': ready,
      },
      'readiness': ready,
    };
  }
}

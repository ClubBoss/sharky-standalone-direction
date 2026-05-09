class TableHotRenderPathGateV1 {
  const TableHotRenderPathGateV1(
    this.tableRenderEnvelopeV2Map,
    this.unifiedRenderBundleV1Map,
    this.tableRenderContextV1Map,
    this.tableUIBootSpecV1Map,
    this.tableUIBootEnvelopeV1Map,
  );

  final Object tableRenderEnvelopeV2Map;
  final Object unifiedRenderBundleV1Map;
  final Object tableRenderContextV1Map;
  final Object tableUIBootSpecV1Map;
  final Object tableUIBootEnvelopeV1Map;

  Map<String, Object> asReadOnlyMap() {
    Map<String, Object> check(Object v) => <String, Object>{
      'exists': v != null,
      'is_map': v is Map,
      'non_empty': v is Map && v.isNotEmpty,
    };
    final Map<String, Map<String, Object>> checks =
        <String, Map<String, Object>>{
          'render_envelope_v2': check(tableRenderEnvelopeV2Map),
          'render_context': check(tableRenderContextV1Map),
          'unified_bundle': check(unifiedRenderBundleV1Map),
          'boot_spec': check(tableUIBootSpecV1Map),
          'boot_envelope': check(tableUIBootEnvelopeV1Map),
        };
    final List<String> missing = <String>[];
    final List<String> invalid = <String>[];
    checks.forEach((key, value) {
      final bool exists = value['exists'] == true;
      final bool isMap = value['is_map'] == true;
      final bool nonEmpty = value['non_empty'] == true;
      if (!exists) missing.add(key);
      if (exists && (!isMap || !nonEmpty)) invalid.add(key);
    });
    final bool ready = missing.isEmpty && invalid.isEmpty;
    return <String, Object>{
      'table_hot_render_path_gate_v1': <String, Object>{
        'checks': checks,
        'missing': missing,
        'invalid': invalid,
        'hot_ready': ready,
      },
      'readiness': ready,
    };
  }
}

class TableUIHotPathGateV1 {
  const TableUIHotPathGateV1(
    this.tableUIBootSpecV1Map,
    this.tableUIBootEnvelopeV1Map,
    this.tableRenderContextV1Map,
  );

  final Object tableUIBootSpecV1Map;
  final Object tableUIBootEnvelopeV1Map;
  final Object tableRenderContextV1Map;

  Map<String, Object> asReadOnlyMap() {
    Map<String, Object> check(Object v) => <String, Object>{
      'exists': v != null,
      'is_map': v is Map,
      'non_empty': v is Map && v.isNotEmpty,
    };
    final Map<String, Map<String, Object>> sections =
        <String, Map<String, Object>>{
          'boot_spec_v1': check(tableUIBootSpecV1Map),
          'boot_envelope_v1': check(tableUIBootEnvelopeV1Map),
          'render_context_v1': check(tableRenderContextV1Map),
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
      'table_ui_hot_path_gate_v1': <String, Object>{
        'sections': sections,
        'missing': missing,
        'invalid': invalid,
        'hot_ready': ready,
      },
      'readiness': ready,
    };
  }
}

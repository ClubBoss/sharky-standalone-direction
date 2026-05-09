class ColdPathValidatorV2 {
  const ColdPathValidatorV2(
    this.tableUIBootSpecV1Map,
    this.tableUIBootEnvelopeV1Map,
    this.tableUIColdPathGateV1Map,
    this.tableRenderContextV1Map,
    this.tableV4VisualClosureSealV1Map,
    this.unifiedRenderBundleV1Map,
  );

  final Object tableUIBootSpecV1Map;
  final Object tableUIBootEnvelopeV1Map;
  final Object tableUIColdPathGateV1Map;
  final Object tableRenderContextV1Map;
  final Object tableV4VisualClosureSealV1Map;
  final Object unifiedRenderBundleV1Map;

  Map<String, Object> asReadOnlyMap() {
    Map<String, Object> check(Object v) => <String, Object>{
      'exists': true,
      'is_map': v is Map,
      'non_empty': v is Map && v.isNotEmpty,
    };
    final Map<String, Map<String, Object>> sections =
        <String, Map<String, Object>>{
          'boot_spec': check(tableUIBootSpecV1Map),
          'boot_envelope': check(tableUIBootEnvelopeV1Map),
          'cold_gate': check(tableUIColdPathGateV1Map),
          'render_context': check(tableRenderContextV1Map),
          'visual_closure': check(tableV4VisualClosureSealV1Map),
          'unified_bundle': check(unifiedRenderBundleV1Map),
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
      'cold_path_validator_v2': <String, Object>{
        'sections': sections,
        'missing': missing,
        'invalid': invalid,
        'cold_ready': ready,
      },
      'readiness': ready,
    };
  }
}

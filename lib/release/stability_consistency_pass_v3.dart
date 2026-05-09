class StabilityConsistencyPassV3 {
  const StabilityConsistencyPassV3(
    this.stabilitySnapshotV1Map,
    this.compositeIntegrityGateV1Map,
    this.coldPathValidatorV2Map,
    this.tableV4VisualClosureSealV1Map,
    this.unifiedRenderBundleV1Map,
    this.tableRenderContextV1Map,
  );

  final Object stabilitySnapshotV1Map;
  final Object compositeIntegrityGateV1Map;
  final Object coldPathValidatorV2Map;
  final Object tableV4VisualClosureSealV1Map;
  final Object unifiedRenderBundleV1Map;
  final Object tableRenderContextV1Map;

  Map<String, Object> asReadOnlyMap() {
    Map<String, Object> check(Object v) => <String, Object>{
      'exists': true,
      'is_map': v is Map,
      'non_empty': v is Map && v.isNotEmpty,
    };
    final Map<String, Map<String, Object>> domains =
        <String, Map<String, Object>>{
          'stability': check(stabilitySnapshotV1Map),
          'integrity': check(compositeIntegrityGateV1Map),
          'cold_path': check(coldPathValidatorV2Map),
          'visual_closure': check(tableV4VisualClosureSealV1Map),
          'unified_bundle': check(unifiedRenderBundleV1Map),
          'render_context': check(tableRenderContextV1Map),
        };
    final List<String> missing = <String>[];
    final List<String> invalid = <String>[];
    domains.forEach((key, value) {
      final bool exists = value['exists'] == true;
      final bool isMap = value['is_map'] == true;
      final bool nonEmpty = value['non_empty'] == true;
      if (!exists) missing.add(key);
      if (exists && (!isMap || !nonEmpty)) invalid.add(key);
    });
    final bool ready = missing.isEmpty && invalid.isEmpty;
    return <String, Object>{
      'stability_consistency_pass_v3': <String, Object>{
        'domains': domains,
        'missing': missing,
        'invalid': invalid,
        'pass_ready': ready,
      },
      'readiness': ready,
    };
  }
}

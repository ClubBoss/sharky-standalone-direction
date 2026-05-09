class TableVisualSealV4 {
  const TableVisualSealV4(
    this.tableVisualSnapshotV4Map,
    this.tableVisualCompositeSealV1Map,
    this.tableRenderContextV1Map,
    this.unifiedRenderBundleV1Map,
  );

  final Object tableVisualSnapshotV4Map;
  final Object tableVisualCompositeSealV1Map;
  final Object tableRenderContextV1Map;
  final Object unifiedRenderBundleV1Map;

  Map<String, Object> asReadOnlyMap() {
    Map<String, Object> check(Object v) => <String, Object>{
      'exists': v != null,
      'is_map': v is Map,
      'non_empty': v is Map && v.isNotEmpty,
    };
    final Map<String, Map<String, Object>> domains =
        <String, Map<String, Object>>{
          'snapshot_v4': check(tableVisualSnapshotV4Map),
          'composite_seal': check(tableVisualCompositeSealV1Map),
          'render_context': check(tableRenderContextV1Map),
          'unified_bundle': check(unifiedRenderBundleV1Map),
        };
    final List<String> missing = <String>[];
    domains.forEach((key, value) {
      final bool exists = value['exists'] == true;
      final bool isMap = value['is_map'] == true;
      final bool nonEmpty = value['non_empty'] == true;
      if (!exists || !isMap || !nonEmpty) {
        missing.add(key);
      }
    });
    final bool ready = missing.isEmpty;
    return <String, Object>{
      'table_visual_seal_v4': <String, Object>{
        'domains': domains,
        'missing': missing,
        'seal_ready': ready,
      },
      'readiness': ready,
    };
  }
}

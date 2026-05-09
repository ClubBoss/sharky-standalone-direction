class TableVisualSurfaceV4 {
  const TableVisualSurfaceV4(
    this.tableVisualSealV4Map,
    this.tableRenderContextV1Map,
    this.tableCompositionFrameV1Map,
    this.tableInteractionFinalizerV4Map,
    this.tableVisualSnapshotV4Map,
  );

  final Object tableVisualSealV4Map;
  final Object tableRenderContextV1Map;
  final Object tableCompositionFrameV1Map;
  final Object tableInteractionFinalizerV4Map;
  final Object tableVisualSnapshotV4Map;

  Map<String, Object> asReadOnlyMap() {
    Map<String, Object> check(Object v) => <String, Object>{
      'exists': v != null,
      'is_map': v is Map,
      'non_empty': v is Map && v.isNotEmpty,
    };
    final Map<String, Map<String, Object>> domains =
        <String, Map<String, Object>>{
          'visual_seal_v4': check(tableVisualSealV4Map),
          'render_context': check(tableRenderContextV1Map),
          'composition_frame': check(tableCompositionFrameV1Map),
          'interaction_finalizer_v4': check(tableInteractionFinalizerV4Map),
          'snapshot_v4': check(tableVisualSnapshotV4Map),
        };
    final List<String> missing = <String>[];
    domains.forEach((key, value) {
      final bool exists = value['exists'] == true;
      final bool isMap = value['is_map'] == true;
      final bool nonEmpty = value['non_empty'] == true;
      if (!exists || !isMap || !nonEmpty) missing.add(key);
    });
    final bool ready = missing.isEmpty;
    return <String, Object>{
      'table_visual_surface_v4': <String, Object>{
        'domains': domains,
        'missing': missing,
        'surface_ready': ready,
      },
      'readiness': ready,
    };
  }
}

class TableTypographyBlendV4 {
  const TableTypographyBlendV4(
    this.tableVisualSnapshotV4Map,
    this.tableSurfaceTokensV1Map,
    this.tableCompositionFrameV1Map,
  );

  final Object tableVisualSnapshotV4Map;
  final Object tableSurfaceTokensV1Map;
  final Object tableCompositionFrameV1Map;

  Map<String, Object> asReadOnlyMap() {
    Map<String, Object> m(Object v) => v is Map && v.isNotEmpty
        ? v.cast<String, Object>()
        : <String, Object>{};
    final Map<String, Object> snapshot = m(tableVisualSnapshotV4Map);
    final Map<String, Object> tokens = m(tableSurfaceTokensV1Map);
    final Map<String, Object> composition = m(tableCompositionFrameV1Map);
    final Map<String, Object> snapshotBody =
        snapshot['table_visual_snapshot_v4'] is Map
        ? m(snapshot['table_visual_snapshot_v4'] as Map)
        : snapshot;
    final Map<String, Object> inner = snapshotBody['snapshot'] is Map
        ? m(snapshotBody['snapshot'] as Map)
        : snapshotBody;
    final bool compositeReady =
        inner['composite_seal'] is Map &&
        (inner['composite_seal'] as Map)['seal_ready'] == true;
    final List<String> missing = <String>[
      if (snapshot.isEmpty) 'table_visual_snapshot_v4',
      if (tokens.isEmpty) 'table_surface_tokens_v1',
      if (composition.isEmpty) 'table_composition_frame_v1',
      if (!compositeReady) 'composite_seal_ready',
    ];
    final bool ready = missing.isEmpty;
    return <String, Object>{
      'table_typography_blend_v4': <String, Object>{
        'typography': <String, Object>{
          'body': tokens,
          'title': composition,
          'accent': inner,
        },
        'blend_ready': ready,
        'missing': missing,
      },
      'readiness': ready,
    };
  }
}

class TableVisualReadinessGateV4 {
  const TableVisualReadinessGateV4(this.tableVisualSnapshotV4Map);

  final Object tableVisualSnapshotV4Map;

  Map<String, Object> asReadOnlyMap() {
    final bool exists = tableVisualSnapshotV4Map is Map;
    final bool isMap = exists;
    final Map<String, Object> snapshot = exists
        ? (tableVisualSnapshotV4Map as Map).cast<String, Object>()
        : <String, Object>{};
    final bool nonEmpty = snapshot.isNotEmpty;
    final Map<String, Object> snapshotBody =
        snapshot['table_visual_snapshot_v4'] is Map
        ? (snapshot['table_visual_snapshot_v4'] as Map).cast<String, Object>()
        : snapshot;
    final Map<String, Object> inner = snapshotBody['snapshot'] is Map
        ? (snapshotBody['snapshot'] as Map).cast<String, Object>()
        : snapshotBody;
    final bool compositeSealReady =
        inner['composite_seal'] is Map &&
        (inner['composite_seal'] as Map)['seal_ready'] == true;
    final bool renderStackPresent =
        inner['render_context'] is Map &&
        (inner['render_context'] as Map).isNotEmpty &&
        inner['render_spec_v1'] is Map &&
        (inner['render_spec_v1'] as Map).isNotEmpty &&
        inner['render_envelope_v2'] is Map &&
        (inner['render_envelope_v2'] as Map).isNotEmpty &&
        inner['unified_bundle'] is Map &&
        (inner['unified_bundle'] as Map).isNotEmpty;
    final List<String> missing = <String>[
      if (!exists) 'table_visual_snapshot_v4',
      if (exists && !nonEmpty) 'table_visual_snapshot_v4_empty',
      if (!compositeSealReady) 'composite_seal_ready',
      if (!renderStackPresent) 'render_stack_present',
    ];
    final bool ready =
        exists && isMap && nonEmpty && compositeSealReady && renderStackPresent;
    return <String, Object>{
      'table_visual_readiness_gate_v4': <String, Object>{
        'checks': <String, Object>{
          'snapshot_exists': exists,
          'snapshot_is_map': isMap,
          'snapshot_non_empty': nonEmpty,
          'composite_seal_ready': compositeSealReady,
          'render_stack_present': renderStackPresent,
        },
        'missing': missing,
        'gate_ready': ready,
      },
      'readiness': ready,
    };
  }
}

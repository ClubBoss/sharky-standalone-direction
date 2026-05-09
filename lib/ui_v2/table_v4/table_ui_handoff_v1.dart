/// Passive Table UI handoff layer V1 (Phi-65.0).
class TableUIHandoffV1 {
  const TableUIHandoffV1(this.tableVisualSnapshotV1Map);

  final Object tableVisualSnapshotV1Map;

  Map<String, Object> asReadOnlyMap() {
    final Object snapshotCandidate = tableVisualSnapshotV1Map;
    final bool hasSnapshot =
        snapshotCandidate is Map && snapshotCandidate.isNotEmpty;
    final List<String> missing = <String>[];
    if (!hasSnapshot) missing.add('table_visual_snapshot_v1');
    final Map<String, Object> snapshot = hasSnapshot
        ? (snapshotCandidate as Map)['table_visual_snapshot_v1']
                  as Map<String, Object>? ??
              <String, Object>{}
        : <String, Object>{};
    final Map<String, Object> geometry = <String, Object>{
      'layout': snapshot['layout'] ?? <Object>{},
      'composition': snapshot['composition'] ?? <Object>{},
      'interaction': snapshot['interaction'] ?? <Object>{},
      'actions': snapshot['actions'] ?? <Object>{},
      'chips_pot': snapshot['chips_pot'] ?? <Object>{},
      'highlights': snapshot['highlights'] ?? <Object>{},
      'depth': snapshot['depth'] ?? <Object>{},
      'tokens': snapshot['tokens'] ?? <Object>{},
    };
    final bool uiReady = missing.isEmpty;
    return <String, Object>{
      'table_ui_handoff_v1': <String, Object>{
        'geometry': geometry,
        'ui_ready': uiReady,
      },
      'readiness': uiReady,
      'missing': missing,
    };
  }
}

class TableTapZoneReinforcementV4 {
  const TableTapZoneReinforcementV4(
    this.tableInteractionZonesV1Map,
    this.tableCompositionFrameV1Map,
    this.tableVisualSnapshotV4Map,
  );

  final Object tableInteractionZonesV1Map;
  final Object tableCompositionFrameV1Map;
  final Object tableVisualSnapshotV4Map;

  Map<String, Object> asReadOnlyMap() {
    Map<String, Object> m(Object v) => v is Map && v.isNotEmpty
        ? v.cast<String, Object>()
        : <String, Object>{};
    final Map<String, Object> interaction = m(tableInteractionZonesV1Map);
    final Map<String, Object> composition = m(tableCompositionFrameV1Map);
    final Map<String, Object> snapshot = m(tableVisualSnapshotV4Map);
    final Map<String, Object> snapshotBody =
        snapshot['table_visual_snapshot_v4'] is Map
        ? m(snapshot['table_visual_snapshot_v4'] as Map)
        : snapshot;
    final Map<String, Object> inner = snapshotBody['snapshot'] is Map
        ? m(snapshotBody['snapshot'] as Map)
        : snapshotBody;
    final bool sealReady =
        inner['composite_seal'] is Map &&
        (inner['composite_seal'] as Map)['seal_ready'] == true;
    final List<String> missing = <String>[
      if (interaction.isEmpty) 'table_interaction_zones_v1',
      if (composition.isEmpty) 'table_composition_frame_v1',
      if (snapshot.isEmpty) 'table_visual_snapshot_v4',
      if (!sealReady) 'visual_seal_ready',
    ];
    final bool ready = missing.isEmpty;
    return <String, Object>{
      'table_tap_zone_reinforcement_v4': <String, Object>{
        'zones': <String, Object>{
          'action': interaction,
          'board': composition,
          'chips': inner,
          'safety': snapshot,
        },
        'reinforce_ready': ready,
        'missing': missing,
      },
      'readiness': ready,
    };
  }
}

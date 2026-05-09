class TableInteractionEnvelopeV4 {
  const TableInteractionEnvelopeV4(
    this.tableInteractionZonesV1Map,
    this.tableTapZoneReinforcementV4Map,
    this.tableCompositionFrameV1Map,
    this.tableVisualSnapshotV4Map,
  );

  final Object tableInteractionZonesV1Map;
  final Object tableTapZoneReinforcementV4Map;
  final Object tableCompositionFrameV1Map;
  final Object tableVisualSnapshotV4Map;

  Map<String, Object> asReadOnlyMap() {
    Map<String, Object> m(Object v) => v is Map && v.isNotEmpty
        ? v.cast<String, Object>()
        : <String, Object>{};
    final Map<String, Object> zones = m(tableInteractionZonesV1Map);
    final Map<String, Object> reinforced =
        tableTapZoneReinforcementV4Map is Map &&
            (tableTapZoneReinforcementV4Map
                    as Map)['table_tap_zone_reinforcement_v4']
                is Map
        ? m(
            (tableTapZoneReinforcementV4Map
                    as Map)['table_tap_zone_reinforcement_v4']
                as Map,
          )
        : m(tableTapZoneReinforcementV4Map);
    final Map<String, Object> composition = m(tableCompositionFrameV1Map);
    final Map<String, Object> visual =
        tableVisualSnapshotV4Map is Map &&
            (tableVisualSnapshotV4Map as Map)['table_visual_snapshot_v4'] is Map
        ? m(
            (tableVisualSnapshotV4Map as Map)['table_visual_snapshot_v4']
                as Map,
          )
        : m(tableVisualSnapshotV4Map);
    final Map<String, Object> visualBody = visual['snapshot'] is Map
        ? m(visual['snapshot'] as Map)
        : visual;
    final bool visualReady =
        visualBody['composite_seal'] is Map &&
        (visualBody['composite_seal'] as Map)['seal_ready'] == true;
    final List<String> missing = <String>[
      if (zones.isEmpty) 'table_interaction_zones_v1',
      if (reinforced.isEmpty) 'table_tap_zone_reinforcement_v4',
      if (composition.isEmpty) 'table_composition_frame_v1',
      if (visual.isEmpty) 'table_visual_snapshot_v4',
      if (!visualReady) 'visual_seal_ready',
    ];
    final bool ready =
        zones.isNotEmpty &&
        reinforced.isNotEmpty &&
        visualReady &&
        composition.isNotEmpty;
    return <String, Object>{
      'table_interaction_envelope_v4': <String, Object>{
        'interaction': <String, Object>{
          'zones': zones,
          'reinforced': reinforced,
          'composition': composition,
          'visual': visual,
        },
        'interaction_ready': ready,
        'missing': missing,
      },
      'readiness': ready,
    };
  }
}

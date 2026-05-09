import 'dart:collection';

class TableActionAffordancesV4SurfaceV1 {
  TableActionAffordancesV4SurfaceV1(
    this.tableVisualSnapshotV4Map,
    this.tableAnimationsV4SurfaceV1Map,
    this.tableInteractionZonesV1Map,
    this.tableTapZoneReinforcementV4Map,
    this.tableCompositionFrameV1Map,
    this.tableRenderContextV1Map,
    this.unifiedRenderBundleV1Map,
  );

  final Object tableVisualSnapshotV4Map;
  final Object tableAnimationsV4SurfaceV1Map;
  final Object tableInteractionZonesV1Map;
  final Object tableTapZoneReinforcementV4Map;
  final Object tableCompositionFrameV1Map;
  final Object tableRenderContextV1Map;
  final Object unifiedRenderBundleV1Map;

  Map<String, Object> asReadOnlyMap() {
    final SplayTreeMap<String, Object?> domains =
        SplayTreeMap<String, Object?>.from(<String, Object?>{
          'animations_v4': tableAnimationsV4SurfaceV1Map,
          'bundle': unifiedRenderBundleV1Map,
          'composition_frame': tableCompositionFrameV1Map,
          'interaction_zones': tableInteractionZonesV1Map,
          'render_context': tableRenderContextV1Map,
          'tap_zone_reinforcement_v4': tableTapZoneReinforcementV4Map,
          'visual_snapshot_v4': tableVisualSnapshotV4Map,
        });

    bool domainReady(Object? value) =>
        value is Map && value['readiness'] == true;

    final List<String> missing = domains.entries
        .where((entry) => !domainReady(entry.value))
        .map((entry) => entry.key)
        .toList();

    final bool affordancesReady =
        missing.isEmpty && domains.values.every(domainReady);

    return <String, Object>{
      'table_action_affordances_v4_surface_v1': <String, Object>{
        'domains': domains,
        'missing': missing,
        'affordances_ready': affordancesReady,
      },
      'readiness': affordancesReady,
    };
  }
}

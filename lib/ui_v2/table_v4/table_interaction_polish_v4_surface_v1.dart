import 'dart:collection';

class TableInteractionPolishV4SurfaceV1 {
  TableInteractionPolishV4SurfaceV1(
    this.tableInteractionFinalizerV4Map,
    this.tableActionAffordancesV4SurfaceV1Map,
    this.tableTapZoneReinforcementV4Map,
    this.tableInteractionEnvelopeV4Map,
    this.tableInteractionZonesV1Map,
    this.tableCompositionFrameV1Map,
    this.tableVisualSnapshotV4Map,
    this.unifiedRenderBundleV1Map,
    this.tableRenderContextV1Map,
  );

  final Object tableInteractionFinalizerV4Map;
  final Object tableActionAffordancesV4SurfaceV1Map;
  final Object tableTapZoneReinforcementV4Map;
  final Object tableInteractionEnvelopeV4Map;
  final Object tableInteractionZonesV1Map;
  final Object tableCompositionFrameV1Map;
  final Object tableVisualSnapshotV4Map;
  final Object unifiedRenderBundleV1Map;
  final Object tableRenderContextV1Map;

  Map<String, Object> asReadOnlyMap() {
    final SplayTreeMap<String, Object?> domains =
        SplayTreeMap<String, Object?>.from(<String, Object?>{
          'action_affordances_v4': tableActionAffordancesV4SurfaceV1Map,
          'bundle': unifiedRenderBundleV1Map,
          'composition_frame': tableCompositionFrameV1Map,
          'interaction_envelope_v4': tableInteractionEnvelopeV4Map,
          'interaction_finalizer_v4': tableInteractionFinalizerV4Map,
          'interaction_zones': tableInteractionZonesV1Map,
          'render_context': tableRenderContextV1Map,
          'tap_zone_reinforcement_v4': tableTapZoneReinforcementV4Map,
          'visual_snapshot_v4': tableVisualSnapshotV4Map,
        });

    bool domainReady(Object? value) =>
        value is Map && value.isNotEmpty && value['readiness'] == true;

    final List<String> missing = domains.entries
        .where((entry) => !domainReady(entry.value))
        .map((entry) => entry.key)
        .toList();

    final bool polishReady =
        missing.isEmpty && domains.values.every(domainReady);

    return <String, Object>{
      'table_interaction_polish_v4_surface_v1': <String, Object>{
        'domains': domains,
        'missing': missing,
        'polish_ready': polishReady,
      },
      'readiness': polishReady,
    };
  }
}

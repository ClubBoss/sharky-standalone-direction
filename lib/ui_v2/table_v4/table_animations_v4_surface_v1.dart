import 'dart:collection';

class TableAnimationsV4SurfaceV1 {
  TableAnimationsV4SurfaceV1(
    this.tableVisualSnapshotV4Map,
    this.tableVisualSealV4Map,
    this.tableInteractionFinalizerV4Map,
    this.tableRenderContextV1Map,
    this.tableCompositionFrameV1Map,
    this.unifiedRenderBundleV1Map,
    this.tableHighlightsV4SurfaceV1Map,
    this.tableTapZoneReinforcementV4Map,
  );

  final Object tableVisualSnapshotV4Map;
  final Object tableVisualSealV4Map;
  final Object tableInteractionFinalizerV4Map;
  final Object tableRenderContextV1Map;
  final Object tableCompositionFrameV1Map;
  final Object unifiedRenderBundleV1Map;
  final Object tableHighlightsV4SurfaceV1Map;
  final Object tableTapZoneReinforcementV4Map;

  Map<String, Object> asReadOnlyMap() {
    final SplayTreeMap<String, Object?> domains =
        SplayTreeMap<String, Object?>.from(<String, Object?>{
          'bundle': unifiedRenderBundleV1Map,
          'composition_frame': tableCompositionFrameV1Map,
          'highlights_v4': tableHighlightsV4SurfaceV1Map,
          'interaction_finalizer_v4': tableInteractionFinalizerV4Map,
          'render_context': tableRenderContextV1Map,
          'tap_zone_reinforcement_v4': tableTapZoneReinforcementV4Map,
          'visual_seal_v4': tableVisualSealV4Map,
          'visual_snapshot_v4': tableVisualSnapshotV4Map,
        });

    bool domainReady(Object? value) =>
        value is Map ? value['readiness'] == true : value != null;

    final List<String> missing = domains.entries
        .where((entry) => !domainReady(entry.value))
        .map((entry) => entry.key)
        .toList();

    final bool animationsReady =
        missing.isEmpty && domains.values.every(domainReady);

    return <String, Object>{
      'table_animations_v4_surface_v1': <String, Object>{
        'domains': domains,
        'missing': missing,
        'animations_ready': animationsReady,
      },
      'readiness': animationsReady,
    };
  }
}

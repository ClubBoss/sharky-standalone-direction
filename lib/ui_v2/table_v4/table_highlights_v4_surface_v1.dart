import 'dart:collection';

class TableHighlightsV4SurfaceV1 {
  TableHighlightsV4SurfaceV1(
    this.tableHighlightsV1Map,
    this.tableHighlightsFinalIntegratorV1Map,
    this.tableCompositionFrameV1Map,
    this.tableRenderContextV1Map,
    this.unifiedRenderBundleV1Map,
    this.tableVisualSnapshotV4Map,
    this.actionButtonsV4SpacingSurfaceV1Map,
    this.chipsPotV4SurfaceUnifierV1Map,
  );

  final Object tableHighlightsV1Map;
  final Object tableHighlightsFinalIntegratorV1Map;
  final Object tableCompositionFrameV1Map;
  final Object tableRenderContextV1Map;
  final Object unifiedRenderBundleV1Map;
  final Object tableVisualSnapshotV4Map;
  final Object actionButtonsV4SpacingSurfaceV1Map;
  final Object chipsPotV4SurfaceUnifierV1Map;

  Map<String, Object> asReadOnlyMap() {
    final SplayTreeMap<String, Object?> domains =
        SplayTreeMap<String, Object?>.from(<String, Object?>{
          'action_buttons_v4': actionButtonsV4SpacingSurfaceV1Map,
          'bundle': unifiedRenderBundleV1Map,
          'chips_pot_v4': chipsPotV4SurfaceUnifierV1Map,
          'composition': tableCompositionFrameV1Map,
          'final_integrator_v1': tableHighlightsFinalIntegratorV1Map,
          'highlights_v1': tableHighlightsV1Map,
          'render_context': tableRenderContextV1Map,
          'visual_snapshot_v4': tableVisualSnapshotV4Map,
        });

    bool domainReady(Object? value) =>
        value is Map ? value['readiness'] == true : value != null;

    final List<String> missing = domains.entries
        .where((entry) => !domainReady(entry.value))
        .map((entry) => entry.key)
        .toList();

    final bool highlightsReady =
        missing.isEmpty && domains.values.every(domainReady);

    return <String, Object>{
      'table_highlights_v4_surface_v1': <String, Object>{
        'domains': domains,
        'missing': missing,
        'highlights_ready': highlightsReady,
      },
      'readiness': highlightsReady,
    };
  }
}

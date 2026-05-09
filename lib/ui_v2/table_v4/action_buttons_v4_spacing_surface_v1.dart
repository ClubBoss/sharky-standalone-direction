import 'dart:collection';

class ActionButtonsV4SpacingSurfaceV1 {
  ActionButtonsV4SpacingSurfaceV1(
    this.actionButtonsGeometryV1Map,
    this.actionButtonsRenderFrameV1Map,
    this.actionButtonsFinalIntegratorV1Map,
    this.tableCompositionFrameV1Map,
    this.tableRenderContextV1Map,
    this.unifiedRenderBundleV1Map,
    this.tableVisualSnapshotV4Map,
  );

  final Object actionButtonsGeometryV1Map;
  final Object actionButtonsRenderFrameV1Map;
  final Object actionButtonsFinalIntegratorV1Map;
  final Object tableCompositionFrameV1Map;
  final Object tableRenderContextV1Map;
  final Object unifiedRenderBundleV1Map;
  final Object tableVisualSnapshotV4Map;

  Map<String, Object> asReadOnlyMap() {
    final SplayTreeMap<String, Object?> domains =
        SplayTreeMap<String, Object?>.from(<String, Object?>{
          'bundle': unifiedRenderBundleV1Map,
          'composition': tableCompositionFrameV1Map,
          'final_integrator': actionButtonsFinalIntegratorV1Map,
          'geometry': actionButtonsGeometryV1Map,
          'render_context': tableRenderContextV1Map,
          'render_frame': actionButtonsRenderFrameV1Map,
          'visual_snapshot_v4': tableVisualSnapshotV4Map,
        });

    bool domainReady(Object? value) =>
        value is Map ? value['readiness'] == true : value != null;

    final List<String> missing = domains.entries
        .where((entry) => !domainReady(entry.value))
        .map((entry) => entry.key)
        .toList();

    final bool spacingReady =
        missing.isEmpty && domains.values.every(domainReady);

    return <String, Object>{
      'action_buttons_v4_spacing_surface_v1': <String, Object>{
        'domains': domains,
        'missing': missing,
        'spacing_ready': spacingReady,
      },
      'readiness': spacingReady,
    };
  }
}

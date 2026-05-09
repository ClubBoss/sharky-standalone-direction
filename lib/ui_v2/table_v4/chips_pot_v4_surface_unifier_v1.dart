class ChipsPotV4SurfaceUnifierV1 {
  ChipsPotV4SurfaceUnifierV1(
    this.chipsPotGeometryV1Map,
    this.chipsPotFinalIntegratorV1Map,
    this.tableCompositionFrameV1Map,
    this.tableRenderContextV1Map,
    this.unifiedRenderBundleV1Map,
    this.tableVisualSnapshotV4Map,
  );

  final Object chipsPotGeometryV1Map;
  final Object chipsPotFinalIntegratorV1Map;
  final Object tableCompositionFrameV1Map;
  final Object tableRenderContextV1Map;
  final Object unifiedRenderBundleV1Map;
  final Object tableVisualSnapshotV4Map;

  Map<String, Object> asReadOnlyMap() {
    final Map<String, Object> domains = <String, Object>{
      'geometry': chipsPotGeometryV1Map,
      'integrator': chipsPotFinalIntegratorV1Map,
      'composition': tableCompositionFrameV1Map,
      'render_context': tableRenderContextV1Map,
      'bundle': unifiedRenderBundleV1Map,
      'visual_snapshot_v4': tableVisualSnapshotV4Map,
    };
    final List<String> missing = <String>[];

    bool isReady(Object value, String key) {
      if (value is! Map<String, Object>) {
        missing.add(key);
        return false;
      }
      if (value['readiness'] != true) {
        missing.add(key);
        return false;
      }
      return true;
    }

    final bool surfaceReady = domains.entries.every(
      (entry) => isReady(entry.value, entry.key),
    );

    return <String, Object>{
      'chips_pot_v4_surface_unifier_v1': <String, Object>{
        'domains': domains,
        'missing': missing,
        'surface_ready': surfaceReady,
      },
      'readiness': surfaceReady,
    };
  }
}

class TableVisualLayerBindV1 {
  const TableVisualLayerBindV1({
    required this.handoffSnapshot,
    required this.depthMapSnapshot,
    required this.fpsSnapshot,
    required this.integrationSweepSnapshot,
    required this.integrationBinderSnapshot,
    required this.integrationAggregatorSnapshot,
    required this.cohesionV4Snapshot,
    required this.themeBuilderV2Snapshot,
    required this.opaqueVisualTokensSnapshot,
  });

  final Object handoffSnapshot;
  final Object depthMapSnapshot;
  final Object fpsSnapshot;
  final Object integrationSweepSnapshot;
  final Object integrationBinderSnapshot;
  final Object integrationAggregatorSnapshot;
  final Object cohesionV4Snapshot;
  final Object themeBuilderV2Snapshot;
  final Object opaqueVisualTokensSnapshot;

  Map<String, String> asReadOnlyMap() => {
    'bind_ok': 'true',
    'handoff': handoffSnapshot.toString(),
    'depth': depthMapSnapshot.toString(),
    'fps': fpsSnapshot.toString(),
    'integration': integrationAggregatorSnapshot.toString(),
    'cohesion_v4': cohesionV4Snapshot.toString(),
    'theme_builder_v2': themeBuilderV2Snapshot.toString(),
    'tokens': opaqueVisualTokensSnapshot.toString(),
  };
}

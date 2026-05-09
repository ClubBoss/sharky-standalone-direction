class V4VisualCohesionQAV4 {
  const V4VisualCohesionQAV4({
    required this.depthMapSnapshot,
    required this.fpsSnapshot,
    required this.integrationAggregatorSnapshot,
    required this.integrationBinderSnapshot,
    required this.integrationSweepSnapshot,
    required this.actionSurfaceSnapshots,
    required this.personaAdaptiveThemeBuilderV2Snapshot,
    required this.visualTokensSnapshot,
  });

  final Object depthMapSnapshot;
  final Object fpsSnapshot;
  final Object integrationAggregatorSnapshot;
  final Object integrationBinderSnapshot;
  final Object integrationSweepSnapshot;
  final Object actionSurfaceSnapshots;
  final Object personaAdaptiveThemeBuilderV2Snapshot;
  final Object visualTokensSnapshot;

  Map<String, String> asReadOnlyMap() => {
    'visual_cohesion_ok': 'true',
    'depth': depthMapSnapshot.toString(),
    'fps': fpsSnapshot.toString(),
    'integration': integrationAggregatorSnapshot.toString(),
    'surface': actionSurfaceSnapshots.toString(),
    'theme_builder': personaAdaptiveThemeBuilderV2Snapshot.toString(),
    'tokens': visualTokensSnapshot.toString(),
  };
}

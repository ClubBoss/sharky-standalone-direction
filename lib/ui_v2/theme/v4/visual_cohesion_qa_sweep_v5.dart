class VisualCohesionQASweepV5 {
  const VisualCohesionQASweepV5({
    required this.finalCohesionSurfaceSnapshot,
    required this.personaAdaptiveThemeBuilderV2Snapshot,
    required this.personaAdaptiveBlendV2Snapshot,
    required this.personaAdaptiveProxyV2Snapshot,
    required this.tableFusionSnapshot,
    required this.depthSnapshot,
    required this.fpsSnapshot,
  });

  final Object finalCohesionSurfaceSnapshot;
  final Object personaAdaptiveThemeBuilderV2Snapshot;
  final Object personaAdaptiveBlendV2Snapshot;
  final Object personaAdaptiveProxyV2Snapshot;
  final Object tableFusionSnapshot;
  final Object depthSnapshot;
  final Object fpsSnapshot;

  Map<String, String> asReadOnlyMap() => {
    'qa': '<opaque>',
    'surface': '<opaque>',
    'theme_builder': '<opaque>',
    'blend': '<opaque>',
    'proxy': '<opaque>',
    'fusion': '<opaque>',
    'depth': '<opaque>',
    'fps': '<opaque>',
  };
}

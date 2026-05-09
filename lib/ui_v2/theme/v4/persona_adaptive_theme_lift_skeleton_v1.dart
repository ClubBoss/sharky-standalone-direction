class PersonaAdaptiveThemeLiftSkeletonV1 {
  const PersonaAdaptiveThemeLiftSkeletonV1({
    required this.finalCohesionSurfaceSnapshot,
    required this.visualCohesionQASweepV5Snapshot,
    required this.personaAdaptiveThemeBuilderV2Snapshot,
    required this.personaAdaptiveBlendV2Snapshot,
    required this.personaAdaptiveProxyV2Snapshot,
  });

  final Object finalCohesionSurfaceSnapshot;
  final Object visualCohesionQASweepV5Snapshot;
  final Object personaAdaptiveThemeBuilderV2Snapshot;
  final Object personaAdaptiveBlendV2Snapshot;
  final Object personaAdaptiveProxyV2Snapshot;

  Map<String, String> asReadOnlyMap() => {
    'lift': '<opaque>',
    'surface': '<opaque>',
    'qa_v5': '<opaque>',
    'builder_v2': '<opaque>',
    'blend_v2': '<opaque>',
    'proxy_v2': '<opaque>',
  };
}

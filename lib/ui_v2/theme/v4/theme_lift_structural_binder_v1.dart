class ThemeLiftStructuralBinderV1 {
  const ThemeLiftStructuralBinderV1({
    required this.themeLiftSkeletonV1Snapshot,
    required this.personaAdaptiveThemeBuilderV2Snapshot,
    required this.personaAdaptiveBlendV2Snapshot,
    required this.personaAdaptiveProxyV2Snapshot,
    required this.visualCohesionQASweepV5Snapshot,
  });

  final Object themeLiftSkeletonV1Snapshot;
  final Object personaAdaptiveThemeBuilderV2Snapshot;
  final Object personaAdaptiveBlendV2Snapshot;
  final Object personaAdaptiveProxyV2Snapshot;
  final Object visualCohesionQASweepV5Snapshot;

  Map<String, String> asReadOnlyMap() => {
    'binder': '<opaque>',
    'skeleton': '<opaque>',
    'builder_v2': '<opaque>',
    'blend_v2': '<opaque>',
    'proxy_v2': '<opaque>',
    'qa_v5': '<opaque>',
  };
}

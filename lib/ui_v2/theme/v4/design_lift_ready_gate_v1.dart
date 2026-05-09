class DesignLiftReadyGateV1 {
  const DesignLiftReadyGateV1({
    required this.personaAdaptiveThemeLiftSkeletonSnapshot,
    required this.themeLiftStructuralBinderSnapshot,
    required this.v4TokenLiftSkeletonSnapshot,
    required this.personaAdaptiveTokenMappingSnapshot,
    required this.visualMergeLayerSnapshot,
    required this.adaptiveRenderingPreviewSnapshot,
    required this.visualCohesionQASweepV5Snapshot,
    required this.finalCohesionSurfaceSnapshot,
  });

  final Object personaAdaptiveThemeLiftSkeletonSnapshot;
  final Object themeLiftStructuralBinderSnapshot;
  final Object v4TokenLiftSkeletonSnapshot;
  final Object personaAdaptiveTokenMappingSnapshot;
  final Object visualMergeLayerSnapshot;
  final Object adaptiveRenderingPreviewSnapshot;
  final Object visualCohesionQASweepV5Snapshot;
  final Object finalCohesionSurfaceSnapshot;

  Map<String, String> asReadOnlyMap() => {
    'ready_gate': '<opaque>',
    'skeleton': '<opaque>',
    'binder': '<opaque>',
    'token_lift': '<opaque>',
    'token_mapping': '<opaque>',
    'merge': '<opaque>',
    'preview': '<opaque>',
    'qa_v5': '<opaque>',
    'surface': '<opaque>',
  };
}

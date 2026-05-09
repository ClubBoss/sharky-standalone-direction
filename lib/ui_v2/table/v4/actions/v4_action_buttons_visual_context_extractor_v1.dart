class V4ActionButtonsVisualContextExtractorV1 {
  const V4ActionButtonsVisualContextExtractorV1({
    required this.structureMapSnapshot,
    required this.skeletonSnapshot,
    required this.layoutSkeletonSnapshot,
    required this.visualTokenBundle,
  });

  final Object structureMapSnapshot;
  final Object skeletonSnapshot;
  final Object layoutSkeletonSnapshot;
  final Object visualTokenBundle;

  Map<String, String> asReadOnlyMap() => {
    'context_ok': 'true',
    'context': structureMapSnapshot.toString(),
    'layout': layoutSkeletonSnapshot.toString(),
    'visual': skeletonSnapshot.toString(),
    'bundle': visualTokenBundle.toString(),
  };
}

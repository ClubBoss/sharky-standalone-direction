class V4ActionButtonsVisualStructureMapV1 {
  const V4ActionButtonsVisualStructureMapV1({
    required this.layoutSkeletonSnapshot,
    required this.visualSkeletonSnapshot,
    required this.visualTokenBundle,
  });

  final Object layoutSkeletonSnapshot;
  final Object visualSkeletonSnapshot;
  final Object visualTokenBundle;

  Map<String, String> asReadOnlyMap() => {
    'structure_map_ok': 'true',
    'layout': layoutSkeletonSnapshot.toString(),
    'visual': visualSkeletonSnapshot.toString(),
    'bundle': visualTokenBundle.toString(),
  };
}

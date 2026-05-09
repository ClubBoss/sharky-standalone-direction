class V4ActionButtonsVisualBindingV1 {
  const V4ActionButtonsVisualBindingV1({
    required this.contextSnapshot,
    required this.structureMapSnapshot,
    required this.skeletonSnapshot,
    required this.visualTokenBundle,
  });

  final Object contextSnapshot;
  final Object structureMapSnapshot;
  final Object skeletonSnapshot;
  final Object visualTokenBundle;

  Map<String, String> asReadOnlyMap() => {
    'binding_ok': 'true',
    'binding': contextSnapshot.toString(),
    'layout': structureMapSnapshot.toString(),
    'visual': skeletonSnapshot.toString(),
    'bundle': visualTokenBundle.toString(),
  };
}

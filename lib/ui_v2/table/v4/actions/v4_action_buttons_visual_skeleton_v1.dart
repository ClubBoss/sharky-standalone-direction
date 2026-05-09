class V4ActionButtonsVisualSkeletonV1 {
  const V4ActionButtonsVisualSkeletonV1({
    required this.actionButtonsLayoutSkeleton,
    required this.visualTokenBundle,
    required this.visualTokenAccessor,
  });

  final Object actionButtonsLayoutSkeleton;
  final Object visualTokenBundle;
  final Object visualTokenAccessor;

  Map<String, String> asReadOnlyMap() => {
    'layout': actionButtonsLayoutSkeleton.toString(),
    'bundle': visualTokenBundle.toString(),
    'accessor': visualTokenAccessor.toString(),
  };
}

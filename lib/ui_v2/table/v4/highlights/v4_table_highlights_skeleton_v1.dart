class V4TableHighlightsSkeletonV1 {
  const V4TableHighlightsSkeletonV1({
    required this.tableInteractionSkeleton,
    required this.tableVisualBridge,
    required this.visualTokenBundle,
  });

  final Object tableInteractionSkeleton;
  final Object tableVisualBridge;
  final Object visualTokenBundle;

  Map<String, String> asReadOnlyMap() => {
    'interaction': tableInteractionSkeleton.toString(),
    'bridge': tableVisualBridge.toString(),
    'bundle': visualTokenBundle.toString(),
  };
}

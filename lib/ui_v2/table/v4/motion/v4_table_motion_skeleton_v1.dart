class V4TableMotionSkeletonV1 {
  const V4TableMotionSkeletonV1({
    required this.tableActionZonesSkeleton,
    required this.tableHighlightsSkeleton,
    required this.visualTokenBundle,
  });

  final Object tableActionZonesSkeleton;
  final Object tableHighlightsSkeleton;
  final Object visualTokenBundle;

  Map<String, String> asReadOnlyMap() => {
    'actions': tableActionZonesSkeleton.toString(),
    'highlights': tableHighlightsSkeleton.toString(),
    'bundle': visualTokenBundle.toString(),
  };
}

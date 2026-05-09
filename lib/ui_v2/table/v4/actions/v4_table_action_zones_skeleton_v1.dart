class V4TableActionZonesSkeletonV1 {
  const V4TableActionZonesSkeletonV1({
    required this.tableInteractionSkeleton,
    required this.tableHighlightsSkeleton,
    required this.visualTokenAccessor,
  });

  final Object tableInteractionSkeleton;
  final Object tableHighlightsSkeleton;
  final Object visualTokenAccessor;

  Map<String, String> asReadOnlyMap() => {
    'interaction': tableInteractionSkeleton.toString(),
    'highlights': tableHighlightsSkeleton.toString(),
    'accessor': visualTokenAccessor.toString(),
  };
}

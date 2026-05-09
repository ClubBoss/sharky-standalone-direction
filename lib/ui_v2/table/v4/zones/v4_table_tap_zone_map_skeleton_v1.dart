class V4TableTapZoneMapSkeletonV1 {
  const V4TableTapZoneMapSkeletonV1({
    required this.tableInteractionSkeleton,
    required this.tableActionZonesSkeleton,
    required this.tableMotionSkeleton,
  });

  final Object tableInteractionSkeleton;
  final Object tableActionZonesSkeleton;
  final Object tableMotionSkeleton;

  Map<String, String> asReadOnlyMap() => {
    'interaction': tableInteractionSkeleton.toString(),
    'actions': tableActionZonesSkeleton.toString(),
    'motion': tableMotionSkeleton.toString(),
  };
}

class V4TableActionScaffoldSkeletonV1 {
  const V4TableActionScaffoldSkeletonV1({
    required this.tableTapZoneMapSkeleton,
    required this.tableMotionSkeleton,
    required this.visualTokenAccessor,
  });

  final Object tableTapZoneMapSkeleton;
  final Object tableMotionSkeleton;
  final Object visualTokenAccessor;

  Map<String, String> asReadOnlyMap() => {
    'zones': tableTapZoneMapSkeleton.toString(),
    'motion': tableMotionSkeleton.toString(),
    'accessor': visualTokenAccessor.toString(),
  };
}

class V4ActionButtonsGeometrySkeletonV1 {
  const V4ActionButtonsGeometrySkeletonV1({
    required this.tableActionScaffoldSkeleton,
    required this.visualTokenBundle,
    required this.visualTokenAccessor,
  });

  final Object tableActionScaffoldSkeleton;
  final Object visualTokenBundle;
  final Object visualTokenAccessor;

  Map<String, String> asReadOnlyMap() => {
    'scaffold': tableActionScaffoldSkeleton.toString(),
    'bundle': visualTokenBundle.toString(),
    'accessor': visualTokenAccessor.toString(),
  };
}

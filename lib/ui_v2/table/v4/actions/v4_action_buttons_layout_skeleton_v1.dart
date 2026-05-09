class V4ActionButtonsLayoutSkeletonV1 {
  const V4ActionButtonsLayoutSkeletonV1({
    required this.actionButtonsGeometrySkeleton,
    required this.tableActionScaffoldSkeleton,
    required this.visualTokenBundle,
  });

  final Object actionButtonsGeometrySkeleton;
  final Object tableActionScaffoldSkeleton;
  final Object visualTokenBundle;

  Map<String, String> asReadOnlyMap() => {
    'geometry': actionButtonsGeometrySkeleton.toString(),
    'scaffold': tableActionScaffoldSkeleton.toString(),
    'bundle': visualTokenBundle.toString(),
  };
}

class V4TableBoardAggregatorV1 {
  const V4TableBoardAggregatorV1({
    required this.tableRendererSkeleton,
    required this.cardGridLayout,
    required this.chipsPotModel,
    required this.visualTokenAccessor,
  });

  final Object tableRendererSkeleton;
  final Object cardGridLayout;
  final Object chipsPotModel;
  final Object visualTokenAccessor;

  Map<String, String> asReadOnlyMap() => {
    'renderer': tableRendererSkeleton.toString(),
    'grid': cardGridLayout.toString(),
    'chips_pot': chipsPotModel.toString(),
    'accessor': visualTokenAccessor.toString(),
  };
}

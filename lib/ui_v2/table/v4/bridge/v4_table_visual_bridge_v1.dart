class V4TableVisualBridgeV1 {
  const V4TableVisualBridgeV1({
    required this.tableBoardAggregator,
    required this.visualTokenAccessor,
    required this.visualTokenBundle,
    required this.visualTokenExportSurface,
  });

  final Object tableBoardAggregator;
  final Object visualTokenAccessor;
  final Object visualTokenBundle;
  final Object visualTokenExportSurface;

  Map<String, String> asReadOnlyMap() => {
    'board': tableBoardAggregator.toString(),
    'accessor': visualTokenAccessor.toString(),
    'bundle': visualTokenBundle.toString(),
    'export': visualTokenExportSurface.toString(),
  };
}

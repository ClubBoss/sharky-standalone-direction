class V4AdaptivePersonaSurfaceV1 {
  const V4AdaptivePersonaSurfaceV1({
    required this.facade,
    required this.uiProvider,
    required this.readModel,
  });

  final Object facade;
  final Object uiProvider;
  final Object readModel;

  Map<String, Object> asReadOnlyMap() => Map<String, Object>.unmodifiable({
    'facade': facade.toString(),
    'provider': uiProvider.toString(),
    'read_model': readModel.toString(),
  });
}

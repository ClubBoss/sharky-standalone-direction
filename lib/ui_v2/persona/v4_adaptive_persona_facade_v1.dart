class V4AdaptivePersonaFacadeV1 {
  const V4AdaptivePersonaFacadeV1({
    required this.uiProvider,
    required this.readModel,
    required this.adaptationGateway,
  });

  final Object uiProvider;
  final Object readModel;
  final Object adaptationGateway;

  Map<String, Object> asReadOnlyMap() => Map<String, Object>.unmodifiable({
    'provider': uiProvider.toString(),
    'read_model': readModel.toString(),
    'gateway': adaptationGateway.toString(),
  });
}

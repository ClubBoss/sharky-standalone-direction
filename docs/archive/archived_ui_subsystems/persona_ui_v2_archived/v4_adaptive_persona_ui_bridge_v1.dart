class V4AdaptivePersonaUIBridgeV1 {
  const V4AdaptivePersonaUIBridgeV1({
    required this.uiAdapter,
    required this.uiProvider,
    required this.facade,
  });

  final Object uiAdapter;
  final Object uiProvider;
  final Object facade;

  Map<String, Object> asReadOnlyMap() => Map<String, Object>.unmodifiable({
    'adapter': uiAdapter.toString(),
    'provider': uiProvider.toString(),
    'facade': facade.toString(),
  });
}

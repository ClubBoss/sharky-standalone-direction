class V4AdaptivePersonaUIMediatorV1 {
  const V4AdaptivePersonaUIMediatorV1({
    required this.uiBridge,
    required this.uiAdapter,
    required this.uiProvider,
  });

  final Object uiBridge;
  final Object uiAdapter;
  final Object uiProvider;

  Map<String, Object> asReadOnlyMap() => Map<String, Object>.unmodifiable({
    'bridge': uiBridge.toString(),
    'adapter': uiAdapter.toString(),
    'provider': uiProvider.toString(),
  });
}

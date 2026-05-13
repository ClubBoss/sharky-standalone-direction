class V4AdaptivePersonaUIAdapterV1 {
  const V4AdaptivePersonaUIAdapterV1({
    required this.uiHook,
    required this.uiProvider,
    required this.readModel,
  });

  final Object uiHook;
  final Object uiProvider;
  final Object readModel;

  Map<String, Object> asReadOnlyMap() => Map<String, Object>.unmodifiable({
    'hook': uiHook.toString(),
    'provider': uiProvider.toString(),
    'read_model': readModel.toString(),
  });
}

class V4AdaptivePersonaUIHookV1 {
  const V4AdaptivePersonaUIHookV1({
    required this.entryPoint,
    required this.shellBinding,
    required this.uiProvider,
  });

  final Object entryPoint;
  final Object shellBinding;
  final Object uiProvider;

  Map<String, Object> asReadOnlyMap() => Map<String, Object>.unmodifiable({
    'entry': entryPoint.toString(),
    'shell': shellBinding.toString(),
    'provider': uiProvider.toString(),
  });
}

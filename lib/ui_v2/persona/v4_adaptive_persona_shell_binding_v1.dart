class V4AdaptivePersonaShellBindingV1 {
  const V4AdaptivePersonaShellBindingV1({
    required this.surface,
    required this.facade,
    required this.uiProvider,
  });

  final Object surface;
  final Object facade;
  final Object uiProvider;

  Map<String, Object> asReadOnlyMap() => Map<String, Object>.unmodifiable({
    'surface': surface.toString(),
    'facade': facade.toString(),
    'provider': uiProvider.toString(),
  });
}

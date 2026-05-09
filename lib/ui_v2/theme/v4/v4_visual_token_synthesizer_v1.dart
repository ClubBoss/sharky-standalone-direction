class V4VisualTokenSynthesizerV1 {
  const V4VisualTokenSynthesizerV1({
    required this.personaContext,
    required this.visualBinder,
    required this.themeBlendingProxy,
  });

  final Object personaContext;
  final Object visualBinder;
  final Object themeBlendingProxy;

  Map<String, String> asReadOnlyMap() => {
    'persona_ctx': personaContext.toString(),
    'binder': visualBinder.toString(),
    'theme_proxy': themeBlendingProxy.toString(),
  };
}

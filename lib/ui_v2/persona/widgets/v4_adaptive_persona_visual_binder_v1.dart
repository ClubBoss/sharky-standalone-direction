class V4AdaptivePersonaVisualBinderV1 {
  const V4AdaptivePersonaVisualBinderV1({
    required this.visualSurface,
    required this.visualAdapter,
    required this.personaContext,
  });

  final Object visualSurface;
  final Object visualAdapter;
  final Object personaContext;

  Map<String, String> asReadOnlyMap() => {
    'surface': visualSurface.toString(),
    'adapter': visualAdapter.toString(),
    'persona_ctx': personaContext.toString(),
  };
}

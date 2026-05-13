class V4AdaptivePersonaVisualSurfaceV1 {
  const V4AdaptivePersonaVisualSurfaceV1({
    required this.visualAdapter,
    required this.visualBridge,
    required this.personaContext,
  });

  final Object visualAdapter;
  final Object visualBridge;
  final Object personaContext;

  Map<String, Object> asReadOnlyMap() => Map<String, Object>.unmodifiable({
    'adapter': visualAdapter.toString(),
    'bridge': visualBridge.toString(),
    'persona_ctx': personaContext.toString(),
  });
}

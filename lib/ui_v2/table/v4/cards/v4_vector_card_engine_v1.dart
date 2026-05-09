class V4VectorCardEngineV1 {
  const V4VectorCardEngineV1({
    required this.visualTokenAccessor,
    required this.personaContext,
  });

  final Object visualTokenAccessor;
  final Object personaContext;

  Map<String, String> asReadOnlyMap() => {
    'accessor': visualTokenAccessor.toString(),
    'persona_ctx': personaContext.toString(),
  };
}

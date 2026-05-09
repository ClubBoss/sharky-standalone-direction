class V4PersonaUIReadModelV1 {
  const V4PersonaUIReadModelV1({
    required this.adaptationGateway,
    required this.personaContext,
    required this.themeContext,
  });

  final Object adaptationGateway;
  final Object personaContext;
  final Object themeContext;

  Map<String, Object> asReadOnlyMap() => Map<String, Object>.unmodifiable({
    'gateway': adaptationGateway.toString(),
    'persona_ctx': personaContext.toString(),
    'theme_ctx': themeContext.toString(),
  });
}

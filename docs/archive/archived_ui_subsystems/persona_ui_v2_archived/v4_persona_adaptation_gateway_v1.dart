class V4PersonaAdaptationGatewayV1 {
  const V4PersonaAdaptationGatewayV1({
    required this.masterBundle,
    required this.personaContext,
    required this.themeContext,
  });

  final Object masterBundle;
  final Object personaContext;
  final Object themeContext;

  Map<String, Object> asReadOnlyMap() => Map<String, Object>.unmodifiable({
    'master': masterBundle.toString(),
    'persona_ctx': personaContext.toString(),
    'theme_ctx': themeContext.toString(),
  });
}

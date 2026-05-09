class V4PersonaUIProviderV1 {
  const V4PersonaUIProviderV1({
    required this.readModel,
    required this.personaContext,
    required this.themeContext,
  });

  final Object readModel;
  final Object personaContext;
  final Object themeContext;

  Map<String, Object> asReadOnlyMap() => Map<String, Object>.unmodifiable({
    'read_model': readModel.toString(),
    'persona_ctx': personaContext.toString(),
    'theme_ctx': themeContext.toString(),
  });
}

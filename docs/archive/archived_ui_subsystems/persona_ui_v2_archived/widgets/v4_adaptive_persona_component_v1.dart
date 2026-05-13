class V4AdaptivePersonaComponentV1 {
  const V4AdaptivePersonaComponentV1({
    required this.uiMediator,
    required this.uiProvider,
    required this.personaContext,
  });

  final Object uiMediator;
  final Object uiProvider;
  final Object personaContext;

  Map<String, Object> asReadOnlyMap() => Map<String, Object>.unmodifiable({
    'mediator': uiMediator.toString(),
    'provider': uiProvider.toString(),
    'persona_ctx': personaContext.toString(),
  });
}

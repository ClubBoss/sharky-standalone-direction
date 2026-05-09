class V4AdaptivePersonaVisualNodeV1 {
  const V4AdaptivePersonaVisualNodeV1({
    required this.component,
    required this.uiMediator,
    required this.personaContext,
  });

  final Object component;
  final Object uiMediator;
  final Object personaContext;

  Map<String, Object> asReadOnlyMap() => Map<String, Object>.unmodifiable({
    'component': component.toString(),
    'mediator': uiMediator.toString(),
    'persona_ctx': personaContext.toString(),
  });
}

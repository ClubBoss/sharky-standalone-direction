class V4VisualTokenBundleV1 {
  const V4VisualTokenBundleV1({
    required this.visualTokenSynthesizer,
    required this.visualBinder,
    required this.personaContext,
  });

  final Object visualTokenSynthesizer;
  final Object visualBinder;
  final Object personaContext;

  Map<String, String> asReadOnlyMap() => {
    'synth': visualTokenSynthesizer.toString(),
    'binder': visualBinder.toString(),
    'persona_ctx': personaContext.toString(),
  };
}

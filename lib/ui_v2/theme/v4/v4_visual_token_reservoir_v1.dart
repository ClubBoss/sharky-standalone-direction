class V4VisualTokenReservoirV1 {
  const V4VisualTokenReservoirV1({
    required this.visualTokenBundle,
    required this.visualTokenSynthesizer,
    required this.personaContext,
  });

  final Object visualTokenBundle;
  final Object visualTokenSynthesizer;
  final Object personaContext;

  Map<String, String> asReadOnlyMap() => {
    'bundle': visualTokenBundle.toString(),
    'synth': visualTokenSynthesizer.toString(),
    'persona_ctx': personaContext.toString(),
  };
}

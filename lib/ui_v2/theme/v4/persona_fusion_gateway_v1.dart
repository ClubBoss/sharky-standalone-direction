class PersonaFusionGatewayV1 {
  const PersonaFusionGatewayV1(
    this.surface,
    this.synthesis,
    this.injectionGate,
    this.emotionEngine,
    this.personaFusionSurface,
  );

  final Object surface;
  final Object synthesis;
  final Object injectionGate;
  final Object emotionEngine;
  final Object personaFusionSurface;

  Map<String, Object> asReadOnlyMap() {
    return <String, Object>{
      'surface': '<opaque>',
      'synthesis': '<opaque>',
      'injection_gate': '<opaque>',
      'emotion': '<opaque>',
      'fusion_surface': '<opaque>',
    };
  }
}

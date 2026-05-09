class V4CardGeometryDescriptorV1 {
  const V4CardGeometryDescriptorV1({
    required this.vectorCardEngine,
    required this.visualTokenAccessor,
    required this.personaContext,
  });

  final Object vectorCardEngine;
  final Object visualTokenAccessor;
  final Object personaContext;

  Map<String, String> asReadOnlyMap() => {
    'engine': vectorCardEngine.toString(),
    'accessor': visualTokenAccessor.toString(),
    'persona_ctx': personaContext.toString(),
  };
}

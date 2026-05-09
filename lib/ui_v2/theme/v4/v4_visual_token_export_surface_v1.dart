class V4VisualTokenExportSurfaceV1 {
  const V4VisualTokenExportSurfaceV1({
    required this.visualTokenReservoir,
    required this.visualTokenBundle,
    required this.personaContext,
  });

  final Object visualTokenReservoir;
  final Object visualTokenBundle;
  final Object personaContext;

  Map<String, String> asReadOnlyMap() => {
    'reservoir': visualTokenReservoir.toString(),
    'bundle': visualTokenBundle.toString(),
    'persona_ctx': personaContext.toString(),
  };
}

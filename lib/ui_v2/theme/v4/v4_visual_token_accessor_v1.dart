class V4VisualTokenAccessorV1 {
  const V4VisualTokenAccessorV1({
    required this.visualTokenExportSurface,
    required this.visualTokenReservoir,
    required this.personaContext,
  });

  final Object visualTokenExportSurface;
  final Object visualTokenReservoir;
  final Object personaContext;

  Map<String, String> asReadOnlyMap() => {
    'export_surface': visualTokenExportSurface.toString(),
    'reservoir': visualTokenReservoir.toString(),
    'persona_ctx': personaContext.toString(),
  };
}

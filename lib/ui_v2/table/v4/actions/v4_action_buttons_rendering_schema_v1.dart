class V4ActionButtonsRenderingSchemaV1 {
  const V4ActionButtonsRenderingSchemaV1({
    required this.bindingSnapshot,
    required this.contextSnapshot,
    required this.structureMapSnapshot,
    required this.visualTokenBundle,
  });

  final Object bindingSnapshot;
  final Object contextSnapshot;
  final Object structureMapSnapshot;
  final Object visualTokenBundle;

  Map<String, String> asReadOnlyMap() => {
    'schema_ok': 'true',
    'instructions': bindingSnapshot.toString(),
    'layout': structureMapSnapshot.toString(),
    'visual': contextSnapshot.toString(),
    'bundle': visualTokenBundle.toString(),
  };
}

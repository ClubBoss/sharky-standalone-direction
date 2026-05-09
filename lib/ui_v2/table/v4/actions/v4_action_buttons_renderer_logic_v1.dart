class V4ActionButtonsRendererLogicV1 {
  const V4ActionButtonsRendererLogicV1({
    required this.schemaSnapshot,
    required this.bindingSnapshot,
    required this.contextSnapshot,
    required this.structureMapSnapshot,
    required this.visualTokenBundle,
  });

  final Object schemaSnapshot;
  final Object bindingSnapshot;
  final Object contextSnapshot;
  final Object structureMapSnapshot;
  final Object visualTokenBundle;

  Map<String, String> asReadOnlyMap() => {
    'renderer_logic_ok': 'true',
    'render_plan': schemaSnapshot.toString(),
    'layout': structureMapSnapshot.toString(),
    'visual': contextSnapshot.toString(),
    'bundle': visualTokenBundle.toString(),
  };
}

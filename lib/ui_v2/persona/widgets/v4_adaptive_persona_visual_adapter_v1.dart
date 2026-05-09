class V4AdaptivePersonaVisualAdapterV1 {
  const V4AdaptivePersonaVisualAdapterV1({
    required this.visualBridge,
    required this.visualNode,
    required this.uiMediator,
  });

  final Object visualBridge;
  final Object visualNode;
  final Object uiMediator;

  Map<String, Object> asReadOnlyMap() => Map<String, Object>.unmodifiable({
    'bridge': visualBridge.toString(),
    'node': visualNode.toString(),
    'mediator': uiMediator.toString(),
  });
}

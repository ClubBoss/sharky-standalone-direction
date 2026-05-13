class V4AdaptivePersonaVisualBridgeV1 {
  final String visualNode;
  final String uiMediator;
  final String uiProvider;

  const V4AdaptivePersonaVisualBridgeV1({
    required this.visualNode,
    required this.uiMediator,
    required this.uiProvider,
  });

  Map<String, Object> asReadOnlyMap() {
    return <String, Object>{
      'visual_node': visualNode,
      'ui_mediator': uiMediator,
      'ui_provider': uiProvider,
    };
  }
}

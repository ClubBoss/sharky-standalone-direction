/// Passive descriptor for Turn Chain Heuristic v1.
class TurnChainDescriptorV1 {
  const TurnChainDescriptorV1();

  Map<String, Object> asReadOnlyMap() {
    return <String, Object>{
      'id': 'turn:chain:v1',
      'template': 'training_pack_template_v2',
      'components': <String>['theory', 'drills', 'demos', 'allowlist'],
      'status': 'pre-init',
    };
  }
}

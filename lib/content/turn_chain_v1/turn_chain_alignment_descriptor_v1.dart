/// Passive advanced alignment descriptor for Turn Chain v1.
class TurnChainAlignmentDescriptorV1 {
  const TurnChainAlignmentDescriptorV1();

  Map<String, Object> asReadOnlyMap() {
    return <String, Object>{
      'id': 'turn:chain:v1',
      'layer': 'advanced-alignment',
      'template': 'training_pack_template_v2',
      'requires': <String>['ra2_v1', 'exploit_builder_v1', 't2e_v1'],
      'status': 'pre-align',
    };
  }
}

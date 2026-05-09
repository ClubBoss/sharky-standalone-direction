/// Passive advanced alignment descriptor for Range Advantage 2.0 v1.
class RA2AlignmentDescriptorV1 {
  const RA2AlignmentDescriptorV1();

  Map<String, Object> asReadOnlyMap() {
    return <String, Object>{
      'id': 'ra2:v1',
      'layer': 'advanced-alignment',
      'template': 'training_pack_template_v2',
      'requires': <String>['turn_chain_v1', 'exploit_builder_v1', 't2e_v1'],
      'status': 'pre-align',
    };
  }
}

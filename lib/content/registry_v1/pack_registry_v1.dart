/// Passive pack registry v1.
class PackRegistryV1 {
  const PackRegistryV1();

  Map<String, Object> asReadOnlyMap() {
    return <String, Object>{
      'id': 'pack:registry:v1',
      'template': 'training_pack_template_v2',
      'status': 'active',
      'modules': <String>[
        'cash:l3:v1',
        'icm:l4:v1',
        'mtt:l4:v1',
        'turn:chain:v1',
        'exploit:builder:v1',
        't2e:v1',
        'mix:cp:v1',
        'ra2:v1',
        'synthesis:v1',
      ],
    };
  }
}

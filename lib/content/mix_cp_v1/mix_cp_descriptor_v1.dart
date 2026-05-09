/// Passive descriptor for Mixed Checkpoints v1.
class MixCPDescriptorV1 {
  const MixCPDescriptorV1();

  Map<String, Object> asReadOnlyMap() {
    return <String, Object>{
      'id': 'mix:cp:v1',
      'template': 'training_pack_template_v2',
      'components': <String>[
        'theory',
        'demos',
        'drills',
        'checkpoints',
        'allowlist',
      ],
      'status': 'pre-init',
    };
  }
}

/// Passive descriptor for Advanced Synthesis Layer v1.
class SynthesisDescriptorV1 {
  const SynthesisDescriptorV1();

  Map<String, Object> asReadOnlyMap() {
    return <String, Object>{
      'id': 'synthesis:v1',
      'template': 'training_pack_template_v2',
      'requires': <String>[
        'ra2_v1',
        'turn_chain_v1',
        'exploit_builder_v1',
        't2e_v1',
      ],
      'layer': 'advanced-synthesis',
      'status': 'pre-synth',
    };
  }
}

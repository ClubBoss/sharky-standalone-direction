/// Passive binder descriptor for Tap-to-Explain v1.
class T2EBinderDescriptorV1 {
  const T2EBinderDescriptorV1();

  Map<String, Object> asReadOnlyMap() {
    return <String, Object>{
      'id': 't2e:binder:v1',
      'template': 'training_pack_template_v2',
      'status': 'pre-bind',
      'requires': <String>[
        't2e:v1',
        'ra2:v1',
        'turn:chain:v1',
        'exploit:builder:v1',
      ],
    };
  }
}

/// Passive descriptor for Tap-to-Explain v1.
class T2EDescriptorV1 {
  const T2EDescriptorV1();

  Map<String, Object> asReadOnlyMap() {
    return <String, Object>{
      'id': 't2e:v1',
      'template': 'training_pack_template_v2',
      'components': <String>['theory', 'explanations', 'allowlist'],
      'status': 'pre-init',
    };
  }
}

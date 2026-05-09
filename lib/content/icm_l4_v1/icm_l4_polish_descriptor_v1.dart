/// Passive polish descriptor for ICM L4 v1.
class ICML4PolishDescriptorV1 {
  const ICML4PolishDescriptorV1();

  Map<String, Object> asReadOnlyMap() {
    return <String, Object>{
      'id': 'icm:l4:v1',
      'template': 'training_pack_template_v2',
      'components': <String>['theory', 'drills', 'demos', 'allowlist'],
      'status': 'pre-polish',
    };
  }
}

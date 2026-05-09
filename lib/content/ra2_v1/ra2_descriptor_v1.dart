/// Passive descriptor for Range Advantage 2.0 v1.
class RA2DescriptorV1 {
  const RA2DescriptorV1();

  Map<String, Object> asReadOnlyMap() {
    return <String, Object>{
      'id': 'ra2:v1',
      'template': 'training_pack_template_v2',
      'components': <String>['theory', 'drills', 'demos', 'allowlist'],
      'status': 'pre-init',
    };
  }
}

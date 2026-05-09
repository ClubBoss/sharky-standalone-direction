/// Passive deepening descriptor for MTT L4 v1.
class MTTL4DeepeningDescriptorV1 {
  const MTTL4DeepeningDescriptorV1();

  Map<String, Object> asReadOnlyMap() {
    return <String, Object>{
      'id': 'mtt:l4:v1',
      'template': 'training_pack_template_v2',
      'components': <String>['theory', 'drills', 'demos', 'allowlist'],
      'status': 'pre-deepening',
    };
  }
}

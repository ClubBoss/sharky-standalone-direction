/// Passive bootstrap metadata for content system.
class ContentBootstrapV1 {
  const ContentBootstrapV1();

  Map<String, Object> asReadOnlyMap() {
    return <String, Object>{
      'packs_root': 'content/',
      'version': 'v1',
      'supports': <String>['cash_l3', 'icm_l4', 'mttr_l4'],
      'spec': 'training_pack_template_v2',
    };
  }
}

/// Passive descriptor for Rewrite Engine v1.
class RewriteEngineDescriptorV1 {
  const RewriteEngineDescriptorV1();

  Map<String, Object> asReadOnlyMap() {
    return <String, Object>{
      'id': 'rewrite:engine:v1',
      'template': 'training_pack_template_v2',
      'status': 'pre-engine',
    };
  }
}

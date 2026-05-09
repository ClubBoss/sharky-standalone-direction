/// Passive descriptor for Cash L3 theory rewrite draft v3.
class CashL3TheoryRewriteDescriptorV3 {
  const CashL3TheoryRewriteDescriptorV3();

  Map<String, Object> asReadOnlyMap() {
    return <String, Object>{
      'id': 'cash:l3:theory:rewrite:v3',
      'stage': 'rewrite-phase-4',
      'source': 'cash:l3:v1',
      'target': 'cash:l3:v2',
      'template': 'training_pack_template_v2',
      'status': 'draft-generator',
    };
  }
}

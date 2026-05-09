/// Passive descriptor for Cash L3 theory rewrite v2.
class CashL3TheoryRewriteDescriptorV2 {
  const CashL3TheoryRewriteDescriptorV2();

  Map<String, Object> asReadOnlyMap() {
    return <String, Object>{
      'id': 'cash:l3:theory:rewrite:v2',
      'stage': 'rewrite-phase-2',
      'source': 'cash:l3:v1',
      'target': 'cash:l3:v2',
      'template': 'training_pack_template_v2',
      'status': 'structural-only',
    };
  }
}

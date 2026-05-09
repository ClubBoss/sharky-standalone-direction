/// Passive descriptor for Cash L3 theory draft normalization v1.
class CashL3TheoryDraftNormalizeDescriptorV1 {
  const CashL3TheoryDraftNormalizeDescriptorV1();

  Map<String, Object> asReadOnlyMap() {
    return <String, Object>{
      'id': 'cash:l3:theory:draft:normalize:v1',
      'stage': 'rewrite-phase-5',
      'source': 'cash:l3:v1',
      'target': 'cash:l3:v2',
      'template': 'training_pack_template_v2',
      'status': 'normalization-pass',
    };
  }
}

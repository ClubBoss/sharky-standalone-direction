/// Passive descriptor for Cash L3 theory extraction v1.
class CashL3TheoryExtractionDescriptorV1 {
  const CashL3TheoryExtractionDescriptorV1();

  Map<String, Object> asReadOnlyMap() {
    return <String, Object>{
      'id': 'cash:l3:theory:extract:v1',
      'stage': 'rewrite-phase-1',
      'source': 'cash:l3:v1',
      'template': 'training_pack_template_v2',
      'status': 'extract-only',
    };
  }
}

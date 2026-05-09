/// Passive descriptor for Cash L3 theory V2 final assembly.
class CashL3TheoryV2Descriptor {
  const CashL3TheoryV2Descriptor();

  Map<String, Object> asReadOnlyMap() {
    return <String, Object>{
      'id': 'cash:l3:theory:v2',
      'stage': 'rewrite-phase-6',
      'source': 'cash:l3:v1',
      'template': 'training_pack_template_v2',
      'status': 'final-assembly',
    };
  }
}

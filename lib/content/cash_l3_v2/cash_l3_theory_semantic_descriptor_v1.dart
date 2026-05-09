/// Passive descriptor for Cash L3 theory semantic safety v1.
class CashL3TheorySemanticDescriptorV1 {
  const CashL3TheorySemanticDescriptorV1();

  Map<String, Object> asReadOnlyMap() {
    return <String, Object>{
      'id': 'cash:l3:theory:semantic:v1',
      'stage': 'rewrite-phase-3',
      'source': 'cash:l3:v1',
      'target': 'cash:l3:v2',
      'template': 'training_pack_template_v2',
      'status': 'semantic-check',
    };
  }
}

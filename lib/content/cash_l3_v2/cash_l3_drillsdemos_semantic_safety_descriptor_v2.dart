/// Passive descriptor for Cash L3 drills/demos semantic safety v2.
class CashL3DrillsDemosSemanticSafetyDescriptorV2 {
  const CashL3DrillsDemosSemanticSafetyDescriptorV2();

  Map<String, Object> asReadOnlyMap() {
    return <String, Object>{
      'id': 'cash:l3:drillsdemos:semantic-safety:v2',
      'stage': 'rewrite-phase-10',
      'source': 'cash:l3:v1',
      'target': 'cash:l3:v2',
      'template': 'training_pack_template_v2',
      'status': 'semantic-safety',
    };
  }
}

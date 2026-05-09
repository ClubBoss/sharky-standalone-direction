/// Passive descriptor for Cash L3 drills/demos structural rewrite v2.
class CashL3DrillsDemosRewriteStructDescriptorV2 {
  const CashL3DrillsDemosRewriteStructDescriptorV2();

  Map<String, Object> asReadOnlyMap() {
    return <String, Object>{
      'id': 'cash:l3:drillsdemos:rewrite:struct:v2',
      'stage': 'rewrite-phase-9',
      'source': 'cash:l3:v1',
      'target': 'cash:l3:v2',
      'template': 'training_pack_template_v2',
      'status': 'structural',
    };
  }
}

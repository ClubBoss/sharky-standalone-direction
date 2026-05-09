/// Passive descriptor for Cash L3 drills/demos rewrite migration v1.
class CashL3DrillsDemosRewriteMigrationDescriptorV1 {
  const CashL3DrillsDemosRewriteMigrationDescriptorV1();

  Map<String, Object> asReadOnlyMap() {
    return <String, Object>{
      'id': 'cash:l3:drillsdemos:rewrite:migration:v1',
      'stage': 'rewrite-phase-8',
      'source': 'cash:l3:v1',
      'target': 'cash:l3:v2',
      'template': 'training_pack_template_v2',
      'status': 'migration',
    };
  }
}

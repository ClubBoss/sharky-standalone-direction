/// Passive descriptor for Cash L3 theory migration v1.
class CashL3TheoryMigrationDescriptorV1 {
  const CashL3TheoryMigrationDescriptorV1();

  Map<String, Object> asReadOnlyMap() {
    return <String, Object>{
      'id': 'cash:l3:theory:migration:v1',
      'source': 'cash:l3:v1',
      'target': 'cash:l3:v2',
      'template': 'training_pack_template_v2',
      'status': 'pre-migrate',
    };
  }
}

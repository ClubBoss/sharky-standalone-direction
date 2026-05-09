/// Counter - Phi-57.0
///
/// Passive sync layer for Table UI V4 activation.
class TableUIActivationSyncV1 {
  const TableUIActivationSyncV1(this.activationFrame, this.themeV4Controller);

  final Object activationFrame;
  final Object themeV4Controller;

  Map<String, Object> asReadOnlyMap() {
    final bool v4Ready = (themeV4Controller as dynamic)?.isActive == true;
    return <String, Object>{
      'activation_frame': activationFrame,
      'v4_ready': v4Ready,
      'v4_state': themeV4Controller,
    };
  }
}

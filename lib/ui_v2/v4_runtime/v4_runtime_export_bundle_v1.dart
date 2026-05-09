/// Counter - Phi-60.0
///
/// Passive bundle for V4 runtime export.
class V4RuntimeExportBundleV1 {
  const V4RuntimeExportBundleV1(
    this.activationFrame,
    this.activationSyncMap,
    this.materializationMap,
    this.toggleQAState,
  );

  final Object activationFrame;
  final Object activationSyncMap;
  final Object materializationMap;
  final Object toggleQAState;

  Map<String, Object> asReadOnlyMap() {
    return <String, Object>{
      'activation_frame': activationFrame,
      'sync': activationSyncMap,
      'materialization': materializationMap,
      'qa': toggleQAState,
    };
  }
}

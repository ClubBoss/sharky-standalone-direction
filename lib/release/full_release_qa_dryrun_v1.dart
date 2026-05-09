class FullReleaseQADryRunV1 {
  const FullReleaseQADryRunV1(
    this.finalReleaseQASweepV1Map,
    this.releaseNotesValidationV1Map,
    this.rcFreezeMarkerValidationV1Map,
    this.rcPackagingValidationV1Map,
    this.preRCSweepEnhancerV1Map,
    this.releaseNotesGeneratorV1Map,
    this.finalStabilityGuardV1Map,
    this.finalRenderQABridgeV1Map,
  );

  final Object finalReleaseQASweepV1Map;
  final Object releaseNotesValidationV1Map;
  final Object rcFreezeMarkerValidationV1Map;
  final Object rcPackagingValidationV1Map;
  final Object preRCSweepEnhancerV1Map;
  final Object releaseNotesGeneratorV1Map;
  final Object finalStabilityGuardV1Map;
  final Object finalRenderQABridgeV1Map;

  Map<String, Object> asReadOnlyMap() {
    Map<String, Object> m(Object v) => v is Map && v.isNotEmpty
        ? v.cast<String, Object>()
        : <String, Object>{};
    bool ready(Object v) => v is Map && v['readiness'] == true;
    final Map<String, Object> domains = <String, Object>{
      'qa_sweep': m(finalReleaseQASweepV1Map),
      'notes_validation': m(releaseNotesValidationV1Map),
      'freeze_validation': m(rcFreezeMarkerValidationV1Map),
      'packaging_validation': m(rcPackagingValidationV1Map),
      'pre_rc_enhanced': m(preRCSweepEnhancerV1Map),
      'notes': m(releaseNotesGeneratorV1Map),
      'render_qa': m(finalRenderQABridgeV1Map),
      'stability_guard': m(finalStabilityGuardV1Map),
    };
    final List<String> missing = domains.entries
        .where((entry) {
          final value = entry.value;
          final bool empty = value is Map && value.isEmpty;
          return empty || !ready(value);
        })
        .map((entry) => entry.key)
        .toList();
    final bool dryrunReady = missing.isEmpty;
    return <String, Object>{
      'full_release_qa_dryrun_v1': <String, Object>{
        'domains': domains,
        'missing': missing,
        'dryrun_ready': dryrunReady,
      },
      'readiness': dryrunReady,
    };
  }
}

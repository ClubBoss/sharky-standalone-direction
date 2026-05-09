class RCValidationGateV1 {
  const RCValidationGateV1(
    this.finalReleaseCandidateAssemblyV1Map,
    this.fullReleaseQADryRunV1Map,
    this.releaseNotesValidationV1Map,
    this.rcFreezeMarkerValidationV1Map,
    this.rcPackagingValidationV1Map,
    this.preRCSweepEnhancerV1Map,
    this.finalReleaseQASweepV1Map,
    this.finalStabilityGuardV1Map,
    this.finalRenderQABridgeV1Map,
  );

  final Object finalReleaseCandidateAssemblyV1Map;
  final Object fullReleaseQADryRunV1Map;
  final Object releaseNotesValidationV1Map;
  final Object rcFreezeMarkerValidationV1Map;
  final Object rcPackagingValidationV1Map;
  final Object preRCSweepEnhancerV1Map;
  final Object finalReleaseQASweepV1Map;
  final Object finalStabilityGuardV1Map;
  final Object finalRenderQABridgeV1Map;

  Map<String, Object> asReadOnlyMap() {
    Map<String, Object> m(Object v) => v is Map && v.isNotEmpty
        ? v.cast<String, Object>()
        : <String, Object>{};
    bool ready(Object v) => v is Map && v['readiness'] == true;
    final Map<String, Object> domains = <String, Object>{
      'assembly': m(finalReleaseCandidateAssemblyV1Map),
      'dryrun': m(fullReleaseQADryRunV1Map),
      'freeze_validation': m(rcFreezeMarkerValidationV1Map),
      'notes_validation': m(releaseNotesValidationV1Map),
      'packaging_validation': m(rcPackagingValidationV1Map),
      'pre_rc_enhanced': m(preRCSweepEnhancerV1Map),
      'qa_sweep': m(finalReleaseQASweepV1Map),
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
    final bool rcReady = missing.isEmpty;
    return <String, Object>{
      'rc_validation_gate_v1': <String, Object>{
        'domains': domains,
        'missing': missing,
        'rc_ready': rcReady,
      },
      'readiness': rcReady,
    };
  }
}

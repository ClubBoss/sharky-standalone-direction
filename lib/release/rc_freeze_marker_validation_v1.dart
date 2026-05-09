class RCFreezeMarkerValidationV1 {
  const RCFreezeMarkerValidationV1(
    this.rcFreezeMarkerV1Map,
    this.rcPackagingValidationV1Map,
    this.rcPackagingIntegrationV1Map,
    this.preRCSweepEnhancerV1Map,
    this.finalReleaseQASweepV1Map,
  );

  final Object rcFreezeMarkerV1Map;
  final Object rcPackagingValidationV1Map;
  final Object rcPackagingIntegrationV1Map;
  final Object preRCSweepEnhancerV1Map;
  final Object finalReleaseQASweepV1Map;

  Map<String, Object> asReadOnlyMap() {
    Map<String, Object> m(Object v) => v is Map && v.isNotEmpty
        ? v.cast<String, Object>()
        : <String, Object>{};
    bool ready(Object v) => v is Map && v['readiness'] == true;
    final Map<String, Object> domains = <String, Object>{
      'freeze_marker': m(rcFreezeMarkerV1Map),
      'packaging_integration': m(rcPackagingIntegrationV1Map),
      'packaging_validation': m(rcPackagingValidationV1Map),
      'pre_rc_enhanced': m(preRCSweepEnhancerV1Map),
      'qa_sweep': m(finalReleaseQASweepV1Map),
    };
    final List<String> missing = domains.entries
        .where((entry) {
          final value = entry.value;
          final bool empty = value is Map && value.isEmpty;
          return empty || !ready(value);
        })
        .map((entry) => entry.key)
        .toList();
    final bool freezeReady = missing.isEmpty;
    return <String, Object>{
      'rc_freeze_marker_validation_v1': <String, Object>{
        'domains': domains,
        'missing': missing,
        'freeze_ready': freezeReady,
      },
      'readiness': freezeReady,
    };
  }
}

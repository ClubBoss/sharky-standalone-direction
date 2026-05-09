class PreRCSweepEnhancerV1 {
  const PreRCSweepEnhancerV1(
    this.finalReleaseQASweepV1Map,
    this.preRCSweepHookV1Map,
    this.rcPackagingIntegrationV1Map,
    this.rcFreezeMarkerV1Map,
    this.releaseNotesGeneratorV1Map,
  );

  final Object finalReleaseQASweepV1Map;
  final Object preRCSweepHookV1Map;
  final Object rcPackagingIntegrationV1Map;
  final Object rcFreezeMarkerV1Map;
  final Object releaseNotesGeneratorV1Map;

  Map<String, Object> asReadOnlyMap() {
    Map<String, Object> m(Object v) => v is Map && v.isNotEmpty
        ? v.cast<String, Object>()
        : <String, Object>{};
    bool ready(Object v) => v is Map && v['readiness'] == true;
    final Map<String, Object> domains = <String, Object>{
      'freeze_marker': m(rcFreezeMarkerV1Map),
      'notes': m(releaseNotesGeneratorV1Map),
      'packaging': m(rcPackagingIntegrationV1Map),
      'pre_rc_hook': m(preRCSweepHookV1Map),
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
    final bool enhancedReady = missing.isEmpty;
    return <String, Object>{
      'pre_rc_sweep_enhancer_v1': <String, Object>{
        'domains': domains,
        'missing': missing,
        'enhanced_ready': enhancedReady,
      },
      'readiness': enhancedReady,
    };
  }
}

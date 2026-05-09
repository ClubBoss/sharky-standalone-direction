class RCPackagingValidationV1 {
  const RCPackagingValidationV1(
    this.rcPackagingIntegrationV1Map,
    this.preRCSweepEnhancerV1Map,
    this.finalReleaseQASweepV1Map,
    this.releaseNotesGeneratorV1Map,
    this.v4ToV3FallbackValidatorV1Map,
  );

  final Object rcPackagingIntegrationV1Map;
  final Object preRCSweepEnhancerV1Map;
  final Object finalReleaseQASweepV1Map;
  final Object releaseNotesGeneratorV1Map;
  final Object v4ToV3FallbackValidatorV1Map;

  Map<String, Object> asReadOnlyMap() {
    Map<String, Object> m(Object v) => v is Map && v.isNotEmpty
        ? v.cast<String, Object>()
        : <String, Object>{};
    bool ready(Object v) => v is Map && v['readiness'] == true;
    final Map<String, Object> domains = <String, Object>{
      'fallback': m(v4ToV3FallbackValidatorV1Map),
      'packaging': m(rcPackagingIntegrationV1Map),
      'pre_rc_enhanced': m(preRCSweepEnhancerV1Map),
      'qa_sweep': m(finalReleaseQASweepV1Map),
      'release_notes': m(releaseNotesGeneratorV1Map),
    };
    final List<String> missing = domains.entries
        .where((entry) {
          final value = entry.value;
          final bool empty = value is Map && value.isEmpty;
          return empty || !ready(value);
        })
        .map((entry) => entry.key)
        .toList();
    final bool packagingValid = missing.isEmpty;
    return <String, Object>{
      'rc_packaging_validation_v1': <String, Object>{
        'domains': domains,
        'missing': missing,
        'packaging_valid': packagingValid,
      },
      'readiness': packagingValid,
    };
  }
}

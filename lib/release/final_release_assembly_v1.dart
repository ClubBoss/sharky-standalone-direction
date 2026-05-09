class FinalReleaseAssemblyV1 {
  const FinalReleaseAssemblyV1(
    this.releaseNotesGeneratorV1Map,
    this.rcFreezeMarkerV1Map,
    this.rcPackagingIntegrationV1Map,
    this.preRCSweepHookV1Map,
    this.v4ToV3FallbackValidatorV1Map,
    this.personaThemeAlignmentV1Map,
    this.crossDomainFlagZeroingV1Map,
    this.consolidatedScoringLockInV1Map,
    this.stabilityConsistencyPassV3Map,
    this.coldPathValidatorV2Map,
    this.qaFinalIntegrationSurfaceV1Map,
  );

  final Object releaseNotesGeneratorV1Map;
  final Object rcFreezeMarkerV1Map;
  final Object rcPackagingIntegrationV1Map;
  final Object preRCSweepHookV1Map;
  final Object v4ToV3FallbackValidatorV1Map;
  final Object personaThemeAlignmentV1Map;
  final Object crossDomainFlagZeroingV1Map;
  final Object consolidatedScoringLockInV1Map;
  final Object stabilityConsistencyPassV3Map;
  final Object coldPathValidatorV2Map;
  final Object qaFinalIntegrationSurfaceV1Map;

  Map<String, Object> asReadOnlyMap() {
    Map<String, Object> m(Object v) => v is Map && v.isNotEmpty
        ? v.cast<String, Object>()
        : <String, Object>{};
    bool ready(Object v) => v is Map && v['readiness'] == true;
    final Map<String, Object> domains = <String, Object>{
      'release_notes': m(releaseNotesGeneratorV1Map),
      'rc_freeze': m(rcFreezeMarkerV1Map),
      'packaging': m(rcPackagingIntegrationV1Map),
      'sweep': m(preRCSweepHookV1Map),
      'fallback': m(v4ToV3FallbackValidatorV1Map),
      'alignment': m(personaThemeAlignmentV1Map),
      'zeroing': m(crossDomainFlagZeroingV1Map),
      'scoring_lockin': m(consolidatedScoringLockInV1Map),
      'stability': m(stabilityConsistencyPassV3Map),
      'cold_path': m(coldPathValidatorV2Map),
      'qa_integration': m(qaFinalIntegrationSurfaceV1Map),
    };
    final List<String> missing = domains.entries
        .where((entry) {
          final value = entry.value;
          final bool empty = value is Map && value.isEmpty;
          return empty || !ready(value);
        })
        .map((entry) => entry.key)
        .toList();
    final bool assemblyReady = missing.isEmpty;
    return <String, Object>{
      'final_release_assembly_v1': <String, Object>{
        'domains': domains,
        'missing': missing,
        'assembly_ready': assemblyReady,
      },
      'readiness': assemblyReady,
    };
  }
}

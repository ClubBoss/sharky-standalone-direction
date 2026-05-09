class FinalReleaseQASweepV1 {
  const FinalReleaseQASweepV1(
    this.finalStabilityGuardV1Map,
    this.finalRenderQABridgeV1Map,
    this.releaseAssemblyV1Map,
    this.v4ToV3FallbackValidatorV1Map,
    this.releaseNotesGeneratorV1Map,
    this.coldPathValidatorV2Map,
    this.systemQACrownV1Map,
    this.personaThemeAlignmentV1Map,
  );

  final Object finalStabilityGuardV1Map;
  final Object finalRenderQABridgeV1Map;
  final Object releaseAssemblyV1Map;
  final Object v4ToV3FallbackValidatorV1Map;
  final Object releaseNotesGeneratorV1Map;
  final Object coldPathValidatorV2Map;
  final Object systemQACrownV1Map;
  final Object personaThemeAlignmentV1Map;

  Map<String, Object> asReadOnlyMap() {
    Map<String, Object> m(Object v) => v is Map && v.isNotEmpty
        ? v.cast<String, Object>()
        : <String, Object>{};
    bool ready(Object v) => v is Map && v['readiness'] == true;
    final Map<String, Object> domains = <String, Object>{
      'assembly': m(releaseAssemblyV1Map),
      'cold_path': m(coldPathValidatorV2Map),
      'fallback': m(v4ToV3FallbackValidatorV1Map),
      'notes': m(releaseNotesGeneratorV1Map),
      'persona_theme': m(personaThemeAlignmentV1Map),
      'render_qa': m(finalRenderQABridgeV1Map),
      'stability_guard': m(finalStabilityGuardV1Map),
      'system_crown': m(systemQACrownV1Map),
    };
    final List<String> missing = domains.entries
        .where((entry) {
          final value = entry.value;
          final bool empty = value is Map && value.isEmpty;
          return empty || !ready(value);
        })
        .map((entry) => entry.key)
        .toList();
    final bool sweepReady = missing.isEmpty;
    return <String, Object>{
      'final_release_qa_sweep_v1': <String, Object>{
        'domains': domains,
        'missing': missing,
        'sweep_ready': sweepReady,
      },
      'readiness': sweepReady,
    };
  }
}

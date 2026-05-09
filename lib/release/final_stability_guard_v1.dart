class FinalStabilityGuardV1 {
  const FinalStabilityGuardV1(
    this.stabilityConsistencyPassV3Map,
    this.finalRenderQABridgeV1Map,
    this.tableV4VisualClosureSealV1Map,
    this.coldPathValidatorV2Map,
    this.personaThemeAlignmentV1Map,
    this.v4ToV3FallbackValidatorV1Map,
    this.systemQACrownV1Map,
  );

  final Object stabilityConsistencyPassV3Map;
  final Object finalRenderQABridgeV1Map;
  final Object tableV4VisualClosureSealV1Map;
  final Object coldPathValidatorV2Map;
  final Object personaThemeAlignmentV1Map;
  final Object v4ToV3FallbackValidatorV1Map;
  final Object systemQACrownV1Map;

  Map<String, Object> asReadOnlyMap() {
    Map<String, Object> m(Object v) => v is Map && v.isNotEmpty
        ? v.cast<String, Object>()
        : <String, Object>{};
    bool ready(Object v) => v is Map && v['readiness'] == true;
    final Map<String, Object> stability = m(stabilityConsistencyPassV3Map);
    final Map<String, Object> renderQA = m(finalRenderQABridgeV1Map);
    final Map<String, Object> visualClosure = m(tableV4VisualClosureSealV1Map);
    final Map<String, Object> coldPath = m(coldPathValidatorV2Map);
    final Map<String, Object> personaTheme = m(personaThemeAlignmentV1Map);
    final Map<String, Object> fallback = m(v4ToV3FallbackValidatorV1Map);
    final Map<String, Object> systemCrown = m(systemQACrownV1Map);
    final Map<String, Object> domains = <String, Object>{
      'cold_path': coldPath,
      'fallback': fallback,
      'persona_theme': personaTheme,
      'render_qa': renderQA,
      'stability_consistency': stability,
      'system_crown': systemCrown,
      'visual_closure': visualClosure,
    };
    final List<String> missing = domains.entries
        .where((entry) {
          final value = entry.value;
          final bool empty = value is Map && value.isEmpty;
          return empty || !ready(value);
        })
        .map((entry) => entry.key)
        .toList();
    final bool guardReady = missing.isEmpty;
    return <String, Object>{
      'final_stability_guard_v1': <String, Object>{
        'domains': domains,
        'missing': missing,
        'guard_ready': guardReady,
      },
      'readiness': guardReady,
    };
  }
}

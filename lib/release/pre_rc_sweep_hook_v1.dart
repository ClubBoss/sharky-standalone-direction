class PreRCSweepHookV1 {
  const PreRCSweepHookV1(
    this.qaFinalIntegrationSurfaceV1Map,
    this.qaReleaseSummaryV1Map,
    this.qaSystemVerdictV1Map,
    this.qaStructuralSealV1Map,
    this.qaDeepSystemVerdictV1Map,
    this.systemQACrownV1Map,
    this.stabilityConsistencyPassV3Map,
    this.v4ToV3FallbackValidatorV1Map,
    this.personaThemeAlignmentV1Map,
  );

  final Object qaFinalIntegrationSurfaceV1Map;
  final Object qaReleaseSummaryV1Map;
  final Object qaSystemVerdictV1Map;
  final Object qaStructuralSealV1Map;
  final Object qaDeepSystemVerdictV1Map;
  final Object systemQACrownV1Map;
  final Object stabilityConsistencyPassV3Map;
  final Object v4ToV3FallbackValidatorV1Map;
  final Object personaThemeAlignmentV1Map;

  Map<String, Object> asReadOnlyMap() {
    Map<String, Object> m(Object v) => v is Map && v.isNotEmpty
        ? v.cast<String, Object>()
        : <String, Object>{};
    bool ready(Object v) => v is Map && v['readiness'] == true;
    final Map<String, Object> integration = m(qaFinalIntegrationSurfaceV1Map);
    final Map<String, Object> release = m(qaReleaseSummaryV1Map);
    final Map<String, Object> system = m(qaSystemVerdictV1Map);
    final Map<String, Object> structural = m(qaStructuralSealV1Map);
    final Map<String, Object> deep = m(qaDeepSystemVerdictV1Map);
    final Map<String, Object> crown = m(systemQACrownV1Map);
    final Map<String, Object> stability = m(stabilityConsistencyPassV3Map);
    final Map<String, Object> fallback = m(v4ToV3FallbackValidatorV1Map);
    final Map<String, Object> persona = m(personaThemeAlignmentV1Map);
    final Map<String, Object> domains = <String, Object>{
      'integration_surface': integration,
      'release_summary': release,
      'system_verdict': system,
      'structural_seal': structural,
      'deep_verdict': deep,
      'system_crown': crown,
      'stability_consistency': stability,
      'fallback': fallback,
      'persona_theme_alignment': persona,
    };
    final List<String> missing = <String>[
      if (integration.isEmpty) 'qa_final_integration_surface_v1',
      if (release.isEmpty) 'qa_release_summary_v1',
      if (system.isEmpty) 'qa_system_verdict_v1',
      if (structural.isEmpty) 'qa_structural_seal_v1',
      if (deep.isEmpty) 'qa_deep_system_verdict_v1',
      if (crown.isEmpty) 'system_qa_crown_v1',
      if (stability.isEmpty) 'stability_consistency_pass_v3',
      if (fallback.isEmpty) 'v4_to_v3_fallback_validator_v1',
      if (persona.isEmpty) 'persona_theme_alignment_v1',
    ];
    final bool sweepReady =
        ready(integration) &&
        ready(release) &&
        ready(system) &&
        ready(structural) &&
        ready(deep) &&
        ready(crown) &&
        ready(stability) &&
        ready(fallback) &&
        ready(persona);
    return <String, Object>{
      'pre_rc_sweep_hook_v1': <String, Object>{
        'domains': domains,
        'missing': missing,
        'sweep_ready': sweepReady,
      },
      'readiness': sweepReady,
    };
  }
}

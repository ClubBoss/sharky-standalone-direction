class RCPackagingIntegrationV1 {
  const RCPackagingIntegrationV1(
    this.preRCSweepHookV1Map,
    this.qaFinalIntegrationSurfaceV1Map,
    this.qaReleaseSummaryV1Map,
    this.qaSystemVerdictV1Map,
    this.qaStructuralSealV1Map,
    this.stabilityConsistencyPassV3Map,
    this.v4ToV3FallbackValidatorV1Map,
    this.personaThemeAlignmentV1Map,
  );

  final Object preRCSweepHookV1Map;
  final Object qaFinalIntegrationSurfaceV1Map;
  final Object qaReleaseSummaryV1Map;
  final Object qaSystemVerdictV1Map;
  final Object qaStructuralSealV1Map;
  final Object stabilityConsistencyPassV3Map;
  final Object v4ToV3FallbackValidatorV1Map;
  final Object personaThemeAlignmentV1Map;

  Map<String, Object> asReadOnlyMap() {
    Map<String, Object> m(Object v) => v is Map && v.isNotEmpty
        ? v.cast<String, Object>()
        : <String, Object>{};
    bool ready(Object v) => v is Map && v['readiness'] == true;
    final Map<String, Object> sweep = m(preRCSweepHookV1Map);
    final Map<String, Object> integration = m(qaFinalIntegrationSurfaceV1Map);
    final Map<String, Object> release = m(qaReleaseSummaryV1Map);
    final Map<String, Object> system = m(qaSystemVerdictV1Map);
    final Map<String, Object> structural = m(qaStructuralSealV1Map);
    final Map<String, Object> stability = m(stabilityConsistencyPassV3Map);
    final Map<String, Object> fallback = m(v4ToV3FallbackValidatorV1Map);
    final Map<String, Object> persona = m(personaThemeAlignmentV1Map);
    final Map<String, Object> domains = <String, Object>{
      'fallback': fallback,
      'integration_surface': integration,
      'persona_theme_alignment': persona,
      'release_summary': release,
      'stability_consistency': stability,
      'structural_seal': structural,
      'sweep': sweep,
      'system_verdict': system,
    };
    final List<String> missing = <String>[
      if (sweep.isEmpty) 'pre_rc_sweep_hook_v1',
      if (integration.isEmpty) 'qa_final_integration_surface_v1',
      if (release.isEmpty) 'qa_release_summary_v1',
      if (system.isEmpty) 'qa_system_verdict_v1',
      if (structural.isEmpty) 'qa_structural_seal_v1',
      if (stability.isEmpty) 'stability_consistency_pass_v3',
      if (fallback.isEmpty) 'v4_to_v3_fallback_validator_v1',
      if (persona.isEmpty) 'persona_theme_alignment_v1',
    ];
    final bool readyFlag =
        ready(sweep) &&
        ready(integration) &&
        ready(release) &&
        ready(system) &&
        ready(structural) &&
        ready(stability) &&
        ready(fallback) &&
        ready(persona);
    return <String, Object>{
      'rc_packaging_integration_v1': <String, Object>{
        'domains': domains,
        'missing': missing,
        'pack_ready': readyFlag,
      },
      'readiness': readyFlag,
    };
  }
}

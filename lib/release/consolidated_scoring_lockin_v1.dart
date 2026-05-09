class ConsolidatedScoringLockInV1 {
  const ConsolidatedScoringLockInV1(
    this.stabilityConsistencyPassV3Map,
    this.qaFinalIntegrationSurfaceV1Map,
    this.systemQACrownV1Map,
    this.qaStructuralSealV1Map,
    this.qaReleaseSummaryV1Map,
    this.tableUIPathVerdictV1Map,
    this.tableRenderPathVerdictV1Map,
  );

  final Object stabilityConsistencyPassV3Map;
  final Object qaFinalIntegrationSurfaceV1Map;
  final Object systemQACrownV1Map;
  final Object qaStructuralSealV1Map;
  final Object qaReleaseSummaryV1Map;
  final Object tableUIPathVerdictV1Map;
  final Object tableRenderPathVerdictV1Map;

  Map<String, Object> asReadOnlyMap() {
    Map<String, Object> m(Object v) => v is Map && v.isNotEmpty
        ? v.cast<String, Object>()
        : <String, Object>{};
    bool ready(Object v) => v is Map && v['readiness'] == true;
    final Map<String, Object> stability = m(stabilityConsistencyPassV3Map);
    final Map<String, Object> qaFinal = m(qaFinalIntegrationSurfaceV1Map);
    final Map<String, Object> crown = m(systemQACrownV1Map);
    final Map<String, Object> structural = m(qaStructuralSealV1Map);
    final Map<String, Object> release = m(qaReleaseSummaryV1Map);
    final Map<String, Object> uiPath = m(tableUIPathVerdictV1Map);
    final Map<String, Object> renderPath = m(tableRenderPathVerdictV1Map);
    final Map<String, Object> domains = <String, Object>{
      'stability_consistency': stability,
      'qa_final_integration': qaFinal,
      'system_crown': crown,
      'structural': structural,
      'release_summary': release,
      'ui_path': uiPath,
      'render_path': renderPath,
    };
    final List<String> missing = <String>[
      if (stability.isEmpty) 'stability_consistency_pass_v3',
      if (qaFinal.isEmpty) 'qa_final_integration_surface_v1',
      if (crown.isEmpty) 'system_qa_crown_v1',
      if (structural.isEmpty) 'qa_structural_seal_v1',
      if (release.isEmpty) 'qa_release_summary_v1',
      if (uiPath.isEmpty) 'table_ui_path_verdict_v1',
      if (renderPath.isEmpty) 'table_render_path_verdict_v1',
    ];
    final List<String> invalid = <String>[];
    final bool readyFlag =
        ready(stability) &&
        ready(qaFinal) &&
        ready(crown) &&
        ready(structural) &&
        ready(release) &&
        ready(uiPath) &&
        ready(renderPath);
    return <String, Object>{
      'consolidated_scoring_lockin_v1': <String, Object>{
        'domains': domains,
        'missing': missing,
        'invalid': invalid,
        'lockin_ready': readyFlag,
      },
      'readiness': readyFlag,
    };
  }

  // compat forwarder
  Map<String, Object> toReadOnlyMap() => asReadOnlyMap();
}

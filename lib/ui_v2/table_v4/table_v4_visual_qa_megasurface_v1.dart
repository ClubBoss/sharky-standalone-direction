class TableV4VisualQAMegaSurfaceV1 {
  const TableV4VisualQAMegaSurfaceV1();

  static Map<String, Object> build({
    required Map<String, Object?> orchestratorMap,
    required Map<String, Object?> contrastMap,
    required Map<String, Object?> cohesionMap,
    required Map<String, Object?> qaSurfaceMap,
    required Map<String, Object?> readinessAggregateMap,
    required Map<String, Object?> readinessSurfaceMap,
    required Map<String, Object?> healthLedgerMap,
    required Map<String, Object?> auditBridgeMap,
    required Map<String, Object?> manifestMap,
    required Map<String, Object?> dashboardMap,
  }) {
    final Map<String, Object?> orchestratorBody =
        orchestratorMap['table_v4_visual_qa_orchestrator_v1']
            as Map<String, Object?>? ??
        <String, Object?>{};
    final Map<String, Object?> contrastBody =
        contrastMap['table_v4_contrast_audit_v1'] as Map<String, Object?>? ??
        <String, Object?>{};
    final Map<String, Object?> cohesionBody =
        cohesionMap['table_v4_cohesion_pass_v1'] as Map<String, Object?>? ??
        <String, Object?>{};
    final Map<String, Object?> qaBody =
        qaSurfaceMap['table_v4_visual_qa_surface_v1']
            as Map<String, Object?>? ??
        <String, Object?>{};
    final Map<String, Object?> aggregateBody =
        readinessAggregateMap['table_v4_readiness_aggregate_v1']
            as Map<String, Object?>? ??
        <String, Object?>{};
    final Map<String, Object?> readinessBody =
        readinessSurfaceMap['table_v4_readiness_surface_v1']
            as Map<String, Object?>? ??
        <String, Object?>{};
    final Map<String, Object?> ledgerBody =
        healthLedgerMap['table_v4_visual_health_ledger_v1']
            as Map<String, Object?>? ??
        <String, Object?>{};
    final Map<String, Object?> auditBody =
        auditBridgeMap['table_v4_visual_audit_bridge_v1']
            as Map<String, Object?>? ??
        <String, Object?>{};
    final Map<String, Object?> manifestBody =
        manifestMap['table_v4_visual_qa_manifest_v1']
            as Map<String, Object?>? ??
        <String, Object?>{};
    final Map<String, Object?> dashboardBody =
        dashboardMap['table_v4_visual_qa_dashboard_v1']
            as Map<String, Object?>? ??
        <String, Object?>{};
    final Map<String, Object> components = <String, Object>{
      'orchestrator': orchestratorBody,
      'contrast': contrastBody,
      'cohesion': cohesionBody,
      'qa_surface': qaBody,
      'readiness_aggregate': aggregateBody,
      'readiness_surface': readinessBody,
      'health_ledger': ledgerBody,
      'audit_bridge': auditBody,
      'manifest': manifestBody,
      'dashboard': dashboardBody,
    };
    final Map<String, int> counts = <String, int>{
      'orchestrator': _issueCount(orchestratorBody),
      'contrast': _issueCount(contrastBody),
      'cohesion': _issueCount(cohesionBody),
      'qa_surface': _issueCount(qaBody),
      'readiness_aggregate': _issueCount(aggregateBody),
      'readiness_surface': _issueCount(readinessBody),
      'health_ledger': _issueCount(ledgerBody),
      'audit_bridge': _issueCount(auditBody),
      'manifest': _issueCount(manifestBody),
      'dashboard': _issueCount(dashboardBody),
    };
    final Set<String> allIssues = <String>{
      ..._issues(orchestratorBody, 'orchestrator'),
      ..._issues(contrastBody, 'contrast'),
      ..._issues(cohesionBody, 'cohesion'),
      ..._issues(qaBody, 'qa'),
      ..._issues(aggregateBody, 'readiness_aggregate'),
      ..._issues(readinessBody, 'readiness_surface'),
      ..._issues(ledgerBody, 'ledger'),
      ..._issues(auditBody, 'audit'),
      ..._issues(manifestBody, 'manifest'),
      ..._issues(dashboardBody, 'dashboard'),
    };
    final List<String> sortedIssues = allIssues.toList()..sort();
    return <String, Object>{
      'table_v4_visual_qa_megasurface_v1': <String, Object>{
        'components': components,
        'issue_counts': counts,
        'all_issues': sortedIssues,
        'mega_ready': false,
      },
    };
  }

  static int _issueCount(Map<String, Object?> map) => map['issues'] is List
      ? (map['issues'] as List).whereType<String>().length
      : 0;

  static List<String> _issues(Map<String, Object?> map, String prefix) {
    final Object? issues = map['issues'] ?? map['all_issues'];
    if (issues is List) {
      return issues
          .whereType<String>()
          .map((issue) => '$prefix:$issue')
          .toList();
    }
    return <String>[];
  }
}

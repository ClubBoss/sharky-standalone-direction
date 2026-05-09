class TableV4VisualQAOrchestratorV1 {
  const TableV4VisualQAOrchestratorV1();

  static Map<String, Object> build({
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
    final Map<String, bool> okFlags = <String, bool>{
      'contrast_ok': false,
      'cohesion_ok': false,
      'qa_ok': false,
      'readiness_ok': false,
      'ledger_ok': false,
      'audit_ok': false,
      'manifest_ok': false,
      'dashboard_ok': false,
    };
    final Map<String, int> counts = <String, int>{
      'contrast': _issueCount(contrastBody),
      'cohesion': _issueCount(cohesionBody),
      'qa': _issueCount(qaBody),
      'readiness': _issueCount(aggregateBody),
      'ledger': _issueCount(ledgerBody),
      'audit': _issueCount(auditBody),
      'manifest': _issueCount(manifestBody),
      'dashboard': _issueCount(dashboardBody),
    };
    final Set<String> allIssuesSet = <String>{
      ..._issues(contrastBody, 'contrast'),
      ..._issues(cohesionBody, 'cohesion'),
      ..._issues(qaBody, 'qa'),
      ..._issues(aggregateBody, 'readiness'),
      ..._issues(readinessBody, 'readiness_surface'),
      ..._issues(ledgerBody, 'ledger'),
      ..._issues(auditBody, 'audit'),
      ..._issues(manifestBody, 'manifest'),
      ..._issues(dashboardBody, 'dashboard'),
    };
    final List<String> allIssues = allIssuesSet.toList()..sort();
    return <String, Object>{
      'table_v4_visual_qa_orchestrator_v1': <String, Object>{
        'ok_flags': okFlags,
        'issue_counts': counts,
        'all_issues': allIssues,
        'orchestrator_ready': false,
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

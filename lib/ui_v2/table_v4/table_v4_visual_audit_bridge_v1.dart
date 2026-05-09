class TableV4VisualAuditBridgeV1 {
  const TableV4VisualAuditBridgeV1();

  static Map<String, Object> build({
    required Map<String, Object?> contrastMap,
    required Map<String, Object?> cohesionMap,
    required Map<String, Object?> qaSurfaceMap,
    required Map<String, Object?> readinessAggregateMap,
    required Map<String, Object?> readinessSurfaceMap,
    required Map<String, Object?> healthLedgerMap,
  }) {
    final bool contrastReady = _flag(
      contrastMap['table_v4_contrast_audit_v1'] as Map<String, Object?>?,
      'ready',
    );
    final bool cohesionReady = _flag(
      cohesionMap['table_v4_cohesion_pass_v1'] as Map<String, Object?>?,
      'ready',
    );
    final bool qaReady = _flag(
      qaSurfaceMap['table_v4_visual_qa_surface_v1'] as Map<String, Object?>?,
      'ready',
    );
    final bool readinessReady = _flag(
      readinessSurfaceMap['table_v4_readiness_surface_v1']
          as Map<String, Object?>?,
      'ready',
    );
    final bool ledgerAllOk = _flag(
      healthLedgerMap['table_v4_visual_health_ledger_v1']
          as Map<String, Object?>?,
      'all_ok',
    );
    final List<String> issues = <String>[
      ..._issuesFrom(
        contrastMap['table_v4_contrast_audit_v1'] as Map<String, Object?>?,
        'contrast',
      ),
      ..._issuesFrom(
        cohesionMap['table_v4_cohesion_pass_v1'] as Map<String, Object?>?,
        'cohesion',
      ),
      ..._issuesFrom(
        qaSurfaceMap['table_v4_visual_qa_surface_v1'] as Map<String, Object?>?,
        'qa',
      ),
      ..._issuesFrom(
        readinessAggregateMap['table_v4_readiness_aggregate_v1']
            as Map<String, Object?>?,
        'aggregate',
      ),
      ..._issuesFrom(
        readinessSurfaceMap['table_v4_readiness_surface_v1']
            as Map<String, Object?>?,
        'readiness',
      ),
      ..._issuesFrom(
        healthLedgerMap['table_v4_visual_health_ledger_v1']
            as Map<String, Object?>?,
        'ledger',
      ),
    ];
    issues.sort();
    return <String, Object>{
      'table_v4_visual_audit_bridge_v1': <String, Object>{
        'contrast_ready': contrastReady,
        'cohesion_ready': cohesionReady,
        'qa_ready': qaReady,
        'readiness_ready': readinessReady,
        'ledger_all_ok': ledgerAllOk,
        'issues': issues,
        'ready': false,
      },
    };
  }

  static bool _flag(Map<String, Object?>? map, String key) {
    if (map == null) return false;
    final Object? value = map[key];
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final String normalized = value.toLowerCase();
      return normalized == 'true' || normalized == '1';
    }
    return false;
  }

  static List<String> _issuesFrom(Map<String, Object?>? map, String prefix) {
    if (map == null) return <String>[];
    final Object? issues = map['issues'];
    if (issues is List) {
      return issues
          .whereType<String>()
          .map((issue) => '$prefix:$issue')
          .toList();
    }
    return <String>[];
  }
}

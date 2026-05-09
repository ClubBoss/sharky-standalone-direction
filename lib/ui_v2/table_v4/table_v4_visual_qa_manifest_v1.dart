class TableV4VisualQAManifestV1 {
  const TableV4VisualQAManifestV1();

  static Map<String, Object> build({
    required Map<String, Object?> contrastMap,
    required Map<String, Object?> cohesionMap,
    required Map<String, Object?> qaSurfaceMap,
    required Map<String, Object?> readabilityAggregateMap,
    required Map<String, Object?> readinessSurfaceMap,
    required Map<String, Object?> healthLedgerMap,
    required Map<String, Object?> auditBridgeMap,
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
        readabilityAggregateMap['table_v4_readiness_aggregate_v1']
            as Map<String, Object?>? ??
        <String, Object?>{};
    final Map<String, Object?> readinessSurfaceBody =
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
    final List<String> issues = <String>[
      ..._issues(contrastBody, 'contrast'),
      ..._issues(cohesionBody, 'cohesion'),
      ..._issues(qaBody, 'qa'),
      ..._issues(aggregateBody, 'agg'),
      ..._issues(readinessSurfaceBody, 'readiness'),
      ..._issues(ledgerBody, 'ledger'),
      ..._issues(auditBody, 'audit'),
    ];
    issues.sort();
    return <String, Object>{
      'table_v4_visual_qa_manifest_v1': <String, Object>{
        'contrast_keys': _sortedKeys(contrastBody),
        'cohesion_keys': _sortedKeys(cohesionBody),
        'qa_keys': _sortedKeys(qaBody),
        'readiness_keys': _sortedKeys(aggregateBody),
        'readiness_surface_keys': _sortedKeys(readinessSurfaceBody),
        'health_ledger_keys': _sortedKeys(ledgerBody),
        'audit_bridge_keys': _sortedKeys(auditBody),
        'all_issues': issues,
        'manifest_ready': false,
      },
    };
  }

  static List<String> _sortedKeys(Map<String, Object?> map) {
    final List<String> keys = map.keys.whereType<String>().toList();
    keys.sort();
    return keys;
  }

  static List<String> _issues(Map<String, Object?> map, String prefix) {
    final Object? value = map['issues'];
    if (value is List) {
      return value
          .whereType<String>()
          .map((issue) => '$prefix:$issue')
          .toList();
    }
    return <String>[];
  }
}

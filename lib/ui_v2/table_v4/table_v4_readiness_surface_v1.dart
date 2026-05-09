class TableV4ReadinessSurfaceV1 {
  const TableV4ReadinessSurfaceV1();

  static Map<String, Object> build({
    required Map<String, Object?> readinessAggregateMap,
    required Map<String, Object?> visualQASurfaceMap,
    required Map<String, Object?> contrastMap,
    required Map<String, Object?> cohesionMap,
  }) {
    final Map<String, Object?> aggregateBody =
        readinessAggregateMap['table_v4_readiness_aggregate_v1']
            as Map<String, Object?>? ??
        <String, Object?>{};
    final Map<String, Object?> qaBody =
        visualQASurfaceMap['table_v4_visual_qa_surface_v1']
            as Map<String, Object?>? ??
        <String, Object?>{};
    final Map<String, Object?> contrastBody =
        contrastMap['v4_contrast_audit_v1'] as Map<String, Object?>? ??
        <String, Object?>{};
    final Map<String, Object?> cohesionBody =
        cohesionMap['visual_cohesion_v1'] as Map<String, Object?>? ??
        <String, Object?>{};
    final bool aggregateOk = aggregateBody['all_ok'] == true;
    final bool qaOk = qaBody['all_ok'] == true;
    final bool contrastOk = contrastBody['ready'] == true;
    final bool cohesionOk = cohesionBody['ready'] == true;
    final bool allOk = aggregateOk && qaOk && contrastOk && cohesionOk;
    final List<String> issues = <String>[
      ..._extractIssues(aggregateBody, 'aggregate'),
      ..._extractIssues(qaBody, 'qa'),
      ..._extractIssues(contrastBody, 'contrast'),
      ..._extractIssues(cohesionBody, 'cohesion'),
    ];
    issues.sort();
    return <String, Object>{
      'table_v4_readiness_surface_v1': <String, Object>{
        'aggregate_ok': aggregateOk,
        'qa_ok': qaOk,
        'contrast_ok': contrastOk,
        'cohesion_ok': cohesionOk,
        'all_ok': allOk,
        'issues': issues,
        'ready': false,
      },
    };
  }

  static List<String> _extractIssues(Map<String, Object?> map, String prefix) {
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

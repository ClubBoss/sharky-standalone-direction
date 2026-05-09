class TableV4VisualHealthLedgerV1 {
  const TableV4VisualHealthLedgerV1();

  static Map<String, Object> build({
    required Map<String, Object?> contrastMap,
    required Map<String, Object?> cohesionMap,
    required Map<String, Object?> visualQAMap,
    required Map<String, Object?> readinessSurfaceMap,
    required Map<String, Object?> shellMap,
  }) {
    final bool contrastOk = _flag(
      contrastMap['table_v4_contrast_audit_v1'] as Map<String, Object?>?,
    );
    final bool cohesionOk = _flag(
      cohesionMap['table_v4_cohesion_pass_v1'] as Map<String, Object?>?,
    );
    final bool qaOk = _flag(
      visualQAMap['table_v4_visual_qa_surface_v1'] as Map<String, Object?>?,
      key: 'all_ok',
    );
    final bool readinessOk = _flag(
      readinessSurfaceMap['table_v4_readiness_surface_v1']
          as Map<String, Object?>?,
      key: 'all_ok',
    );
    final bool shellReady =
        (shellMap['v4_readiness'] as Map<String, Object?>?)?['v4_ready'] ==
        true;
    final bool allOk =
        contrastOk && cohesionOk && qaOk && readinessOk && shellReady;
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
        visualQAMap['table_v4_visual_qa_surface_v1'] as Map<String, Object?>?,
        'visual_qa',
      ),
      ..._issuesFrom(
        readinessSurfaceMap['table_v4_readiness_surface_v1']
            as Map<String, Object?>?,
        'readiness',
      ),
      ..._issuesFrom(
        shellMap['v4_readiness'] as Map<String, Object?>?,
        'shell',
      ),
    ];
    issues.sort();
    return <String, Object>{
      'table_v4_visual_health_ledger_v1': <String, Object>{
        'contrast_ok': contrastOk,
        'cohesion_ok': cohesionOk,
        'qa_ok': qaOk,
        'readiness_ok': readinessOk,
        'shell_ready': shellReady,
        'all_ok': allOk,
        'issues': issues,
        'ready': false,
      },
    };
  }

  static bool _flag(Map<String, Object?>? map, {String key = 'ready'}) {
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

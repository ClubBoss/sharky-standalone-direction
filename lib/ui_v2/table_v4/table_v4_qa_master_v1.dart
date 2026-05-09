class TableV4QAMasterV1 {
  const TableV4QAMasterV1();

  static Map<String, Object> build({
    required Map<String, Object?> contrastAudit,
    required Map<String, Object?> cohesionPass,
    required Map<String, Object?> visualQASurface,
    required Map<String, Object?> readinessAggregate,
    required Map<String, Object?> readinessSurface,
    required Map<String, Object?> visualHealthLedger,
    required Map<String, Object?> auditBridge,
    required Map<String, Object?> manifest,
    required Map<String, Object?> dashboard,
    required Map<String, Object?> orchestrator,
    required Map<String, Object?> megaSurface,
    required Map<String, Object?> summaryDescriptor,
  }) {
    final List<Map<String, Object?>> sections = <Map<String, Object?>>[
      <String, Object?>{'name': 'contrast', 'map': contrastAudit},
      <String, Object?>{'name': 'cohesion', 'map': cohesionPass},
      <String, Object?>{'name': 'visual', 'map': visualQASurface},
      <String, Object?>{'name': 'readiness', 'map': readinessAggregate},
      <String, Object?>{'name': 'readiness_surface', 'map': readinessSurface},
      <String, Object?>{'name': 'health', 'map': visualHealthLedger},
      <String, Object?>{'name': 'audit', 'map': auditBridge},
      <String, Object?>{'name': 'manifest', 'map': manifest},
      <String, Object?>{'name': 'dashboard', 'map': dashboard},
      <String, Object?>{'name': 'orchestrator', 'map': orchestrator},
      <String, Object?>{'name': 'mega', 'map': megaSurface},
    ];
    final Map<String, bool> sectionOk = <String, bool>{};
    int totalIssues = 0;
    final Set<String> uniqueIssues = <String>{};
    for (final entry in sections) {
      final String name = entry['name'] as String;
      final Map<String, Object?>? map = entry['map'] as Map<String, Object?>?;
      final Iterable<String> issues = _collectIssues(map);
      uniqueIssues.addAll(issues);
      totalIssues += issues.length;
      sectionOk[name] = _flagOk(map);
    }
    final List<String> sortedUnique = uniqueIssues.toList()..sort();
    final int weightedScore =
        (summaryDescriptor['qa_summary_descriptor_v1']
                as Map<String, Object?>?)?['weighted_score']
            as int? ??
        0;
    return <String, Object>{
      'qa_master_v1': <String, Object>{
        'all_ok': sectionOk.values.every((value) => value),
        'total_issues': totalIssues,
        'weighted_score': weightedScore,
        'unique_issues': sortedUnique,
        'sections': sectionOk,
      },
    };
  }

  static Iterable<String> _collectIssues(Map<String, Object?>? map) {
    if (map == null) return <String>[];
    final Object? issues = map['issues'] ?? map['all_issues'];
    if (issues is List) {
      return issues.whereType<String>();
    }
    return <String>[];
  }

  static bool _flagOk(Map<String, Object?>? map) {
    if (map == null) return false;
    final Object? value = map['all_ok'] ?? map['ready'];
    if (value is bool) return value;
    if (value is num) return value != 0;
    return false;
  }
}

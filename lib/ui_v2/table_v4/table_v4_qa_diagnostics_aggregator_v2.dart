class TableV4QADiagnosticsAggregatorV2 {
  const TableV4QADiagnosticsAggregatorV2();

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
    required Map<String, Object?> orchestratorMap,
    required Map<String, Object?> megaSurfaceMap,
    required Map<String, Object?> frameDiagnosticsMap,
    required Map<String, Object?> typographyCohesionMap,
    required Map<String, Object?> typographyUnifierMap,
    required Map<String, Object?> severityWeightsMap,
  }) {
    final Map<String, Object?> sectionBodies = <String, Object?>{
      'contrast': contrastMap,
      'cohesion': cohesionMap,
      'qa_surface': qaSurfaceMap,
      'readiness_aggregate': readinessAggregateMap,
      'readiness_surface': readinessSurfaceMap,
      'health_ledger': healthLedgerMap,
      'audit_bridge': auditBridgeMap,
      'manifest': manifestMap,
      'dashboard': dashboardMap,
      'orchestrator': orchestratorMap,
      'mega_surface': megaSurfaceMap,
      'frame_diagnostics': frameDiagnosticsMap,
      'typography_cohesion': typographyCohesionMap,
      'typography_unifier': typographyUnifierMap,
    };
    final Map<String, bool> sectionsOk = <String, bool>{};
    final Set<String> allIssues = <String>{};
    for (final MapEntry<String, Object?> entry in sectionBodies.entries) {
      final bool readyFlag = _isReady(entry.value);
      sectionsOk[entry.key] = readyFlag != true;
      allIssues.addAll(_collectIssues(entry.value));
    }
    final List<String> sortedIssues = allIssues.toList()..sort();
    final Map<String, int> weights = _severityWeights(severityWeightsMap);
    final int weightedScore = sortedIssues.fold<int>(
      0,
      (total, issue) => total + _weightForIssue(issue, weights),
    );
    return <String, Object>{
      'qa_diagnostics_v2': <String, Object>{
        'qa_weighted_score': weightedScore,
        'qa_issue_count': sortedIssues.length,
        'qa_unique_issues': sortedIssues,
        'sections_ok': sectionsOk,
        'ready': false,
      },
    };
  }

  static bool _isReady(Object? entry) {
    if (entry is Map<String, Object?>) {
      final Object? value = entry['ready'];
      if (value is bool) {
        return value;
      }
    }
    return false;
  }

  static Iterable<String> _collectIssues(Object? entry) {
    if (entry is Map<String, Object?>) {
      final Object? issues = entry['issues'] ?? entry['all_issues'];
      if (issues is List) {
        return issues.whereType<String>();
      }
    }
    return <String>[];
  }

  static Map<String, int> _severityWeights(Map<String, Object?> map) {
    final Map<String, int> result = <String, int>{};
    map.forEach((key, value) {
      result[key.toLowerCase()] = _toInt(value, 1);
    });
    return result;
  }

  static int _weightForIssue(String issue, Map<String, int> weights) {
    final List<String> parts = issue.split(':');
    final String severity = parts.isNotEmpty
        ? parts.first.toLowerCase()
        : 'info';
    return weights[severity] ?? 1;
  }

  static int _toInt(Object? value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? fallback;
    }
    return fallback;
  }
}

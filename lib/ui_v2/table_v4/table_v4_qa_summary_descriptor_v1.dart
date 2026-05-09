class TableV4QASummaryDescriptorV1 {
  const TableV4QASummaryDescriptorV1();

  static Map<String, Object> build({
    required Iterable<String> uniqueIssues,
    required Map<String, Object?> severityWeights,
    required Map<String, Object?> severityLegend,
  }) {
    final Map<String, int> counts = <String, int>{
      'error': 0,
      'warning': 0,
      'info': 0,
    };
    final Map<String, int> weights = <String, int>{
      'error': _extractWeight(severityWeights, 'error'),
      'warning': _extractWeight(severityWeights, 'warning'),
      'info': _extractWeight(severityWeights, 'info'),
    };
    int weightedScore = 0;
    for (final String issue in uniqueIssues) {
      final String severity = _severityFromIssue(issue);
      counts[severity] = counts[severity]! + 1;
      weightedScore += weights[severity] ?? 1;
    }
    return <String, Object>{
      'qa_summary_descriptor_v1': <String, Object>{
        'error_count': counts['error'] ?? 0,
        'warning_count': counts['warning'] ?? 0,
        'info_count': counts['info'] ?? 0,
        'weighted_score': weightedScore,
      },
    };
  }

  static String _severityFromIssue(String issue) {
    final List<String> parts = issue.split(':');
    final String prefix = parts.isNotEmpty ? parts.first.toLowerCase() : 'info';
    if (prefix == 'error') return 'error';
    if (prefix == 'warning' || prefix == 'warn') return 'warning';
    return 'info';
  }

  static int _extractWeight(Map<String, Object?> weights, String key) {
    final Object? value =
        weights[key] ?? weights[key == 'warning' ? 'warn' : key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? 1;
    }
    return 1;
  }
}

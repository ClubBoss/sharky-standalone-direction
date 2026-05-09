class V4VisualCohesionCheck {
  const V4VisualCohesionCheck({
    required this.normalizedV4,
    required this.deltaReport,
  });

  final Map<String, Object> normalizedV4;
  final Map<String, Object> deltaReport;

  Map<String, Object> buildCohesionReport() {
    final items = deltaReport['items'];
    final results = <Map<String, String>>[];
    if (items is List) {
      for (final item in items) {
        final status = (item is Map ? item['status'] : null)?.toString();
        final key = (item is Map ? item['key'] : null)?.toString() ?? '';
        String cohesion = 'asymmetric';
        if (status == 'same') {
          cohesion = 'ok';
        } else if (status == 'different') {
          cohesion = 'needs_review';
        }
        results.add(<String, String>{
          'key': key,
          'status': status ?? '',
          'cohesion': cohesion,
        });
      }
    }
    return <String, Object>{
      'token_count': normalizedV4.length,
      'results': results,
    };
  }

  Map<String, Object> exportCohesionQAStatus() {
    final report = buildCohesionReport();
    final results = report['results'];
    final missingTokens = <String>[];
    final mismatched = <String>[];
    final deltaAnomalies = <String>[];
    if (results is List) {
      for (final entry in results) {
        final key = (entry is Map ? entry['key'] : null)?.toString() ?? '';
        final status =
            (entry is Map ? entry['status'] : null)?.toString() ?? '';
        if (status == 'missing_in_v3' || status == 'missing_in_v4') {
          missingTokens.add(key);
        } else if (status == 'different') {
          mismatched.add(key);
        }
      }
    }
    missingTokens.sort();
    mismatched.sort();
    deltaAnomalies.sort();
    final ok =
        missingTokens.isEmpty && mismatched.isEmpty && deltaAnomalies.isEmpty;
    return <String, Object>{
      'ok': ok,
      'missing_tokens': List<String>.unmodifiable(missingTokens),
      'mismatched_tokens': List<String>.unmodifiable(mismatched),
      'delta_anomalies': List<String>.unmodifiable(deltaAnomalies),
    };
  }

  Map<String, Object> exportV4TokenVerification() {
    final malformed = <String>[];
    final missingKeys = <String>[];
    final extraTokens = <String>[];
    final requiredCategories = [
      'color',
      'radius',
      'padding',
      'shadow',
      'motion',
    ];

    for (final entry in normalizedV4.entries) {
      final key = entry.key;
      if (!_isValidTokenName(key)) malformed.add(key);
      if (!deltaReport.containsKey(key)) extraTokens.add(key);
    }

    final snapshotKeys = deltaReport.keys.whereType<String>().toList();
    for (final k in snapshotKeys) {
      if (!_isValidTokenName(k)) malformed.add(k);
    }
    for (final cat in requiredCategories) {
      if (!snapshotKeys.contains(cat)) missingKeys.add(cat);
    }

    malformed.sort();
    missingKeys.sort();
    extraTokens.sort();
    final ok = malformed.isEmpty && missingKeys.isEmpty;
    return <String, Object>{
      'ok': ok,
      'malformed_tokens': List<String>.unmodifiable(malformed),
      'missing_snapshot_keys': List<String>.unmodifiable(missingKeys),
      'extra_tokens': List<String>.unmodifiable(extraTokens),
    };
  }

  bool _isValidTokenName(String key) {
    final lower = key.toLowerCase();
    return key == lower && !key.contains(' ') && key.contains('_');
  }
}

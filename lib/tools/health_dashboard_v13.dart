class HealthDashboardV13 {
  const HealthDashboardV13({
    this.v3Surface = const <String, Object>{},
    this.v4Surface = const <String, Object>{},
    this.cSeriesSurface = const <String, Object>{},
    this.fusionSurface = const <String, Object>{},
    this.releaseSurface = const <String, Object>{},
    this.unifiedValidation = const <String, Object>{},
    this.driftGate = const <String, Object>{},
    this.preCommitFull = const <String, Object>{},
    this.analyzerAutoFix = const <String, Object>{},
  });

  HealthDashboardV13.fromInputs({
    Map<String, Object?>? v3Surface,
    Map<String, Object?>? v4Surface,
    Map<String, Object?>? cSeriesSurface,
    Map<String, Object?>? fusionSurface,
    Map<String, Object?>? releaseSurface,
    Map<String, Object?>? unifiedValidation,
    Map<String, Object?>? driftGate,
    Map<String, Object?>? preCommitFull,
    Map<String, Object?>? analyzerAutoFix,
  }) : this(
         v3Surface: _safe(v3Surface),
         v4Surface: _safe(v4Surface),
         cSeriesSurface: _safe(cSeriesSurface),
         fusionSurface: _safe(fusionSurface),
         releaseSurface: _safe(releaseSurface),
         unifiedValidation: _safe(unifiedValidation),
         driftGate: _safe(driftGate),
         preCommitFull: _safe(preCommitFull),
         analyzerAutoFix: _safe(analyzerAutoFix),
       );

  final Map<String, Object> v3Surface;
  final Map<String, Object> v4Surface;
  final Map<String, Object> cSeriesSurface;
  final Map<String, Object> fusionSurface;
  final Map<String, Object> releaseSurface;
  final Map<String, Object> unifiedValidation;
  final Map<String, Object> driftGate;
  final Map<String, Object> preCommitFull;
  final Map<String, Object> analyzerAutoFix;

  Map<String, Object> build() {
    final Map<String, bool> sectionsOk = <String, bool>{
      'v3_surface': _ready(v3Surface),
      'v4_surface': _ready(v4Surface),
      'c_series_surface': _ready(cSeriesSurface),
      'fusion_surface': _ready(fusionSurface),
      'release_surface': _ready(releaseSurface),
      'unified_validation': _ready(unifiedValidation),
      'drift_gate': _ready(driftGate),
      'pre_commit_full': _ready(preCommitFull),
      'analyzer_autofix': _ready(analyzerAutoFix),
    };
    final List<String> missingSections =
        sectionsOk.entries
            .where((entry) => !entry.value)
            .map((entry) => entry.key)
            .toList()
          ..sort();
    final List<String> allKeys = <String>{
      ..._sortedKeys(v3Surface),
      ..._sortedKeys(v4Surface),
      ..._sortedKeys(cSeriesSurface),
      ..._sortedKeys(fusionSurface),
      ..._sortedKeys(releaseSurface),
      ..._sortedKeys(unifiedValidation),
      ..._sortedKeys(driftGate),
      ..._sortedKeys(preCommitFull),
      ..._sortedKeys(analyzerAutoFix),
    }.toList()..sort();
    final Map<String, Object> signatures = <String, Object>{
      'v3_surface': _signature(v3Surface, allKeys),
      'v4_surface': _signature(v4Surface, allKeys),
      'c_series_surface': _signature(cSeriesSurface, allKeys),
      'fusion_surface': _signature(fusionSurface, allKeys),
      'release_surface': _signature(releaseSurface, allKeys),
      'unified_validation': _signature(unifiedValidation, allKeys),
      'drift_gate': _signature(driftGate, allKeys),
      'pre_commit_full': _signature(preCommitFull, allKeys),
      'analyzer_autofix': _signature(analyzerAutoFix, allKeys),
    };
    final Map<String, Object> readyFlags = sectionsOk.map(
      (key, value) => MapEntry(_ascii(key), value),
    );
    final List<String> issues = _aggregateIssues(analyzerAutoFix);
    final bool overallOk = sectionsOk.values.every((value) => value);
    return <String, Object>{
      'health_dashboard_v13': <String, Object>{
        'sections_ok': sectionsOk,
        'missing_sections': missingSections,
        'signatures': signatures,
        'ready_flags': readyFlags,
        'overall_ok': overallOk,
        'issues': issues,
      },
    };
  }

  static Map<String, Object> _signature(
    Map<String, Object> source,
    List<String> allKeys,
  ) {
    final List<String> keys = _sortedKeys(source);
    final List<String> missingKeys =
        allKeys.where((key) => !source.containsKey(key)).toList()..sort();
    return <String, Object>{'keys': keys, 'missing_keys': missingKeys};
  }

  static List<String> _aggregateIssues(Map<String, Object> analyzerAutoFix) {
    final Object? payload = analyzerAutoFix['analyzer_autofix_engine_v1'];
    if (payload is! Map<String, Object>) return <String>[];
    final List<String> result = <String>{}.toList();
    for (final String category in <String>[
      'unused_import',
      'unused_field',
      'implicit_this',
      'undefined_identifier',
      'other',
    ]) {
      final Object? bucket = payload[category];
      if (bucket is Iterable) {
        for (final Object entry in bucket) {
          if (entry is Map<String, Object>) {
            final String file = _ascii(entry['file']?.toString() ?? '');
            final String line = _ascii(entry['line']?.toString() ?? '0');
            final String code = _ascii(entry['code']?.toString() ?? category);
            result.add('$category:$file:$line:$code');
          }
        }
      }
    }
    final Set<String> unique = result.toSet();
    final List<String> sorted = unique.toList()..sort();
    return sorted;
  }

  static bool _ready(Map<String, Object> map) {
    final Object? ready = map['ready'];
    if (ready is bool) return ready;
    return false;
  }

  static List<String> _sortedKeys(Map<String, Object> map) {
    return map.keys.whereType<String>().map(_ascii).toList()..sort();
  }

  static Map<String, Object> _safe(Map<String, Object?>? source) {
    if (source == null) return const <String, Object>{};
    final Map<String, Object> result = <String, Object>{};
    for (final MapEntry<String, Object?> entry in source.entries) {
      final String key = _ascii(entry.key);
      final Object value = entry.value is String
          ? _ascii(entry.value as String)
          : entry.value ?? '';
      result[key] = value;
    }
    return result;
  }

  static String _ascii(String input) =>
      String.fromCharCodes(input.codeUnits.where((c) => c >= 0 && c < 128));
}

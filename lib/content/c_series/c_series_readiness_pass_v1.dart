class CSeriesReadinessPassV1 {
  const CSeriesReadinessPassV1({
    required this.unifiedMap,
    required this.coldPathMap,
    required this.diagnosticsMap,
    required this.unifierMap,
    required this.previewMap,
    required this.runtimeMap,
  });

  final Map<String, Object> unifiedMap;
  final Map<String, Object> coldPathMap;
  final Map<String, Object> diagnosticsMap;
  final Map<String, Object> unifierMap;
  final Map<String, Object> previewMap;
  final Map<String, Object> runtimeMap;

  Map<String, Object> build() {
    final Map<String, bool> status = <String, bool>{
      'unified': _flag(unifiedMap, 'ready'),
      'cold_path': _flag(coldPathMap, 'ready'),
      'diagnostics': _flag(diagnosticsMap, 'ready'),
      'unifier': _flag(unifierMap, 'surface_ready'),
      'preview': _flag(previewMap, 'preview_ready'),
      'runtime': _flag(runtimeMap, 'runtime_ready'),
    };
    final List<String> missing =
        status.entries
            .where((entry) => !entry.value)
            .map((entry) => '${entry.key}_not_ready')
            .toList()
          ..sort();
    return <String, Object>{
      'c_series_readiness_pass_v1': <String, Object>{
        'version': 'v1',
        'unified_ok': status['unified']!,
        'cold_path_ok': status['cold_path']!,
        'diagnostics_ok': status['diagnostics']!,
        'unifier_ok': status['unifier']!,
        'preview_ok': status['preview']!,
        'runtime_ok': status['runtime']!,
        'missing': missing,
        'ready': false,
      },
    };
  }

  static bool _flag(Map<String, Object> source, String key) {
    final Object? value = source[key];
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value is String) {
      final String normalized = value.toLowerCase();
      return normalized == 'true' || normalized == '1';
    }
    return false;
  }
}

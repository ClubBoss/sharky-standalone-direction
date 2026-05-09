class CSeriesIntegrationSurfaceV1 {
  const CSeriesIntegrationSurfaceV1({
    required this.unifiedMap,
    required this.coldPathMap,
    required this.diagnosticsMap,
    required this.unifierMap,
    required this.previewMap,
    required this.runtimeMap,
    required this.readinessMap,
  });

  final Map<String, Object> unifiedMap;
  final Map<String, Object> coldPathMap;
  final Map<String, Object> diagnosticsMap;
  final Map<String, Object> unifierMap;
  final Map<String, Object> previewMap;
  final Map<String, Object> runtimeMap;
  final Map<String, Object> readinessMap;

  Map<String, Object> build() {
    final Map<String, bool> status = <String, bool>{
      'unified': _flag(readinessMap, 'unified_ok'),
      'cold_path': _flag(readinessMap, 'cold_path_ok'),
      'diagnostics': _flag(readinessMap, 'diagnostics_ok'),
      'unifier': _flag(readinessMap, 'unifier_ok'),
      'preview': _flag(readinessMap, 'preview_ok'),
      'runtime': _flag(readinessMap, 'runtime_ok'),
    };
    final List<String> missing =
        status.entries
            .where((entry) => !entry.value)
            .map((entry) => '${entry.key}_missing')
            .toList()
          ..sort();
    final bool allOk = status.values.every((value) => value);
    return <String, Object>{
      'c_series_integration_surface_v1': <String, Object>{
        'version': 'v1',
        'unified_ok': status['unified']!,
        'cold_path_ok': status['cold_path']!,
        'diagnostics_ok': status['diagnostics']!,
        'unifier_ok': status['unifier']!,
        'preview_ok': status['preview']!,
        'runtime_ok': status['runtime']!,
        'all_ok': allOk,
        'missing': missing,
        'ready': false,
      },
    };
  }

  static bool _flag(Map<String, Object> map, String key) {
    final Object? value = map[key];
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final String normalized = value.toLowerCase();
      return normalized == 'true' || normalized == '1';
    }
    return false;
  }
}

class CSeriesApexSurfaceV1 {
  const CSeriesApexSurfaceV1({
    required this.readinessMap,
    required this.integrationMap,
    required this.runtimeMap,
  });

  final Map<String, Object> readinessMap;
  final Map<String, Object> integrationMap;
  final Map<String, Object> runtimeMap;

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
      'c_series_apex_surface_v1': <String, Object>{
        'version': 'v1',
        'readiness': readinessMap,
        'integration': integrationMap,
        'runtime': runtimeMap,
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

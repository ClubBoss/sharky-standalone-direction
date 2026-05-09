class CSeriesUnifiedValidatorV1 {
  const CSeriesUnifiedValidatorV1({
    required this.coldPathMap,
    required this.diagnosticsMap,
    required this.unifierMap,
    required this.previewMap,
    required this.runtimeMap,
  });

  final Map<String, Object> coldPathMap;
  final Map<String, Object> diagnosticsMap;
  final Map<String, Object> unifierMap;
  final Map<String, Object> previewMap;
  final Map<String, Object> runtimeMap;

  Map<String, Object> validate() {
    final Map<String, bool> status = <String, bool>{
      'cold_path': _hasDiagnostics(coldPathMap),
      'diagnostics': _hasDiagnostics(diagnosticsMap),
      'unifier': _hasDiagnostics(unifierMap),
      'preview': _hasDiagnostics(previewMap),
      'runtime': _hasDiagnostics(runtimeMap),
    };
    final List<String> missing =
        status.entries
            .where((entry) => !entry.value)
            .map((entry) => '${entry.key}_missing_diagnostics')
            .toList()
          ..sort();
    return <String, Object>{
      'c_series_unified_validator_v1': <String, Object>{
        'version': 'v1',
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

  static bool _hasDiagnostics(Map<String, Object> source) {
    final Object? diagnostics = source['diagnostics'];
    return diagnostics is Map<String, Object> && diagnostics.isNotEmpty;
  }
}

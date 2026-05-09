class CSeriesColdPathValidatorV1 {
  const CSeriesColdPathValidatorV1({
    required this.loaderMap,
    required this.recapMap,
    required this.microQuizMap,
    required this.spacedRepetitionMap,
    required this.mixedCheckpointMap,
    required this.previewMap,
    required this.runtimeMap,
  });

  final Map<String, Object> loaderMap;
  final Map<String, Object> recapMap;
  final Map<String, Object> microQuizMap;
  final Map<String, Object> spacedRepetitionMap;
  final Map<String, Object> mixedCheckpointMap;
  final Map<String, Object> previewMap;
  final Map<String, Object> runtimeMap;

  Map<String, Object> validate() {
    final Map<String, bool> status = <String, bool>{
      'loader': _hasDiagnostics(loaderMap),
      'recap': _hasDiagnostics(recapMap),
      'micro_quiz': _hasDiagnostics(microQuizMap),
      'spaced_repetition': _hasDiagnostics(spacedRepetitionMap),
      'mixed_checkpoint': _hasDiagnostics(mixedCheckpointMap),
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
      'c_series_cold_path_validator_v1': <String, Object>{
        'version': 'v1',
        'loader_ok': status['loader']!,
        'recap_ok': status['recap']!,
        'micro_quiz_ok': status['micro_quiz']!,
        'spaced_repetition_ok': status['spaced_repetition']!,
        'mixed_checkpoint_ok': status['mixed_checkpoint']!,
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

class CSeriesDiagnosticsBridgeV1 {
  const CSeriesDiagnosticsBridgeV1({
    required this.loaderDiagnostics,
    required this.recapDiagnostics,
    required this.microQuizDiagnostics,
    required this.spacedRepetitionDiagnostics,
    required this.mixedCheckpointDiagnostics,
    required this.previewDiagnostics,
    required this.runtimeDiagnostics,
  });

  final Map<String, Object> loaderDiagnostics;
  final Map<String, Object> recapDiagnostics;
  final Map<String, Object> microQuizDiagnostics;
  final Map<String, Object> spacedRepetitionDiagnostics;
  final Map<String, Object> mixedCheckpointDiagnostics;
  final Map<String, Object> previewDiagnostics;
  final Map<String, Object> runtimeDiagnostics;

  Map<String, Object> build() => <String, Object>{
    'c_series_diagnostics_bridge_v1': <String, Object>{
      'version': 'v1',
      'loader': loaderDiagnostics,
      'recap': recapDiagnostics,
      'micro_quiz': microQuizDiagnostics,
      'spaced_repetition': spacedRepetitionDiagnostics,
      'mixed_checkpoint': mixedCheckpointDiagnostics,
      'preview': previewDiagnostics,
      'runtime': runtimeDiagnostics,
      'diagnostics_ready': false,
    },
  };

  Map<String, Object> diagnostics() => <String, Object>{
    'c_series_diagnostics_bridge_v1': <String, Object>{
      'ready': false,
      'component_counts': <String, int>{
        'loader': loaderDiagnostics.length,
        'recap': recapDiagnostics.length,
        'micro_quiz': microQuizDiagnostics.length,
        'spaced_repetition': spacedRepetitionDiagnostics.length,
        'mixed_checkpoint': mixedCheckpointDiagnostics.length,
        'preview': previewDiagnostics.length,
        'runtime': runtimeDiagnostics.length,
      },
    },
  };
}

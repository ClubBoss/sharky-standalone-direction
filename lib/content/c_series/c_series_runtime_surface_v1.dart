class CSeriesRuntimeSurfaceV1 {
  const CSeriesRuntimeSurfaceV1({
    required this.loaderMap,
    required this.recapMap,
    required this.microQuizMap,
    required this.spacedRepetitionMap,
    required this.mixedCheckpointMap,
    required this.previewMap,
    required this.metadataIndexMap,
    required this.recommendationMap,
  });

  final Map<String, Object> loaderMap;
  final Map<String, Object> recapMap;
  final Map<String, Object> microQuizMap;
  final Map<String, Object> spacedRepetitionMap;
  final Map<String, Object> mixedCheckpointMap;
  final Map<String, Object> previewMap;
  final Map<String, Object> metadataIndexMap;
  final Map<String, Object> recommendationMap;

  Map<String, Object> build() => <String, Object>{
    'c_series_runtime_surface_v1': <String, Object>{
      'version': 'v1',
      'preview': previewMap,
      'modules': _list(loaderMap['modules']),
      'recaps': _list(recapMap['recaps']),
      'micro_quizzes': _list(microQuizMap['micro_quizzes']),
      'spaced_repetition': _list(spacedRepetitionMap['spaced_repetition']),
      'mixed_checkpoints': _list(mixedCheckpointMap['mixed_checkpoints']),
      'metadata': metadataIndexMap,
      'recommendations': recommendationMap,
      'runtime_ready': false,
    },
  };

  Map<String, Object> diagnostics() => <String, Object>{
    'c_series_runtime_surface_v1': <String, Object>{
      'ready': false,
      'counts': <String, Object>{
        'modules': _list(loaderMap['modules']).length,
        'recaps': _list(recapMap['recaps']).length,
        'micro_quizzes': _list(microQuizMap['micro_quizzes']).length,
        'spaced_repetition': _list(
          spacedRepetitionMap['spaced_repetition'],
        ).length,
        'mixed_checkpoints': _list(
          mixedCheckpointMap['mixed_checkpoints'],
        ).length,
      },
    },
  };

  static List<String> _list(Object? value) {
    if (value is List) {
      final List<String> result = <String>[];
      for (final Object? entry in value) {
        if (entry is String) {
          result.add(entry);
        }
      }
      return result;
    }
    return <String>[];
  }
}

class CSeriesPersonaRecommendationV1 {
  const CSeriesPersonaRecommendationV1({
    required this.metadataIndexMap,
    required this.personaId,
  });

  final Map<String, Object> metadataIndexMap;
  final String personaId;

  Map<String, Object> build() {
    final Map<String, Object> index = _mapFromKey(
      metadataIndexMap,
      'c_series_metadata_index_v1',
    );
    return <String, Object>{
      'c_series_persona_recommendation_v1': <String, Object>{
        'version': 'v1',
        'persona_id': personaId,
        'modules': _subset(index['modules']),
        'recaps': _subset(index['recaps']),
        'micro_quizzes': _subset(index['micro_quizzes']),
        'spaced_repetition': _subset(index['spaced_repetition']),
        'mixed_checkpoints': _subset(index['mixed_checkpoints']),
        'recommendation_ready': false,
      },
    };
  }

  Map<String, Object> diagnostics() {
    final Map<String, Object> index = _mapFromKey(
      metadataIndexMap,
      'c_series_metadata_index_v1',
    );
    return <String, Object>{
      'c_series_persona_recommendation_v1': <String, Object>{
        'ready': false,
        'counts': <String, Object>{
          'modules': _listLength(index['modules']),
          'recaps': _listLength(index['recaps']),
          'micro_quizzes': _listLength(index['micro_quizzes']),
          'spaced_repetition': _listLength(index['spaced_repetition']),
          'mixed_checkpoints': _listLength(index['mixed_checkpoints']),
        },
      },
    };
  }

  static List<String> _subset(Object? value) {
    if (value is List) {
      final List<String> filtered = <String>[];
      for (int i = 0; i < value.length; i += 2) {
        final Object? entry = value[i];
        if (entry is String) {
          filtered.add(entry);
        }
      }
      return filtered;
    }
    return <String>[];
  }

  static int _listLength(Object? value) {
    if (value is List) {
      return value.length;
    }
    return 0;
  }

  static Map<String, Object> _mapFromKey(
    Map<String, Object> source,
    String key,
  ) {
    final Object? value = source[key];
    if (value is Map<String, Object>) {
      return value;
    }
    return <String, Object>{};
  }
}

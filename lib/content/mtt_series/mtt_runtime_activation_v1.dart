class MTTRuntimeActivationV1 {
  const MTTRuntimeActivationV1();

  static Map<String, Object> build({
    required Map<String, Object> loaderMap,
    required Map<String, Object> recapMap,
    required Map<String, Object> quizMap,
    required Map<String, Object> metadataIndexMap,
    required Map<String, Object> recommendationMap,
  }) {
    final Map<String, bool> sections = <String, bool>{
      'loader': _ready(loaderMap),
      'recap': _ready(recapMap),
      'quiz': _ready(quizMap),
      'metadata_index': _ready(metadataIndexMap),
      'recommendation': _ready(recommendationMap),
    };
    final List<String> missingSections =
        sections.entries
            .where((entry) => !entry.value)
            .map((entry) => entry.key)
            .toList()
          ..sort();
    final Map<String, Object> signatures = <String, Object>{
      'loader_keys': _sortedKeys(loaderMap),
      'recap_keys': _sortedKeys(recapMap),
      'quiz_keys': _sortedKeys(quizMap),
      'metadata_index_keys': _sortedKeys(metadataIndexMap),
      'recommendation_keys': _sortedKeys(recommendationMap),
    };
    return <String, Object>{
      'mtt_runtime_activation_v1': <String, Object>{
        'activation_ready': false,
        'sections_ok': sections,
        'missing_sections': missingSections,
        'signatures': signatures,
        'ready': false,
      },
    };
  }

  static bool _ready(Map<String, Object> map) {
    final Object? flag = map['ready'];
    return flag is bool && flag;
  }

  static List<String> _sortedKeys(Map<String, Object> map) {
    final List<String> keys = map.keys.whereType<String>().toList()..sort();
    return keys;
  }
}

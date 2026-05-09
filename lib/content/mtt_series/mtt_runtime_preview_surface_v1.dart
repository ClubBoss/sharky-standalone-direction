class MTTRuntimePreviewSurfaceV1 {
  const MTTRuntimePreviewSurfaceV1();

  static Map<String, Object> build({
    required Map<String, Object> activationMap,
    required Map<String, Object> metadataIndexMap,
    required Map<String, Object> recapMap,
    required Map<String, Object> quizMap,
  }) {
    final Map<String, bool> sections = <String, bool>{
      'activation': _ready(activationMap),
      'metadata_index': _ready(metadataIndexMap),
      'recap': _ready(recapMap),
      'quiz': _ready(quizMap),
    };
    final List<String> missingSections =
        sections.entries
            .where((entry) => !entry.value)
            .map((entry) => entry.key)
            .toList()
          ..sort();
    final bool previewReady = sections.values.every((value) => value);
    final Map<String, Object> signatures = <String, Object>{
      'activation_keys': _sortedKeys(activationMap),
      'metadata_index_keys': _sortedKeys(metadataIndexMap),
      'recap_keys': _sortedKeys(recapMap),
      'quiz_keys': _sortedKeys(quizMap),
    };
    return <String, Object>{
      'mtt_runtime_preview_surface_v1': <String, Object>{
        'preview_ready': previewReady,
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

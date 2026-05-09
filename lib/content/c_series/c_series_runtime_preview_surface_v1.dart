class CSeriesRuntimePreviewSurfaceV1 {
  const CSeriesRuntimePreviewSurfaceV1();

  static Map<String, Object> build({
    required Map<String, Object> activationMap,
    required Map<String, Object> apexSurfaceMap,
    required Map<String, Object> integrationSurfaceMap,
    required Map<String, Object> metadataIndexMap,
    required Map<String, Object> personaRecommendationMap,
  }) {
    final Map<String, bool> sections = <String, bool>{
      'activation_map': _ready(activationMap),
      'apex_surface_map': _ready(apexSurfaceMap),
      'integration_surface_map': _ready(integrationSurfaceMap),
      'metadata_index_map': _ready(metadataIndexMap),
      'persona_recommendation_map': _ready(personaRecommendationMap),
    };
    final List<String> missingSections =
        sections.entries
            .where((entry) => !entry.value)
            .map((entry) => entry.key)
            .toList()
          ..sort();
    final Map<String, Object> signature = <String, Object>{
      'activation_keys': _sortedKeys(activationMap),
      'apex_surface_keys': _sortedKeys(apexSurfaceMap),
      'integration_surface_keys': _sortedKeys(integrationSurfaceMap),
      'metadata_index_keys': _sortedKeys(metadataIndexMap),
      'persona_recommendation_keys': _sortedKeys(personaRecommendationMap),
    };
    final bool ready = sections.values.every((value) => value);
    return <String, Object>{
      'c_series_runtime_preview_surface_v1': <String, Object>{
        'ready': ready,
        'sections_ok': sections,
        'missing_sections': missingSections,
        'signature': signature,
      },
    };
  }

  static bool _ready(Map<String, Object> map) {
    final Object? ready = map['ready'];
    return ready is bool && ready;
  }

  static List<String> _sortedKeys(Map<String, Object> map) {
    final List<String> keys = map.keys.whereType<String>().toList()..sort();
    return keys;
  }
}

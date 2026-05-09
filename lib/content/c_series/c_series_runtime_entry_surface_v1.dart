class CSeriesRuntimeEntrySurfaceV1 {
  const CSeriesRuntimeEntrySurfaceV1();

  static Map<String, Object> build({
    required Map<String, Object> runtimeActivation,
    required Map<String, Object> apexSurface,
    required Map<String, Object> integrationSurface,
    required Map<String, Object> metadataIndex,
    required Map<String, Object> personaRecommendation,
    required Map<String, Object> runtimePreview,
  }) {
    final Map<String, bool> sections = <String, bool>{
      'runtime_activation': _ready(runtimeActivation),
      'apex_surface': _ready(apexSurface),
      'integration_surface': _ready(integrationSurface),
      'metadata_index': _ready(metadataIndex),
      'persona_recommendation': _ready(personaRecommendation),
      'runtime_preview': _ready(runtimePreview),
    };
    final List<String> missingSections =
        sections.entries
            .where((entry) => !entry.value)
            .map((entry) => entry.key)
            .toList()
          ..sort();
    final bool runtimeReady = sections.values.every((value) => value);
    final Map<String, Object> signatures = <String, Object>{
      'runtime_activation_keys': _sortedKeys(runtimeActivation),
      'apex_surface_keys': _sortedKeys(apexSurface),
      'integration_surface_keys': _sortedKeys(integrationSurface),
      'metadata_index_keys': _sortedKeys(metadataIndex),
      'persona_recommendation_keys': _sortedKeys(personaRecommendation),
      'runtime_preview_keys': _sortedKeys(runtimePreview),
    };
    return <String, Object>{
      'c_series_runtime_entry_surface_v1': <String, Object>{
        'runtime_ready': runtimeReady,
        'sections_ok': sections,
        'signatures': signatures,
        'missing_sections': missingSections,
        'ready': false,
      },
    };
  }

  static bool _ready(Map<String, Object> map) {
    final Object? value = map['ready'];
    if (value is bool) return value;
    return false;
  }

  static List<String> _sortedKeys(Map<String, Object> map) {
    final List<String> keys = map.keys.whereType<String>().toList()..sort();
    return keys;
  }
}

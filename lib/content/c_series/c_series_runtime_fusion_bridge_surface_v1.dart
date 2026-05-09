class CSeriesRuntimeFusionBridgeSurfaceV1 {
  const CSeriesRuntimeFusionBridgeSurfaceV1();

  static Map<String, Object> build({
    required Map<String, Object> runtimeActivation,
    required Map<String, Object> runtimePreview,
    required Map<String, Object> runtimeEntry,
    required Map<String, Object> apexSurface,
    required Map<String, Object> integrationSurface,
    required Map<String, Object> metadataIndex,
    required Map<String, Object> personaRecommendation,
  }) {
    final Map<String, bool> sections = <String, bool>{
      'runtime_activation': _ready(runtimeActivation),
      'runtime_preview': _ready(runtimePreview),
      'runtime_entry': _ready(runtimeEntry),
      'apex_surface': _ready(apexSurface),
      'integration_surface': _ready(integrationSurface),
      'metadata_index': _ready(metadataIndex),
      'persona_recommendation': _ready(personaRecommendation),
    };
    final List<String> missingSections =
        sections.entries
            .where((entry) => !entry.value)
            .map((entry) => entry.key)
            .toList()
          ..sort();
    final bool fusionReady = sections.values.every((value) => value);
    final Map<String, Object> signatures = <String, Object>{
      'runtime_activation_keys': _sortedKeys(runtimeActivation),
      'runtime_preview_keys': _sortedKeys(runtimePreview),
      'runtime_entry_keys': _sortedKeys(runtimeEntry),
      'apex_surface_keys': _sortedKeys(apexSurface),
      'integration_surface_keys': _sortedKeys(integrationSurface),
      'metadata_index_keys': _sortedKeys(metadataIndex),
      'persona_recommendation_keys': _sortedKeys(personaRecommendation),
    };
    return <String, Object>{
      'c_series_runtime_fusion_bridge_surface_v1': <String, Object>{
        'fusion_ready': fusionReady,
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

class CSeriesRuntimeActivationV1 {
  const CSeriesRuntimeActivationV1();

  static Map<String, Object> build({
    required Map<String, Object> apexSurface,
    required Map<String, Object> integrationSurface,
    required Map<String, Object> runtimeSurface,
    required Map<String, Object> readinessPass,
    required Map<String, Object> unifiedValidator,
    required Map<String, Object> metadataIndex,
    required Map<String, Object> personaRecommendation,
  }) {
    final Map<String, bool> sections = <String, bool>{
      'apex_surface': _isReady(apexSurface),
      'integration_surface': _isReady(integrationSurface),
      'runtime_surface': _isReady(runtimeSurface),
      'readiness_pass': _isReady(readinessPass),
      'unified_validator': _isReady(unifiedValidator),
      'metadata_index': _isReady(metadataIndex),
      'persona_recommendation': _isReady(personaRecommendation),
    };
    final List<String> missingSections =
        sections.entries
            .where((entry) => !entry.value)
            .map((entry) => entry.key)
            .toList()
          ..sort();
    final bool activationReady = sections.values.every((value) => value);
    final Map<String, Object> signatures = <String, Object>{
      'apex_surface_keys': _sortedKeys(apexSurface),
      'integration_surface_keys': _sortedKeys(integrationSurface),
      'runtime_surface_keys': _sortedKeys(runtimeSurface),
      'readiness_pass_keys': _sortedKeys(readinessPass),
      'unified_validator_keys': _sortedKeys(unifiedValidator),
      'metadata_index_keys': _sortedKeys(metadataIndex),
      'persona_recommendation_keys': _sortedKeys(personaRecommendation),
    };
    return <String, Object>{
      'c_series_runtime_activation_v1': <String, Object>{
        'activation_ready': activationReady,
        'sections_ok': sections,
        'missing_sections': missingSections,
        'signatures': signatures,
        'ready': false,
      },
    };
  }

  static bool _isReady(Map<String, Object> map) {
    final Object? value = map['ready'];
    if (value is bool) {
      return value;
    }
    return false;
  }

  static List<String> _sortedKeys(Map<String, Object> map) {
    final List<String> keys = map.keys.whereType<String>().toList()..sort();
    return keys;
  }
}

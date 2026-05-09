class FusionFinalStabilizationV1 {
  const FusionFinalStabilizationV1();

  static Map<String, Object> buildFusionFinalStabilizationV1({
    required Map<String, Object> fusionGlobalContext,
    required Map<String, Object> fusionIntegrationBridge,
    required Map<String, Object> fusionPersonaAdapter,
    required Map<String, Object> fusionThemeOverrides,
  }) {
    final List<String> globalSignature = _sortedKeys(fusionGlobalContext);
    final List<String> integrationSignature = _sortedKeys(
      fusionIntegrationBridge,
    );
    final List<String> personaSignature = _sortedKeys(fusionPersonaAdapter);
    final List<String> overrideSignature = _sortedKeys(fusionThemeOverrides);
    final List<String> mergedSignature = <String>{
      ...globalSignature,
      ...integrationSignature,
      ...personaSignature,
      ...overrideSignature,
    }.toList()..sort();
    final List<String> missingSections = <String>[];
    if (!_ready(fusionGlobalContext))
      missingSections.add('fusion_global_context_v1');
    if (!_ready(fusionIntegrationBridge))
      missingSections.add('fusion_integration_bridge_v1');
    if (!_ready(fusionPersonaAdapter))
      missingSections.add('fusion_persona_adapter_v1');
    if (!_ready(fusionThemeOverrides))
      missingSections.add('fusion_theme_overrides_v1');
    missingSections.sort();
    return <String, Object>{
      'fusion_final_stabilization_v1': <String, Object>{
        'global_signature': globalSignature,
        'integration_signature': integrationSignature,
        'persona_signature': personaSignature,
        'override_signature': overrideSignature,
        'merged_signature': mergedSignature,
        'missing_sections': missingSections,
        'fusion_stable': false,
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

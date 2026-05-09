class FusionPersonaAdapterV1 {
  const FusionPersonaAdapterV1();

  static Map<String, Object> buildFusionPersonaAdapterV1({
    required Map<String, Object> personaContextV4,
    required Map<String, Object> fusionGlobalContext,
    required Map<String, Object> fusionIntegrationBridge,
  }) {
    final List<String> personaSignature = _sortedKeys(personaContextV4);
    final List<String> fusionSignature = _sortedKeys(fusionGlobalContext);
    final List<String> bridgeSignature = _sortedKeys(fusionIntegrationBridge);
    final List<String> mergedSignature = <String>{
      ...personaSignature,
      ...fusionSignature,
      ...bridgeSignature,
    }.toList()..sort();
    final List<String> missingSections = <String>[];
    if (!_ready(personaContextV4)) missingSections.add('persona_context_v4');
    if (!_ready(fusionGlobalContext))
      missingSections.add('fusion_global_context_v1');
    if (!_ready(fusionIntegrationBridge))
      missingSections.add('fusion_integration_bridge_v1');
    missingSections.sort();
    return <String, Object>{
      'fusion_persona_adapter_v1': <String, Object>{
        'persona_ready': false,
        'fusion_ready': false,
        'adapter_ready': false,
        'persona_signature': personaSignature,
        'fusion_signature': fusionSignature,
        'bridge_signature': bridgeSignature,
        'merged_signature': mergedSignature,
        'missing_sections': missingSections,
        'ready': false,
      },
    };
  }

  static bool _ready(Map<String, Object> map) {
    final Object? value = map['ready'];
    return value is bool && value;
  }

  static List<String> _sortedKeys(Map<String, Object> map) {
    final List<String> keys = map.keys.whereType<String>().toList()..sort();
    return keys;
  }
}

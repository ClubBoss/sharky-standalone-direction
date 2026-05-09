class FusionThemeOverridesV1 {
  const FusionThemeOverridesV1();

  static Map<String, Object> buildFusionThemeOverridesV1({
    required Map<String, Object> personaContextV4,
    required Map<String, Object> fusionGlobalContext,
    required Map<String, Object> fusionPersonaAdapter,
  }) {
    final List<String> personaSignature = _sortedKeys(personaContextV4);
    final List<String> fusionSignature = _sortedKeys(fusionGlobalContext);
    final List<String> adapterSignature = _sortedKeys(fusionPersonaAdapter);
    final List<String> merged = <String>{
      ...personaSignature,
      ...fusionSignature,
      ...adapterSignature,
    }.toList()..sort();
    final List<String> missingSections = <String>[];
    if (!_ready(personaContextV4)) missingSections.add('persona_context_v4');
    if (!_ready(fusionGlobalContext))
      missingSections.add('fusion_global_context_v1');
    if (!_ready(fusionPersonaAdapter))
      missingSections.add('fusion_persona_adapter_v1');
    missingSections.sort();
    return <String, Object>{
      'fusion_theme_overrides_v1': <String, Object>{
        'persona_signature': personaSignature,
        'fusion_signature': fusionSignature,
        'adapter_signature': adapterSignature,
        'merged_signature': merged,
        'missing_sections': missingSections,
        'theme_overrides': <String, Object>{
          'use_dark': false,
          'use_light': false,
          'use_persona_pref': false,
        },
        'theme_ready': false,
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

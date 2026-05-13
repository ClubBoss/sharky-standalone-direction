/// Passive light modulation adapter for personalization (Phi-16).
class AIPersonalizationLightModulationV1 {
  const AIPersonalizationLightModulationV1(this.modulationAlphaMap);

  final Map<String, Object> modulationAlphaMap;

  Map<String, Object> run() {
    final bool hasAlpha = modulationAlphaMap.isNotEmpty;
    final Map<String, Object> lightModulationMap = <String, Object>{};
    final List<String> lightMissing = <String>[];

    void _pick(String sourceKey, String targetKey) {
      if (modulationAlphaMap.containsKey(sourceKey)) {
        final Object value = modulationAlphaMap[sourceKey] as Object;
        lightModulationMap[targetKey] = value;
        if (value == '' ||
            value == [] ||
            value == <Object>[] ||
            value == <String, Object>{}) {
          lightMissing.add(targetKey);
        }
      } else {
        lightMissing.add(targetKey);
      }
    }

    _pick('alpha_persona', 'light_persona');
    _pick('alpha_consistency', 'light_consistency');
    _pick('alpha_aggregate', 'light_aggregate');
    _pick('alpha_tier_a', 'light_tier_a');

    final bool lightReady = hasAlpha && lightMissing.isEmpty;

    return <String, Object>{
      'has_alpha': hasAlpha,
      'light_missing': lightMissing,
      'light_modulation_map': lightModulationMap,
      'light_ready': lightReady,
    };
  }
}

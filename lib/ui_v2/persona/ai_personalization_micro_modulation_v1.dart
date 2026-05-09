/// Passive micro-modulation adapter for personalization (Phi-17).
class AIPersonalizationMicroModulationV1 {
  const AIPersonalizationMicroModulationV1(this.lightModulationMap);

  final Map<String, Object> lightModulationMap;

  Map<String, Object> run() {
    final bool hasLight = lightModulationMap.isNotEmpty;
    final Map<String, Object> microModulationMap = <String, Object>{};
    final List<String> microMissing = <String>[];

    void _pick(String sourceKey, String targetKey) {
      if (lightModulationMap.containsKey(sourceKey)) {
        final Object value = lightModulationMap[sourceKey] as Object;
        microModulationMap[targetKey] = value;
        if (value == '' ||
            value == [] ||
            value == <Object>[] ||
            value == <String, Object>{}) {
          microMissing.add(targetKey);
        }
      } else {
        microMissing.add(targetKey);
      }
    }

    _pick('light_persona', 'micro_persona');
    _pick('light_consistency', 'micro_consistency');
    _pick('light_aggregate', 'micro_aggregate');
    _pick('light_tier_a', 'micro_tier_a');

    final bool microReady = hasLight && microMissing.isEmpty;

    return <String, Object>{
      'has_light': hasLight,
      'micro_missing': microMissing,
      'micro_modulation_map': microModulationMap,
      'micro_ready': microReady,
    };
  }
}

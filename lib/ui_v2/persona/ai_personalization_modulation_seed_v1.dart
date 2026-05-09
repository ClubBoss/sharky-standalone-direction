/// Passive modulation seed generator for personalization (Phi-14).
class AIPersonalizationModulationSeedV1 {
  const AIPersonalizationModulationSeedV1(this.preModulationMap);

  final Map<String, Object> preModulationMap;

  Map<String, Object> run() {
    final bool hasPreModulation = preModulationMap.isNotEmpty;
    final Map<String, Object> modulationSeedMap = <String, Object>{};
    final List<String> seedMissing = <String>[];

    void _pick(String sourceKey, String targetKey) {
      if (preModulationMap.containsKey(sourceKey)) {
        final Object value = preModulationMap[sourceKey] as Object;
        modulationSeedMap[targetKey] = value;
        if (value == '' ||
            value == [] ||
            value == <Object>[] ||
            value == <String, Object>{}) {
          seedMissing.add(targetKey);
        }
      } else {
        seedMissing.add(targetKey);
      }
    }

    _pick('pm_persona', 'seed_persona');
    _pick('pm_consistency', 'seed_consistency');
    _pick('pm_aggregate', 'seed_aggregate');
    _pick('pm_tier_a', 'seed_tier_a');

    final bool seedReady = hasPreModulation && seedMissing.isEmpty;

    return <String, Object>{
      'has_pre_modulation': hasPreModulation,
      'seed_missing': seedMissing,
      'modulation_seed_map': modulationSeedMap,
      'seed_ready': seedReady,
    };
  }
}

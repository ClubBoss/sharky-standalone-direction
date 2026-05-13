/// Passive modulation alpha adapter for personalization (Phi-15).
class AIPersonalizationModulationAlphaV1 {
  const AIPersonalizationModulationAlphaV1(this.modulationSeedMap);

  final Map<String, Object> modulationSeedMap;

  Map<String, Object> run() {
    final bool hasSeed = modulationSeedMap.isNotEmpty;
    final Map<String, Object> modulationAlphaMap = <String, Object>{};
    final List<String> alphaMissing = <String>[];

    void _pick(String sourceKey, String targetKey) {
      if (modulationSeedMap.containsKey(sourceKey)) {
        final Object value = modulationSeedMap[sourceKey] as Object;
        modulationAlphaMap[targetKey] = value;
        if (value == '' ||
            value == [] ||
            value == <Object>[] ||
            value == <String, Object>{}) {
          alphaMissing.add(targetKey);
        }
      } else {
        alphaMissing.add(targetKey);
      }
    }

    _pick('seed_persona', 'alpha_persona');
    _pick('seed_consistency', 'alpha_consistency');
    _pick('seed_aggregate', 'alpha_aggregate');
    _pick('seed_tier_a', 'alpha_tier_a');

    final bool alphaReady = hasSeed && alphaMissing.isEmpty;

    return <String, Object>{
      'has_seed': hasSeed,
      'alpha_missing': alphaMissing,
      'modulation_alpha_map': modulationAlphaMap,
      'alpha_ready': alphaReady,
    };
  }
}

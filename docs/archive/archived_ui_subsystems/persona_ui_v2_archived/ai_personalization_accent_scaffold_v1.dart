/// Passive adaptive accent scaffold generator (Phi-18).
class AIPersonalizationAccentScaffoldV1 {
  const AIPersonalizationAccentScaffoldV1(this.microModulationMap);

  final Map<String, Object> microModulationMap;

  Map<String, Object> run() {
    final bool hasMicro = microModulationMap.isNotEmpty;
    final Map<String, Object> accentScaffoldMap = <String, Object>{};
    final List<String> accentMissing = <String>[];

    void _pick(String sourceKey, String targetKey) {
      if (microModulationMap.containsKey(sourceKey)) {
        final Object value = microModulationMap[sourceKey] as Object;
        accentScaffoldMap[targetKey] = value;
        if (value == '' ||
            value == [] ||
            value == <Object>[] ||
            value == <String, Object>{}) {
          accentMissing.add(targetKey);
        }
      } else {
        accentMissing.add(targetKey);
      }
    }

    _pick('micro_persona', 'accent_persona');
    _pick('micro_consistency', 'accent_consistency');
    _pick('micro_aggregate', 'accent_aggregate');
    _pick('micro_tier_a', 'accent_tier_a');

    final bool accentReady = hasMicro && accentMissing.isEmpty;

    return <String, Object>{
      'has_micro': hasMicro,
      'accent_missing': accentMissing,
      'accent_scaffold_map': accentScaffoldMap,
      'accent_ready': accentReady,
    };
  }
}

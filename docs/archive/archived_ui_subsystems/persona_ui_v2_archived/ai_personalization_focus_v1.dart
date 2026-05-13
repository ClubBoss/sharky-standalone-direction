/// Passive focus weighting adapter for personalization (Phi-20).
class AIPersonalizationFocusV1 {
  const AIPersonalizationFocusV1(this.tempoMap);

  final Map<String, Object> tempoMap;

  Map<String, Object> run() {
    final bool hasTempo = tempoMap.isNotEmpty;
    final Map<String, Object> focusWeightMap = <String, Object>{};
    final List<String> focusMissing = <String>[];

    void _pick(String sourceKey, String targetKey) {
      if (tempoMap.containsKey(sourceKey)) {
        final Object value = tempoMap[sourceKey] as Object;
        focusWeightMap[targetKey] = value;
        if (value == '' ||
            value == [] ||
            value == <Object>[] ||
            value == <String, Object>{}) {
          focusMissing.add(targetKey);
        }
      } else {
        focusMissing.add(targetKey);
      }
    }

    _pick('tempo_persona', 'focus_persona');
    _pick('tempo_consistency', 'focus_consistency');
    _pick('tempo_aggregate', 'focus_aggregate');
    _pick('tempo_tier_a', 'focus_tier_a');

    final bool focusReady = hasTempo && focusMissing.isEmpty;

    return <String, Object>{
      'has_tempo': hasTempo,
      'focus_missing': focusMissing,
      'focus_weight_map': focusWeightMap,
      'focus_ready': focusReady,
    };
  }
}

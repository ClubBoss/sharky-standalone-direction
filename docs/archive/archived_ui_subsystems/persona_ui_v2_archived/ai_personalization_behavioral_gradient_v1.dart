/// Passive behavioral gradient adapter for personalization (Phi-32).
class AIPersonalizationBehavioralGradientV1 {
  const AIPersonalizationBehavioralGradientV1(this.uiPersonalityHintsMap);

  final Map<String, Object> uiPersonalityHintsMap;

  Map<String, Object> run() {
    final bool hasUiPersonality = uiPersonalityHintsMap.isNotEmpty;
    final Map<String, Object> behavioralGradientMap = <String, Object>{};
    final List<String> bgMissing = <String>[];

    void _pick(String sourceKey, String targetKey) {
      if (uiPersonalityHintsMap.containsKey(sourceKey)) {
        final Object value = uiPersonalityHintsMap[sourceKey] as Object;
        behavioralGradientMap[targetKey] = value;
        if (value == '' ||
            value == [] ||
            value == <Object>[] ||
            value == <String, Object>{}) {
          bgMissing.add(targetKey);
        }
      } else {
        bgMissing.add(targetKey);
      }
    }

    _pick('uph_accent', 'bg_accent');
    _pick('uph_scaling', 'bg_scaling');
    _pick('uph_tierA', 'bg_tierA');
    _pick('uph_tierB', 'bg_tierB');

    final bool bgReady = hasUiPersonality && bgMissing.isEmpty;

    return <String, Object>{
      'has_ui_personality': hasUiPersonality,
      'bg_missing': bgMissing,
      'behavioral_gradient_map': behavioralGradientMap,
      'bg_ready': bgReady,
    };
  }
}

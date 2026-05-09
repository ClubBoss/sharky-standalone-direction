/// Passive accent lift adapter for personalization (Phi-33).
class AIPersonalizationAccentLiftV1 {
  const AIPersonalizationAccentLiftV1(this.behavioralGradientMap);

  final Map<String, Object> behavioralGradientMap;

  Map<String, Object> run() {
    final bool hasGradient = behavioralGradientMap.isNotEmpty;
    final Map<String, Object> accentLiftMap = <String, Object>{};
    final List<String> accentLiftMissing = <String>[];

    void _pick(String sourceKey, String targetKey) {
      if (behavioralGradientMap.containsKey(sourceKey)) {
        final Object value = behavioralGradientMap[sourceKey] as Object;
        accentLiftMap[targetKey] = value;
        if (value == '' ||
            value == [] ||
            value == <Object>[] ||
            value == <String, Object>{}) {
          accentLiftMissing.add(targetKey);
        }
      } else {
        accentLiftMissing.add(targetKey);
      }
    }

    _pick('bg_accent', 'al_accent');
    _pick('bg_scaling', 'al_scaling');
    _pick('bg_tierA', 'al_tierA');
    _pick('bg_tierB', 'al_tierB');
    accentLiftMap['al_factor'] = 0.03;

    final bool accentLiftReady = hasGradient && accentLiftMissing.isEmpty;

    return <String, Object>{
      'has_gradient': hasGradient,
      'accent_lift_missing': accentLiftMissing,
      'accent_lift_map': accentLiftMap,
      'accent_lift_ready': accentLiftReady,
    };
  }
}

/// Passive accent application v2 adapter for personalization (Phi-34).
class AIPersonalizationAccentApplicationV2 {
  const AIPersonalizationAccentApplicationV2(this.accentLiftMap);

  final Map<String, Object> accentLiftMap;

  Map<String, Object> run() {
    final bool hasAccentLift = accentLiftMap.isNotEmpty;
    final Map<String, Object> uiAccentIntentMap = <String, Object>{};
    final List<String> accentAppV2Missing = <String>[];

    void _pick(String sourceKey, String targetKey) {
      if (accentLiftMap.containsKey(sourceKey)) {
        final Object value = accentLiftMap[sourceKey] as Object;
        uiAccentIntentMap[targetKey] = value;
        if (value == '' ||
            value == [] ||
            value == <Object>[] ||
            value == <String, Object>{}) {
          accentAppV2Missing.add(targetKey);
        }
      } else {
        accentAppV2Missing.add(targetKey);
      }
    }

    _pick('al_accent', 'uai_accent');
    _pick('al_scaling', 'uai_scaling');
    _pick('al_tierA', 'uai_tierA');
    _pick('al_tierB', 'uai_tierB');
    _pick('al_factor', 'uai_factor');

    final bool accentAppV2Ready = hasAccentLift && accentAppV2Missing.isEmpty;

    return <String, Object>{
      'has_accent_lift': hasAccentLift,
      'accent_app_v2_missing': accentAppV2Missing,
      'ui_accent_intent_map': uiAccentIntentMap,
      'accent_app_v2_ready': accentAppV2Ready,
    };
  }
}

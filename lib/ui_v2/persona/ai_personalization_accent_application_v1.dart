/// Passive accent application adapter for personalization (Phi-22).
class AIPersonalizationAccentApplicationV1 {
  const AIPersonalizationAccentApplicationV1(this.adaptiveUIMap);

  final Map<String, Object> adaptiveUIMap;

  Map<String, Object> run() {
    final bool hasAdaptive = adaptiveUIMap.isNotEmpty;
    final Map<String, Object> accentApplicationMap = <String, Object>{};
    final List<String> accentAppMissing = <String>[];

    void _pick(String sourceKey, String targetKey) {
      if (adaptiveUIMap.containsKey(sourceKey)) {
        final Object value = adaptiveUIMap[sourceKey] as Object;
        accentApplicationMap[targetKey] = value;
        if (value == '' ||
            value == [] ||
            value == <Object>[] ||
            value == <String, Object>{}) {
          accentAppMissing.add(targetKey);
        }
      } else {
        accentAppMissing.add(targetKey);
      }
    }

    _pick('ui_accent', 'app_accent');
    _pick('ui_tempo', 'app_tempo');
    _pick('ui_focus', 'app_focus');

    final bool accentAppReady = hasAdaptive && accentAppMissing.isEmpty;

    return <String, Object>{
      'has_adaptive': hasAdaptive,
      'accent_app_missing': accentAppMissing,
      'accent_application_map': accentApplicationMap,
      'accent_app_ready': accentAppReady,
    };
  }
}

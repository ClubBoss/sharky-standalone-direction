/// Passive focus application adapter for personalization (Phi-24).
class AIPersonalizationFocusApplicationV1 {
  const AIPersonalizationFocusApplicationV1(this.tempoApplicationMap);

  final Map<String, Object> tempoApplicationMap;

  Map<String, Object> run() {
    final bool hasTempoApp = tempoApplicationMap.isNotEmpty;
    final Map<String, Object> focusApplicationMap = <String, Object>{};
    final List<String> focusAppMissing = <String>[];

    void _pick(String sourceKey, String targetKey) {
      if (tempoApplicationMap.containsKey(sourceKey)) {
        final Object value = tempoApplicationMap[sourceKey] as Object;
        focusApplicationMap[targetKey] = value;
        if (value == '' ||
            value == [] ||
            value == <Object>[] ||
            value == <String, Object>{}) {
          focusAppMissing.add(targetKey);
        }
      } else {
        focusAppMissing.add(targetKey);
      }
    }

    _pick('tapp_accent', 'fapp_accent');
    _pick('tapp_tempo', 'fapp_tempo');
    _pick('tapp_focus', 'fapp_focus');

    final bool focusAppReady = hasTempoApp && focusAppMissing.isEmpty;

    return <String, Object>{
      'has_tempo_app': hasTempoApp,
      'focus_app_missing': focusAppMissing,
      'focus_application_map': focusApplicationMap,
      'focus_app_ready': focusAppReady,
    };
  }
}

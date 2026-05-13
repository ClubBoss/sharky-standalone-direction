/// Passive tempo application adapter for personalization (Phi-23).
class AIPersonalizationTempoApplicationV1 {
  const AIPersonalizationTempoApplicationV1(this.accentApplicationMap);

  final Map<String, Object> accentApplicationMap;

  Map<String, Object> run() {
    final bool hasAccentApp = accentApplicationMap.isNotEmpty;
    final Map<String, Object> tempoApplicationMap = <String, Object>{};
    final List<String> tempoAppMissing = <String>[];

    void _pick(String sourceKey, String targetKey) {
      if (accentApplicationMap.containsKey(sourceKey)) {
        final Object value = accentApplicationMap[sourceKey] as Object;
        tempoApplicationMap[targetKey] = value;
        if (value == '' ||
            value == [] ||
            value == <Object>[] ||
            value == <String, Object>{}) {
          tempoAppMissing.add(targetKey);
        }
      } else {
        tempoAppMissing.add(targetKey);
      }
    }

    _pick('app_accent', 'tapp_accent');
    _pick('app_tempo', 'tapp_tempo');
    _pick('app_focus', 'tapp_focus');

    final bool tempoAppReady = hasAccentApp && tempoAppMissing.isEmpty;

    return <String, Object>{
      'has_accent_app': hasAccentApp,
      'tempo_app_missing': tempoAppMissing,
      'tempo_application_map': tempoApplicationMap,
      'tempo_app_ready': tempoAppReady,
    };
  }
}

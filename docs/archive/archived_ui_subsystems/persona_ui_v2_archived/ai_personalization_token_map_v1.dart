/// Passive token map generator for personalization (Phi-27).
class AIPersonalizationTokenMapV1 {
  const AIPersonalizationTokenMapV1(this.previsualMap);

  final Map<String, Object> previsualMap;

  Map<String, Object> run() {
    final bool hasPrevisual = previsualMap.isNotEmpty;
    final Map<String, Object> uiTokenMap = <String, Object>{};
    final List<String> tokenMissing = <String>[];

    void _pick(String sourceKey, String targetKey) {
      if (previsualMap.containsKey(sourceKey)) {
        final Object value = previsualMap[sourceKey] as Object;
        uiTokenMap[targetKey] = value;
        if (value == '' ||
            value == [] ||
            value == <Object>[] ||
            value == <String, Object>{}) {
          tokenMissing.add(targetKey);
        }
      } else {
        tokenMissing.add(targetKey);
      }
    }

    _pick('pv_hints', 'token_hints');
    _pick('pv_tier_context', 'token_tier_context');
    _pick('pv_consistency', 'token_consistency');

    final bool tokenReady = hasPrevisual && tokenMissing.isEmpty;

    return <String, Object>{
      'has_previsual': hasPrevisual,
      'token_missing': tokenMissing,
      'ui_token_map': uiTokenMap,
      'token_ready': tokenReady,
    };
  }
}

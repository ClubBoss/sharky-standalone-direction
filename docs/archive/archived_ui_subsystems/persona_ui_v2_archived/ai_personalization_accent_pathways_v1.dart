/// Passive accent pathways adapter for personalization (Phi-28).
class AIPersonalizationAccentPathwaysV1 {
  const AIPersonalizationAccentPathwaysV1(this.uiTokenMap);

  final Map<String, Object> uiTokenMap;

  Map<String, Object> run() {
    final bool hasTokenMap = uiTokenMap.isNotEmpty;
    final Map<String, Object> accentPathwaysMap = <String, Object>{};
    final List<String> accentPathwaysMissing = <String>[];

    void _pick(String sourceKey, String targetKey) {
      if (uiTokenMap.containsKey(sourceKey)) {
        final Object value = uiTokenMap[sourceKey] as Object;
        accentPathwaysMap[targetKey] = value;
        if (value == '' ||
            value == [] ||
            value == <Object>[] ||
            value == <String, Object>{}) {
          accentPathwaysMissing.add(targetKey);
        }
      } else {
        accentPathwaysMissing.add(targetKey);
      }
    }

    _pick('token_hints', 'ap_hints');
    _pick('token_tier_context', 'ap_tier_context');
    _pick('token_consistency', 'ap_consistency');

    final bool accentPathwaysReady =
        hasTokenMap && accentPathwaysMissing.isEmpty;

    return <String, Object>{
      'has_token_map': hasTokenMap,
      'accent_pathways_missing': accentPathwaysMissing,
      'accent_pathways_map': accentPathwaysMap,
      'accent_pathways_ready': accentPathwaysReady,
    };
  }
}

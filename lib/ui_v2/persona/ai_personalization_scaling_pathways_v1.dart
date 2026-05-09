/// Passive adaptive scaling pathways adapter (Phi-29).
class AIPersonalizationScalingPathwaysV1 {
  const AIPersonalizationScalingPathwaysV1(this.accentPathwaysMap);

  final Map<String, Object> accentPathwaysMap;

  Map<String, Object> run() {
    final bool hasAccentPathways = accentPathwaysMap.isNotEmpty;
    final Map<String, Object> scalingPathwaysMap = <String, Object>{};
    final List<String> scalingPathwaysMissing = <String>[];

    void _pick(String sourceKey, String targetKey) {
      if (accentPathwaysMap.containsKey(sourceKey)) {
        final Object value = accentPathwaysMap[sourceKey] as Object;
        scalingPathwaysMap[targetKey] = value;
        if (value == '' ||
            value == [] ||
            value == <Object>[] ||
            value == <String, Object>{}) {
          scalingPathwaysMissing.add(targetKey);
        }
      } else {
        scalingPathwaysMissing.add(targetKey);
      }
    }

    _pick('ap_hints', 'sp_hints');
    _pick('ap_tier_context', 'sp_tier_context');
    _pick('ap_consistency', 'sp_consistency');

    final bool scalingPathwaysReady =
        hasAccentPathways && scalingPathwaysMissing.isEmpty;

    return <String, Object>{
      'has_accent_pathways': hasAccentPathways,
      'scaling_pathways_missing': scalingPathwaysMissing,
      'scaling_pathways_map': scalingPathwaysMap,
      'scaling_pathways_ready': scalingPathwaysReady,
    };
  }
}

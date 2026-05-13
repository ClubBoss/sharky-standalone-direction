/// Passive accent delta generator for personalization (Phi-36).
class AIPersonalizationAccentDeltaV1 {
  const AIPersonalizationAccentDeltaV1(this.accentMergeMap);

  final Map<String, Object> accentMergeMap;

  Map<String, Object> run() {
    final bool hasAccentMerge = accentMergeMap.isNotEmpty;
    final Map<String, Object> accentDeltaMap = <String, Object>{};
    final List<String> accentDeltaMissing = <String>[];

    void _pick(String sourceKey, String targetKey) {
      if (accentMergeMap.containsKey(sourceKey)) {
        final Object value = accentMergeMap[sourceKey] as Object;
        accentDeltaMap[targetKey] = value;
        if (value == '' ||
            value == [] ||
            value == <Object>[] ||
            value == <String, Object>{}) {
          accentDeltaMissing.add(targetKey);
        }
      } else {
        accentDeltaMissing.add(targetKey);
      }
    }

    _pick('am_intent', 'ad_intent');
    _pick('am_lift', 'ad_lift');
    _pick('am_gradient', 'ad_gradient');
    accentDeltaMap['ad_factor'] = 0.02;

    final bool accentDeltaReady = hasAccentMerge && accentDeltaMissing.isEmpty;

    return <String, Object>{
      'has_accent_merge': hasAccentMerge,
      'accent_delta_missing': accentDeltaMissing,
      'accent_delta_map': accentDeltaMap,
      'accent_delta_ready': accentDeltaReady,
    };
  }
}

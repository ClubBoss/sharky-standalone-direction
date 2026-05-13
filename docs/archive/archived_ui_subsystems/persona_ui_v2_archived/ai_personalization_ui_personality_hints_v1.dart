/// Passive UI personality hints adapter (Phi-31).
class AIPersonalizationUIPersonalityHintsV1 {
  const AIPersonalizationUIPersonalityHintsV1({
    required this.adaptivePathwaysMap,
    required this.tierAContextMap,
    required this.tierBAggregateMap,
  });

  final Map<String, Object> adaptivePathwaysMap;
  final Map<String, Object> tierAContextMap;
  final Map<String, Object> tierBAggregateMap;

  Map<String, Object> run() {
    final bool hasAdaptivePathways = adaptivePathwaysMap.isNotEmpty;
    final bool hasTierContext = tierAContextMap.isNotEmpty;
    final bool hasTierBAggregate = tierBAggregateMap.isNotEmpty;

    final List<String> uiPersonalityMissing = <String>[];
    if (!hasAdaptivePathways) {
      uiPersonalityMissing.add('uph_accent');
      uiPersonalityMissing.add('uph_scaling');
    }
    if (!hasTierContext) uiPersonalityMissing.add('uph_tierA');
    if (!hasTierBAggregate) uiPersonalityMissing.add('uph_tierB');

    final Map<String, Object> uiPersonalityHintsMap = <String, Object>{
      'uph_accent': adaptivePathwaysMap['mp_accent'] ?? <Object>{},
      'uph_scaling': adaptivePathwaysMap['mp_scaling'] ?? <Object>{},
      'uph_tierA': tierAContextMap,
      'uph_tierB': tierBAggregateMap,
    };

    void _checkEmpty(String key, Object? value) {
      if (value == null ||
          value == '' ||
          value == [] ||
          value == <Object>[] ||
          value == <String, Object>{}) {
        uiPersonalityMissing.add(key);
      }
    }

    _checkEmpty('uph_accent', uiPersonalityHintsMap['uph_accent']);
    _checkEmpty('uph_scaling', uiPersonalityHintsMap['uph_scaling']);
    _checkEmpty('uph_tierA', uiPersonalityHintsMap['uph_tierA']);
    _checkEmpty('uph_tierB', uiPersonalityHintsMap['uph_tierB']);

    final bool uiPersonalityReady =
        hasAdaptivePathways && hasTierContext && uiPersonalityMissing.isEmpty;

    return <String, Object>{
      'has_adaptive_pathways': hasAdaptivePathways,
      'has_tier_context': hasTierContext,
      'ui_personality_missing': uiPersonalityMissing,
      'ui_personality_hints_map': uiPersonalityHintsMap,
      'ui_personality_ready': uiPersonalityReady,
    };
  }
}

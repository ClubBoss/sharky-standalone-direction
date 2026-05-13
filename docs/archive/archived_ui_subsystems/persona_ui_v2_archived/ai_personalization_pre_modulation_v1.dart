/// Passive pre-modulation adapter for personalization (Phi-13).
class AIPersonalizationPreModulationV1 {
  const AIPersonalizationPreModulationV1(this.uiHookMap);

  final Map<String, Object> uiHookMap;

  Map<String, Object> run() {
    final bool hasUiHook = uiHookMap.isNotEmpty;
    final Map<String, Object> preModulationMap = <String, Object>{};
    final List<String> missingSubsections = <String>[];

    void _pick(String sourceKey, String targetKey) {
      if (uiHookMap.containsKey(sourceKey)) {
        preModulationMap[targetKey] = uiHookMap[sourceKey] as Object;
      } else {
        missingSubsections.add(targetKey);
      }
    }

    _pick('ui_persona', 'pm_persona');
    _pick('ui_consistency', 'pm_consistency');
    _pick('ui_aggregate', 'pm_aggregate');
    _pick('ui_tier_a', 'pm_tier_a');

    final bool preModulationReady = hasUiHook && missingSubsections.isEmpty;

    return <String, Object>{
      'has_ui_hook': hasUiHook,
      'missing_subsections': missingSubsections,
      'pre_modulation_map': preModulationMap,
      'pre_modulation_ready': preModulationReady,
    };
  }
}

/// Passive UI hook adapter for personalization output (Phi-12).
class AIPersonalizationUIHookV1 {
  const AIPersonalizationUIHookV1(this.personalityOutputMap);

  final Map<String, Object> personalityOutputMap;

  Map<String, Object> run() {
    final bool hasOutput = personalityOutputMap.isNotEmpty;
    final Map<String, Object> uiHookMap = <String, Object>{};

    void _pick(String sourceKey, String targetKey) {
      if (personalityOutputMap.containsKey(sourceKey)) {
        uiHookMap[targetKey] = personalityOutputMap[sourceKey] as Object;
      }
    }

    _pick('out_persona', 'ui_persona');
    _pick('out_consistency', 'ui_consistency');
    _pick('out_aggregate', 'ui_aggregate');
    _pick('out_tier_a', 'ui_tier_a');

    final bool hookReady = hasOutput && uiHookMap.isNotEmpty;

    return <String, Object>{
      'has_output': hasOutput,
      'ui_hook_map': uiHookMap,
      'hook_ready': hookReady,
    };
  }
}

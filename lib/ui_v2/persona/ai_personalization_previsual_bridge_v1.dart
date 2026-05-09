/// Passive pre-visualization persona bridge (Phi-26).
class AIPersonalizationPrevisualBridgeV1 {
  const AIPersonalizationPrevisualBridgeV1({
    required this.personaHintsMap,
    required this.tierContext,
    required this.tierBConsistencyMap,
  });

  final Map<String, Object> personaHintsMap;
  final Map<String, Object> tierContext;
  final Map<String, Object> tierBConsistencyMap;

  Map<String, Object> run() {
    final bool hasHints = personaHintsMap.isNotEmpty;
    final bool hasTierContext = tierContext.isNotEmpty;
    final bool hasConsistency = tierBConsistencyMap.isNotEmpty;

    final List<String> previsualMissing = <String>[];
    if (!hasHints) previsualMissing.add('pv_hints');
    if (!hasTierContext) previsualMissing.add('pv_tier_context');
    if (!hasConsistency) previsualMissing.add('pv_consistency');

    final Map<String, Object> preVisualizationMap = <String, Object>{
      'pv_hints': personaHintsMap,
      'pv_tier_context': tierContext,
      'pv_consistency': tierBConsistencyMap,
    };

    final bool previsualReady =
        hasHints &&
        hasTierContext &&
        hasConsistency &&
        previsualMissing.isEmpty;

    return <String, Object>{
      'has_hints': hasHints,
      'has_tier_context': hasTierContext,
      'has_consistency': hasConsistency,
      'previsual_missing': previsualMissing,
      'pre_visualization_map': preVisualizationMap,
      'previsual_ready': previsualReady,
    };
  }
}

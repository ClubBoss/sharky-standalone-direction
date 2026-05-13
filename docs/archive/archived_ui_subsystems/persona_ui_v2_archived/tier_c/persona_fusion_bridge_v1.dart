class PersonaFusionBridgeV1 {
  const PersonaFusionBridgeV1({
    this.personaTableHooksMap = const <String, Object>{},
    this.personaBiasMap = const <String, Object>{},
    this.personaAdaptiveRecommendationsMap = const <String, Object>{},
    this.fusionGlobalContextMap = const <String, Object>{},
    this.fusionIntegrationBridgeMap = const <String, Object>{},
  });

  PersonaFusionBridgeV1.fromInputs({
    Map<String, Object?>? personaTableHooksMap,
    Map<String, Object?>? personaBiasMap,
    Map<String, Object?>? personaAdaptiveRecommendationsMap,
    Map<String, Object?>? fusionGlobalContextMap,
    Map<String, Object?>? fusionIntegrationBridgeMap,
  }) : this(
         personaTableHooksMap: _safe(personaTableHooksMap),
         personaBiasMap: _safe(personaBiasMap),
         personaAdaptiveRecommendationsMap: _safe(
           personaAdaptiveRecommendationsMap,
         ),
         fusionGlobalContextMap: _safe(fusionGlobalContextMap),
         fusionIntegrationBridgeMap: _safe(fusionIntegrationBridgeMap),
       );

  final Map<String, Object> personaTableHooksMap;
  final Map<String, Object> personaBiasMap;
  final Map<String, Object> personaAdaptiveRecommendationsMap;
  final Map<String, Object> fusionGlobalContextMap;
  final Map<String, Object> fusionIntegrationBridgeMap;

  Map<String, Object> build() {
    final String hook =
        (personaTableHooksMap['persona_table_hooks_v1']
                as Map<String, Object?>?)?['hook']
            as String? ??
        '';
    final String tone =
        (personaBiasMap['persona_bias_map_v1']
                as Map<String, Object?>?)?['bias_tone']
            as String? ??
        '';
    final String recommendationTag =
        (personaAdaptiveRecommendationsMap['persona_adaptive_recommendations_v1']
                as Map<String, Object?>?)?['tag']
            as String? ??
        '';
    final bool fusionReady =
        (fusionGlobalContextMap['fusion_context_ready'] == true) ||
        (fusionIntegrationBridgeMap['integration_ready'] == true);
    String fusionTag = 'persona_neutral_bridge';
    if (hook == 'boost_attack' && fusionReady) {
      fusionTag = 'persona_aggressive_fusion';
    } else if (tone == 'soft' && fusionReady) {
      fusionTag = 'persona_calm_fusion';
    } else if (recommendationTag.startsWith('focus')) {
      fusionTag = 'persona_focus_bridge';
    }
    return <String, Object>{
      'persona_fusion_bridge_v1': <String, Object>{
        'fusion_persona_tag': _ascii(fusionTag),
        'ready': true,
      },
    };
  }

  static Map<String, Object> _safe(Map<String, Object?>? source) {
    if (source == null) return const <String, Object>{};
    final Map<String, Object> result = <String, Object>{};
    for (final MapEntry<String, Object?> entry in source.entries) {
      result[entry.key] = entry.value ?? '';
    }
    return result;
  }

  static String _ascii(String input) => String.fromCharCodes(
    input.codeUnits.where((unit) => unit >= 0 && unit < 128),
  );
}

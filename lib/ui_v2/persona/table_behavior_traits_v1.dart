/// Passive table behavior traits V1 (Phi-75.2).
class TableBehaviorTraitsV1 {
  const TableBehaviorTraitsV1(this.tableBehaviorModulationV1Map);

  final Object tableBehaviorModulationV1Map;

  Map<String, Object> asReadOnlyMap() {
    final bool hasMod =
        tableBehaviorModulationV1Map is Map &&
        (tableBehaviorModulationV1Map as Map).isNotEmpty;
    final List<String> missing = <String>[];
    if (!hasMod) missing.add('table_behavior_modulation_v1');
    final Map<String, Object> modulation = hasMod
        ? (tableBehaviorModulationV1Map as Map)['table_behavior_modulation_v1']
                  as Map<String, Object>? ??
              <String, Object>{}
        : <String, Object>{};
    final Map<String, Object> traits = <String, Object>{
      'intensity': modulation['modulation'] is Map
          ? (modulation['modulation'] as Map)['focus_mod'] ?? <Object>{}
          : <Object>{},
      'clarity': modulation['modulation'] is Map
          ? (modulation['modulation'] as Map)['tempo_mod'] ?? <Object>{}
          : <Object>{},
      'stability': modulation['modulation'] is Map
          ? (modulation['modulation'] as Map)['risk_mod'] ?? <Object>{}
          : <Object>{},
    };
    final bool traitsReady = missing.isEmpty;
    return <String, Object>{
      'table_behavior_traits_v1': <String, Object>{
        'traits': traits,
        'traits_ready': traitsReady,
        'missing': missing,
      },
      'ready': traitsReady,
    };
  }
}

/// Passive table behavior modulation V1 (Phi-75.1).
class TableBehaviorModulationV1 {
  const TableBehaviorModulationV1(this.tableBehaviorSeedV1Map);

  final Object tableBehaviorSeedV1Map;

  Map<String, Object> asReadOnlyMap() {
    final bool hasSeed =
        tableBehaviorSeedV1Map is Map &&
        (tableBehaviorSeedV1Map as Map).isNotEmpty;
    final List<String> missing = <String>[];
    if (!hasSeed) missing.add('table_behavior_seed_v1');
    final Map<String, Object> seed = hasSeed
        ? (tableBehaviorSeedV1Map as Map)['table_behavior_seed_v1']
                  as Map<String, Object>? ??
              <String, Object>{}
        : <String, Object>{};
    final Map<String, Object> modulation = <String, Object>{
      'focus_mod':
          ((seed['hints'] as Map?)?['focus'] ?? seed['hints']) ?? <Object>{},
      'tempo_mod':
          ((seed['hints'] as Map?)?['tempo'] ?? seed['hints']) ?? <Object>{},
      'risk_mod':
          ((seed['hints'] as Map?)?['risk'] ?? seed['persona_output']) ??
          <Object>{},
    };
    final bool modReady = missing.isEmpty;
    return <String, Object>{
      'table_behavior_modulation_v1': <String, Object>{
        'modulation': modulation,
        'mod_ready': modReady,
        'missing': missing,
      },
      'ready': modReady,
    };
  }
}

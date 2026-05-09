class TablePersonaSyncSealV1 {
  const TablePersonaSyncSealV1(
    this.tableFusionPersonaV1Map,
    this.tableHintMapV1Map,
    this.tableBehaviorDiffuserV1Map,
    this.personaOutputMap,
  );
  final Object tableFusionPersonaV1Map,
      tableHintMapV1Map,
      tableBehaviorDiffuserV1Map,
      personaOutputMap;

  Map<String, Object> asReadOnlyMap() {
    Map<String, Object> m(Object s) => s is Map && (s as Map).isNotEmpty
        ? (s as Map).cast<String, Object>()
        : <String, Object>{};
    Map<String, Object> n(Object s, String k) =>
        s is Map && s[k] is Map ? m(s[k] as Map) : m(s);
    final fusion = n(tableFusionPersonaV1Map, 'table_fusion_persona_v1'),
        hints = n(tableHintMapV1Map, 'table_hint_map_v1'),
        behavior = n(tableBehaviorDiffuserV1Map, 'table_behavior_diffuser_v1');
    final Map<String, Object> persona =
        personaOutputMap is Map &&
            (personaOutputMap as Map)['persona_output'] is Map
        ? m((personaOutputMap as Map)['persona_output'] as Map)
        : m(personaOutputMap);
    final bool syncReady =
        fusion.isNotEmpty &&
        hints.isNotEmpty &&
        behavior.isNotEmpty &&
        persona.isNotEmpty;
    final List<String> missing = <String>[
      if (persona.isEmpty) 'persona_output',
      if (fusion.isEmpty) 'table_fusion_persona_v1',
      if (hints.isEmpty) 'table_hint_map_v1',
      if (behavior.isEmpty) 'table_behavior_diffuser_v1',
      if (!syncReady) 'table_persona_sync_seal_v1',
    ];
    return <String, Object>{
      'table_persona_sync_seal_v1': <String, Object>{
        'sync': <String, Object>{
          'persona': persona,
          'hints': hints,
          'fusion': fusion,
          'behavior': behavior,
        },
        'sync_ready': syncReady,
      },
      'readiness': syncReady,
      'missing': missing,
    };
  }
}

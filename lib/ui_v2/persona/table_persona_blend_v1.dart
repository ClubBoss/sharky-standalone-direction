class TablePersonaBlendV1 {
  const TablePersonaBlendV1(
    this.tablePersonaSyncSealV1Map,
    this.tableFusionPersonaV1Map,
    this.tableHintMapV1Map,
    this.tableBehaviorDiffuserV1Map,
  );
  final Object tablePersonaSyncSealV1Map,
      tableFusionPersonaV1Map,
      tableHintMapV1Map,
      tableBehaviorDiffuserV1Map;

  Map<String, Object> asReadOnlyMap() {
    Map<String, Object> m(Object s) => s is Map && (s as Map).isNotEmpty
        ? (s as Map).cast<String, Object>()
        : <String, Object>{};
    Map<String, Object> n(Object s, String k) =>
        s is Map && s[k] is Map ? m(s[k] as Map) : m(s);
    final sync = n(tablePersonaSyncSealV1Map, 'table_persona_sync_seal_v1'),
        fusion = n(tableFusionPersonaV1Map, 'table_fusion_persona_v1'),
        hints = n(tableHintMapV1Map, 'table_hint_map_v1'),
        behavior = n(tableBehaviorDiffuserV1Map, 'table_behavior_diffuser_v1');
    final Map<String, Object> syncBody = sync['sync'] is Map
        ? m(sync['sync'] as Map)
        : sync;
    final bool ready =
        sync.isNotEmpty &&
        fusion.isNotEmpty &&
        hints.isNotEmpty &&
        behavior.isNotEmpty &&
        sync['sync_ready'] == true;
    final List<String> missing = <String>[
      if (sync.isEmpty) 'table_persona_sync_seal_v1',
      if (fusion.isEmpty) 'table_fusion_persona_v1',
      if (hints.isEmpty) 'table_hint_map_v1',
      if (behavior.isEmpty) 'table_behavior_diffuser_v1',
      if (!ready) 'table_persona_blend_v1',
    ];
    return <String, Object>{
      'table_persona_blend_v1': <String, Object>{
        'blend': <String, Object>{
          'persona': syncBody['persona'] ?? syncBody,
          'fusion': fusion,
          'hints': hints,
          'behavior': behavior,
        },
        'blend_ready': ready,
      },
      'readiness': ready,
      'missing': missing,
    };
  }
}

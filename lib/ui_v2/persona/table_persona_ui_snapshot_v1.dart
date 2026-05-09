class TablePersonaUISnapshotV1 {
  const TablePersonaUISnapshotV1(this.tablePersonaBlendV1Map);
  final Object tablePersonaBlendV1Map;

  Map<String, Object> asReadOnlyMap() {
    Map<String, Object> m(Object s) => s is Map && (s as Map).isNotEmpty
        ? (s as Map).cast<String, Object>()
        : <String, Object>{};
    final Map<String, Object> blend =
        tablePersonaBlendV1Map is Map &&
            (tablePersonaBlendV1Map as Map)['table_persona_blend_v1'] is Map
        ? m((tablePersonaBlendV1Map as Map)['table_persona_blend_v1'] as Map)
        : m(tablePersonaBlendV1Map);
    final Map<String, Object> blendBody = blend['blend'] is Map
        ? m(blend['blend'] as Map)
        : blend;
    final bool ready =
        blend.isNotEmpty &&
        blend['blend_ready'] == true &&
        blendBody.isNotEmpty;
    final List<String> missing = <String>[
      if (blendBody.isEmpty) 'table_persona_blend_v1',
      if (!ready) 'table_persona_ui_snapshot_v1',
    ];
    return <String, Object>{
      'table_persona_ui_snapshot_v1': <String, Object>{
        'ui_snapshot': <String, Object>{
          'persona': blendBody['persona'] ?? blendBody,
          'fusion': blendBody['fusion'] ?? <String, Object>{},
          'hints': blendBody['hints'] ?? <String, Object>{},
          'behavior': blendBody['behavior'] ?? <String, Object>{},
        },
        'ui_ready': ready,
      },
      'readiness': ready,
      'missing': missing,
    };
  }
}

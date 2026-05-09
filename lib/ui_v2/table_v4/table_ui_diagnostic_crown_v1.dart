class TableUIDiagnosticCrownV1 {
  const TableUIDiagnosticCrownV1(
    this.tableUIPathVerdictV1Map,
    this.tableUIColdPathGateV1Map,
    this.tableUIWarmPathGateV1Map,
    this.tableUIHotPathGateV1Map,
  );

  final Object tableUIPathVerdictV1Map;
  final Object tableUIColdPathGateV1Map;
  final Object tableUIWarmPathGateV1Map;
  final Object tableUIHotPathGateV1Map;

  Map<String, Object> asReadOnlyMap() {
    Map<String, Object> m(Object v) => v is Map && v.isNotEmpty
        ? v.cast<String, Object>()
        : <String, Object>{};
    final Map<String, Object> verdict =
        tableUIPathVerdictV1Map is Map &&
            (tableUIPathVerdictV1Map as Map)['table_ui_path_verdict_v1'] is Map
        ? m((tableUIPathVerdictV1Map as Map)['table_ui_path_verdict_v1'] as Map)
        : m(tableUIPathVerdictV1Map);
    final Map<String, Object> cold = m(tableUIColdPathGateV1Map);
    final Map<String, Object> warm = m(tableUIWarmPathGateV1Map);
    final Map<String, Object> hot = m(tableUIHotPathGateV1Map);
    final List<String> missing = <String>[
      if (verdict.isEmpty) 'table_ui_path_verdict_v1',
      if (cold.isEmpty) 'table_ui_cold_path_gate_v1',
      if (warm.isEmpty) 'table_ui_warm_path_gate_v1',
      if (hot.isEmpty) 'table_ui_hot_path_gate_v1',
    ];
    final List<String> invalid = <String>[];
    final bool crownReady =
        verdict['path_ready'] == true &&
        cold['cold_ready'] == true &&
        warm['warm_ready'] == true &&
        hot['hot_ready'] == true;
    return <String, Object>{
      'table_ui_diagnostic_crown_v1': <String, Object>{
        'verdict': verdict,
        'cold': cold,
        'warm': warm,
        'hot': hot,
        'crown_ready': crownReady,
        'missing': missing,
        'invalid': invalid,
      },
      'readiness': crownReady,
    };
  }
}

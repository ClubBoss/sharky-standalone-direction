class TableUIStabilitySealV1 {
  const TableUIStabilitySealV1(
    this.tableUIColdPathGateV1Map,
    this.tableUIWarmPathGateV1Map,
    this.tableUIHotPathGateV1Map,
    this.tableUIPathVerdictV1Map,
    this.tableUIDiagnosticCrownV1Map,
  );

  final Object tableUIColdPathGateV1Map;
  final Object tableUIWarmPathGateV1Map;
  final Object tableUIHotPathGateV1Map;
  final Object tableUIPathVerdictV1Map;
  final Object tableUIDiagnosticCrownV1Map;

  Map<String, Object> asReadOnlyMap() {
    Map<String, Object> m(Object v) => v is Map && v.isNotEmpty
        ? v.cast<String, Object>()
        : <String, Object>{};
    final Map<String, Object> cold = m(tableUIColdPathGateV1Map);
    final Map<String, Object> warm = m(tableUIWarmPathGateV1Map);
    final Map<String, Object> hot = m(tableUIHotPathGateV1Map);
    final Map<String, Object> verdict = m(tableUIPathVerdictV1Map);
    final Map<String, Object> crown = m(tableUIDiagnosticCrownV1Map);
    final List<String> missing = <String>[
      if (cold.isEmpty) 'table_ui_cold_path_gate_v1',
      if (warm.isEmpty) 'table_ui_warm_path_gate_v1',
      if (hot.isEmpty) 'table_ui_hot_path_gate_v1',
      if (verdict.isEmpty) 'table_ui_path_verdict_v1',
      if (crown.isEmpty) 'table_ui_diagnostic_crown_v1',
    ];
    final List<String> invalid = <String>[];
    final bool ready =
        cold['cold_ready'] == true &&
        warm['warm_ready'] == true &&
        hot['hot_ready'] == true &&
        verdict['path_ready'] == true &&
        crown['crown_ready'] == true;
    return <String, Object>{
      'table_ui_stability_seal_v1': <String, Object>{
        'cold': cold,
        'warm': warm,
        'hot': hot,
        'verdict': verdict,
        'crown': crown,
        'seal_ready': ready,
        'missing': missing,
        'invalid': invalid,
      },
      'readiness': ready,
    };
  }
}

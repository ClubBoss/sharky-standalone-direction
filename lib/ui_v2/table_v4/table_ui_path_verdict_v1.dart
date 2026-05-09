class TableUIPathVerdictV1 {
  const TableUIPathVerdictV1(
    this.tableUIColdPathGateV1Map,
    this.tableUIWarmPathGateV1Map,
    this.tableUIHotPathGateV1Map,
  );

  final Object tableUIColdPathGateV1Map;
  final Object tableUIWarmPathGateV1Map;
  final Object tableUIHotPathGateV1Map;

  Map<String, Object> asReadOnlyMap() {
    bool flag(Object m, String key) => m is Map && m[key] == true;
    List<String> list(Object m, String key) => m is Map && m[key] is List
        ? List<String>.from(m[key] as List)
        : <String>[];

    final bool cold = flag(tableUIColdPathGateV1Map, 'readiness');
    final bool warm = flag(tableUIWarmPathGateV1Map, 'readiness');
    final bool hot = flag(tableUIHotPathGateV1Map, 'readiness');
    final List<String> missing = <String>[
      ...list(tableUIColdPathGateV1Map, 'missing'),
      ...list(tableUIWarmPathGateV1Map, 'missing'),
      ...list(tableUIHotPathGateV1Map, 'missing'),
    ];
    final List<String> invalid = <String>[
      ...list(tableUIColdPathGateV1Map, 'invalid'),
      ...list(tableUIWarmPathGateV1Map, 'invalid'),
      ...list(tableUIHotPathGateV1Map, 'invalid'),
    ];
    final bool ready = cold && warm && hot;
    return <String, Object>{
      'table_ui_path_verdict_v1': <String, Object>{
        'cold_ready': cold,
        'warm_ready': warm,
        'hot_ready': hot,
        'path_ready': ready,
        'missing': missing,
        'invalid': invalid,
      },
      'readiness': ready,
    };
  }
}

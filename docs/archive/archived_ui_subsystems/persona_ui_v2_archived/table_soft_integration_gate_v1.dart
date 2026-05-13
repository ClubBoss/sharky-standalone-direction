typedef M = Map<String, Object>;

class TableSoftIntegrationGateV1 {
  const TableSoftIntegrationGateV1(
    this.u,
    this.b,
    this.s,
    this.f,
    this.h,
    this.v,
  );
  final Object u, b, s, f, h, v;

  Map<String, Object> asReadOnlyMap() {
    M m(Object x) => x is Map && (x as Map).isNotEmpty
        ? (x as Map).cast<String, Object>()
        : <String, Object>{};
    M n(Object x, String k) => x is Map && x[k] is Map ? m(x[k] as Map) : m(x);
    final ui = n(u, 'table_persona_ui_snapshot_v1'),
        bl = n(b, 'table_persona_blend_v1'),
        sy = n(s, 'table_persona_sync_seal_v1'),
        fu = n(f, 'table_fusion_persona_v1'),
        hi = n(h, 'table_hint_map_v1'),
        bh = n(v, 'table_behavior_diffuser_v1');
    final M uiBody = ui['ui_snapshot'] is Map
        ? m(ui['ui_snapshot'] as Map)
        : ui;
    final M blBody = bl['blend'] is Map ? m(bl['blend'] as Map) : bl;
    final M syBody = sy['sync'] is Map ? m(sy['sync'] as Map) : sy;
    final bool ready =
        ui.isNotEmpty &&
        ui['ui_ready'] == true &&
        uiBody.isNotEmpty &&
        blBody.isNotEmpty &&
        syBody.isNotEmpty &&
        fu.isNotEmpty &&
        hi.isNotEmpty &&
        bh.isNotEmpty;
    final List<String> missing = <String>[
      if (uiBody.isEmpty) 'table_persona_ui_snapshot_v1',
      if (blBody.isEmpty) 'table_persona_blend_v1',
      if (syBody.isEmpty) 'table_persona_sync_seal_v1',
      if (fu.isEmpty) 'table_fusion_persona_v1',
      if (hi.isEmpty) 'table_hint_map_v1',
      if (bh.isEmpty) 'table_behavior_diffuser_v1',
      if (!ready) 'table_soft_integration_gate_v1',
    ];
    return <String, Object>{
      'table_soft_integration_gate_v1': <String, Object>{
        'integration': <String, Object>{
          'ui_snapshot': uiBody,
          'blend': blBody,
          'sync': syBody,
          'fusion': fu,
          'hints': hi,
          'behavior': bh,
        },
        'integration_ready': ready,
      },
      'readiness': ready,
      'missing': missing,
    };
  }
}

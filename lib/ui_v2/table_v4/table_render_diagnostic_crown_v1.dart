class TableRenderDiagnosticCrownV1 {
  const TableRenderDiagnosticCrownV1(
    this.tableRenderPathVerdictV1Map,
    this.tableHotRenderPathGateV1Map,
    this.tableRenderEnvelopeV2Map,
    this.unifiedRenderBundleV1Map,
    this.tableRenderContextV1Map,
  );

  final Object tableRenderPathVerdictV1Map;
  final Object tableHotRenderPathGateV1Map;
  final Object tableRenderEnvelopeV2Map;
  final Object unifiedRenderBundleV1Map;
  final Object tableRenderContextV1Map;

  Map<String, Object> asReadOnlyMap() {
    Map<String, Object> m(Object v) => v is Map && v.isNotEmpty
        ? v.cast<String, Object>()
        : <String, Object>{};
    final Map<String, Object> verdict =
        tableRenderPathVerdictV1Map is Map &&
            (tableRenderPathVerdictV1Map as Map)['table_render_path_verdict_v1']
                is Map
        ? m(
            (tableRenderPathVerdictV1Map as Map)['table_render_path_verdict_v1']
                as Map,
          )
        : m(tableRenderPathVerdictV1Map);
    final Map<String, Object> hotGate = m(tableHotRenderPathGateV1Map);
    final Map<String, Object> renderEnvelope = m(tableRenderEnvelopeV2Map);
    final Map<String, Object> bundle = m(unifiedRenderBundleV1Map);
    final Map<String, Object> renderContext = m(tableRenderContextV1Map);
    final List<String> missing = <String>[
      if (verdict.isEmpty) 'table_render_path_verdict_v1',
      if (hotGate.isEmpty) 'table_hot_render_path_gate_v1',
      if (renderEnvelope.isEmpty) 'table_render_envelope_v2',
      if (bundle.isEmpty) 'unified_render_bundle_v1',
      if (renderContext.isEmpty) 'table_render_context_v1',
    ];
    final List<String> invalid = <String>[];
    final bool crownReady =
        verdict['verdict_ready'] == true &&
        hotGate.isNotEmpty &&
        renderEnvelope.isNotEmpty &&
        bundle.isNotEmpty &&
        renderContext.isNotEmpty;
    return <String, Object>{
      'table_render_diagnostic_crown_v1': <String, Object>{
        'domains': <String, Object>{
          'verdict': verdict,
          'hot_gate': hotGate,
          'render_envelope_v2': renderEnvelope,
          'unified_bundle': bundle,
          'render_context': renderContext,
        },
        'missing': missing,
        'invalid': invalid,
        'crown_ready': crownReady,
      },
      'readiness': crownReady,
    };
  }
}

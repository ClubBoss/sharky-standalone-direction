class TableRenderStabilitySealV1 {
  const TableRenderStabilitySealV1(
    this.tableRenderDiagnosticCrownV1Map,
    this.tableRenderPathVerdictV1Map,
    this.tableHotRenderPathGateV1Map,
    this.tableRenderEnvelopeV2Map,
    this.unifiedRenderBundleV1Map,
    this.tableRenderContextV1Map,
  );

  final Object tableRenderDiagnosticCrownV1Map;
  final Object tableRenderPathVerdictV1Map;
  final Object tableHotRenderPathGateV1Map;
  final Object tableRenderEnvelopeV2Map;
  final Object unifiedRenderBundleV1Map;
  final Object tableRenderContextV1Map;

  Map<String, Object> asReadOnlyMap() {
    Map<String, Object> m(Object v) => v is Map && v.isNotEmpty
        ? v.cast<String, Object>()
        : <String, Object>{};
    final Map<String, Object> crown =
        tableRenderDiagnosticCrownV1Map is Map &&
            (tableRenderDiagnosticCrownV1Map
                    as Map)['table_render_diagnostic_crown_v1']
                is Map
        ? m(
            (tableRenderDiagnosticCrownV1Map
                    as Map)['table_render_diagnostic_crown_v1']
                as Map,
          )
        : m(tableRenderDiagnosticCrownV1Map);
    final Map<String, Object> pathVerdict = m(tableRenderPathVerdictV1Map);
    final Map<String, Object> hotGate = m(tableHotRenderPathGateV1Map);
    final Map<String, Object> renderEnvelope = m(tableRenderEnvelopeV2Map);
    final Map<String, Object> bundle = m(unifiedRenderBundleV1Map);
    final Map<String, Object> renderContext = m(tableRenderContextV1Map);
    final List<String> missing = <String>[
      if (crown.isEmpty) 'table_render_diagnostic_crown_v1',
      if (pathVerdict.isEmpty) 'table_render_path_verdict_v1',
      if (hotGate.isEmpty) 'table_hot_render_path_gate_v1',
      if (renderEnvelope.isEmpty) 'table_render_envelope_v2',
      if (bundle.isEmpty) 'unified_render_bundle_v1',
      if (renderContext.isEmpty) 'table_render_context_v1',
    ];
    final List<String> invalid = <String>[];
    final bool ready =
        crown['crown_ready'] == true &&
        pathVerdict.isNotEmpty &&
        hotGate.isNotEmpty &&
        renderEnvelope.isNotEmpty &&
        bundle.isNotEmpty &&
        renderContext.isNotEmpty;
    return <String, Object>{
      'table_render_stability_seal_v1': <String, Object>{
        'domains': <String, Object>{
          'diagnostic_crown': crown,
          'path_verdict': pathVerdict,
          'hot_gate': hotGate,
          'render_envelope_v2': renderEnvelope,
          'unified_bundle': bundle,
          'render_context': renderContext,
        },
        'missing': missing,
        'invalid': invalid,
        'seal_ready': ready,
      },
      'readiness': ready,
    };
  }
}

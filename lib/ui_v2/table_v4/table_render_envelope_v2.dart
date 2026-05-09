class TableRenderEnvelopeV2 {
  const TableRenderEnvelopeV2(
    this.tableVisualSpecV2Map,
    this.tableRenderEnvelopeV1Map,
    this.tableRenderContextV1Map,
  );

  final Object tableVisualSpecV2Map;
  final Object tableRenderEnvelopeV1Map;
  final Object tableRenderContextV1Map;

  Map<String, Object> asReadOnlyMap() {
    Map<String, Object> m(Object v) => v is Map && v.isNotEmpty
        ? v.cast<String, Object>()
        : <String, Object>{};
    final Map<String, Object> visualSpec = m(tableVisualSpecV2Map);
    final Map<String, Object> renderEnvelope = m(tableRenderEnvelopeV1Map);
    final Map<String, Object> renderContext = m(tableRenderContextV1Map);
    final List<String> missing = <String>[
      if (visualSpec.isEmpty) 'table_visual_spec_v2',
      if (renderEnvelope.isEmpty) 'table_render_envelope_v1',
      if (renderContext.isEmpty) 'table_render_context_v1',
    ];
    final bool ready = missing.isEmpty;
    return <String, Object>{
      'table_render_envelope_v2': <String, Object>{
        'envelope': <String, Object>{
          'visual_spec_v2': visualSpec,
          'render_envelope_v1': renderEnvelope,
          'render_context': renderContext,
        },
        'envelope_ready': ready,
      },
      'readiness': ready,
      'missing': missing,
    };
  }
}

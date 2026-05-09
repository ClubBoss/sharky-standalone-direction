class TableHighlightsFinalIntegratorV1 {
  const TableHighlightsFinalIntegratorV1(
    this.tableHighlightsV1Map,
    this.tableCompositionFrameV1Map,
    this.tableRenderContextV1Map,
  );

  final Object tableHighlightsV1Map;
  final Object tableCompositionFrameV1Map;
  final Object tableRenderContextV1Map;

  Map<String, Object> asReadOnlyMap() {
    Map<String, Object> m(Object v) => v is Map && v.isNotEmpty
        ? v.cast<String, Object>()
        : <String, Object>{};
    final Map<String, Object> highlights = m(tableHighlightsV1Map);
    final Map<String, Object> composition = m(tableCompositionFrameV1Map);
    final Map<String, Object> renderContext = m(tableRenderContextV1Map);
    final List<String> missing = <String>[
      if (highlights.isEmpty) 'table_highlights_v1',
      if (composition.isEmpty) 'table_composition_frame_v1',
      if (renderContext.isEmpty) 'table_render_context_v1',
    ];
    final bool ready = missing.isEmpty;
    return <String, Object>{
      'table_highlights_final_integrator_v1': <String, Object>{
        'integrated': <String, Object>{
          'highlights': highlights,
          'composition': composition,
          'render_context': renderContext,
        },
        'integrated_ready': ready,
      },
      'readiness': ready,
      'missing': missing,
    };
  }
}

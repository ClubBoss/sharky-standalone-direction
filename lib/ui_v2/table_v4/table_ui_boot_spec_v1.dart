class TableUIBootSpecV1 {
  const TableUIBootSpecV1(
    this.unifiedRenderBundleV1Map,
    this.tableRenderContextV1Map,
    this.tableCompositionFrameV1Map,
  );

  final Object unifiedRenderBundleV1Map;
  final Object tableRenderContextV1Map;
  final Object tableCompositionFrameV1Map;

  Map<String, Object> asReadOnlyMap() {
    Map<String, Object> m(Object v) => v is Map && v.isNotEmpty
        ? v.cast<String, Object>()
        : <String, Object>{};
    final Map<String, Object> bundle = m(unifiedRenderBundleV1Map);
    final Map<String, Object> renderContext = m(tableRenderContextV1Map);
    final Map<String, Object> composition = m(tableCompositionFrameV1Map);
    final List<String> missing = <String>[
      if (bundle.isEmpty) 'unified_render_bundle_v1',
      if (renderContext.isEmpty) 'table_render_context_v1',
      if (composition.isEmpty) 'table_composition_frame_v1',
    ];
    final bool ready = missing.isEmpty;
    return <String, Object>{
      'table_ui_boot_spec_v1': <String, Object>{
        'boot': <String, Object>{
          'bundle': bundle,
          'render_context': renderContext,
          'composition': composition,
        },
        'boot_ready': ready,
      },
      'readiness': ready,
      'missing': missing,
    };
  }
}

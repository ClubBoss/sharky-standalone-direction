class ChipsPotFinalIntegratorV1 {
  const ChipsPotFinalIntegratorV1(
    this.chipsPotGeometryV1Map,
    this.tableCompositionFrameV1Map,
    this.tableRenderContextV1Map,
  );

  final Object chipsPotGeometryV1Map;
  final Object tableCompositionFrameV1Map;
  final Object tableRenderContextV1Map;

  Map<String, Object> asReadOnlyMap() {
    Map<String, Object> m(Object v) => v is Map && v.isNotEmpty
        ? v.cast<String, Object>()
        : <String, Object>{};
    final Map<String, Object> geometry = m(chipsPotGeometryV1Map);
    final Map<String, Object> composition = m(tableCompositionFrameV1Map);
    final Map<String, Object> renderContext = m(tableRenderContextV1Map);
    final List<String> missing = <String>[
      if (geometry.isEmpty) 'chips_pot_geometry_v1',
      if (composition.isEmpty) 'table_composition_frame_v1',
      if (renderContext.isEmpty) 'table_render_context_v1',
    ];
    final bool ready = missing.isEmpty;
    return <String, Object>{
      'chips_pot_final_integrator_v1': <String, Object>{
        'integrated': <String, Object>{
          'geometry': geometry,
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

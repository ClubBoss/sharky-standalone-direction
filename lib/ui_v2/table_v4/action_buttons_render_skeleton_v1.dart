class ActionButtonsRenderSkeletonV1 {
  const ActionButtonsRenderSkeletonV1(
    this.actionButtonsGeometryV1Map,
    this.tableSurfaceTokensV1Map,
    this.tableCompositionFrameV1Map,
  );

  final Object actionButtonsGeometryV1Map;
  final Object tableSurfaceTokensV1Map;
  final Object tableCompositionFrameV1Map;

  Map<String, Object> asReadOnlyMap() {
    Map<String, Object> m(Object v) => v is Map && v.isNotEmpty
        ? v.cast<String, Object>()
        : <String, Object>{};
    final Map<String, Object> geometry = m(actionButtonsGeometryV1Map);
    final Map<String, Object> tokens = m(tableSurfaceTokensV1Map);
    final Map<String, Object> composition = m(tableCompositionFrameV1Map);
    final List<String> missing = <String>[
      if (geometry.isEmpty) 'action_buttons_geometry_v1',
      if (tokens.isEmpty) 'table_surface_tokens_v1',
      if (composition.isEmpty) 'table_composition_frame_v1',
    ];
    final bool ready = missing.isEmpty;
    return <String, Object>{
      'action_buttons_render_skeleton_v1': <String, Object>{
        'geometry': geometry,
        'tokens': tokens,
        'composition': composition,
        'skeleton_ready': ready,
      },
      'readiness': ready,
      'missing': missing,
    };
  }
}

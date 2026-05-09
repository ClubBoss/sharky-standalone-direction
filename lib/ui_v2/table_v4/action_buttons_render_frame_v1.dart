class ActionButtonsRenderFrameV1 {
  const ActionButtonsRenderFrameV1(
    this.actionButtonsRenderSpecV1Map,
    this.actionButtonsGeometryV1Map,
  );

  final Object actionButtonsRenderSpecV1Map;
  final Object actionButtonsGeometryV1Map;

  Map<String, Object> asReadOnlyMap() {
    Map<String, Object> m(Object v) => v is Map && v.isNotEmpty
        ? v.cast<String, Object>()
        : <String, Object>{};
    final Map<String, Object> spec =
        actionButtonsRenderSpecV1Map is Map &&
            (actionButtonsRenderSpecV1Map
                    as Map)['action_buttons_render_spec_v1']
                is Map
        ? m(
            (actionButtonsRenderSpecV1Map
                    as Map)['action_buttons_render_spec_v1']
                as Map,
          )
        : m(actionButtonsRenderSpecV1Map);
    final Map<String, Object> geometry = m(actionButtonsGeometryV1Map);
    final List<String> missing = <String>[
      if (spec.isEmpty) 'action_buttons_render_spec_v1',
      if (geometry.isEmpty) 'action_buttons_geometry_v1',
    ];
    final bool ready = missing.isEmpty;
    return <String, Object>{
      'action_buttons_render_frame_v1': <String, Object>{
        'frame': <String, Object>{'spec': spec, 'geometry': geometry},
        'frame_ready': ready,
      },
      'readiness': ready,
      'missing': missing,
    };
  }
}

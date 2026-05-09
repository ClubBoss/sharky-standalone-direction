class ActionButtonsFinalIntegratorV1 {
  const ActionButtonsFinalIntegratorV1(
    this.actionButtonsRenderFrameV1Map,
    this.tableCompositionFrameV1Map,
    this.tableRenderContextV1Map,
  );

  final Object actionButtonsRenderFrameV1Map;
  final Object tableCompositionFrameV1Map;
  final Object tableRenderContextV1Map;

  Map<String, Object> asReadOnlyMap() {
    Map<String, Object> m(Object v) => v is Map && v.isNotEmpty
        ? v.cast<String, Object>()
        : <String, Object>{};
    final Map<String, Object> frame =
        actionButtonsRenderFrameV1Map is Map &&
            (actionButtonsRenderFrameV1Map
                    as Map)['action_buttons_render_frame_v1']
                is Map
        ? m(
            (actionButtonsRenderFrameV1Map
                    as Map)['action_buttons_render_frame_v1']
                as Map,
          )
        : m(actionButtonsRenderFrameV1Map);
    final Map<String, Object> composition = m(tableCompositionFrameV1Map);
    final Map<String, Object> renderContext = m(tableRenderContextV1Map);
    final List<String> missing = <String>[
      if (frame.isEmpty) 'action_buttons_render_frame_v1',
      if (composition.isEmpty) 'table_composition_frame_v1',
      if (renderContext.isEmpty) 'table_render_context_v1',
    ];
    final bool ready = missing.isEmpty;
    return <String, Object>{
      'action_buttons_final_integrator_v1': <String, Object>{
        'integrated': <String, Object>{
          'frame': frame,
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

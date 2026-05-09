class UnifiedRenderBundleV1 {
  const UnifiedRenderBundleV1(
    this.tableRenderEnvelopeV2Map,
    this.tableVisualSpecV2Map,
    this.tableRenderContextV1Map,
    this.tableCompositionFrameV1Map,
    this.tableInteractionZonesV1Map,
    this.actionButtonsFinalIntegratorV1Map,
    this.chipsPotFinalIntegratorV1Map,
    this.tableHighlightsFinalIntegratorV1Map,
    this.tableDepthFinalIntegratorV1Map,
  );

  final Object tableRenderEnvelopeV2Map;
  final Object tableVisualSpecV2Map;
  final Object tableRenderContextV1Map;
  final Object tableCompositionFrameV1Map;
  final Object tableInteractionZonesV1Map;
  final Object actionButtonsFinalIntegratorV1Map;
  final Object chipsPotFinalIntegratorV1Map;
  final Object tableHighlightsFinalIntegratorV1Map;
  final Object tableDepthFinalIntegratorV1Map;

  Map<String, Object> asReadOnlyMap() {
    Map<String, Object> m(Object v) => v is Map && v.isNotEmpty
        ? v.cast<String, Object>()
        : <String, Object>{};
    final Map<String, Object> renderEnvelope = m(tableRenderEnvelopeV2Map);
    final Map<String, Object> visualSpec = m(tableVisualSpecV2Map);
    final Map<String, Object> renderContext = m(tableRenderContextV1Map);
    final Map<String, Object> composition = m(tableCompositionFrameV1Map);
    final Map<String, Object> interaction = m(tableInteractionZonesV1Map);
    final Map<String, Object> actions = m(actionButtonsFinalIntegratorV1Map);
    final Map<String, Object> chipsPot = m(chipsPotFinalIntegratorV1Map);
    final Map<String, Object> highlights = m(
      tableHighlightsFinalIntegratorV1Map,
    );
    final Map<String, Object> depth = m(tableDepthFinalIntegratorV1Map);
    final List<String> missing = <String>[
      if (renderEnvelope.isEmpty) 'table_render_envelope_v2',
      if (visualSpec.isEmpty) 'table_visual_spec_v2',
      if (renderContext.isEmpty) 'table_render_context_v1',
      if (composition.isEmpty) 'table_composition_frame_v1',
      if (interaction.isEmpty) 'table_interaction_zones_v1',
      if (actions.isEmpty) 'action_buttons_final_integrator_v1',
      if (chipsPot.isEmpty) 'chips_pot_final_integrator_v1',
      if (highlights.isEmpty) 'table_highlights_final_integrator_v1',
      if (depth.isEmpty) 'table_depth_final_integrator_v1',
    ];
    final bool ready = missing.isEmpty;
    return <String, Object>{
      'unified_render_bundle_v1': <String, Object>{
        'bundle': <String, Object>{
          'render_envelope_v2': renderEnvelope,
          'visual_spec_v2': visualSpec,
          'render_context': renderContext,
          'composition': composition,
          'interaction': interaction,
          'actions': actions,
          'chips_pot': chipsPot,
          'highlights': highlights,
          'depth': depth,
        },
        'bundle_ready': ready,
      },
      'readiness': ready,
      'missing': missing,
    };
  }
}

class TableVisualCompositeSealV1 {
  const TableVisualCompositeSealV1(
    this.tableRenderStabilitySealV1Map,
    this.tableVisualSpecV2Map,
    this.unifiedRenderBundleV1Map,
    this.tableRenderContextV1Map,
    this.tableCompositionFrameV1Map,
    this.tableInteractionZonesV1Map,
    this.actionButtonsFinalIntegratorV1Map,
    this.chipsPotFinalIntegratorV1Map,
    this.tableHighlightsFinalIntegratorV1Map,
    this.tableDepthFinalIntegratorV1Map,
  );

  final Object tableRenderStabilitySealV1Map;
  final Object tableVisualSpecV2Map;
  final Object unifiedRenderBundleV1Map;
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
    final Map<String, Object> renderStability = m(
      tableRenderStabilitySealV1Map,
    );
    final Map<String, Object> visualSpec = m(tableVisualSpecV2Map);
    final Map<String, Object> bundle = m(unifiedRenderBundleV1Map);
    final Map<String, Object> renderContext = m(tableRenderContextV1Map);
    final Map<String, Object> composition = m(tableCompositionFrameV1Map);
    final Map<String, Object> interaction = m(tableInteractionZonesV1Map);
    final Map<String, Object> actions = m(actionButtonsFinalIntegratorV1Map);
    final Map<String, Object> chipsPot = m(chipsPotFinalIntegratorV1Map);
    final Map<String, Object> highlights = m(
      tableHighlightsFinalIntegratorV1Map,
    );
    final Map<String, Object> depth = m(tableDepthFinalIntegratorV1Map);
    final Map<String, Object> domains = <String, Object>{
      'action_buttons': actions,
      'chips_pot': chipsPot,
      'composition': composition,
      'depth': depth,
      'highlights': highlights,
      'interaction_zones': interaction,
      'render_context': renderContext,
      'render_stability': renderStability,
      'unified_bundle': bundle,
      'visual_spec_v2': visualSpec,
    };
    final List<String> missing = <String>[
      if (renderStability.isEmpty) 'table_render_stability_seal_v1',
      if (visualSpec.isEmpty) 'table_visual_spec_v2',
      if (bundle.isEmpty) 'unified_render_bundle_v1',
      if (renderContext.isEmpty) 'table_render_context_v1',
      if (composition.isEmpty) 'table_composition_frame_v1',
      if (interaction.isEmpty) 'table_interaction_zones_v1',
      if (actions.isEmpty) 'action_buttons_final_integrator_v1',
      if (chipsPot.isEmpty) 'chips_pot_final_integrator_v1',
      if (highlights.isEmpty) 'table_highlights_final_integrator_v1',
      if (depth.isEmpty) 'table_depth_final_integrator_v1',
    ];
    final List<String> invalid = <String>[];
    final bool ready =
        renderStability['seal_ready'] == true &&
        visualSpec.isNotEmpty &&
        bundle.isNotEmpty &&
        renderContext.isNotEmpty &&
        composition.isNotEmpty &&
        interaction.isNotEmpty &&
        actions.isNotEmpty &&
        chipsPot.isNotEmpty &&
        highlights.isNotEmpty &&
        depth.isNotEmpty;
    return <String, Object>{
      'table_visual_composite_seal_v1': <String, Object>{
        'domains': domains,
        'missing': missing,
        'invalid': invalid,
        'seal_ready': ready,
      },
      'readiness': ready,
    };
  }
}

class TableVisualSnapshotV4 {
  const TableVisualSnapshotV4(
    this.tableVisualCompositeSealV1Map,
    this.tableRenderContextV1Map,
    this.tableRenderSpecV1Map,
    this.tableRenderEnvelopeV2Map,
    this.unifiedRenderBundleV1Map,
    this.tableCompositionFrameV1Map,
    this.tableInteractionZonesV1Map,
    this.actionButtonsFinalIntegratorV1Map,
    this.chipsPotFinalIntegratorV1Map,
    this.tableHighlightsFinalIntegratorV1Map,
    this.tableDepthFinalIntegratorV1Map,
  );

  final Object tableVisualCompositeSealV1Map;
  final Object tableRenderContextV1Map;
  final Object tableRenderSpecV1Map;
  final Object tableRenderEnvelopeV2Map;
  final Object unifiedRenderBundleV1Map;
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
    final Map<String, Object> compositeSeal = m(tableVisualCompositeSealV1Map);
    final Map<String, Object> renderContext = m(tableRenderContextV1Map);
    final Map<String, Object> renderSpec = m(tableRenderSpecV1Map);
    final Map<String, Object> renderEnvelope = m(tableRenderEnvelopeV2Map);
    final Map<String, Object> bundle = m(unifiedRenderBundleV1Map);
    final Map<String, Object> composition = m(tableCompositionFrameV1Map);
    final Map<String, Object> interaction = m(tableInteractionZonesV1Map);
    final Map<String, Object> actions = m(actionButtonsFinalIntegratorV1Map);
    final Map<String, Object> chipsPot = m(chipsPotFinalIntegratorV1Map);
    final Map<String, Object> highlights = m(
      tableHighlightsFinalIntegratorV1Map,
    );
    final Map<String, Object> depth = m(tableDepthFinalIntegratorV1Map);
    final List<String> missing = <String>[
      if (compositeSeal.isEmpty) 'table_visual_composite_seal_v1',
      if (renderContext.isEmpty) 'table_render_context_v1',
      if (renderSpec.isEmpty) 'table_render_spec_v1',
      if (renderEnvelope.isEmpty) 'table_render_envelope_v2',
      if (bundle.isEmpty) 'unified_render_bundle_v1',
      if (composition.isEmpty) 'table_composition_frame_v1',
      if (interaction.isEmpty) 'table_interaction_zones_v1',
      if (actions.isEmpty) 'action_buttons_final_integrator_v1',
      if (chipsPot.isEmpty) 'chips_pot_final_integrator_v1',
      if (highlights.isEmpty) 'table_highlights_final_integrator_v1',
      if (depth.isEmpty) 'table_depth_final_integrator_v1',
    ];
    final bool ready =
        compositeSeal['seal_ready'] == true &&
        renderContext.isNotEmpty &&
        renderSpec.isNotEmpty &&
        renderEnvelope.isNotEmpty &&
        bundle.isNotEmpty &&
        composition.isNotEmpty &&
        interaction.isNotEmpty &&
        actions.isNotEmpty &&
        chipsPot.isNotEmpty &&
        highlights.isNotEmpty &&
        depth.isNotEmpty;
    return <String, Object>{
      'table_visual_snapshot_v4': <String, Object>{
        'snapshot': <String, Object>{
          'composite_seal': compositeSeal,
          'render_context': renderContext,
          'render_spec_v1': renderSpec,
          'render_envelope_v2': renderEnvelope,
          'unified_bundle': bundle,
          'composition': composition,
          'interaction_zones': interaction,
          'action_buttons': actions,
          'chips_pot': chipsPot,
          'highlights': highlights,
          'depth': depth,
        },
        'snapshot_ready': ready,
      },
      'readiness': ready,
      'missing': missing,
    };
  }
}

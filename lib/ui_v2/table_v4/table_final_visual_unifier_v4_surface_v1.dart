import 'dart:collection';

class TableFinalVisualUnifierV4SurfaceV1 {
  TableFinalVisualUnifierV4SurfaceV1(
    this.tableInteractionPolishV4SurfaceV1Map,
    this.tableActionAffordancesV4SurfaceV1Map,
    this.tableAnimationsV4SurfaceV1Map,
    this.tableHighlightsV4SurfaceV1Map,
    this.tableTapZoneReinforcementV4Map,
    this.tableTypographyBlendV4Map,
    this.tableVisualSnapshotV4Map,
    this.tableVisualSealV4Map,
    this.tableVisualSurfaceV4Map,
    this.tableRenderSurfaceV4Map,
    this.tableFinalVisualFusionV4Map,
    this.tableFinalRenderEnvelopeFusionV4Map,
    this.unifiedRenderBundleV1Map,
    this.tableRenderContextV1Map,
    this.tableCompositionFrameV1Map,
    this.tableInteractionZonesV1Map,
  );

  final Object tableInteractionPolishV4SurfaceV1Map;
  final Object tableActionAffordancesV4SurfaceV1Map;
  final Object tableAnimationsV4SurfaceV1Map;
  final Object tableHighlightsV4SurfaceV1Map;
  final Object tableTapZoneReinforcementV4Map;
  final Object tableTypographyBlendV4Map;
  final Object tableVisualSnapshotV4Map;
  final Object tableVisualSealV4Map;
  final Object tableVisualSurfaceV4Map;
  final Object tableRenderSurfaceV4Map;
  final Object tableFinalVisualFusionV4Map;
  final Object tableFinalRenderEnvelopeFusionV4Map;
  final Object unifiedRenderBundleV1Map;
  final Object tableRenderContextV1Map;
  final Object tableCompositionFrameV1Map;
  final Object tableInteractionZonesV1Map;

  Map<String, Object> asReadOnlyMap() {
    final SplayTreeMap<String, Object?> domains =
        SplayTreeMap<String, Object?>.from(<String, Object?>{
          'action_affordances_v4': tableActionAffordancesV4SurfaceV1Map,
          'animations_v4': tableAnimationsV4SurfaceV1Map,
          'bundle': unifiedRenderBundleV1Map,
          'composition_frame': tableCompositionFrameV1Map,
          'final_render_envelope_fusion_v4':
              tableFinalRenderEnvelopeFusionV4Map,
          'final_visual_fusion_v4': tableFinalVisualFusionV4Map,
          'highlights_v4': tableHighlightsV4SurfaceV1Map,
          'interaction_polish_v4': tableInteractionPolishV4SurfaceV1Map,
          'interaction_zones': tableInteractionZonesV1Map,
          'render_context': tableRenderContextV1Map,
          'render_surface_v4': tableRenderSurfaceV4Map,
          'tap_zone_reinforcement_v4': tableTapZoneReinforcementV4Map,
          'typography_blend_v4': tableTypographyBlendV4Map,
          'visual_seal_v4': tableVisualSealV4Map,
          'visual_snapshot_v4': tableVisualSnapshotV4Map,
          'visual_surface_v4': tableVisualSurfaceV4Map,
        });

    bool domainReady(Object? value) =>
        value is Map && value.isNotEmpty && value['readiness'] == true;

    final List<String> missing = domains.entries
        .where((entry) => !domainReady(entry.value))
        .map((entry) => entry.key)
        .toList();

    final bool unifierReady =
        missing.isEmpty && domains.values.every(domainReady);

    return <String, Object>{
      'table_final_visual_unifier_v4_surface_v1': <String, Object>{
        'domains': domains,
        'missing': missing,
        'unifier_ready': unifierReady,
      },
      'readiness': unifierReady,
    };
  }
}

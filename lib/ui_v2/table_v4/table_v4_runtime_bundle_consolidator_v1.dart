import 'dart:collection';

class TableV4RuntimeBundleConsolidatorV1 {
  TableV4RuntimeBundleConsolidatorV1(
    this.deviceFusionValidator,
    this.viewportIntegrityGuard,
    this.finalVisualUnifier,
    this.actionAffordancesV4,
    this.interactionPolishV4,
    this.highlightsV4,
    this.animationsV4,
    this.renderSurfaceV4,
    this.visualSurfaceV4,
    this.visualSealV4,
    this.visualSnapshotV4,
    this.tableInteractionEnvelopeV4,
    this.tableTypographyBlendV4,
    this.tapZoneReinforcementV4,
    this.tableInteractionFinalizerV4,
  );

  final Object deviceFusionValidator;
  final Object viewportIntegrityGuard;
  final Object finalVisualUnifier;
  final Object actionAffordancesV4;
  final Object interactionPolishV4;
  final Object highlightsV4;
  final Object animationsV4;
  final Object renderSurfaceV4;
  final Object visualSurfaceV4;
  final Object visualSealV4;
  final Object visualSnapshotV4;
  final Object tableInteractionEnvelopeV4;
  final Object tableTypographyBlendV4;
  final Object tapZoneReinforcementV4;
  final Object tableInteractionFinalizerV4;

  Map<String, Object> asReadOnlyMap() {
    final SplayTreeMap<String, Object?> domains =
        SplayTreeMap<String, Object?>.from(<String, Object?>{
          'action_affordances_v4': actionAffordancesV4,
          'animations_v4': animationsV4,
          'device_fusion_validator': deviceFusionValidator,
          'final_visual_unifier_v4': finalVisualUnifier,
          'highlights_v4': highlightsV4,
          'interaction_finalizer_v4': tableInteractionFinalizerV4,
          'interaction_polish_v4': interactionPolishV4,
          'interaction_v4': tableInteractionEnvelopeV4,
          'render_surface_v4': renderSurfaceV4,
          'tap_zone_reinforcement_v4': tapZoneReinforcementV4,
          'typography_blend_v4': tableTypographyBlendV4,
          'viewport_integrity_guard': viewportIntegrityGuard,
          'visual_seal_v4': visualSealV4,
          'visual_snapshot_v4': visualSnapshotV4,
          'visual_surface_v4': visualSurfaceV4,
        });

    bool domainReady(Object? value) =>
        value is Map && value.isNotEmpty && value['readiness'] == true;

    final List<String> missing = domains.entries
        .where((entry) => !domainReady(entry.value))
        .map((entry) => entry.key)
        .toList();

    final bool bundleReady =
        missing.isEmpty && domains.values.every(domainReady);

    return <String, Object>{
      'table_v4_runtime_bundle_consolidator_v1': <String, Object>{
        'domains': domains,
        'missing': missing,
        'bundle_ready': bundleReady,
      },
      'readiness': bundleReady,
    };
  }
}

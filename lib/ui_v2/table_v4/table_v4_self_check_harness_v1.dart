import 'dart:collection';

class TableV4SelfCheckHarnessV1 {
  TableV4SelfCheckHarnessV1(
    this.finalReadinessGate,
    this.demoSurfaceSnapshot,
    this.runtimeBundle,
    this.finalVisualUnifier,
    this.interactionPolishV4,
    this.actionAffordancesV4,
    this.animationsV4,
    this.highlightsV4,
    this.tapZoneReinforcementV4,
    this.visualSnapshotV4,
    this.renderSurfaceV4,
    this.visualSurfaceV4,
    this.interactionEnvelopeV4,
    this.typographyBlendV4,
    this.visualSealV4,
    this.viewportIntegrityGuard,
    this.deviceFusionValidator,
  );

  final Object finalReadinessGate;
  final Object demoSurfaceSnapshot;
  final Object runtimeBundle;
  final Object finalVisualUnifier;
  final Object interactionPolishV4;
  final Object actionAffordancesV4;
  final Object animationsV4;
  final Object highlightsV4;
  final Object tapZoneReinforcementV4;
  final Object visualSnapshotV4;
  final Object renderSurfaceV4;
  final Object visualSurfaceV4;
  final Object interactionEnvelopeV4;
  final Object typographyBlendV4;
  final Object visualSealV4;
  final Object viewportIntegrityGuard;
  final Object deviceFusionValidator;

  Map<String, Object> asReadOnlyMap() {
    final SplayTreeMap<String, Object?> domains =
        SplayTreeMap<String, Object?>.from(<String, Object?>{
          'action_affordances_v4': actionAffordancesV4,
          'animations_v4': animationsV4,
          'demo_surface_snapshot': demoSurfaceSnapshot,
          'device_fusion_validator': deviceFusionValidator,
          'final_readiness_gate': finalReadinessGate,
          'final_visual_unifier_v4': finalVisualUnifier,
          'highlights_v4': highlightsV4,
          'interaction_envelope_v4': interactionEnvelopeV4,
          'interaction_polish_v4': interactionPolishV4,
          'render_surface_v4': renderSurfaceV4,
          'runtime_bundle': runtimeBundle,
          'tap_zone_reinforcement_v4': tapZoneReinforcementV4,
          'typography_blend_v4': typographyBlendV4,
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

    final bool harnessReady =
        missing.isEmpty && domains.values.every(domainReady);

    return <String, Object>{
      'table_v4_self_check_harness_v1': <String, Object>{
        'domains': domains,
        'missing': missing,
        'harness_ready': harnessReady,
      },
      'readiness': harnessReady,
    };
  }
}

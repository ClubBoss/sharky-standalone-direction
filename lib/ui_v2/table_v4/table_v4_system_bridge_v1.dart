import 'dart:collection';

class TableV4SystemBridgeV1 {
  TableV4SystemBridgeV1(
    this.v4SelfCheckHarness,
    this.v4DemoSurfaceSnapshot,
    this.v4FinalReadinessGate,
    this.v4RuntimeBundle,
    this.v4FinalVisualUnifier,
    this.v4InteractionPolish,
    this.v4ActionAffordances,
    this.v4Animations,
    this.v4Highlights,
    this.v4TapZoneReinforcement,
    this.v4VisualSnapshot,
    this.v4RenderSurface,
    this.v4VisualSurface,
    this.v4InteractionEnvelope,
    this.v4TypographyBlend,
    this.v4VisualSeal,
    this.v4ViewportIntegrityGuard,
    this.v4DeviceFusionValidator,
  );

  final Object v4SelfCheckHarness;
  final Object v4DemoSurfaceSnapshot;
  final Object v4FinalReadinessGate;
  final Object v4RuntimeBundle;
  final Object v4FinalVisualUnifier;
  final Object v4InteractionPolish;
  final Object v4ActionAffordances;
  final Object v4Animations;
  final Object v4Highlights;
  final Object v4TapZoneReinforcement;
  final Object v4VisualSnapshot;
  final Object v4RenderSurface;
  final Object v4VisualSurface;
  final Object v4InteractionEnvelope;
  final Object v4TypographyBlend;
  final Object v4VisualSeal;
  final Object v4ViewportIntegrityGuard;
  final Object v4DeviceFusionValidator;

  Map<String, Object> asReadOnlyMap() {
    final SplayTreeMap<String, Object?> domains =
        SplayTreeMap<String, Object?>.from(<String, Object?>{
          'action_affordances_v4': v4ActionAffordances,
          'animations_v4': v4Animations,
          'device_fusion_validator': v4DeviceFusionValidator,
          'demo_surface_snapshot_v4': v4DemoSurfaceSnapshot,
          'final_readiness_gate_v4': v4FinalReadinessGate,
          'final_visual_unifier_v4': v4FinalVisualUnifier,
          'highlights_v4': v4Highlights,
          'interaction_envelope_v4': v4InteractionEnvelope,
          'interaction_polish_v4': v4InteractionPolish,
          'render_surface_v4': v4RenderSurface,
          'runtime_bundle_v4': v4RuntimeBundle,
          'self_check_harness_v4': v4SelfCheckHarness,
          'tap_zone_reinforcement_v4': v4TapZoneReinforcement,
          'typography_blend_v4': v4TypographyBlend,
          'viewport_integrity_guard_v4': v4ViewportIntegrityGuard,
          'visual_seal_v4': v4VisualSeal,
          'visual_snapshot_v4': v4VisualSnapshot,
          'visual_surface_v4': v4VisualSurface,
        });

    bool domainReady(Object? value) =>
        value is Map && value.isNotEmpty && value['readiness'] == true;

    final List<String> missing = domains.entries
        .where((entry) => !domainReady(entry.value))
        .map((entry) => entry.key)
        .toList();

    final bool bridgeReady =
        missing.isEmpty && domains.values.every(domainReady);

    return <String, Object>{
      'table_v4_system_bridge_v1': <String, Object>{
        'domains': domains,
        'missing': missing,
        'bridge_ready': bridgeReady,
      },
      'readiness': bridgeReady,
    };
  }
}

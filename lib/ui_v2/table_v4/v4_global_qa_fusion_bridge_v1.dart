import 'dart:collection';

class V4GlobalQAFusionBridgeV1 {
  V4GlobalQAFusionBridgeV1(
    this.v4SystemVerdictAdapter,
    this.v4SystemBridge,
    this.v4SelfCheckHarness,
    this.v4FinalReadinessGate,
    this.v4RuntimeBundle,
    this.v4ViewportIntegrityGuard,
    this.v4DeviceFusionValidator,
    this.systemQACrown,
    this.deepSystemVerdict,
    this.qaStructuralSeal,
    this.qaCompletionSeal,
    this.stabilitySnapshot,
  );

  final Object v4SystemVerdictAdapter;
  final Object v4SystemBridge;
  final Object v4SelfCheckHarness;
  final Object v4FinalReadinessGate;
  final Object v4RuntimeBundle;
  final Object v4ViewportIntegrityGuard;
  final Object v4DeviceFusionValidator;
  final Object systemQACrown;
  final Object deepSystemVerdict;
  final Object qaStructuralSeal;
  final Object qaCompletionSeal;
  final Object stabilitySnapshot;

  Map<String, Object> asReadOnlyMap() {
    final SplayTreeMap<String, Object?> domains =
        SplayTreeMap<String, Object?>.from(<String, Object?>{
          'deep_system_verdict': deepSystemVerdict,
          'device_fusion_validator_v4': v4DeviceFusionValidator,
          'final_readiness_gate_v4': v4FinalReadinessGate,
          'qa_completion_seal': qaCompletionSeal,
          'qa_structural_seal': qaStructuralSeal,
          'runtime_bundle_v4': v4RuntimeBundle,
          'self_check_harness_v4': v4SelfCheckHarness,
          'stability_snapshot': stabilitySnapshot,
          'system_bridge_v4': v4SystemBridge,
          'system_qa_crown': systemQACrown,
          'system_verdict_adapter_v4': v4SystemVerdictAdapter,
          'viewport_integrity_guard_v4': v4ViewportIntegrityGuard,
        });

    bool domainReady(Object? value) =>
        value is Map && value.isNotEmpty && value['readiness'] == true;

    final List<String> missing = domains.entries
        .where((entry) => !domainReady(entry.value))
        .map((entry) => entry.key)
        .toList();

    final bool fusionReady =
        missing.isEmpty && domains.values.every(domainReady);

    return <String, Object>{
      'v4_global_qa_fusion_bridge_v1': <String, Object>{
        'domains': domains,
        'missing': missing,
        'fusion_ready': fusionReady,
      },
      'readiness': fusionReady,
    };
  }
}

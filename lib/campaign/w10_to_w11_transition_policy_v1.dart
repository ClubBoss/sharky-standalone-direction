import 'package:poker_analyzer/campaign/w11_route_backed_proof_registry_v1.dart';

/// Descriptor-only W10-to-W11 transition policy.
///
/// This does not activate handoff. It records the minimum conditions that must
/// be proven before W10 can point at the W11 source route proof.
class W10ToW11TransitionPolicyV1 {
  const W10ToW11TransitionPolicyV1({
    required this.sourceTerminalPackId,
    required this.targetRouteProofId,
    required this.activeHandoffEnabled,
    required this.requiresLearnerVisibleW11,
    required this.requiresRuntimeConsumption,
    required this.impliesVolumeICompletion,
    required this.allowsW13Unlock,
    required this.descriptorOnly,
  });

  final String sourceTerminalPackId;
  final String targetRouteProofId;
  final bool activeHandoffEnabled;
  final bool requiresLearnerVisibleW11;
  final bool requiresRuntimeConsumption;
  final bool impliesVolumeICompletion;
  final bool allowsW13Unlock;
  final bool descriptorOnly;
}

W10ToW11TransitionPolicyV1 buildW10ToW11TransitionPolicyV1(
  W11RouteBackedProofV1 proof,
) {
  return W10ToW11TransitionPolicyV1(
    sourceTerminalPackId: 'world10_spine_campaign_v1',
    targetRouteProofId: proof.routeId,
    activeHandoffEnabled: false,
    requiresLearnerVisibleW11: true,
    requiresRuntimeConsumption: true,
    impliesVolumeICompletion: false,
    allowsW13Unlock: false,
    descriptorOnly: true,
  );
}

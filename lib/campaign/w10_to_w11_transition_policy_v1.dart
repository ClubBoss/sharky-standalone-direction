import 'package:poker_analyzer/campaign/w11_route_backed_proof_registry_v1.dart';

/// W10-to-W11 transition policy.
///
/// This records the active W10 handoff into W11 and keeps downstream claims
/// blocked. It does not imply W12, W13, Volume I completion, commercial
/// readiness, or public learning-effect readiness.
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
    sourceTerminalPackId: 'world10_spine_followup_v1_b2',
    targetRouteProofId: proof.routeId,
    activeHandoffEnabled: true,
    requiresLearnerVisibleW11: true,
    requiresRuntimeConsumption: false,
    impliesVolumeICompletion: false,
    allowsW13Unlock: false,
    descriptorOnly: false,
  );
}

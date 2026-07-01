import 'package:poker_analyzer/campaign/w11_route_backed_proof_registry_v1.dart';

enum W11VolumeIAdmissionStateV1 { activeRouteAdmittedW12Locked }

/// W11 Volume I admission descriptor.
///
/// This records the strongest currently safe state: W11 has active route entry
/// from W10, while W12, W13, Volume I completion, commercial, AI, and mastery
/// claims remain blocked.
class W11VolumeIAdmissionPolicyV1 {
  const W11VolumeIAdmissionPolicyV1({
    required this.state,
    required this.routeProofId,
    required this.surfaceOwner,
    required this.surfaceCopyKey,
    required this.learnerVisibleAsPlannedContinuation,
    required this.activeEntryEnabled,
    required this.w10HandoffEnabled,
    required this.runtimeConsumptionEnabled,
    required this.requiresRuntimeConsumptionBeforeActiveEntry,
    required this.w12PlannedOnly,
    required this.w13FrontierOnly,
    required this.impliesVolumeICompletion,
    required this.allowsPremiumOrPaywallClaim,
    required this.allowsAiMasteryOrLeakClaim,
  });

  final W11VolumeIAdmissionStateV1 state;
  final String routeProofId;
  final String surfaceOwner;
  final String surfaceCopyKey;
  final bool learnerVisibleAsPlannedContinuation;
  final bool activeEntryEnabled;
  final bool w10HandoffEnabled;
  final bool runtimeConsumptionEnabled;
  final bool requiresRuntimeConsumptionBeforeActiveEntry;
  final bool w12PlannedOnly;
  final bool w13FrontierOnly;
  final bool impliesVolumeICompletion;
  final bool allowsPremiumOrPaywallClaim;
  final bool allowsAiMasteryOrLeakClaim;
}

W11VolumeIAdmissionPolicyV1 buildW11VolumeIAdmissionPolicyV1(
  W11RouteBackedProofV1 proof,
) {
  return W11VolumeIAdmissionPolicyV1(
    state: W11VolumeIAdmissionStateV1.activeRouteAdmittedW12Locked,
    routeProofId: proof.routeId,
    surfaceOwner: 'Act0LearnPathShellV1',
    surfaceCopyKey: 'act0_shell_levels_planned_foundation_line',
    learnerVisibleAsPlannedContinuation: true,
    activeEntryEnabled: true,
    w10HandoffEnabled: true,
    runtimeConsumptionEnabled: true,
    requiresRuntimeConsumptionBeforeActiveEntry: false,
    w12PlannedOnly: true,
    w13FrontierOnly: true,
    impliesVolumeICompletion: false,
    allowsPremiumOrPaywallClaim: false,
    allowsAiMasteryOrLeakClaim: false,
  );
}

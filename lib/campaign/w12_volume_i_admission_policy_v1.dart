import 'package:poker_analyzer/campaign/w12_route_backed_proof_registry_v1.dart';

enum W12VolumeIAdmissionStateV1 { activeRouteAdmittedW13Locked }

/// W12 Volume I admission descriptor.
///
/// This records the safe state: W12 has active route entry from W11 while W13,
/// commercial readiness, public learning-effect claims, and final-quality
/// claims remain blocked.
class W12VolumeIAdmissionPolicyV1 {
  const W12VolumeIAdmissionPolicyV1({
    required this.state,
    required this.routeProofId,
    required this.surfaceOwner,
    required this.surfaceCopyKey,
    required this.learnerVisibleAsPlannedContinuation,
    required this.activeEntryEnabled,
    required this.w11HandoffEnabled,
    required this.runtimeConsumptionEnabled,
    required this.requiresRuntimeConsumptionBeforeActiveEntry,
    required this.w13FrontierOnly,
    required this.impliesVolumeICompletion,
    required this.allowsPremiumOrPaywallClaim,
    required this.allowsAiMasteryOrLeakClaim,
  });

  final W12VolumeIAdmissionStateV1 state;
  final String routeProofId;
  final String surfaceOwner;
  final String surfaceCopyKey;
  final bool learnerVisibleAsPlannedContinuation;
  final bool activeEntryEnabled;
  final bool w11HandoffEnabled;
  final bool runtimeConsumptionEnabled;
  final bool requiresRuntimeConsumptionBeforeActiveEntry;
  final bool w13FrontierOnly;
  final bool impliesVolumeICompletion;
  final bool allowsPremiumOrPaywallClaim;
  final bool allowsAiMasteryOrLeakClaim;
}

W12VolumeIAdmissionPolicyV1 buildW12VolumeIAdmissionPolicyV1(
  W12RouteBackedProofV1 proof,
) {
  return W12VolumeIAdmissionPolicyV1(
    state: W12VolumeIAdmissionStateV1.activeRouteAdmittedW13Locked,
    routeProofId: proof.routeId,
    surfaceOwner: 'Act0LearnPathShellV1',
    surfaceCopyKey: 'act0_shell_levels_planned_foundation_line',
    learnerVisibleAsPlannedContinuation: true,
    activeEntryEnabled: true,
    w11HandoffEnabled: true,
    runtimeConsumptionEnabled: true,
    requiresRuntimeConsumptionBeforeActiveEntry: false,
    w13FrontierOnly: true,
    impliesVolumeICompletion: false,
    allowsPremiumOrPaywallClaim: false,
    allowsAiMasteryOrLeakClaim: false,
  );
}

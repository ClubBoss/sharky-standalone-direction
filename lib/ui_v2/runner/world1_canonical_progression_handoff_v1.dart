import 'package:flutter/widgets.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_continuation_control_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_continuation_state_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_local_policy_boundary_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_route_completion_boundary_v1.dart';

enum World1CanonicalProgressionTargetV1 {
  none,
  retryCurrentStep,
  advanceStep,
  startReviewPass,
  advanceReviewPass,
  openCheckpointResult,
  openCampaignSpineResult,
  openTablePracticeResult,
  closePack,
}

World1CanonicalProgressionTargetV1 resolveWorld1CanonicalProgressionTargetV1({
  required bool continueAdvancesFlow,
  required bool isInReviewPass,
  required bool hasReviewQueue,
  required bool isAtLastStep,
  required bool isCheckpointSession,
  required bool isCampaignSpineSession,
  required bool isTablePracticeSession,
  required bool isDailyRunSession,
}) {
  if (!continueAdvancesFlow) {
    return World1CanonicalProgressionTargetV1.retryCurrentStep;
  }
  if (isInReviewPass) {
    return World1CanonicalProgressionTargetV1.advanceReviewPass;
  }
  if (isAtLastStep && hasReviewQueue) {
    return World1CanonicalProgressionTargetV1.startReviewPass;
  }
  if (isCheckpointSession && isAtLastStep) {
    return World1CanonicalProgressionTargetV1.openCheckpointResult;
  }
  if (isCampaignSpineSession && isAtLastStep) {
    return World1CanonicalProgressionTargetV1.openCampaignSpineResult;
  }
  if (isTablePracticeSession && isAtLastStep) {
    return World1CanonicalProgressionTargetV1.openTablePracticeResult;
  }
  if (isDailyRunSession || isAtLastStep) {
    return World1CanonicalProgressionTargetV1.closePack;
  }
  return World1CanonicalProgressionTargetV1.advanceStep;
}

SharedLearnerLocalPolicyBoundaryV1 buildWorld1CanonicalLocalPolicyBoundaryV1({
  required bool outcomeVisible,
  required bool continueAdvancesFlow,
  required World1CanonicalProgressionTargetV1 progressionTarget,
  required String primaryLabel,
  required String? secondaryLabel,
  required bool isPrimaryBusy,
  required VoidCallback? onPrimaryPressed,
  required VoidCallback? onSecondaryPressed,
}) {
  final continuationState = buildWorld1CanonicalContinuationStateV1(
    outcomeVisible: outcomeVisible,
    continueAdvancesFlow: continueAdvancesFlow,
    progressionTarget: progressionTarget,
    primaryLabel: primaryLabel,
    secondaryLabel: secondaryLabel,
  );
  return SharedLearnerLocalPolicyBoundaryV1(
    continuationControlContract: SharedLearnerContinuationControlContractV1(
      continuationState: continuationState,
      isPrimaryBusy: isPrimaryBusy,
      onPrimaryPressed: onPrimaryPressed,
      onSecondaryPressed: onSecondaryPressed,
    ),
    routeCompletionBoundary: buildWorld1CanonicalRouteCompletionBoundaryV1(
      outcomeVisible: outcomeVisible,
      progressionTarget: progressionTarget,
      primaryLabel: primaryLabel,
      secondaryLabel: secondaryLabel,
      isPrimaryBusy: isPrimaryBusy,
      onPrimaryPressed: onPrimaryPressed,
      onSecondaryPressed: onSecondaryPressed,
    ),
  );
}

SharedLearnerRouteCompletionBoundaryV1
buildWorld1CanonicalRouteCompletionBoundaryV1({
  required bool outcomeVisible,
  required World1CanonicalProgressionTargetV1 progressionTarget,
  required String primaryLabel,
  required String? secondaryLabel,
  required bool isPrimaryBusy,
  required VoidCallback? onPrimaryPressed,
  required VoidCallback? onSecondaryPressed,
}) {
  if (!outcomeVisible) {
    return const SharedLearnerRouteCompletionBoundaryV1.hidden();
  }
  final primaryCategory = switch (progressionTarget) {
    World1CanonicalProgressionTargetV1.retryCurrentStep =>
      SharedLearnerTerminalControlCategoryV1.retryLike,
    World1CanonicalProgressionTargetV1.startReviewPass ||
    World1CanonicalProgressionTargetV1.advanceReviewPass =>
      SharedLearnerTerminalControlCategoryV1.reviewLike,
    World1CanonicalProgressionTargetV1.openCheckpointResult ||
    World1CanonicalProgressionTargetV1.openCampaignSpineResult ||
    World1CanonicalProgressionTargetV1.openTablePracticeResult =>
      SharedLearnerTerminalControlCategoryV1.resultLike,
    World1CanonicalProgressionTargetV1.closePack =>
      SharedLearnerTerminalControlCategoryV1.closeLike,
    _ => SharedLearnerTerminalControlCategoryV1.continueLike,
  };
  return SharedLearnerRouteCompletionBoundaryV1(
    primaryAction: SharedLearnerTerminalControlActionV1.visible(
      category: primaryCategory,
      label: primaryLabel,
      onPressed: onPrimaryPressed,
      isBusy: isPrimaryBusy,
    ),
    secondaryAction: secondaryLabel == null || onSecondaryPressed == null
        ? const SharedLearnerTerminalControlActionV1.hidden()
        : SharedLearnerTerminalControlActionV1.visible(
            category: SharedLearnerTerminalControlCategoryV1.retryLike,
            label: secondaryLabel,
            onPressed: onSecondaryPressed,
          ),
  );
}

SharedLearnerContinuationStateV1 buildWorld1CanonicalContinuationStateV1({
  required bool outcomeVisible,
  required bool continueAdvancesFlow,
  required World1CanonicalProgressionTargetV1 progressionTarget,
  required String primaryLabel,
  required String? secondaryLabel,
}) {
  if (!outcomeVisible) {
    return const SharedLearnerContinuationStateV1.hidden();
  }
  final visualState = switch (progressionTarget) {
    World1CanonicalProgressionTargetV1.retryCurrentStep =>
      SharedLearnerContinuationVisualStateV1.retryLike,
    World1CanonicalProgressionTargetV1.openCheckpointResult ||
    World1CanonicalProgressionTargetV1.openCampaignSpineResult ||
    World1CanonicalProgressionTargetV1.openTablePracticeResult ||
    World1CanonicalProgressionTargetV1.closePack =>
      SharedLearnerContinuationVisualStateV1.completionLike,
    _ =>
      continueAdvancesFlow
          ? SharedLearnerContinuationVisualStateV1.continueLike
          : SharedLearnerContinuationVisualStateV1.retryLike,
  };
  return SharedLearnerContinuationStateV1.visible(
    visualState: visualState,
    primaryLabel: primaryLabel,
    secondaryLabel: secondaryLabel,
  );
}

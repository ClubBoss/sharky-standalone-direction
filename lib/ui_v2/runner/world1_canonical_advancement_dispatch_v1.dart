import 'package:poker_analyzer/ui_v2/runner/world1_canonical_progression_handoff_v1.dart';

typedef World1CanonicalAsyncCallbackV1 = Future<void> Function();

enum World1CanonicalModeCompletionActionV1 {
  completeReviewQueueSession,
  completeCheckpointResult,
  completeCampaignSpineResult,
  completeTablePracticeResult,
  closePack,
  advanceStep,
}

enum World1CanonicalReviewAdvanceActionV1 {
  delegateToModeCompletion,
  clearReviewAndDelegateToModeCompletion,
  applyNextReviewCursor,
}

World1CanonicalModeCompletionActionV1
resolveWorld1CanonicalModeCompletionActionV1({
  required bool isReviewQueueSession,
  required bool isCheckpointSession,
  required bool isCampaignSpineSession,
  required bool isTablePracticeSession,
  required bool isDailyRunSession,
  required bool isAtLastStep,
}) {
  if (isReviewQueueSession) {
    return World1CanonicalModeCompletionActionV1.completeReviewQueueSession;
  }
  if (isCheckpointSession) {
    return World1CanonicalModeCompletionActionV1.completeCheckpointResult;
  }
  if (isCampaignSpineSession) {
    return World1CanonicalModeCompletionActionV1.completeCampaignSpineResult;
  }
  if (isTablePracticeSession) {
    return World1CanonicalModeCompletionActionV1.completeTablePracticeResult;
  }
  if (isDailyRunSession || isAtLastStep) {
    return World1CanonicalModeCompletionActionV1.closePack;
  }
  return World1CanonicalModeCompletionActionV1.advanceStep;
}

World1CanonicalReviewAdvanceActionV1
resolveWorld1CanonicalReviewAdvanceActionV1({
  required bool isInReviewPass,
  required bool isLastReviewStep,
}) {
  if (!isInReviewPass) {
    return World1CanonicalReviewAdvanceActionV1.delegateToModeCompletion;
  }
  if (isLastReviewStep) {
    return World1CanonicalReviewAdvanceActionV1
        .clearReviewAndDelegateToModeCompletion;
  }
  return World1CanonicalReviewAdvanceActionV1.applyNextReviewCursor;
}

class World1CanonicalAdvancementCallbacksV1 {
  const World1CanonicalAdvancementCallbacksV1({
    required this.onAdvanceReviewQueue,
    required this.onStartReviewPass,
    required this.onOpenCheckpointResult,
    required this.onOpenCampaignSpineResult,
    required this.onOpenTablePracticeResult,
    required this.onClosePack,
    required this.onAdvanceStep,
  });

  final World1CanonicalAsyncCallbackV1 onAdvanceReviewQueue;
  final World1CanonicalAsyncCallbackV1 onStartReviewPass;
  final World1CanonicalAsyncCallbackV1 onOpenCheckpointResult;
  final World1CanonicalAsyncCallbackV1 onOpenCampaignSpineResult;
  final World1CanonicalAsyncCallbackV1 onOpenTablePracticeResult;
  final World1CanonicalAsyncCallbackV1 onClosePack;
  final World1CanonicalAsyncCallbackV1 onAdvanceStep;
}

Future<void> runWorld1CanonicalProgressionDispatchV1({
  required World1CanonicalProgressionTargetV1 target,
  required World1CanonicalAdvancementCallbacksV1 callbacks,
}) async {
  switch (target) {
    case World1CanonicalProgressionTargetV1.none:
    case World1CanonicalProgressionTargetV1.retryCurrentStep:
      return;
    case World1CanonicalProgressionTargetV1.advanceReviewPass:
      await callbacks.onAdvanceReviewQueue();
      return;
    case World1CanonicalProgressionTargetV1.startReviewPass:
      await callbacks.onStartReviewPass();
      return;
    case World1CanonicalProgressionTargetV1.openCheckpointResult:
      await callbacks.onOpenCheckpointResult();
      return;
    case World1CanonicalProgressionTargetV1.openCampaignSpineResult:
      await callbacks.onOpenCampaignSpineResult();
      return;
    case World1CanonicalProgressionTargetV1.openTablePracticeResult:
      await callbacks.onOpenTablePracticeResult();
      return;
    case World1CanonicalProgressionTargetV1.closePack:
      await callbacks.onClosePack();
      return;
    case World1CanonicalProgressionTargetV1.advanceStep:
      await callbacks.onAdvanceStep();
      return;
  }
}

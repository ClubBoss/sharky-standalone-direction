enum World1CanonicalRunnerModeV1 { seatQuiz, handLoop }

World1CanonicalRunnerModeV1 resolveWorld1CanonicalRunnerModeV1({
  required bool isWorld2SeatQuizBeat,
  required bool stepIndicatesActionDecision,
  required bool isCampaignSpineSession,
  required bool packContainsTableLiteracy,
  required bool hasCampaignPointer,
  required bool replayerHasSteps,
  required bool legalActionsPresent,
  required bool engineInteropAvailable,
}) {
  if (isWorld2SeatQuizBeat) {
    return World1CanonicalRunnerModeV1.seatQuiz;
  }
  if (!isCampaignSpineSession) {
    return World1CanonicalRunnerModeV1.seatQuiz;
  }
  if (stepIndicatesActionDecision) {
    return World1CanonicalRunnerModeV1.handLoop;
  }
  if (packContainsTableLiteracy) {
    return World1CanonicalRunnerModeV1.seatQuiz;
  }
  if (!hasCampaignPointer || !replayerHasSteps || !legalActionsPresent) {
    return stepIndicatesActionDecision
        ? World1CanonicalRunnerModeV1.handLoop
        : World1CanonicalRunnerModeV1.seatQuiz;
  }
  if (!engineInteropAvailable) {
    return stepIndicatesActionDecision
        ? World1CanonicalRunnerModeV1.handLoop
        : World1CanonicalRunnerModeV1.seatQuiz;
  }
  return World1CanonicalRunnerModeV1.handLoop;
}

class World1CanonicalRunnerAuthorityStateV1 {
  const World1CanonicalRunnerAuthorityStateV1({
    required this.runnerMode,
    required this.isReviewPass,
    required this.outcomeVisible,
    required this.actionStateAvailable,
    required this.visibleBoardCount,
    required this.handLoopMode,
  });

  final World1CanonicalRunnerModeV1 runnerMode;
  final bool isReviewPass;
  final bool outcomeVisible;
  final bool actionStateAvailable;
  final int visibleBoardCount;
  final bool handLoopMode;

  bool get showHandLoopActionBar =>
      handLoopMode && !outcomeVisible && actionStateAvailable;
}

World1CanonicalRunnerAuthorityStateV1 buildWorld1CanonicalRunnerAuthorityV1({
  required World1CanonicalRunnerModeV1 runnerMode,
  required bool isReviewPass,
  required bool outcomeVisible,
  required bool actionStateAvailable,
  required int visibleBoardCount,
  required bool isCampaignSpineSession,
  required bool forceHandLoopSurfaceForTest,
  required bool isDemoHandLoopVisualStep,
}) {
  final handLoopMode =
      (isCampaignSpineSession &&
          runnerMode == World1CanonicalRunnerModeV1.handLoop) ||
      forceHandLoopSurfaceForTest ||
      isDemoHandLoopVisualStep;
  return World1CanonicalRunnerAuthorityStateV1(
    runnerMode: runnerMode,
    isReviewPass: isReviewPass,
    outcomeVisible: outcomeVisible,
    actionStateAvailable: actionStateAvailable,
    visibleBoardCount: visibleBoardCount,
    handLoopMode: handLoopMode,
  );
}

enum World1CanonicalTableRenderBranchV1 { seatQuiz, handLoop }

class World1CanonicalTableRenderBranchStateV1 {
  const World1CanonicalTableRenderBranchStateV1({
    required this.branch,
    required this.seatQuizVisualMode,
    required this.handLoopVisualMode,
    required this.showCampaignHandVisuals,
    required this.targetSeatId,
  });

  final World1CanonicalTableRenderBranchV1 branch;
  final bool seatQuizVisualMode;
  final bool handLoopVisualMode;
  final bool showCampaignHandVisuals;
  final String? targetSeatId;
}

World1CanonicalTableRenderBranchStateV1
buildWorld1CanonicalTableRenderBranchV1({
  required bool currentModeIsSeatQuiz,
  required bool currentModeIsHandLoop,
  required bool stepIndicatesActionDecision,
  required bool isDemoHandLoopVisualStep,
  required bool forceHandLoopSurfaceForTest,
  required bool showEngineV2StreetUi,
  required int visibleBoardCount,
  required String? seatQuizTargetSeatId,
}) {
  final seatQuizVisualMode =
      currentModeIsSeatQuiz &&
      !isDemoHandLoopVisualStep &&
      !forceHandLoopSurfaceForTest;
  final handLoopVisualMode =
      !seatQuizVisualMode &&
      (forceHandLoopSurfaceForTest ||
          stepIndicatesActionDecision ||
          currentModeIsHandLoop ||
          isDemoHandLoopVisualStep);
  return World1CanonicalTableRenderBranchStateV1(
    branch: handLoopVisualMode
        ? World1CanonicalTableRenderBranchV1.handLoop
        : World1CanonicalTableRenderBranchV1.seatQuiz,
    seatQuizVisualMode: seatQuizVisualMode,
    handLoopVisualMode: handLoopVisualMode,
    showCampaignHandVisuals:
        handLoopVisualMode || showEngineV2StreetUi || visibleBoardCount > 0,
    targetSeatId: seatQuizVisualMode ? seatQuizTargetSeatId : null,
  );
}

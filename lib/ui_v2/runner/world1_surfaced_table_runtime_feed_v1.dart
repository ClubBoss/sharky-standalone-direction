import 'package:poker_analyzer/ui_v2/runner/world1_canonical_table_render_branch_v1.dart';

class World1SurfacedTableRenderFeedInputV1 {
  const World1SurfacedTableRenderFeedInputV1({
    required this.currentModeIsSeatQuiz,
    required this.currentModeIsHandLoop,
    required this.stepIndicatesActionDecision,
    required this.isDemoHandLoopVisualStep,
    required this.forceHandLoopSurfaceForTest,
    required this.showEngineV2StreetUi,
    required this.visibleBoardCount,
    required this.seatQuizTargetSeatId,
  });

  final bool currentModeIsSeatQuiz;
  final bool currentModeIsHandLoop;
  final bool stepIndicatesActionDecision;
  final bool isDemoHandLoopVisualStep;
  final bool forceHandLoopSurfaceForTest;
  final bool showEngineV2StreetUi;
  final int visibleBoardCount;
  final String? seatQuizTargetSeatId;
}

World1CanonicalTableRenderBranchStateV1 resolveWorld1SurfacedTableRenderFeedV1(
  World1SurfacedTableRenderFeedInputV1 input,
) {
  return buildWorld1CanonicalTableRenderBranchV1(
    currentModeIsSeatQuiz: input.currentModeIsSeatQuiz,
    currentModeIsHandLoop: input.currentModeIsHandLoop,
    stepIndicatesActionDecision: input.stepIndicatesActionDecision,
    isDemoHandLoopVisualStep: input.isDemoHandLoopVisualStep,
    forceHandLoopSurfaceForTest: input.forceHandLoopSurfaceForTest,
    showEngineV2StreetUi: input.showEngineV2StreetUi,
    visibleBoardCount: input.visibleBoardCount,
    seatQuizTargetSeatId: input.seatQuizTargetSeatId,
  );
}

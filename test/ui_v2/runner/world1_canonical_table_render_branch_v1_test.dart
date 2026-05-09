import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_table_render_branch_v1.dart';

void main() {
  test('world1 canonical table render branch resolves seat quiz branch', () {
    final branch = buildWorld1CanonicalTableRenderBranchV1(
      currentModeIsSeatQuiz: true,
      currentModeIsHandLoop: false,
      stepIndicatesActionDecision: false,
      isDemoHandLoopVisualStep: false,
      forceHandLoopSurfaceForTest: false,
      showEngineV2StreetUi: false,
      visibleBoardCount: 0,
      seatQuizTargetSeatId: 'btn',
    );

    expect(branch.branch, World1CanonicalTableRenderBranchV1.seatQuiz);
    expect(branch.seatQuizVisualMode, isTrue);
    expect(branch.handLoopVisualMode, isFalse);
    expect(branch.showCampaignHandVisuals, isFalse);
    expect(branch.targetSeatId, 'btn');
  });

  test('world1 canonical table render branch resolves hand loop branch', () {
    final branch = buildWorld1CanonicalTableRenderBranchV1(
      currentModeIsSeatQuiz: false,
      currentModeIsHandLoop: true,
      stepIndicatesActionDecision: true,
      isDemoHandLoopVisualStep: false,
      forceHandLoopSurfaceForTest: false,
      showEngineV2StreetUi: true,
      visibleBoardCount: 3,
      seatQuizTargetSeatId: 'co',
    );

    expect(branch.branch, World1CanonicalTableRenderBranchV1.handLoop);
    expect(branch.seatQuizVisualMode, isFalse);
    expect(branch.handLoopVisualMode, isTrue);
    expect(branch.showCampaignHandVisuals, isTrue);
    expect(branch.targetSeatId, isNull);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_runner_authority_v1.dart';

void main() {
  test('world1 canonical runner mode resolves seat quiz and hand loop', () {
    expect(
      resolveWorld1CanonicalRunnerModeV1(
        isWorld2SeatQuizBeat: true,
        stepIndicatesActionDecision: true,
        isCampaignSpineSession: true,
        packContainsTableLiteracy: false,
        hasCampaignPointer: true,
        replayerHasSteps: true,
        legalActionsPresent: true,
        engineInteropAvailable: true,
      ),
      World1CanonicalRunnerModeV1.seatQuiz,
    );

    expect(
      resolveWorld1CanonicalRunnerModeV1(
        isWorld2SeatQuizBeat: false,
        stepIndicatesActionDecision: true,
        isCampaignSpineSession: true,
        packContainsTableLiteracy: false,
        hasCampaignPointer: true,
        replayerHasSteps: true,
        legalActionsPresent: true,
        engineInteropAvailable: true,
      ),
      World1CanonicalRunnerModeV1.handLoop,
    );
  });

  test(
    'world1 canonical runner authority exposes hand-loop action bar state',
    () {
      final authority = buildWorld1CanonicalRunnerAuthorityV1(
        runnerMode: World1CanonicalRunnerModeV1.handLoop,
        isReviewPass: false,
        outcomeVisible: false,
        actionStateAvailable: true,
        visibleBoardCount: 2,
        isCampaignSpineSession: true,
        forceHandLoopSurfaceForTest: false,
        isDemoHandLoopVisualStep: false,
      );

      expect(authority.handLoopMode, isTrue);
      expect(authority.showHandLoopActionBar, isTrue);
      expect(authority.visibleBoardCount, 2);
    },
  );
}

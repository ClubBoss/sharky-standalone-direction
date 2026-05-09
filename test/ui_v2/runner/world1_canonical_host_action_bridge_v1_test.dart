import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/engine_v2/engine_v2.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_host_action_bridge_v1.dart';

void main() {
  test(
    'campaign action tap plan blocks on lock-in and forwards hero action',
    () {
      const action = ActionV1(
        actorId: PlayerIdV1('hero'),
        kind: ActionKindV1.call,
      );

      final blocked = resolveWorld1CanonicalCampaignActionTapPlanV1(
        isLockInBlocked: true,
        action: action,
      );
      final allowed = resolveWorld1CanonicalCampaignActionTapPlanV1(
        isLockInBlocked: false,
        action: action,
      );

      expect(blocked.shouldIgnoreTap, isTrue);
      expect(blocked.shouldMarkDecisionTap, isFalse);
      expect(blocked.heroActionOverride, isNull);

      expect(allowed.shouldIgnoreTap, isFalse);
      expect(allowed.shouldMarkDecisionTap, isTrue);
      expect(allowed.heroActionOverride, same(action));
    },
  );

  test('seat tap plan routes auto-check only for active spine seat quiz', () {
    final plan = resolveWorld1CanonicalSeatTapPlanV1(
      seatId: 'btn',
      currentModeIsSeatQuiz: true,
      introStepRequiresSeatTap: false,
      introStepSeatId: null,
      isCampaignSpineSession: true,
      campaignSeatQuizMode: true,
      showSeatQuizPrelude: false,
      showIntroSequence: false,
      outcomeSurfaceVisible: false,
      completionInProgress: false,
    );

    expect(plan.shouldPlayTapSound, isTrue);
    expect(plan.shouldMarkDecisionTap, isTrue);
    expect(plan.shouldDismissInteractivePreludes, isTrue);
    expect(plan.selectionState.shouldIgnoreTap, isFalse);
    expect(plan.selectionState.selectedSeatId, 'btn');
    expect(plan.selectionState.shouldAutoRunSeatQuizCheck, isTrue);
  });

  test(
    'check plan routes to hand loop only for campaign spine hand loop mode',
    () {
      final seatQuiz = resolveWorld1CanonicalCheckPlanV1(
        isWorld2SeatQuizBeat: false,
        isCampaignSpineSession: false,
        currentModeIsHandLoop: false,
      );
      final handLoop = resolveWorld1CanonicalCheckPlanV1(
        isWorld2SeatQuizBeat: false,
        isCampaignSpineSession: true,
        currentModeIsHandLoop: true,
      );

      expect(seatQuiz.route, World1CanonicalCheckRouteV1.seatQuizCheck);
      expect(handLoop.route, World1CanonicalCheckRouteV1.handLoopRun);
    },
  );

  test(
    'intro continue states resolve prelude and sequence transitions canonically',
    () {
      final prelude = resolveWorld1CanonicalSeatQuizPreludeContinueStateV1(
        firstIntroStepRequiresSeatTap: false,
      );
      final sequence = resolveWorld1CanonicalIntroSequenceContinueStateV1(
        isIntroContinueEnabled: true,
        introSequenceIndex: 0,
        totalIntroSteps: 3,
        nextStepRequiresSeatTap: true,
      );

      expect(prelude.preludeDismissed, isTrue);
      expect(prelude.introDismissed, isFalse);
      expect(prelude.introSequenceIndex, 0);
      expect(prelude.introStepSatisfied, isTrue);
      expect(prelude.selectedSeatId, isNull);

      expect(sequence.shouldIgnore, isFalse);
      expect(sequence.introDismissed, isFalse);
      expect(sequence.introSequenceIndex, 1);
      expect(sequence.introStepSatisfied, isFalse);
      expect(sequence.selectedSeatId, isNull);
    },
  );
}

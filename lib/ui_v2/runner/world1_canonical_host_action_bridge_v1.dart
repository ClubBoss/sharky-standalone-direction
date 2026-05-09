import 'package:poker_analyzer/engine_v2/engine_v2.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_host_interaction_state_adapter_v1.dart';

class World1CanonicalCampaignActionTapPlanV1 {
  const World1CanonicalCampaignActionTapPlanV1({
    required this.shouldIgnoreTap,
    required this.shouldMarkDecisionTap,
    required this.heroActionOverride,
  });

  final bool shouldIgnoreTap;
  final bool shouldMarkDecisionTap;
  final ActionV1? heroActionOverride;
}

World1CanonicalCampaignActionTapPlanV1
resolveWorld1CanonicalCampaignActionTapPlanV1({
  required bool isLockInBlocked,
  required ActionV1 action,
}) {
  if (isLockInBlocked) {
    return const World1CanonicalCampaignActionTapPlanV1(
      shouldIgnoreTap: true,
      shouldMarkDecisionTap: false,
      heroActionOverride: null,
    );
  }
  return World1CanonicalCampaignActionTapPlanV1(
    shouldIgnoreTap: false,
    shouldMarkDecisionTap: true,
    heroActionOverride: action,
  );
}

class World1CanonicalSeatTapPlanV1 {
  const World1CanonicalSeatTapPlanV1({
    required this.shouldPlayTapSound,
    required this.shouldMarkDecisionTap,
    required this.shouldDismissInteractivePreludes,
    required this.selectionState,
  });

  final bool shouldPlayTapSound;
  final bool shouldMarkDecisionTap;
  final bool shouldDismissInteractivePreludes;
  final World1CanonicalSeatSelectionResolvedV1 selectionState;
}

World1CanonicalSeatTapPlanV1 resolveWorld1CanonicalSeatTapPlanV1({
  required String seatId,
  required bool currentModeIsSeatQuiz,
  required bool introStepRequiresSeatTap,
  required String? introStepSeatId,
  required bool isCampaignSpineSession,
  required bool campaignSeatQuizMode,
  required bool showSeatQuizPrelude,
  required bool showIntroSequence,
  required bool outcomeSurfaceVisible,
  required bool completionInProgress,
}) {
  return World1CanonicalSeatTapPlanV1(
    shouldPlayTapSound: true,
    shouldMarkDecisionTap: currentModeIsSeatQuiz,
    shouldDismissInteractivePreludes: true,
    selectionState: resolveWorld1CanonicalSeatSelectionV1(
      World1CanonicalSeatSelectionInputV1(
        seatId: seatId,
        introStepRequiresSeatTap: introStepRequiresSeatTap,
        introStepSeatId: introStepSeatId,
        isCampaignSpineSession: isCampaignSpineSession,
        campaignSeatQuizMode: campaignSeatQuizMode,
        showSeatQuizPrelude: showSeatQuizPrelude,
        showIntroSequence: showIntroSequence,
        outcomeSurfaceVisible: outcomeSurfaceVisible,
        completionInProgress: completionInProgress,
      ),
    ),
  );
}

enum World1CanonicalCheckRouteV1 { seatQuizCheck, handLoopRun }

class World1CanonicalCheckPlanV1 {
  const World1CanonicalCheckPlanV1({
    required this.shouldMarkDecisionTap,
    required this.route,
  });

  final bool shouldMarkDecisionTap;
  final World1CanonicalCheckRouteV1 route;
}

World1CanonicalCheckPlanV1 resolveWorld1CanonicalCheckPlanV1({
  required bool isWorld2SeatQuizBeat,
  required bool isCampaignSpineSession,
  required bool currentModeIsHandLoop,
}) {
  return World1CanonicalCheckPlanV1(
    shouldMarkDecisionTap: true,
    route:
        isWorld2SeatQuizBeat ||
            !isCampaignSpineSession ||
            !currentModeIsHandLoop
        ? World1CanonicalCheckRouteV1.seatQuizCheck
        : World1CanonicalCheckRouteV1.handLoopRun,
  );
}

class World1CanonicalSeatQuizPreludeContinueStateV1 {
  const World1CanonicalSeatQuizPreludeContinueStateV1({
    required this.preludeDismissed,
    required this.introDismissed,
    required this.introSequenceIndex,
    required this.introStepSatisfied,
    required this.selectedSeatId,
  });

  final bool preludeDismissed;
  final bool introDismissed;
  final int introSequenceIndex;
  final bool introStepSatisfied;
  final String? selectedSeatId;
}

World1CanonicalSeatQuizPreludeContinueStateV1
resolveWorld1CanonicalSeatQuizPreludeContinueStateV1({
  required bool firstIntroStepRequiresSeatTap,
}) {
  return World1CanonicalSeatQuizPreludeContinueStateV1(
    preludeDismissed: true,
    introDismissed: false,
    introSequenceIndex: 0,
    introStepSatisfied: !firstIntroStepRequiresSeatTap,
    selectedSeatId: null,
  );
}

class World1CanonicalIntroSequenceContinueStateV1 {
  const World1CanonicalIntroSequenceContinueStateV1({
    required this.shouldIgnore,
    required this.introDismissed,
    required this.introSequenceIndex,
    required this.introStepSatisfied,
    required this.selectedSeatId,
  });

  final bool shouldIgnore;
  final bool introDismissed;
  final int introSequenceIndex;
  final bool introStepSatisfied;
  final String? selectedSeatId;
}

World1CanonicalIntroSequenceContinueStateV1
resolveWorld1CanonicalIntroSequenceContinueStateV1({
  required bool isIntroContinueEnabled,
  required int introSequenceIndex,
  required int totalIntroSteps,
  required bool nextStepRequiresSeatTap,
}) {
  if (!isIntroContinueEnabled) {
    return const World1CanonicalIntroSequenceContinueStateV1(
      shouldIgnore: true,
      introDismissed: false,
      introSequenceIndex: 0,
      introStepSatisfied: false,
      selectedSeatId: null,
    );
  }
  final isLast = introSequenceIndex >= totalIntroSteps - 1;
  return World1CanonicalIntroSequenceContinueStateV1(
    shouldIgnore: false,
    introDismissed: isLast,
    introSequenceIndex: isLast ? introSequenceIndex : introSequenceIndex + 1,
    introStepSatisfied: isLast ? false : !nextStepRequiresSeatTap,
    selectedSeatId: null,
  );
}

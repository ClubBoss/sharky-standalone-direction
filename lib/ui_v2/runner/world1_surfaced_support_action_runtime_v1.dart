import 'package:poker_analyzer/engine_v2/decision/decision_bar_v1.dart';
import 'package:poker_analyzer/engine_v2/model/action_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_surfaced_composer_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_surfaced_runtime_feed_v1.dart';

class World1SurfacedActionStateV1 {
  const World1SurfacedActionStateV1({
    required this.pot,
    required this.toCall,
    required this.currentBet,
    required this.heroStack,
    required this.decisionModel,
    required this.actingSeatId,
    required this.inHandBySeatId,
    required this.foldedBySeatId,
    required this.toCallBySeatId,
    required this.committedBySeatId,
    required this.actingSeatToCall,
    required this.hasBetOwnerInState,
    this.lastActionSeatId,
    this.lastAggressorSeatId,
    this.priceSettingActionKindV1,
    this.betOwnerSeatId,
  });

  final int pot;
  final int toCall;
  final int currentBet;
  final int heroStack;
  final DecisionBarModelV1 decisionModel;
  final String actingSeatId;
  final Map<String, bool> inHandBySeatId;
  final Map<String, bool> foldedBySeatId;
  final Map<String, int> toCallBySeatId;
  final Map<String, int> committedBySeatId;
  final int actingSeatToCall;
  final String? lastActionSeatId;
  final String? lastAggressorSeatId;
  final ActionKindV1? priceSettingActionKindV1;
  final String? betOwnerSeatId;
  final bool hasBetOwnerInState;
}

enum World1SurfacedActionModeV1 {
  none,
  introContinue,
  outcome,
  seatQuizConfirm,
  handLoopBar,
  hiddenConfirmGhost,
}

class World1SurfacedSupportActionRuntimeInputV1 {
  const World1SurfacedSupportActionRuntimeInputV1({
    required this.showHandLoopActionBar,
    required this.allowSeatQuizConfirmPanel,
    required this.introCaptionActive,
    required this.lockInNeedsSeatSelection,
    required this.instructionPlacementFlowV1,
    required this.outcomeProgressionHandoffContractV1,
    required this.coachModeIsAction,
    required this.showIntroSequence,
    required this.outcomeSurfaceVisible,
    required this.hasHandLoopActionState,
  });

  final bool showHandLoopActionBar;
  final bool allowSeatQuizConfirmPanel;
  final bool introCaptionActive;
  final bool lockInNeedsSeatSelection;
  final World1SurfacedInstructionPlacementFlowV1 instructionPlacementFlowV1;
  final World1SurfacedOutcomeProgressionHandoffContractV1
  outcomeProgressionHandoffContractV1;
  final bool coachModeIsAction;
  final bool showIntroSequence;
  final bool outcomeSurfaceVisible;
  final bool hasHandLoopActionState;
}

class World1SurfacedSupportActionRuntimeStateV1 {
  const World1SurfacedSupportActionRuntimeStateV1({
    required this.showsPortraitIdleGuidance,
    required this.showsPortraitSeatQuizCoachStrip,
    required this.showsPortraitHandLoopCoachStrip,
    required this.showsLandscapeOutcomeStatus,
    required this.portraitActionMode,
    required this.landscapeActionMode,
  });

  final bool showsPortraitIdleGuidance;
  final bool showsPortraitSeatQuizCoachStrip;
  final bool showsPortraitHandLoopCoachStrip;
  final bool showsLandscapeOutcomeStatus;
  final World1SurfacedActionModeV1 portraitActionMode;
  final World1SurfacedActionModeV1 landscapeActionMode;
}

World1SurfacedSupportActionRuntimeStateV1
resolveWorld1SurfacedSupportActionRuntimeV1(
  World1SurfacedSupportActionRuntimeInputV1 input,
) {
  final portraitActionMode = input.introCaptionActive
      ? World1SurfacedActionModeV1.introContinue
      : input.outcomeProgressionHandoffContractV1.outcomeVisible
      ? World1SurfacedActionModeV1.outcome
      : (!input.showHandLoopActionBar &&
            input.allowSeatQuizConfirmPanel &&
            !input.introCaptionActive)
      ? World1SurfacedActionModeV1.seatQuizConfirm
      : input.showHandLoopActionBar && input.hasHandLoopActionState
      ? World1SurfacedActionModeV1.handLoopBar
      : (!input.showHandLoopActionBar &&
            !input.allowSeatQuizConfirmPanel &&
            !input.introCaptionActive &&
            !input.outcomeProgressionHandoffContractV1.outcomeVisible)
      ? World1SurfacedActionModeV1.hiddenConfirmGhost
      : (!input.showHandLoopActionBar &&
            input.allowSeatQuizConfirmPanel &&
            input.coachModeIsAction &&
            !input.introCaptionActive &&
            !input.outcomeProgressionHandoffContractV1.outcomeVisible)
      ? World1SurfacedActionModeV1.hiddenConfirmGhost
      : World1SurfacedActionModeV1.none;

  final landscapeActionMode =
      input.showHandLoopActionBar && input.hasHandLoopActionState
      ? World1SurfacedActionModeV1.handLoopBar
      : input.outcomeProgressionHandoffContractV1.outcomeVisible
      ? World1SurfacedActionModeV1.outcome
      : (!input.showHandLoopActionBar &&
            input.allowSeatQuizConfirmPanel &&
            !input.introCaptionActive)
      ? World1SurfacedActionModeV1.seatQuizConfirm
      : (!input.showHandLoopActionBar &&
            input.allowSeatQuizConfirmPanel &&
            input.coachModeIsAction &&
            !input.introCaptionActive &&
            !input.showIntroSequence &&
            !input.outcomeSurfaceVisible)
      ? World1SurfacedActionModeV1.hiddenConfirmGhost
      : (!input.showHandLoopActionBar &&
            !input.allowSeatQuizConfirmPanel &&
            !input.introCaptionActive &&
            !input.outcomeSurfaceVisible)
      ? World1SurfacedActionModeV1.hiddenConfirmGhost
      : World1SurfacedActionModeV1.none;

  return World1SurfacedSupportActionRuntimeStateV1(
    showsPortraitIdleGuidance:
        input.lockInNeedsSeatSelection &&
        input.allowSeatQuizConfirmPanel &&
        !input.instructionPlacementFlowV1.feltInstructionVisibleV1,
    showsPortraitSeatQuizCoachStrip:
        !input.instructionPlacementFlowV1.feltInstructionVisibleV1 &&
        input.instructionPlacementFlowV1.showSeatQuizCoachStripV1,
    showsPortraitHandLoopCoachStrip:
        !input.instructionPlacementFlowV1.feltInstructionVisibleV1 &&
        input.instructionPlacementFlowV1.showHandLoopCoachStripV1,
    showsLandscapeOutcomeStatus:
        input.outcomeProgressionHandoffContractV1.outcomeVisible,
    portraitActionMode: portraitActionMode,
    landscapeActionMode: landscapeActionMode,
  );
}

import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_table_instruction_surface_v1.dart';

class World1SurfacedHandLoopPromptSurfaceV1 {
  const World1SurfacedHandLoopPromptSurfaceV1({
    required this.isAffectedStateFamily,
    required this.usesFeltCaptionHost,
    required this.isMounted,
    required this.promptText,
    required this.reviewQueuePrefix,
  });

  final bool isAffectedStateFamily;
  final bool usesFeltCaptionHost;
  final bool isMounted;
  final String promptText;
  final bool reviewQueuePrefix;
}

class World1SurfacedInstructionPlacementFlowV1 {
  const World1SurfacedInstructionPlacementFlowV1({
    required this.seatQuizInstructionModeActiveV1,
    required this.seatQuizHeaderInstructionActiveV1,
    required this.useFeltOverlayAsPromptSourceV1,
    required this.compactHeaderUnderFeedbackPressureV1,
    required this.collapsePortraitHeaderForFeltCaptionV1,
    required this.showSeatQuizCoachStripV1,
    required this.showHandLoopCoachStripV1,
    required this.feltInstructionVisibleV1,
    required this.showBottomCoachStripV1,
    required this.showCompactInstructionOverlayV1,
    required this.hideStepPromptInHeaderV1,
  });

  final bool seatQuizInstructionModeActiveV1;
  final bool seatQuizHeaderInstructionActiveV1;
  final bool useFeltOverlayAsPromptSourceV1;
  final bool compactHeaderUnderFeedbackPressureV1;
  final bool collapsePortraitHeaderForFeltCaptionV1;
  final bool showSeatQuizCoachStripV1;
  final bool showHandLoopCoachStripV1;
  final bool feltInstructionVisibleV1;
  final bool showBottomCoachStripV1;
  final bool showCompactInstructionOverlayV1;
  final bool hideStepPromptInHeaderV1;
}

class World1SurfacedInstructionPlacementInputV1 {
  const World1SurfacedInstructionPlacementInputV1({
    required this.portraitLayout,
    required this.compactPortrait,
    required this.handLoopMode,
    required this.introCaptionActive,
    required this.showInstructionOverlay,
    required this.useRunnerCompactHeaderV1,
    required this.hasFeedbackTextV1,
    required this.awaitingSeatInput,
    required this.lockInNeedsSeatSelection,
    required this.allowSeatQuizConfirmPanelV1,
    required this.showHandLoopActionBar,
    required this.mediaSize,
    required this.outcomeSurfaceVisible,
    required this.showHintBubble,
    required this.showSeatQuizPrelude,
    required this.showIntroSequence,
    required this.campaignHudDetailsExpanded,
    required this.currentModeIsSeatQuiz,
    required this.isDemoHandLoopVisualStep,
    required this.handLoopPromptSurfaceV1,
  });

  final bool portraitLayout;
  final bool compactPortrait;
  final bool handLoopMode;
  final bool introCaptionActive;
  final bool showInstructionOverlay;
  final bool useRunnerCompactHeaderV1;
  final bool hasFeedbackTextV1;
  final bool awaitingSeatInput;
  final bool lockInNeedsSeatSelection;
  final bool allowSeatQuizConfirmPanelV1;
  final bool showHandLoopActionBar;
  final Size mediaSize;
  final bool outcomeSurfaceVisible;
  final bool showHintBubble;
  final bool showSeatQuizPrelude;
  final bool showIntroSequence;
  final bool campaignHudDetailsExpanded;
  final bool currentModeIsSeatQuiz;
  final bool isDemoHandLoopVisualStep;
  final World1SurfacedHandLoopPromptSurfaceV1? handLoopPromptSurfaceV1;
}

class World1SurfacedHandLoopPromptSurfaceInputV1 {
  const World1SurfacedHandLoopPromptSurfaceInputV1({
    required this.handLoopMode,
    required this.isDemoHandLoopVisualStep,
    required this.showSeatQuizPrelude,
    required this.showIntroSequence,
    required this.promptText,
    required this.outcomeSurfaceVisible,
    required this.debugCaptionOverrideVisible,
    required this.runnerAuthorityIsReviewPass,
    required this.runnerAuthorityVisibleBoardCount,
    required this.portraitLayout,
    required this.reviewQueueSession,
  });

  final bool handLoopMode;
  final bool isDemoHandLoopVisualStep;
  final bool showSeatQuizPrelude;
  final bool showIntroSequence;
  final String promptText;
  final bool outcomeSurfaceVisible;
  final bool debugCaptionOverrideVisible;
  final bool runnerAuthorityIsReviewPass;
  final int runnerAuthorityVisibleBoardCount;
  final bool portraitLayout;
  final bool reviewQueueSession;
}

World1SurfacedHandLoopPromptSurfaceV1
resolveWorld1SurfacedHandLoopPromptSurfaceV1(
  World1SurfacedHandLoopPromptSurfaceInputV1 input,
) {
  final resolved = resolveWorld1CanonicalHandLoopPromptSurfaceV1(
    World1CanonicalHandLoopPromptSurfaceInputV1(
      handLoopMode: input.handLoopMode,
      isDemoHandLoopVisualStep: input.isDemoHandLoopVisualStep,
      showSeatQuizPrelude: input.showSeatQuizPrelude,
      showIntroSequence: input.showIntroSequence,
      promptText: input.promptText,
      outcomeSurfaceVisible: input.outcomeSurfaceVisible,
      debugCaptionOverrideVisible: input.debugCaptionOverrideVisible,
      runnerAuthorityIsReviewPass: input.runnerAuthorityIsReviewPass,
      runnerAuthorityVisibleBoardCount: input.runnerAuthorityVisibleBoardCount,
      portraitLayout: input.portraitLayout,
      reviewQueueSession: input.reviewQueueSession,
    ),
  );
  return World1SurfacedHandLoopPromptSurfaceV1(
    isAffectedStateFamily: resolved.isAffectedStateFamily,
    usesFeltCaptionHost: resolved.usesFeltCaptionHost,
    isMounted: resolved.isMounted,
    promptText: resolved.promptText,
    reviewQueuePrefix: resolved.reviewQueuePrefix,
  );
}

World1SurfacedInstructionPlacementFlowV1
resolveWorld1SurfacedInstructionPlacementFlowV1(
  World1SurfacedInstructionPlacementInputV1 input,
) {
  final handLoopPromptSurfaceV1 = input.handLoopPromptSurfaceV1;
  final usesHandLoopFeltCaptionHostV1 =
      handLoopPromptSurfaceV1 != null &&
      handLoopPromptSurfaceV1.isAffectedStateFamily &&
      handLoopPromptSurfaceV1.usesFeltCaptionHost;
  final seatQuizInstructionModeActiveV1 =
      !input.handLoopMode &&
      (input.introCaptionActive || input.currentModeIsSeatQuiz);
  final seatQuizHeaderInstructionActiveV1 =
      seatQuizInstructionModeActiveV1 &&
      (input.mediaSize.height < 560 || input.mediaSize.width < 330) &&
      !input.currentModeIsSeatQuiz;
  final useFeltOverlayAsPromptSourceV1 =
      usesHandLoopFeltCaptionHostV1 ||
      (input.portraitLayout &&
          !seatQuizInstructionModeActiveV1 &&
          !input.handLoopMode);
  final isSeatQuizPortraitV1 = input.portraitLayout && !input.handLoopMode;
  final isHandLoopPortraitV1 =
      (input.portraitLayout || usesHandLoopFeltCaptionHostV1) &&
      input.handLoopMode;
  final compactHeaderUnderFeedbackPressureV1 =
      input.useRunnerCompactHeaderV1 &&
      (input.hasFeedbackTextV1 || input.outcomeSurfaceVisible);
  final collapsePortraitHeaderForFeltCaptionV1 =
      input.portraitLayout &&
      useFeltOverlayAsPromptSourceV1 &&
      !input.introCaptionActive;
  final showSeatQuizCoachStatusV1 =
      isSeatQuizPortraitV1 &&
      !input.introCaptionActive &&
      (input.outcomeSurfaceVisible ||
          input.showHintBubble ||
          input.hasFeedbackTextV1 ||
          (input.lockInNeedsSeatSelection &&
              input.allowSeatQuizConfirmPanelV1));
  final showSeatQuizCoachStripV1 =
      isSeatQuizPortraitV1 &&
      !seatQuizInstructionModeActiveV1 &&
      (input.introCaptionActive || showSeatQuizCoachStatusV1);
  final showHandLoopCoachStripV1 =
      isHandLoopPortraitV1 &&
      !(handLoopPromptSurfaceV1?.isMounted ?? false) &&
      (input.outcomeSurfaceVisible ||
          (input.showHandLoopActionBar && input.isDemoHandLoopVisualStep));
  final feltInstructionVisibleV1 =
      handLoopPromptSurfaceV1 != null &&
          handLoopPromptSurfaceV1.isAffectedStateFamily &&
          handLoopPromptSurfaceV1.usesFeltCaptionHost
      ? handLoopPromptSurfaceV1.isMounted
      : (useFeltOverlayAsPromptSourceV1 &&
            ((input.showSeatQuizPrelude || input.showIntroSequence) ||
                (input.handLoopMode && !input.outcomeSurfaceVisible)));
  final showBottomCoachStripV1 =
      !feltInstructionVisibleV1 &&
      (showSeatQuizCoachStripV1 || showHandLoopCoachStripV1);
  final showCompactInstructionOverlayV1 =
      input.showInstructionOverlay &&
      (!input.compactPortrait || input.campaignHudDetailsExpanded) &&
      (!input.compactPortrait || !input.handLoopMode);
  final hideStepPromptInHeaderV1 =
      useFeltOverlayAsPromptSourceV1 ||
      (seatQuizInstructionModeActiveV1 && !seatQuizHeaderInstructionActiveV1) ||
      (input.awaitingSeatInput && !seatQuizHeaderInstructionActiveV1);
  return World1SurfacedInstructionPlacementFlowV1(
    seatQuizInstructionModeActiveV1: seatQuizInstructionModeActiveV1,
    seatQuizHeaderInstructionActiveV1: seatQuizHeaderInstructionActiveV1,
    useFeltOverlayAsPromptSourceV1: useFeltOverlayAsPromptSourceV1,
    compactHeaderUnderFeedbackPressureV1: compactHeaderUnderFeedbackPressureV1,
    collapsePortraitHeaderForFeltCaptionV1:
        collapsePortraitHeaderForFeltCaptionV1,
    showSeatQuizCoachStripV1: showSeatQuizCoachStripV1,
    showHandLoopCoachStripV1: showHandLoopCoachStripV1,
    feltInstructionVisibleV1: feltInstructionVisibleV1,
    showBottomCoachStripV1: showBottomCoachStripV1,
    showCompactInstructionOverlayV1: showCompactInstructionOverlayV1,
    hideStepPromptInHeaderV1: hideStepPromptInHeaderV1,
  );
}

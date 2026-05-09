import 'package:flutter/widgets.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_teaching_flow_v1.dart';

class World1CanonicalHostViewBridgeInputV1 {
  const World1CanonicalHostViewBridgeInputV1({
    required this.moduleId,
    required this.stepIndex,
    required this.totalSteps,
    required this.isWorld2SeatQuizBeat,
    required this.stepIndicatesActionDecision,
    required this.isCampaignSpineSession,
    required this.currentModeIsSeatQuiz,
    required this.currentModeIsHandLoop,
    required this.rawHandLoopMode,
    required this.showHandLoopActionBar,
    required this.isDemoHandLoopVisualStep,
    required this.introCaptionActive,
    required this.showSeatQuizPrelude,
    required this.showIntroSequence,
    required this.outcomeVisible,
    required this.completionInProgress,
    required this.enginePlaybackBusy,
    required this.selectedSeatId,
    required this.introSequenceIndex,
    required this.introCoachRailTotal,
    required this.canonicalPrompt,
    required this.handLoopPrompt,
    required this.seatQuizInstruction,
    required this.activeIntroCoachTitle,
    required this.activeIntroCoachSubtitle,
    required this.seatQuizPreviewTitle,
    required this.seatQuizPreviewSubtitle,
    required this.introSequencePrompt,
    required this.guidedSeatSubtitle,
    required this.seatQuizFallbackGuidanceTitle,
    required this.onSeatQuizPreludeContinue,
    required this.onIntroSequenceContinue,
  });

  final String moduleId;
  final int stepIndex;
  final int totalSteps;
  final bool isWorld2SeatQuizBeat;
  final bool stepIndicatesActionDecision;
  final bool isCampaignSpineSession;
  final bool currentModeIsSeatQuiz;
  final bool currentModeIsHandLoop;
  final bool rawHandLoopMode;
  final bool showHandLoopActionBar;
  final bool isDemoHandLoopVisualStep;
  final bool introCaptionActive;
  final bool showSeatQuizPrelude;
  final bool showIntroSequence;
  final bool outcomeVisible;
  final bool completionInProgress;
  final bool enginePlaybackBusy;
  final String? selectedSeatId;
  final int introSequenceIndex;
  final int introCoachRailTotal;
  final String canonicalPrompt;
  final String? handLoopPrompt;
  final String? seatQuizInstruction;
  final String? activeIntroCoachTitle;
  final String? activeIntroCoachSubtitle;
  final String seatQuizPreviewTitle;
  final String seatQuizPreviewSubtitle;
  final String? introSequencePrompt;
  final String? guidedSeatSubtitle;
  final String seatQuizFallbackGuidanceTitle;
  final VoidCallback? onSeatQuizPreludeContinue;
  final VoidCallback? onIntroSequenceContinue;
}

class World1CanonicalHostViewBridgeResolvedV1 {
  const World1CanonicalHostViewBridgeResolvedV1({
    required this.progress,
    required this.isSeatQuizStep,
    required this.handLoopMode,
    required this.hideAppBarBack,
    required this.introCaptionContinueOnPressed,
    required this.teachingFlow,
  });

  final double progress;
  final bool isSeatQuizStep;
  final bool handLoopMode;
  final bool hideAppBarBack;
  final VoidCallback? introCaptionContinueOnPressed;
  final World1CanonicalTeachingFlowResolvedV1 teachingFlow;
}

World1CanonicalHostViewBridgeResolvedV1 resolveWorld1CanonicalHostViewBridgeV1(
  World1CanonicalHostViewBridgeInputV1 input,
) {
  final progress = ((input.stepIndex + 1) / input.totalSteps).clamp(0.0, 1.0);
  final isSeatQuizStep =
      input.isWorld2SeatQuizBeat ||
      (input.isCampaignSpineSession &&
          input.currentModeIsSeatQuiz &&
          !input.stepIndicatesActionDecision &&
          !input.isDemoHandLoopVisualStep);
  final handLoopMode = !isSeatQuizStep && input.rawHandLoopMode;
  final teachingFlow = resolveWorld1CanonicalTeachingFlowV1(
    World1CanonicalTeachingFlowInputV1(
      sourceId: '${input.moduleId}#step${input.stepIndex + 1}',
      canonicalPrompt: input.canonicalPrompt,
      handLoopMode: handLoopMode,
      currentModeIsHandLoop: input.currentModeIsHandLoop,
      isDemoHandLoopVisualStep: input.isDemoHandLoopVisualStep,
      showHandLoopActionBar: input.showHandLoopActionBar,
      introCaptionActive: input.introCaptionActive,
      showSeatQuizPrelude: input.showSeatQuizPrelude,
      showIntroSequence: input.showIntroSequence,
      isCampaignSpineSession: input.isCampaignSpineSession,
      isSeatQuizStep: isSeatQuizStep,
      outcomeVisible: input.outcomeVisible,
      completionInProgress: input.completionInProgress,
      enginePlaybackBusy: input.enginePlaybackBusy,
      selectedSeatId: input.selectedSeatId,
      introSequenceIndex: input.introSequenceIndex,
      introCoachRailTotal: input.introCoachRailTotal,
      handLoopPrompt: input.handLoopPrompt,
      seatQuizInstruction: input.seatQuizInstruction,
      activeIntroCoachTitle: input.activeIntroCoachTitle,
      activeIntroCoachSubtitle: input.activeIntroCoachSubtitle,
      seatQuizPreviewTitle: input.seatQuizPreviewTitle,
      seatQuizPreviewSubtitle: input.seatQuizPreviewSubtitle,
      introSequencePrompt: input.introSequencePrompt,
      guidedSeatSubtitle: input.guidedSeatSubtitle,
      seatQuizFallbackGuidanceTitle: input.seatQuizFallbackGuidanceTitle,
    ),
  );
  final hideAppBarBack =
      input.isCampaignSpineSession &&
      !input.outcomeVisible &&
      !input.completionInProgress;
  final introCaptionContinueOnPressed = input.showSeatQuizPrelude
      ? input.onSeatQuizPreludeContinue
      : (input.showIntroSequence ? input.onIntroSequenceContinue : null);

  return World1CanonicalHostViewBridgeResolvedV1(
    progress: progress,
    isSeatQuizStep: isSeatQuizStep,
    handLoopMode: handLoopMode,
    hideAppBarBack: hideAppBarBack,
    introCaptionContinueOnPressed: introCaptionContinueOnPressed,
    teachingFlow: teachingFlow,
  );
}

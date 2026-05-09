import 'package:flutter/foundation.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_details_surface_adapter_v1.dart';

@immutable
class World1CanonicalTeachingFlowInputV1 {
  const World1CanonicalTeachingFlowInputV1({
    required this.sourceId,
    required this.canonicalPrompt,
    required this.handLoopMode,
    required this.currentModeIsHandLoop,
    required this.isDemoHandLoopVisualStep,
    required this.showHandLoopActionBar,
    required this.introCaptionActive,
    required this.showSeatQuizPrelude,
    required this.showIntroSequence,
    required this.isCampaignSpineSession,
    required this.isSeatQuizStep,
    required this.outcomeVisible,
    required this.completionInProgress,
    required this.enginePlaybackBusy,
    required this.selectedSeatId,
    required this.introSequenceIndex,
    required this.introCoachRailTotal,
    this.handLoopPrompt,
    this.seatQuizInstruction,
    this.activeIntroCoachTitle,
    this.activeIntroCoachSubtitle,
    required this.seatQuizPreviewTitle,
    required this.seatQuizPreviewSubtitle,
    this.introSequencePrompt,
    this.guidedSeatSubtitle,
    required this.seatQuizFallbackGuidanceTitle,
  });

  final String sourceId;
  final String canonicalPrompt;
  final bool handLoopMode;
  final bool currentModeIsHandLoop;
  final bool isDemoHandLoopVisualStep;
  final bool showHandLoopActionBar;
  final bool introCaptionActive;
  final bool showSeatQuizPrelude;
  final bool showIntroSequence;
  final bool isCampaignSpineSession;
  final bool isSeatQuizStep;
  final bool outcomeVisible;
  final bool completionInProgress;
  final bool enginePlaybackBusy;
  final String? selectedSeatId;
  final int introSequenceIndex;
  final int introCoachRailTotal;
  final String? handLoopPrompt;
  final String? seatQuizInstruction;
  final String? activeIntroCoachTitle;
  final String? activeIntroCoachSubtitle;
  final String seatQuizPreviewTitle;
  final String seatQuizPreviewSubtitle;
  final String? introSequencePrompt;
  final String? guidedSeatSubtitle;
  final String seatQuizFallbackGuidanceTitle;
}

@immutable
class World1CanonicalTeachingFlowResolvedV1 {
  const World1CanonicalTeachingFlowResolvedV1({
    required this.displayedPrompt,
    required this.detailsPromptOverride,
    required this.detailsSurfaceAdapter,
    required this.effectiveTopPrompt,
    required this.introCoachTitle,
    required this.introCoachSubtitleRaw,
    required this.showIntroCoachSubtitle,
    required this.introCoachRailActiveIndex,
    required this.lockInNeedsSeatSelection,
    required this.allowSeatQuizConfirmPanel,
  });

  final String displayedPrompt;
  final String? detailsPromptOverride;
  final World1DetailsSurfaceAdapterV1 detailsSurfaceAdapter;
  final String effectiveTopPrompt;
  final String introCoachTitle;
  final String introCoachSubtitleRaw;
  final bool showIntroCoachSubtitle;
  final int introCoachRailActiveIndex;
  final bool lockInNeedsSeatSelection;
  final bool allowSeatQuizConfirmPanel;
}

World1CanonicalTeachingFlowResolvedV1 resolveWorld1CanonicalTeachingFlowV1(
  World1CanonicalTeachingFlowInputV1 input,
) {
  final displayedPrompt = input.handLoopMode
      ? _nonEmptyTrimmedV1(input.handLoopPrompt) ?? input.canonicalPrompt
      : input.canonicalPrompt;
  final detailsPromptOverride =
      input.currentModeIsHandLoop && !input.isDemoHandLoopVisualStep
      ? 'Choose the best action.'
      : _nonEmptyTrimmedV1(input.seatQuizInstruction);
  final detailsSurfaceAdapter = buildWorld1DetailsSurfaceAdapterV1(
    sourceId: input.sourceId,
    canonicalPrompt: input.canonicalPrompt,
    shortPromptOverride: input.introCaptionActive
        ? 'Follow caption.'
        : displayedPrompt,
    detailsPromptOverride: detailsPromptOverride,
  );
  final introCoachTitle =
      _nonEmptyTrimmedV1(input.activeIntroCoachTitle) ??
      (input.showSeatQuizPrelude
          ? input.seatQuizPreviewTitle.trim()
          : (_nonEmptyTrimmedV1(input.introSequencePrompt) ??
                input.seatQuizFallbackGuidanceTitle.trim()));
  final introCoachSubtitleRaw =
      _nonEmptyTrimmedV1(input.activeIntroCoachSubtitle) ??
      (input.showSeatQuizPrelude
          ? input.seatQuizPreviewSubtitle.trim()
          : (_nonEmptyTrimmedV1(input.guidedSeatSubtitle) ?? ''));
  final showIntroCoachSubtitle =
      introCoachSubtitleRaw.isNotEmpty &&
      introCoachSubtitleRaw.toLowerCase() != introCoachTitle.toLowerCase();
  final introCoachRailActiveIndex = input.showSeatQuizPrelude
      ? 0
      : (1 + input.introSequenceIndex).clamp(
          0,
          input.introCoachRailTotal > 0 ? input.introCoachRailTotal - 1 : 0,
        );
  final lockInNeedsSeatSelection =
      !input.showHandLoopActionBar &&
      !input.showSeatQuizPrelude &&
      !input.showIntroSequence &&
      input.selectedSeatId == null &&
      !input.outcomeVisible &&
      !input.completionInProgress &&
      !input.enginePlaybackBusy;
  final allowSeatQuizConfirmPanel =
      !(input.isCampaignSpineSession && input.isSeatQuizStep);
  return World1CanonicalTeachingFlowResolvedV1(
    displayedPrompt: displayedPrompt,
    detailsPromptOverride: detailsPromptOverride,
    detailsSurfaceAdapter: detailsSurfaceAdapter,
    effectiveTopPrompt: detailsSurfaceAdapter.presentation.shortPrompt,
    introCoachTitle: introCoachTitle,
    introCoachSubtitleRaw: introCoachSubtitleRaw,
    showIntroCoachSubtitle: showIntroCoachSubtitle,
    introCoachRailActiveIndex: introCoachRailActiveIndex,
    lockInNeedsSeatSelection: lockInNeedsSeatSelection,
    allowSeatQuizConfirmPanel: allowSeatQuizConfirmPanel,
  );
}

String? _nonEmptyTrimmedV1(String? value) {
  if (value == null) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

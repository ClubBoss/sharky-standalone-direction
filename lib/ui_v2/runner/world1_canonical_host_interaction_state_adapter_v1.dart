class World1CanonicalSeatSelectionInputV1 {
  const World1CanonicalSeatSelectionInputV1({
    required this.seatId,
    required this.introStepRequiresSeatTap,
    required this.introStepSeatId,
    required this.isCampaignSpineSession,
    required this.campaignSeatQuizMode,
    required this.showSeatQuizPrelude,
    required this.showIntroSequence,
    required this.outcomeSurfaceVisible,
    required this.completionInProgress,
  });

  final String seatId;
  final bool introStepRequiresSeatTap;
  final String? introStepSeatId;
  final bool isCampaignSpineSession;
  final bool campaignSeatQuizMode;
  final bool showSeatQuizPrelude;
  final bool showIntroSequence;
  final bool outcomeSurfaceVisible;
  final bool completionInProgress;
}

class World1CanonicalSeatSelectionResolvedV1 {
  const World1CanonicalSeatSelectionResolvedV1({
    required this.shouldIgnoreTap,
    required this.selectedSeatId,
    required this.introStepSatisfied,
    required this.feedback,
    required this.shouldAutoRunSeatQuizCheck,
  });

  final bool shouldIgnoreTap;
  final String? selectedSeatId;
  final bool introStepSatisfied;
  final String? feedback;
  final bool shouldAutoRunSeatQuizCheck;
}

World1CanonicalSeatSelectionResolvedV1
resolveWorld1CanonicalSeatSelectionV1(
  World1CanonicalSeatSelectionInputV1 input,
) {
  final introTapBlocked =
      input.introStepRequiresSeatTap && input.seatId != input.introStepSeatId;
  if (introTapBlocked) {
    return const World1CanonicalSeatSelectionResolvedV1(
      shouldIgnoreTap: true,
      selectedSeatId: null,
      introStepSatisfied: false,
      feedback: null,
      shouldAutoRunSeatQuizCheck: false,
    );
  }
  final introSatisfied =
      input.introStepRequiresSeatTap && input.seatId == input.introStepSeatId;
  return World1CanonicalSeatSelectionResolvedV1(
    shouldIgnoreTap: false,
    selectedSeatId: input.seatId,
    introStepSatisfied: introSatisfied,
    feedback: null,
    shouldAutoRunSeatQuizCheck:
        input.isCampaignSpineSession &&
        input.campaignSeatQuizMode &&
        !input.showSeatQuizPrelude &&
        !input.showIntroSequence &&
        !input.outcomeSurfaceVisible &&
        !input.completionInProgress,
  );
}

enum World1CanonicalSeatQuizResolutionKindV1 { noSelection, incorrect, correct }

class World1CanonicalSeatQuizResolutionInputV1 {
  const World1CanonicalSeatQuizResolutionInputV1({
    required this.kind,
    required this.isCampaignSpineSession,
    required this.attempts,
    required this.wrongAttemptsCount,
    required this.negativeDelta,
    required this.conceptFirstSeatMicroSlice,
    required this.actionLiteracyMicroSlice,
    required this.streetFlowMicroSlice,
    required this.conceptFirstSeatReinforceLine,
    required this.actionLiteracyReinforceLine,
    required this.streetFlowReinforceLine,
    required this.insightText,
  });

  final World1CanonicalSeatQuizResolutionKindV1 kind;
  final bool isCampaignSpineSession;
  final int attempts;
  final int wrongAttemptsCount;
  final int negativeDelta;
  final bool conceptFirstSeatMicroSlice;
  final bool actionLiteracyMicroSlice;
  final bool streetFlowMicroSlice;
  final String conceptFirstSeatReinforceLine;
  final String actionLiteracyReinforceLine;
  final String streetFlowReinforceLine;
  final String? insightText;
}

class World1CanonicalSeatQuizResolutionStateV1 {
  const World1CanonicalSeatQuizResolutionStateV1({
    required this.showHint,
    required this.feedback,
    required this.spineMistakesCount,
    required this.seatQuizAutoAdvancePending,
  });

  final bool? showHint;
  final String? feedback;
  final int? spineMistakesCount;
  final bool? seatQuizAutoAdvancePending;
}

World1CanonicalSeatQuizResolutionStateV1
resolveWorld1CanonicalSeatQuizResolutionStateV1(
  World1CanonicalSeatQuizResolutionInputV1 input,
) {
  switch (input.kind) {
    case World1CanonicalSeatQuizResolutionKindV1.noSelection:
      return const World1CanonicalSeatQuizResolutionStateV1(
        showHint: null,
        feedback: 'No seat selected.',
        spineMistakesCount: null,
        seatQuizAutoAdvancePending: null,
      );
    case World1CanonicalSeatQuizResolutionKindV1.incorrect:
      return World1CanonicalSeatQuizResolutionStateV1(
        showHint: input.isCampaignSpineSession ? false : input.attempts >= 1,
        feedback: input.isCampaignSpineSession
            ? 'Incorrect seat: ${input.negativeDelta >= 0 ? '+' : ''}${input.negativeDelta} chips.'
            : 'Incorrect seat.',
        spineMistakesCount: input.wrongAttemptsCount,
        seatQuizAutoAdvancePending: null,
      );
    case World1CanonicalSeatQuizResolutionKindV1.correct:
      final insight = input.insightText?.trim();
      final feedback = input.conceptFirstSeatMicroSlice
          ? input.conceptFirstSeatReinforceLine
          : input.actionLiteracyMicroSlice
          ? input.actionLiteracyReinforceLine
          : input.streetFlowMicroSlice
          ? input.streetFlowReinforceLine
          : (insight == null || insight.isEmpty ? null : insight);
      return World1CanonicalSeatQuizResolutionStateV1(
        showHint: null,
        feedback: feedback,
        spineMistakesCount: null,
        seatQuizAutoAdvancePending: true,
      );
  }
}

class World1CanonicalReviewPassCursorStateV1 {
  const World1CanonicalReviewPassCursorStateV1({
    required this.isInReviewPass,
    required this.reviewQueueCursor,
    required this.stepIndex,
    required this.selectedSeatId,
    required this.showHint,
    required this.feedback,
    required this.decisionStartedAt,
  });

  final bool isInReviewPass;
  final int reviewQueueCursor;
  final int stepIndex;
  final String? selectedSeatId;
  final bool showHint;
  final String feedback;
  final DateTime decisionStartedAt;
}

World1CanonicalReviewPassCursorStateV1
resolveWorld1CanonicalReviewPassCursorStateV1({
  required int cursor,
  required List<int> reviewQueueStepIndices,
  required String feedback,
  required DateTime decisionStartedAt,
}) {
  return World1CanonicalReviewPassCursorStateV1(
    isInReviewPass: true,
    reviewQueueCursor: cursor,
    stepIndex: reviewQueueStepIndices[cursor],
    selectedSeatId: null,
    showHint: true,
    feedback: feedback,
    decisionStartedAt: decisionStartedAt,
  );
}

class World1CanonicalAdvanceStepStateV1 {
  const World1CanonicalAdvanceStepStateV1({
    required this.seatQuizAutoAdvancePending,
    required this.stepIndex,
    required this.selectedSeatId,
    required this.showHint,
    required this.feedback,
    required this.decisionStartedAt,
  });

  final bool seatQuizAutoAdvancePending;
  final int stepIndex;
  final String? selectedSeatId;
  final bool showHint;
  final String? feedback;
  final DateTime decisionStartedAt;
}

World1CanonicalAdvanceStepStateV1 resolveWorld1CanonicalAdvanceStepStateV1({
  required int currentStepIndex,
  required DateTime decisionStartedAt,
}) {
  return World1CanonicalAdvanceStepStateV1(
    seatQuizAutoAdvancePending: false,
    stepIndex: currentStepIndex + 1,
    selectedSeatId: null,
    showHint: false,
    feedback: null,
    decisionStartedAt: decisionStartedAt,
  );
}

class World1CanonicalRetryStateV1 {
  const World1CanonicalRetryStateV1({
    required this.selectedSeatId,
    required this.showHint,
  });

  final String? selectedSeatId;
  final bool showHint;
}

const World1CanonicalRetryStateV1 kWorld1CanonicalRetryStateV1 =
    World1CanonicalRetryStateV1(selectedSeatId: null, showHint: true);

class World1CanonicalOutcomeSurfacePresentationStateV1 {
  const World1CanonicalOutcomeSurfacePresentationStateV1({
    required this.outcomeSurfaceVisible,
    required this.outcomeLastResultCorrect,
    required this.outcomeLines,
    required this.outcomeContinueAdvancesFlow,
    required this.outcomeAutoContinueArmed,
    required this.outcomeProgressionTarget,
    required this.outcomePrimaryCtaLabel,
    required this.outcomeShowRetrySecondary,
    required this.resultContinueBusy,
  });

  final bool outcomeSurfaceVisible;
  final bool outcomeLastResultCorrect;
  final List<String> outcomeLines;
  final bool outcomeContinueAdvancesFlow;
  final bool outcomeAutoContinueArmed;
  final Object outcomeProgressionTarget;
  final String outcomePrimaryCtaLabel;
  final bool outcomeShowRetrySecondary;
  final bool resultContinueBusy;
}

World1CanonicalOutcomeSurfacePresentationStateV1
resolveWorld1CanonicalOutcomeSurfacePresentationStateV1({
  required bool isCorrect,
  required List<String> lines,
  required bool continueAdvancesFlow,
  required bool autoContinue,
  required Object progressionTarget,
  required String primaryLabel,
  required bool showsRetrySecondary,
}) {
  return World1CanonicalOutcomeSurfacePresentationStateV1(
    outcomeSurfaceVisible: true,
    outcomeLastResultCorrect: isCorrect,
    outcomeLines: List<String>.unmodifiable(lines),
    outcomeContinueAdvancesFlow: continueAdvancesFlow,
    outcomeAutoContinueArmed: autoContinue,
    outcomeProgressionTarget: progressionTarget,
    outcomePrimaryCtaLabel: primaryLabel,
    outcomeShowRetrySecondary: showsRetrySecondary,
    resultContinueBusy: false,
  );
}

class World1CanonicalOutcomeSurfaceResetStateV1 {
  const World1CanonicalOutcomeSurfaceResetStateV1({
    required this.seatQuizAutoAdvancePending,
    required this.outcomeSurfaceVisible,
    required this.outcomeLastResultCorrect,
    required this.outcomeLines,
    required this.outcomeContinueAdvancesFlow,
    required this.outcomeAutoContinueArmed,
    required this.outcomeProgressionTarget,
    required this.outcomePrimaryCtaLabel,
    required this.outcomeShowRetrySecondary,
    required this.resultContinueBusy,
  });

  final bool seatQuizAutoAdvancePending;
  final bool outcomeSurfaceVisible;
  final bool outcomeLastResultCorrect;
  final List<String> outcomeLines;
  final bool outcomeContinueAdvancesFlow;
  final bool outcomeAutoContinueArmed;
  final Object outcomeProgressionTarget;
  final String outcomePrimaryCtaLabel;
  final bool outcomeShowRetrySecondary;
  final bool resultContinueBusy;
}

World1CanonicalOutcomeSurfaceResetStateV1
resolveWorld1CanonicalOutcomeSurfaceResetStateV1({
  required Object noneProgressionTarget,
}) {
  return World1CanonicalOutcomeSurfaceResetStateV1(
    seatQuizAutoAdvancePending: false,
    outcomeSurfaceVisible: false,
    outcomeLastResultCorrect: false,
    outcomeLines: const <String>[],
    outcomeContinueAdvancesFlow: false,
    outcomeAutoContinueArmed: false,
    outcomeProgressionTarget: noneProgressionTarget,
    outcomePrimaryCtaLabel: 'CONTINUE',
    outcomeShowRetrySecondary: false,
    resultContinueBusy: false,
  );
}

class World1CanonicalOutcomeContinueBusyStateV1 {
  const World1CanonicalOutcomeContinueBusyStateV1({
    required this.resultContinueBusy,
  });

  final bool resultContinueBusy;
}

const World1CanonicalOutcomeContinueBusyStateV1
    kWorld1CanonicalOutcomeContinueBusyStartedV1 =
    World1CanonicalOutcomeContinueBusyStateV1(resultContinueBusy: true);
const World1CanonicalOutcomeContinueBusyStateV1
    kWorld1CanonicalOutcomeContinueBusyFinishedV1 =
    World1CanonicalOutcomeContinueBusyStateV1(resultContinueBusy: false);

class World1CanonicalHandLoopLaunchStateV1 {
  const World1CanonicalHandLoopLaunchStateV1({
    required this.engineRunBusy,
    required this.enginePlaybackBusy,
    required this.engineCurrentStreet,
    required this.engineStepStreet,
    required this.enginePotChips,
    required this.engineToCallChips,
    required this.engineCurrentBetChips,
    required this.enginePotPulse,
    required this.engineTurnFeedLines,
  });

  final bool engineRunBusy;
  final Object? engineCurrentStreet;
  final Object? engineStepStreet;
  final int enginePotChips;
  final int engineToCallChips;
  final int engineCurrentBetChips;
  final bool enginePotPulse;
  final bool enginePlaybackBusy;
  final List<String> engineTurnFeedLines;
}

World1CanonicalHandLoopLaunchStateV1
resolveWorld1CanonicalHandLoopLaunchStateV1({
  required Object preflopStreet,
}) {
  return World1CanonicalHandLoopLaunchStateV1(
    engineRunBusy: true,
    enginePlaybackBusy: true,
    engineCurrentStreet: preflopStreet,
    engineStepStreet: preflopStreet,
    enginePotChips: 0,
    engineToCallChips: 0,
    engineCurrentBetChips: 0,
    enginePotPulse: false,
    engineTurnFeedLines: const <String>[],
  );
}

class World1CanonicalHandLoopFallbackStateV1 {
  const World1CanonicalHandLoopFallbackStateV1({
    required this.enginePlaybackBusy,
    required this.engineCurrentStreet,
    required this.engineStepStreet,
    required this.enginePotChips,
    required this.engineToCallChips,
    required this.engineCurrentBetChips,
    required this.enginePotPulse,
    required this.engineTurnFeedLines,
  });

  final bool enginePlaybackBusy;
  final Object? engineCurrentStreet;
  final Object? engineStepStreet;
  final int enginePotChips;
  final int engineToCallChips;
  final int engineCurrentBetChips;
  final bool enginePotPulse;
  final List<String> engineTurnFeedLines;
}

const World1CanonicalHandLoopFallbackStateV1
    kWorld1CanonicalHandLoopFallbackStateV1 = World1CanonicalHandLoopFallbackStateV1(
      enginePlaybackBusy: false,
      engineCurrentStreet: null,
      engineStepStreet: null,
      enginePotChips: 0,
      engineToCallChips: 0,
      engineCurrentBetChips: 0,
      enginePotPulse: false,
      engineTurnFeedLines: <String>[],
    );

class World1CanonicalHandLoopInteropFailureStateV1 {
  const World1CanonicalHandLoopInteropFailureStateV1({
    required this.engineUseLegacyBackend,
    required this.engineVerdict,
    required this.engineErrorType,
    required this.engineSummaryLines,
    required this.engineFallbackNote,
    required this.engineCurrentStreet,
    required this.engineStepStreet,
    required this.enginePotChips,
    required this.engineToCallChips,
    required this.engineCurrentBetChips,
    required this.enginePotPulse,
    required this.enginePlaybackBusy,
  });

  final bool engineUseLegacyBackend;
  final String? engineVerdict;
  final String? engineErrorType;
  final List<String> engineSummaryLines;
  final String? engineFallbackNote;
  final Object? engineCurrentStreet;
  final Object? engineStepStreet;
  final int enginePotChips;
  final int engineToCallChips;
  final int engineCurrentBetChips;
  final bool enginePotPulse;
  final bool enginePlaybackBusy;
}

const World1CanonicalHandLoopInteropFailureStateV1
    kWorld1CanonicalHandLoopInteropFailureStateV1 =
    World1CanonicalHandLoopInteropFailureStateV1(
      engineUseLegacyBackend: false,
      engineVerdict: null,
      engineErrorType: null,
      engineSummaryLines: <String>[],
      engineFallbackNote: null,
      engineCurrentStreet: null,
      engineStepStreet: null,
      enginePotChips: 0,
      engineToCallChips: 0,
      engineCurrentBetChips: 0,
      enginePotPulse: false,
      enginePlaybackBusy: false,
    );

class World1CanonicalHandLoopOutcomeStateV1 {
  const World1CanonicalHandLoopOutcomeStateV1({
    required this.engineUseLegacyBackend,
    required this.engineVerdict,
    required this.engineErrorType,
    required this.engineSummaryLines,
    required this.engineFallbackNote,
    required this.engineTurnFeedLines,
  });

  final bool engineUseLegacyBackend;
  final String? engineVerdict;
  final String? engineErrorType;
  final List<String> engineSummaryLines;
  final String? engineFallbackNote;
  final List<String> engineTurnFeedLines;
}

World1CanonicalHandLoopOutcomeStateV1
resolveWorld1CanonicalHandLoopOutcomeStateV1({
  required String verdict,
  required String? errorType,
  required List<String> summaryLines,
  required List<String> turnFeedLines,
}) {
  return World1CanonicalHandLoopOutcomeStateV1(
    engineUseLegacyBackend: false,
    engineVerdict: verdict,
    engineErrorType: errorType,
    engineSummaryLines: List<String>.unmodifiable(summaryLines),
    engineFallbackNote: null,
    engineTurnFeedLines: List<String>.unmodifiable(turnFeedLines),
  );
}

class World1CanonicalHandLoopRunBusyStateV1 {
  const World1CanonicalHandLoopRunBusyStateV1({required this.engineRunBusy});

  final bool engineRunBusy;
}

const World1CanonicalHandLoopRunBusyStateV1
    kWorld1CanonicalHandLoopRunBusyStartedV1 =
    World1CanonicalHandLoopRunBusyStateV1(engineRunBusy: true);
const World1CanonicalHandLoopRunBusyStateV1
    kWorld1CanonicalHandLoopRunBusyFinishedV1 =
    World1CanonicalHandLoopRunBusyStateV1(engineRunBusy: false);

class World1CanonicalLegacyBackendSummaryStateV1 {
  const World1CanonicalLegacyBackendSummaryStateV1({
    required this.engineUseLegacyBackend,
    required this.engineVerdict,
    required this.engineErrorType,
    required this.engineSummaryLines,
    required this.engineFallbackNote,
    required this.engineCurrentStreet,
    required this.engineStepStreet,
    required this.enginePotChips,
    required this.engineToCallChips,
    required this.engineCurrentBetChips,
    required this.enginePotPulse,
    required this.enginePlaybackBusy,
    required this.engineTurnFeedLines,
  });

  final bool engineUseLegacyBackend;
  final String engineVerdict;
  final String? engineErrorType;
  final List<String> engineSummaryLines;
  final String? engineFallbackNote;
  final Object? engineCurrentStreet;
  final Object? engineStepStreet;
  final int enginePotChips;
  final int engineToCallChips;
  final int engineCurrentBetChips;
  final bool enginePotPulse;
  final bool enginePlaybackBusy;
  final List<String> engineTurnFeedLines;
}

World1CanonicalLegacyBackendSummaryStateV1
resolveWorld1CanonicalLegacyBackendSummaryStateV1({
  required String verdict,
  required String? errorType,
  required List<String> summaryLines,
  required String? fallbackNote,
}) {
  return World1CanonicalLegacyBackendSummaryStateV1(
    engineUseLegacyBackend: true,
    engineVerdict: verdict,
    engineErrorType: errorType,
    engineSummaryLines: List<String>.unmodifiable(summaryLines),
    engineFallbackNote: fallbackNote,
    engineCurrentStreet: null,
    engineStepStreet: null,
    enginePotChips: 0,
    engineToCallChips: 0,
    engineCurrentBetChips: 0,
    enginePotPulse: false,
    enginePlaybackBusy: false,
    engineTurnFeedLines: const <String>[],
  );
}

class World1CanonicalPlaybackStateV1 {
  const World1CanonicalPlaybackStateV1({
    required this.engineCurrentStreet,
    required this.engineStepStreet,
    required this.enginePotChips,
    required this.engineToCallChips,
    required this.engineCurrentBetChips,
    required this.enginePotPulse,
    required this.enginePlaybackBusy,
  });

  final Object? engineCurrentStreet;
  final Object? engineStepStreet;
  final int enginePotChips;
  final int engineToCallChips;
  final int engineCurrentBetChips;
  final bool enginePotPulse;
  final bool enginePlaybackBusy;
}

const World1CanonicalPlaybackStateV1 kWorld1CanonicalPlaybackEmptyStateV1 =
    World1CanonicalPlaybackStateV1(
      engineCurrentStreet: null,
      engineStepStreet: null,
      enginePotChips: 0,
      engineToCallChips: 0,
      engineCurrentBetChips: 0,
      enginePotPulse: false,
      enginePlaybackBusy: false,
    );

World1CanonicalPlaybackStateV1 resolveWorld1CanonicalPlaybackImmediateStateV1({
  required Object lastStreet,
  required Object firstStreet,
  required int potChips,
  required int toCallChips,
  required int currentBetChips,
}) {
  return World1CanonicalPlaybackStateV1(
    engineCurrentStreet: lastStreet,
    engineStepStreet: firstStreet,
    enginePotChips: potChips,
    engineToCallChips: toCallChips,
    engineCurrentBetChips: currentBetChips,
    enginePotPulse: false,
    enginePlaybackBusy: false,
  );
}

World1CanonicalPlaybackStateV1 resolveWorld1CanonicalPlaybackInitialStateV1({
  required Object firstStreet,
  required int potChips,
  required int toCallChips,
  required int currentBetChips,
}) {
  return World1CanonicalPlaybackStateV1(
    engineCurrentStreet: firstStreet,
    engineStepStreet: firstStreet,
    enginePotChips: potChips,
    engineToCallChips: toCallChips,
    engineCurrentBetChips: currentBetChips,
    enginePotPulse: false,
    enginePlaybackBusy: true,
  );
}

World1CanonicalPlaybackStateV1 resolveWorld1CanonicalPlaybackTickStateV1({
  required Object nextStreet,
  required int potChips,
  required int toCallChips,
  required int currentBetChips,
  required bool potIncreased,
}) {
  return World1CanonicalPlaybackStateV1(
    engineCurrentStreet: nextStreet,
    engineStepStreet: null,
    enginePotChips: potChips,
    engineToCallChips: toCallChips,
    engineCurrentBetChips: currentBetChips,
    enginePotPulse: potIncreased,
    enginePlaybackBusy: true,
  );
}

const World1CanonicalPlaybackStateV1 kWorld1CanonicalPlaybackCompletedStateV1 =
    World1CanonicalPlaybackStateV1(
      engineCurrentStreet: null,
      engineStepStreet: null,
      enginePotChips: 0,
      engineToCallChips: 0,
      engineCurrentBetChips: 0,
      enginePotPulse: false,
      enginePlaybackBusy: false,
    );

enum World1CanonicalHandLoopFollowUpActionV1 {
  seatQuizCheck,
  presentOutcome,
}

class World1CanonicalHandLoopFollowUpPlanV1 {
  const World1CanonicalHandLoopFollowUpPlanV1({
    required this.action,
    required this.continueAdvancesFlow,
    required this.autoContinue,
    required this.primaryCtaLabel,
    required this.showRetrySecondary,
  });

  final World1CanonicalHandLoopFollowUpActionV1 action;
  final bool continueAdvancesFlow;
  final bool autoContinue;
  final String primaryCtaLabel;
  final bool showRetrySecondary;
}

const World1CanonicalHandLoopFollowUpPlanV1
    kWorld1CanonicalHandLoopFallbackFollowUpPlanV1 =
    World1CanonicalHandLoopFollowUpPlanV1(
      action: World1CanonicalHandLoopFollowUpActionV1.seatQuizCheck,
      continueAdvancesFlow: false,
      autoContinue: false,
      primaryCtaLabel: 'CONTINUE',
      showRetrySecondary: false,
    );

const World1CanonicalHandLoopFollowUpPlanV1
    kWorld1CanonicalHandLoopInteropFailureFollowUpPlanV1 =
    World1CanonicalHandLoopFollowUpPlanV1(
      action: World1CanonicalHandLoopFollowUpActionV1.seatQuizCheck,
      continueAdvancesFlow: false,
      autoContinue: false,
      primaryCtaLabel: 'CONTINUE',
      showRetrySecondary: false,
    );

const World1CanonicalHandLoopFollowUpPlanV1
    kWorld1CanonicalHandLoopOutcomeFollowUpPlanV1 =
    World1CanonicalHandLoopFollowUpPlanV1(
      action: World1CanonicalHandLoopFollowUpActionV1.presentOutcome,
      continueAdvancesFlow: true,
      autoContinue: false,
      primaryCtaLabel: 'CONTINUE',
      showRetrySecondary: false,
    );

enum World1CanonicalHandLoopEffectProfileV1 { success, error }

class World1CanonicalHandLoopOutcomeEffectsInputV1 {
  const World1CanonicalHandLoopOutcomeEffectsInputV1({
    required this.moduleId,
    required this.mode,
    required this.stepIndex,
    required this.isCorrect,
    required this.errorType,
    required this.decisionMs,
    required this.previousAttemptsForStep,
    required this.previousMistakesCount,
    required this.reason,
  });

  final String moduleId;
  final Object mode;
  final int stepIndex;
  final bool isCorrect;
  final String errorType;
  final int decisionMs;
  final int previousAttemptsForStep;
  final int previousMistakesCount;
  final String reason;
}

class World1CanonicalHandLoopOutcomeEffectsStateV1 {
  const World1CanonicalHandLoopOutcomeEffectsStateV1({
    required this.correctTelemetry,
    required this.timeToDecisionTelemetry,
    required this.effectProfile,
    required this.uiSoundEventName,
    required this.uiSfxAssetName,
    required this.uiHapticEventName,
    required this.triggerSuccessPulse,
    required this.triggerFailurePulse,
    required this.nextAttemptsForStep,
    required this.nextMistakesCount,
    required this.showHint,
    required this.feedback,
    required this.applyCampaignConsequence,
  });

  final Map<String, dynamic> correctTelemetry;
  final Map<String, dynamic> timeToDecisionTelemetry;
  final World1CanonicalHandLoopEffectProfileV1 effectProfile;
  final String uiSoundEventName;
  final String uiSfxAssetName;
  final String uiHapticEventName;
  final bool triggerSuccessPulse;
  final bool triggerFailurePulse;
  final int? nextAttemptsForStep;
  final int? nextMistakesCount;
  final bool? showHint;
  final String feedback;
  final bool applyCampaignConsequence;
}

World1CanonicalHandLoopOutcomeEffectsStateV1
resolveWorld1CanonicalHandLoopOutcomeEffectsStateV1(
  World1CanonicalHandLoopOutcomeEffectsInputV1 input,
) {
  return World1CanonicalHandLoopOutcomeEffectsStateV1(
    correctTelemetry: <String, dynamic>{
      'module_id': input.moduleId,
      'mode': input.mode,
      'step_index': input.stepIndex,
      'correct': input.isCorrect,
      'error_type': input.isCorrect ? 'none' : input.errorType,
    },
    timeToDecisionTelemetry: <String, dynamic>{
      'module_id': input.moduleId,
      'mode': input.mode,
      'step_index': input.stepIndex,
      'time_to_decision_ms': input.decisionMs,
    },
    effectProfile: input.isCorrect
        ? World1CanonicalHandLoopEffectProfileV1.success
        : World1CanonicalHandLoopEffectProfileV1.error,
    uiSoundEventName: input.isCorrect ? 'success' : 'error',
    uiSfxAssetName: input.isCorrect ? 'chip_win' : 'chip_lose',
    uiHapticEventName: input.isCorrect ? 'success' : 'error',
    triggerSuccessPulse: input.isCorrect,
    triggerFailurePulse: !input.isCorrect,
    nextAttemptsForStep: input.isCorrect ? null : input.previousAttemptsForStep + 1,
    nextMistakesCount: input.isCorrect ? null : input.previousMistakesCount + 1,
    showHint: input.isCorrect ? null : true,
    feedback: input.reason,
    applyCampaignConsequence: true,
  );
}

class World1CanonicalHandLoopExecutionPackageInputV1 {
  const World1CanonicalHandLoopExecutionPackageInputV1({
    required this.verdict,
    required this.errorType,
    required this.outcomeSummaryLines,
    required this.turnFeedLines,
    required this.heroActionsApplied,
    required this.entryCount,
    required this.stopReasonName,
    required this.isCorrect,
    required this.reason,
    required this.outcomeType,
    required this.nextHint,
  });

  final String verdict;
  final String? errorType;
  final List<String> outcomeSummaryLines;
  final List<String> turnFeedLines;
  final int heroActionsApplied;
  final int entryCount;
  final String stopReasonName;
  final bool isCorrect;
  final String reason;
  final String outcomeType;
  final String nextHint;
}

class World1CanonicalHandLoopExecutionPackageV1 {
  const World1CanonicalHandLoopExecutionPackageV1({
    required this.engineVerdict,
    required this.engineErrorType,
    required this.engineSummaryLines,
    required this.engineFallbackNote,
    required this.engineTurnFeedLines,
    required this.isCorrect,
    required this.reason,
    required this.outcomeType,
    required this.nextHint,
  });

  final String engineVerdict;
  final String? engineErrorType;
  final List<String> engineSummaryLines;
  final String? engineFallbackNote;
  final List<String> engineTurnFeedLines;
  final bool isCorrect;
  final String reason;
  final String outcomeType;
  final String nextHint;
}

World1CanonicalHandLoopExecutionPackageV1
resolveWorld1CanonicalHandLoopExecutionPackageV1(
  World1CanonicalHandLoopExecutionPackageInputV1 input,
) {
  return World1CanonicalHandLoopExecutionPackageV1(
    engineVerdict: input.verdict,
    engineErrorType: input.errorType,
    engineSummaryLines: List<String>.unmodifiable(<String>[
      'Hand loop -> hero decisions ${input.heroActionsApplied}, '
          'steps ${input.entryCount}, stop ${input.stopReasonName}',
      ...input.outcomeSummaryLines,
    ]),
    engineFallbackNote: null,
    engineTurnFeedLines: List<String>.unmodifiable(input.turnFeedLines),
    isCorrect: input.isCorrect,
    reason: input.reason,
    outcomeType: input.outcomeType,
    nextHint: input.nextHint,
  );
}

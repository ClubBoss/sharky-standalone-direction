import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_host_interaction_state_adapter_v1.dart';

void main() {
  test('seat selection resolves intro gating and campaign auto-check', () {
    final blocked = resolveWorld1CanonicalSeatSelectionV1(
      const World1CanonicalSeatSelectionInputV1(
        seatId: 'sb',
        introStepRequiresSeatTap: true,
        introStepSeatId: 'btn',
        isCampaignSpineSession: true,
        campaignSeatQuizMode: true,
        showSeatQuizPrelude: false,
        showIntroSequence: false,
        outcomeSurfaceVisible: false,
        completionInProgress: false,
      ),
    );
    expect(blocked.shouldIgnoreTap, isTrue);

    final resolved = resolveWorld1CanonicalSeatSelectionV1(
      const World1CanonicalSeatSelectionInputV1(
        seatId: 'btn',
        introStepRequiresSeatTap: true,
        introStepSeatId: 'btn',
        isCampaignSpineSession: true,
        campaignSeatQuizMode: true,
        showSeatQuizPrelude: false,
        showIntroSequence: false,
        outcomeSurfaceVisible: false,
        completionInProgress: false,
      ),
    );
    expect(resolved.shouldIgnoreTap, isFalse);
    expect(resolved.selectedSeatId, 'btn');
    expect(resolved.introStepSatisfied, isTrue);
    expect(resolved.shouldAutoRunSeatQuizCheck, isTrue);
  });

  test('seat quiz resolution resolves no-selection and incorrect state', () {
    const noSelection = World1CanonicalSeatQuizResolutionInputV1(
      kind: World1CanonicalSeatQuizResolutionKindV1.noSelection,
      isCampaignSpineSession: false,
      attempts: 0,
      wrongAttemptsCount: 0,
      negativeDelta: 0,
      conceptFirstSeatMicroSlice: false,
      actionLiteracyMicroSlice: false,
      streetFlowMicroSlice: false,
      conceptFirstSeatReinforceLine: '',
      actionLiteracyReinforceLine: '',
      streetFlowReinforceLine: '',
      insightText: null,
    );
    expect(
      resolveWorld1CanonicalSeatQuizResolutionStateV1(noSelection).feedback,
      'No seat selected.',
    );

    final incorrect = resolveWorld1CanonicalSeatQuizResolutionStateV1(
      const World1CanonicalSeatQuizResolutionInputV1(
        kind: World1CanonicalSeatQuizResolutionKindV1.incorrect,
        isCampaignSpineSession: false,
        attempts: 2,
        wrongAttemptsCount: 3,
        negativeDelta: -4,
        conceptFirstSeatMicroSlice: false,
        actionLiteracyMicroSlice: false,
        streetFlowMicroSlice: false,
        conceptFirstSeatReinforceLine: '',
        actionLiteracyReinforceLine: '',
        streetFlowReinforceLine: '',
        insightText: null,
      ),
    );
    expect(incorrect.showHint, isTrue);
    expect(incorrect.feedback, 'Incorrect seat.');
    expect(incorrect.spineMistakesCount, 3);
  });

  test('seat quiz resolution resolves success reinforcement and auto-advance', () {
    final correct = resolveWorld1CanonicalSeatQuizResolutionStateV1(
      const World1CanonicalSeatQuizResolutionInputV1(
        kind: World1CanonicalSeatQuizResolutionKindV1.correct,
        isCampaignSpineSession: true,
        attempts: 0,
        wrongAttemptsCount: 0,
        negativeDelta: 0,
        conceptFirstSeatMicroSlice: false,
        actionLiteracyMicroSlice: true,
        streetFlowMicroSlice: false,
        conceptFirstSeatReinforceLine: 'concept',
        actionLiteracyReinforceLine: 'action',
        streetFlowReinforceLine: 'street',
        insightText: 'insight',
      ),
    );
    expect(correct.feedback, 'action');
    expect(correct.seatQuizAutoAdvancePending, isTrue);
  });

  test('review-pass and advance-step states reset host interaction fields', () {
    final now = DateTime.utc(2026, 3, 27, 12);
    final review = resolveWorld1CanonicalReviewPassCursorStateV1(
      cursor: 1,
      reviewQueueStepIndices: const <int>[2, 5, 7],
      feedback: 'Review queued spots.',
      decisionStartedAt: now,
    );
    expect(review.isInReviewPass, isTrue);
    expect(review.stepIndex, 5);
    expect(review.selectedSeatId, isNull);
    expect(review.showHint, isTrue);

    final advance = resolveWorld1CanonicalAdvanceStepStateV1(
      currentStepIndex: 4,
      decisionStartedAt: now,
    );
    expect(advance.stepIndex, 5);
    expect(advance.selectedSeatId, isNull);
    expect(advance.showHint, isFalse);
    expect(advance.feedback, isNull);
    expect(advance.seatQuizAutoAdvancePending, isFalse);
  });

  test('outcome surface presentation and reset states are canonicalized', () {
    final presented = resolveWorld1CanonicalOutcomeSurfacePresentationStateV1(
      isCorrect: true,
      lines: const <String>['Correct.', 'Next hint'],
      continueAdvancesFlow: true,
      autoContinue: false,
      progressionTarget: 'advance',
      primaryLabel: 'CONTINUE',
      showsRetrySecondary: false,
    );
    expect(presented.outcomeSurfaceVisible, isTrue);
    expect(presented.outcomeLastResultCorrect, isTrue);
    expect(presented.outcomeLines, const <String>['Correct.', 'Next hint']);
    expect(presented.outcomeProgressionTarget, 'advance');
    expect(presented.resultContinueBusy, isFalse);

    final reset = resolveWorld1CanonicalOutcomeSurfaceResetStateV1(
      noneProgressionTarget: 'none',
    );
    expect(reset.seatQuizAutoAdvancePending, isFalse);
    expect(reset.outcomeSurfaceVisible, isFalse);
    expect(reset.outcomeLines, isEmpty);
    expect(reset.outcomeProgressionTarget, 'none');
    expect(reset.outcomePrimaryCtaLabel, 'CONTINUE');
  });

  test('outcome continue-busy states are canonicalized', () {
    expect(kWorld1CanonicalOutcomeContinueBusyStartedV1.resultContinueBusy, isTrue);
    expect(
      kWorld1CanonicalOutcomeContinueBusyFinishedV1.resultContinueBusy,
      isFalse,
    );
  });

  test('hand-loop launch and fallback states are canonicalized', () {
    final launch = resolveWorld1CanonicalHandLoopLaunchStateV1(
      preflopStreet: 'preflop',
    );
    expect(launch.engineRunBusy, isTrue);
    expect(launch.enginePlaybackBusy, isTrue);
    expect(launch.engineCurrentStreet, 'preflop');
    expect(launch.engineStepStreet, 'preflop');
    expect(launch.engineTurnFeedLines, isEmpty);

    expect(kWorld1CanonicalHandLoopFallbackStateV1.enginePlaybackBusy, isFalse);
    expect(kWorld1CanonicalHandLoopFallbackStateV1.engineCurrentStreet, isNull);
    expect(kWorld1CanonicalHandLoopFallbackStateV1.engineTurnFeedLines, isEmpty);
  });

  test('hand-loop interop failure and outcome states are canonicalized', () {
    expect(
      kWorld1CanonicalHandLoopInteropFailureStateV1.engineUseLegacyBackend,
      isFalse,
    );
    expect(kWorld1CanonicalHandLoopInteropFailureStateV1.engineVerdict, isNull);
    expect(
      kWorld1CanonicalHandLoopInteropFailureStateV1.enginePlaybackBusy,
      isFalse,
    );

    final outcome = resolveWorld1CanonicalHandLoopOutcomeStateV1(
      verdict: 'correct',
      errorType: 'range',
      summaryLines: const <String>['line 1', 'line 2'],
      turnFeedLines: const <String>['feed 1'],
    );
    expect(outcome.engineUseLegacyBackend, isFalse);
    expect(outcome.engineVerdict, 'correct');
    expect(outcome.engineErrorType, 'range');
    expect(outcome.engineSummaryLines, const <String>['line 1', 'line 2']);
    expect(outcome.engineTurnFeedLines, const <String>['feed 1']);
  });

  test('hand-loop run-busy lifecycle is canonicalized', () {
    expect(kWorld1CanonicalHandLoopRunBusyStartedV1.engineRunBusy, isTrue);
    expect(kWorld1CanonicalHandLoopRunBusyFinishedV1.engineRunBusy, isFalse);
  });

  test('legacy backend summary state is canonicalized', () {
    final state = resolveWorld1CanonicalLegacyBackendSummaryStateV1(
      verdict: 'correct',
      errorType: 'range',
      summaryLines: const <String>['line 1'],
      fallbackNote: 'legacy fallback',
    );
    expect(state.engineUseLegacyBackend, isTrue);
    expect(state.engineVerdict, 'correct');
    expect(state.engineErrorType, 'range');
    expect(state.engineSummaryLines, const <String>['line 1']);
    expect(state.engineFallbackNote, 'legacy fallback');
    expect(state.enginePlaybackBusy, isFalse);
    expect(state.engineTurnFeedLines, isEmpty);
  });

  test('playback states are canonicalized', () {
    expect(kWorld1CanonicalPlaybackEmptyStateV1.enginePlaybackBusy, isFalse);
    expect(kWorld1CanonicalPlaybackEmptyStateV1.engineCurrentStreet, isNull);

    final immediate = resolveWorld1CanonicalPlaybackImmediateStateV1(
      lastStreet: 'river',
      firstStreet: 'preflop',
      potChips: 42,
      toCallChips: 8,
      currentBetChips: 12,
    );
    expect(immediate.engineCurrentStreet, 'river');
    expect(immediate.engineStepStreet, 'preflop');
    expect(immediate.enginePlaybackBusy, isFalse);

    final initial = resolveWorld1CanonicalPlaybackInitialStateV1(
      firstStreet: 'preflop',
      potChips: 10,
      toCallChips: 2,
      currentBetChips: 4,
    );
    expect(initial.engineCurrentStreet, 'preflop');
    expect(initial.engineStepStreet, 'preflop');
    expect(initial.enginePlaybackBusy, isTrue);

    final tick = resolveWorld1CanonicalPlaybackTickStateV1(
      nextStreet: 'turn',
      potChips: 30,
      toCallChips: 5,
      currentBetChips: 10,
      potIncreased: true,
    );
    expect(tick.engineCurrentStreet, 'turn');
    expect(tick.enginePotPulse, isTrue);
    expect(tick.enginePlaybackBusy, isTrue);

    expect(kWorld1CanonicalPlaybackCompletedStateV1.enginePlaybackBusy, isFalse);
  });

  test('hand-loop follow-up plans are canonicalized', () {
    expect(
      kWorld1CanonicalHandLoopFallbackFollowUpPlanV1.action,
      World1CanonicalHandLoopFollowUpActionV1.seatQuizCheck,
    );
    expect(
      kWorld1CanonicalHandLoopInteropFailureFollowUpPlanV1.action,
      World1CanonicalHandLoopFollowUpActionV1.seatQuizCheck,
    );
    expect(
      kWorld1CanonicalHandLoopOutcomeFollowUpPlanV1.action,
      World1CanonicalHandLoopFollowUpActionV1.presentOutcome,
    );
    expect(
      kWorld1CanonicalHandLoopOutcomeFollowUpPlanV1.continueAdvancesFlow,
      isTrue,
    );
    expect(kWorld1CanonicalHandLoopOutcomeFollowUpPlanV1.autoContinue, isFalse);
    expect(
      kWorld1CanonicalHandLoopOutcomeFollowUpPlanV1.primaryCtaLabel,
      'CONTINUE',
    );
    expect(
      kWorld1CanonicalHandLoopOutcomeFollowUpPlanV1.showRetrySecondary,
      isFalse,
    );
  });

  test('hand-loop outcome effects are canonicalized', () {
    final success = resolveWorld1CanonicalHandLoopOutcomeEffectsStateV1(
      const World1CanonicalHandLoopOutcomeEffectsInputV1(
        moduleId: 'world1',
        mode: 'campaign',
        stepIndex: 3,
        isCorrect: true,
        errorType: 'range',
        decisionMs: 1200,
        previousAttemptsForStep: 1,
        previousMistakesCount: 2,
        reason: 'Good fold.',
      ),
    );
    expect(success.correctTelemetry['correct'], isTrue);
    expect(success.correctTelemetry['error_type'], 'none');
    expect(success.timeToDecisionTelemetry['time_to_decision_ms'], 1200);
    expect(
      success.effectProfile,
      World1CanonicalHandLoopEffectProfileV1.success,
    );
    expect(success.uiSoundEventName, 'success');
    expect(success.uiSfxAssetName, 'chip_win');
    expect(success.uiHapticEventName, 'success');
    expect(success.triggerSuccessPulse, isTrue);
    expect(success.triggerFailurePulse, isFalse);
    expect(success.nextAttemptsForStep, isNull);
    expect(success.nextMistakesCount, isNull);
    expect(success.showHint, isNull);
    expect(success.feedback, 'Good fold.');
    expect(success.applyCampaignConsequence, isTrue);

    final failure = resolveWorld1CanonicalHandLoopOutcomeEffectsStateV1(
      const World1CanonicalHandLoopOutcomeEffectsInputV1(
        moduleId: 'world1',
        mode: 'campaign',
        stepIndex: 3,
        isCorrect: false,
        errorType: 'range',
        decisionMs: 1400,
        previousAttemptsForStep: 1,
        previousMistakesCount: 2,
        reason: 'That action was too loose.',
      ),
    );
    expect(failure.correctTelemetry['correct'], isFalse);
    expect(failure.correctTelemetry['error_type'], 'range');
    expect(
      failure.effectProfile,
      World1CanonicalHandLoopEffectProfileV1.error,
    );
    expect(failure.uiSoundEventName, 'error');
    expect(failure.uiSfxAssetName, 'chip_lose');
    expect(failure.uiHapticEventName, 'error');
    expect(failure.triggerSuccessPulse, isFalse);
    expect(failure.triggerFailurePulse, isTrue);
    expect(failure.nextAttemptsForStep, 2);
    expect(failure.nextMistakesCount, 3);
    expect(failure.showHint, isTrue);
    expect(failure.feedback, 'That action was too loose.');
    expect(failure.applyCampaignConsequence, isTrue);
  });

  test('hand-loop execution package is canonicalized', () {
    final execution = resolveWorld1CanonicalHandLoopExecutionPackageV1(
      const World1CanonicalHandLoopExecutionPackageInputV1(
        verdict: 'correct',
        errorType: 'range',
        outcomeSummaryLines: <String>['summary 1', 'summary 2'],
        turnFeedLines: <String>['feed 1'],
        heroActionsApplied: 2,
        entryCount: 5,
        stopReasonName: 'showdown',
        isCorrect: true,
        reason: 'Good fold.',
        outcomeType: 'none',
        nextHint: 'Keep folding here.',
      ),
    );
    expect(execution.engineVerdict, 'correct');
    expect(execution.engineErrorType, 'range');
    expect(
      execution.engineSummaryLines,
      const <String>[
        'Hand loop -> hero decisions 2, steps 5, stop showdown',
        'summary 1',
        'summary 2',
      ],
    );
    expect(execution.engineFallbackNote, isNull);
    expect(execution.engineTurnFeedLines, const <String>['feed 1']);
    expect(execution.isCorrect, isTrue);
    expect(execution.reason, 'Good fold.');
    expect(execution.outcomeType, 'none');
    expect(execution.nextHint, 'Keep folding here.');
  });
}

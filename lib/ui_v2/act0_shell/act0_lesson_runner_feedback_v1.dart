part of 'act0_lesson_runner_shell_v1.dart';

class Act0FeedbackShellV1 extends StatelessWidget {
  const Act0FeedbackShellV1({
    super.key,
    required this.title,
    required this.reason,
    this.nextClueLine = '',
    required this.quality,
    required this.sharkyLine,
    required this.sharkyMood,
    required this.selectedLabel,
    this.otherOptions = const [],
    required this.preferredLabel,
    required this.betterLabel,
    this.taskFamily,
    this.hasSeatTargets = false,
    this.potLabel = '',
    this.showPotSweep = false,
    this.signalProof,
    this.contextLabels = const <String>[],
    this.refined = false,
    this.completionSummary,
    this.isAssistedDecision = false,
    this.isRepaired = false,
    this.assistedTitle,
    this.isRepairedFeedback = false,
    this.isLessonRetryFeedback = false,
    this.localizeW1Ctas = false,
    this.firstValueReceiptLine,
    this.repairReasonLine,
    this.repairResultReceiptLine,
    this.repairOutcomeProofLine,
    this.forceShowRepairOutcomeProof = false,
    this.repairContinuesToSourceRecheck = false,
    this.isSourceRecheckAttempt = false,
    this.repairSessionSummaryLines = const <String>[],
    this.forwardCtaLabel,
    this.onTryAnotherExample,
    this.suppressRepairFocus = false,
    this.onBack,
    this.rapidMode = false,
    this.streamlinedDirectDecisionFeedback = false,
    this.cycleStableEnvelope = false,
    this.forceCompactPhoneFeedback = false,
    this.ensureFullCtaGeometry = false,
    this.sceneOwnsFeedbackExplanation = false,
    this.alwaysShowAnswerReason = false,
    this.coachVoiceSeed,
    required this.onContinue,
  });

  final String title;
  final String reason;
  final String nextClueLine;
  final Act0FeedbackQualityV1 quality;
  final String sharkyLine;
  final Act0SharkyMoodV1 sharkyMood;
  final String selectedLabel;
  final List<String> otherOptions;
  final String preferredLabel;
  final String betterLabel;
  final Act0TaskFamilyV1? taskFamily;
  final bool hasSeatTargets;
  final String potLabel;
  final bool showPotSweep;
  final Act0FeedbackSignalProofV1? signalProof;
  final List<String> contextLabels;
  final bool refined;
  final Act0RunnerCompletionSummaryV1? completionSummary;
  final bool isAssistedDecision;
  final bool isRepaired;
  final String? assistedTitle;
  final bool isRepairedFeedback;
  final bool isLessonRetryFeedback;
  final bool localizeW1Ctas;
  final String? firstValueReceiptLine;
  final String? repairReasonLine;
  final String? repairResultReceiptLine;
  final String? repairOutcomeProofLine;
  final bool forceShowRepairOutcomeProof;
  final bool repairContinuesToSourceRecheck;
  final bool isSourceRecheckAttempt;
  final List<String> repairSessionSummaryLines;
  final String? forwardCtaLabel;
  final VoidCallback? onTryAnotherExample;
  final bool suppressRepairFocus;
  final VoidCallback? onBack;
  final bool rapidMode;
  final bool streamlinedDirectDecisionFeedback;
  final bool cycleStableEnvelope;
  final bool forceCompactPhoneFeedback;
  final bool ensureFullCtaGeometry;
  final bool sceneOwnsFeedbackExplanation;
  final bool alwaysShowAnswerReason;
  final String? coachVoiceSeed;
  final VoidCallback onContinue;

  bool get _hasRepairedFeedback => isRepaired || isRepairedFeedback;

  @override
  Widget build(BuildContext context) => Act0ChoiceResultSemanticsV1(
    title: _hasRepairedFeedback
        ? _fixedFeedbackLabelV1(context, lessonRetry: isLessonRetryFeedback)
        : isAssistedDecision && quality.passes
        ? assistedTitle ?? title
        : title,
    selectedLabel: selectedLabel,
    otherOptions: otherOptions,
    reason: reason,
    assisted: isAssistedDecision,
    child: _buildFeedback(context),
  );

  Widget _buildFeedback(BuildContext context) {
    final isWrong = quality == Act0FeedbackQualityV1.wrong;
    final isSuboptimal = quality == Act0FeedbackQualityV1.suboptimal;
    final isAcceptable = quality == Act0FeedbackQualityV1.acceptable;
    final isRepairFocusState =
        !rapidMode &&
        !suppressRepairFocus &&
        (repairReasonLine?.trim().isNotEmpty ?? false);
    // An open Review item can still supply table focus after a correct
    // lesson answer. It does not make the forward action another retry.
    final isCorrectWithPendingRepair = isRepairFocusState && quality.passes;
    final repairReceiptLine = repairResultReceiptLine?.trim() ?? '';
    final repairOutcomeProofLine = this.repairOutcomeProofLine?.trim() ?? '';
    final hasRepairOutcomeProof = repairOutcomeProofLine.isNotEmpty;
    // Repair success remains partial. Only the explicit source-recheck
    // projection can make the stronger recovery claim.
    final isRecoveredSourceRecheck =
        !isAssistedDecision &&
        hasRepairOutcomeProof &&
        forceShowRepairOutcomeProof;
    final isFailedSourceRecheck = isWrong && isSourceRecheckAttempt;
    final hasProofEarnedState =
        !isAssistedDecision &&
        (hasRepairOutcomeProof ||
            repairReceiptLine.toLowerCase().startsWith('repair fixed:') ||
            repairReceiptLine.toLowerCase().startsWith('replay fixed:') ||
            repairReceiptLine.toLowerCase().startsWith('fix landed:'));
    final reservesFullCtaGeometry =
        ensureFullCtaGeometry && hasProofEarnedState;
    final media = MediaQuery.of(context);
    final view = View.of(context);
    final fullViewportHeight = view.physicalSize.height / view.devicePixelRatio;
    final safeVertical = media.viewPadding.vertical > 0
        ? media.viewPadding.vertical
        : media.padding.vertical;
    final usableHeight = media.size.height - safeVertical;
    final isCompactRefinedFeedback =
        !rapidMode &&
        (forceCompactPhoneFeedback ||
            (refined &&
                (usableHeight <= 900 ||
                    (fullViewportHeight > 900 && fullViewportHeight <= 980))) ||
            (!refined &&
                fullViewportHeight > 900 &&
                fullViewportHeight <= 980));
    const missedCueTone = Color(0xFFFFA296);
    final tone = hasProofEarnedState
        ? Act0ShellTokensV1.gold
        : isRepairFocusState
        ? Act0ShellTokensV1.gold
        : isWrong
        ? missedCueTone
        : isSuboptimal
        ? Act0ShellTokensV1.gold
        : Act0ShellTokensV1.primary;
    final icon = hasProofEarnedState
        ? Icons.verified_rounded
        : isWrong
        ? Icons.close_rounded
        : isSuboptimal
        ? Icons.trending_up_rounded
        : Icons.check_rounded;
    final iconKey = hasProofEarnedState
        ? const Key('act0_shell_feedback_icon_proof_earned')
        : isWrong
        ? const Key('act0_shell_feedback_icon_wrong')
        : (isSuboptimal
              ? const Key('act0_shell_feedback_icon_suboptimal')
              : const Key('act0_shell_feedback_icon_correct'));
    final sharkyTone = hasProofEarnedState
        ? Act0ShellTokensV1.gold
        : isWrong
        ? missedCueTone
        : isSuboptimal
        ? Act0ShellTokensV1.gold
        : Act0ShellTokensV1.primary;
    final resolvedTitle = _hasRepairedFeedback
        ? _fixedFeedbackLabelV1(context, lessonRetry: isLessonRetryFeedback)
        : isAssistedDecision && !isWrong
        ? assistedTitle ??
              (act0AcademyLanguageV1(context) == 'ru'
                  ? '\u0412\u0435\u0440\u043d\u043e \u0441 \u043f\u043e\u0434\u0441\u043a\u0430\u0437\u043a\u043e\u0439'
                  : 'Correct with help')
        : _feedbackTitleFloorV1(
            context,
            title: title,
            quality: quality,
            contextLabels: contextLabels,
          );
    final resolvedSharkyLine =
        _premiumSafeFeedbackTitleV1(sharkyLine.trim()) ?? sharkyLine;
    final reactionLine = act0RuntimeFeedbackCoachLineV1(
      context,
      authoredLine: resolvedSharkyLine,
      title: resolvedTitle,
      quality: quality,
      variationSeed:
          coachVoiceSeed ??
          '${quality.name}|${resolvedTitle.trim().toLowerCase()}|${resolvedSharkyLine.trim().toLowerCase()}',
      taskFamily: taskFamily,
    );
    final primaryResultLabel = _hasRepairedFeedback
        ? _fixedFeedbackLabelV1(context, lessonRetry: isLessonRetryFeedback)
        : _feedbackPrimaryResultLabelV1(
            context,
            quality: quality,
            repairReceiptLine: repairResultReceiptLine,
          );
    final stateLabel = isRecoveredSourceRecheck
        ? 'Original read proven'
        : isFailedSourceRecheck
        ? 'Original read needs one more rep'
        : isRepairFocusState
        ? 'Practice the clue'
        : primaryResultLabel;
    final stateDetail = isFailedSourceRecheck
        ? 'This was the original hand. Review the clue before the next practice.'
        : isRepairFocusState
        ? 'This practice hand keeps the missed clue in view.'
        : isWrong
        ? 'Start with the table clue, then choose the action.'
        : '';
    // Sharky coaches a miss and acknowledges proven recovery only. Ordinary
    // correct and repair feedback keep the learning scene calm.
    final showSharkyCompanion =
        isRecoveredSourceRecheck || (!isCompactRefinedFeedback && isWrong);
    final showVerdictTitle = resolvedTitle.isNotEmpty;
    final actionPrefix = act0RuntimeFeedbackActionPrefixV1(
      context,
      quality,
      taskFamily: taskFamily,
      hasSeatTargets: hasSeatTargets,
    );
    final fullActionLabel = _premiumSafeFeedbackOptionLabelV1(
      act0RuntimeLocalizedOptionLabelV1(
        context,
        isWrong || isAcceptable || isSuboptimal ? betterLabel : preferredLabel,
      ),
    );
    final actionLabel = isCompactRefinedFeedback
        ? _compactFeedbackActionLabelV1(fullActionLabel)
        : fullActionLabel;
    final localizedContextLabels = [
      for (final label in (refined ? contextLabels.take(1) : contextLabels))
        _premiumSafeFeedbackOptionLabelV1(
          act0RuntimeLocalizedContextLabelV1(context, label),
        ).trim(),
    ];
    final visibleContextLabels = _dedupedFeedbackContextLabelsV1(
      localizedContextLabels,
      preferredLine: actionLabel,
      selectedLine: isWrong || isSuboptimal ? selectedLabel : '',
      statusLine: showVerdictTitle
          ? act0RuntimeLocalizedGeneralLabelV1(context, resolvedTitle).trim()
          : '',
      signalLabel: signalProof?.label ?? '',
      proofLine: signalProof?.proofLine ?? '',
    );
    final resolvedReason = _feedbackReasonFloorV1(
      context,
      reason: reason,
      quality: quality,
      selectedLabel: selectedLabel,
      preferredLabel: preferredLabel,
      betterLabel: betterLabel,
      contextLabels: contextLabels,
    );
    final preserveFullCompactReason =
        isCompactRefinedFeedback &&
        _shouldPreserveFullCompactFeedbackReasonV1(resolvedReason);
    final skillReceipt =
        firstValueReceiptLine == null ||
            isAssistedDecision ||
            _hasRepairedFeedback
        ? null
        : _skillReceiptForSignalProofV1(proof: signalProof, quality: quality);
    final repairReason = repairReasonLine?.trim() ?? '';
    final visibleRepairReasonLines = suppressRepairFocus
        ? const <String>[]
        : _visibleRepairReasonLinesV1(
            quality: quality,
            signalProof: signalProof,
            repairReasonLine: repairReason,
            repairReceiptLine: repairReceiptLine,
          );
    final visibleRepairSessionSummaryLines = [
      for (final line in repairSessionSummaryLines)
        if (line.trim().isNotEmpty) line.trim(),
    ];
    final fallbackReceiptLine = repairReceiptLine.isNotEmpty
        ? repairReceiptLine
        : isAssistedDecision || _hasRepairedFeedback
        ? null
        : firstValueReceiptLine?.trim();
    final receiptSplitIndex = fallbackReceiptLine?.indexOf('. Next:') ?? -1;
    final receiptTitle = isRecoveredSourceRecheck
        ? ''
        : hasRepairOutcomeProof
        ? 'Repair landed'
        : repairReceiptLine.isNotEmpty
        ? 'Repair result'
        : skillReceipt?.title ??
              (fallbackReceiptLine == null || fallbackReceiptLine.isEmpty
                  ? ''
                  : receiptSplitIndex < 0
                  ? fallbackReceiptLine
                  : fallbackReceiptLine.substring(0, receiptSplitIndex + 1));
    final receiptDetail = hasRepairOutcomeProof
        ? repairOutcomeProofLine
        : repairReceiptLine.isNotEmpty
        ? repairReceiptLine
        : skillReceipt?.detail ??
              (fallbackReceiptLine == null ||
                      fallbackReceiptLine.isEmpty ||
                      receiptSplitIndex < 0
                  ? ''
                  : fallbackReceiptLine
                        .substring(receiptSplitIndex + 2)
                        .trim());
    final isFocusedCompactProofFeedback =
        isCompactRefinedFeedback && hasProofEarnedState;
    final shouldShowReceiptProof =
        !rapidMode &&
        (!isFocusedCompactProofFeedback || forceShowRepairOutcomeProof) &&
        (receiptTitle.isNotEmpty ||
            (isRecoveredSourceRecheck && receiptDetail.isNotEmpty)) &&
        (!isWrong || hasRepairOutcomeProof);
    final receiptNextLine = skillReceipt == null
        ? ''
        : switch (skillReceipt.outcome) {
            Act0SkillReceiptOutcomeV1.learned =>
              'Next: practice the same table clue once more.',
            Act0SkillReceiptOutcomeV1.repairStarted =>
              'Next: try this table clue once more.',
            Act0SkillReceiptOutcomeV1.needsRep =>
              'Next: practice the same table clue once more.',
          };
    final selectedContrastLine =
        !isCompactRefinedFeedback &&
            (isWrong || isSuboptimal) &&
            selectedLabel.isNotEmpty
        ? _feedbackSelectedLineV1(context, selectedLabel)
        : '';
    final hasRepairTeachingBlock =
        isWrong && visibleRepairReasonLines.isNotEmpty;
    final showSignalProofInProofStack =
        !rapidMode && !hasRepairTeachingBlock && signalProof != null;
    final showActionContrast = actionLabel.isNotEmpty;
    final usesSharedAccessibilitySurface =
        (streamlinedDirectDecisionFeedback || cycleStableEnvelope) &&
        isCompactRefinedFeedback;
    final pinsAllocatedFeedbackCta =
        usesSharedAccessibilitySurface && ensureFullCtaGeometry && !rapidMode;
    final pinsF1FeedbackCta =
        usesSharedAccessibilitySurface &&
        hasSeatTargets &&
        !hasRepairTeachingBlock;
    final isExactReplayRepair =
        repairResultReceiptLine?.trim().toLowerCase().startsWith('replay ') ==
            true ||
        repairResultReceiptLine?.trim() ==
            'Fix landed: you handled this spot correctly.' ||
        repairResultReceiptLine?.trim() ==
            'This spot still needs one more careful rep.';
    Widget buildContinueAction() {
      return Row(
        children: [
          if (onBack != null) ...[
            _DockBackButtonV1(
              key: const Key('act0_shell_interaction_back_cta'),
              onPressed: onBack!,
            ),
            const SizedBox(width: Act0ShellTokensV1.gapSm),
          ],
          if (onTryAnotherExample != null) ...[
            Expanded(
              child: TextButton(
                key: const Key('act0_shell_feedback_another_example'),
                onPressed: onTryAnotherExample,
                style: TextButton.styleFrom(
                  foregroundColor: Act0ShellTokensV1.info,
                  minimumSize: const Size(48, 48),
                ),
                child: const Text('Try another example'),
              ),
            ),
            const SizedBox(width: Act0ShellTokensV1.gapSm),
          ],
          Expanded(
            child: Act0SkinPrimaryButtonV1(
              compact: true,
              controlKey: const Key('act0_shell_feedback_continue_cta'),
              labelKey: const Key('act0_shell_feedback_continue_cta_label'),
              onPressed: onContinue,
              label:
                  (localizeW1Ctas && forwardCtaLabel != null
                      ? act0AcademyW1CtaV1(context, forwardCtaLabel!)
                      : forwardCtaLabel) ??
                  (localizeW1Ctas
                      ? act0AcademyW1CtaV1(
                          context,
                          isRecoveredSourceRecheck
                              ? 'Continue'
                              : isWrong && isSourceRecheckAttempt
                              ? 'Continue to Review'
                              : repairReceiptLine.isNotEmpty && !isWrong
                              ? repairContinuesToSourceRecheck
                                    ? 'Check original read'
                                    : 'Continue to Review'
                              : isCorrectWithPendingRepair
                              ? 'Continue'
                              : isWrong || isRepairFocusState
                              ? isExactReplayRepair
                                    ? 'Try this spot again'
                                    : 'Try same clue'
                              : 'Next hand',
                        )
                      : (isRecoveredSourceRecheck
                            ? 'Continue'
                            : isWrong && isSourceRecheckAttempt
                            ? 'Continue to Review'
                            : repairReceiptLine.isNotEmpty && !isWrong
                            ? repairContinuesToSourceRecheck
                                  ? 'Check original read'
                                  : 'Continue to Review'
                            : isCorrectWithPendingRepair
                            ? 'Continue'
                            : isWrong || isRepairFocusState
                            ? isExactReplayRepair
                                  ? 'Try this spot again'
                                  : 'Try same clue'
                            : 'Next hand')),
            ),
          ),
        ],
      );
    }

    final showReason =
        alwaysShowAnswerReason || (!rapidMode && !hasRepairTeachingBlock);
    final foldsNextClueIntoExplanation =
        pinsF1FeedbackCta &&
        showReason &&
        cycleStableEnvelope &&
        nextClueLine.trim().isNotEmpty;
    final showRepairFocus = !rapidMode && visibleRepairReasonLines.isNotEmpty;
    final showProofStack =
        !rapidMode &&
        (showSignalProofInProofStack ||
            showActionContrast ||
            showReason ||
            showRepairFocus);
    // Keep the outer cycle envelope stable, but center the complete semantic
    // outcome only when it has no repair, proof-earned, receipt, completion,
    // or long-copy obligation. These are state flags rather than copy heuristics.
    final usesCohesiveShortOutcome =
        usesSharedAccessibilitySurface &&
        !isWrong &&
        !isSuboptimal &&
        !hasRepairTeachingBlock &&
        !hasProofEarnedState &&
        !isRecoveredSourceRecheck &&
        !isSourceRecheckAttempt &&
        repairReceiptLine.isEmpty &&
        !shouldShowReceiptProof &&
        visibleRepairSessionSummaryLines.isEmpty &&
        completionSummary == null;
    final showActionContrastEyebrow =
        isAcceptable ||
        (!(streamlinedDirectDecisionFeedback && isCompactRefinedFeedback) &&
            !usesCohesiveShortOutcome);
    final feedbackStateKey = hasProofEarnedState
        ? const Key('act0_shell_wave2_feedback_proof_earned_state')
        : isRepairFocusState
        ? const Key('act0_shell_wave2_feedback_repair_state')
        : isWrong
        ? const Key('act0_shell_wave2_feedback_miss_state')
        : const Key('act0_shell_wave2_feedback_correct_state');
    final feedbackTreatmentKey = isWrong
        ? const Key('act0_shell_feedback_missed_cue_treatment')
        : const Key('act0_shell_feedback_non_miss_treatment');
    final feedbackSharkySlotKey = hasProofEarnedState
        ? const Key('act0_shell_feedback_sharky_slot_proof_earned')
        : isRepairFocusState || isSuboptimal
        ? const Key('act0_shell_feedback_sharky_slot_repair')
        : isWrong
        ? const Key('act0_shell_feedback_sharky_slot_wrong')
        : const Key('act0_shell_feedback_sharky_slot_proof');
    final companionRoleLabel = _hasRepairedFeedback
        ? _fixedFeedbackLabelV1(context, lessonRetry: isLessonRetryFeedback)
        : hasProofEarnedState
        ? isRecoveredSourceRecheck
              ? 'Original read proven'
              : 'Repair landed'
        : isRepairFocusState
        ? 'Repair focus'
        : isSuboptimal
        ? 'Better read'
        : isWrong
        ? 'Missed cue'
        : 'Correct read';
    if (sceneOwnsFeedbackExplanation) {
      final missedAnswer = _premiumSafeFeedbackOptionLabelV1(
        selectedLabel.trim(),
      );
      final bestAnswer = _premiumSafeFeedbackOptionLabelV1(
        betterLabel.trim().isEmpty ? preferredLabel.trim() : betterLabel.trim(),
      );
      final showAnswerContrast =
          isWrong &&
          !suppressRepairFocus &&
          missedAnswer.isNotEmpty &&
          bestAnswer.isNotEmpty;
      final nextActionLine = forwardCtaLabel == 'Continue lesson'
          ? 'This mistake is saved in Review.'
          : suppressRepairFocus && forwardCtaLabel == 'Next check'
          ? 'Continue to the next diagnostic question.'
          : suppressRepairFocus && forwardCtaLabel == 'See my start'
          ? 'See your suggested starting point.'
          : forwardCtaLabel == 'Continue to Review'
          ? 'Return to Review to choose the next repair. Open mistakes stay available.'
          : isCorrectWithPendingRepair
          ? null
          : isWrong || isRepairFocusState
          ? 'Try the same table clue once more.'
          : repairContinuesToSourceRecheck
          ? 'Return to the original read and prove the repair.'
          : 'Continue to the next table read.';
      return LayoutBuilder(
        builder: (context, constraints) {
          final hasBoundedHeight = constraints.hasBoundedHeight;
          final resultBody = SingleChildScrollView(
            key: const Key('act0_shell_feedback_allocated_body_scroll'),
            primary: false,
            physics: const ClampingScrollPhysics(),
            child: KeyedSubtree(
              key: feedbackTreatmentKey,
              child: Column(
                key: const Key('act0_shell_feedback_primary_result_block'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showAnswerContrast) ...[
                    Act0SkinAnswerOptionRowV1(
                      compact: true,
                      verdict: Act0SkinAnswerVerdictV1.notThisOne,
                      label: missedAnswer,
                    ),
                    const SizedBox(height: 3),
                    Act0SkinAnswerOptionRowV1(
                      compact: true,
                      verdict: Act0SkinAnswerVerdictV1.better,
                      verdictLabel: 'Right answer',
                      label: bestAnswer,
                    ),
                    const SizedBox(height: 7),
                  ],
                  if (isAcceptable && bestAnswer.isNotEmpty) ...[
                    Act0SkinAnswerOptionRowV1(
                      compact: true,
                      verdict: Act0SkinAnswerVerdictV1.better,
                      verdictLabel: actionPrefix,
                      label: bestAnswer,
                    ),
                    const SizedBox(height: 7),
                  ],
                  // Source-owned proof must be visible before reporting it viewed.
                  // The scene already owns the causal explanation; this compact
                  // slot owns the earned result without moving the table or CTA.
                  if (isRecoveredSourceRecheck) ...[
                    Text(
                      companionRoleLabel,
                      key: const Key(
                        'act0_shell_feedback_primary_result_label',
                      ),
                      style: Act0ShellTokensV1.label.copyWith(
                        color: tone,
                        fontSize: 10.0,
                        letterSpacing: 0.45,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      repairOutcomeProofLine,
                      key: const Key('act0_shell_repair_outcome_proof_line'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Act0ShellTokensV1.body.copyWith(
                        color: Act0ShellTokensV1.text,
                        fontSize: 11.4,
                        height: 1.10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ] else ...[
                    if (suppressRepairFocus) ...[
                      Text(
                        forwardCtaLabel == 'See my start'
                            ? 'NEXT \u00B7 YOUR START'
                            : 'NEXT \u00B7 CONTINUE CHECK',
                        key: const Key(
                          'act0_shell_feedback_primary_result_label',
                        ),
                        style: Act0ShellTokensV1.label.copyWith(
                          color: tone,
                          fontSize: 10.0,
                          letterSpacing: 0.45,
                        ),
                      ),
                      const SizedBox(height: 3),
                    ],
                    if (nextActionLine != null)
                      Text(
                        nextActionLine,
                        key: const Key('act0_shell_feedback_rhythm_verdict'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Act0ShellTokensV1.body.copyWith(
                          color: Act0ShellTokensV1.text,
                          fontSize: 13.2,
                          height: 1.14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                  ],
                ],
              ),
            ),
          );
          // B6: the verdict arrives rather than cuts. On this route the scene
          // owns the causal explanation, so the table's quieting field and its
          // asserting clue already carry "the state changed; here is why" \u2014
          // this is the third beat, the verdict itself becoming current.
          //
          // Reuses the accepted reveal widget rather than inventing motion:
          // it starts at 0.92 opacity, so the continue CTA is visible and
          // interaction-ready on the very first frame, never gated behind a
          // duration, and it resolves to identical geometry.
          return _ProofMotionRevealV1(
            key: const Key('act0_shell_feedback_card_motion_reveal'),
            child: Container(
              key: const Key('act0_shell_feedback_card'),
              padding: const EdgeInsets.fromLTRB(13, 10, 13, 8),
              child: Column(
                mainAxisSize: hasBoundedHeight
                    ? MainAxisSize.max
                    : MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (hasBoundedHeight)
                    Expanded(child: resultBody)
                  else if (showAnswerContrast)
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 42),
                      child: resultBody,
                    )
                  else
                    resultBody,
                  const SizedBox(height: 7),
                  buildContinueAction(),
                ],
              ),
            ),
          );
        },
      );
    }
    return _ProofMotionRevealV1(
      key: const Key('act0_shell_feedback_card_motion_reveal'),
      child: KeyedSubtree(
        key: feedbackStateKey,
        child: LayoutBuilder(
          builder: (context, constraints) => Container(
            key: const Key('act0_shell_feedback_card'),
            constraints: usesSharedAccessibilitySurface
                ? BoxConstraints.tightFor(height: constraints.maxHeight)
                : null,
            padding: usesSharedAccessibilitySurface
                ? EdgeInsets.fromLTRB(
                    5,
                    pinsF1FeedbackCta || reservesFullCtaGeometry
                        ? 0
                        : Act0ShellTokensV1.gapMd,
                    5,
                    // The runner is already inside the route-level SafeArea.
                    // Reserving viewPadding again clips the compact feedback
                    // CTA at enlarged text.
                    4,
                  )
                : EdgeInsets.all(
                    rapidMode
                        ? 8
                        : (isCompactRefinedFeedback ? 5 : (refined ? 8 : 10)),
                  ),
            // Feedback states share the runner's single lower-stage surface.
            // Accent belongs to the outcome, not to a state-specific card.
            decoration: usesSharedAccessibilitySurface
                ? null
                : BoxDecoration(
                    color: Act0ShellTokensV1.surface2.withValues(alpha: 0.98),
                    borderRadius: BorderRadius.circular(
                      Act0ShellTokensV1.radiusCard,
                    ),
                  ),
            child: Builder(
              builder: (context) {
                final feedbackBody = Column(
                  key: usesCohesiveShortOutcome
                      ? const Key('act0_shell_feedback_cohesive_group')
                      : null,
                  mainAxisSize: pinsAllocatedFeedbackCta
                      ? MainAxisSize.min
                      : usesCohesiveShortOutcome
                      ? MainAxisSize.max
                      : MainAxisSize.min,
                  mainAxisAlignment: pinsAllocatedFeedbackCta
                      ? MainAxisAlignment.start
                      : usesCohesiveShortOutcome
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showSharkyCompanion) ...[
                          Act0SharkyMascotV1(
                            key: feedbackSharkySlotKey,
                            mood: sharkyMood,
                            tone: sharkyTone,
                            size: isCompactRefinedFeedback
                                ? 30
                                : (refined ? 46 : 50),
                          ),
                          const SizedBox(width: 8),
                        ] else if (!isCompactRefinedFeedback) ...[
                          Container(
                            key: const Key('act0_shell_feedback_state_mark'),
                            width: refined ? 42 : 46,
                            height: refined ? 42 : 46,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: tone.withValues(alpha: 0.10),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: tone.withValues(alpha: 0.30),
                              ),
                            ),
                            child: Icon(
                              icon,
                              color: tone,
                              size: refined ? 21 : 23,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!rapidMode && stateLabel.isNotEmpty) ...[
                                KeyedSubtree(
                                  key: const Key(
                                    'act0_shell_feedback_primary_result_block',
                                  ),
                                  child: KeyedSubtree(
                                    key: const Key(
                                      'act0_shell_feedback_primary_result_label',
                                    ),
                                    child: Text(
                                      stateLabel,
                                      key: const Key(
                                        'act0_shell_feedback_rhythm_verdict',
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.fade,
                                      style: Act0ShellTokensV1.label.copyWith(
                                        color: tone,
                                        fontSize: 13.5,
                                        height: 1.04,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 1),
                              ],
                              if (!isCompactRefinedFeedback &&
                                  (stateDetail.isNotEmpty ||
                                      (showSharkyCompanion &&
                                          reactionLine.isNotEmpty)))
                                KeyedSubtree(
                                  key: const Key(
                                    'act0_shell_feedback_companion_role',
                                  ),
                                  child: Text(
                                    stateDetail.isNotEmpty
                                        ? stateDetail
                                        : '$companionRoleLabel \u00B7 $reactionLine',
                                    key: const Key(
                                      'act0_shell_sharky_outcome_reaction',
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.fade,
                                    style: Act0ShellTokensV1.muted.copyWith(
                                      color: Act0ShellTokensV1.textMuted,
                                      fontSize: refined ? 10.0 : 10.5,
                                      height: 1.06,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (rapidMode && actionLabel.isNotEmpty) ...[
                      Text(
                        '$actionPrefix: $actionLabel',
                        key: const Key('act0_shell_feedback_hero_action'),
                        maxLines: 2,
                        overflow: TextOverflow.fade,
                        style: Act0ShellTokensV1.body.copyWith(
                          color: Act0ShellTokensV1.text,
                          fontSize: 15,
                          height: 1.06,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 0),
                    ],
                    if (!rapidMode && !isCompactRefinedFeedback) ...[
                      SizedBox(height: isCompactRefinedFeedback ? 4 : 6),
                      _FeedbackStateRailV1(
                        tone: tone,
                        compact: isCompactRefinedFeedback,
                      ),
                    ],
                    if (showProofStack) ...[
                      SizedBox(height: isCompactRefinedFeedback ? 4 : 8),
                      Builder(
                        builder: (context) {
                          final proofStack = Column(
                            key: const Key('act0_shell_feedback_proof_stack'),
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (showActionContrast) ...[
                                _FeedbackActionContrastBlockV1(
                                  actionLine: '$actionPrefix: $actionLabel',
                                  selectedLine: selectedContrastLine,
                                  tone: tone,
                                  compact: isCompactRefinedFeedback,
                                  refined: refined,
                                  showEyebrow: showActionContrastEyebrow,
                                ),
                                SizedBox(
                                  height: isCompactRefinedFeedback ? 7 : 10,
                                ),
                              ],
                              if (showSignalProofInProofStack) ...[
                                _FeedbackSignalProofRowV1(
                                  proofLine: signalProof!.proofLine,
                                  tone: tone,
                                  compact: isCompactRefinedFeedback,
                                ),
                                SizedBox(
                                  height: isCompactRefinedFeedback ? 2 : 3,
                                ),
                              ],
                              if (showReason)
                                cycleStableEnvelope &&
                                        !usesSharedAccessibilitySurface
                                    ? ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxHeight: pinsF1FeedbackCta
                                              ? 20
                                              : isCompactRefinedFeedback
                                              ? 34
                                              : 60,
                                        ),
                                        child: SingleChildScrollView(
                                          key: const Key(
                                            'act0_shell_feedback_explanation_scroll',
                                          ),
                                          primary: false,
                                          physics:
                                              const ClampingScrollPhysics(),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(
                                                resolvedReason,
                                                key: const Key(
                                                  'act0_shell_feedback_reason',
                                                ),
                                                style: Act0ShellTokensV1.body
                                                    .copyWith(
                                                      color: Act0ShellTokensV1
                                                          .textMuted,
                                                      fontSize:
                                                          isCompactRefinedFeedback
                                                          ? 11.4
                                                          : (refined
                                                                ? 12.0
                                                                : 12.5),
                                                      height:
                                                          isCompactRefinedFeedback
                                                          ? 1.08
                                                          : 1.16,
                                                    ),
                                              ),
                                              if (foldsNextClueIntoExplanation) ...[
                                                const SizedBox(height: 3),
                                                Text(
                                                  nextClueLine.trim(),
                                                  key: const Key(
                                                    'act0_shell_feedback_next_clue',
                                                  ),
                                                  style: Act0ShellTokensV1.label
                                                      .copyWith(
                                                        color: tone.withValues(
                                                          alpha: 0.9,
                                                        ),
                                                        fontSize: 10.5,
                                                        height: 1.1,
                                                      ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      )
                                    : Text(
                                        resolvedReason,
                                        key: const Key(
                                          'act0_shell_feedback_reason',
                                        ),
                                        maxLines:
                                            isCompactRefinedFeedback &&
                                                !usesSharedAccessibilitySurface &&
                                                !preserveFullCompactReason
                                            ? 2
                                            : null,
                                        overflow:
                                            isCompactRefinedFeedback &&
                                                !usesSharedAccessibilitySurface &&
                                                !preserveFullCompactReason
                                            ? TextOverflow.fade
                                            : null,
                                        style: Act0ShellTokensV1.body.copyWith(
                                          color: Act0ShellTokensV1.textMuted,
                                          fontSize: isCompactRefinedFeedback
                                              ? 11.4
                                              : (refined ? 12.0 : 12.5),
                                          height: isCompactRefinedFeedback
                                              ? 1.08
                                              : 1.16,
                                        ),
                                      ),
                              if (!rapidMode &&
                                  nextClueLine.trim().isNotEmpty &&
                                  !foldsNextClueIntoExplanation) ...[
                                SizedBox(
                                  height: isCompactRefinedFeedback ? 3 : 6,
                                ),
                                Text(
                                  nextClueLine.trim(),
                                  key: const Key(
                                    'act0_shell_feedback_next_clue',
                                  ),
                                  maxLines:
                                      isCompactRefinedFeedback &&
                                          !usesSharedAccessibilitySurface
                                      ? 2
                                      : null,
                                  overflow:
                                      isCompactRefinedFeedback &&
                                          !usesSharedAccessibilitySurface
                                      ? TextOverflow.fade
                                      : null,
                                  style: Act0ShellTokensV1.label.copyWith(
                                    color: tone.withValues(alpha: 0.9),
                                    fontSize: isCompactRefinedFeedback
                                        ? 10.5
                                        : 11.0,
                                    height: 1.1,
                                  ),
                                ),
                              ],
                              if (showRepairFocus) ...[
                                SizedBox(
                                  height: isCompactRefinedFeedback ? 6 : 10,
                                ),
                                const _FeedbackVerdictDividerV1(),
                                SizedBox(
                                  height: isCompactRefinedFeedback ? 6 : 8,
                                ),
                                _FeedbackVisibleRepairReasonBlockV1(
                                  lines: visibleRepairReasonLines,
                                  compact: isCompactRefinedFeedback,
                                ),
                              ],
                            ],
                          );
                          if (!usesSharedAccessibilitySurface ||
                              (usesCohesiveShortOutcome &&
                                  !preserveFullCompactReason)) {
                            return proofStack;
                          }
                          return ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 64),
                            child: SingleChildScrollView(
                              key: const Key(
                                'act0_shell_feedback_proof_stack_scroll',
                              ),
                              primary: false,
                              physics: const ClampingScrollPhysics(),
                              child: proofStack,
                            ),
                          );
                        },
                      ),
                    ],
                    if (!rapidMode &&
                        showVerdictTitle &&
                        !isCompactRefinedFeedback) ...[
                      const SizedBox(height: 7),
                      Row(
                        children: [
                          Icon(icon, key: iconKey, color: tone, size: 15),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              act0RuntimeLocalizedGeneralLabelV1(
                                context,
                                resolvedTitle,
                              ),
                              key: const Key(
                                'act0_shell_feedback_status_label',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.fade,
                              style: Act0ShellTokensV1.muted.copyWith(
                                color: tone.withValues(alpha: 0.92),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (!rapidMode &&
                        !MediaQuery.disableAnimationsOf(context) &&
                        showPotSweep &&
                        potLabel.isNotEmpty) ...[
                      const SizedBox(height: 9),
                      _PotSweepMomentV1(potLabel: potLabel),
                    ],
                    if (!rapidMode &&
                        !isCompactRefinedFeedback &&
                        visibleContextLabels.isNotEmpty) ...[
                      const SizedBox(height: 7),
                      Wrap(
                        key: const Key('act0_shell_feedback_context_labels'),
                        spacing: 6,
                        runSpacing: 5,
                        children: [
                          for (final label in visibleContextLabels)
                            _DockStatusPillV1(
                              label: label,
                              icon: Icons.check_rounded,
                              tone: tone,
                            ),
                        ],
                      ),
                    ],
                    if (shouldShowReceiptProof) ...[
                      const SizedBox(height: 8),
                      const _FeedbackVerdictDividerV1(),
                      const SizedBox(height: 8),
                      Builder(
                        builder: (context) {
                          final receiptProof = KeyedSubtree(
                            key: const Key(
                              'act0_shell_repair_result_system_card',
                            ),
                            child: _FeedbackProofKeyWrapperV1(
                              proofKey: repairReceiptLine.isNotEmpty
                                  ? const Key(
                                      'act0_shell_repair_receipt_proof_block',
                                    )
                                  : hasRepairOutcomeProof
                                  ? const Key('act0_shell_repair_outcome_proof')
                                  : null,
                              child: KeyedSubtree(
                                key: repairReceiptLine.isNotEmpty
                                    ? const Key(
                                        'act0_shell_repair_result_receipt',
                                      )
                                    : hasRepairOutcomeProof
                                    ? const Key(
                                        'act0_shell_repair_outcome_proof_card',
                                      )
                                    : const Key(
                                        'act0_shell_first_value_receipt',
                                      ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (receiptTitle.isNotEmpty)
                                      Text(
                                        receiptTitle,
                                        key: repairReceiptLine.isNotEmpty
                                            ? const Key(
                                                'act0_shell_repair_result_receipt_title',
                                              )
                                            : hasRepairOutcomeProof
                                            ? const Key(
                                                'act0_shell_repair_outcome_proof_title',
                                              )
                                            : null,
                                        style: Act0ShellTokensV1.label.copyWith(
                                          color: Act0ShellTokensV1.primary,
                                          fontSize: isCompactRefinedFeedback
                                              ? 10.0
                                              : 10.5,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    if (receiptDetail.isNotEmpty) ...[
                                      if (receiptTitle.isNotEmpty)
                                        const SizedBox(height: 4),
                                      Text(
                                        receiptDetail,
                                        key: repairReceiptLine.isNotEmpty
                                            ? const Key(
                                                'act0_shell_repair_result_outcome_line',
                                              )
                                            : hasRepairOutcomeProof
                                            ? const Key(
                                                'act0_shell_repair_outcome_proof_line',
                                              )
                                            : null,
                                        style: Act0ShellTokensV1.body.copyWith(
                                          color: Act0ShellTokensV1.text,
                                          fontSize: isCompactRefinedFeedback
                                              ? 13.0
                                              : 15.0,
                                          height: 1.12,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                    if (receiptNextLine.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        receiptNextLine,
                                        style: Act0ShellTokensV1.label.copyWith(
                                          color: Act0ShellTokensV1.textMuted,
                                          fontSize: isCompactRefinedFeedback
                                              ? 10.0
                                              : 10.5,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                          if (!usesSharedAccessibilitySurface)
                            return receiptProof;
                          return ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 44),
                            child: SingleChildScrollView(
                              key: const Key(
                                'act0_shell_feedback_receipt_scroll',
                              ),
                              primary: false,
                              physics: const ClampingScrollPhysics(),
                              child: receiptProof,
                            ),
                          );
                        },
                      ),
                    ],
                    if (!rapidMode &&
                        !isFocusedCompactProofFeedback &&
                        visibleRepairSessionSummaryLines.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const _FeedbackVerdictDividerV1(),
                      const SizedBox(height: 8),
                      _RepairSystemProofBlockV1(
                        cardKey: const Key(
                          'act0_shell_repair_closure_system_card',
                        ),
                        tone: Act0ShellTokensV1.gold,
                        showLabel: false,
                        child: _FeedbackProofKeyWrapperV1(
                          proofKey: const Key(
                            'act0_shell_session_summary_proof_block',
                          ),
                          child: _FeedbackSessionSummaryCeremonyBlockV1(
                            lines: visibleRepairSessionSummaryLines,
                          ),
                        ),
                      ),
                    ],
                    if (!rapidMode &&
                        !isAssistedDecision &&
                        !_hasRepairedFeedback &&
                        completionSummary != null) ...[
                      const SizedBox(height: 8),
                      _CompletionToastV1(summary: completionSummary!),
                    ],
                    if (rapidMode) ...[
                      SizedBox(key: feedbackTreatmentKey, height: 0),
                      const SizedBox(height: 8),
                      Text(
                        'Next spot...',
                        key: const Key(
                          'act0_shell_feedback_auto_advance_label',
                        ),
                        textAlign: TextAlign.center,
                        style: Act0ShellTokensV1.label.copyWith(
                          color: tone,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ] else ...[
                      SizedBox(key: feedbackTreatmentKey, height: 0),
                      if (pinsAllocatedFeedbackCta)
                        const SizedBox.shrink()
                      else if (pinsF1FeedbackCta)
                        SizedBox(height: 48, child: buildContinueAction())
                      else if (usesCohesiveShortOutcome) ...[
                        const SizedBox(height: 16),
                        buildContinueAction(),
                      ] else if (usesSharedAccessibilitySurface &&
                          reservesFullCtaGeometry) ...[
                        SizedBox(height: 48, child: buildContinueAction()),
                      ] else if (usesSharedAccessibilitySurface)
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: Act0ShellTokensV1.gapSm,
                              ),
                              child: buildContinueAction(),
                            ),
                          ),
                        )
                      else ...[
                        SizedBox(height: isCompactRefinedFeedback ? 4 : 10),
                        buildContinueAction(),
                      ],
                    ],
                  ],
                );
                if (!pinsAllocatedFeedbackCta) return feedbackBody;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        key: const Key(
                          'act0_shell_feedback_allocated_body_scroll',
                        ),
                        primary: false,
                        physics: const ClampingScrollPhysics(),
                        child: feedbackBody,
                      ),
                    ),
                    SizedBox(height: 48, child: buildContinueAction()),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

String _compactFeedbackActionLabelV1(String label) => switch (label.trim()) {
  'The visible king leaves fewer king-containing combinations.' =>
    'Fewer king-containing hands remain.',
  'Fewer seven-containing hands remain, but trips are still possible.' =>
    'Fewer seven hands remain; trips are still possible.',
  'Fewer queen-containing combinations remain; no exact hand is proved.' =>
    'Fewer queen hands remain; exact hand unknown.',
  _ => label,
};

class _FeedbackVerdictDividerV1 extends StatelessWidget {
  const _FeedbackVerdictDividerV1();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: Act0ShellTokensV1.border.withValues(alpha: 0.72),
    );
  }
}

class _FeedbackActionContrastBlockV1 extends StatelessWidget {
  const _FeedbackActionContrastBlockV1({
    required this.actionLine,
    required this.selectedLine,
    required this.tone,
    required this.compact,
    required this.refined,
    required this.showEyebrow,
  });

  final String actionLine;
  final String selectedLine;
  final Color tone;
  final bool compact;
  final bool refined;
  final bool showEyebrow;

  @override
  Widget build(BuildContext context) {
    final separator = actionLine.indexOf(':');
    final eyebrow = separator < 0
        ? ''
        : actionLine.substring(0, separator).trim();
    final heroAction = separator < 0
        ? actionLine
        : actionLine.substring(separator + 1).trim();
    return KeyedSubtree(
      key: const Key('act0_shell_feedback_action_contrast_block'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showEyebrow && eyebrow.isNotEmpty) ...[
            Text(
              key: const Key('act0_shell_feedback_action_eyebrow'),
              eyebrow,
              style: Act0ShellTokensV1.label.copyWith(
                color: tone,
                fontSize: compact ? 10.0 : 10.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 2),
          ],
          Text(
            heroAction,
            key: const Key('act0_shell_feedback_hero_action'),
            maxLines: 2,
            overflow: TextOverflow.fade,
            style: Act0ShellTokensV1.body.copyWith(
              color: Act0ShellTokensV1.text,
              fontSize: compact ? 20.0 : (refined ? 22.0 : 23.0),
              height: 1.0,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (selectedLine.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              selectedLine,
              key: const Key('act0_shell_feedback_selected_label'),
              maxLines: 1,
              overflow: TextOverflow.fade,
              style: Act0ShellTokensV1.muted.copyWith(
                color: Act0ShellTokensV1.textMuted,
                fontSize: refined ? 11.5 : 12.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FeedbackStateRailV1 extends StatelessWidget {
  const _FeedbackStateRailV1({required this.tone, required this.compact});

  final Color tone;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('act0_shell_wave2_feedback_state_rail'),
      height: compact ? 3 : 4,
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
      ),
    );
  }
}

class _FeedbackVisibleRepairReasonBlockV1 extends StatelessWidget {
  const _FeedbackVisibleRepairReasonBlockV1({
    required this.lines,
    required this.compact,
  });

  final List<String> lines;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (lines.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      key: const Key('act0_shell_visible_repair_reason'),
      padding: EdgeInsets.all(compact ? 8 : 10),
      decoration: BoxDecoration(
        color: Act0ShellTokensV1.gold.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusMd),
        border: Border.all(
          color: Act0ShellTokensV1.gold.withValues(alpha: 0.24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Repair focus',
            style: Act0ShellTokensV1.label.copyWith(
              color: Act0ShellTokensV1.gold,
              fontSize: compact ? 10.5 : 11.0,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: compact ? 3 : 5),
          Text(
            _compactRepairFocusCopyV1(lines),
            style: Act0ShellTokensV1.label.copyWith(
              color: Act0ShellTokensV1.textMuted,
              fontSize: compact ? 10.2 : 11.0,
              fontWeight: FontWeight.w700,
              height: 1.12,
            ),
          ),
        ],
      ),
    );
  }
}

String _compactRepairFocusCopyV1(List<String> lines) {
  final explanation = lines.length > 1
      ? lines[1].replaceFirst(
          RegExp(r'^You missed [^.]+\.\s*', caseSensitive: false),
          '',
        )
      : '';
  return <String>[
    explanation.trim(),
    if (lines.length > 2) lines[2].trim(),
  ].where((line) => line.isNotEmpty).join(' ');
}

bool _shouldPreserveFullCompactFeedbackReasonV1(String reason) {
  final normalized = reason.trim();
  if (normalized.length < 96 || normalized.length > 180) {
    return false;
  }
  final sentenceCount = RegExp(r'[.!?](?:\s|$)').allMatches(normalized).length;
  return sentenceCount >= 2;
}

List<String> _visibleRepairReasonLinesV1({
  required Act0FeedbackQualityV1 quality,
  required Act0FeedbackSignalProofV1? signalProof,
  required String repairReasonLine,
  required String repairReceiptLine,
}) {
  final reasonLine = repairReasonLine.trim();
  final receiptLine = repairReceiptLine.trim();
  if ((reasonLine.isEmpty && receiptLine.isEmpty) ||
      signalProof == null ||
      quality.passes) {
    return const <String>[];
  }
  final clue = _visibleRepairCluePhraseV1(signalProof.label);
  if (clue.isEmpty) {
    return const <String>[];
  }
  final focusLine = _visibleRepairFocusLineV1(signalProof.signalId);
  final lines = <String>[
    'You missed the $clue clue.',
    reasonLine.isEmpty
        ? 'This next hand starts with the same table signal.'
        : reasonLine,
    focusLine,
  ];
  if (lines.any(_containsForbiddenVisibleRepairCopyTokenV1)) {
    return const <String>[];
  }
  return List<String>.unmodifiable(lines);
}

String _visibleRepairCluePhraseV1(String label) {
  final normalized = label.trim().toLowerCase();
  return switch (normalized) {
    'no bet yet' => 'no-bet-yet',
    _ => normalized,
  };
}

String _visibleRepairFocusLineV1(String signalId) {
  final normalized = signalId.trim().toLowerCase();
  return switch (normalized) {
    'no_bet_yet' => 'Before choosing, ask whether a bet faces you.',
    _ => 'Before choosing, name the table clue first.',
  };
}

bool _containsForbiddenVisibleRepairCopyTokenV1(String line) {
  final tokens = line
      .toLowerCase()
      .split(RegExp(r'[^a-z0-9-]+'))
      .where((part) => part.isNotEmpty)
      .toSet();
  const forbidden = <String>[
    'ai',
    'adaptive',
    'gto',
    'solver',
    'optimal',
    'guarantee',
    'win-rate',
    'premium',
    'paywall',
    'trial',
  ];
  return forbidden.any(tokens.contains);
}

class _FeedbackProofKeyWrapperV1 extends StatelessWidget {
  const _FeedbackProofKeyWrapperV1({
    required this.child,
    required this.proofKey,
  });

  final Widget child;
  final Key? proofKey;

  @override
  Widget build(BuildContext context) {
    final key = proofKey;
    if (key == null) {
      return child;
    }
    final motionKey = key == const Key('act0_shell_repair_outcome_proof')
        ? const Key('act0_shell_repair_outcome_motion_reveal')
        : const Key('act0_shell_feedback_proof_motion_reveal');
    return KeyedSubtree(
      key: key,
      child: _ProofMotionRevealV1(key: motionKey, child: child),
    );
  }
}

class _RepairSystemProofBlockV1 extends StatelessWidget {
  const _RepairSystemProofBlockV1({
    required this.child,
    required this.cardKey,
    required this.tone,
    this.showLabel = true,
  });

  final Widget child;
  final Key cardKey;
  final Color tone;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: const Key('act0_shell_repair_system_block'),
      child: Container(
        key: cardKey,
        padding: const EdgeInsets.all(Act0ShellTokensV1.gapSm),
        decoration: BoxDecoration(
          color: tone.withValues(alpha: 0.075),
          borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusCard),
          border: Border.all(color: tone.withValues(alpha: 0.18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showLabel) ...[
              Text(
                'Result',
                key: const Key('act0_shell_repair_system_label'),
                style: Act0ShellTokensV1.label.copyWith(
                  color: tone,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.25,
                ),
              ),
              const SizedBox(height: 5),
            ],
            child,
          ],
        ),
      ),
    );
  }
}

class _ProofMotionRevealV1 extends StatefulWidget {
  const _ProofMotionRevealV1({super.key, required this.child});

  final Widget child;

  @override
  State<_ProofMotionRevealV1> createState() => _ProofMotionRevealV1State();
}

class _ProofMotionRevealV1State extends State<_ProofMotionRevealV1> {
  var _settled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _settled = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final disableMotion = MediaQuery.of(context).disableAnimations;
    if (disableMotion) {
      return widget.child;
    }
    return AnimatedScale(
      scale: _settled ? 1 : 0.992,
      duration: Act0MotionTokensV1.standard,
      curve: Act0MotionTokensV1.enter,
      child: AnimatedSlide(
        offset: _settled ? Offset.zero : const Offset(0, 0.035),
        duration: Act0MotionTokensV1.standard,
        curve: Act0MotionTokensV1.enter,
        child: AnimatedOpacity(
          opacity: _settled ? 1 : 0.92,
          duration: Act0MotionTokensV1.micro,
          curve: Act0MotionTokensV1.enter,
          child: widget.child,
        ),
      ),
    );
  }
}

class _FeedbackSessionSummaryCeremonyBlockV1 extends StatelessWidget {
  const _FeedbackSessionSummaryCeremonyBlockV1({required this.lines});

  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: const Key('act0_shell_session_summary_ceremony_block'),
      child: KeyedSubtree(
        key: const Key('act0_shell_session_repair_summary'),
        child: KeyedSubtree(
          key: const Key('act0_shell_session_repair_closure_strip'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Session result',
                key: const Key('act0_shell_session_summary_ceremony_label'),
                style: Act0ShellTokensV1.label.copyWith(
                  color: Act0ShellTokensV1.gold,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              for (var index = 0; index < lines.length; index++) ...[
                if (index > 0) const SizedBox(height: 3),
                Text(
                  lines[index],
                  style:
                      (index == 0
                              ? Act0ShellTokensV1.body
                              : Act0ShellTokensV1.label)
                          .copyWith(
                            color: index == 0
                                ? Act0ShellTokensV1.gold
                                : Act0ShellTokensV1.textMuted,
                            fontSize: index == 0 ? 15.0 : 10.5,
                            height: index == 0 ? 1.1 : null,
                            fontWeight: index == 0
                                ? FontWeight.w900
                                : FontWeight.w700,
                          ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedbackSignalProofRowV1 extends StatelessWidget {
  const _FeedbackSignalProofRowV1({
    required this.proofLine,
    required this.tone,
    this.compact = false,
  });

  final String proofLine;
  final Color tone;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final line = _humanizedFeedbackProofLineV1(proofLine);
    if (line.isEmpty) {
      return const SizedBox.shrink();
    }
    return KeyedSubtree(
      key: const Key('act0_shell_feedback_signal_proof'),
      child: KeyedSubtree(
        key: const Key('act0_shell_wave1_feedback_signal_bridge'),
        child: KeyedSubtree(
          key: const Key('act0_shell_wave1b_feedback_evidence_bridge'),
          child: Container(
            key: const Key('act0_shell_wave2_feedback_evidence_bridge'),
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 6 : 7,
              vertical: compact ? 3.5 : 4.5,
            ),
            decoration: BoxDecoration(
              color: tone.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
              border: Border.all(color: tone.withValues(alpha: 0.16)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.visibility_rounded,
                  color: tone,
                  size: compact ? 12 : 13,
                ),
                const SizedBox(width: 6),
                Text(
                  'Clue from table',
                  style: Act0ShellTokensV1.label.copyWith(
                    color: tone,
                    fontSize: compact ? 8.0 : 8.6,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    line,
                    key: const Key('act0_shell_feedback_signal_proof_label'),
                    maxLines: 2,
                    overflow: TextOverflow.visible,
                    softWrap: true,
                    style: Act0ShellTokensV1.label.copyWith(
                      color: Act0ShellTokensV1.textMuted,
                      fontSize: compact ? 10.5 : 11.0,
                      fontWeight: FontWeight.w800,
                      height: 1.05,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _humanizedFeedbackProofLineV1(String proofLine) {
  final line = proofLine.trim();
  if (line.isEmpty) {
    return '';
  }
  final signalPrefix = RegExp(r'^signal:\s*', caseSensitive: false);
  final cleaned = line.replaceFirst(signalPrefix, '').trim();
  if (_normalizeFeedbackLabelV1(cleaned) == 'no bet yet') {
    return 'Nobody had bet yet - that was the clue.';
  }
  return cleaned;
}

String _fixedFeedbackLabelV1(BuildContext context, {bool lessonRetry = false}) {
  if (act0AcademyLanguageV1(context) == 'ru') return 'Исправлено';
  return lessonRetry ? Act0SkinFeedbackGradeV1.repaired.label : 'Fixed';
}

String _feedbackPrimaryResultLabelV1(
  BuildContext context, {
  required Act0FeedbackQualityV1 quality,
  required String? repairReceiptLine,
}) {
  final receipt = repairReceiptLine?.trim().toLowerCase() ?? '';
  if (receipt.startsWith('repair fixed:')) {
    return 'Repair landed';
  }
  if (receipt.startsWith('replay fixed:')) {
    return 'Repair landed';
  }
  if (receipt.startsWith('fix landed:')) {
    return 'Repair landed';
  }
  if (receipt.startsWith('still missed:') ||
      receipt.startsWith('repair missed:') ||
      receipt.startsWith('replay missed:')) {
    return 'Still fragile';
  }
  return switch (quality) {
    Act0FeedbackQualityV1.correct ||
    Act0FeedbackQualityV1.coCorrect => 'Correct read',
    Act0FeedbackQualityV1.acceptable =>
      act0AcademyLanguageV1(context) == 'ru' ? 'Тоже можно' : 'Also playable',
    Act0FeedbackQualityV1.suboptimal => 'Better read',
    Act0FeedbackQualityV1.wrong => 'Missed clue',
  };
}

List<String> _dedupedFeedbackContextLabelsV1(
  List<String> labels, {
  required String preferredLine,
  required String selectedLine,
  required String statusLine,
  required String signalLabel,
  required String proofLine,
}) {
  final seen = <String>{};
  final normalizedSelected = _normalizeFeedbackLabelV1(selectedLine);
  final blocked = <String>{
    _normalizeFeedbackLabelV1(preferredLine),
    _normalizeFeedbackLabelV1(statusLine),
    _normalizeFeedbackLabelV1(signalLabel),
    _normalizeFeedbackLabelV1(_humanizedFeedbackProofLineV1(proofLine)),
    _normalizeFeedbackLabelV1(
      proofLine.replaceFirst(RegExp(r'^signal:\s*', caseSensitive: false), ''),
    ),
  }..remove('');
  final result = <String>[];
  for (final label in labels) {
    final normalized = _normalizeFeedbackLabelV1(label);
    if (normalized.isEmpty ||
        blocked.contains(normalized) ||
        (normalizedSelected.isNotEmpty &&
            (normalized == normalizedSelected ||
                normalized.startsWith('$normalizedSelected '))) ||
        !seen.add(normalized)) {
      continue;
    }
    result.add(label);
  }
  return result;
}

String _normalizeFeedbackLabelV1(String label) {
  return label.trim().toLowerCase();
}

String _feedbackSelectedLineV1(BuildContext context, String selectedLabel) {
  final prefix = act0RuntimeLocalizedGeneralLabelV1(context, 'You picked');
  return '$prefix ${_premiumSafeFeedbackOptionLabelV1(act0RuntimeLocalizedOptionLabelV1(context, selectedLabel))}';
}

String _premiumSafeFeedbackOptionLabelV1(String label) {
  final trimmed = label.trim();
  return switch (trimmed) {
    'Bottom seat' => 'Hero on the Button',
    'Hero is BTN, blinds are posted, and no board is out yet' =>
      'Hero on the Button preflop',
    _ => trimmed,
  };
}

const Set<String> _genericFeedbackTitleFloorInputsV1 = <String>{
  'Almost there.',
  'Clean execution.',
  'Close call.',
  'Excellent spot.',
  'Getting warmer.',
  'Good.',
  'Good direction.',
  'Good instinct.',
  'Nearly there.',
  'Nice read.',
  'On the right track.',
  'One more step.',
  'Playable instinct.',
  'Playable move.',
  'Sharp read.',
  'Solid understanding.',
  'Spot on.',
  'Strong choice.',
  'Very close.',
  'Well done.',
};

String _feedbackTitleFloorV1(
  BuildContext context, {
  required String title,
  required Act0FeedbackQualityV1 quality,
  required List<String> contextLabels,
}) {
  final trimmedTitle = title.trim();
  final premiumSafeTitle = _premiumSafeFeedbackTitleV1(trimmedTitle);
  if (premiumSafeTitle != null) {
    return premiumSafeTitle;
  }
  if (trimmedTitle.isEmpty ||
      !_genericFeedbackTitleFloorInputsV1.contains(trimmedTitle)) {
    return trimmedTitle;
  }

  final localeIsRu = Localizations.localeOf(
    context,
  ).languageCode.toLowerCase().startsWith('ru');
  final focusLabel = contextLabels.isEmpty
      ? ''
      : act0RuntimeLocalizedContextLabelV1(context, contextLabels.first).trim();

  if (focusLabel.isNotEmpty) {
    if (quality.passes) {
      return focusLabel;
    }
    return localeIsRu
        ? '$focusLabel \u0441\u043D\u0430\u0447\u0430\u043B\u0430'
        : '$focusLabel first';
  }

  if (quality.passes) {
    return localeIsRu
        ? '\u0412\u0435\u0440\u043D\u043E\u0435 \u0447\u0442\u0435\u043D\u0438\u0435'
        : 'Correct read';
  }
  return localeIsRu
      ? '\u0421\u043D\u0430\u0447\u0430\u043B\u0430 \u043F\u0435\u0440\u0435\u0447\u0438\u0442\u0430\u0439 \u0441\u043F\u043E\u0442'
      : 'Read the spot first';
}

String? _premiumSafeFeedbackTitleV1(String title) {
  return switch (title) {
    'Specific fix transfers.' => 'Good. Use this read again.',
    'One clean reread.' => 'One quick repair.',
    _ => null,
  };
}

String _feedbackReasonFloorV1(
  BuildContext context, {
  required String reason,
  required Act0FeedbackQualityV1 quality,
  required String selectedLabel,
  required String preferredLabel,
  required String betterLabel,
  required List<String> contextLabels,
}) {
  final resolved = act0RuntimeLocalizedGeneralLabelV1(context, reason).trim();
  if (resolved.isNotEmpty) {
    return resolved;
  }

  final localeIsRu = Localizations.localeOf(
    context,
  ).languageCode.toLowerCase().startsWith('ru');
  final focusLabel = contextLabels.isEmpty
      ? ''
      : act0RuntimeLocalizedContextLabelV1(context, contextLabels.first).trim();
  final betterLine = act0RuntimeLocalizedOptionLabelV1(
    context,
    quality == Act0FeedbackQualityV1.wrong ? betterLabel : preferredLabel,
  ).trim();
  final pickedLine = act0RuntimeLocalizedOptionLabelV1(
    context,
    selectedLabel,
  ).trim();
  final safeBetterLine = _premiumSafeFeedbackOptionLabelV1(betterLine);
  final safePickedLine = _premiumSafeFeedbackOptionLabelV1(pickedLine);

  if (quality.passes) {
    if (focusLabel.isNotEmpty) {
      return localeIsRu
          ? '$focusLabel \u043F\u0440\u043E\u0447\u0438\u0442\u0430\u043D \u0432\u0435\u0440\u043D\u043E. \u0421\u043E\u0445\u0440\u0430\u043D\u0438 \u044D\u0442\u043E \u0438 \u043F\u0440\u043E\u0434\u043E\u043B\u0436\u0430\u0439.'
          : '$focusLabel read correctly. Keep it and continue.';
    }
    return localeIsRu
        ? '\u0427\u0442\u0435\u043D\u0438\u0435 \u0432\u0435\u0440\u043D\u043E\u0435. \u0421\u043E\u0445\u0440\u0430\u043D\u0438 \u0435\u0433\u043E \u0438 \u043F\u0440\u043E\u0434\u043E\u043B\u0436\u0430\u0439.'
        : 'Read is correct. Keep it and continue.';
  }

  if (focusLabel.isNotEmpty && safeBetterLine.isNotEmpty) {
    return localeIsRu
        ? '$focusLabel \u0441\u043D\u0430\u0447\u0430\u043B\u0430. \u0421\u0440\u0430\u0432\u043D\u0438 \u044D\u0442\u043E \u0441 $safeBetterLine \u043F\u0435\u0440\u0435\u0434 \u043F\u0440\u043E\u0434\u043E\u043B\u0436\u0435\u043D\u0438\u0435\u043C.'
        : '$focusLabel first. Compare it with $safeBetterLine before you continue.';
  }
  if (safePickedLine.isNotEmpty && safeBetterLine.isNotEmpty) {
    return localeIsRu
        ? '\u0421\u0440\u0430\u0432\u043D\u0438 $safePickedLine \u0441 $safeBetterLine \u043F\u0435\u0440\u0435\u0434 \u043F\u0440\u043E\u0434\u043E\u043B\u0436\u0435\u043D\u0438\u0435\u043C.'
        : 'Compare $safePickedLine with $safeBetterLine before you continue.';
  }
  return localeIsRu
      ? '\u0421\u0434\u0435\u043B\u0430\u0439 \u043F\u0430\u0443\u0437\u0443, \u043F\u0440\u043E\u0447\u0438\u0442\u0430\u0439 \u0441\u043F\u043E\u0442 \u0435\u0449\u0451 \u0440\u0430\u0437 \u0438 \u0437\u0430\u0442\u0435\u043C \u043F\u0440\u043E\u0434\u043E\u043B\u0436\u0430\u0439.'
      : 'Pause, read the spot again, then continue.';
}

/// B2 source-identical Summary/Home next action, carried from the root owner.
/// This value cannot grade, schedule, or manufacture a new recommendation.
class Act0SummaryNextHandoffV1 {
  const Act0SummaryNextHandoffV1({
    required this.sourceTaskId,
    required this.targetWorldId,
    required this.targetLessonId,
    required this.targetTaskId,
    required this.reasonCode,
    required this.selectionSource,
    required this.copyLine,
  });
  final String sourceTaskId;
  final String targetWorldId;
  final String targetLessonId;
  final String targetTaskId;
  final String reasonCode;
  final String selectionSource;
  final String copyLine;

  bool get isActionableRepair =>
      sourceTaskId.isNotEmpty &&
      targetWorldId.isNotEmpty &&
      targetLessonId.isNotEmpty &&
      targetTaskId.isNotEmpty &&
      reasonCode.isNotEmpty &&
      (selectionSource == 'repair_intent_mapped' ||
          selectionSource == 'repair_intent_exact_replay');
  Map<String, String> toPayload() => <String, String>{
    'sourceTaskId': sourceTaskId,
    'targetWorldId': targetWorldId,
    'targetLessonId': targetLessonId,
    'targetTaskId': targetTaskId,
    'reasonCode': reasonCode,
    'selectionSource': selectionSource,
    'copyLine': copyLine,
  };
}

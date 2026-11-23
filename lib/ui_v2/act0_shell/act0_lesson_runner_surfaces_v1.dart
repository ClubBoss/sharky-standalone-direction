part of 'act0_lesson_runner_shell_v1.dart';

/// Keeps the task-owned practice table in one slot while only the lower
/// decision/feedback panel changes. No reachable state is allowed to resize or
/// translate the table.
class _TaskOwnedStablePracticePresentationV1 extends StatelessWidget {
  const _TaskOwnedStablePracticePresentationV1({
    required this.runner,
    required this.table,
    required this.isReview,
    required this.isRepaired,
    required this.question,
    required this.onBack,
    required this.onChooseOption,
    required this.onContinueReview,
    this.forwardCtaLabel,
    this.recallLabel,
    this.onRecall,
    this.hintPeek,
    this.actionRecommendation,
    this.actionPayoff,
    this.tableHeight = 460,
    this.lowerPanelHeight = 282,
    this.compactFeedback = false,
  });

  final Act0RunnerStateV1 runner;
  final Act0TableStateV1 table;
  final bool isReview;
  final bool isRepaired;
  final String question;
  final VoidCallback onBack;
  final ValueChanged<Act0RunnerOptionV1> onChooseOption;
  final VoidCallback onContinueReview;
  final String? forwardCtaLabel;
  final String? recallLabel;
  final VoidCallback? onRecall;
  final Widget? hintPeek;
  final Act0ActionRecommendationV1? actionRecommendation;
  final Act0ActionSessionPayoffV1? actionPayoff;
  final double tableHeight;
  final double lowerPanelHeight;
  final bool compactFeedback;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final resolvedTableHeight = math.max(
            0.0,
            math.min(
              tableHeight,
              constraints.maxHeight - lowerPanelHeight - 20,
            ),
          );
          final tableWidth = math.min(
            constraints.maxWidth - 24,
            resolvedTableHeight * 0.576,
          );
          return Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
            child: Column(
              children: [
                SizedBox(
                  key: const Key('act0_task_owned_practice_table_bounds'),
                  height: resolvedTableHeight,
                  width: tableWidth,
                  child: Act0TableSceneV1(
                    table: table,
                    config: Act0TablePresentationConfigV1(
                      maxTableHeight: tableHeight,
                      showFocusBadge: true,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Container(
                    key: const Key('act0_task_owned_practice_panel'),
                    width: double.infinity,
                    // Preserve a 48dp Hint touch target without pushing choices
                    // below the short-height practice dock's fixed bounds.
                    padding: EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: constraints.maxHeight < 650 ? 4 : 14,
                    ),
                    decoration: BoxDecoration(
                      color: Act0ShellTokensV1.surface2,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Act0ShellTokensV1.primary.withValues(
                          alpha: 0.28,
                        ),
                      ),
                    ),
                    child: isReview
                        ? Column(
                            key: const Key('act0_shell_feedback_card'),
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isRepaired
                                    ? _fixedFeedbackLabelV1(context)
                                    : actionPayoff?.type ==
                                          Act0ActionPayoffTypeV1
                                              .recoveredSuccess
                                    ? 'Repair proved'
                                    : actionPayoff?.type ==
                                          Act0ActionPayoffTypeV1.cleanSuccess
                                    ? 'Action read confirmed'
                                    : actionPayoff == null
                                    ? runner.reviewTitle
                                    : 'Action read needs repair',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Act0ShellTokensV1.sectionTitle,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                actionPayoff == null
                                    ? (actionRecommendation?.explanation ??
                                          runner.reviewReason)
                                    : '${actionPayoff!.proofStatement} ${actionPayoff!.meaningStatement}',
                                key: actionRecommendation == null
                                    ? null
                                    : const Key(
                                        'act0_action_recommendation_surface',
                                      ),
                                maxLines: actionPayoff == null
                                    ? (actionRecommendation == null ? 4 : 2)
                                    : 3,
                                overflow: TextOverflow.ellipsis,
                                style: Act0ShellTokensV1.body,
                              ),
                              if (compactFeedback) const SizedBox(height: 16),
                              if (!compactFeedback) const Spacer(),
                              Align(
                                alignment: Alignment.centerRight,
                                child: KeyedSubtree(
                                  key: const Key('act0_shell_continue_cta'),
                                  child: FilledButton(
                                    key: const Key(
                                      'act0_shell_feedback_continue_cta',
                                    ),
                                    onPressed: onContinueReview,
                                    child: Text(
                                      forwardCtaLabel ??
                                          actionPayoff?.primaryActionLabel ??
                                          'Continue',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : hintPeek ??
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          question,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: Act0ShellTokensV1.sectionTitle,
                                        ),
                                      ),
                                      if (onRecall != null &&
                                          recallLabel != null)
                                        _TheoryRecallCtaV1(
                                          label: recallLabel!,
                                          onPressed: onRecall!,
                                          compact: true,
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  for (final option in runner.options)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: OutlinedButton(
                                          key: Key(
                                            'act0_shell_option_${option.id}',
                                          ),
                                          onPressed: () =>
                                              onChooseOption(option),
                                          child: Text(
                                            option.label,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ),
                                  const Spacer(),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextButton(
                                      onPressed: onBack,
                                      child: const Text('Back'),
                                    ),
                                  ),
                                ],
                              ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RunnerTaskCycleViewportEnvelopeV1 {
  const _RunnerTaskCycleViewportEnvelopeV1({
    required this.familyName,
    required this.usesFixedLowerSlot,
    required this.targetLowerSlotHeight,
    required this.minLowerSlotHeight,
    required this.maxLowerSlotShare,
  });

  final String familyName;
  final bool usesFixedLowerSlot;
  final double targetLowerSlotHeight;
  final double minLowerSlotHeight;
  final double maxLowerSlotShare;

  double lowerSlotHeightFor(double availableHeight) {
    if (!usesFixedLowerSlot) {
      return 0;
    }
    final maxLowerSlotHeight = math.max(
      minLowerSlotHeight,
      availableHeight * maxLowerSlotShare,
    );
    return targetLowerSlotHeight.clamp(minLowerSlotHeight, maxLowerSlotHeight);
  }
}

_RunnerLowerStageProfileV1 _resolveRunnerLowerStageProfileV1({
  required bool isTeaching,
  required bool isTheory,
  required bool isReview,
  required bool compactRepairFeedbackDock,
  required _RunnerInteractionModeV1 interactionMode,
  required bool fillsDecisionStage,
}) {
  if (isReview) {
    return compactRepairFeedbackDock
        ? _RunnerLowerStageProfileV1.expandedFeedback
        : _RunnerLowerStageProfileV1.compactFeedback;
  }
  if (interactionMode == _RunnerInteractionModeV1.tableTapDecision) {
    return _RunnerLowerStageProfileV1.tableTapDecision;
  }
  // Instruction owns the complete remaining stage so its body can balance
  // above a fixed navigation rail without changing the table allocation.
  if (isTeaching || isTheory) {
    return _RunnerLowerStageProfileV1.instruction;
  }
  if (fillsDecisionStage) {
    return _RunnerLowerStageProfileV1.decision;
  }
  return _RunnerLowerStageProfileV1.instruction;
}

_RunnerTaskCycleViewportEnvelopeV1 _resolveRunnerTaskCycleViewportEnvelopeV1(
  BuildContext context, {
  required _RunnerViewportFamilyV1 viewportFamily,
  required String pressureReason,
  required bool repairFillMode,
  required bool shortSafeAnswerList,
  required bool compactRepairFeedbackDock,
  required _RunnerInteractionModeV1 interactionMode,
  required bool forceCompactStateAllocation,
}) {
  if (forceCompactStateAllocation) {
    return _RunnerTaskCycleViewportEnvelopeV1(
      familyName: 'compact_${interactionMode.name}',
      usesFixedLowerSlot: true,
      targetLowerSlotHeight:
          interactionMode == _RunnerInteractionModeV1.feedback
          ? _runnerRepairFeedbackDockTargetLowerSlotHeightV1
          : interactionMode == _RunnerInteractionModeV1.tableTapDecision
          ? _runnerCompactSeatTapTargetLowerSlotHeightV1
          : (shortSafeAnswerList
                ? _runnerShortAnswerEnvelopeTargetLowerSlotHeightV1
                : _runnerEnvelopeWave1bTargetLowerSlotHeightV1),
      minLowerSlotHeight: interactionMode == _RunnerInteractionModeV1.feedback
          ? _runnerCompactFeedbackMinLowerSlotHeightV1
          : interactionMode == _RunnerInteractionModeV1.tableTapDecision
          ? _runnerCompactSeatTapMinLowerSlotHeightV1
          : (shortSafeAnswerList
                ? _runnerShortAnswerEnvelopeMinLowerSlotHeightV1
                : _runnerEnvelopeWave1bMinLowerSlotHeightV1),
      maxLowerSlotShare: interactionMode == _RunnerInteractionModeV1.feedback
          ? _runnerRepairFeedbackDockMaxLowerSlotShareV1
          : interactionMode == _RunnerInteractionModeV1.tableTapDecision
          ? _runnerCompactSeatTapMaxLowerSlotShareV1
          : (shortSafeAnswerList
                ? _runnerShortAnswerEnvelopeMaxLowerSlotShareV1
                : _runnerEnvelopeWave1bMaxLowerSlotShareV1),
    );
  }
  final usesFixedAnswerListEnvelope =
      pressureReason != _compactAnswerListNoPressureReasonV1 &&
      _viewportFamilyUsesAnswerListCompositionV1(viewportFamily);
  if (usesFixedAnswerListEnvelope) {
    final media = MediaQuery.sizeOf(context);
    final safePadding = MediaQuery.viewPaddingOf(context).vertical > 0
        ? MediaQuery.viewPaddingOf(context).vertical
        : MediaQuery.paddingOf(context).vertical;
    final usableHeight = media.height - safePadding;
    final targetLowerSlotHeight = compactRepairFeedbackDock
        ? _runnerRepairFeedbackDockTargetLowerSlotHeightV1
        : (usableHeight *
                  (repairFillMode
                      ? _runnerRepairEnvelopeTargetLowerSlotShareV1
                      : _runnerEnvelopeWave1bTargetLowerSlotShareV1))
              .clamp(
                repairFillMode
                    ? _runnerRepairEnvelopeMinLowerSlotHeightV1
                    : _runnerEnvelopeWave1bMinLowerSlotHeightV1,
                repairFillMode
                    ? _runnerRepairEnvelopeTargetLowerSlotHeightV1
                    : _runnerEnvelopeWave1bTargetLowerSlotHeightV1,
              );
    return _RunnerTaskCycleViewportEnvelopeV1(
      familyName: repairFillMode ? 'repairFill' : viewportFamily.name,
      usesFixedLowerSlot: true,
      targetLowerSlotHeight:
          !compactRepairFeedbackDock && !repairFillMode && shortSafeAnswerList
          ? _runnerShortAnswerEnvelopeTargetLowerSlotHeightV1
          : targetLowerSlotHeight,
      minLowerSlotHeight: compactRepairFeedbackDock
          ? _runnerRepairFeedbackDockMinLowerSlotHeightV1
          : repairFillMode
          ? _runnerRepairEnvelopeMinLowerSlotHeightV1
          : (shortSafeAnswerList
                ? _runnerShortAnswerEnvelopeMinLowerSlotHeightV1
                : _runnerEnvelopeWave1bMinLowerSlotHeightV1),
      maxLowerSlotShare: compactRepairFeedbackDock
          ? _runnerRepairFeedbackDockMaxLowerSlotShareV1
          : repairFillMode
          ? _runnerRepairEnvelopeMaxLowerSlotShareV1
          : (shortSafeAnswerList
                ? _runnerShortAnswerEnvelopeMaxLowerSlotShareV1
                : _runnerEnvelopeWave1bMaxLowerSlotShareV1),
    );
  }
  if (repairFillMode) {
    final media = MediaQuery.sizeOf(context);
    final safePadding = MediaQuery.viewPaddingOf(context).vertical > 0
        ? MediaQuery.viewPaddingOf(context).vertical
        : MediaQuery.paddingOf(context).vertical;
    final usableHeight = media.height - safePadding;
    final targetLowerSlotHeight =
        (usableHeight *
                (compactRepairFeedbackDock
                    ? _runnerRepairFeedbackDockTargetLowerSlotShareV1
                    : _runnerRepairEnvelopeTargetLowerSlotShareV1))
            .clamp(
              _runnerRepairEnvelopeMinLowerSlotHeightV1,
              _runnerRepairEnvelopeTargetLowerSlotHeightV1,
            );
    return _RunnerTaskCycleViewportEnvelopeV1(
      familyName: 'repairFill',
      usesFixedLowerSlot: true,
      targetLowerSlotHeight: compactRepairFeedbackDock
          ? _runnerRepairFeedbackDockTargetLowerSlotHeightV1
          : targetLowerSlotHeight,
      minLowerSlotHeight: compactRepairFeedbackDock
          ? _runnerRepairFeedbackDockMinLowerSlotHeightV1
          : _runnerRepairEnvelopeMinLowerSlotHeightV1,
      maxLowerSlotShare: compactRepairFeedbackDock
          ? _runnerRepairFeedbackDockMaxLowerSlotShareV1
          : _runnerRepairEnvelopeMaxLowerSlotShareV1,
    );
  }
  return _RunnerTaskCycleViewportEnvelopeV1(
    familyName: viewportFamily.name,
    usesFixedLowerSlot: false,
    targetLowerSlotHeight: 0,
    minLowerSlotHeight: 0,
    maxLowerSlotShare: 0,
  );
}

double _runnerUpperStageChromeHeightV1({
  required bool showTopInstructionCard,
  required bool isRefinedDev2,
  required double compactTableStageTopInset,
}) {
  var height = Act0ShellTokensV1.gapSm;
  height += _runnerProgressRowHeightV1;
  height += showTopInstructionCard
      ? Act0ShellTokensV1.gapSm
      : Act0ShellTokensV1.gapXs;
  if (!isRefinedDev2) {
    height += Act0ShellTokensV1.gapSm;
    height += 24;
  }
  if (showTopInstructionCard) {
    height += Act0ShellTokensV1.refinedInstructionSlotHeight;
    height += isRefinedDev2 ? Act0ShellTokensV1.gapSm : Act0ShellTokensV1.gapMd;
  }
  height += compactTableStageTopInset;
  return height;
}

String? _learningRailProgressLabel(Act0RunnerStateV1 runner) {
  final total = runner.teachingSteps.length;
  if (total < 4) {
    return null;
  }
  final current = runner.teachingStepIndex.clamp(0, total - 1) + 1;
  return '$current/$total';
}

_RunnerInteractionModeV1 _resolveRunnerInteractionModeV1({
  required bool isDrill,
  required bool isReview,
  required bool hasSeatTargets,
}) {
  if (isReview) {
    return _RunnerInteractionModeV1.feedback;
  }
  if (isDrill && hasSeatTargets) {
    return _RunnerInteractionModeV1.tableTapDecision;
  }
  return _RunnerInteractionModeV1.answerListDecision;
}

Act0RunnerFramingProfileV1 _resolveRunnerFramingProfileV1({
  required Act0RunnerFramingProfileV1 requestedProfile,
  required _RunnerInteractionModeV1 interactionMode,
  required Act0RunnerStateV1 runner,
  required Act0TableStateV1 table,
  required Act0TaskFamilyV1? taskFamily,
  required bool hasSeatTargets,
}) {
  if (interactionMode == _RunnerInteractionModeV1.tableTapDecision ||
      hasSeatTargets) {
    return Act0RunnerFramingProfileV1.seatFocus;
  }
  if (requestedProfile != Act0RunnerFramingProfileV1.neutral) {
    return requestedProfile;
  }

  final hasHeroCards =
      table.heroCards.isNotEmpty ||
      table.seats.any((seat) => seat.holeCards.isNotEmpty && seat.isHero);
  final hasBoardCards = table.boardCards.isNotEmpty;
  final hasPotOrPrice =
      table.potLabel.trim().isNotEmpty ||
      table.toCallLabel.trim().isNotEmpty ||
      table.centerLabel.trim().isNotEmpty;

  if (taskFamily == Act0TaskFamilyV1.decision ||
      taskFamily == Act0TaskFamilyV1.sizing ||
      taskFamily == Act0TaskFamilyV1.repair) {
    return Act0RunnerFramingProfileV1.heroAction;
  }
  if (hasHeroCards && hasBoardCards && hasPotOrPrice) {
    return Act0RunnerFramingProfileV1.boardHeroPot;
  }
  if (hasBoardCards) {
    return Act0RunnerFramingProfileV1.boardOnly;
  }
  return Act0RunnerFramingProfileV1.neutral;
}

_RunnerViewportFamilyV1 _resolveRunnerViewportFamilyV1({
  required Act0RunnerFramingProfileV1 framingProfile,
  required bool hasSeatTargets,
}) {
  if (hasSeatTargets ||
      framingProfile == Act0RunnerFramingProfileV1.seatFocus) {
    return _RunnerViewportFamilyV1.tableTapSeatFocus;
  }
  return switch (framingProfile) {
    Act0RunnerFramingProfileV1.boardHeroPot ||
    Act0RunnerFramingProfileV1.boardOnly =>
      _RunnerViewportFamilyV1.answerListBoardHeroPot,
    Act0RunnerFramingProfileV1.heroAction =>
      _RunnerViewportFamilyV1.answerListHeroAction,
    Act0RunnerFramingProfileV1.seatFocus =>
      _RunnerViewportFamilyV1.tableTapSeatFocus,
    Act0RunnerFramingProfileV1.neutral => _RunnerViewportFamilyV1.neutral,
  };
}

class _RunnerInstructionSlotV1 extends StatelessWidget {
  const _RunnerInstructionSlotV1({
    required this.child,
    required this.showContent,
  });

  final Widget child;
  final bool showContent;

  @override
  Widget build(BuildContext context) {
    final content = showContent
        ? child
        : const SizedBox(key: Key('act0_shell_runner_prompt_spacer'));

    return showContent ? content : const SizedBox.shrink();
  }
}

class _RunnerActionDockV1 extends StatelessWidget {
  const _RunnerActionDockV1({
    required this.child,
    required this.pageX,
    this.taskRailLabel,
    this.sizingPresets,
    this.selectedPresetId,
    this.onSelectPreset,
    this.integratedLowerSurface = false,
    this.compactAnswerListDecision = false,
    this.fillCompactPromptToDock = false,
    this.scrollContentInEnvelope = false,
    this.protectFixedSlotBottom = false,
    this.centerBoundedLowerSurface = false,
    this.fillLowerStage = false,
    this.cycleStableEnvelope = false,
    this.sceneAttachedShelf = false,
    this.lowerStageProfile = _RunnerLowerStageProfileV1.instruction,
    this.accessibilityFeedbackSurface = false,
  });

  final Widget child;
  final double pageX;
  final String? taskRailLabel;
  final List<Act0SizingPresetV1>? sizingPresets;
  final String? selectedPresetId;
  final ValueChanged<Act0SizingPresetV1>? onSelectPreset;
  final bool integratedLowerSurface;
  final bool compactAnswerListDecision;
  final bool fillCompactPromptToDock;
  final bool scrollContentInEnvelope;
  final bool protectFixedSlotBottom;
  final bool centerBoundedLowerSurface;
  final bool fillLowerStage;
  final bool cycleStableEnvelope;

  /// B7: the dock is a scene-attached control shelf, so it takes its own
  /// content height instead of filling a slot the scene had to pay for.
  final bool sceneAttachedShelf;
  final _RunnerLowerStageProfileV1 lowerStageProfile;
  final bool accessibilityFeedbackSurface;

  @override
  Widget build(BuildContext context) {
    final hasSizingPresets = sizingPresets != null && sizingPresets!.isNotEmpty;
    final safeBottom = MediaQuery.viewPaddingOf(context).bottom;
    final usesAccessibilitySharedSurface =
        lowerStageProfile == _RunnerLowerStageProfileV1.accessibility;
    final effectiveTaskRailLabel = compactAnswerListDecision
        ? null
        : taskRailLabel;
    final fillsLowerStage =
        !sceneAttachedShelf &&
        (cycleStableEnvelope ||
            (fillLowerStage &&
                (lowerStageProfile == _RunnerLowerStageProfileV1.instruction ||
                    lowerStageProfile == _RunnerLowerStageProfileV1.decision ||
                    lowerStageProfile ==
                        _RunnerLowerStageProfileV1.tableTapDecision ||
                    lowerStageProfile ==
                        _RunnerLowerStageProfileV1.accessibility)));
    final double stageBottomPadding =
        lowerStageProfile == _RunnerLowerStageProfileV1.compactFeedback
        // SafeArea has already consumed the device inset. Keep only the
        // intentional stage-to-safe-area clearance here.
        ? 12.0
        : compactAnswerListDecision
        ? (protectFixedSlotBottom && safeBottom > 0 ? safeBottom + 12 : 0)
        : (scrollContentInEnvelope && safeBottom > 0
              ? safeBottom + 12
              : Act0ShellTokensV1.gapMd);
    // A scroll viewport gives its child unbounded vertical constraints, so it
    // must contain intrinsic content rather than an Expanded fill contract.
    final fillDockBody =
        (fillCompactPromptToDock || fillsLowerStage) &&
        !scrollContentInEnvelope &&
        (lowerStageProfile != _RunnerLowerStageProfileV1.accessibility ||
            accessibilityFeedbackSurface);
    final dockBody = _CompactAnswerListDecisionScopeV1(
      compact: compactAnswerListDecision,
      child: Column(
        mainAxisSize: fillDockBody ? MainAxisSize.max : MainAxisSize.min,
        children: [
          if (effectiveTaskRailLabel != null &&
              effectiveTaskRailLabel.isNotEmpty) ...[
            _TaskRailV1(label: effectiveTaskRailLabel),
            const SizedBox(height: 6),
          ],
          if (hasSizingPresets) ...[
            _SizingPresetsLaneV1(
              presets: sizingPresets!,
              selectedPresetId: selectedPresetId,
              onSelectPreset: onSelectPreset!,
            ),
            const SizedBox(height: Act0ShellTokensV1.gapSm),
          ],
          if (fillDockBody)
            Expanded(
              child:
                  cycleStableEnvelope &&
                      (lowerStageProfile ==
                              _RunnerLowerStageProfileV1.decision ||
                          lowerStageProfile ==
                              _RunnerLowerStageProfileV1.tableTapDecision)
                  ? Align(alignment: Alignment.topCenter, child: child)
                  : child,
            )
          else
            child,
        ],
      ),
    );
    final effectiveDockBody =
        scrollContentInEnvelope && !fillCompactPromptToDock
        ? _BoundedLowerStageScrollV1(
            showActionFirst:
                lowerStageProfile ==
                _RunnerLowerStageProfileV1.expandedFeedback,
            child: dockBody,
          )
        : dockBody;
    final integratedDockBody = centerBoundedLowerSurface
        ? LayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: SizedBox(
                  height: math.min(
                    constraints.maxHeight,
                    _learningRailMaxHeightV1,
                  ),
                  child: effectiveDockBody,
                ),
              );
            },
          )
        : effectiveDockBody;
    final stageComposedDockBody = switch (lowerStageProfile) {
      _RunnerLowerStageProfileV1.compactFeedback =>
        cycleStableEnvelope && !sceneAttachedShelf
            ? SizedBox.expand(
                key: const Key('act0_shell_lower_stage_compact_feedback'),
                child: integratedDockBody,
              )
            : LayoutBuilder(
                builder: (context, constraints) => Align(
                  key: const Key('act0_shell_lower_stage_compact_feedback'),
                  alignment: Alignment.topCenter,
                  child: integratedDockBody,
                ),
              ),
      // B7: a scene-attached shelf takes its own content height, so the
      // decision slot must not demand a slot to fill.
      _RunnerLowerStageProfileV1.decision =>
        sceneAttachedShelf
            ? Align(
                key: const Key('act0_shell_lower_stage_decision'),
                alignment: Alignment.topCenter,
                child: integratedDockBody,
              )
            : SizedBox.expand(
                key: const Key('act0_shell_lower_stage_decision'),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: integratedDockBody,
                ),
              ),
      _RunnerLowerStageProfileV1.tableTapDecision =>
        fillsLowerStage
            ? SizedBox.expand(
                key: const Key('act0_shell_lower_stage_table_tap_decision'),
                child: integratedDockBody,
              )
            : Align(
                key: const Key('act0_shell_lower_stage_table_tap_decision'),
                alignment: Alignment.topCenter,
                child: integratedDockBody,
              ),
      _RunnerLowerStageProfileV1.instruction =>
        fillsLowerStage
            ? SizedBox.expand(
                key: const Key('act0_shell_lower_stage_instruction'),
                child: integratedDockBody,
              )
            : Align(
                key: const Key('act0_shell_lower_stage_instruction'),
                alignment: Alignment.topCenter,
                child: integratedDockBody,
              ),
      _RunnerLowerStageProfileV1.expandedFeedback =>
        cycleStableEnvelope && !sceneAttachedShelf
            ? SizedBox.expand(
                key: const Key('act0_shell_lower_stage_expanded_feedback'),
                child: integratedDockBody,
              )
            : LayoutBuilder(
                builder: (context, constraints) => Align(
                  key: const Key('act0_shell_lower_stage_expanded_feedback'),
                  alignment: Alignment.topCenter,
                  child: integratedDockBody,
                ),
              ),
      _RunnerLowerStageProfileV1.accessibility => LayoutBuilder(
        builder: (context, constraints) {
          // A scene-attached action shelf sizes to its content. Expanding
          // against its unbounded vertical slot throws an infinite-height
          // layout assertion and hides the first placement decision.
          if (sceneAttachedShelf || !constraints.hasBoundedHeight) {
            return Align(
              key: const Key('act0_shell_lower_stage_accessibility'),
              alignment: Alignment.topCenter,
              heightFactor: 1,
              child: integratedDockBody,
            );
          }
          return SizedBox.expand(
            key: const Key('act0_shell_lower_stage_accessibility'),
            child: accessibilityFeedbackSurface
                ? integratedDockBody
                : Align(alignment: Alignment.center, child: integratedDockBody),
          );
        },
      ),
    };
    final dockContent = usesAccessibilitySharedSurface
        ? SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: pageX),
              child: Container(
                key: const Key('act0_shell_accessibility_shared_surface'),
                width: double.infinity,
                decoration: Act0ShellTokensV1.surfaceDecoration(
                  color: Act0ShellTokensV1.surface2,
                  borderColor: Act0ShellTokensV1.info.withValues(alpha: 0.24),
                ),
                child: stageComposedDockBody,
              ),
            ),
          )
        : integratedLowerSurface
        ? Padding(
            padding: EdgeInsets.fromLTRB(pageX, 0, pageX, 0),
            child: Container(
              key: const Key('act0_shell_runner_action_surface'),
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                0,
                6,
                0,
                safeBottom > 0 ? safeBottom + 6 : 0,
              ),
              // B7: on the scene-attached shelf the shelf itself owns the
              // surface. Painting a second, page-inset gradient here is what
              // left exposed background strips down both edges and read as a
              // card stacked inside another card.
              decoration: sceneAttachedShelf
                  ? null
                  : const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          Act0ShellTokensV1.surface2,
                          Act0ShellTokensV1.surface,
                        ],
                      ),
                    ),
              child: stageComposedDockBody,
            ),
          )
        : SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                pageX,
                compactAnswerListDecision
                    ? 3
                    : lowerStageProfile ==
                          _RunnerLowerStageProfileV1.compactFeedback
                    ? 4
                    : Act0ShellTokensV1.gapSm,
                pageX,
                stageBottomPadding,
              ),
              child: stageComposedDockBody,
            ),
          );
    final visualDock = Container(
      key: const Key('act0_shell_runner_action_dock'),
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: Act0ShellTokensV1.runnerActionDockMinHeight,
      ),
      // B7: the scene-attached shelf owns exactly one surface and one top
      // boundary. The shared glass decoration drew a second competing edge
      // inside it, which is what made the dock read as an app card stacked on
      // the scene rather than a control plane attached to it.
      decoration: sceneAttachedShelf
          ? null
          : Act0ShellTokensV1.glassDecoration(top: true),
      child: dockContent,
    );
    return visualDock;
  }
}

/// Keeps an overflowing repair body discoverable with its primary CTA already
/// inside the safe viewport. The body scrolls upward from that stable action.
class _BoundedLowerStageScrollV1 extends StatelessWidget {
  const _BoundedLowerStageScrollV1({
    required this.child,
    this.showActionFirst = false,
  });

  final Widget child;
  final bool showActionFirst;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const Key('act0_shell_lower_stage_scroll'),
      primary: false,
      reverse: showActionFirst,
      physics: const ClampingScrollPhysics(),
      child: child,
    );
  }
}

class _CompactAnswerListDecisionScopeV1 extends InheritedWidget {
  const _CompactAnswerListDecisionScopeV1({
    required this.compact,
    required super.child,
  });

  final bool compact;

  static bool isCompact(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<
              _CompactAnswerListDecisionScopeV1
            >()
            ?.compact ??
        false;
  }

  @override
  bool updateShouldNotify(_CompactAnswerListDecisionScopeV1 oldWidget) {
    return compact != oldWidget.compact;
  }
}

class _SizingPresetsLaneV1 extends StatelessWidget {
  const _SizingPresetsLaneV1({
    required this.presets,
    required this.selectedPresetId,
    required this.onSelectPreset,
  });

  final List<Act0SizingPresetV1> presets;
  final String? selectedPresetId;
  final ValueChanged<Act0SizingPresetV1> onSelectPreset;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sizing',
          key: Key('act0_shell_sizing_presets_label'),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Act0ShellTokensV1.info,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: Act0ShellTokensV1.gapXs),
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            for (var i = 0; i < presets.length; i++) ...[
              Expanded(
                child: _SizingPresetButtonV1(
                  preset: presets[i],
                  isSelected: presets[i].id == selectedPresetId,
                  onPressed: () => onSelectPreset(presets[i]),
                ),
              ),
              if (i < presets.length - 1)
                const SizedBox(width: Act0ShellTokensV1.gapXs),
            ],
          ],
        ),
      ],
    );
  }
}

class _SizingConfirmPanelV1 extends StatelessWidget {
  const _SizingConfirmPanelV1({
    required this.selectedPreset,
    required this.onConfirm,
  });

  final Act0SizingPresetV1? selectedPreset;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    final preset = selectedPreset;
    final canConfirm = preset != null && onConfirm != null;
    final label = preset == null
        ? 'Select one size'
        : preset.ctaLabel ?? 'Lock ${preset.displayLabel ?? preset.label}';

    return FilledButton(
      key: const Key('act0_shell_sizing_confirm_cta'),
      onPressed: canConfirm ? onConfirm : null,
      style: Act0ShellTokensV1.primaryButtonStyle(
        height: Act0ShellTokensV1.compactCtaHeight,
      ),
      child: Text(label),
    );
  }
}

class _SizingPresetButtonV1 extends StatelessWidget {
  const _SizingPresetButtonV1({
    required this.preset,
    required this.isSelected,
    required this.onPressed,
  });

  final Act0SizingPresetV1 preset;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isSelected
        ? Act0ShellTokensV1.primary.withValues(alpha: 0.16)
        : Act0ShellTokensV1.surface2;
    final borderColor = isSelected
        ? Act0ShellTokensV1.primary.withValues(alpha: 0.92)
        : Act0ShellTokensV1.primary.withValues(alpha: 0.3);

    return Act0SemanticActionV1(
      label: preset.label,
      value: preset.displayLabel == preset.label ? null : preset.displayLabel,
      selected: isSelected,
      onTap: onPressed,
      child: OutlinedButton(
        key: Key('act0_shell_sizing_preset_${preset.id}'),
        onPressed: onPressed,
        style: Act0ShellTokensV1.quietButtonStyle(height: 44).copyWith(
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          ),
          backgroundColor: WidgetStatePropertyAll(backgroundColor),
          side: WidgetStatePropertyAll(
            BorderSide(color: borderColor, width: 1.5),
          ),
          foregroundColor: WidgetStatePropertyAll(
            isSelected ? Act0ShellTokensV1.primary : Act0ShellTokensV1.text,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              preset.displayLabel ?? preset.label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            if ((preset.detailLabel ?? '').isNotEmpty)
              Text(
                preset.detailLabel!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color:
                      (isSelected
                              ? Act0ShellTokensV1.primary
                              : Act0ShellTokensV1.textMuted)
                          .withValues(alpha: isSelected ? 0.92 : 0.9),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StepIntroPillV1 extends StatelessWidget {
  const _StepIntroPillV1({required this.label, required this.title});

  final String label;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('act0_shell_step_intro_pill'),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Act0ShellTokensV1.gold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
        border: Border.all(
          color: Act0ShellTokensV1.gold.withValues(alpha: 0.42),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Act0ShellTokensV1.label.copyWith(
              color: Act0ShellTokensV1.gold,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: Act0ShellTokensV1.label.copyWith(
              color: Act0ShellTokensV1.text,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskRailV1 extends StatelessWidget {
  const _TaskRailV1({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('act0_shell_task_rail'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Act0ShellTokensV1.surface2.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusMd),
        border: Border.all(
          color: Act0ShellTokensV1.info.withValues(alpha: 0.36),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Act0ShellTokensV1.info.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
            ),
            child: const Icon(
              Icons.flag_rounded,
              size: 12,
              color: Act0ShellTokensV1.info,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 3,
              style: Act0ShellTokensV1.body.copyWith(
                fontSize: 12,
                color: Act0ShellTokensV1.text,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SharkyCuePillV1 extends StatelessWidget {
  const _SharkyCuePillV1({
    required this.line,
    required this.tone,
    required this.mood,
  });

  final String line;
  final Color tone;
  final Act0SharkyMoodV1 mood;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
        border: Border.all(color: tone.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Act0SharkyMascotV1(mood: mood, tone: tone, size: 32),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              line,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Act0ShellTokensV1.label.copyWith(
                color: Act0ShellTokensV1.text,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Act0SharkyMascotV1 extends StatelessWidget {
  const Act0SharkyMascotV1({
    super.key,
    required this.mood,
    required this.tone,
    this.size = 32,
  });

  final Act0SharkyMoodV1 mood;
  final Color tone;
  final double size;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final motionScale = switch (mood) {
      Act0SharkyMoodV1.happy => 1.08,
      Act0SharkyMoodV1.celebrate => 1.12,
      Act0SharkyMoodV1.repair => 0.96,
      Act0SharkyMoodV1.thinking => 1.03,
      Act0SharkyMoodV1.neutral => 1.0,
    };
    final motionTilt = switch (mood) {
      Act0SharkyMoodV1.happy => -0.05,
      Act0SharkyMoodV1.celebrate => 0.08,
      Act0SharkyMoodV1.repair => -0.08,
      Act0SharkyMoodV1.thinking => 0.04,
      Act0SharkyMoodV1.neutral => 0.0,
    };

    return Semantics(
      label: 'Sharky mascot',
      child: SizedBox(
        key: const Key('act0_shell_sharky_mascot_motion'),
        child: TweenAnimationBuilder<double>(
          key: ValueKey('act0_shell_sharky_mascot_motion_${mood.name}'),
          tween: Tween<double>(begin: 0, end: reduceMotion ? 0 : 1),
          duration: reduceMotion
              ? Duration.zero
              : const Duration(milliseconds: 420),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            if (reduceMotion) return child!;
            final easedScale = 1 + ((motionScale - 1) * value);
            final easedTilt = motionTilt * value;
            return Transform.rotate(
              angle: easedTilt,
              child: Transform.scale(scale: easedScale, child: child),
            );
          },
          child: SizedBox(
            key: const Key('act0_shell_sharky_mascot'),
            width: size,
            height: size,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  size * Act0ShellTokensV1.sharkyTileRadiusRatio,
                ),
                boxShadow: [
                  BoxShadow(
                    color: tone.withValues(alpha: 0.20),
                    blurRadius: size * 0.24,
                    offset: Offset(0, size * 0.08),
                  ),
                ],
              ),
              child: KeyedSubtree(
                key: Key('act0_shell_sharky_mascot_${mood.name}'),
                child: Act0SharkyPresenceMascotV1(
                  mood: mood,
                  tone: tone,
                  size: size,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

const double _learningRailMaxHeightV1 = 148;
const double _sharedActiveRunnerLearningRailMaxHeightV1 = 148;
const double _runnerCompositionHeaderAndGapV1 = 48;
const double _sharedRunnerSeamV1 = 10;
const double _sharedRunnerTableFramingInsetV1 = 12;
const double _sharedRunnerEnlargedTextDockGrowthV1 = 285;

double _sharedRunnerCycleStableEnvelopeHeightV1({
  required double stageHeight,
  required double accessibilityScale,
}) {
  final boundedScale = accessibilityScale.clamp(1.0, 1.4);
  final decisionDockDemand =
      156 + ((boundedScale - 1) * _sharedRunnerEnlargedTextDockGrowthV1);
  final cyclePeakFraction = boundedScale >= 1.3 ? 0.50 : 0.36;
  final cyclePeak = stageHeight * cyclePeakFraction;
  final reserveMax = stageHeight * 0.13;
  return math.min(cyclePeak, decisionDockDemand + reserveMax);
}

BoxDecoration _sharedRunnerSeamDecorationV1() => BoxDecoration(
  border: Border(
    top: BorderSide(color: Colors.white.withValues(alpha: 0.10), width: 1),
  ),
  gradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[
      Act0ShellTokensV1.surface2.withValues(alpha: 0.18),
      Act0ShellTokensV1.surface2.withValues(alpha: 0.04),
    ],
  ),
);

double _normalRunnerLowerSurfaceDemandV1(
  BuildContext context, {
  required String question,
  required List<Act0RunnerOptionV1> options,
  required bool showsLearningRail,
  bool includeStableLaneFloor = true,
}) {
  // An answer runner keeps one measured decision demand through its ordinary
  // theory, decision, and feedback cycle so the table does not jump.
  if (options.isNotEmpty) {
    final media = MediaQuery.of(context);
    final width = math.max(1.0, media.size.width - 56);
    final scaler = media.textScaler;
    // A normal decision row must keep its complete touch/read target as copy
    // grows. This uses the live scaler, rather than a public scale threshold,
    // so activation follows measured lower-surface demand.
    final scaledControlFloor = math.max(44.0, 44.0 * scaler.scale(1));
    double measuredHeight(String text, TextStyle style) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr,
        textScaler: scaler,
        maxLines: null,
      )..layout(maxWidth: width);
      return painter.height;
    }

    final questionHeight = measuredHeight(
      question,
      Act0ShellTokensV1.body.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w900,
        height: 1.06,
      ),
    );
    final optionDemand = options.fold<double>(0, (sum, option) {
      final labelHeight = measuredHeight(
        option.label,
        Act0ShellTokensV1.body.copyWith(fontSize: 12.6, height: 1.08),
      );
      return sum + math.max(scaledControlFloor, labelHeight + 10);
    });
    // Surface padding, question-to-answer rhythm, dividers, and bounded
    // bottom clearance. This is intrinsic content demand, not final layout
    // allocation or empty lower-surface space.
    final intrinsicDemand = questionHeight + optionDemand + 34;
    // Table allocation is a stable stage contract. It is deliberately
    // separate from the intrinsic content demand used for accessibility
    // activation below, so short copy cannot resize the accepted hand.
    return includeStableLaneFloor
        ? math.max(279, intrinsicDemand)
        : intrinsicDemand;
  }
  return showsLearningRail
      ? _sharedActiveRunnerLearningRailMaxHeightV1
      : Act0ShellTokensV1.runnerActionDockMinHeight;
}

/// Predicts compact-mode activation before the normal table-plus-answer layout
/// renders. It measures the actual question and option copy at the admitted
/// text scale against the lower space left by the accepted table geometry.
/// Learner-facing order of a task's hand premises.
///
/// Authored captions open with a fixed setup sentence (six players, 100 BB
/// stacks, 0.5/1 BB blinds, no ante, straddle or rake). Every premise stays on
/// screen, but the decision facts come first and the setup sentence moves to
/// the end, so the first visible lines answer "what is happening now".
String act0LearnerFacingPremisesV1(String caption) {
  final match = RegExp(
    r'For this [^;]*?100 BB[^;]*;\s*no ante, straddle or rake\.',
  ).firstMatch(caption);
  if (match == null) return caption;
  final rest =
      (caption.substring(0, match.start) + caption.substring(match.end))
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
  if (rest.isEmpty) return caption;
  return '$rest ${match.group(0)}';
}

bool act0ShouldActivateCompactAccessibilityPrototypeV1(
  BuildContext context, {
  required String question,
  required List<Act0RunnerOptionV1> options,
  List<String> tableCriticalLabels = const <String>[],
}) {
  final media = MediaQuery.of(context);
  final supportedPhone = media.size.shortestSide < 600;
  if (!supportedPhone || options.length != 4) {
    return false;
  }
  final required = _normalRunnerLowerSurfaceDemandV1(
    context,
    question: question,
    options: options,
    showsLearningRail: false,
    includeStableLaneFloor: false,
  );
  final safe = media.viewPadding.vertical > 0
      ? media.viewPadding.vertical
      : media.padding.vertical;
  // This is the smallest accepted normal table stage plus runner chrome. If
  // even that stage and the measured lower demand cannot coexist, preserve
  // the hand through Evidence -> Decision rather than shrinking it further.
  const acceptedTableAndChrome = 533.0;
  final available = media.size.height - safe - acceptedTableAndChrome;
  // A broad unwrapped-label width cannot establish a table collision: the
  // admitted centre guidance may wrap safely to two lines. Activation follows
  // intrinsic composition demand; table geometry retains collision ownership.
  return required > available;
}

class _AccessibilityDirectDecisionV1 extends StatefulWidget {
  const _AccessibilityDirectDecisionV1({
    required this.question,
    required this.guidance,
    required this.options,
    required this.onChoose,
  });

  final String question;
  final String guidance;
  final List<Act0RunnerOptionV1> options;
  final ValueChanged<Act0RunnerOptionV1> onChoose;

  @override
  State<_AccessibilityDirectDecisionV1> createState() =>
      _AccessibilityDirectDecisionV1State();
}

class _AccessibilityDirectDecisionV1State
    extends State<_AccessibilityDirectDecisionV1> {
  String? _focusedOptionId;

  @override
  Widget build(BuildContext context) {
    final options = widget.options;
    final guidance = widget.guidance;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        key: const Key('act0_shell_accessibility_answer_group'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            key: const Key('act0_shell_accessibility_decision_module'),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    widget.question,
                    key: const Key('act0_shell_accessibility_question'),
                    style: Act0ShellTokensV1.body.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      height: 1.12,
                    ),
                  ),
                ),
                if (guidance.trim().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      guidance,
                      key: const Key('act0_shell_accessibility_guidance'),
                      style: Act0ShellTokensV1.body.copyWith(
                        color: Act0ShellTokensV1.textMuted,
                        fontSize: 11,
                        height: 1.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 2),
                Container(
                  height: 1,
                  color: Act0ShellTokensV1.info.withValues(alpha: 0.34),
                ),
                const SizedBox(height: 2),
                for (final (index, option) in options.indexed) ...[
                  Act0SemanticActionV1(
                    label: act0AcademyW1OptionLabelV1(
                      context,
                      act0RuntimeLocalizedOptionLabelV1(context, option.label),
                    ),
                    sortKey: OrdinalSortKey(
                      index.toDouble(),
                      name: 'act0_choices',
                    ),
                    selected: false,
                    focused: _focusedOptionId == option.id,
                    value: option.amountLabel.trim().isEmpty
                        ? null
                        : option.amountLabel,
                    onTap: () => widget.onChoose(option),
                    child: Material(
                      color: Act0ShellTokensV1.surface,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        key: Key('act0_shell_option_${option.id}'),
                        onTap: () => widget.onChoose(option),
                        onFocusChange: (focused) {
                          if (focused) {
                            setState(() => _focusedOptionId = option.id);
                          } else if (_focusedOptionId == option.id) {
                            setState(() => _focusedOptionId = null);
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 48),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              child: Text(
                                act0AcademyW1OptionLabelV1(
                                  context,
                                  act0RuntimeLocalizedOptionLabelV1(
                                    context,
                                    option.label,
                                  ),
                                ),
                                style: Act0ShellTokensV1.body.copyWith(
                                  fontWeight: FontWeight.w800,
                                  height: 1.10,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (option != options.last) const SizedBox(height: 2),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A bounded, opt-in artifact for the Phase 1 lower-surface gate. Core repair
/// is deliberately short and paginated; only the optional reference article
/// receives a body viewport. Its footer is a sibling, never scroll content.
class _PrototypeRepairSurfaceV1 extends StatelessWidget {
  const _PrototypeRepairSurfaceV1({required this.state});

  final Act0LowerSurfacePrototypeStateV1 state;

  @override
  Widget build(BuildContext context) {
    final expanded =
        state == Act0LowerSurfacePrototypeStateV1.expandedReference;
    final beat = switch (state) {
      Act0LowerSurfacePrototypeStateV1.coreRepairBeat1 => (
        title: 'Missed clue',
        body: 'Start with the visible table clue before choosing an action.',
        footer: 'Next',
      ),
      Act0LowerSurfacePrototypeStateV1.coreRepairBeat2 => (
        title: 'Reusable rule',
        body:
            'Read the seats, board, and price together. The same order works in the next hand.',
        footer: 'Next',
      ),
      Act0LowerSurfacePrototypeStateV1.coreRepairFinalBeat => (
        title: 'Prepare to recheck',
        body: 'Use that one table read now, then make the same decision again.',
        footer: 'Recheck',
      ),
      Act0LowerSurfacePrototypeStateV1.expandedReference => (
        title: 'Learn more',
        body: '',
        footer: 'Done reading',
      ),
    };
    final body = expanded
        ? SingleChildScrollView(
            key: const Key('act0_shell_expanded_reference_body_scroll'),
            primary: false,
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 56),
            child: Column(
              key: const Key('act0_shell_expanded_reference_body'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const <Widget>[
                Text(
                  'Learn more',
                  key: Key('act0_shell_expanded_reference_top'),
                ),
                SizedBox(height: 8),
                Text(
                  'The quick repair is enough for the next decision. This reference keeps the longer explanation separate: read the table first, then identify the price, then choose the action that matches both facts.'
                  '\n\nThe body is intentionally longer than the compact surface. It can move without moving the table, the surface seam, or the action rail below it.'
                  '\n\nWhen the table changes, repeat the same read in order. That turns one missed clue into a reusable rule instead of a long default lesson.',
                ),
                SizedBox(height: 16),
                Text(
                  'Use this longer reference only when you want the extra why. It is not the default repair: the short three beats are the learner path, while this body is a separate place to revisit the same rule at your own pace.'
                  '\n\nKeep the table as the source of truth. A label is useful only when it points back to a visible seat, card, board, pot, or action.'
                  '\n\nFinish the reference by returning to one concrete recheck. The footer stays available while this explanation moves beneath it.',
                ),
                SizedBox(height: 24),
                Text(
                  'End of reference',
                  key: Key('act0_shell_expanded_reference_bottom'),
                ),
              ],
            ),
          )
        : KeyedSubtree(
            key: const Key('act0_shell_core_repair_body'),
            child: Text(beat.body),
          );
    return Container(
      key: const Key('act0_shell_prototype_repair_surface'),
      constraints: const BoxConstraints.tightFor(height: 148),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: Act0ShellTokensV1.surface2.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
        border: Border.all(
          color: Act0ShellTokensV1.info.withValues(alpha: 0.24),
        ),
      ),
      child: Column(
        key: const Key('act0_shell_prototype_repair_column'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            beat.title,
            key: const Key('act0_shell_prototype_repair_title'),
            maxLines: 2,
            style: Act0ShellTokensV1.label.copyWith(
              color: Act0ShellTokensV1.info,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: expanded
                ? body
                : Align(alignment: Alignment.topLeft, child: body),
          ),
          const SizedBox(height: 8),
          SizedBox(
            key: const Key('act0_shell_prototype_repair_footer'),
            height: Act0ShellTokensV1.compactCtaHeight,
            child: FilledButton(
              key: const Key('act0_shell_prototype_repair_cta'),
              onPressed: () {},
              child: Text(beat.footer),
            ),
          ),
        ],
      ),
    );
  }
}

class _LearningRailV1 extends StatelessWidget {
  const _LearningRailV1({
    required this.taskLabel,
    required this.prompt,
    required this.supportSegments,
    required this.activeSupportSegmentIndex,
    required this.progressLabel,
    required this.canGoBack,
    this.backSemanticLabel = 'Previous theory page',
    required this.onBack,
    required this.canAdvance,
    required this.onAdvance,
    required this.sharkyLine,
    required this.sharkyMood,
    required this.advanceLabel,
    this.maxHeight = _learningRailMaxHeightV1,
    this.emphasizePrompt = false,
    this.fillsAvailableHeight = false,
    this.contextOwnsTeachingCopy = false,
  });

  final String? taskLabel;
  final String prompt;
  final List<String> supportSegments;
  final int activeSupportSegmentIndex;
  final String? progressLabel;
  final bool canGoBack;
  final String backSemanticLabel;
  final VoidCallback? onBack;
  final bool canAdvance;
  final VoidCallback onAdvance;
  final String sharkyLine;
  final Act0SharkyMoodV1 sharkyMood;
  final String advanceLabel;
  final double maxHeight;
  final bool emphasizePrompt;
  final bool fillsAvailableHeight;
  final bool contextOwnsTeachingCopy;

  @override
  Widget build(BuildContext context) {
    final showTaskLabel = taskLabel != null && taskLabel!.trim().isNotEmpty;
    final hasSupportLine = supportSegments.isNotEmpty;
    final showRailProgress =
        progressLabel != null && progressLabel!.trim().isNotEmpty;
    final fallbackCoachLine = sharkyLine.trim();
    final showFallbackCoachLine =
        !hasSupportLine && fallbackCoachLine.isNotEmpty;
    final tone = canAdvance
        ? Act0ShellTokensV1.primary
        : Act0ShellTokensV1.textMuted;
    if (contextOwnsTeachingCopy) {
      final pageCount = math.max(1, supportSegments.length);
      final currentPage = activeSupportSegmentIndex.clamp(0, pageCount - 1);
      if (!canGoBack && pageCount == 1) {
        return Padding(
          key: const Key('act0_shell_learning_rail'),
          padding: const EdgeInsets.fromLTRB(14, 9, 14, 8),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              key: const Key('act0_shell_continue_cta'),
              onPressed: canAdvance ? onAdvance : null,
              style: Act0ShellTokensV1.primaryButtonStyle(
                height: Act0ShellTokensV1.compactCtaHeight,
              ),
              child: Text(advanceLabel),
            ),
          ),
        );
      }

      return Semantics(
        container: true,
        label: 'Theory navigation, page ${currentPage + 1} of $pageCount',
        child: Padding(
          key: const Key('act0_shell_learning_rail'),
          padding: const EdgeInsets.fromLTRB(14, 9, 14, 8),
          child: Row(
            children: [
              if (canGoBack) ...[
                _LearningRailNavButtonV1(
                  icon: Icons.arrow_back_ios_new_rounded,
                  buttonKey: const Key('act0_shell_previous_cta'),
                  semanticLabel: backSemanticLabel,
                  enabled: canGoBack,
                  onPressed: onBack,
                  compact: true,
                ),
                const SizedBox(width: Act0ShellTokensV1.gapSm),
              ],
              Expanded(
                child: pageCount > 1
                    ? _LearningRailSupportDotsV1(
                        count: pageCount,
                        current: currentPage,
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(width: Act0ShellTokensV1.gapSm),
              _LearningRailNavButtonV1(
                icon: Icons.arrow_forward_ios_rounded,
                buttonKey: const Key('act0_shell_continue_cta'),
                enabled: canAdvance,
                onPressed: canAdvance ? onAdvance : null,
                tone: tone,
                compact: true,
                label: advanceLabel,
              ),
            ],
          ),
        ),
      );
    }
    return Material(
      color: Colors.transparent,
      child: Container(
        key: const Key('act0_shell_learning_rail'),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: math.min(102, maxHeight),
            maxHeight: fillsAvailableHeight ? double.infinity : maxHeight,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              const footerHeight = 34.0;
              final compactRail =
                  !fillsAvailableHeight && constraints.maxHeight <= maxHeight;
              final compactLaneMaxWidth = compactRail ? 286.0 : double.infinity;
              final activePage = hasSupportLine
                  ? supportSegments[activeSupportSegmentIndex.clamp(
                      0,
                      supportSegments.length - 1,
                    )]
                  : fallbackCoachLine;
              final title = showTaskLabel ? taskLabel! : 'Read the table';
              final pageCount = math.max(1, supportSegments.length);
              final pageNumber =
                  activeSupportSegmentIndex.clamp(0, pageCount - 1) + 1;
              final usesBoundedContentScroll =
                  MediaQuery.textScalerOf(context).scale(1) > 1.1;
              final contentLane = Semantics(
                label: 'Theory page $pageNumber of $pageCount',
                child: ConstrainedBox(
                  key: const Key('act0_shell_learning_rail_content_lane'),
                  constraints: BoxConstraints(maxWidth: compactLaneMaxWidth),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        title,
                        key: const Key('act0_shell_learning_rail_task_label'),
                        maxLines: 2,
                        style: Act0ShellTokensV1.label.copyWith(
                          color: Act0ShellTokensV1.info,
                          letterSpacing: 0.16,
                          fontSize: 10.2,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _formatInstructionCopyV1(
                          activePage,
                          allowSingleClauseSplit: true,
                        ),
                        key: const Key('act0_shell_runner_prompt'),
                        softWrap: true,
                        style: Act0ShellTokensV1.body.copyWith(
                          color: Act0ShellTokensV1.text,
                          fontSize: compactRail ? 13.0 : 14.0,
                          height: 1.24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: compactRail ? 10 : 12,
                  vertical: emphasizePrompt ? 3 : 2,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: usesBoundedContentScroll
                          ? SingleChildScrollView(
                              key: const Key(
                                'act0_shell_learning_rail_content_scroll',
                              ),
                              primary: false,
                              physics: const ClampingScrollPhysics(),
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: contentLane,
                              ),
                            )
                          : Align(
                              // The navigation footer is the next action for
                              // this instruction. Short pages stay intrinsic
                              // and compose directly above it.
                              alignment: fillsAvailableHeight
                                  ? Alignment.topCenter
                                  : Alignment.bottomCenter,
                              child: contentLane,
                            ),
                    ),
                    const SizedBox(height: 3),
                    SizedBox(
                      key: const Key('act0_shell_learning_rail_fixed_footer'),
                      height: 28,
                      child: Row(
                        children: [
                          _LearningRailNavButtonV1(
                            icon: Icons.arrow_back_ios_new_rounded,
                            buttonKey: const Key('act0_shell_previous_cta'),
                            semanticLabel: backSemanticLabel,
                            enabled: canGoBack,
                            onPressed: onBack,
                            compact: compactRail,
                          ),
                          if (pageCount > 1) ...[
                            const SizedBox(width: Act0ShellTokensV1.gapSm),
                            Expanded(
                              child: Align(
                                alignment: Alignment.center,
                                child: _LearningRailSupportDotsV1(
                                  key: const Key(
                                    'act0_shell_learning_rail_support_dots',
                                  ),
                                  count: pageCount,
                                  current: activeSupportSegmentIndex.clamp(
                                    0,
                                    pageCount - 1,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: Act0ShellTokensV1.gapSm),
                          ] else
                            const Spacer(),
                          _LearningRailNavButtonV1(
                            icon: Icons.arrow_forward_ios_rounded,
                            buttonKey: const Key('act0_shell_continue_cta'),
                            enabled: canAdvance,
                            onPressed: canAdvance ? onAdvance : null,
                            tone: tone,
                            compact: compactRail,
                            label: act0RuntimeLocalizedGeneralLabelV1(
                              context,
                              advanceLabel,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _RailFocusChipV1 extends StatelessWidget {
  const _RailFocusChipV1({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: Act0ShellTokensV1.textMuted.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
        border: Border.all(
          color: Act0ShellTokensV1.textMuted.withValues(alpha: 0.22),
        ),
      ),
      child: Text(
        label,
        style: Act0ShellTokensV1.label.copyWith(
          color: Act0ShellTokensV1.textMuted,
          fontSize: 9,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _LearningRailSupportDotsV1 extends StatelessWidget {
  const _LearningRailSupportDotsV1({
    super.key,
    required this.count,
    required this.current,
  });

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < count; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          AnimatedContainer(
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            width: i == current ? 10 : 4,
            height: 4,
            decoration: BoxDecoration(
              color: i == current
                  ? Act0ShellTokensV1.primary
                  : Act0ShellTokensV1.textMuted.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
            ),
          ),
        ],
      ],
    );
  }
}

class _LearningRailNavButtonV1 extends StatelessWidget {
  const _LearningRailNavButtonV1({
    required this.icon,
    required this.buttonKey,
    required this.enabled,
    this.onPressed,
    this.tone = Act0ShellTokensV1.text,
    this.compact = false,
    this.label,
    this.semanticLabel,
  });

  final IconData icon;
  final Key buttonKey;
  final bool enabled;
  final VoidCallback? onPressed;
  final Color tone;
  final bool compact;
  final String? label;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final hasLabel = (label ?? '').trim().isNotEmpty;
    final resolvedLabel = label?.trim() ?? '';
    return Act0SemanticActionV1(
      label:
          semanticLabel ?? (hasLabel ? resolvedLabel : 'Previous theory page'),
      onTap: enabled ? onPressed : null,
      child: Container(
        width: hasLabel ? null : (compact ? 32 : 40),
        height: compact ? 32 : 40,
        constraints: BoxConstraints(
          minWidth: hasLabel ? (compact ? 92 : 110) : (compact ? 32 : 40),
        ),
        decoration: BoxDecoration(
          color: enabled
              ? tone.withValues(alpha: 0.12)
              : Act0ShellTokensV1.surface3.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusBase),
          border: Border.all(
            color: enabled
                ? tone.withValues(alpha: 0.30)
                : Act0ShellTokensV1.border.withValues(alpha: 0.76),
          ),
        ),
        child: TextButton(
          key: buttonKey,
          onPressed: enabled ? onPressed : null,
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: hasLabel ? 10 : 0,
              vertical: 0,
            ),
            minimumSize: Size(
              hasLabel ? (compact ? 92 : 110) : (compact ? 32 : 40),
              compact ? 32 : 40,
            ),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusBase),
            ),
          ),
          child: hasLabel
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        resolvedLabel,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: Act0ShellTokensV1.label.copyWith(
                          color: enabled ? tone : Act0ShellTokensV1.textDim,
                          fontSize: compact ? 11.0 : 11.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      icon,
                      size: compact ? 12 : 16,
                      color: enabled ? tone : Act0ShellTokensV1.textDim,
                    ),
                  ],
                )
              : Icon(
                  icon,
                  size: compact ? 12 : 16,
                  color: enabled ? tone : Act0ShellTokensV1.textDim,
                ),
        ),
      ),
    );
  }
}

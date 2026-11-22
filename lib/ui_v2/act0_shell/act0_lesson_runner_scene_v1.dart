part of 'act0_lesson_runner_shell_v1.dart';

/// Reusable production-quality full table scene.
///
/// The public constructor intentionally exposes only semantic table state and a
/// data-only presentation config. The runner uses [_fromRunner] to retain its
/// private interaction, overlay, and viewport policy without making those
/// policies part of this scene's external contract.
class Act0TableSceneV1 extends StatelessWidget {
  const Act0TableSceneV1({
    super.key,
    required this.table,
    this.config = const Act0TablePresentationConfigV1(),
    this.onBoardCardTap,
  }) : _runnerInput = null;

  Act0TableSceneV1._fromRunner({required _Act0TableSceneRunnerInput input})
    : table = input.table,
      config = null,
      onBoardCardTap = null,
      _runnerInput = input;

  final Act0TableStateV1 table;
  final Act0TablePresentationConfigV1? config;
  final ValueChanged<Act0TableStateV1>? onBoardCardTap;
  final _Act0TableSceneRunnerInput? _runnerInput;

  @override
  Widget build(BuildContext context) {
    final input = _runnerInput;
    if (input != null) {
      return _Act0TableV1(
        sceneRegistration: input.sceneRegistration,
        table: input.table,
        highlightedCardIds: input.highlightedCardIds,
        interactiveCalloutLabel: input.interactiveCalloutLabel,
        onBoardCardTap: input.onBoardCardTap,
        onChooseSeat: input.onChooseSeat,
        visualVariant: input.visualVariant,
        showFocusBadge: input.showFocusBadge,
        showRepairCallout: input.showRepairCallout,
        playbackActiveSeatId: input.playbackActiveSeatId,
        animateBetMotion: input.animateBetMotion,
        betOverride: input.betOverride,
        centerLabelOverride: input.centerLabelOverride,
        potLabelOverride: input.potLabelOverride,
        toCallLabelOverride: input.toCallLabelOverride,
        streetLabelOverride: input.streetLabelOverride,
        completionSummary: input.completionSummary,
        selectedSeatId: input.selectedSeatId,
        selectedSeatFeedbackState: input.selectedSeatFeedbackState,
        compactBottomDockClearance: input.compactBottomDockClearance,
        interactionMode: input.interactionMode,
        framingProfile: input.framingProfile,
        viewportFamily: input.viewportFamily,
        lateRouteSignal: input.lateRouteSignal,
        identityPolicy: input.identityPolicy,
        maxTableHeight: input.maxTableHeight,
        cameraStageSize: input.cameraStageSize,
        lockSharedActiveTableGeometry: input.lockSharedActiveTableGeometry,
        integratedPerspectivePrototype: input.integratedPerspectivePrototype,
        attention: input.attention,
      );
    }
    final resolved = config!;
    return _Act0TableV1(
      table: table,
      highlightedCardIds: resolved.highlightedCardIds,
      interactiveCalloutLabel: '',
      onBoardCardTap: (table) => onBoardCardTap?.call(table),
      visualVariant: resolved.useRefinedVisualVariant
          ? Act0ShellTableVisualVariantV1.refinedDev2
          : Act0ShellTableVisualVariantV1.classic,
      showFocusBadge: resolved.showFocusBadge,
      showRepairCallout: resolved.showRepairCallout,
      compactBottomDockClearance: resolved.compactBottomDockClearance,
      identityPolicy: resolved.identityPolicy,
      interactionMode: _RunnerInteractionModeV1.answerListDecision,
      framingProfile: Act0RunnerFramingProfileV1.neutral,
      viewportFamily: _RunnerViewportFamilyV1.neutral,
      maxTableHeight: resolved.maxTableHeight,
    );
  }
}

class _Act0TableSceneRunnerInput {
  const _Act0TableSceneRunnerInput({
    this.sceneRegistration,
    required this.attention,
    required this.table,
    required this.highlightedCardIds,
    required this.interactiveCalloutLabel,
    required this.onBoardCardTap,
    required this.onChooseSeat,
    required this.visualVariant,
    required this.showFocusBadge,
    required this.showRepairCallout,
    required this.playbackActiveSeatId,
    required this.animateBetMotion,
    required this.betOverride,
    required this.centerLabelOverride,
    required this.potLabelOverride,
    required this.toCallLabelOverride,
    required this.streetLabelOverride,
    required this.completionSummary,
    required this.selectedSeatId,
    required this.selectedSeatFeedbackState,
    required this.compactBottomDockClearance,
    required this.interactionMode,
    required this.framingProfile,
    required this.viewportFamily,
    required this.lateRouteSignal,
    required this.identityPolicy,
    required this.maxTableHeight,
    required this.cameraStageSize,
    required this.lockSharedActiveTableGeometry,
    required this.integratedPerspectivePrototype,
  });
  final Act0SceneRegistrationV1? sceneRegistration;
  final Act0TableStateV1 table;
  final List<String> highlightedCardIds;
  final String interactiveCalloutLabel;
  final ValueChanged<Act0TableStateV1> onBoardCardTap;
  final ValueChanged<String>? onChooseSeat;
  final Act0ShellTableVisualVariantV1 visualVariant;
  final bool showFocusBadge;
  final bool showRepairCallout;
  final String? playbackActiveSeatId;
  final bool animateBetMotion;
  final Act0SeatBetStateV1? betOverride;
  final String? centerLabelOverride;
  final String? potLabelOverride;
  final String? toCallLabelOverride;
  final String? streetLabelOverride;
  final Act0RunnerCompletionSummaryV1? completionSummary;
  final String? selectedSeatId;
  final _SeatSelectionFeedbackStateV1 selectedSeatFeedbackState;
  final bool compactBottomDockClearance;
  final _RunnerInteractionModeV1 interactionMode;
  final Act0RunnerFramingProfileV1 framingProfile;
  final _RunnerViewportFamilyV1 viewportFamily;
  final Act0LateRouteTableSignalV1? lateRouteSignal;
  final Act0TableIdentityPolicyV1 identityPolicy;
  final double? maxTableHeight;
  final Size? cameraStageSize;
  final bool lockSharedActiveTableGeometry;
  final Act0SceneAttentionMotionV1 attention;
  final bool integratedPerspectivePrototype;
}

class _RunnerTableStageV1 extends StatelessWidget {
  const _RunnerTableStageV1({
    required this.attention,
    required this.table,
    required this.highlightedCardIds,
    required this.interactiveCalloutLabel,
    required this.onBoardCardTap,
    required this.onChooseSeat,
    required this.visualVariant,
    this.showFocusBadge = true,
    this.showRepairCallout = true,
    this.playbackActiveSeatId,
    this.animateBetMotion = false,
    this.betOverride,
    this.centerLabelOverride,
    this.potLabelOverride,
    this.toCallLabelOverride,
    this.streetLabelOverride,
    this.completionSummary,
    this.selectedSeatId,
    this.selectedSeatFeedbackState = _SeatSelectionFeedbackStateV1.none,
    this.compactBottomDockClearance = false,
    required this.interactionMode,
    required this.framingProfile,
    required this.viewportFamily,
    this.lateRouteSignal,
    this.identityPolicy = Act0TableIdentityPolicyV1.currentProduction,
    this.maxTableHeight,
    this.cameraStageSize,
    this.lockSharedActiveTableGeometry = false,
    this.integratedPerspectivePrototype = false,
    this.sceneRegistration,
  });

  final Act0SceneRegistrationV1? sceneRegistration;
  final Act0TableStateV1 table;
  final List<String> highlightedCardIds;
  final String interactiveCalloutLabel;
  final ValueChanged<Act0TableStateV1> onBoardCardTap;
  final ValueChanged<String>? onChooseSeat;
  final Act0ShellTableVisualVariantV1 visualVariant;
  final bool showFocusBadge;
  final bool showRepairCallout;
  final String? playbackActiveSeatId;
  final bool animateBetMotion;
  final Act0SeatBetStateV1? betOverride;
  final String? centerLabelOverride;
  final String? potLabelOverride;
  final String? toCallLabelOverride;
  final String? streetLabelOverride;
  final Act0RunnerCompletionSummaryV1? completionSummary;
  final String? selectedSeatId;
  final _SeatSelectionFeedbackStateV1 selectedSeatFeedbackState;
  final bool compactBottomDockClearance;
  final _RunnerInteractionModeV1 interactionMode;
  final Act0RunnerFramingProfileV1 framingProfile;
  final _RunnerViewportFamilyV1 viewportFamily;
  final Act0LateRouteTableSignalV1? lateRouteSignal;
  final Act0TableIdentityPolicyV1 identityPolicy;
  final double? maxTableHeight;

  /// B7: the exact stage box resolved by [Act0SceneCameraV1], threaded straight
  /// through so no responsive negotiation can reinterpret it.
  final Size? cameraStageSize;

  final bool lockSharedActiveTableGeometry;
  final Act0SceneAttentionMotionV1 attention;
  final bool integratedPerspectivePrototype;

  @override
  Widget build(BuildContext context) {
    return Act0TableSceneV1._fromRunner(
      input: _Act0TableSceneRunnerInput(
        sceneRegistration: sceneRegistration,
        table: table,
        highlightedCardIds: highlightedCardIds,
        interactiveCalloutLabel: interactiveCalloutLabel,
        onBoardCardTap: onBoardCardTap,
        onChooseSeat: onChooseSeat,
        visualVariant: visualVariant,
        showFocusBadge: showFocusBadge,
        showRepairCallout: showRepairCallout,
        playbackActiveSeatId: playbackActiveSeatId,
        animateBetMotion: animateBetMotion,
        betOverride: betOverride,
        centerLabelOverride: centerLabelOverride,
        potLabelOverride: potLabelOverride,
        toCallLabelOverride: toCallLabelOverride,
        streetLabelOverride: streetLabelOverride,
        completionSummary: completionSummary,
        selectedSeatId: selectedSeatId,
        selectedSeatFeedbackState: selectedSeatFeedbackState,
        compactBottomDockClearance: compactBottomDockClearance,
        interactionMode: interactionMode,
        framingProfile: framingProfile,
        viewportFamily: viewportFamily,
        lateRouteSignal: lateRouteSignal,
        identityPolicy: identityPolicy,
        maxTableHeight: maxTableHeight,
        cameraStageSize: cameraStageSize,
        lockSharedActiveTableGeometry: lockSharedActiveTableGeometry,
        integratedPerspectivePrototype: integratedPerspectivePrototype,
        attention: attention,
      ),
    );
  }
}

Act0TableStateV1 act0TeachingTableForRunnerV1(
  Act0TableStateV1 base,
  Act0TeachingStepV1? step,
) {
  if (step == null) {
    return base;
  }
  final source = step.table ?? base;
  final preserveBaseSeatContext =
      (base.activeSeatId ?? '').trim().isNotEmpty ||
      base.seats.any((seat) => seat.isActive);
  final seatContextSource = preserveBaseSeatContext ? base : source;
  final anchorSeatIds = _instructionAnchorSeatIds(source);
  final anchorCardIds = _instructionAnchorCardIds(source);
  return source.copyWith(
    seats: seatContextSource.seats,
    heroSeatId: seatContextSource.heroSeatId ?? source.heroSeatId,
    activeSeatId: preserveBaseSeatContext
        ? seatContextSource.activeSeatId
        : source.activeSeatId,
    highlightedSeatIds: step.focusSeatIds.isEmpty
        ? (source.highlightedSeatIds.isEmpty
              ? anchorSeatIds
              : source.highlightedSeatIds)
        : step.focusSeatIds,
    highlightedCardIds: step.focusCardIds.isEmpty
        ? (source.highlightedCardIds.isEmpty
              ? anchorCardIds
              : source.highlightedCardIds)
        : step.focusCardIds,
  );
}

List<String> _instructionAnchorSeatIds(Act0TableStateV1 table) {
  switch (table.instructionAnchor) {
    case 'hero':
      final heroSeatId = table.heroSeatId ?? table.heroSeat.seatId;
      return <String>[heroSeatId];
    default:
      return const <String>[];
  }
}

List<String> _instructionAnchorCardIds(Act0TableStateV1 table) {
  switch (table.instructionAnchor) {
    case 'cards':
      return List<String>.generate(
        table.heroCards.length,
        (index) => 'hero_$index',
      );
    case 'board':
      return List<String>.generate(
        table.boardCards.length,
        (index) => 'board_$index',
      );
    default:
      return const <String>[];
  }
}

Act0TableStateV1 act0RepairTableForRunnerV1(
  Act0TableStateV1 base,
  Act0RunnerOptionV1? option,
) {
  if (option == null) {
    return base;
  }
  return base.copyWith(
    highlightedSeatIds: option.repairFocusSeatIds.isEmpty
        ? base.highlightedSeatIds
        : option.repairFocusSeatIds,
    highlightedCardIds: option.repairFocusCardIds.isEmpty
        ? base.highlightedCardIds
        : option.repairFocusCardIds,
  );
}

// Share the final rendered projection with source guards. No grading is derived.
Act0TableStateV1 act0FeedbackTableForRunnerV1({
  required Act0RunnerStateV1 runner,
  required Act0TaskFamilyV1? taskFamily,
}) {
  final base = act0RepairTableForRunnerV1(runner.table, runner.selectedOption);
  final proof = _feedbackSignalProofForRunnerV1(
    runner: runner,
    option: runner.selectedOption,
    taskFamily: taskFamily,
    hasSeatTargets: runner.options.any((o) => o.seatId != null),
  );
  return proof == null ? base : _tableWithFeedbackSignalProofV1(base, proof);
}

Act0FeedbackSignalProofV1? _feedbackSignalProofForRunnerV1({
  required Act0RunnerStateV1 runner,
  required Act0RunnerOptionV1? option,
  required Act0TaskFamilyV1? taskFamily,
  required bool hasSeatTargets,
}) {
  final table = runner.table;
  // An admitted conceptual answer uses its stated premise, never unrelated
  // physical cards or a guessed pot. Unknown/mismatched explicit metadata must
  // not fall back to table heuristics and acquire another kind of proof.
  final explicitSignal = runner.feedbackSignalId?.trim() ?? '';
  if (explicitSignal.isNotEmpty && explicitSignal != 'players_behind') {
    switch (explicitSignal) {
      case 'position_action_order':
        // One authored context recap. Never infer this concept from a seat,
        // unrelated cards or a price, and never fall through on stale metadata.
        final choices = <String, Act0RunnerOptionV1>{
          for (final candidate in runner.options) candidate.id: candidate,
        };
        final framework = choices['framework'];
        final oneAnswer = choices['one_answer'];
        final omitsCards = choices['seat_blind_only'];
        final hasValidAlternatives =
            choices.length == 2 ||
            (choices.length == 3 &&
                omitsCards != null &&
                omitsCards.label == 'The seat and posted blinds' &&
                !omitsCards.isCorrect &&
                omitsCards.quality == Act0FeedbackQualityV1.wrong &&
                omitsCards.preferredLabel == 'Bucket, seat, frame' &&
                omitsCards.betterAnswerLabel == 'Bucket, seat, frame' &&
                omitsCards.feedbackReason ==
                    'The 1.5 BB blinds are the start of the pot. You also need to know your cards and whether anyone raised before your turn.');
        if (runner.lessonId != 'same_hand_different_seat' ||
            taskFamily != Act0TaskFamilyV1.review ||
            runner.phase == Act0LessonPhaseV1.theory ||
            runner.question != 'What prevents one-hand-one-answer thinking?' ||
            runner.options.length != choices.length ||
            !hasValidAlternatives ||
            framework == null ||
            oneAnswer == null ||
            framework.label != 'Bucket, seat, frame' ||
            !framework.isCorrect ||
            framework.quality != Act0FeedbackQualityV1.correct ||
            framework.preferredLabel != 'Bucket, seat, frame' ||
            framework.betterAnswerLabel != 'Bucket, seat, frame' ||
            framework.feedbackReason !=
                'The reusable preflop read is hand bucket, position, and action frame before choosing.' ||
            oneAnswer.label != 'One answer per hand' ||
            oneAnswer.isCorrect ||
            oneAnswer.quality != Act0FeedbackQualityV1.wrong ||
            oneAnswer.preferredLabel != 'Bucket, seat, frame' ||
            oneAnswer.betterAnswerLabel != 'Bucket, seat, frame' ||
            oneAnswer.feedbackReason !=
                'One hand can change action when position or action frame changes.' ||
            runner.options.any(
              (candidate) =>
                  (candidate.seatId ?? '').trim().isNotEmpty ||
                  candidate.amountLabel.isNotEmpty ||
                  candidate.repairFocusSeatIds.isNotEmpty ||
                  candidate.repairFocusCardIds.isNotEmpty ||
                  candidate.repairFocusLabels.isNotEmpty,
            )) {
          return null;
        }
        // A valid runner cannot lend its proof to an old or forged external
        // choice. Bind the actual selection to its current canonical option.
        final selected = option == null ? null : choices[option.id];
        if (option == null ||
            selected == null ||
            runner.selectedOptionId != selected.id ||
            option.label != selected.label ||
            option.isCorrect != selected.isCorrect ||
            option.quality != selected.quality ||
            option.preferredLabel != selected.preferredLabel ||
            option.betterAnswerLabel != selected.betterAnswerLabel ||
            option.feedbackTitle != selected.feedbackTitle ||
            option.feedbackReason != selected.feedbackReason ||
            option.amountLabel != selected.amountLabel ||
            option.seatId != selected.seatId ||
            option.repairFocusSeatIds.isNotEmpty ||
            option.repairFocusCardIds.isNotEmpty ||
            option.repairFocusLabels.isNotEmpty) {
          return null;
        }
        return _feedbackSignalProofV1(
          signalId: explicitSignal,
          label: 'Bucket, seat, frame',
        );
      case 'range_bucket_shift':
        if (!const {
          'w6_turn_shift_bucket',
          'w6_turn_pressure_shift_transfer',
        }.contains(runner.lessonId)) {
          return null;
        }
        return _feedbackSignalProofV1(
          signalId: explicitSignal,
          label: 'Stated premise: changing fold pressure',
        );
      case 'board_texture_change':
        if (!const {
          'w6_wet_board_repair',
          'w5_turn_texture_shift_transfer',
          'turn_river_changes',
        }.contains(runner.lessonId)) {
          return null;
        }
        return _feedbackSignalProofV1(
          signalId: explicitSignal,
          label: 'Stated premise: a changed turn board',
        );
      case 'asm05_known_holes_ev':
        // Preview uses the parent lesson id, not the individual task id.
        if (runner.lessonId != 'decision_over_outcome') return null;
        return _feedbackSignalProofV1(
          signalId: 'process_over_outcome',
          label: 'Known cards and price; process over outcome',
        );
      case 'process_over_outcome':
        if (!const {
          'w12_bad_call_good_result',
          'w12_checkpoint_process_line',
        }.contains(runner.lessonId)) {
          return null;
        }
        return _feedbackSignalProofV1(
          signalId: explicitSignal,
          label: 'Stated premise: decision process and result',
        );
      default:
        return null;
    }
  }
  final selectedOption = option ?? runner.selectedOption;
  final correctOption = runner.options.cast<Act0RunnerOptionV1?>().firstWhere(
    (candidate) =>
        candidate != null && act0RunnerOptionIsPreferredV1(candidate),
    orElse: () => null,
  );
  final targetOption = selectedOption?.isCorrect == true
      ? selectedOption
      : correctOption;
  // This authored transfer teaches the CO seat order. It inherits repair
  // labels and a price label from its source runner, but those fields are not
  // evidence that the learner answered a price question.
  if (runner.feedbackSignalId == 'players_behind') {
    final heroSeatId = (table.heroSeatId ?? '').trim();
    final seatsBehind = <String>[];
    if (heroSeatId.isNotEmpty) {
      final seatOrder = table.canonicalSeatOrder;
      final heroIndex = seatOrder.indexWhere(
        (seatId) => seatId.toLowerCase() == heroSeatId.toLowerCase(),
      );
      if (heroIndex >= 0) {
        for (var offset = 1; offset < seatOrder.length; offset++) {
          final seatId = seatOrder[(heroIndex + offset) % seatOrder.length]
              .toLowerCase();
          if (table.seats.any(
            (seat) => seat.seatId == seatId && seat.isOccupied && seat.isInHand,
          )) {
            seatsBehind.add(seatId);
          }
        }
      }
    }
    return _feedbackSignalProofV1(
      signalId: 'players_behind',
      label: 'Players behind',
      seatIds: seatsBehind,
    );
  }

  if (selectedOption != null) {
    final repairSeatIds = _trimmedUniqueStringsV1(
      selectedOption.repairFocusSeatIds,
    );
    final repairCardIds = _trimmedUniqueStringsV1(
      selectedOption.repairFocusCardIds,
    );
    final repairLabels = _trimmedUniqueStringsV1(
      selectedOption.repairFocusLabels,
    );
    final repairTableProof = _proofFromTableSignalsV1(
      table: table,
      seatIds: repairSeatIds,
      cardIds: repairCardIds,
      repairLabels: repairLabels,
    );
    if (repairTableProof != null) {
      return repairTableProof;
    }
  }

  final targetSeatId = (targetOption?.seatId ?? '').trim();
  if (targetSeatId.isNotEmpty) {
    return _proofFromSeatSignalV1(table, targetSeatId);
  }

  if (hasSeatTargets) {
    final activeSeatId = (table.activeSeatId ?? '').trim();
    if (activeSeatId.isNotEmpty) {
      return _proofFromSeatSignalV1(table, activeSeatId);
    }
  }

  final tableText =
      '${runner.lessonId} ${runner.lessonTitle} ${runner.caption} '
              '${runner.hint} ${runner.question} ${runner.reviewReason} '
              '${table.centerLabel} ${table.potLabel} ${table.toCallLabel}'
          .toLowerCase();
  final looksLikeTableRead =
      taskFamily == Act0TaskFamilyV1.transfer ||
      tableText.contains('table read') ||
      (tableText.contains('board') && tableText.contains('pot'));
  if (looksLikeTableRead &&
      table.heroCards.isNotEmpty &&
      table.boardCards.isNotEmpty &&
      table.potLabel.trim().isNotEmpty) {
    return _feedbackSignalProofV1(
      signalId: 'hero_cards_board_pot',
      label: 'Hero cards + board + pot',
      cardIds: <String>[
        for (var i = 0; i < table.heroCards.length; i++) 'hero_$i',
        for (var i = 0; i < table.boardCards.length; i++) 'board_$i',
      ],
      statKeys: const <String>['pot'],
    );
  }

  if (table.toCallLabel.trim().isNotEmpty) {
    return _feedbackSignalProofV1(
      signalId: 'pot_to_call',
      label: 'Pot / to call',
      statKeys: const <String>['pot', 'to_call'],
    );
  }

  final centerLabel = table.centerLabel.trim().toLowerCase();
  if (centerLabel.contains('no bet') || centerLabel.contains('check')) {
    return _feedbackSignalProofV1(signalId: 'no_bet_yet', label: 'No bet yet');
  }

  if (table.boardCards.isNotEmpty) {
    return _feedbackSignalProofV1(
      signalId: 'board_cards',
      label: 'Board cards',
      cardIds: <String>[
        for (var i = 0; i < table.boardCards.length; i++) 'board_$i',
      ],
    );
  }

  return null;
}

Act0SkillReceiptV1? _skillReceiptForSignalProofV1({
  required Act0FeedbackSignalProofV1? proof,
  required Act0FeedbackQualityV1 quality,
}) {
  if (proof == null) {
    return null;
  }
  final sourceSignalLabel = proof.label.trim();
  if (sourceSignalLabel.isEmpty) {
    return null;
  }
  final spec = _skillReceiptSpecForSignalIdV1(proof.signalId);
  return Act0SkillReceiptV1(
    skillAtomId: spec.skillAtomId,
    skillLabel: spec.skillLabel,
    sourceSignalId: proof.signalId.trim().isEmpty
        ? _feedbackSignalIdForLabelV1(sourceSignalLabel)
        : proof.signalId.trim(),
    sourceSignalLabel: sourceSignalLabel,
    outcome: switch (quality) {
      Act0FeedbackQualityV1.correct ||
      Act0FeedbackQualityV1.coCorrect ||
      Act0FeedbackQualityV1.acceptable => Act0SkillReceiptOutcomeV1.learned,
      Act0FeedbackQualityV1.wrong => Act0SkillReceiptOutcomeV1.repairStarted,
      Act0FeedbackQualityV1.suboptimal => Act0SkillReceiptOutcomeV1.needsRep,
    },
    nextRepId: spec.nextRepId,
    nextRepLabel: spec.nextRepLabel,
  );
}

Act0SkillReceiptV1? act0FirstValueSkillReceiptForRunnerV1({
  required Act0RunnerStateV1 runner,
  required Act0RunnerOptionV1 option,
  required Act0TaskFamilyV1? taskFamily,
}) {
  final proof = _feedbackSignalProofForRunnerV1(
    runner: runner.copyWith(selectedOptionId: option.id),
    option: option,
    taskFamily: taskFamily,
    hasSeatTargets: runner.options.any((option) => option.seatId != null),
  );
  return _skillReceiptForSignalProofV1(proof: proof, quality: option.quality);
}

({String skillAtomId, String skillLabel, String nextRepId, String nextRepLabel})
_skillReceiptSpecForSignalIdV1(String signalId) {
  return switch (signalId.trim()) {
    'position_action_order' => (
      skillAtomId: 'position_action_order',
      skillLabel: 'Preflop context read',
      nextRepId: 'repeat_position_action_order',
      nextRepLabel: 'recheck the same context framework',
    ),
    'range_bucket_shift' => (
      skillAtomId: 'range_bucket_reasoning',
      skillLabel: 'Range bucket reasoning',
      nextRepId: 'repeat_range_bucket_reasoning',
      nextRepLabel: 'use this reasoning in another example',
    ),
    'board_texture_change' => (
      skillAtomId: 'board_texture_reasoning',
      skillLabel: 'Board-change reasoning',
      nextRepId: 'repeat_board_texture_reasoning',
      nextRepLabel: 'use this reasoning in another example',
    ),
    'process_over_outcome' => (
      skillAtomId: 'mindset_process_discipline',
      skillLabel: 'Process over outcome',
      nextRepId: 'repeat_mindset_process_discipline',
      nextRepLabel: 'use this reasoning in another example',
    ),
    'hero_button' => (
      skillAtomId: 'table_position_read',
      skillLabel: 'Table position read',
      nextRepId: 'repeat_table_position_read',
      nextRepLabel: 'use the same position read once more',
    ),
    'players_behind' => (
      skillAtomId: 'table_position_read',
      skillLabel: 'Table position read',
      nextRepId: 'repeat_table_position_read',
      nextRepLabel: 'use the same position read once more',
    ),
    'hero_cards' => (
      skillAtomId: 'starting_hand_read',
      skillLabel: 'Starting hand read',
      nextRepId: 'repeat_starting_hand_read',
      nextRepLabel: 'use the same hand read once more',
    ),
    'board_cards' => (
      skillAtomId: 'board_read',
      skillLabel: 'Board read',
      nextRepId: 'repeat_board_read',
      nextRepLabel: 'use the same board read once more',
    ),
    'no_bet_yet' => (
      skillAtomId: 'action_read',
      skillLabel: 'Action read',
      nextRepId: 'repeat_action_read',
      nextRepLabel: 'use the same action read once more',
    ),
    'pot_to_call' => (
      skillAtomId: 'price_read',
      skillLabel: 'Price read',
      nextRepId: 'repeat_price_read',
      nextRepLabel: 'use the same price read once more',
    ),
    _ => (
      skillAtomId: 'table_read',
      skillLabel: 'Table read',
      nextRepId: 'repeat_table_read',
      nextRepLabel: 'use the same table read once more',
    ),
  };
}

Act0TableStateV1 _tableWithFeedbackSignalProofV1(
  Act0TableStateV1 table,
  Act0FeedbackSignalProofV1 proof,
) {
  return table.copyWith(
    highlightedSeatIds: _trimmedUniqueStringsV1(<String>[
      ...table.highlightedSeatIds,
      ...proof.seatIds,
    ]),
    highlightedCardIds: _trimmedUniqueStringsV1(<String>[
      ...table.highlightedCardIds,
      ...proof.cardIds,
    ]),
  );
}

Act0FeedbackSignalProofV1? _proofFromTableSignalsV1({
  required Act0TableStateV1 table,
  required List<String> seatIds,
  required List<String> cardIds,
  required List<String> repairLabels,
}) {
  final hasHeroCards = cardIds.any((id) => id.startsWith('hero_'));
  final hasBoardCards = cardIds.any((id) => id.startsWith('board_'));
  if (hasHeroCards && hasBoardCards && table.potLabel.trim().isNotEmpty) {
    return _feedbackSignalProofV1(
      signalId: 'hero_cards_board_pot',
      label: 'Hero cards + board + pot',
      seatIds: seatIds,
      cardIds: cardIds,
      statKeys: const <String>['pot'],
    );
  }
  if (seatIds.isNotEmpty) {
    return _proofFromSeatSignalV1(
      table,
      seatIds.first,
      extraSeatIds: seatIds.skip(1),
      cardIds: cardIds,
    );
  }
  if (hasHeroCards) {
    return _feedbackSignalProofV1(
      signalId: 'hero_cards',
      label: 'Hero cards',
      cardIds: cardIds,
    );
  }
  if (hasBoardCards) {
    return _feedbackSignalProofV1(
      signalId: 'board_cards',
      label: 'Board cards',
      cardIds: cardIds,
    );
  }
  final repairLabel = repairLabels.isEmpty
      ? ''
      : _feedbackSignalLabelFromRepairLabelV1(repairLabels.first);
  if (repairLabel.isEmpty) {
    return null;
  }
  return _feedbackSignalProofV1(
    signalId: _feedbackSignalIdForLabelV1(repairLabel),
    label: repairLabel,
  );
}

Act0FeedbackSignalProofV1? _proofFromSeatSignalV1(
  Act0TableStateV1 table,
  String seatId, {
  Iterable<String> extraSeatIds = const <String>[],
  List<String> cardIds = const <String>[],
}) {
  final cleanSeatId = seatId.trim();
  if (cleanSeatId.isEmpty) {
    return null;
  }
  final label = _feedbackSeatSignalLabelV1(table, cleanSeatId);
  if (label.isEmpty) {
    return null;
  }
  return _feedbackSignalProofV1(
    signalId: _feedbackSignalIdForLabelV1(label),
    label: label,
    seatIds: _trimmedUniqueStringsV1(<String>[cleanSeatId, ...extraSeatIds]),
    cardIds: cardIds,
  );
}

Act0FeedbackSignalProofV1 _feedbackSignalProofV1({
  required String signalId,
  required String label,
  List<String> seatIds = const <String>[],
  List<String> cardIds = const <String>[],
  List<String> statKeys = const <String>[],
}) {
  final cleanLabel = label.trim();
  return Act0FeedbackSignalProofV1(
    signalId: signalId.trim().isEmpty
        ? _feedbackSignalIdForLabelV1(cleanLabel)
        : signalId.trim(),
    label: cleanLabel,
    proofLine: 'Signal: $cleanLabel',
    seatIds: _trimmedUniqueStringsV1(seatIds),
    cardIds: _trimmedUniqueStringsV1(cardIds),
    statKeys: _trimmedUniqueStringsV1(statKeys),
  );
}

String _feedbackSeatSignalLabelV1(Act0TableStateV1 table, String seatId) {
  final seat = table.seats.cast<Act0SeatStateV1?>().firstWhere(
    (candidate) => candidate?.seatId == seatId,
    orElse: () => null,
  );
  if (seat == null) {
    return '';
  }
  if (seat.isHero && seat.isDealerButton) {
    return 'Hero on the Button';
  }
  if (seat.isHero) {
    return 'Hero seat';
  }
  if (seat.isDealerButton) {
    return 'Button';
  }
  if (seat.isSmallBlind) {
    return 'Small Blind';
  }
  if (seat.isBigBlind) {
    return 'Big Blind';
  }
  final displayName = seat.displayName.trim();
  if (displayName.isNotEmpty) {
    return displayName;
  }
  return seat.seatLabel.trim();
}

String _feedbackSignalLabelFromRepairLabelV1(String label) {
  final clean = _premiumSafeFeedbackOptionLabelV1(label.trim());
  final lower = clean.toLowerCase();
  if (lower == 'button' || lower == 'btn') {
    return 'Hero on the Button';
  }
  if (lower.contains('no bet')) {
    return 'No bet yet';
  }
  if (lower.contains('board')) {
    return 'Board cards';
  }
  if (lower.contains('pot') || lower.contains('to call')) {
    return 'Pot / to call';
  }
  return clean;
}

String _feedbackSignalIdForLabelV1(String label) {
  final lower = label.trim().toLowerCase();
  if (lower == 'hero on the button') {
    return 'hero_button';
  }
  if (lower == 'hero cards + board + pot') {
    return 'hero_cards_board_pot';
  }
  if (lower == 'pot / to call') {
    return 'pot_to_call';
  }
  if (lower == 'no bet yet') {
    return 'no_bet_yet';
  }
  if (lower == 'board cards') {
    return 'board_cards';
  }
  if (lower == 'hero cards') {
    return 'hero_cards';
  }
  final slug = lower
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');
  return slug.isEmpty ? 'table_signal' : slug;
}

List<String> _trimmedUniqueStringsV1(Iterable<String> values) {
  final seen = <String>{};
  final result = <String>[];
  for (final value in values) {
    final clean = value.trim();
    if (clean.isEmpty || !seen.add(clean)) {
      continue;
    }
    result.add(clean);
  }
  return result;
}

class _RunnerProgressV1 extends StatelessWidget {
  const _RunnerProgressV1({
    required this.runner,
    required this.onBack,
    required this.showGlossary,
    this.extraPracticeProgress,
  });

  final Act0RunnerStateV1 runner;
  final VoidCallback onBack;
  final bool showGlossary;
  final ({int step, int total})? extraPracticeProgress;

  @override
  Widget build(BuildContext context) {
    final progress = extraPracticeProgress;
    final step = progress?.step ?? runner.beatIndex;
    final total = progress?.total ?? runner.beatCount;
    final russian = act0AcademyLanguageV1(context) == 'ru';
    final label = russian ? 'Шаг $step/$total' : 'Step $step of $total';
    return Row(
      children: [
        SizedBox(
          width: 48,
          height: 48,
          child: IconButton(
            key: const Key('act0_shell_runner_back'),
            tooltip: act0AcademyLanguageV1(context) == 'ru'
                ? '\u041d\u0430\u0437\u0430\u0434'
                : 'Back',
            onPressed: onBack,
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.arrow_back_rounded),
            color: Act0ShellTokensV1.text,
          ),
        ),
        const SizedBox(width: Act0ShellTokensV1.gapMd),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
            child: LinearProgressIndicator(
              minHeight: Act0ShellTokensV1.progressHeight,
              value: step / total,
              backgroundColor: Act0ShellTokensV1.surface3,
              color: Act0ShellTokensV1.primary,
            ),
          ),
        ),
        if (showGlossary) ...[
          const SizedBox(width: Act0ShellTokensV1.gapXs),
          SizedBox(
            width: 44,
            height: 44,
            child: IconButton(
              key: const Key('act0_shell_runner_glossary'),
              tooltip: 'Glossary',
              onPressed: () => showAct0GlossarySheetV1(
                context,
                taskText: act0GlossaryTaskTextV1(runner),
              ),
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.menu_book_rounded, size: 22),
              color: Act0ShellTokensV1.text,
            ),
          ),
          const SizedBox(width: Act0ShellTokensV1.gapXs),
        ] else
          const SizedBox(width: Act0ShellTokensV1.gapMd),
        Text(
          progress == null
              ? label
              : '$label\n${russian ? 'Ещё практика' : 'Extra practice'}',
          textAlign: TextAlign.end,
          style: Act0ShellTokensV1.body.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _SeatTapPromptV1 extends StatelessWidget {
  const _SeatTapPromptV1({
    required this.taskLabel,
    required this.question,
    required this.helperLine,
    required this.options,
    this.onBack,
    this.recallLabel,
    this.onRecall,
    this.fillsAvailableHeight = false,
  });

  final String taskLabel;
  final String question;
  final String helperLine;
  final List<Act0RunnerOptionV1> options;
  final VoidCallback? onBack;
  final String? recallLabel;
  final VoidCallback? onRecall;
  final bool fillsAvailableHeight;

  @override
  Widget build(BuildContext context) {
    final isFirstTableOrientation = question.trim().toLowerCase().contains(
      'you badge',
    );
    return Container(
      key: const Key('act0_shell_seat_tap_prompt'),
      constraints: const BoxConstraints(minHeight: 104),
      padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
      decoration: isFirstTableOrientation
          ? BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  Act0ShellTokensV1.info.withValues(alpha: 0.16),
                  Act0ShellTokensV1.surface2.withValues(alpha: 0.98),
                  Act0ShellTokensV1.surface3.withValues(alpha: 0.94),
                ],
              ),
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusCard),
              border: Border.all(
                color: Act0ShellTokensV1.info.withValues(alpha: 0.42),
              ),
            )
          : Act0ShellTokensV1.surfaceDecoration(
              color: Act0ShellTokensV1.surface2,
            ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (onBack != null) ...[
            _DockBackButtonV1(onPressed: onBack!),
            const SizedBox(width: Act0ShellTokensV1.gapSm),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: fillsAvailableHeight
                  ? MainAxisSize.max
                  : MainAxisSize.min,
              children: [
                if (isFirstTableOrientation)
                  Column(
                    key: const Key('act0_shell_first_table_read_milestone'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        key: const Key('act0_shell_first_table_orientation'),
                        children: [
                          const Icon(
                            Icons.table_restaurant_rounded,
                            size: 14,
                            color: Act0ShellTokensV1.info,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'First table read',
                              key: const Key('act0_shell_seat_tap_task_label'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Act0ShellTokensV1.label.copyWith(
                                color: Act0ShellTokensV1.info,
                                letterSpacing: 0,
                                fontSize: 10.4,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Container(
                        key: const Key(
                          'act0_shell_wave1b_actionability_anchor',
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Act0ShellTokensV1.primary.withValues(
                            alpha: 0.12,
                          ),
                          borderRadius: BorderRadius.circular(
                            Act0ShellTokensV1.radiusPill,
                          ),
                          border: Border.all(
                            color: Act0ShellTokensV1.primary.withValues(
                              alpha: 0.26,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.touch_app_rounded,
                              size: 12,
                              color: Act0ShellTokensV1.primary,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Tap your seat',
                              key: const Key('act0_shell_wave1b_answer_peek'),
                              style: Act0ShellTokensV1.label.copyWith(
                                color: Act0ShellTokensV1.text,
                                fontSize: 10.0,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    taskLabel,
                    key: const Key('act0_shell_seat_tap_task_label'),
                    maxLines: 2,
                    style: Act0ShellTokensV1.label.copyWith(
                      color: Act0ShellTokensV1.info,
                      letterSpacing: 0.12,
                      fontSize: 9.2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                const SizedBox(height: 5),
                if (question.isNotEmpty)
                  Text(
                    question,
                    key: const Key('act0_shell_action_question'),
                    maxLines: 3,
                    style: Act0ShellTokensV1.body.copyWith(
                      color: Act0ShellTokensV1.text,
                      fontSize: 15.8,
                      height: 1.10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                if (fillsAvailableHeight)
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _SeatTapPromptActionV1(
                        isFirstTableOrientation: isFirstTableOrientation,
                        helperLine: helperLine,
                        recallLabel: recallLabel,
                        onRecall: onRecall,
                      ),
                    ),
                  )
                else ...[
                  const SizedBox(height: 5),
                  _SeatTapPromptActionV1(
                    isFirstTableOrientation: isFirstTableOrientation,
                    helperLine: helperLine,
                    recallLabel: recallLabel,
                    onRecall: onRecall,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SeatTapPromptActionV1 extends StatelessWidget {
  const _SeatTapPromptActionV1({
    required this.isFirstTableOrientation,
    required this.helperLine,
    required this.recallLabel,
    required this.onRecall,
  });

  final bool isFirstTableOrientation;
  final String helperLine;
  final String? recallLabel;
  final VoidCallback? onRecall;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isFirstTableOrientation
              ? 'Use the table markers, then tap.'
              : helperLine,
          key: const Key('act0_shell_seat_tap_prompt_text'),
          maxLines: 1,
          overflow: TextOverflow.fade,
          style: Act0ShellTokensV1.muted.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: isFirstTableOrientation ? 10.6 : 12.2,
            height: 1.08,
          ),
        ),
        if (onRecall != null && recallLabel != null) ...[
          const SizedBox(height: 6),
          _TheoryRecallCtaV1(label: recallLabel!, onPressed: onRecall!),
        ],
      ],
    );
  }
}

class _CoachCardV1 extends StatelessWidget {
  const _CoachCardV1({
    required this.prompt,
    required this.hint,
    required this.focusLabels,
    this.compact = false,
    this.refined = false,
  });

  final String prompt;
  final String hint;
  final List<String> focusLabels;
  final bool compact;
  final bool refined;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: EdgeInsets.symmetric(
        horizontal: refined ? 14 : (compact ? 11 : 12),
        vertical: refined ? 6 : (compact ? 8 : 10),
      ),
      decoration: refined
          ? BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Act0ShellTokensV1.surface.withValues(alpha: 0.82),
                  Act0ShellTokensV1.surface.withValues(alpha: 0.62),
                ],
              ),
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1.0,
              ),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            )
          : Act0ShellTokensV1.surfaceDecoration(
              color: Act0ShellTokensV1.surface2,
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            _formatInstructionCopyV1(prompt, allowSingleClauseSplit: true),
            key: const Key('act0_shell_runner_prompt'),
            textAlign: refined ? TextAlign.left : TextAlign.center,
            style: Act0ShellTokensV1.body.copyWith(
              color: Act0ShellTokensV1.text,
              fontSize: compact ? 13 : 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (hint.isNotEmpty) ...[
            const SizedBox(height: Act0ShellTokensV1.gapXs),
            SingleChildScrollView(
              primary: false,
              physics: const ClampingScrollPhysics(),
              child: Text(
                _formatInstructionCopyV1(hint),
                textAlign: refined ? TextAlign.left : TextAlign.center,
                style: Act0ShellTokensV1.muted.copyWith(
                  fontSize: compact ? 11 : 13,
                  color: Act0ShellTokensV1.textDim,
                ),
              ),
            ),
          ],
          if (focusLabels.isNotEmpty) ...[
            const SizedBox(height: Act0ShellTokensV1.gapXs),
            Wrap(
              key: const Key('act0_shell_teaching_focus_labels'),
              alignment: refined ? WrapAlignment.start : WrapAlignment.center,
              spacing: 6,
              runSpacing: 4,
              children: [
                for (final label in focusLabels)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Act0ShellTokensV1.textMuted.withValues(
                        alpha: 0.10,
                      ),
                      borderRadius: BorderRadius.circular(
                        Act0ShellTokensV1.radiusPill,
                      ),
                      border: Border.all(
                        color: Act0ShellTokensV1.textMuted.withValues(
                          alpha: 0.22,
                        ),
                      ),
                    ),
                    child: Text(
                      label,
                      style: Act0ShellTokensV1.label.copyWith(
                        color: Act0ShellTokensV1.textMuted,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );

    return refined
        ? ClipRRect(
            borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: card,
            ),
          )
        : card;
  }
}

String _formatInstructionCopyV1(
  String text, {
  bool allowSingleClauseSplit = false,
}) {
  final normalized = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (normalized.isEmpty) {
    return normalized;
  }

  final sentences = normalized
      .split(RegExp(r'(?<=[.!?])\s+'))
      .where((part) => part.trim().isNotEmpty)
      .toList();

  if (sentences.length >= 3) {
    final midpoint = (sentences.length / 2).ceil();
    return <String>[
      sentences.take(midpoint).join(' '),
      sentences.skip(midpoint).join(' '),
    ].join('\n');
  }

  if (sentences.length == 2) {
    if (normalized.length < 72) {
      return normalized;
    }
    return sentences.join('\n');
  }

  if (!allowSingleClauseSplit || normalized.length < 72) {
    return normalized;
  }

  final breakpoints = <String>[' \u2014 ', ': ', '; ', ', '];
  final middle = normalized.length ~/ 2;

  int? bestIndex;
  int bestDistance = normalized.length;
  for (final marker in breakpoints) {
    var start = 0;
    while (true) {
      final index = normalized.indexOf(marker, start);
      if (index == -1) {
        break;
      }
      final candidate = index + marker.length;
      final distance = (candidate - middle).abs();
      if (candidate > 24 && candidate < normalized.length - 18) {
        if (distance < bestDistance) {
          bestDistance = distance;
          bestIndex = candidate;
        }
      }
      start = index + marker.length;
    }
  }

  if (bestIndex == null) {
    return normalized;
  }

  final first = normalized.substring(0, bestIndex).trimRight();
  final second = normalized.substring(bestIndex).trimLeft();
  return '$first\n$second';
}

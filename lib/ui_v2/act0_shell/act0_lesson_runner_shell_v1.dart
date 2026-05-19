import 'dart:async';

import 'package:flutter/material.dart';
import 'package:poker_solver/poker_solver.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_content_copy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_instruction_content_policy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_runtime_surface_copy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_sharky_presence_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_tokens_v1.dart';

enum Act0ShellTableVisualVariantV1 { classic, refinedDev2 }

enum Act0ProgressMilestoneTierV1 { lesson, world }

enum Act0TheoryPresentationRoleV1 {
  tableReading,
  conceptIntro,
  actionPrep,
  recapCheck,
  denseSynthesis,
}

enum Act0MilestoneCtaKindV1 {
  continueForward,
  replayForPerfect,
  reviewFirst,
  reviewForPerfect,
  backToMap,
}

Act0TheoryPresentationRoleV1 resolveAct0TheoryPresentationRoleV1({
  String? taskId,
  required Act0RunnerStateV1 runner,
  required int teachingStepIndex,
}) {
  final normalizedTaskId =
      (taskId?.trim().isNotEmpty == true ? taskId!.trim() : runner.lessonId)
          .toLowerCase();
  if (normalizedTaskId.endsWith('what_poker_is_theory')) {
    return teachingStepIndex <= 0
        ? Act0TheoryPresentationRoleV1.conceptIntro
        : Act0TheoryPresentationRoleV1.tableReading;
  }
  if (normalizedTaskId.endsWith('your_first_hand_preflop') ||
      normalizedTaskId.endsWith('blinds_theory')) {
    return Act0TheoryPresentationRoleV1.tableReading;
  }
  if (normalizedTaskId.endsWith('seat_order_decision')) {
    return Act0TheoryPresentationRoleV1.denseSynthesis;
  }
  if (normalizedTaskId.endsWith('actions_theory') ||
      normalizedTaskId.endsWith('hand_discipline_buckets_intro') ||
      normalizedTaskId.endsWith('continue_intro') ||
      normalizedTaskId.endsWith('discipline_intro') ||
      normalizedTaskId.endsWith('position_apply_intro')) {
    return Act0TheoryPresentationRoleV1.actionPrep;
  }
  if (normalizedTaskId.endsWith('apply_intro') ||
      normalizedTaskId.endsWith('checkpoint_intro') ||
      normalizedTaskId.endsWith('showdown_theory')) {
    return Act0TheoryPresentationRoleV1.recapCheck;
  }
  if (normalizedTaskId.endsWith('cards_ranks_suits_theory') ||
      normalizedTaskId.endsWith('positions_theory') ||
      normalizedTaskId.endsWith('button_intro') ||
      normalizedTaskId.endsWith('position_checkpoint_intro') ||
      normalizedTaskId.endsWith('hand_rankings_theory')) {
    return Act0TheoryPresentationRoleV1.conceptIntro;
  }
  return Act0TheoryPresentationRoleV1.tableReading;
}

class Act0RunnerCompletionSummaryV1 {
  const Act0RunnerCompletionSummaryV1({
    required this.xpGain,
    required this.startLevel,
    required this.endLevel,
    required this.startXp,
    required this.endXp,
    required this.xpTarget,
    this.skillGains = const <Act0SkillGainV1>[],
  });

  final int xpGain;
  final int startLevel;
  final int endLevel;
  final int startXp;
  final int endXp;
  final int xpTarget;
  final List<Act0SkillGainV1> skillGains;

  bool get leveledUp => endLevel > startLevel;

  String get toastRewardLabel => leveledUp ? 'Level up' : 'Clean rep';

  String get growthLabel => _formatSkillGrowthLabelV1(skillGains);
}

class Act0BlockCompletionSummaryV1 {
  const Act0BlockCompletionSummaryV1({
    required this.lessonTitle,
    required this.xpEarned,
    required this.errorCount,
    required this.taskCount,
    required this.correctCount,
    required this.startLevel,
    required this.endLevel,
    required this.startXp,
    required this.endXp,
    required this.xpTarget,
    this.sharkyLine = '',
    this.nextLessonTitle,
    this.quickFixCount = 0,
    this.deepLeakCount = 0,
    this.skillGains = const <Act0SkillGainV1>[],
    this.milestoneTier = Act0ProgressMilestoneTierV1.lesson,
    this.worldNumber = 0,
    this.worldTitle = '',
    this.nextWorldNumber,
    this.nextWorldTitle,
    this.perfectClearCount = 0,
    this.completedClearCount = 0,
    this.hasSafeReviewTarget = false,
    this.hasReplayForPerfectTarget = false,
  });

  static const int unlockAccuracyPercent = 80;

  final String lessonTitle;
  final int xpEarned;
  final int errorCount;
  final int taskCount;
  final int correctCount;
  final int startLevel;
  final int endLevel;
  final int startXp;
  final int endXp;
  final int xpTarget;
  final String sharkyLine;
  final String? nextLessonTitle;
  final int quickFixCount;
  final int deepLeakCount;
  final List<Act0SkillGainV1> skillGains;
  final Act0ProgressMilestoneTierV1 milestoneTier;
  final int worldNumber;
  final String worldTitle;
  final int? nextWorldNumber;
  final String? nextWorldTitle;
  final int perfectClearCount;
  final int completedClearCount;
  final bool hasSafeReviewTarget;
  final bool hasReplayForPerfectTarget;

  bool get hasNextLesson =>
      nextLessonTitle != null && nextLessonTitle!.isNotEmpty;

  bool get isWorldComplete =>
      milestoneTier == Act0ProgressMilestoneTierV1.world &&
      worldNumber > 0 &&
      worldTitle.trim().isNotEmpty;

  bool get hasPerfectGap =>
      completedClearCount > 0 && perfectClearCount < completedClearCount;

  bool get hasForwardPath =>
      hasNextLesson ||
      (isWorldComplete &&
          nextWorldTitle != null &&
          nextWorldTitle!.trim().isNotEmpty);

  bool get leveledUp => endLevel > startLevel;

  int get accuracyPercent =>
      taskCount <= 0 ? 100 : ((correctCount * 100) / taskCount).round();

  bool get qualifiesForNextLesson =>
      !hasNextLesson || accuracyPercent >= unlockAccuracyPercent;

  Act0MasteryStatusV1 get masteryStatus {
    if (errorCount == 0 && taskCount > 0) {
      return Act0MasteryStatusV1.cleanPass;
    }
    if (deepLeakCount > 0 || !qualifiesForNextLesson) {
      return Act0MasteryStatusV1.needsReview;
    }
    return Act0MasteryStatusV1.solid;
  }

  String get masteryLabel => switch (masteryStatus) {
    Act0MasteryStatusV1.cleanPass => 'Clean pass',
    Act0MasteryStatusV1.solid => 'Solid',
    Act0MasteryStatusV1.needsReview => 'Needs review',
    Act0MasteryStatusV1.learning => 'Learning',
  };

  String get milestoneTitle =>
      isWorldComplete ? 'World $worldNumber complete' : 'Lesson complete';

  String get milestoneDetailTitle => isWorldComplete ? worldTitle : lessonTitle;

  String? get unlockedLabel {
    if (isWorldComplete) {
      if (nextWorldTitle == null ||
          nextWorldTitle!.trim().isEmpty ||
          nextWorldNumber == null ||
          nextWorldNumber! <= 0) {
        return null;
      }
      return 'Unlocked now: World $nextWorldNumber - $nextWorldTitle';
    }
    if (!hasNextLesson) {
      return null;
    }
    return 'Unlocked now: $nextLessonTitle';
  }

  String get progressStatusLabel {
    if (deepLeakCount > 0) {
      return 'Review open';
    }
    if (completedClearCount > 0 && perfectClearCount == completedClearCount) {
      return 'Perfect path';
    }
    if (perfectClearCount > 0 && completedClearCount > 0) {
      return '$perfectClearCount/$completedClearCount clean tasks';
    }
    if (quickFixCount > 0) {
      return 'Repairs recovered';
    }
    return masteryLabel;
  }

  bool get shouldReviewFirst =>
      deepLeakCount > 0 && qualifiesForNextLesson && hasSafeReviewTarget;

  bool get shouldOfferReplayForPerfect =>
      hasPerfectGap &&
      hasReplayForPerfectTarget &&
      !hasSafeReviewTarget &&
      !shouldReviewFirst;

  bool get shouldOfferReviewForPerfect =>
      hasPerfectGap &&
      hasSafeReviewTarget &&
      !shouldReviewFirst &&
      deepLeakCount == 0;

  Act0MilestoneCtaKindV1 get primaryCtaKind {
    if (!qualifiesForNextLesson) {
      return Act0MilestoneCtaKindV1.replayForPerfect;
    }
    if (shouldReviewFirst) {
      return Act0MilestoneCtaKindV1.reviewFirst;
    }
    if (hasForwardPath) {
      return Act0MilestoneCtaKindV1.continueForward;
    }
    return Act0MilestoneCtaKindV1.backToMap;
  }

  Act0MilestoneCtaKindV1? get secondaryCtaKind {
    if (!qualifiesForNextLesson) {
      return null;
    }
    if (shouldReviewFirst) {
      return hasForwardPath ? Act0MilestoneCtaKindV1.continueForward : null;
    }
    if (shouldOfferReplayForPerfect) {
      return Act0MilestoneCtaKindV1.replayForPerfect;
    }
    if (shouldOfferReviewForPerfect) {
      return Act0MilestoneCtaKindV1.reviewForPerfect;
    }
    return null;
  }

  String get progressionCtaLabel {
    if (isWorldComplete &&
        nextWorldTitle != null &&
        nextWorldTitle!.trim().isNotEmpty) {
      return 'Open next world';
    }
    if (hasNextLesson) {
      return 'Open next lesson';
    }
    return 'Back to map';
  }

  String get suggestedNextAction {
    if (deepLeakCount > 0) {
      return 'Go to Review and fix the deep leak.';
    }
    if (masteryStatus == Act0MasteryStatusV1.needsReview) {
      return 'Replay this block before moving on.';
    }
    if (quickFixCount > 0) {
      return hasNextLesson
          ? 'Continue now, then check quick fixes in Review.'
          : isWorldComplete &&
                nextWorldTitle != null &&
                nextWorldTitle!.isNotEmpty
          ? 'Continue into $nextWorldTitle, then check quick fixes in Review.'
          : 'Check your quick fixes in Review.';
    }
    if (hasNextLesson) {
      return 'Continue to ${nextLessonTitle!}.';
    }
    if (isWorldComplete &&
        nextWorldTitle != null &&
        nextWorldTitle!.isNotEmpty) {
      return 'Continue to $nextWorldTitle.';
    }
    return 'All lessons done. Head to Review to track your progress.';
  }

  String get primaryCtaLabel {
    return switch (primaryCtaKind) {
      Act0MilestoneCtaKindV1.continueForward => progressionCtaLabel,
      Act0MilestoneCtaKindV1.replayForPerfect =>
        hasForwardPath ? 'Replay before next lesson' : 'Replay this block',
      Act0MilestoneCtaKindV1.reviewFirst => 'Review first',
      Act0MilestoneCtaKindV1.reviewForPerfect => 'Review for perfect',
      Act0MilestoneCtaKindV1.backToMap => 'Back to map',
    };
  }

  String? get secondaryCtaLabel => switch (secondaryCtaKind) {
    Act0MilestoneCtaKindV1.continueForward => progressionCtaLabel,
    Act0MilestoneCtaKindV1.replayForPerfect => 'Replay for perfect',
    Act0MilestoneCtaKindV1.reviewFirst => 'Review first',
    Act0MilestoneCtaKindV1.reviewForPerfect => 'Review for perfect',
    Act0MilestoneCtaKindV1.backToMap => 'Back to map',
    null => null,
  };

  String get habitRewardLabel {
    if (deepLeakCount > 0) {
      return 'Repair flagged';
    }
    if (quickFixCount > 0) {
      return 'Miss recovered';
    }
    if (errorCount == 0 && taskCount > 0) {
      return 'Clean read';
    }
    if (qualifiesForNextLesson) {
      return 'Route held';
    }
    return 'Replay ready';
  }

  String get habitRewardDetail {
    if (deepLeakCount > 0) {
      return 'A real weak spot was caught. Fixing it now keeps tomorrow from feeling heavier.';
    }
    if (quickFixCount > 0) {
      return 'You corrected the miss inside the lesson. That recovery keeps tomorrow\'s seat intact.';
    }
    if (errorCount == 0 && taskCount > 0) {
      return 'No repairs needed. Clean work like this makes tomorrow\'s first rep lighter.';
    }
    if (qualifiesForNextLesson) {
      return 'The block counts. One short clean return tomorrow is enough.';
    }
    return 'Replay is the right move before adding new material. Clean it once and the route will feel lighter again.';
  }

  String get gateMessage {
    if (deepLeakCount > 0 && qualifiesForNextLesson) {
      if (isWorldComplete &&
          nextWorldTitle != null &&
          nextWorldTitle!.isNotEmpty) {
        return 'Deep leak saved for Review. $nextWorldTitle is unlocked, but repair should be next.';
      }
      return hasNextLesson
          ? 'Deep leak saved for Review. ${nextLessonTitle!} is unlocked, but repair should be next.'
          : 'Deep leak saved for Review. Clean it up before moving on.';
    }
    if (isWorldComplete) {
      if (nextWorldTitle != null && nextWorldTitle!.isNotEmpty) {
        return 'Strong finish. $nextWorldTitle is unlocked.';
      }
      return 'Strong finish. You completed this world.';
    }
    return qualifiesForNextLesson
        ? hasNextLesson
              ? 'Strong read. ${nextLessonTitle!} is unlocked.'
              : 'Clean finish. You completed all lessons.'
        : 'Need $unlockAccuracyPercent% accuracy to unlock ${nextLessonTitle!}. Replay this block and tighten up the mistakes.';
  }

  String get growthLabel => _formatSkillGrowthLabelV1(skillGains);
}

String _formatSkillGrowthLabelV1(List<Act0SkillGainV1> gains) {
  if (gains.isEmpty) {
    return '';
  }
  final sorted = gains.toList()
    ..sort((a, b) {
      final gainCompare = b.gain.compareTo(a.gain);
      if (gainCompare != 0) {
        return gainCompare;
      }
      return a.label.compareTo(b.label);
    });
  return sorted
      .take(2)
      .map((gain) => '${gain.label} +${gain.gain}')
      .join('  •  ');
}

// ── Pure pot-calculation helpers (top-level so they are unit-testable) ────────

/// Parses a BB amount string like "2.5 BB", "0.5 BB", "3BB" → double.
/// Returns 0.0 if unrecognised.
double act0ParseBbAmountV1(String s) {
  final m = RegExp(r'(\d+(?:\.\d+)?)\s*BB', caseSensitive: false).firstMatch(s);
  if (m == null) return 0.0;
  return double.tryParse(m.group(1)!) ?? 0.0;
}

/// Extracts the actor token (e.g. "BTN", "SB") from a stripped trail label.
/// Returns null when the label has no identifiable actor or no bet amount.
String? _act0TrailActor(String stripped) {
  final m = RegExp(
    r'^(\w+)\s+(?:blind|raises?|opens?|opened|calls?|called|bets?|all[- ]?in|goes\s+all)',
    caseSensitive: false,
  ).firstMatch(stripped);
  return m?.group(1)?.toUpperCase();
}

/// Calculates the running pot (in BB) by replaying [labels][0..upToIndex].
///
/// Returns `(potBb: -1.0, street: '')` when the trail does not start from
/// preflop blinds, so the caller can fall back to a static pot label.
///
/// Algorithm (per street):
///   – Each player's contribution is the **maximum** amount they put in
///     during that street (raise or call to X BB).
///   – On street transition the per-street map is flushed into [runningPot].
({double potBb, String street}) act0CalcTrailPotV1(
  List<String> labels,
  int upToIndex,
) {
  if (labels.isEmpty) return (potBb: -1.0, street: '');

  final firstLower = labels[0].toLowerCase();
  // In a valid cash-game trail the *first* entry must be the small blind post.
  // A trail starting with BB only (or any other action) is incomplete — fall
  // back to the static potLabel so we never display a wrong pot.
  if (!firstLower.contains('sb blind')) {
    return (potBb: -1.0, street: '');
  }

  double runningPot = 0.0;
  final streetContribs = <String, double>{};
  String currentStreet = 'Preflop';

  for (int i = 0; i <= upToIndex && i < labels.length; i++) {
    final raw = labels[i];

    // Detect street transition: both "Flop: action" and bare "Flop dealt" forms.
    String? newStreet;
    if (RegExp(r'^flop[:\s]', caseSensitive: false).hasMatch(raw)) {
      newStreet = 'Flop';
    } else if (RegExp(r'^turn[:\s]', caseSensitive: false).hasMatch(raw)) {
      newStreet = 'Turn';
    } else if (RegExp(r'^river[:\s]', caseSensitive: false).hasMatch(raw)) {
      newStreet = 'River';
    }
    if (newStreet != null && newStreet != currentStreet) {
      runningPot += streetContribs.values.fold(0.0, (acc, v) => acc + v);
      streetContribs.clear();
      currentStreet = newStreet;
    }

    final stripped = raw.replaceFirst(
      RegExp(r'^(Flop|Turn|River):\s*', caseSensitive: false),
      '',
    );
    final actor = _act0TrailActor(stripped);
    if (actor == null) continue;
    final amount = act0ParseBbAmountV1(stripped);
    if (amount <= 0) continue;
    final existing = streetContribs[actor] ?? 0.0;
    if (amount > existing) streetContribs[actor] = amount;
  }

  final totalPot =
      runningPot + streetContribs.values.fold(0.0, (acc, v) => acc + v);
  return (potBb: totalPot, street: currentStreet);
}

/// Formats a pot double as a readable label: 6.5 → "Pot 6.5 BB", 7.0 → "Pot 7 BB".
String act0FormatPotLabelV1(double bb) {
  final rounded = (bb * 2).round() / 2; // nearest 0.5 BB
  final isWhole = rounded == rounded.truncateToDouble();
  return 'Pot ${isWhole ? rounded.toInt() : rounded} BB';
}

// ─────────────────────────────────────────────────────────────────────────────

class Act0LessonRunnerShellV1 extends StatefulWidget {
  const Act0LessonRunnerShellV1({
    super.key,
    required this.runner,
    this.selectedTaskId,
    this.selectedTaskFamily,
    this.theoryRecallStep,
    required this.onBack,
    required this.onContinueTheory,
    this.onPreviousTheory,
    this.onUndoInteraction,
    required this.onChooseOption,
    this.onSelectSizingPreset,
    this.onConfirmSizingPreset,
    this.onChooseSeat,
    required this.onContinueReview,
    this.completionSummary,
    this.tableVisualVariant = Act0ShellTableVisualVariantV1.refinedDev2,
    this.relaxTheoryAdvanceLock = false,
    this.showLearningRailFocusLabels = false,
    this.rapidReviewMode = false,
  });

  final Act0RunnerStateV1 runner;
  final String? selectedTaskId;
  final Act0TaskFamilyV1? selectedTaskFamily;
  final Act0TeachingStepV1? theoryRecallStep;
  final VoidCallback onBack;
  final VoidCallback onContinueTheory;
  final VoidCallback? onPreviousTheory;
  final VoidCallback? onUndoInteraction;
  final ValueChanged<Act0RunnerOptionV1> onChooseOption;
  final ValueChanged<Act0SizingPresetV1>? onSelectSizingPreset;
  final VoidCallback? onConfirmSizingPreset;
  final ValueChanged<String>? onChooseSeat;
  final VoidCallback onContinueReview;
  final Act0RunnerCompletionSummaryV1? completionSummary;
  final Act0ShellTableVisualVariantV1 tableVisualVariant;
  final bool relaxTheoryAdvanceLock;
  final bool showLearningRailFocusLabels;
  final bool rapidReviewMode;

  @override
  State<Act0LessonRunnerShellV1> createState() =>
      _Act0LessonRunnerShellV1State();
}

class _Act0LessonRunnerShellV1State extends State<Act0LessonRunnerShellV1> {
  static const Duration _theoryAdvanceLockDuration = Duration(
    milliseconds: 820,
  );
  static const Duration _replayAdvanceLockDuration = Duration(
    milliseconds: 280,
  );

  Timer? _theoryUnlockTimer;
  Timer? _rapidReviewTimer;
  bool _canAdvanceTheory = true;
  String _advanceLockKey = '';
  String _rapidReviewKey = '';
  String _showdownInteractionKey = '';
  List<String> _interactiveHighlightedCardIds = const <String>[];
  String _interactiveShowdownLine = '';
  int? _actionTrailFocusedIndex;
  int _learningRailSupportSegmentIndex = 0;
  String _learningRailSupportStepKey = '';

  @override
  void initState() {
    super.initState();
    _syncTheoryAdvanceLock(initial: true);
    _syncRapidReviewAdvance();
  }

  @override
  void didUpdateWidget(covariant Act0LessonRunnerShellV1 oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncTheoryAdvanceLock();
    _syncLearningRailSupportSegment();
    _syncRapidReviewAdvance();
    final nextKey = _interactionKey(widget.runner);
    if (_showdownInteractionKey != nextKey) {
      _actionTrailFocusedIndex = null;
      _showdownInteractionKey = nextKey;
      _interactiveHighlightedCardIds = const <String>[];
      _interactiveShowdownLine = '';
    }
  }

  @override
  void dispose() {
    _theoryUnlockTimer?.cancel();
    _rapidReviewTimer?.cancel();
    super.dispose();
  }

  void _syncRapidReviewAdvance() {
    final shouldAutoAdvance =
        widget.rapidReviewMode &&
        _isReview &&
        widget.runner.selectedOptionId != null;
    if (!shouldAutoAdvance) {
      _rapidReviewTimer?.cancel();
      _rapidReviewKey = '';
      return;
    }
    final nextKey = _interactionKey(widget.runner);
    if (_rapidReviewKey == nextKey) {
      return;
    }
    _rapidReviewTimer?.cancel();
    _rapidReviewKey = nextKey;
    _rapidReviewTimer = Timer(const Duration(milliseconds: 650), () {
      if (!mounted) {
        return;
      }
      widget.onContinueReview();
    });
  }

  void _syncLearningRailSupportSegment() {
    final nextKey =
        '${widget.runner.lessonId}|${widget.runner.beatIndex}|'
        '${widget.runner.phase.name}|${widget.runner.teachingStepIndex}';
    if (_learningRailSupportStepKey == nextKey) {
      return;
    }
    _learningRailSupportStepKey = nextKey;
    _learningRailSupportSegmentIndex = 0;
  }

  bool get _isRefinedDev2 =>
      widget.tableVisualVariant == Act0ShellTableVisualVariantV1.refinedDev2;

  bool get _isTheory => widget.runner.phase == Act0LessonPhaseV1.theory;

  bool get _isReview => widget.runner.phase == Act0LessonPhaseV1.review;

  Act0TeachingStepV1? get _teachingStep => widget.runner.activeTeachingStep;

  bool get _isTeaching =>
      _teachingStep != null &&
      widget.runner.selectedOptionId == null &&
      widget.runner.phase != Act0LessonPhaseV1.review;

  bool get _showBottomLearningRail =>
      _isRefinedDev2 && (_isTheory || _isTeaching);

  String _interactionKey(Act0RunnerStateV1 runner) {
    return '${runner.lessonId}|${runner.beatIndex}|${runner.phase.name}|${runner.teachingStepIndex}|${runner.selectedOptionId ?? ''}';
  }

  bool _allowsInteractiveShowdown(Act0RunnerStateV1 runner) {
    final id = runner.lessonId.toLowerCase();
    return id.contains('showdown') ||
        id.contains('flush') ||
        id.contains('straight') ||
        id.contains('rank') ||
        id.contains('kicker') ||
        id.contains('best_five');
  }

  void _onBoardTappedForShowdown(Act0TableStateV1 table) {
    if (!_allowsInteractiveShowdown(widget.runner)) {
      return;
    }
    final insight = _computeShowdownInsight(table);
    if (insight == null) {
      setState(() {
        _interactiveHighlightedCardIds = const <String>[];
        _interactiveShowdownLine = '';
      });
      return;
    }
    setState(() {
      _interactiveHighlightedCardIds = insight.highlightedCardIds;
      _interactiveShowdownLine = insight.summaryLine;
    });
  }

  String? _activeSeatIdFromActionTrail(
    Act0TableStateV1 table,
    int? focusedIndex,
  ) {
    if (focusedIndex == null || table.actionTrail.isEmpty) {
      return null;
    }
    final index = focusedIndex.clamp(0, table.actionTrail.length - 1);
    final label = table.actionTrail[index].label;
    final match = RegExp(
      r'\b(UTG|HJ|CO|BTN|SB|BB|HERO)\b',
      caseSensitive: false,
    ).firstMatch(label);
    if (match == null) {
      return null;
    }
    final token = (match.group(1) ?? '').trim().toUpperCase();
    if (token == 'HERO') {
      return table.heroSeatId ?? table.heroSeat.seatId;
    }
    for (final seat in table.seats) {
      if (seat.seatLabel.trim().toUpperCase() == token) {
        return seat.seatId;
      }
    }
    return null;
  }

  Act0SeatBetStateV1? _deriveBetFromTrailStep(
    Act0TableStateV1 table,
    int? focusedIndex,
  ) {
    if (focusedIndex == null || table.actionTrail.isEmpty) {
      return null;
    }
    final index = focusedIndex.clamp(0, table.actionTrail.length - 1);
    final raw = table.actionTrail[index].label.trim();
    // Strip street prefix: "Flop: BB checks" → "BB checks"
    final stripped = raw.replaceFirst(
      RegExp(r'^(Flop|Turn|River):\s*', caseSensitive: false),
      '',
    );

    // Blind post: "SB blind 0.5 BB" / "BB blind 1 BB"
    final blindMatch = RegExp(
      r'^(SB|BB)\s+blind\s+(.+)$',
      caseSensitive: false,
    ).firstMatch(stripped);
    if (blindMatch != null) {
      return Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.post,
        label: blindMatch.group(1)!.toUpperCase(),
        amountLabel: blindMatch.group(2)!.trim(),
      );
    }

    // Raise: "BTN raises" / "BTN raises 2.5 BB" / "BTN opens 2.5 BB" / "BTN opened" / "CO opens"
    final raiseMatch = RegExp(
      r'^(\w+)\s+(raises?|opens?|opened)\s*(.*)?$',
      caseSensitive: false,
    ).firstMatch(stripped);
    if (raiseMatch != null) {
      final seat = raiseMatch.group(1)!.toUpperCase();
      final amt = (raiseMatch.group(3) ?? '').trim();
      return Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.raise,
        label: seat,
        amountLabel: amt.isNotEmpty ? amt : 'raise',
      );
    }

    // Call: "BB calls" / "BB calls 2.5 BB" / "BB called"
    final callMatch = RegExp(
      r'^(\w+)\s+(calls?|called)\s*(.*)?$',
      caseSensitive: false,
    ).firstMatch(stripped);
    if (callMatch != null) {
      final seat = callMatch.group(1)!.toUpperCase();
      final amt = (callMatch.group(3) ?? '').trim();
      return Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.call,
        label: seat,
        amountLabel: amt.isNotEmpty ? amt : 'call',
      );
    }

    // Bet: "BTN bets 2 BB" / "BTN bet 2 BB"
    final betMatch = RegExp(
      r'^(\w+)\s+bets?\s*(.*)?$',
      caseSensitive: false,
    ).firstMatch(stripped);
    if (betMatch != null) {
      final seat = betMatch.group(1)!.toUpperCase();
      final amt = (betMatch.group(2) ?? '').trim();
      return Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.bet,
        label: seat,
        amountLabel: amt.isNotEmpty ? amt : 'bet',
      );
    }

    // All-in: "BTN all-in" / "UTG goes all in"
    final allInMatch = RegExp(
      r'^(\w+)\s+(all[- ]?in|goes all)',
      caseSensitive: false,
    ).firstMatch(stripped);
    if (allInMatch != null) {
      return Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.allIn,
        label: allInMatch.group(1)!.toUpperCase(),
        amountLabel: 'all-in',
      );
    }

    // Folds / checks → no chip
    return null;
  }

  // ── Pot calculation ─────────────────────────────────────────────────────────

  /// Calculates the running pot by replaying the trail up to [upToIndex].
  /// Delegates to top-level [act0CalcTrailPotV1].
  ({double potBb, String street}) _calculatePotAtTrailIndex(
    Act0TableStateV1 table,
    int upToIndex,
  ) {
    final labels = table.actionTrail
        .map((item) => item.label)
        .toList(growable: false);
    return act0CalcTrailPotV1(labels, upToIndex);
  }

  /// Delegates to top-level [act0FormatPotLabelV1].
  String _formatPotLabel(double bb) => act0FormatPotLabelV1(bb);

  // ─────────────────────────────────────────────────────────────────────────

  _Act0ShowdownInsightV1? _computeShowdownInsight(Act0TableStateV1 table) {
    if (table.boardCards.length < 5) {
      return null;
    }
    final board = <String>[];
    final boardByCard = <String, List<String>>{};
    for (var i = 0; i < table.boardCards.length && i < 5; i++) {
      final solver = _toSolverCard(table.boardCards[i]);
      if (solver == null) {
        return null;
      }
      board.add(solver);
      boardByCard.putIfAbsent(solver, () => <String>[]).add('board_$i');
    }

    final participants = <_Act0ShowdownParticipantV1>[];
    final heroCards = <String>[];
    final heroByCard = <String, List<String>>{};
    for (var i = 0; i < table.heroCards.length && i < 2; i++) {
      final solver = _toSolverCard(table.heroCards[i]);
      if (solver == null) {
        continue;
      }
      heroCards.add(solver);
      heroByCard.putIfAbsent(solver, () => <String>[]).add('hero_$i');
    }
    if (heroCards.length >= 2) {
      participants.add(
        _Act0ShowdownParticipantV1(
          seatId: table.heroSeatId ?? table.heroSeat.seatId,
          displayLabel: 'You',
          cards: heroCards,
          cardIdsBySolver: heroByCard,
        ),
      );
    }

    for (final seat in table.seats) {
      if (seat.isHero ||
          seat.holeCards.length < 2 ||
          seat.cardsVisibleMode != Act0CardsVisibleModeV1.faceUp ||
          seat.isFolded ||
          !seat.isInHand) {
        continue;
      }
      final seatCards = <String>[];
      final seatByCard = <String, List<String>>{};
      for (var i = 0; i < seat.holeCards.length && i < 2; i++) {
        final solver = _toSolverCard(seat.holeCards[i]);
        if (solver == null) {
          continue;
        }
        seatCards.add(solver);
        seatByCard
            .putIfAbsent(solver, () => <String>[])
            .add('${seat.seatId}_$i');
      }
      if (seatCards.length >= 2) {
        participants.add(
          _Act0ShowdownParticipantV1(
            seatId: seat.seatId,
            displayLabel: seat.seatLabel,
            cards: seatCards,
            cardIdsBySolver: seatByCard,
          ),
        );
      }
    }

    if (participants.isEmpty) {
      return null;
    }

    final hands = <int, Hand>{};
    for (var i = 0; i < participants.length; i++) {
      hands[i] = Hand.solveHand(<String>[...board, ...participants[i].cards]);
    }
    if (hands.isEmpty) {
      return null;
    }
    final winningHands = Hand.winners(hands.values.toList());
    final winnerIndexes = <int>[
      for (final entry in hands.entries)
        if (winningHands.contains(entry.value)) entry.key,
    ];
    if (winnerIndexes.isEmpty) {
      return null;
    }

    final highlighted = <String>{};
    for (final winnerIndex in winnerIndexes) {
      final winner = participants[winnerIndex];
      final hand = hands[winnerIndex]!;
      for (final card in hand.cards) {
        final cardKey = card.toString();
        highlighted.addAll(boardByCard[cardKey] ?? const <String>[]);
        highlighted.addAll(winner.cardIdsBySolver[cardKey] ?? const <String>[]);
      }
    }

    final leadWinner = winnerIndexes.first;
    final leadHand = hands[leadWinner]!;
    final winnerLabels = winnerIndexes
        .map((index) => participants[index].displayLabel)
        .toList(growable: false);
    final winnerPhrase = winnerLabels.join(' & ');
    final winnerVerb = winnerPhrase == 'You' ? 'win' : 'wins';
    String summary;
    if (winnerIndexes.length > 1) {
      summary = 'Split pot: $winnerPhrase with ${_humanHandName(leadHand)}.';
    } else {
      final loserCandidates = <int>[
        for (final idx in hands.keys)
          if (idx != leadWinner) idx,
      ];
      if (loserCandidates.isNotEmpty) {
        var bestLoser = loserCandidates.first;
        for (final idx in loserCandidates.skip(1)) {
          if (hands[idx]!.compare(hands[bestLoser]!) < 0) {
            bestLoser = idx;
          }
        }
        summary =
            '$winnerPhrase $winnerVerb with ${_humanHandName(leadHand)} over ${_humanHandName(hands[bestLoser]!)}.';
      } else {
        summary = '$winnerPhrase $winnerVerb with ${_humanHandName(leadHand)}.';
      }
    }

    if (highlighted.isEmpty) {
      highlighted.addAll(
        List<String>.generate(board.length, (index) => 'board_$index'),
      );
    }
    return _Act0ShowdownInsightV1(
      highlightedCardIds: highlighted.toList(growable: false),
      summaryLine: summary,
    );
  }

  String _humanHandName(Hand hand) {
    final raw = (hand.descr ?? hand.name).trim();
    if (raw.isEmpty) {
      return 'best hand';
    }
    return '${raw[0].toUpperCase()}${raw.substring(1)}';
  }

  String? _toSolverCard(Act0CardStateV1 card) {
    final rank = _toSolverRank(card.rank);
    final suit = _toSolverSuit(card.suit);
    if (rank == null || suit == null) {
      return null;
    }
    return '$rank$suit';
  }

  String? _toSolverRank(String rank) {
    final normalized = rank.trim().toUpperCase();
    if (normalized == '10') {
      return 'T';
    }
    const allowed = <String>{
      'A',
      'K',
      'Q',
      'J',
      'T',
      '9',
      '8',
      '7',
      '6',
      '5',
      '4',
      '3',
      '2',
    };
    return allowed.contains(normalized) ? normalized : null;
  }

  String? _toSolverSuit(String suit) {
    switch (suit.trim().toLowerCase()) {
      case 's':
      case '♠':
        return 's';
      case 'h':
      case '♥':
        return 'h';
      case 'd':
      case '♦':
        return 'd';
      case 'c':
      case '♣':
        return 'c';
      default:
        return null;
    }
  }

  bool _shouldShowPotSweep(Act0RunnerStateV1 runner) {
    if (runner.phase != Act0LessonPhaseV1.review) {
      return false;
    }
    if (runner.reviewQuality == Act0FeedbackQualityV1.wrong) {
      return false;
    }
    if (runner.table.potLabel.trim().isEmpty) {
      return false;
    }
    final text =
        '${runner.lessonId} ${runner.lessonTitle} ${runner.reviewTitle} ${runner.reviewReason}'
            .toLowerCase();
    return text.contains('showdown') ||
        text.contains('win at showdown') ||
        text.contains('wins the pot') ||
        text.contains('split pot') ||
        text.contains('tie the pot') ||
        text.contains('board plays') ||
        text.contains('which hand wins');
  }

  Duration get _currentTheoryAdvanceLockDuration =>
      widget.relaxTheoryAdvanceLock
      ? _replayAdvanceLockDuration
      : _theoryAdvanceLockDuration;

  String get _currentAdvanceLockKey {
    if (!_showBottomLearningRail) {
      return '';
    }
    return '${widget.runner.lessonId}|${widget.runner.beatIndex}|${widget.runner.phase.name}|${widget.runner.teachingStepIndex}|${widget.runner.selectedOptionId ?? ''}';
  }

  Future<void> _openTheoryRecallSheet() async {
    final step = widget.theoryRecallStep;
    if (step == null) {
      return;
    }
    final bodyBlocks = act0BuildInstructionBlocksV1(
      text: step.body,
      compact: true,
    );
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (context) => _TheoryRecallSheetV1(
        label: act0RuntimeTheoryRecallLabelV1(context),
        title: step.title,
        bodyBlocks: bodyBlocks,
      ),
    );
  }

  void _syncTheoryAdvanceLock({bool initial = false}) {
    _theoryUnlockTimer?.cancel();
    final nextKey = _currentAdvanceLockKey;
    if (nextKey.isEmpty) {
      _advanceLockKey = '';
      if (initial) {
        _canAdvanceTheory = true;
      } else if (!_canAdvanceTheory) {
        setState(() => _canAdvanceTheory = true);
      }
      return;
    }
    if (_advanceLockKey == nextKey) {
      return;
    }
    _advanceLockKey = nextKey;
    if (initial) {
      _canAdvanceTheory = false;
    } else {
      setState(() => _canAdvanceTheory = false);
    }
    _theoryUnlockTimer = Timer(_currentTheoryAdvanceLockDuration, () {
      if (!mounted) {
        return;
      }
      setState(() => _canAdvanceTheory = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final runner = widget.runner;
    final isTheory = _isTheory;
    final isDrill = runner.phase == Act0LessonPhaseV1.drill;
    final isReview = _isReview;
    final isRefinedDev2 = _isRefinedDev2;
    final teachingStep = _teachingStep;
    final isTeaching = _isTeaching;
    final prompt = isTeaching
        ? act0LocalizedTeachingStepTitleAtomByTaskIdV1(
            widget.selectedTaskId,
            runner.teachingStepIndex,
            fallback: teachingStep!.title,
            isRu: act0IsRuLocaleV1(context),
          )
        : act0LocalizedRunnerPromptAtomByTaskIdV1(
            widget.selectedTaskId,
            fallback: runner.caption,
            isRu: act0IsRuLocaleV1(context),
          );
    final shouldShowRunnerHint = switch (runner.hintPolicy) {
      Act0HintPolicyV1.always => true,
      Act0HintPolicyV1.theoryOnly => isTheory,
      Act0HintPolicyV1.hidden => false,
    };
    final hint = isTeaching
        ? act0LocalizedTeachingStepBodyAtomByTaskIdV1(
            widget.selectedTaskId,
            runner.teachingStepIndex,
            fallback: teachingStep!.body,
            isRu: act0IsRuLocaleV1(context),
          )
        : act0LocalizedRunnerSupportAtomByTaskIdV1(
            widget.selectedTaskId,
            fallback: shouldShowRunnerHint ? runner.hint : '',
            isRu: act0IsRuLocaleV1(context),
          );
    final question = act0LocalizedRunnerQuestionAtomByTaskIdV1(
      widget.selectedTaskId,
      fallback: runner.question,
      isRu: act0IsRuLocaleV1(context),
    );
    final learningRailSupportSegments = act0BuildLearningRailSupportSegmentsV1(
      hint: hint,
      focusLabels: widget.showLearningRailFocusLabels
          ? teachingStep?.focusLabels ?? const <String>[]
          : const <String>[],
      compact: isRefinedDev2,
    );
    final cappedSupportSegmentIndex = learningRailSupportSegments.isEmpty
        ? 0
        : _learningRailSupportSegmentIndex.clamp(
            0,
            learningRailSupportSegments.length - 1,
          );
    final hasNextSupportSegment =
        cappedSupportSegmentIndex < learningRailSupportSegments.length - 1;
    final hasPreviousSupportSegment = cappedSupportSegmentIndex > 0;
    final learningRailProgress = isRefinedDev2
        ? null
        : _learningRailProgressLabel(runner);
    final theoryPresentationRole = _showBottomLearningRail
        ? resolveAct0TheoryPresentationRoleV1(
            taskId: widget.selectedTaskId,
            runner: runner,
            teachingStepIndex: runner.teachingStepIndex,
          )
        : null;
    final hasSeatTargets = runner.options.any(
      (option) => option.seatId != null,
    );
    final table = isReview
        ? _repairTable(runner.table, runner.selectedOption)
        : _teachingTable(runner.table, teachingStep);
    final bottomContext = _resolveRunnerBottomContextV1(
      context,
      runner: runner,
      table: table,
      isTeaching: isTeaching,
      isTheory: isTheory,
      isDrill: isDrill,
      isReview: isReview,
      showBottomLearningRail: _showBottomLearningRail,
      hasSeatTargets: hasSeatTargets,
      taskFamily: widget.selectedTaskFamily,
    );
    final compactBottomDockClearance =
        isRefinedDev2 &&
        table.density == Act0TableDensityV1.compactLesson &&
        bottomContext.owner != _RunnerBottomOwnerV1.feedback;
    final centerLabelOverride = _resolveTableCueDisplayV1(
      context: context,
      runner: runner,
      table: table,
      isTeaching: isTeaching,
      isTheory: isTheory,
      isReview: isReview,
      taskFamily: widget.selectedTaskFamily,
      hasSeatTargets: hasSeatTargets,
    );
    final centerStatDisplay = _resolveCenterStatDisplayV1(
      context,
      runner: runner,
      table: table,
      bottomContext: bottomContext,
      centerCueLabel: centerLabelOverride,
      isTeaching: isTeaching,
      isTheory: isTheory,
      isReview: isReview,
      taskFamily: widget.selectedTaskFamily,
      hasSeatTargets: hasSeatTargets,
    );
    final taskRailLabel = bottomContext.taskLabel;
    final theoryCoachLine = act0RuntimeTheoryCoachLineV1(
      context,
      authoredLine: runner.sharky.preSessionLine,
      lessonId: runner.lessonId,
      beatIndex: runner.beatIndex,
      teachingStepIndex: runner.teachingStepIndex,
      taskFamily: widget.selectedTaskFamily,
      prompt: prompt,
      supportLine: learningRailSupportSegments.isEmpty
          ? hint
          : learningRailSupportSegments[cappedSupportSegmentIndex],
    );
    final promptCoachLine = act0RuntimePromptCoachLineV1(
      context,
      lessonId: runner.lessonId,
      beatIndex: runner.beatIndex,
      question: question,
      taskFamily: widget.selectedTaskFamily,
      hasSeatTargets: hasSeatTargets,
      isTrailHistory: bottomContext.isTrailHistory,
    );
    final promptContextLine =
        bottomContext.promptSupportLine?.trim().isNotEmpty == true
        ? bottomContext.promptSupportLine
        : (bottomContext.isTrailHistory ? null : promptCoachLine);
    final theoryRecallLabel = widget.theoryRecallStep == null
        ? null
        : act0RuntimeTheoryRecallLabelV1(context);
    final showStepIntro =
        isTeaching && runner.teachingStepIndex == 0 && runner.beatIndex > 1;
    final showTopInstructionCard = !isRefinedDev2;
    final pageX = isRefinedDev2 ? 8.0 : Act0ShellTokensV1.runnerPageX;
    final compactTableStageTopInset = 0.0;
    final showCompletionToast =
        isRefinedDev2 &&
        isReview &&
        runner.reviewQuality != Act0FeedbackQualityV1.wrong &&
        widget.completionSummary != null;
    final interactionKey = _interactionKey(runner);
    if (_showdownInteractionKey != interactionKey) {
      _actionTrailFocusedIndex = null;
      _showdownInteractionKey = interactionKey;
      _interactiveHighlightedCardIds = const <String>[];
      _interactiveShowdownLine = '';
    }
    final trailPlaybackEnabled =
        _actionTrailFocusedIndex != null && !isTeaching;
    final mergedHighlightIds = <String>{
      ...table.highlightedCardIds,
      ..._interactiveHighlightedCardIds,
    }.toList(growable: false);
    final playbackActiveSeatId = trailPlaybackEnabled
        ? _activeSeatIdFromActionTrail(table, _actionTrailFocusedIndex)
        : null;
    final betOverride = trailPlaybackEnabled
        ? _deriveBetFromTrailStep(table, _actionTrailFocusedIndex)
        : null;
    // Dynamic pot & street derived from replaying the trail up to current step.
    String? playbackPotLabel;
    String? playbackStreetLabel;
    if (trailPlaybackEnabled && _actionTrailFocusedIndex != null) {
      final calc = _calculatePotAtTrailIndex(table, _actionTrailFocusedIndex!);
      if (calc.potBb >= 0) {
        playbackPotLabel = _formatPotLabel(calc.potBb);
        playbackStreetLabel = calc.street.isNotEmpty ? calc.street : null;
      }
    }
    final interactiveCallout = _interactiveShowdownLine;
    final showActionTrail = bottomContext.showActionTrail;
    final selectedSeatId = runner.selectedOption?.seatId?.trim();
    final selectedSeatFeedbackState = switch (runner.reviewQuality) {
      Act0FeedbackQualityV1.wrong => _SeatSelectionFeedbackStateV1.wrong,
      Act0FeedbackQualityV1.correct || Act0FeedbackQualityV1.suboptimal =>
        selectedSeatId != null && selectedSeatId.isNotEmpty
            ? _SeatSelectionFeedbackStateV1.confirmed
            : _SeatSelectionFeedbackStateV1.none,
    };
    return Column(
      key: const Key('act0_shell_runner_screen'),
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, _) {
              return SingleChildScrollView(
                key: const Key('act0_shell_runner_scroll'),
                padding: EdgeInsets.fromLTRB(
                  pageX,
                  Act0ShellTokensV1.gapSm,
                  pageX,
                  Act0ShellTokensV1.gapMd,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _RunnerProgressV1(runner: runner, onBack: widget.onBack),
                    SizedBox(
                      height: showTopInstructionCard
                          ? Act0ShellTokensV1.gapSm
                          : Act0ShellTokensV1.gapXs,
                    ),
                    if (!isRefinedDev2) ...[
                      _PhaseTrackerV1(phase: runner.phase),
                      const SizedBox(height: Act0ShellTokensV1.gapSm),
                    ],
                    if (showTopInstructionCard) ...[
                      _RunnerInstructionSlotV1(
                        showContent: true,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (showStepIntro) ...[
                              _StepIntroPillV1(
                                label: 'New step',
                                title:
                                    '${runner.beatIndex}/${runner.beatCount}',
                              ),
                              const SizedBox(height: Act0ShellTokensV1.gapXs),
                            ],
                            _CoachCardV1(
                              prompt: prompt,
                              hint: hint,
                              focusLabels:
                                  teachingStep?.focusLabels ?? const <String>[],
                              compact: isRefinedDev2,
                              refined: isRefinedDev2,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: isRefinedDev2
                            ? Act0ShellTokensV1.gapSm
                            : Act0ShellTokensV1.gapMd,
                      ),
                    ],
                    if (compactTableStageTopInset > 0)
                      SizedBox(height: compactTableStageTopInset),
                    Center(
                      child: _RunnerTableStageV1(
                        table: table,
                        highlightedCardIds: mergedHighlightIds,
                        interactiveCalloutLabel: interactiveCallout,
                        onBoardCardTap: _onBoardTappedForShowdown,
                        onChooseSeat: widget.onChooseSeat,
                        visualVariant: widget.tableVisualVariant,
                        showFocusBadge: !_showBottomLearningRail,
                        showRepairCallout: !_isReview,
                        playbackActiveSeatId: playbackActiveSeatId,
                        animateBetMotion: trailPlaybackEnabled,
                        betOverride: betOverride,
                        centerLabelOverride: centerStatDisplay.centerCueLabel,
                        potLabelOverride:
                            playbackPotLabel ?? centerStatDisplay.potLabel,
                        toCallLabelOverride: centerStatDisplay.toCallLabel,
                        streetLabelOverride: playbackStreetLabel,
                        completionSummary: showCompletionToast
                            ? widget.completionSummary
                            : null,
                        selectedSeatId: selectedSeatId,
                        selectedSeatFeedbackState: selectedSeatFeedbackState,
                        compactBottomDockClearance: compactBottomDockClearance,
                      ),
                    ),
                    if (interactiveCallout.isNotEmpty) ...[
                      const SizedBox(height: Act0ShellTokensV1.gapSm),
                      Container(
                        key: const Key('act0_shell_showdown_explain_line'),
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: Act0ShellTokensV1.info.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(
                            Act0ShellTokensV1.radiusBase,
                          ),
                          border: Border.all(
                            color: Act0ShellTokensV1.info.withValues(
                              alpha: 0.34,
                            ),
                          ),
                        ),
                        child: Text(
                          interactiveCallout,
                          style: Act0ShellTokensV1.body.copyWith(
                            color: Act0ShellTokensV1.text,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                    if (showActionTrail) ...[
                      const SizedBox(height: Act0ShellTokensV1.gapSm),
                      _ActionTrailV1(
                        items: table.actionTrail,
                        variant:
                            bottomContext.actionTrailVariant ??
                            _ActionTrailVariantV1.compactContext,
                        streetLabel: table.streetLabel,
                        refined: isRefinedDev2,
                        onFocusedIndexChanged: (index) {
                          if (_actionTrailFocusedIndex == index) {
                            return;
                          }
                          setState(() => _actionTrailFocusedIndex = index);
                        },
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
        _RunnerActionDockV1(
          pageX: pageX,
          taskRailLabel: isRefinedDev2 ? null : taskRailLabel,
          sizingPresets: runner.sizingConfig.isEnabled
              ? runner.sizingConfig.presets
              : null,
          selectedPresetId: runner.selectedPresetId,
          onSelectPreset: widget.onSelectSizingPreset,
          child: _showBottomLearningRail
              ? _LearningRailV1(
                  taskLabel: taskRailLabel,
                  prompt: prompt,
                  supportSegments: learningRailSupportSegments,
                  activeSupportSegmentIndex: cappedSupportSegmentIndex,
                  progressLabel: learningRailProgress,
                  canGoBack:
                      hasPreviousSupportSegment || runner.teachingStepIndex > 0,
                  onBack: hasPreviousSupportSegment
                      ? () => setState(() => _learningRailSupportSegmentIndex--)
                      : (runner.teachingStepIndex > 0
                            ? widget.onPreviousTheory
                            : null),
                  canAdvance: _canAdvanceTheory,
                  onAdvance: hasNextSupportSegment
                      ? () => setState(() => _learningRailSupportSegmentIndex++)
                      : widget.onContinueTheory,
                  sharkyLine: theoryCoachLine,
                  sharkyMood: runner.sharky.preSessionMood,
                  emphasizePrompt:
                      theoryPresentationRole ==
                          Act0TheoryPresentationRoleV1.conceptIntro ||
                      theoryPresentationRole ==
                          Act0TheoryPresentationRoleV1.actionPrep ||
                      theoryPresentationRole ==
                          Act0TheoryPresentationRoleV1.recapCheck,
                )
              : isTeaching
              ? FilledButton(
                  key: const Key('act0_shell_continue_cta'),
                  onPressed: widget.onContinueTheory,
                  style: Act0ShellTokensV1.primaryButtonStyle(
                    height: Act0ShellTokensV1.compactCtaHeight,
                  ),
                  child: Text(teachingStep!.ctaLabel),
                )
              : isTheory
              ? FilledButton(
                  key: const Key('act0_shell_continue_cta'),
                  onPressed: widget.onContinueTheory,
                  style: Act0ShellTokensV1.primaryButtonStyle(
                    height: Act0ShellTokensV1.compactCtaHeight,
                  ),
                  child: Text(runner.primaryCtaLabel),
                )
              : isDrill
              ? runner.options.any((option) => option.seatId != null)
                    ? _SeatTapPromptV1(
                        taskLabel: taskRailLabel,
                        question: question,
                        helperLine: promptCoachLine,
                        options: runner.options,
                        onBack: null,
                        recallLabel: theoryRecallLabel,
                        onRecall: widget.theoryRecallStep == null
                            ? null
                            : _openTheoryRecallSheet,
                      )
                    : runner.sizingConfig.isEnabled
                    ? _ActionPromptPanelV1(
                        taskLabel: taskRailLabel,
                        questionBadgeLabel: bottomContext.questionBadgeLabel,
                        contextLine: promptContextLine,
                        embedChildInSurface: bottomContext.isTrailHistory,
                        question: question,
                        onBack: null,
                        recallLabel: theoryRecallLabel,
                        onRecall: widget.theoryRecallStep == null
                            ? null
                            : _openTheoryRecallSheet,
                        child: _SizingConfirmPanelV1(
                          selectedPreset: runner.selectedPreset,
                          onConfirm: widget.onConfirmSizingPreset,
                        ),
                      )
                    : _ActionPromptPanelV1(
                        taskLabel: taskRailLabel,
                        questionBadgeLabel: bottomContext.questionBadgeLabel,
                        contextLine: promptContextLine,
                        embedChildInSurface: bottomContext.isTrailHistory,
                        question: question,
                        onBack: null,
                        recallLabel: theoryRecallLabel,
                        onRecall: widget.theoryRecallStep == null
                            ? null
                            : _openTheoryRecallSheet,
                        child: _ActionPanelV1(
                          options: runner.options,
                          selectedOptionId: runner.selectedOptionId,
                          onChoose: widget.onChooseOption,
                        ),
                      )
              : isReview
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Act0FeedbackShellV1(
                      title: runner.reviewTitle,
                      reason: runner.reviewReason,
                      quality: runner.reviewQuality,
                      sharkyLine:
                          runner.reviewQuality == Act0FeedbackQualityV1.correct
                          ? runner.sharky.correctReaction
                          : runner.sharky.wrongReaction,
                      sharkyMood:
                          runner.reviewQuality == Act0FeedbackQualityV1.correct
                          ? runner.sharky.correctMood
                          : (runner.reviewQuality ==
                                    Act0FeedbackQualityV1.suboptimal
                                ? Act0SharkyMoodV1.thinking
                                : runner.sharky.wrongMood),
                      selectedLabel: runner.reviewSelectedLabel,
                      preferredLabel: runner.reviewPreferredLabel,
                      betterLabel: runner.reviewBetterLabel,
                      taskFamily: widget.selectedTaskFamily,
                      hasSeatTargets: hasSeatTargets,
                      potLabel: runner.table.potLabel,
                      showPotSweep: _shouldShowPotSweep(runner),
                      contextLabels: <String>[
                        ...bottomContext.feedbackContextLabels,
                        ...runner.reviewContextLabels,
                      ],
                      refined: isRefinedDev2,
                      completionSummary: null,
                      onBack: null,
                      rapidMode: widget.rapidReviewMode,
                      coachVoiceSeed:
                          '${runner.lessonId}|${runner.beatIndex}|${runner.phase.name}|${runner.selectedOptionId ?? ''}',
                      onContinue: widget.onContinueReview,
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

String? _learningRailProgressLabel(Act0RunnerStateV1 runner) {
  final total = runner.teachingSteps.length;
  if (total < 4) {
    return null;
  }
  final current = runner.teachingStepIndex.clamp(0, total - 1) + 1;
  return '$current/$total';
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
  });

  final Widget child;
  final double pageX;
  final String? taskRailLabel;
  final List<Act0SizingPresetV1>? sizingPresets;
  final String? selectedPresetId;
  final ValueChanged<Act0SizingPresetV1>? onSelectPreset;

  @override
  Widget build(BuildContext context) {
    final hasSizingPresets = sizingPresets != null && sizingPresets!.isNotEmpty;
    return Container(
      key: const Key('act0_shell_runner_action_dock'),
      constraints: const BoxConstraints(
        minHeight: Act0ShellTokensV1.runnerActionDockMinHeight,
      ),
      padding: EdgeInsets.fromLTRB(
        pageX,
        Act0ShellTokensV1.gapSm,
        pageX,
        Act0ShellTokensV1.gapMd,
      ),
      decoration: Act0ShellTokensV1.glassDecoration(top: true),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (taskRailLabel != null && taskRailLabel!.isNotEmpty) ...[
              _TaskRailV1(label: taskRailLabel!),
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
            child,
          ],
        ),
      ),
    );
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

    return OutlinedButton(
      key: Key('act0_shell_sizing_preset_${preset.id}'),
      onPressed: onPressed,
      style: Act0ShellTokensV1.quietButtonStyle(height: 40).copyWith(
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
            maxLines: 1,
            overflow: TextOverflow.fade,
            softWrap: false,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          if ((preset.detailLabel ?? '').isNotEmpty)
            Text(
              preset.detailLabel!,
              maxLines: 1,
              overflow: TextOverflow.fade,
              softWrap: false,
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
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
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
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: size * 0.10,
                  right: size * 0.10,
                  top: size * 0.10,
                  bottom: size * 0.06,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: tone.withValues(alpha: 0.28),
                          blurRadius: size * 0.32,
                          offset: Offset(0, size * 0.10),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Act0ShellTokensV1.runnerSharkGradientStart,
                          Act0ShellTokensV1.runnerSharkGradientEnd,
                        ],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Act0ShellTokensV1.runnerSharkBlueDark,
                        width: size * 0.05,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(size * 0.05),
                      child: ClipOval(
                        child: DecoratedBox(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0x22FFFFFF), Color(0x00000000)],
                            ),
                          ),
                          child: Image.asset(
                            _act0MascotAssetForMoodV1(mood),
                            key: Key('act0_shell_sharky_mascot_${mood.name}'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: size * 0.04,
                  top: size * 0.02,
                  child: Container(
                    width: size * 0.16,
                    height: size * 0.16,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.40),
                      shape: BoxShape.circle,
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

String _act0MascotAssetForMoodV1(Act0SharkyMoodV1 mood) {
  return switch (mood) {
    Act0SharkyMoodV1.neutral => 'assets/images/mascot/sharky_neutral.png',
    Act0SharkyMoodV1.happy => 'assets/images/mascot/sharky_happy.png',
    Act0SharkyMoodV1.thinking => 'assets/images/mascot/sharky_thinking.png',
    Act0SharkyMoodV1.repair => 'assets/images/mascot/sharky_repair.png',
    Act0SharkyMoodV1.celebrate => 'assets/images/mascot/sharky_celebrate.png',
  };
}

class _LearningRailV1 extends StatelessWidget {
  const _LearningRailV1({
    required this.taskLabel,
    required this.prompt,
    required this.supportSegments,
    required this.activeSupportSegmentIndex,
    required this.progressLabel,
    required this.canGoBack,
    required this.onBack,
    required this.canAdvance,
    required this.onAdvance,
    required this.sharkyLine,
    required this.sharkyMood,
    this.emphasizePrompt = false,
  });

  final String? taskLabel;
  final String prompt;
  final List<String> supportSegments;
  final int activeSupportSegmentIndex;
  final String? progressLabel;
  final bool canGoBack;
  final VoidCallback? onBack;
  final bool canAdvance;
  final VoidCallback onAdvance;
  final String sharkyLine;
  final Act0SharkyMoodV1 sharkyMood;
  final bool emphasizePrompt;

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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const Key('act0_shell_learning_rail'),
        onTap: canAdvance ? onAdvance : null,
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
        child: Ink(
          decoration: BoxDecoration(
            color: Act0ShellTokensV1.surface2.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
            border: Border.all(
              color: canAdvance
                  ? Act0ShellTokensV1.primary.withValues(alpha: 0.28)
                  : Act0ShellTokensV1.border.withValues(alpha: 0.60),
            ),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 124, maxHeight: 168),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compactRail = constraints.maxHeight <= 168;
                final promptMaxLines = compactRail ? 2 : null;
                final supportMaxLines = compactRail ? 2 : null;
                final promptFontSize = emphasizePrompt
                    ? (compactRail ? 15.0 : 15.2)
                    : (compactRail ? 14.2 : 14.6);
                final supportFontSize = emphasizePrompt
                    ? (compactRail ? 12.2 : 12.2)
                    : (compactRail ? 12.0 : 12.0);
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: compactRail ? 12 : 12,
                    vertical: emphasizePrompt
                        ? (compactRail ? 9 : 7)
                        : (compactRail ? 8 : 6),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (showTaskLabel || showRailProgress) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (showTaskLabel)
                              Expanded(
                                child: Row(
                                  children: [
                                    Act0SharkyMascotV1(
                                      mood: sharkyMood,
                                      tone: Act0ShellTokensV1.info,
                                      size: compactRail ? 16 : 16,
                                    ),
                                    SizedBox(width: compactRail ? 6 : 6),
                                    Expanded(
                                      child: Text(
                                        taskLabel!,
                                        key: const Key(
                                          'act0_shell_learning_rail_task_label',
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Act0ShellTokensV1.label.copyWith(
                                          color: Act0ShellTokensV1.info,
                                          letterSpacing: 0.16,
                                          fontSize: compactRail ? 10.2 : 10.2,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              const Spacer(),
                            if (showRailProgress)
                              Text(
                                progressLabel!,
                                key: const Key(
                                  'act0_shell_learning_rail_progress',
                                ),
                                style: Act0ShellTokensV1.label.copyWith(
                                  color: Act0ShellTokensV1.textDim,
                                  fontSize: compactRail ? 8.8 : 10.0,
                                  letterSpacing: 0.12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: compactRail ? 4 : 4),
                      ],
                      Text(
                        _formatInstructionCopyV1(
                          prompt,
                          allowSingleClauseSplit: true,
                        ),
                        key: const Key('act0_shell_runner_prompt'),
                        maxLines: promptMaxLines,
                        overflow: compactRail ? TextOverflow.fade : null,
                        softWrap: true,
                        style: Act0ShellTokensV1.body.copyWith(
                          color: Act0ShellTokensV1.text,
                          fontSize: promptFontSize,
                          height: compactRail ? 1.05 : 1.06,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (hasSupportLine) ...[
                        SizedBox(height: compactRail ? 4 : 4),
                        _LearningRailKeyIdeaV1(
                          supportSegments: supportSegments,
                          activeSegmentIndex: activeSupportSegmentIndex,
                          compact: compactRail,
                          maxLines: supportMaxLines,
                        ),
                      ] else if (showFallbackCoachLine) ...[
                        SizedBox(height: compactRail ? 4 : 4),
                        Text(
                          fallbackCoachLine,
                          key: const Key(
                            'act0_shell_learning_rail_support_line',
                          ),
                          maxLines: compactRail ? 2 : 2,
                          overflow: compactRail ? TextOverflow.fade : null,
                          softWrap: true,
                          style: Act0ShellTokensV1.body.copyWith(
                            color: Act0ShellTokensV1.textMuted,
                            fontSize: supportFontSize,
                            height: compactRail ? 1.08 : 1.08,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                      SizedBox(height: compactRail ? 6 : 6),
                      Row(
                        children: [
                          _LearningRailNavButtonV1(
                            icon: Icons.arrow_back_ios_new_rounded,
                            buttonKey: const Key('act0_shell_previous_cta'),
                            enabled: canGoBack,
                            onPressed: onBack,
                            compact: compactRail,
                          ),
                          if (supportSegments.length > 1) ...[
                            const SizedBox(width: Act0ShellTokensV1.gapSm),
                            Expanded(
                              child: Align(
                                alignment: Alignment.center,
                                child: _LearningRailSupportDotsV1(
                                  key: const Key(
                                    'act0_shell_learning_rail_support_dots',
                                  ),
                                  count: supportSegments.length,
                                  current: activeSupportSegmentIndex.clamp(
                                    0,
                                    supportSegments.length - 1,
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
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
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

class _LearningRailKeyIdeaV1 extends StatelessWidget {
  const _LearningRailKeyIdeaV1({
    required this.supportSegments,
    required this.activeSegmentIndex,
    this.compact = false,
    this.maxLines,
  });

  final List<String> supportSegments;
  final int activeSegmentIndex;
  final bool compact;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    if (supportSegments.isEmpty) {
      return const SizedBox.shrink();
    }
    final safeIndex = activeSegmentIndex.clamp(0, supportSegments.length - 1);
    final line = supportSegments[safeIndex];
    return Text(
      _formatInstructionCopyV1(line),
      key: const Key('act0_shell_learning_rail_support_line'),
      maxLines: maxLines,
      overflow: compact ? TextOverflow.fade : null,
      softWrap: true,
      style: Act0ShellTokensV1.body.copyWith(
        color: Act0ShellTokensV1.textMuted,
        fontSize: compact ? 12.0 : 12.0,
        height: compact ? 1.08 : 1.10,
        fontWeight: FontWeight.w700,
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
            duration: const Duration(milliseconds: 180),
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
  });

  final IconData icon;
  final Key buttonKey;
  final bool enabled;
  final VoidCallback? onPressed;
  final Color tone;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: compact ? 32 : 40,
      height: compact ? 32 : 40,
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
      child: IconButton(
        key: buttonKey,
        onPressed: enabled ? onPressed : null,
        splashRadius: compact ? 16 : 20,
        padding: EdgeInsets.zero,
        icon: Icon(
          icon,
          size: compact ? 12 : 16,
          color: enabled ? tone : Act0ShellTokensV1.textDim,
        ),
      ),
    );
  }
}

class _RunnerTableStageV1 extends StatelessWidget {
  const _RunnerTableStageV1({
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
  });

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

  @override
  Widget build(BuildContext context) {
    return _Act0TableV1(
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
    );
  }
}

Act0TableStateV1 _teachingTable(
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

Act0TableStateV1 _repairTable(
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

class _RunnerProgressV1 extends StatelessWidget {
  const _RunnerProgressV1({required this.runner, required this.onBack});

  final Act0RunnerStateV1 runner;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 34,
          height: 34,
          child: IconButton(
            key: const Key('act0_shell_runner_back'),
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
              value: runner.beatIndex / runner.beatCount,
              backgroundColor: Act0ShellTokensV1.surface3,
              color: Act0ShellTokensV1.primary,
            ),
          ),
        ),
        const SizedBox(width: Act0ShellTokensV1.gapMd),
        Text(
          '${runner.beatIndex}/${runner.beatCount}',
          style: Act0ShellTokensV1.body.copyWith(fontWeight: FontWeight.w900),
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
  });

  final String taskLabel;
  final String question;
  final String helperLine;
  final List<Act0RunnerOptionV1> options;
  final VoidCallback? onBack;
  final String? recallLabel;
  final VoidCallback? onRecall;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('act0_shell_seat_tap_prompt'),
      constraints: const BoxConstraints(minHeight: 124),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 11),
      decoration: Act0ShellTokensV1.surfaceDecoration(
        color: Act0ShellTokensV1.surface2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (onBack != null) ...[
            _DockBackButtonV1(onPressed: onBack!),
            const SizedBox(width: Act0ShellTokensV1.gapSm),
          ] else
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(
                Icons.touch_app_rounded,
                color: Act0ShellTokensV1.primary.withValues(alpha: 0.92),
                size: 18,
              ),
            ),
          if (onBack == null) const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  taskLabel,
                  key: const Key('act0_shell_seat_tap_task_label'),
                  maxLines: 2,
                  style: Act0ShellTokensV1.label.copyWith(
                    color: Act0ShellTokensV1.info,
                    letterSpacing: 0.2,
                    fontSize: 9.4,
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
                      fontSize: 15.4,
                      height: 1.08,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                const SizedBox(height: 5),
                Text(
                  helperLine,
                  key: const Key('act0_shell_seat_tap_prompt_text'),
                  maxLines: 2,
                  style: Act0ShellTokensV1.muted.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 12.6,
                    height: 1.10,
                  ),
                ),
                if (onRecall != null && recallLabel != null) ...[
                  const SizedBox(height: 6),
                  _TheoryRecallCtaV1(label: recallLabel!, onPressed: onRecall!),
                ],
              ],
            ),
          ),
        ],
      ),
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
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: refined ? 14 : (compact ? 11 : 12),
        vertical: refined ? 6 : (compact ? 8 : 10),
      ),
      decoration: refined
          ? BoxDecoration(
              color: Act0ShellTokensV1.surface.withValues(alpha: 0.68),
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
              border: Border.all(
                color: Act0ShellTokensV1.border.withValues(alpha: 0.8),
              ),
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
    return sentences.join('\n');
  }

  if (!allowSingleClauseSplit || normalized.length < 72) {
    return normalized;
  }

  final breakpoints = <String>[' — ', ': ', '; ', ', '];
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

class Act0FeedbackShellV1 extends StatelessWidget {
  const Act0FeedbackShellV1({
    super.key,
    required this.title,
    required this.reason,
    required this.quality,
    required this.sharkyLine,
    required this.sharkyMood,
    required this.selectedLabel,
    required this.preferredLabel,
    required this.betterLabel,
    this.taskFamily,
    this.hasSeatTargets = false,
    this.potLabel = '',
    this.showPotSweep = false,
    this.contextLabels = const <String>[],
    this.refined = false,
    this.completionSummary,
    this.onBack,
    this.rapidMode = false,
    this.coachVoiceSeed,
    required this.onContinue,
  });

  final String title;
  final String reason;
  final Act0FeedbackQualityV1 quality;
  final String sharkyLine;
  final Act0SharkyMoodV1 sharkyMood;
  final String selectedLabel;
  final String preferredLabel;
  final String betterLabel;
  final Act0TaskFamilyV1? taskFamily;
  final bool hasSeatTargets;
  final String potLabel;
  final bool showPotSweep;
  final List<String> contextLabels;
  final bool refined;
  final Act0RunnerCompletionSummaryV1? completionSummary;
  final VoidCallback? onBack;
  final bool rapidMode;
  final String? coachVoiceSeed;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final isWrong = quality == Act0FeedbackQualityV1.wrong;
    final isSuboptimal = quality == Act0FeedbackQualityV1.suboptimal;
    final tone = isWrong
        ? Act0ShellTokensV1.danger
        : (isSuboptimal ? Act0ShellTokensV1.gold : Act0ShellTokensV1.primary);
    final icon = isWrong
        ? Icons.close_rounded
        : (isSuboptimal ? Icons.trending_up_rounded : Icons.check_rounded);
    final iconKey = isWrong
        ? const Key('act0_shell_feedback_icon_wrong')
        : (isSuboptimal
              ? const Key('act0_shell_feedback_icon_suboptimal')
              : const Key('act0_shell_feedback_icon_correct'));
    final sharkyTone = isWrong
        ? Act0ShellTokensV1.danger
        : (isSuboptimal ? Act0ShellTokensV1.gold : Act0ShellTokensV1.primary);
    final resolvedTitle = _feedbackTitleFloorV1(
      context,
      title: title,
      quality: quality,
      contextLabels: contextLabels,
    );
    final reactionLine = act0RuntimeFeedbackCoachLineV1(
      context,
      authoredLine: sharkyLine,
      title: resolvedTitle,
      quality: quality,
      variationSeed:
          coachVoiceSeed ??
          '${quality.name}|${resolvedTitle.trim().toLowerCase()}|${sharkyLine.trim().toLowerCase()}',
      taskFamily: taskFamily,
    );
    final showVerdictTitle = resolvedTitle.isNotEmpty;
    final actionPrefix = act0RuntimeFeedbackActionPrefixV1(
      context,
      quality,
      taskFamily: taskFamily,
      hasSeatTargets: hasSeatTargets,
    );
    final actionLabel = act0RuntimeLocalizedOptionLabelV1(
      context,
      isWrong ? betterLabel : preferredLabel,
    );
    final localizedContextLabels = [
      for (final label in (refined ? contextLabels.take(1) : contextLabels))
        act0RuntimeLocalizedContextLabelV1(context, label).trim(),
    ];
    final visibleContextLabels = _dedupedFeedbackContextLabelsV1(
      localizedContextLabels,
      preferredLine: actionLabel,
      selectedLine: isWrong || isSuboptimal ? selectedLabel : '',
      statusLine: showVerdictTitle
          ? act0RuntimeLocalizedGeneralLabelV1(context, resolvedTitle).trim()
          : '',
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
    return Container(
      key: const Key('act0_shell_feedback_card'),
      padding: EdgeInsets.all(rapidMode ? 8 : (refined ? 8 : 10)),
      decoration: Act0ShellTokensV1.surfaceDecoration(
        borderColor: tone.withValues(alpha: refined ? 0.32 : 0.46),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Act0SharkyMascotV1(
                mood: sharkyMood,
                tone: sharkyTone,
                size: refined ? 34 : 40,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (reactionLine.isNotEmpty)
                      Text(
                        reactionLine,
                        key: const Key('act0_shell_sharky_outcome_reaction'),
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                        style: Act0ShellTokensV1.muted.copyWith(
                          color: Act0ShellTokensV1.textMuted,
                          fontSize: refined ? 10.0 : 10.5,
                          height: 1.06,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (!rapidMode) const SizedBox(height: 8),
          if (actionLabel.isNotEmpty) ...[
            Text(
              '$actionPrefix: $actionLabel',
              key: const Key('act0_shell_feedback_preferred_label'),
              maxLines: rapidMode ? 2 : 2,
              overflow: TextOverflow.fade,
              style: Act0ShellTokensV1.body.copyWith(
                color: Act0ShellTokensV1.text,
                fontSize: rapidMode ? 15 : (refined ? 15.5 : 16.5),
                height: 1.06,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: rapidMode ? 0 : 6),
          ],
          if (!rapidMode &&
              (isWrong || isSuboptimal) &&
              selectedLabel.isNotEmpty) ...[
            Text(
              act0RuntimeFeedbackSelectedLineV1(context, selectedLabel),
              key: const Key('act0_shell_feedback_selected_label'),
              maxLines: 1,
              overflow: TextOverflow.fade,
              style: Act0ShellTokensV1.muted.copyWith(
                color: Act0ShellTokensV1.textMuted,
                fontSize: refined ? 11.5 : 12.0,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
          ],
          if (!rapidMode)
            Text(
              resolvedReason,
              key: const Key('act0_shell_feedback_reason'),
              maxLines: refined ? 3 : 4,
              overflow: TextOverflow.fade,
              style: Act0ShellTokensV1.body.copyWith(
                color: Act0ShellTokensV1.textMuted,
                fontSize: refined ? 12.0 : 12.5,
                height: 1.16,
              ),
            ),
          if (!rapidMode && showVerdictTitle) ...[
            const SizedBox(height: 7),
            Row(
              children: [
                Icon(icon, key: iconKey, color: tone, size: 15),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    act0RuntimeLocalizedGeneralLabelV1(context, resolvedTitle),
                    key: const Key('act0_shell_feedback_status_label'),
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
          if (!rapidMode && showPotSweep && potLabel.isNotEmpty) ...[
            const SizedBox(height: 9),
            _PotSweepMomentV1(potLabel: potLabel),
          ],
          if (!rapidMode && visibleContextLabels.isNotEmpty) ...[
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
          if (!rapidMode && completionSummary != null) ...[
            const SizedBox(height: 8),
            _CompletionToastV1(summary: completionSummary!),
          ],
          if (rapidMode) ...[
            const SizedBox(height: 8),
            Text(
              'Next spot...',
              key: const Key('act0_shell_feedback_auto_advance_label'),
              textAlign: TextAlign.center,
              style: Act0ShellTokensV1.label.copyWith(
                color: tone,
                letterSpacing: 0.2,
              ),
            ),
          ] else ...[
            const SizedBox(height: 10),
            Row(
              children: [
                if (onBack != null) ...[
                  _DockBackButtonV1(
                    key: const Key('act0_shell_interaction_back_cta'),
                    onPressed: onBack!,
                  ),
                  const SizedBox(width: Act0ShellTokensV1.gapSm),
                ],
                Expanded(
                  child: FilledButton(
                    key: const Key('act0_shell_feedback_continue_cta'),
                    onPressed: onContinue,
                    style: Act0ShellTokensV1.primaryButtonStyle(
                      height: Act0ShellTokensV1.compactCtaHeight,
                    ),
                    child: const Text('Continue'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

List<String> _dedupedFeedbackContextLabelsV1(
  List<String> labels, {
  required String preferredLine,
  required String selectedLine,
  required String statusLine,
}) {
  final seen = <String>{};
  final normalizedSelected = _normalizeFeedbackLabelV1(selectedLine);
  final blocked = <String>{
    _normalizeFeedbackLabelV1(preferredLine),
    _normalizeFeedbackLabelV1(statusLine),
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
    if (quality == Act0FeedbackQualityV1.correct) {
      return focusLabel;
    }
    return localeIsRu ? '$focusLabel сначала' : '$focusLabel first';
  }

  if (quality == Act0FeedbackQualityV1.correct) {
    return localeIsRu ? 'Верное чтение' : 'Correct read';
  }
  return localeIsRu ? 'Сначала перечитай спот' : 'Read the spot first';
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

  if (quality == Act0FeedbackQualityV1.correct) {
    if (focusLabel.isNotEmpty) {
      return localeIsRu
          ? '$focusLabel прочитан верно. Сохрани это и продолжай.'
          : '$focusLabel read correctly. Keep it and continue.';
    }
    return localeIsRu
        ? 'Чтение верное. Сохрани его и продолжай.'
        : 'Read is correct. Keep it and continue.';
  }

  if (focusLabel.isNotEmpty && betterLine.isNotEmpty) {
    return localeIsRu
        ? '$focusLabel сначала. Сравни это с $betterLine перед продолжением.'
        : '$focusLabel first. Compare it with $betterLine before you continue.';
  }
  if (pickedLine.isNotEmpty && betterLine.isNotEmpty) {
    return localeIsRu
        ? 'Сравни $pickedLine с $betterLine перед продолжением.'
        : 'Compare $pickedLine with $betterLine before you continue.';
  }
  return localeIsRu
      ? 'Сделай паузу, прочитай спот ещё раз и затем продолжай.'
      : 'Pause, read the spot again, then continue.';
}

class Act0BlockCompletionShellV1 extends StatelessWidget {
  const Act0BlockCompletionShellV1({
    super.key,
    required this.summary,
    required this.onContinue,
    this.onReplay,
    this.onOpenReview,
    required this.onBackToMap,
  });

  final Act0BlockCompletionSummaryV1 summary;
  final VoidCallback onContinue;
  final VoidCallback? onReplay;
  final VoidCallback? onOpenReview;
  final VoidCallback onBackToMap;

  VoidCallback? _callbackForCta(Act0MilestoneCtaKindV1 kind) {
    return switch (kind) {
      Act0MilestoneCtaKindV1.continueForward => onContinue,
      Act0MilestoneCtaKindV1.replayForPerfect => onReplay,
      Act0MilestoneCtaKindV1.reviewFirst => onOpenReview,
      Act0MilestoneCtaKindV1.reviewForPerfect => onOpenReview,
      Act0MilestoneCtaKindV1.backToMap => onBackToMap,
    };
  }

  @override
  Widget build(BuildContext context) {
    final celebrateTone = summary.qualifiesForNextLesson
        ? (summary.leveledUp
              ? Act0ShellTokensV1.gold
              : Act0ShellTokensV1.primary)
        : Act0ShellTokensV1.gold;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Act0ShellTokensV1.gapLg),
        child: Container(
          key: const Key('act0_shell_block_summary_card'),
          constraints: const BoxConstraints(maxWidth: 388),
          padding: const EdgeInsets.all(Act0ShellTokensV1.gapLg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                celebrateTone.withValues(alpha: 0.18),
                Act0ShellTokensV1.info.withValues(alpha: 0.05),
                Act0ShellTokensV1.surface,
                Act0ShellTokensV1.surface2,
              ],
            ),
            borderRadius: BorderRadius.circular(
              Act0ShellTokensV1.radiusOverlay,
            ),
            border: Border.all(color: celebrateTone.withValues(alpha: 0.34)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: celebrateTone.withValues(alpha: 0.16),
                blurRadius: 40,
                offset: const Offset(0, 18),
              ),
              const BoxShadow(
                color: Act0ShellTokensV1.shadowSoft,
                blurRadius: 22,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    Act0ShellTokensV1.radiusPill,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: <Color>[
                      celebrateTone.withValues(alpha: 0.18),
                      celebrateTone.withValues(alpha: 0.82),
                      Act0ShellTokensV1.info.withValues(alpha: 0.34),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Act0ShellTokensV1.gapMd),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: celebrateTone.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(
                        Act0ShellTokensV1.radiusPill,
                      ),
                      border: Border.all(
                        color: celebrateTone.withValues(alpha: 0.34),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          summary.qualifiesForNextLesson
                              ? Icons.auto_awesome_rounded
                              : Icons.refresh_rounded,
                          size: 14,
                          color: celebrateTone,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          summary.masteryLabel,
                          style: Act0ShellTokensV1.label.copyWith(
                            color: celebrateTone,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Act0ShellTokensV1.gapSm),
              Text(
                summary.milestoneTitle,
                key: const Key('act0_shell_block_summary_title'),
                style: Act0ShellTokensV1.screenTitle.copyWith(fontSize: 28),
              ),
              const SizedBox(height: 4),
              Text(
                summary.milestoneDetailTitle,
                key: const Key('act0_shell_block_summary_detail_title'),
                maxLines: 2,
                overflow: TextOverflow.fade,
                style: Act0ShellTokensV1.body.copyWith(
                  color: Act0ShellTokensV1.text,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                summary.gateMessage,
                key: const Key('act0_shell_block_summary_gate_message'),
                maxLines: 4,
                overflow: TextOverflow.fade,
                style: Act0ShellTokensV1.body.copyWith(
                  color: Act0ShellTokensV1.textMuted,
                ),
              ),
              const SizedBox(height: Act0ShellTokensV1.gapMd),
              if (summary.unlockedLabel != null ||
                  summary.progressStatusLabel.isNotEmpty) ...[
                Container(
                  key: const Key('act0_shell_block_summary_unlock_card'),
                  padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
                  decoration: BoxDecoration(
                    color: celebrateTone.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(
                      Act0ShellTokensV1.radiusCard,
                    ),
                    border: Border.all(
                      color: celebrateTone.withValues(alpha: 0.24),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (summary.unlockedLabel != null) ...[
                        Text(
                          summary.unlockedLabel!,
                          key: const Key(
                            'act0_shell_block_summary_unlock_label',
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.fade,
                          style: Act0ShellTokensV1.body.copyWith(
                            color: Act0ShellTokensV1.text,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                      Text(
                        summary.progressStatusLabel,
                        key: const Key(
                          'act0_shell_block_summary_progress_status',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.fade,
                        style: Act0ShellTokensV1.muted.copyWith(
                          color: Act0ShellTokensV1.textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Act0ShellTokensV1.gapMd),
              ],
              Container(
                key: const Key('act0_shell_block_summary_habit_reward'),
                padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
                decoration: BoxDecoration(
                  color: Act0ShellTokensV1.surface2.withValues(alpha: 0.82),
                  borderRadius: BorderRadius.circular(
                    Act0ShellTokensV1.radiusCard,
                  ),
                  border: Border.all(
                    color: celebrateTone.withValues(alpha: 0.20),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: celebrateTone.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(
                          Act0ShellTokensV1.radiusLg,
                        ),
                      ),
                      child: Icon(
                        summary.deepLeakCount > 0
                            ? Icons.build_circle_rounded
                            : summary.quickFixCount > 0
                            ? Icons.trending_up_rounded
                            : summary.leveledUp
                            ? Icons.auto_awesome_rounded
                            : Icons.check_circle_rounded,
                        size: 18,
                        color: celebrateTone,
                      ),
                    ),
                    const SizedBox(width: Act0ShellTokensV1.gapSm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            summary.habitRewardLabel,
                            key: const Key(
                              'act0_shell_block_summary_habit_reward_label',
                            ),
                            style: Act0ShellTokensV1.label.copyWith(
                              color: celebrateTone,
                              letterSpacing: 0.35,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            summary.habitRewardDetail,
                            key: const Key(
                              'act0_shell_block_summary_habit_reward_detail',
                            ),
                            maxLines: 4,
                            overflow: TextOverflow.fade,
                            style: Act0ShellTokensV1.body.copyWith(
                              color: Act0ShellTokensV1.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Act0ShellTokensV1.gapMd),
              Container(
                key: const Key('act0_shell_block_summary_next_label'),
                padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
                decoration: BoxDecoration(
                  color: celebrateTone.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(
                    Act0ShellTokensV1.radiusCard,
                  ),
                  border: Border.all(
                    color: celebrateTone.withValues(alpha: 0.24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      summary.suggestedNextAction,
                      key: const Key('act0_shell_block_summary_suggested_next'),
                      maxLines: 4,
                      overflow: TextOverflow.fade,
                      style: Act0ShellTokensV1.body.copyWith(
                        color: Act0ShellTokensV1.text,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (summary.sharkyLine.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Act0SharkyPresenceBubbleV1(
                        line: summary.sharkyLine,
                        mood: summary.qualifiesForNextLesson
                            ? Act0SharkyMoodV1.celebrate
                            : Act0SharkyMoodV1.repair,
                        tone: summary.qualifiesForNextLesson
                            ? Act0ShellTokensV1.primary
                            : Act0ShellTokensV1.gold,
                        textKey: const Key(
                          'act0_shell_block_summary_sharky_line',
                        ),
                        mascotSize: 68,
                        bubblePadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (summary.growthLabel.isNotEmpty) ...[
                const SizedBox(height: Act0ShellTokensV1.gapMd),
                _GrowthHighlightV1(
                  key: const Key('act0_shell_block_summary_growth_highlight'),
                  title: 'What moved',
                  label: summary.growthLabel,
                  tone: celebrateTone,
                ),
              ],
              const SizedBox(height: Act0ShellTokensV1.gapMd),
              _BlockXpProgressCardV1(summary: summary),
              const SizedBox(height: Act0ShellTokensV1.gapSm),
              Text(
                '${summary.accuracyPercent}% accuracy · ${summary.correctCount}/${summary.taskCount} correct · ${summary.errorCount} errors',
                key: const Key('act0_shell_block_summary_accuracy'),
                maxLines: 2,
                overflow: TextOverflow.fade,
                style: Act0ShellTokensV1.muted.copyWith(
                  color: Act0ShellTokensV1.textMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (summary.quickFixCount > 0 || summary.deepLeakCount > 0) ...[
                const SizedBox(height: Act0ShellTokensV1.gapSm),
                Container(
                  key: const Key('act0_shell_block_summary_repair_mix'),
                  padding: const EdgeInsets.all(Act0ShellTokensV1.gapSm),
                  decoration: BoxDecoration(
                    color: Act0ShellTokensV1.surface2.withValues(alpha: 0.82),
                    borderRadius: BorderRadius.circular(
                      Act0ShellTokensV1.radiusLg,
                    ),
                    border: Border.all(color: Act0ShellTokensV1.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Quick fixes: ${summary.quickFixCount}',
                          key: const Key(
                            'act0_shell_block_summary_quick_fixes',
                          ),
                          style: Act0ShellTokensV1.body.copyWith(
                            color: Act0ShellTokensV1.text,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: Act0ShellTokensV1.gapSm),
                      Expanded(
                        child: Text(
                          'Deep leaks: ${summary.deepLeakCount}',
                          key: const Key('act0_shell_block_summary_deep_leaks'),
                          textAlign: TextAlign.right,
                          style: Act0ShellTokensV1.body.copyWith(
                            color: summary.deepLeakCount == 0
                                ? Act0ShellTokensV1.textMuted
                                : Act0ShellTokensV1.danger,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: Act0ShellTokensV1.gapLg),
              FilledButton(
                key: const Key('act0_shell_block_summary_continue_cta'),
                onPressed: _callbackForCta(summary.primaryCtaKind),
                style: Act0ShellTokensV1.primaryButtonStyle(),
                child: Text(summary.primaryCtaLabel),
              ),
              if (summary.secondaryCtaLabel != null) ...[
                const SizedBox(height: Act0ShellTokensV1.gapSm),
                OutlinedButton(
                  key: const Key('act0_shell_block_summary_quality_cta'),
                  onPressed: _callbackForCta(summary.secondaryCtaKind!),
                  style: Act0ShellTokensV1.tonalButtonStyle(
                    tone: Act0ShellTokensV1.info,
                    fullWidth: true,
                  ),
                  child: Text(summary.secondaryCtaLabel!),
                ),
              ],
              if (summary.hasNextLesson ||
                  (summary.isWorldComplete &&
                      summary.nextWorldTitle != null &&
                      summary.nextWorldTitle!.isNotEmpty)) ...[
                const SizedBox(height: Act0ShellTokensV1.gapXs),
                TextButton(
                  key: const Key('act0_shell_block_summary_map_cta'),
                  onPressed: onBackToMap,
                  child: const Text('Back to map'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _BlockXpProgressCardV1 extends StatelessWidget {
  const _BlockXpProgressCardV1({required this.summary});

  final Act0BlockCompletionSummaryV1 summary;

  @override
  Widget build(BuildContext context) {
    final tone = summary.leveledUp
        ? Act0ShellTokensV1.gold
        : Act0ShellTokensV1.primary;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1800),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final animatedGain = (summary.xpEarned * value).round();
        final progress = _blockSummaryProgressAtGain(summary, animatedGain);
        return Container(
          decoration: BoxDecoration(
            color: Act0ShellTokensV1.surface2.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPanel),
            border: Border.all(color: tone.withValues(alpha: 0.28)),
          ),
          padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: tone.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(
                        Act0ShellTokensV1.radiusPill,
                      ),
                    ),
                    child: Text(
                      '+$animatedGain XP',
                      key: const Key('act0_shell_block_summary_xp_gain'),
                      style: Act0ShellTokensV1.label.copyWith(
                        color: tone,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    progress.leveledUp
                        ? 'Level ${progress.endLevel}'
                        : '${progress.endXp}/${summary.xpTarget} XP',
                    key: const Key('act0_shell_block_summary_xp_total'),
                    style: Act0ShellTokensV1.body.copyWith(
                      color: Act0ShellTokensV1.text,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Act0ShellTokensV1.gapSm),
              ClipRRect(
                borderRadius: BorderRadius.circular(
                  Act0ShellTokensV1.radiusPill,
                ),
                child: LinearProgressIndicator(
                  key: const Key('act0_shell_block_summary_xp_progress'),
                  minHeight: 8,
                  value: summary.xpTarget <= 0
                      ? 0
                      : (progress.endXp / summary.xpTarget).clamp(0, 1),
                  backgroundColor: Act0ShellTokensV1.surface3,
                  color: tone,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GrowthHighlightV1 extends StatelessWidget {
  const _GrowthHighlightV1({
    super.key,
    required this.label,
    required this.tone,
    this.title = 'Skill gain',
  });

  final String title;
  final String label;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Act0ShellTokensV1.gapMd,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusCard),
        border: Border.all(color: tone.withValues(alpha: 0.24)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tone.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusMd),
            ),
            child: Icon(Icons.auto_graph_rounded, size: 17, color: tone),
          ),
          const SizedBox(width: Act0ShellTokensV1.gapSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Act0ShellTokensV1.label.copyWith(
                    color: tone,
                    letterSpacing: 0.35,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: Act0ShellTokensV1.body.copyWith(
                    color: Act0ShellTokensV1.text,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Act0RunnerCompletionSummaryV1 _blockSummaryProgressAtGain(
  Act0BlockCompletionSummaryV1 summary,
  int gain,
) {
  final xpTarget = summary.xpTarget <= 0 ? 1 : summary.xpTarget;
  final totalXp = summary.startXp + gain;
  return Act0RunnerCompletionSummaryV1(
    xpGain: gain,
    startLevel: summary.startLevel,
    endLevel: summary.startLevel + (totalXp ~/ xpTarget),
    startXp: summary.startXp,
    endXp: totalXp % xpTarget,
    xpTarget: summary.xpTarget,
  );
}

class _CompletionToastV1 extends StatelessWidget {
  const _CompletionToastV1({
    required this.summary,
    this.overlayStyle = _CompletionToastOverlayStyleV1.standard,
  });

  final Act0RunnerCompletionSummaryV1 summary;
  final _CompletionToastOverlayStyleV1 overlayStyle;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1800),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final appear = Curves.easeOut.transform((value / 0.18).clamp(0.0, 1.0));
        final disappear = Curves.easeIn.transform(
          ((value - 0.72) / 0.28).clamp(0.0, 1.0),
        );
        final opacity = (appear * (1 - disappear)).clamp(0.0, 1.0);
        final animatedGain = (summary.xpGain * appear).round();
        final progress = _feedbackProgressAtGain(summary, animatedGain);
        final tone = summary.leveledUp
            ? Act0ShellTokensV1.gold
            : Act0ShellTokensV1.primary;
        final onTableOverlay =
            overlayStyle == _CompletionToastOverlayStyleV1.table;
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, (1 - appear) * (onTableOverlay ? 5 : 6)),
            child: Container(
              key: const Key('act0_shell_completion_toast'),
              constraints: BoxConstraints(
                minWidth: onTableOverlay ? 164 : 176,
                maxWidth: onTableOverlay ? 204 : 220,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: onTableOverlay ? 11 : 12,
                vertical: onTableOverlay ? 8 : 10,
              ),
              decoration: BoxDecoration(
                color: onTableOverlay
                    ? Act0ShellTokensV1.surface2.withValues(alpha: 0.88)
                    : Act0ShellTokensV1.surface2.withValues(alpha: 0.96),
                borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusMd),
                border: Border.all(
                  color: tone.withValues(alpha: onTableOverlay ? 0.24 : 0.34),
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: onTableOverlay ? 0.10 : 0.24,
                    ),
                    blurRadius: onTableOverlay ? 8 : 18,
                    offset: Offset(0, onTableOverlay ? 3 : 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '+$animatedGain XP · ${summary.toastRewardLabel}',
                          key: const Key(
                            'act0_shell_completion_toast_reward_label',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          style: Act0ShellTokensV1.label.copyWith(
                            color: tone,
                            letterSpacing: onTableOverlay ? 0.16 : 0.25,
                            fontSize: onTableOverlay ? 9.0 : null,
                          ),
                        ),
                      ),
                      if (summary.leveledUp)
                        Text(
                          'Level ${summary.endLevel}',
                          key: const Key(
                            'act0_shell_completion_toast_level_up',
                          ),
                          style: Act0ShellTokensV1.body.copyWith(
                            color: Act0ShellTokensV1.gold,
                            fontWeight: FontWeight.w900,
                            fontSize: onTableOverlay ? 10.5 : 11.5,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: onTableOverlay ? 2 : 3),
                  Text(
                    '${progress.endXp}/${summary.xpTarget} XP',
                    key: const Key('act0_shell_completion_toast_total'),
                    style: Act0ShellTokensV1.body.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: onTableOverlay ? 10.8 : 11.5,
                    ),
                  ),
                  SizedBox(height: onTableOverlay ? 5 : 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                      Act0ShellTokensV1.radiusPill,
                    ),
                    child: LinearProgressIndicator(
                      key: const Key('act0_shell_completion_toast_progress'),
                      minHeight: onTableOverlay ? 5 : 6,
                      value: summary.xpTarget <= 0
                          ? 0
                          : (progress.endXp / summary.xpTarget).clamp(0, 1),
                      backgroundColor: Act0ShellTokensV1.surface3,
                      color: tone,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

enum _CompletionToastOverlayStyleV1 { standard, table }

class _PotSweepMomentV1 extends StatelessWidget {
  const _PotSweepMomentV1({required this.potLabel});

  final String potLabel;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: const Key('act0_shell_pot_sweep_moment'),
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1180),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final appear = Curves.easeOut.transform((value / 0.18).clamp(0.0, 1.0));
        final settle = Curves.easeInOut.transform(
          ((value - 0.12) / 0.70).clamp(0.0, 1.0),
        );
        final fade = Curves.easeIn.transform(
          ((value - 0.78) / 0.22).clamp(0.0, 1.0),
        );
        return Opacity(
          opacity: (appear * (1 - fade)).clamp(0.0, 1.0),
          child: Align(
            alignment:
                Alignment.lerp(
                  const Alignment(0, -0.04),
                  const Alignment(0, 0.58),
                  settle,
                ) ??
                const Alignment(0, 0.58),
            child: Transform.scale(scale: 0.90 + (0.10 * appear), child: child),
          ),
        );
      },
      child: Container(
        key: const Key('act0_shell_pot_sweep_chip'),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Act0ShellTokensV1.gold.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
          border: Border.all(
            color: Act0ShellTokensV1.gold.withValues(alpha: 0.38),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Act0ShellTokensV1.gold.withValues(alpha: 0.18),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.casino_rounded, size: 13, color: Act0ShellTokensV1.gold),
            const SizedBox(width: 5),
            Text(
              potLabel,
              key: const Key('act0_shell_pot_sweep_label'),
              maxLines: 3,
              overflow: TextOverflow.fade,
              style: Act0ShellTokensV1.label.copyWith(
                color: Act0ShellTokensV1.gold,
                fontSize: 9.4,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Act0RunnerCompletionSummaryV1 _feedbackProgressAtGain(
  Act0RunnerCompletionSummaryV1 summary,
  int gain,
) {
  final xpTarget = summary.xpTarget <= 0 ? 1 : summary.xpTarget;
  final totalXp = summary.startXp + gain;
  return Act0RunnerCompletionSummaryV1(
    xpGain: gain,
    startLevel: summary.startLevel,
    endLevel: summary.startLevel + (totalXp ~/ xpTarget),
    startXp: summary.startXp,
    endXp: totalXp % xpTarget,
    xpTarget: summary.xpTarget,
  );
}

class _Act0TableV1 extends StatelessWidget {
  const _Act0TableV1({
    required this.table,
    required this.highlightedCardIds,
    required this.interactiveCalloutLabel,
    required this.onBoardCardTap,
    this.onChooseSeat,
    this.visualVariant = Act0ShellTableVisualVariantV1.classic,
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
  });

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

  @override
  Widget build(BuildContext context) {
    final seats = _visualSeatOrder(table.seats);
    final refined = visualVariant == Act0ShellTableVisualVariantV1.refinedDev2;
    final isTablet = Act0ShellTokensV1.isTabletWidth(context);
    var tableMaxWidth = switch (table.density) {
      Act0TableDensityV1.compactLesson => Act0ShellTokensV1.runnerTableMaxWidth,
      Act0TableDensityV1.handView => Act0ShellTokensV1.handTableMaxWidth,
    };
    if (visualVariant == Act0ShellTableVisualVariantV1.refinedDev2 &&
        table.density == Act0TableDensityV1.compactLesson) {
      tableMaxWidth += 44;
    }
    if (isTablet) {
      tableMaxWidth = switch (table.density) {
        Act0TableDensityV1.compactLesson => refined ? 560 : 520,
        Act0TableDensityV1.handView => refined ? 600 : 560,
      };
    }
    var tableAspect = switch (table.density) {
      Act0TableDensityV1.compactLesson => Act0ShellTokensV1.tableAspect,
      Act0TableDensityV1.handView => Act0ShellTokensV1.handTableAspect,
    };
    if (visualVariant == Act0ShellTableVisualVariantV1.refinedDev2 &&
        table.density == Act0TableDensityV1.compactLesson) {
      tableAspect = 0.59;
    }
    if (isTablet) {
      tableAspect = switch (table.density) {
        Act0TableDensityV1.compactLesson => refined ? 0.88 : 0.84,
        Act0TableDensityV1.handView => refined ? 0.82 : 0.80,
      };
    }
    return ConstrainedBox(
      key: const Key('act0_shell_table'),
      constraints: BoxConstraints(maxWidth: tableMaxWidth),
      child: AspectRatio(
        aspectRatio: tableAspect,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;
            final seatSlots = _seatSlotsForVariant(
              visualVariant,
              compactBottomDockClearance: compactBottomDockClearance,
            );
            final chipSlots = _chipSlotsForVariant(
              visualVariant,
              compactBottomDockClearance: compactBottomDockClearance,
            );
            final activeSeatId = (playbackActiveSeatId ?? '').trim().isNotEmpty
                ? playbackActiveSeatId
                : _resolveActiveSeatId(table);
            final decisionPriceOwnedByTable =
                (toCallLabelOverride ?? table.toCallLabel).trim().isNotEmpty;
            final resolvedSelectedSeatId =
                (selectedSeatId ?? table.selectedSeatId)?.trim();
            final focusResolution = _resolvePrimarySeatFocusV1(
              activeSeatId: activeSeatId,
              highlightedSeatIds: table.highlightedSeatIds,
              selectableSeatIds: table.selectableSeatIds,
              selectedSeatId: resolvedSelectedSeatId,
              selectionFeedbackState: selectedSeatFeedbackState,
            );
            return Container(
              padding: const EdgeInsets.all(10),
              decoration: Act0ShellTokensV1.tableRimDecoration(),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: Act0ShellTokensV1.feltDecoration(),
                    ),
                  ),
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(13),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            Act0ShellTokensV1.tableInnerRadius,
                          ),
                          border: Border.all(
                            color: Act0ShellTokensV1.feltLine.withValues(
                              alpha: 0.28,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            Act0ShellTokensV1.tableInnerRadius,
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: <Color>[
                              Colors.white.withValues(
                                alpha: refined ? 0.06 : 0.04,
                              ),
                              Colors.transparent,
                              Colors.black.withValues(
                                alpha: refined ? 0.18 : 0.12,
                              ),
                            ],
                            stops: const <double>[0, 0.34, 1],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Align(
                        child: FractionallySizedBox(
                          widthFactor: refined ? 0.56 : 0.52,
                          heightFactor: refined ? 0.20 : 0.18,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                Act0ShellTokensV1.radiusPill,
                              ),
                              gradient: RadialGradient(
                                center: const Alignment(0, -0.12),
                                radius: refined ? 1.12 : 1.04,
                                colors: <Color>[
                                  Colors.white.withValues(
                                    alpha: refined ? 0.032 : 0.024,
                                  ),
                                  Colors.transparent,
                                  Colors.black.withValues(
                                    alpha: refined ? 0.09 : 0.06,
                                  ),
                                ],
                                stops: const <double>[0, 0.62, 1],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: _CenterPotV1(
                      table: table,
                      highlightedCardIds: highlightedCardIds,
                      onBoardCardTap: () => onBoardCardTap(table),
                      visualVariant: visualVariant,
                      showFocusBadge: showFocusBadge,
                      centerLabelOverride: centerLabelOverride,
                      potLabelOverride: potLabelOverride,
                      toCallLabelOverride: toCallLabelOverride,
                      streetLabelOverride: streetLabelOverride,
                    ),
                  ),
                  if (showRepairCallout &&
                      (table.focusCalloutLabel.isNotEmpty ||
                          interactiveCalloutLabel.isNotEmpty))
                    Positioned(
                      key: const Key('act0_shell_table_repair_callout'),
                      left: width * 0.20,
                      right: width * 0.20,
                      top: height * 0.23,
                      child: _TableRepairCalloutV1(
                        label: table.focusCalloutLabel.isNotEmpty
                            ? table.focusCalloutLabel
                            : interactiveCalloutLabel,
                      ),
                    ),
                  if (completionSummary != null)
                    Positioned(
                      key: const Key('act0_shell_completion_reward_lane'),
                      left: width * 0.29,
                      right: width * 0.29,
                      top: height * (refined ? 0.205 : 0.17),
                      child: IgnorePointer(
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: _CompletionToastV1(
                            summary: completionSummary!,
                            overlayStyle: _CompletionToastOverlayStyleV1.table,
                          ),
                        ),
                      ),
                    ),
                  for (var slot = 0; slot < seats.length; slot++)
                    _BetChipPlacementV1(
                      slot: slot,
                      seat: seats[slot],
                      betOverride: activeSeatId == seats[slot].seatId
                          ? betOverride
                          : null,
                      animateMotion:
                          animateBetMotion &&
                          activeSeatId == seats[slot].seatId &&
                          betOverride != null,
                      tableWidth: width,
                      tableHeight: height,
                      chipSlots: chipSlots,
                      seatSlots: seatSlots,
                      visualVariant: visualVariant,
                    ),
                  for (var slot = 0; slot < seats.length; slot++)
                    _SeatPlacementV1(
                      slot: slot,
                      seat: seats[slot],
                      heroCards: table.heroCards,
                      highlightedCardIds: table.highlightedCardIds,
                      active: activeSeatId == seats[slot].seatId,
                      emphasized: table.highlightedSeatIds.contains(
                        seats[slot].seatId,
                      ),
                      hero:
                          seats[slot].isHero ||
                          seats[slot].seatId == table.heroSeatId,
                      selectable: table.selectableSeatIds.contains(
                        seats[slot].seatId,
                      ),
                      decisionPriceOwnedByTable: decisionPriceOwnedByTable,
                      visualState: _resolveSeatVisualStateV1(
                        seatId: seats[slot].seatId,
                        hero:
                            seats[slot].isHero ||
                            seats[slot].seatId == table.heroSeatId,
                        selectable: table.selectableSeatIds.contains(
                          seats[slot].seatId,
                        ),
                        selected: resolvedSelectedSeatId == seats[slot].seatId,
                        selectionFeedbackState: selectedSeatFeedbackState,
                        focusResolution: focusResolution,
                      ),
                      onChooseSeat: onChooseSeat,
                      tableWidth: width,
                      tableHeight: height,
                      seatSlots: seatSlots,
                      visualVariant: visualVariant,
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String? _resolveActiveSeatId(Act0TableStateV1 table) {
    final explicitRaw = table.activeSeatId;
    if (explicitRaw != null) {
      final explicit = explicitRaw.trim();
      return explicit.isEmpty ? null : explicit;
    }
    for (final seat in table.seats) {
      if (seat.isActive) {
        return seat.seatId;
      }
    }
    return null;
  }
}

class _TableRepairCalloutV1 extends StatelessWidget {
  const _TableRepairCalloutV1({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Act0ShellTokensV1.danger.withValues(alpha: 0.13),
          borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
          border: Border.all(
            color: Act0ShellTokensV1.danger.withValues(alpha: 0.34),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 13,
              color: Act0ShellTokensV1.danger,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                key: const Key('act0_shell_table_repair_callout_text'),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.fade,
                style: Act0ShellTokensV1.label.copyWith(
                  color: Act0ShellTokensV1.text,
                  fontSize: 9.4,
                  letterSpacing: 0,
                  height: 1.08,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DockBackButtonV1 extends StatelessWidget {
  const _DockBackButtonV1({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: OutlinedButton(
        onPressed: onPressed,
        style: Act0ShellTokensV1.quietButtonStyle().copyWith(
          padding: const WidgetStatePropertyAll(EdgeInsets.zero),
          side: WidgetStatePropertyAll(
            BorderSide(color: Act0ShellTokensV1.border.withValues(alpha: 0.82)),
          ),
        ),
        child: const Icon(Icons.arrow_back_ios_new_rounded, size: 14),
      ),
    );
  }
}

List<Offset> _seatSlotsForVariant(
  Act0ShellTableVisualVariantV1 variant, {
  bool compactBottomDockClearance = false,
}) {
  switch (variant) {
    case Act0ShellTableVisualVariantV1.classic:
      return _SeatPlacementV1.defaultSlots;
    case Act0ShellTableVisualVariantV1.refinedDev2:
      if (compactBottomDockClearance) {
        return const <Offset>[
          Offset(0.50, 0.84),
          Offset(0.12, 0.68),
          Offset(0.12, 0.33),
          Offset(0.50, 0.12),
          Offset(0.88, 0.33),
          Offset(0.88, 0.68),
        ];
      }
      return const <Offset>[
        Offset(0.50, 0.91),
        Offset(0.12, 0.75),
        Offset(0.12, 0.33),
        Offset(0.50, 0.12),
        Offset(0.88, 0.33),
        Offset(0.88, 0.75),
      ];
  }
}

List<Offset> _chipSlotsForVariant(
  Act0ShellTableVisualVariantV1 variant, {
  bool compactBottomDockClearance = false,
}) {
  switch (variant) {
    case Act0ShellTableVisualVariantV1.classic:
      return _BetChipPlacementV1.defaultChipSlots;
    case Act0ShellTableVisualVariantV1.refinedDev2:
      if (compactBottomDockClearance) {
        return const <Offset>[
          Offset(0.50, 0.64),
          Offset(0.24, 0.58),
          Offset(0.26, 0.30),
          Offset(0.50, 0.29),
          Offset(0.74, 0.30),
          Offset(0.76, 0.58),
        ];
      }
      return const <Offset>[
        Offset(0.50, 0.71),
        Offset(0.24, 0.64),
        Offset(0.26, 0.30),
        Offset(0.50, 0.29),
        Offset(0.74, 0.30),
        Offset(0.76, 0.64),
      ];
  }
}

List<Act0SeatStateV1> _visualSeatOrder(List<Act0SeatStateV1> seats) {
  final canonicalOrder = _inferCanonicalSeatOrder(seats);
  final byLabel = <String, Act0SeatStateV1>{
    for (final seat in seats) seat.seatLabel.toUpperCase(): seat,
  };
  final hero = seats.where((seat) => seat.isHero).toList(growable: false);
  final heroLabel = hero.isEmpty
      ? canonicalOrder.first
      : hero.first.seatLabel.toUpperCase();
  final heroIndex = canonicalOrder.indexOf(heroLabel);
  final start = heroIndex < 0 ? 0 : heroIndex;
  final canonicalSeats = <Act0SeatStateV1>[
    for (var i = 0; i < canonicalOrder.length; i++)
      if (byLabel[canonicalOrder[(start + i) % canonicalOrder.length]] != null)
        byLabel[canonicalOrder[(start + i) % canonicalOrder.length]]!,
  ];
  if (canonicalSeats.isEmpty) {
    final others = seats.where((seat) => !seat.isHero).toList(growable: false);
    return <Act0SeatStateV1>[...hero, ...others];
  }
  final canonicalIds = canonicalSeats.map((seat) => seat.seatId).toSet();
  return <Act0SeatStateV1>[
    ...canonicalSeats,
    for (final seat in seats)
      if (!canonicalIds.contains(seat.seatId)) seat,
  ];
}

List<String> _inferCanonicalSeatOrder(List<Act0SeatStateV1> seats) {
  final labels = seats.map((seat) => seat.seatLabel.toUpperCase()).toSet();
  for (final format in Act0TableFormatV1.values) {
    final order = act0CanonicalSeatOrderForFormatV1(format);
    if (labels.every(order.contains)) {
      return order;
    }
  }
  return act0CanonicalSeatOrderForFormatV1(Act0TableFormatV1.sixMax);
}

class _CenterPotV1 extends StatelessWidget {
  const _CenterPotV1({
    required this.table,
    required this.highlightedCardIds,
    required this.onBoardCardTap,
    required this.visualVariant,
    this.showFocusBadge = true,
    this.centerLabelOverride,
    this.potLabelOverride,
    this.toCallLabelOverride,
    this.streetLabelOverride,
  });

  final Act0TableStateV1 table;
  final List<String> highlightedCardIds;
  final VoidCallback onBoardCardTap;
  final Act0ShellTableVisualVariantV1 visualVariant;
  final bool showFocusBadge;
  final String? centerLabelOverride;
  final String? potLabelOverride;
  final String? toCallLabelOverride;
  final String? streetLabelOverride;

  @override
  Widget build(BuildContext context) {
    final refined = visualVariant == Act0ShellTableVisualVariantV1.refinedDev2;
    final resolvedCenterLabel = (centerLabelOverride ?? table.centerLabel)
        .trim();
    final shouldShowFocusBadge =
        showFocusBadge &&
        resolvedCenterLabel.isNotEmpty &&
        !(refined &&
            (resolvedCenterLabel == 'Blinds posted' ||
                resolvedCenterLabel == 'Action on hero'));
    final streetLabel = act0RuntimeLocalizedStreetLabelV1(
      context,
      streetLabelOverride ?? table.streetLabel,
    ).toUpperCase();
    final resolvedToCallLabel = (toCallLabelOverride ?? table.toCallLabel)
        .trim();
    return Center(
      child: Container(
        key: const Key('act0_shell_center_info_card'),
        width: refined ? 182 : Act0ShellTokensV1.centerInfoWidth,
        padding: EdgeInsets.symmetric(
          horizontal: refined ? 6 : 4,
          vertical: refined ? 4 : 3,
        ),
        decoration: refined
            ? BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Colors.white.withValues(alpha: 0.03),
                    Colors.black.withValues(alpha: 0.13),
                    Colors.black.withValues(alpha: 0.18),
                  ],
                ),
                borderRadius: BorderRadius.circular(
                  Act0ShellTokensV1.radiusCard,
                ),
                border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 6,
              runSpacing: 4,
              children: [
                if (shouldShowFocusBadge)
                  _CenterInfoPillV1(
                    key: const Key('act0_shell_center_focus_badge'),
                    label: act0RuntimeLocalizedCenterLabelV1(
                      context,
                      resolvedCenterLabel,
                    ),
                    tone: Act0ShellTokensV1.primary,
                    icon: Icons.visibility_rounded,
                    compact: refined,
                  ),
                if (refined)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 2,
                      vertical: 1,
                    ),
                    child: Text(
                      streetLabel,
                      key: const Key('act0_shell_center_street_badge'),
                      style: Act0ShellTokensV1.label.copyWith(
                        color: Act0ShellTokensV1.gold.withValues(alpha: 0.92),
                        fontSize: 8.1,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  )
                else
                  _CenterInfoPillV1(
                    key: const Key('act0_shell_center_street_badge'),
                    label: streetLabel,
                    tone: Act0ShellTokensV1.gold,
                    icon: Icons.layers_rounded,
                    compact: refined,
                  ),
              ],
            ),
            if (table.boardCards.isNotEmpty) ...[
              const SizedBox(height: 5),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < table.boardCards.length; i++) ...[
                      _BoardCardV1(
                        card: table.boardCards[i],
                        cardId: 'board_$i',
                        highlighted: highlightedCardIds.contains('board_$i'),
                        onTap: onBoardCardTap,
                      ),
                      if (i < table.boardCards.length - 1)
                        const SizedBox(width: 5),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 6),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 5,
              runSpacing: 3,
              children: [
                _CenterInfoPillV1(
                  key: const Key('act0_shell_center_pot_stat'),
                  label: act0RuntimeLocalizedPotLabelV1(
                    context,
                    potLabelOverride ?? table.potLabel,
                  ),
                  tone: Act0ShellTokensV1.text,
                  icon: Icons.casino_rounded,
                  compact: refined,
                  filled: true,
                  pulse: table.actionTrail.isNotEmpty,
                ),
                if (resolvedToCallLabel.isNotEmpty)
                  _CenterInfoPillV1(
                    key: const Key('act0_shell_center_to_call_stat'),
                    label: act0RuntimeLocalizedToCallLabelV1(
                      context,
                      resolvedToCallLabel,
                    ),
                    tone: Act0ShellTokensV1.info,
                    icon: Icons.arrow_downward_rounded,
                    compact: refined,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterInfoPillV1 extends StatelessWidget {
  const _CenterInfoPillV1({
    super.key,
    required this.label,
    required this.tone,
    required this.icon,
    this.compact = false,
    this.filled = false,
    this.pulse = false,
  });

  final String label;
  final Color tone;
  final IconData icon;
  final bool compact;
  final bool filled;
  final bool pulse;

  @override
  Widget build(BuildContext context) {
    final pill = Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 7 : 9,
        vertical: compact ? 3.5 : 4.5,
      ),
      decoration: BoxDecoration(
        color: filled
            ? tone.withValues(alpha: 0.10)
            : Colors.black.withValues(alpha: compact ? 0.24 : 0.34),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
        border: Border.all(
          color: filled
              ? tone.withValues(alpha: 0.20)
              : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 11 : 12, color: tone),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 2,
              style: Act0ShellTokensV1.label.copyWith(
                color: filled ? tone : Act0ShellTokensV1.text,
                fontSize: compact ? 8.6 : 9.2,
                letterSpacing: compact ? 0.1 : 0.3,
              ),
            ),
          ),
        ],
      ),
    );
    if (!pulse) {
      return pill;
    }
    return TweenAnimationBuilder<double>(
      key: Key('act0_shell_center_pot_pulse_$label'),
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 760),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final settle = (1 - value).clamp(0.0, 1.0);
        return Transform.scale(
          scale: 1 + (0.055 * settle),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Act0ShellTokensV1.gold.withValues(
                    alpha: 0.14 * settle,
                  ),
                  blurRadius: 12 * settle,
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: pill,
    );
  }
}

class _BetChipPlacementV1 extends StatelessWidget {
  const _BetChipPlacementV1({
    required this.slot,
    required this.seat,
    required this.tableWidth,
    required this.tableHeight,
    required this.chipSlots,
    required this.seatSlots,
    required this.visualVariant,
    required this.animateMotion,
    this.betOverride,
  });

  final int slot;
  final Act0SeatStateV1 seat;
  final double tableWidth;
  final double tableHeight;
  final List<Offset> chipSlots;
  final List<Offset> seatSlots;
  final Act0ShellTableVisualVariantV1 visualVariant;
  final bool animateMotion;

  /// When non-null, shown instead of seat.bet (used during action trail playback).
  final Act0SeatBetStateV1? betOverride;

  static const List<Offset> defaultChipSlots = <Offset>[
    Offset(0.50, 0.75),
    Offset(0.055, 0.60),
    Offset(0.055, 0.50),
    Offset(0.50, 0.25),
    Offset(0.945, 0.50),
    Offset(0.945, 0.60),
  ];

  @override
  Widget build(BuildContext context) {
    final bet = betOverride ?? seat.bet;
    if (bet == null || seat.isFolded) {
      return const SizedBox.shrink();
    }
    final safeSlot = slot.clamp(0, chipSlots.length - 1);
    final chipPoint = chipSlots[safeSlot];
    final seatPoint = seatSlots[safeSlot.clamp(0, seatSlots.length - 1)];
    final child = _BetChipV1(
      bet: bet,
      compact: visualVariant == Act0ShellTableVisualVariantV1.refinedDev2,
    );
    if (!animateMotion) {
      return Positioned(
        left: tableWidth * chipPoint.dx,
        top: tableHeight * chipPoint.dy,
        child: FractionalTranslation(
          translation: const Offset(-0.5, -0.5),
          child: IgnorePointer(child: child),
        ),
      );
    }
    return TweenAnimationBuilder<double>(
      key: Key('act0_shell_bet_chip_motion_${seat.seatId}_${bet.label}'),
      tween: Tween<double>(begin: 0, end: 1),
      duration: _chipMotionDuration(bet.kind),
      curve: bet.kind == Act0SeatBetKindV1.post
          ? Curves.easeInOutCubic
          : Curves.easeOutCubic,
      builder: (context, value, child) {
        final point = Offset.lerp(seatPoint, chipPoint, value) ?? chipPoint;
        return Positioned(
          left: tableWidth * point.dx,
          top: tableHeight * point.dy,
          child: FractionalTranslation(
            translation: const Offset(-0.5, -0.5),
            child: IgnorePointer(
              child: Transform.scale(
                scale: 0.94 + (0.06 * value),
                child: Opacity(opacity: 0.72 + (0.28 * value), child: child),
              ),
            ),
          ),
        );
      },
      child: child,
    );
  }

  Duration _chipMotionDuration(Act0SeatBetKindV1 kind) {
    return switch (kind) {
      Act0SeatBetKindV1.post => const Duration(milliseconds: 380),
      Act0SeatBetKindV1.call => const Duration(milliseconds: 360),
      Act0SeatBetKindV1.bet ||
      Act0SeatBetKindV1.raise ||
      Act0SeatBetKindV1.allIn => const Duration(milliseconds: 440),
    };
  }
}

class _SeatPlacementV1 extends StatelessWidget {
  const _SeatPlacementV1({
    required this.slot,
    required this.seat,
    required this.heroCards,
    required this.highlightedCardIds,
    required this.active,
    required this.emphasized,
    required this.hero,
    required this.selectable,
    required this.visualState,
    required this.decisionPriceOwnedByTable,
    required this.onChooseSeat,
    required this.tableWidth,
    required this.tableHeight,
    required this.seatSlots,
    required this.visualVariant,
  });

  final int slot;
  final Act0SeatStateV1 seat;
  final List<Act0CardStateV1> heroCards;
  final List<String> highlightedCardIds;
  final bool active;
  final bool emphasized;
  final bool hero;
  final bool selectable;
  final _SeatVisualStateV1 visualState;
  final bool decisionPriceOwnedByTable;
  final ValueChanged<String>? onChooseSeat;
  final double tableWidth;
  final double tableHeight;
  final List<Offset> seatSlots;
  final Act0ShellTableVisualVariantV1 visualVariant;

  static const List<Offset> defaultSlots = <Offset>[
    Offset(0.50, 0.90),
    Offset(0.08, 0.72),
    Offset(0.06, 0.36),
    Offset(0.50, 0.08),
    Offset(0.94, 0.36),
    Offset(0.92, 0.72),
  ];

  @override
  Widget build(BuildContext context) {
    final point = seatSlots[slot.clamp(0, seatSlots.length - 1)];
    return Positioned(
      left: tableWidth * point.dx,
      top: tableHeight * point.dy,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: _SeatNodeV1(
          seat: seat,
          heroCards: heroCards,
          highlightedCardIds: highlightedCardIds,
          active: active,
          emphasized: emphasized,
          hero: hero,
          selectable: selectable,
          visualState: visualState,
          decisionPriceOwnedByTable: decisionPriceOwnedByTable,
          visualVariant: visualVariant,
          onTap: selectable && onChooseSeat != null
              ? () => onChooseSeat!(seat.seatId)
              : null,
          compact: slot != 0,
        ),
      ),
    );
  }
}

class _SeatNodeV1 extends StatelessWidget {
  const _SeatNodeV1({
    required this.seat,
    required this.heroCards,
    required this.highlightedCardIds,
    required this.active,
    required this.emphasized,
    required this.hero,
    required this.selectable,
    required this.visualState,
    required this.decisionPriceOwnedByTable,
    required this.visualVariant,
    this.onTap,
    this.compact = false,
  });

  final Act0SeatStateV1 seat;
  final List<Act0CardStateV1> heroCards;
  final List<String> highlightedCardIds;
  final bool active;
  final bool emphasized;
  final bool hero;
  final bool selectable;
  final _SeatVisualStateV1 visualState;
  final bool decisionPriceOwnedByTable;
  final Act0ShellTableVisualVariantV1 visualVariant;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final refined = visualVariant == Act0ShellTableVisualVariantV1.refinedDev2;
    final seatVisualState = visualState;
    final markerDisplay = _resolveSeatMarkerDisplayV1(
      context,
      seat: seat,
      active: active,
      hero: hero,
      refined: refined,
      decisionPriceOwnedByTable: decisionPriceOwnedByTable,
    );
    final highlighted = switch (seatVisualState) {
      _SeatVisualStateV1.passive || _SeatVisualStateV1.selectable => false,
      _ => true,
    };
    final useSlimRefinedSeat = refined && !hero;
    final folded = seat.isFolded;
    final borderColor = _seatBorderColorV1(seatVisualState, refined: refined);
    final ringColor = _seatRingColorV1(seatVisualState);
    final shouldShowRing =
        seatVisualState != _SeatVisualStateV1.passive &&
        seatVisualState != _SeatVisualStateV1.selectable;
    final visibleCards = hero ? heroCards : seat.holeCards;
    final showFaceDown =
        !hero &&
        seat.isOccupied &&
        seat.isInHand &&
        !folded &&
        seat.cardsVisibleMode == Act0CardsVisibleModeV1.faceDown &&
        visibleCards.isNotEmpty;
    final showFaceUp =
        !hero &&
        seat.isOccupied &&
        seat.isInHand &&
        !folded &&
        seat.cardsVisibleMode == Act0CardsVisibleModeV1.faceUp &&
        visibleCards.isNotEmpty;
    final occupiedOpacity = !seat.isOccupied
        ? 0.42
        : folded || !seat.isInHand
        ? 0.58
        : 1.0;
    final node = Container(
      key: Key('act0_shell_seat_node_${seat.seatId}'),
      constraints: BoxConstraints(
        minWidth: compact
            ? Act0ShellTokensV1.compactSeatMinWidth
            : Act0ShellTokensV1.seatMinWidth,
      ),
      child: Opacity(
        opacity: occupiedOpacity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hero && visibleCards.isNotEmpty) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < visibleCards.length; i++) ...[
                    _CardV1(
                      card: visibleCards[i],
                      cardId: 'hero_$i',
                      highlighted: highlightedCardIds.contains('hero_$i'),
                    ),
                    if (i < visibleCards.length - 1) const SizedBox(width: 4),
                  ],
                ],
              ),
              const SizedBox(height: 3),
            ] else if (showFaceDown) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < visibleCards.length; i++) ...[
                    const _MiniCardBackV1(),
                    if (i < visibleCards.length - 1) const SizedBox(width: 3),
                  ],
                ],
              ),
              const SizedBox(height: 3),
            ] else if (showFaceUp) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < visibleCards.length; i++) ...[
                    _CardV1(
                      card: visibleCards[i],
                      cardId: '${seat.seatId}_$i',
                      highlighted: highlightedCardIds.contains(
                        '${seat.seatId}_$i',
                      ),
                    ),
                    if (i < visibleCards.length - 1) const SizedBox(width: 3),
                  ],
                ],
              ),
              const SizedBox(height: 3),
            ],
            if (folded) ...[const _FoldedBadgeV1(), const SizedBox(height: 3)],
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: compact
                        ? (refined ? 5 : 7)
                        : (useSlimRefinedSeat ? 7 : (refined ? 9 : 8)),
                    vertical: useSlimRefinedSeat ? 5 : (refined ? 6 : 5),
                  ),
                  decoration: BoxDecoration(
                    color: refined
                        ? (seatVisualState == _SeatVisualStateV1.hero
                              ? Act0ShellTokensV1.runnerPanelSurface
                              : highlighted
                              ? Act0ShellTokensV1.surface2
                              : Act0ShellTokensV1.surface.withValues(
                                  alpha: 0.78,
                                ))
                        : highlighted
                        ? Act0ShellTokensV1.surface2
                        : Act0ShellTokensV1.surface.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(
                      Act0ShellTokensV1.radiusSm,
                    ),
                    border: Border.all(
                      color: borderColor.withValues(alpha: refined ? 0.86 : 1),
                      width: refined ? 1.15 : 1,
                    ),
                    boxShadow: <BoxShadow>[
                      if (shouldShowRing)
                        BoxShadow(
                          color: ringColor.withValues(
                            alpha: seatVisualState == _SeatVisualStateV1.hero
                                ? 0.12
                                : 0.16,
                          ),
                          blurRadius: refined ? 10 : 14,
                        ),
                      if (!shouldShowRing &&
                          seatVisualState == _SeatVisualStateV1.hero)
                        BoxShadow(
                          color: Act0ShellTokensV1.primary.withValues(
                            alpha: 0.15,
                          ),
                          blurRadius: refined ? 9 : 12,
                        ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: compact
                            ? (refined ? 18 : 22)
                            : (useSlimRefinedSeat ? 22 : (refined ? 26 : 24)),
                        height: compact
                            ? (refined ? 18 : 22)
                            : (useSlimRefinedSeat ? 22 : (refined ? 26 : 24)),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: hero
                              ? Act0ShellTokensV1.primary
                              : refined
                              ? (seatVisualState ==
                                        _SeatVisualStateV1.selectable
                                    ? Act0ShellTokensV1.info.withValues(
                                        alpha: 0.10,
                                      )
                                    : Act0ShellTokensV1.surface2)
                              : Act0ShellTokensV1.surface3,
                          borderRadius: BorderRadius.circular(
                            refined
                                ? Act0ShellTokensV1.radiusXs
                                : Act0ShellTokensV1.radiusPill,
                          ),
                          border: refined && !hero
                              ? Border.all(
                                  color: Act0ShellTokensV1.border.withValues(
                                    alpha: 0.72,
                                  ),
                                )
                              : null,
                        ),
                        child: hero
                            ? Text(
                                'Y',
                                style: Act0ShellTokensV1.label.copyWith(
                                  color: Act0ShellTokensV1.onPrimary,
                                  fontSize: refined ? 8.5 : 9,
                                  letterSpacing: 0,
                                ),
                              )
                            : Icon(
                                seat.isOccupied
                                    ? Icons.person_rounded
                                    : Icons.circle_outlined,
                                size: useSlimRefinedSeat
                                    ? 11
                                    : (refined ? 12 : 13),
                                color:
                                    seatVisualState ==
                                        _SeatVisualStateV1.selectable
                                    ? Act0ShellTokensV1.info.withValues(
                                        alpha: 0.56,
                                      )
                                    : refined
                                    ? Act0ShellTokensV1.textDim
                                    : Act0ShellTokensV1.textMuted,
                              ),
                      ),
                      SizedBox(width: useSlimRefinedSeat ? 4 : 5),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            act0RuntimeLocalizedSeatPrimaryLabelV1(
                              context,
                              seat: seat,
                              hero: hero,
                              refined: refined,
                            ),
                            maxLines: 2,
                            style: Act0ShellTokensV1.label.copyWith(
                              color: refined && !hero
                                  ? Act0ShellTokensV1.textMuted
                                  : Act0ShellTokensV1.text,
                              fontSize: useSlimRefinedSeat
                                  ? 8.5
                                  : (refined ? 9.0 : 10),
                              letterSpacing: refined ? 0.1 : 0.4,
                            ),
                          ),
                          if (markerDisplay.subLabel != null)
                            Text(
                              markerDisplay.subLabel!,
                              key: Key(
                                'act0_shell_seat_sublabel_${seat.seatId}',
                              ),
                              style: Act0ShellTokensV1.muted.copyWith(
                                fontSize: useSlimRefinedSeat
                                    ? 8.0
                                    : (refined ? 8.5 : 9),
                                color: refined && !hero
                                    ? Act0ShellTokensV1.textDim
                                    : Act0ShellTokensV1.textMuted,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (markerDisplay.markers.isNotEmpty)
                  _SeatMarkerPlacementV1(
                    seatId: seat.seatId,
                    leftSide: seat.seatLabel == 'SB' || seat.seatLabel == 'BB',
                    markers: markerDisplay.markers,
                    hero: hero,
                    visualVariant: visualVariant,
                  ),
                if (shouldShowRing)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        key: const Key('act0_shell_active_seat_ring'),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            Act0ShellTokensV1.radiusSm,
                          ),
                          border: Border.all(
                            color: ringColor.withValues(alpha: 0.42),
                            width: 2,
                          ),
                        ),
                        child: SizedBox(
                          key: Key(
                            'act0_shell_active_seat_ring_${seat.seatId}',
                          ),
                        ),
                      ),
                    ),
                  ),
                if (seatVisualState != _SeatVisualStateV1.passive)
                  Positioned(
                    child: SizedBox(
                      key: Key(
                        'act0_shell_seat_state_${seat.seatId}_${seatVisualState.name}',
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
    if (onTap == null) {
      return node;
    }
    return GestureDetector(
      key: Key('act0_shell_seat_tap_${seat.seatId}'),
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: node,
    );
  }
}

enum _SeatSelectionFeedbackStateV1 { none, wrong, confirmed }

enum _PrimarySeatFocusKindV1 { none, active, target }

class _PrimarySeatFocusResolutionV1 {
  const _PrimarySeatFocusResolutionV1({required this.kind, this.seatId});

  final _PrimarySeatFocusKindV1 kind;
  final String? seatId;
}

enum _SeatVisualStateV1 {
  wrongSelected,
  confirmedSelected,
  hero,
  activeFocus,
  targetFocus,
  selectable,
  passive,
}

enum _SeatMarkerKindV1 { dealer, smallBlind, bigBlind, aggressor, act }

class _SeatMarkerDisplayV1 {
  const _SeatMarkerDisplayV1({required this.markers, this.subLabel});

  final List<_SeatMarkerKindV1> markers;
  final String? subLabel;
}

_PrimarySeatFocusResolutionV1 _resolvePrimarySeatFocusV1({
  required String? activeSeatId,
  required List<String> highlightedSeatIds,
  required List<String> selectableSeatIds,
  required String? selectedSeatId,
  required _SeatSelectionFeedbackStateV1 selectionFeedbackState,
}) {
  final normalizedHighlights = highlightedSeatIds
      .map((id) => id.trim())
      .where((id) => id.isNotEmpty)
      .toList(growable: false);
  final normalizedSelectable = selectableSeatIds
      .map((id) => id.trim())
      .where((id) => id.isNotEmpty)
      .toSet();
  final explicitTargets = normalizedHighlights
      .where((id) => normalizedSelectable.contains(id))
      .toList(growable: false);
  final selected = (selectedSeatId ?? '').trim();

  if (selectionFeedbackState == _SeatSelectionFeedbackStateV1.confirmed &&
      selected.isNotEmpty) {
    return const _PrimarySeatFocusResolutionV1(
      kind: _PrimarySeatFocusKindV1.none,
    );
  }

  if (selectionFeedbackState == _SeatSelectionFeedbackStateV1.wrong) {
    final repairTargets = normalizedHighlights
        .where((id) => id != selected)
        .toList(growable: false);
    if (repairTargets.length == 1) {
      return _PrimarySeatFocusResolutionV1(
        kind: _PrimarySeatFocusKindV1.target,
        seatId: repairTargets.first,
      );
    }
  }

  final active = (activeSeatId ?? '').trim();
  if (active.isNotEmpty) {
    return _PrimarySeatFocusResolutionV1(
      kind: _PrimarySeatFocusKindV1.active,
      seatId: active,
    );
  }

  if (explicitTargets.length == 1) {
    return _PrimarySeatFocusResolutionV1(
      kind: _PrimarySeatFocusKindV1.target,
      seatId: explicitTargets.first,
    );
  }

  if (normalizedHighlights.length == 1) {
    return _PrimarySeatFocusResolutionV1(
      kind: _PrimarySeatFocusKindV1.target,
      seatId: normalizedHighlights.first,
    );
  }

  return const _PrimarySeatFocusResolutionV1(
    kind: _PrimarySeatFocusKindV1.none,
  );
}

_SeatVisualStateV1 _resolveSeatVisualStateV1({
  required String seatId,
  required bool hero,
  required bool selectable,
  required bool selected,
  required _SeatSelectionFeedbackStateV1 selectionFeedbackState,
  required _PrimarySeatFocusResolutionV1 focusResolution,
}) {
  if (selected &&
      selectionFeedbackState == _SeatSelectionFeedbackStateV1.wrong) {
    return _SeatVisualStateV1.wrongSelected;
  }
  if (selected &&
      selectionFeedbackState == _SeatSelectionFeedbackStateV1.confirmed) {
    return _SeatVisualStateV1.confirmedSelected;
  }
  if (hero) {
    return _SeatVisualStateV1.hero;
  }
  if (focusResolution.kind == _PrimarySeatFocusKindV1.active &&
      focusResolution.seatId == seatId) {
    return _SeatVisualStateV1.activeFocus;
  }
  if (focusResolution.kind == _PrimarySeatFocusKindV1.target &&
      focusResolution.seatId == seatId) {
    return _SeatVisualStateV1.targetFocus;
  }
  if (selectable) {
    return _SeatVisualStateV1.selectable;
  }
  return _SeatVisualStateV1.passive;
}

bool _seatHasBlindPostChipV1(Act0SeatStateV1 seat) {
  final bet = seat.bet;
  return bet != null &&
      bet.kind == Act0SeatBetKindV1.post &&
      !seat.isFolded &&
      (bet.label == 'SB' || bet.label == 'BB' || bet.label == 'POST');
}

bool _seatCurrentBetIsOwnedByChipV1(Act0SeatStateV1 seat) {
  final bet = seat.bet;
  final currentBetLabel = seat.currentBetLabel?.trim() ?? '';
  if (bet == null || currentBetLabel.isEmpty || seat.isFolded) {
    return false;
  }
  return currentBetLabel == bet.amountLabel.trim();
}

String _localizedSeatRoleLabelV1(
  BuildContext context, {
  required String atomId,
  required String fallback,
}) => act0LocalizedSurfaceAtomV1(context, atomId, fallback: fallback);

_SeatMarkerDisplayV1 _resolveSeatMarkerDisplayV1(
  BuildContext context, {
  required Act0SeatStateV1 seat,
  required bool active,
  required bool hero,
  required bool refined,
  required bool decisionPriceOwnedByTable,
}) {
  final markers = <_SeatMarkerKindV1>[
    if (seat.isDealerButton) _SeatMarkerKindV1.dealer,
    if (!refined && seat.isSmallBlind && !_seatHasBlindPostChipV1(seat))
      _SeatMarkerKindV1.smallBlind,
    if (!refined && seat.isBigBlind && !_seatHasBlindPostChipV1(seat))
      _SeatMarkerKindV1.bigBlind,
    if (seat.isLastAggressor && !active) _SeatMarkerKindV1.aggressor,
    if (active && !hero) _SeatMarkerKindV1.act,
  ];

  if (!hero && active) {
    if (decisionPriceOwnedByTable) {
      return _SeatMarkerDisplayV1(markers: markers);
    }
    final toActAmountLabel =
        (seat.currentBetLabel ?? seat.blindAmountLabel ?? '').trim();
    final toAct = _localizedSeatRoleLabelV1(
      context,
      atomId: 'table_word_to_act',
      fallback: 'To act',
    );
    return _SeatMarkerDisplayV1(
      markers: markers,
      subLabel: toActAmountLabel.isEmpty ? toAct : '$toAct: $toActAmountLabel',
    );
  }

  final stackLabel = (seat.stackLabel ?? '').trim();
  if (stackLabel.isNotEmpty) {
    return _SeatMarkerDisplayV1(markers: markers, subLabel: stackLabel);
  }

  if (_seatCurrentBetIsOwnedByChipV1(seat) || _seatHasBlindPostChipV1(seat)) {
    return _SeatMarkerDisplayV1(markers: markers);
  }

  final currentBetLabel = (seat.currentBetLabel ?? '').trim();
  if (currentBetLabel.isNotEmpty) {
    return _SeatMarkerDisplayV1(markers: markers, subLabel: currentBetLabel);
  }

  final blindAmountLabel = (seat.blindAmountLabel ?? '').trim();
  if (blindAmountLabel.isNotEmpty && !_seatHasBlindPostChipV1(seat)) {
    return _SeatMarkerDisplayV1(markers: markers, subLabel: blindAmountLabel);
  }

  if (refined && !hero) {
    if (seat.isDealerButton) {
      return _SeatMarkerDisplayV1(markers: markers);
    }
    if (seat.isSmallBlind) {
      return _SeatMarkerDisplayV1(
        markers: markers,
        subLabel: _localizedSeatRoleLabelV1(
          context,
          atomId: 'table_word_small_blind',
          fallback: 'Small blind',
        ),
      );
    }
    if (seat.isBigBlind) {
      return _SeatMarkerDisplayV1(
        markers: markers,
        subLabel: _localizedSeatRoleLabelV1(
          context,
          atomId: 'table_word_big_blind',
          fallback: 'Big blind',
        ),
      );
    }
  }

  return _SeatMarkerDisplayV1(markers: markers);
}

Color _seatBorderColorV1(_SeatVisualStateV1 state, {required bool refined}) {
  return switch (state) {
    _SeatVisualStateV1.wrongSelected => Act0ShellTokensV1.danger,
    _SeatVisualStateV1.confirmedSelected => Act0ShellTokensV1.primary,
    _SeatVisualStateV1.hero => Act0ShellTokensV1.primary,
    _SeatVisualStateV1.activeFocus => Act0ShellTokensV1.gold,
    _SeatVisualStateV1.targetFocus => Act0ShellTokensV1.gold,
    _SeatVisualStateV1.selectable =>
      refined
          ? Act0ShellTokensV1.info.withValues(alpha: 0.42)
          : Act0ShellTokensV1.info.withValues(alpha: 0.58),
    _SeatVisualStateV1.passive => Act0ShellTokensV1.border,
  };
}

Color _seatRingColorV1(_SeatVisualStateV1 state) {
  return switch (state) {
    _SeatVisualStateV1.wrongSelected => Act0ShellTokensV1.danger,
    _SeatVisualStateV1.confirmedSelected => Act0ShellTokensV1.primary,
    _SeatVisualStateV1.hero => Act0ShellTokensV1.primary,
    _SeatVisualStateV1.activeFocus => Act0ShellTokensV1.gold,
    _SeatVisualStateV1.targetFocus => Act0ShellTokensV1.gold,
    _SeatVisualStateV1.selectable => Act0ShellTokensV1.info,
    _SeatVisualStateV1.passive => Act0ShellTokensV1.border,
  };
}

enum _ActionTrailVariantV1 { compactContext, replay }

enum _RunnerBottomOwnerV1 { coachRail, questionPrompt, feedback }

class _RunnerBottomContextV1 {
  const _RunnerBottomContextV1({
    required this.owner,
    required this.isTrailHistory,
    required this.promptOwnsDecisionContext,
    required this.showActionTrail,
    this.actionTrailVariant,
    required this.taskLabel,
    required this.questionBadgeLabel,
    this.promptSupportLine,
    this.feedbackContextLabels = const <String>[],
  });

  final _RunnerBottomOwnerV1 owner;
  final bool isTrailHistory;
  final bool promptOwnsDecisionContext;
  final bool showActionTrail;
  final _ActionTrailVariantV1? actionTrailVariant;
  final String taskLabel;
  final String questionBadgeLabel;
  final String? promptSupportLine;
  final List<String> feedbackContextLabels;
}

class _CenterStatDisplayV1 {
  const _CenterStatDisplayV1({
    required this.centerCueLabel,
    required this.potLabel,
    required this.toCallLabel,
  });

  final String centerCueLabel;
  final String potLabel;
  final String toCallLabel;

  bool get ownsDecisionPrice => toCallLabel.trim().isNotEmpty;
}

bool _isActiveAssessmentStateV1({
  required bool isTeaching,
  required bool isTheory,
  required bool isReview,
  required Act0RunnerStateV1 runner,
}) {
  return !isTeaching &&
      !isTheory &&
      !isReview &&
      (runner.selectedOptionId ?? '').trim().isEmpty;
}

String _normalizeAnswerLeakTextV1(String text) {
  return text
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9 ]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

bool _isAnswerBearingTableCueV1({
  required String cueLabel,
  required String question,
  required List<Act0RunnerOptionV1> options,
}) {
  final normalizedCue = _normalizeAnswerLeakTextV1(cueLabel);
  if (normalizedCue.isEmpty) {
    return false;
  }
  final normalizedQuestion = _normalizeAnswerLeakTextV1(question);
  final optionLabels = <String>{
    for (final option in options) ...[
      _normalizeAnswerLeakTextV1(option.label),
      _normalizeAnswerLeakTextV1(option.preferredLabel),
      _normalizeAnswerLeakTextV1(option.betterAnswerLabel),
    ],
  }..remove('');

  final cueTokens = normalizedCue.split(' ').where((token) => token.isNotEmpty);
  if (optionLabels.contains(normalizedCue)) {
    return true;
  }
  for (final optionLabel in optionLabels) {
    if (optionLabel.isEmpty) {
      continue;
    }
    if (normalizedCue.contains(optionLabel) ||
        optionLabel.contains(normalizedCue)) {
      return true;
    }
  }
  final categoryQuestions = <String>[
    'which bucket',
    'what bucket',
    'which made hand',
    'what made hand',
    'which hand category',
    'what hand category',
    'which hand class',
  ];
  if (categoryQuestions.any(normalizedQuestion.contains)) {
    return cueTokens.any(optionLabels.contains);
  }
  return false;
}

bool _looksLikeActionDecisionPromptV1(
  String question, {
  required Act0TaskFamilyV1? taskFamily,
  required bool hasSeatTargets,
}) {
  if (hasSeatTargets) {
    return false;
  }
  if (taskFamily == Act0TaskFamilyV1.decision ||
      taskFamily == Act0TaskFamilyV1.sizing ||
      taskFamily == Act0TaskFamilyV1.repair) {
    return true;
  }
  final normalizedQuestion = _normalizeAnswerLeakTextV1(question);
  return normalizedQuestion.contains('what is the') ||
      normalizedQuestion.contains('best action') ||
      normalizedQuestion.contains('simple action') ||
      normalizedQuestion.contains('simple response') ||
      normalizedQuestion.contains('clean action') ||
      normalizedQuestion.contains('clean response') ||
      normalizedQuestion.contains('disciplined action') ||
      normalizedQuestion.contains('disciplined response') ||
      normalizedQuestion.contains('first in action') ||
      normalizedQuestion.contains('response');
}

bool _isAnswerLeadingTableCueV1(
  String cueLabel, {
  required String question,
  required Act0TaskFamilyV1? taskFamily,
  required bool hasSeatTargets,
}) {
  final rawCue = cueLabel.trim().toLowerCase();
  final normalizedCue = _normalizeAnswerLeakTextV1(cueLabel);
  if (normalizedCue.isEmpty) {
    return false;
  }
  final cueKeywords = <String>[
    'weak continue',
    'strong continue',
    'easy fold',
    'call spot',
    'value spot',
    'bluff catch',
    'fold pressure',
    'low fold pressure',
    'one third',
    'half pot',
    'pot size',
    'range bucket',
    'value action',
    'bucket',
  ];
  final isDecisionPrompt = _looksLikeActionDecisionPromptV1(
    question,
    taskFamily: taskFamily,
    hasSeatTargets: hasSeatTargets,
  );
  if (rawCue.contains('?')) {
    return true;
  }
  if (cueKeywords.any(normalizedCue.contains)) {
    return true;
  }
  if (isDecisionPrompt) {
    const decisionWords = <String>[
      'continue',
      'fold',
      'call',
      'raise',
      'value',
      'bluff',
      'pressure',
      'sizing',
    ];
    if (decisionWords.any(normalizedCue.contains)) {
      return true;
    }
  }
  return false;
}

String? _deriveFacingActorCueV1(
  BuildContext context, {
  required Act0TableStateV1 table,
}) {
  final candidates = <String>[
    for (final item in table.actionTrail.reversed) item.label,
    table.centerLabel,
  ];
  for (final raw in candidates) {
    final label = raw.trim();
    final openMatch = RegExp(
      r'^([A-Z0-9]+)\s+opens\s+(.+)$',
      caseSensitive: false,
    ).firstMatch(label);
    if (openMatch != null) {
      return act0RuntimeNeutralFacingActorCueLabelV1(
        context,
        actor: openMatch.group(1)!.toUpperCase(),
        amount: openMatch.group(2)!,
      );
    }
    final betMatch = RegExp(
      r'^([A-Z0-9]+)\s+bets\s+(.+)$',
      caseSensitive: false,
    ).firstMatch(label);
    if (betMatch != null) {
      return act0RuntimeNeutralFacingActorCueLabelV1(
        context,
        actor: betMatch.group(1)!.toUpperCase(),
        amount: betMatch.group(2)!,
      );
    }
  }
  return null;
}

String _neutralizeLeadingTableCueV1(
  BuildContext context, {
  required Act0TableStateV1 table,
  required Act0TaskFamilyV1? taskFamily,
}) {
  if (taskFamily == Act0TaskFamilyV1.sizing) {
    return act0RuntimeNeutralSizingCueLabelV1(context);
  }
  final facingActorCue = _deriveFacingActorCueV1(context, table: table);
  if (facingActorCue != null) {
    return facingActorCue;
  }
  if (table.potLabel.trim().isNotEmpty && table.toCallLabel.trim().isNotEmpty) {
    return act0RuntimeNeutralPotAndPriceCueLabelV1(context);
  }
  if (table.toCallLabel.trim().isNotEmpty) {
    return act0RuntimeNeutralFacingPriceCueLabelV1(context);
  }
  return act0RuntimeNeutralDecisionCueLabelV1(context);
}

String? _resolveDecisionPromptSupportLineV1(
  BuildContext context, {
  required Act0RunnerStateV1 runner,
  required Act0TableStateV1 table,
  required Act0TaskFamilyV1? taskFamily,
  required bool hasSeatTargets,
}) {
  if (!_looksLikeActionDecisionPromptV1(
    runner.question,
    taskFamily: taskFamily,
    hasSeatTargets: hasSeatTargets,
  )) {
    return null;
  }
  return _deriveFacingActorCueV1(context, table: table);
}

String _neutralizeAnswerBearingCueV1({
  required BuildContext context,
  required String cueLabel,
  required String question,
}) {
  final normalizedCue = _normalizeAnswerLeakTextV1(cueLabel);
  final normalizedQuestion = _normalizeAnswerLeakTextV1(question);
  if (normalizedQuestion.contains('bucket') ||
      normalizedCue.contains('bucket')) {
    return act0RuntimeNeutralBucketCueLabelV1(context);
  }
  if (normalizedQuestion.contains('made hand') ||
      normalizedQuestion.contains('hand category') ||
      normalizedQuestion.contains('showdown')) {
    return act0RuntimeNeutralHandReadCueLabelV1(context);
  }
  if (normalizedQuestion.contains('trail') ||
      normalizedQuestion.contains('history')) {
    return 'Hand history';
  }
  return act0RuntimeNeutralTableReadCueLabelV1(context);
}

String _resolveTableCueDisplayV1({
  required BuildContext context,
  required Act0RunnerStateV1 runner,
  required Act0TableStateV1 table,
  required bool isTeaching,
  required bool isTheory,
  required bool isReview,
  required Act0TaskFamilyV1? taskFamily,
  required bool hasSeatTargets,
}) {
  final rawCue = table.centerLabel.trim();
  if (rawCue.isEmpty) {
    return rawCue;
  }
  if (!_isActiveAssessmentStateV1(
    isTeaching: isTeaching,
    isTheory: isTheory,
    isReview: isReview,
    runner: runner,
  )) {
    return rawCue;
  }
  if (_looksLikeTrailHistoryQuestionV1(runner, table)) {
    return '';
  }
  if (_isAnswerBearingTableCueV1(
    cueLabel: rawCue,
    question: runner.question,
    options: runner.options,
  )) {
    return _neutralizeAnswerBearingCueV1(
      context: context,
      cueLabel: rawCue,
      question: runner.question,
    );
  }
  if (_isAnswerLeadingTableCueV1(
    rawCue,
    question: runner.question,
    taskFamily: taskFamily,
    hasSeatTargets: hasSeatTargets,
  )) {
    return _neutralizeLeadingTableCueV1(
      context,
      table: table,
      taskFamily: taskFamily,
    );
  }
  return rawCue;
}

bool _isCenterPriceContextCueV1(BuildContext context, String cueLabel) {
  final normalizedCue = cueLabel.trim().toLowerCase();
  if (normalizedCue.isEmpty) {
    return false;
  }
  if (normalizedCue.startsWith('facing ') ||
      normalizedCue.startsWith('против ')) {
    return true;
  }
  final facingPrice = act0RuntimeNeutralFacingPriceCueLabelV1(
    context,
  ).toLowerCase();
  final potAndPrice = act0RuntimeNeutralPotAndPriceCueLabelV1(
    context,
  ).toLowerCase();
  return normalizedCue == facingPrice || normalizedCue == potAndPrice;
}

_CenterStatDisplayV1 _resolveCenterStatDisplayV1(
  BuildContext context, {
  required Act0RunnerStateV1 runner,
  required Act0TableStateV1 table,
  required _RunnerBottomContextV1 bottomContext,
  required String centerCueLabel,
  required bool isTeaching,
  required bool isTheory,
  required bool isReview,
  required Act0TaskFamilyV1? taskFamily,
  required bool hasSeatTargets,
}) {
  final potLabel = table.potLabel.trim();
  final isActiveAssessment = _isActiveAssessmentStateV1(
    isTeaching: isTeaching,
    isTheory: isTheory,
    isReview: isReview,
    runner: runner,
  );
  final isDecisionPrompt =
      isActiveAssessment &&
      _looksLikeActionDecisionPromptV1(
        runner.question,
        taskFamily: taskFamily,
        hasSeatTargets: hasSeatTargets,
      );
  final showToCall =
      table.toCallLabel.trim().isNotEmpty && !bottomContext.isTrailHistory;
  var resolvedCue = centerCueLabel.trim();

  if (isDecisionPrompt && showToCall && resolvedCue.isNotEmpty) {
    final genericDecisionCue = taskFamily == Act0TaskFamilyV1.sizing
        ? act0RuntimeNeutralSizingCueLabelV1(context)
        : act0RuntimeNeutralDecisionCueLabelV1(context);
    if (bottomContext.promptOwnsDecisionContext &&
        _isCenterPriceContextCueV1(context, resolvedCue)) {
      resolvedCue = genericDecisionCue;
    } else if (_isCenterPriceContextCueV1(context, resolvedCue) &&
        !bottomContext.promptOwnsDecisionContext) {
      resolvedCue = genericDecisionCue;
    }
  }

  return _CenterStatDisplayV1(
    centerCueLabel: resolvedCue,
    potLabel: potLabel,
    toCallLabel: showToCall ? table.toCallLabel.trim() : '',
  );
}

String _normalizedTrailStreetFromLabelV1(String label) {
  final match = RegExp(
    r'^(Preflop|Flop|Turn|River)[:\s]',
    caseSensitive: false,
  ).firstMatch(label.trim());
  return match?.group(1)?.trim() ?? '';
}

bool _looksLikeTrailHistoryQuestionV1(
  Act0RunnerStateV1 runner,
  Act0TableStateV1 table,
) {
  if (table.actionTrail.isEmpty) {
    return false;
  }
  final question = runner.question.trim().toLowerCase();
  if (question.contains('trail') ||
      question.contains('history') ||
      question.contains('happened last') ||
      question.contains('latest action')) {
    return true;
  }
  final trailLabels = table.actionTrail
      .map((item) => item.label.trim())
      .where((label) => label.isNotEmpty)
      .toSet();
  for (final option in runner.options) {
    final optionLabel = option.label.trim();
    final preferredLabel = option.preferredLabel.trim();
    if (trailLabels.contains(optionLabel) ||
        trailLabels.contains(preferredLabel)) {
      return true;
    }
  }
  return false;
}

_RunnerBottomContextV1 _resolveRunnerBottomContextV1(
  BuildContext context, {
  required Act0RunnerStateV1 runner,
  required Act0TableStateV1 table,
  required bool isTeaching,
  required bool isTheory,
  required bool isDrill,
  required bool isReview,
  required bool showBottomLearningRail,
  required bool hasSeatTargets,
  required Act0TaskFamilyV1? taskFamily,
}) {
  final isTrailHistory = !isTeaching && !isTheory
      ? _looksLikeTrailHistoryQuestionV1(runner, table)
      : false;
  final taskLabel = act0RuntimeTaskRailLabelV1(
    context,
    isTeaching: isTeaching,
    isTheory: isTheory,
    isDrill: isDrill,
    isReview: isReview,
    isTrailHistory: isTrailHistory,
    hasSeatTargets: hasSeatTargets,
    taskFamily: taskFamily,
  );
  final tableStreet = table.streetLabel.trim();
  final trailStreet = table.actionTrail.isEmpty
      ? ''
      : _normalizedTrailStreetFromLabelV1(table.actionTrail.last.label);
  final decisionPromptSupportLine = !isTrailHistory
      ? _resolveDecisionPromptSupportLineV1(
          context,
          runner: runner,
          table: table,
          taskFamily: taskFamily,
          hasSeatTargets: hasSeatTargets,
        )
      : null;
  final promptSupportLine = isTrailHistory
      ? act0RuntimeTrailPromptSupportLineV1(
          context,
          currentStreetLabel: tableStreet,
          trailStreetLabel: trailStreet,
        )
      : decisionPromptSupportLine;
  final feedbackContextLabels = isTrailHistory
      ? <String>[act0RuntimeTrailFeedbackContextLabelV1(context)]
      : const <String>[];

  if (showBottomLearningRail || isTeaching || isTheory) {
    return _RunnerBottomContextV1(
      owner: _RunnerBottomOwnerV1.coachRail,
      isTrailHistory: isTrailHistory,
      promptOwnsDecisionContext: false,
      showActionTrail: false,
      taskLabel: taskLabel,
      questionBadgeLabel: act0RuntimeQuestionBadgeLabelV1(context),
      promptSupportLine: promptSupportLine,
      feedbackContextLabels: feedbackContextLabels,
    );
  }
  if (isReview) {
    return _RunnerBottomContextV1(
      owner: _RunnerBottomOwnerV1.feedback,
      isTrailHistory: isTrailHistory,
      promptOwnsDecisionContext: false,
      showActionTrail: table.actionTrail.isNotEmpty,
      actionTrailVariant: table.actionTrail.isNotEmpty
          ? _ActionTrailVariantV1.replay
          : null,
      taskLabel: taskLabel,
      questionBadgeLabel: act0RuntimeQuestionBadgeLabelV1(
        context,
        isTrailHistory: isTrailHistory,
      ),
      promptSupportLine: promptSupportLine,
      feedbackContextLabels: feedbackContextLabels,
    );
  }
  return _RunnerBottomContextV1(
    owner: _RunnerBottomOwnerV1.questionPrompt,
    isTrailHistory: isTrailHistory,
    promptOwnsDecisionContext: decisionPromptSupportLine != null,
    showActionTrail: false,
    taskLabel: taskLabel,
    questionBadgeLabel: act0RuntimeQuestionBadgeLabelV1(
      context,
      isTrailHistory: isTrailHistory,
    ),
    promptSupportLine: promptSupportLine,
    feedbackContextLabels: feedbackContextLabels,
  );
}

class _ActionTrailV1 extends StatefulWidget {
  const _ActionTrailV1({
    required this.items,
    required this.variant,
    this.streetLabel,
    this.refined = false,
    this.onFocusedIndexChanged,
  });

  final List<Act0ActionTrailItemV1> items;
  final _ActionTrailVariantV1 variant;
  final String? streetLabel;
  final bool refined;
  final ValueChanged<int>? onFocusedIndexChanged;

  @override
  State<_ActionTrailV1> createState() => _ActionTrailV1State();
}

class _ActionTrailV1State extends State<_ActionTrailV1> {
  Timer? _revealTimer;
  Timer? _playbackTimer;
  int _visibleCount = 0;
  int _focusedIndex = 0;
  bool _isAutoPlaying = false;

  @override
  void initState() {
    super.initState();
    _visibleCount = widget.items.length;
    _focusedIndex = widget.items.isEmpty ? 0 : widget.items.length - 1;
    _emitFocusedIndex();
  }

  @override
  void didUpdateWidget(covariant _ActionTrailV1 oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldLabels = oldWidget.items.map((item) => item.label).toList();
    final newLabels = widget.items.map((item) => item.label).toList();
    if (_isSamePrefix(oldLabels, newLabels) &&
        newLabels.length > oldLabels.length) {
      _revealTimer?.cancel();
      setState(() => _visibleCount = oldLabels.length);
      _scheduleRevealUntil(newLabels.length);
      return;
    }
    _revealTimer?.cancel();
    _playbackTimer?.cancel();
    _isAutoPlaying = false;
    setState(() {
      _visibleCount = newLabels.length;
      _focusedIndex = newLabels.isEmpty ? 0 : newLabels.length - 1;
    });
    _emitFocusedIndex();
  }

  @override
  void dispose() {
    _revealTimer?.cancel();
    _playbackTimer?.cancel();
    super.dispose();
  }

  void _emitFocusedIndex() {
    if (widget.items.isEmpty) {
      return;
    }
    final normalized = _focusedIndex.clamp(0, widget.items.length - 1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      widget.onFocusedIndexChanged?.call(normalized);
    });
  }

  bool _isSamePrefix(List<String> oldLabels, List<String> nextLabels) {
    if (oldLabels.length > nextLabels.length) {
      return false;
    }
    for (var i = 0; i < oldLabels.length; i++) {
      if (oldLabels[i] != nextLabels[i]) {
        return false;
      }
    }
    return true;
  }

  void _scheduleRevealUntil(int target) {
    if (!mounted || _visibleCount >= target) {
      return;
    }
    _revealTimer = Timer(const Duration(milliseconds: 130), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _visibleCount = (_visibleCount + 1).clamp(0, target);
      });
      _scheduleRevealUntil(target);
    });
  }

  void _focusStep(int nextIndex) {
    if (widget.items.isEmpty) {
      return;
    }
    final maxIndex = widget.items.length - 1;
    final normalized = nextIndex.clamp(0, maxIndex);
    if (_focusedIndex == normalized) {
      return;
    }
    setState(() {
      _focusedIndex = normalized;
    });
    _emitFocusedIndex();
  }

  /// Returns the street name if this trail label starts a new street
  /// (e.g. "Flop: BB checks" → "FLOP", "Flop dealt" → "FLOP"), otherwise null.
  String? _streetNameFromLabel(String label) {
    final m = RegExp(
      r'^(Flop|Turn|River)[:\s]',
      caseSensitive: false,
    ).firstMatch(label.trim());
    return m != null ? m.group(1)!.toUpperCase() : null;
  }

  void _toggleAutoPlay() {
    if (widget.items.length < 2) {
      return;
    }
    if (_isAutoPlaying) {
      _playbackTimer?.cancel();
      setState(() => _isAutoPlaying = false);
      return;
    }
    setState(() => _isAutoPlaying = true);
    _playbackTimer?.cancel();
    _playbackTimer = Timer.periodic(const Duration(milliseconds: 900), (_) {
      if (!mounted || widget.items.isEmpty) {
        return;
      }
      final maxIndex = widget.items.length - 1;
      final atEnd = _focusedIndex >= maxIndex;
      setState(() {
        _focusedIndex = atEnd ? 0 : (_focusedIndex + 1);
      });
      _emitFocusedIndex();
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    final refined = widget.refined;
    final compactContext =
        widget.variant == _ActionTrailVariantV1.compactContext;
    final streetLabel = widget.streetLabel?.trim() ?? '';
    final visibleCount = _visibleCount.clamp(0, items.length);
    final focusedIndex = items.isEmpty
        ? 0
        : _focusedIndex.clamp(0, visibleCount - 1);
    final text = items.map((item) => item.label).join('  .  ');
    final focusedLabel = items.isEmpty
        ? ''
        : act0RuntimeLocalizedActionTrailLabelV1(
            context,
            items[focusedIndex].label,
          );
    final compactStreetLabel = streetLabel.isNotEmpty
        ? act0RuntimeLocalizedStreetLabelV1(context, streetLabel)
        : '';
    return Container(
      key: const Key('act0_shell_action_trail'),
      constraints: BoxConstraints(maxWidth: refined ? 332 : 370),
      padding: EdgeInsets.symmetric(
        horizontal: refined ? 8 : 11,
        vertical: refined ? 4 : 7,
      ),
      decoration: BoxDecoration(
        color: refined
            ? Act0ShellTokensV1.surface.withValues(alpha: 0.26)
            : Act0ShellTokensV1.surface2.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusXl),
        border: Border.all(
          color: Act0ShellTokensV1.border.withValues(
            alpha: refined ? 0.16 : 0.44,
          ),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (compactContext) {
            return Row(
              key: const Key('act0_shell_action_trail_compact_context'),
              mainAxisSize: MainAxisSize.min,
              children: [
                if (compactStreetLabel.isNotEmpty)
                  Container(
                    key: const Key('act0_shell_action_trail_street_badge'),
                    padding: EdgeInsets.symmetric(
                      horizontal: refined ? 7 : 8,
                      vertical: refined ? 3 : 4,
                    ),
                    decoration: BoxDecoration(
                      color: Act0ShellTokensV1.info.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(
                        Act0ShellTokensV1.radiusPill,
                      ),
                      border: Border.all(
                        color: Act0ShellTokensV1.info.withValues(alpha: 0.26),
                      ),
                    ),
                    child: Text(
                      compactStreetLabel,
                      style: Act0ShellTokensV1.label.copyWith(
                        fontSize: refined ? 7.2 : 7.8,
                        color: Act0ShellTokensV1.info.withValues(alpha: 0.88),
                        letterSpacing: 0.18,
                      ),
                    ),
                  ),
                if (compactStreetLabel.isNotEmpty)
                  SizedBox(width: refined ? 7 : 8),
                Expanded(
                  child: Text(
                    focusedLabel,
                    key: const Key('act0_shell_action_trail_text'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Act0ShellTokensV1.muted.copyWith(
                      color: Act0ShellTokensV1.text.withValues(
                        alpha: refined ? 0.84 : 0.90,
                      ),
                      fontSize: refined ? 10.2 : 10.8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            );
          }
          final stackControls =
              items.length > 1 && refined && constraints.maxWidth < 206;
          final trailControls = Row(
            key: const Key('act0_shell_action_trail_replay_controls'),
            mainAxisSize: MainAxisSize.min,
            children: [
              _TrailPlaybackButtonV1(
                key: const Key('act0_shell_action_trail_playback_prev'),
                icon: Icons.skip_previous_rounded,
                onTap: () {
                  _playbackTimer?.cancel();
                  if (_isAutoPlaying) {
                    setState(() => _isAutoPlaying = false);
                  }
                  _focusStep(focusedIndex - 1);
                },
                compact: refined,
              ),
              SizedBox(width: refined ? 4 : 5),
              _TrailPlaybackButtonV1(
                key: const Key('act0_shell_action_trail_playback_toggle'),
                icon: _isAutoPlaying
                    ? Icons.pause_circle_filled_rounded
                    : Icons.play_circle_fill_rounded,
                onTap: _toggleAutoPlay,
                active: _isAutoPlaying,
                compact: refined,
              ),
              SizedBox(width: refined ? 4 : 5),
              _TrailPlaybackButtonV1(
                key: const Key('act0_shell_action_trail_playback_next'),
                icon: Icons.skip_next_rounded,
                onTap: () {
                  _playbackTimer?.cancel();
                  if (_isAutoPlaying) {
                    setState(() => _isAutoPlaying = false);
                  }
                  _focusStep(focusedIndex + 1);
                },
                compact: refined,
              ),
              const SizedBox(width: 6),
              Text(
                '${focusedIndex + 1}/${items.length}',
                style: TextStyle(
                  color: Act0ShellTokensV1.textMuted,
                  fontSize: refined ? 8.5 : 9.5,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const <FontFeature>[
                    FontFeature.tabularFigures(),
                  ],
                ),
              ),
            ],
          );
          final trailMain = Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: refined ? 22 : 26,
                height: refined ? 22 : 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Act0ShellTokensV1.surface3.withValues(
                    alpha: refined ? 0.28 : 0.62,
                  ),
                  borderRadius: BorderRadius.circular(
                    refined
                        ? Act0ShellTokensV1.radiusXs
                        : Act0ShellTokensV1.radiusPill,
                  ),
                  border: Border.all(
                    color: Act0ShellTokensV1.border.withValues(
                      alpha: refined ? 0.20 : 0.28,
                    ),
                  ),
                ),
                child: Icon(
                  Icons.timeline_rounded,
                  key: const Key('act0_shell_action_trail_icon'),
                  size: refined ? 12 : 14,
                  color: Act0ShellTokensV1.textMuted.withValues(
                    alpha: refined ? 0.66 : 0.82,
                  ),
                ),
              ),
              SizedBox(width: refined ? 6 : 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox.shrink(
                      child: Text(
                        text,
                        key: const Key('act0_shell_action_trail_text'),
                      ),
                    ),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final badgeWidth = streetLabel.isNotEmpty
                            ? (refined ? 54.0 : 58.0)
                            : 0.0;
                        final scrollerWidth = streetLabel.isNotEmpty
                            ? (constraints.maxWidth -
                                      badgeWidth -
                                      (refined ? 5 : 7))
                                  .clamp(80.0, constraints.maxWidth)
                            : constraints.maxWidth;
                        return Wrap(
                          spacing: refined ? 5 : 7,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            if (streetLabel.isNotEmpty)
                              refined
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 1,
                                        vertical: 1,
                                      ),
                                      child: Text(
                                        streetLabel,
                                        key: const Key(
                                          'act0_shell_action_trail_street_badge',
                                        ),
                                        style: Act0ShellTokensV1.label.copyWith(
                                          fontSize: 7.1,
                                          color: Act0ShellTokensV1.info
                                              .withValues(alpha: 0.84),
                                          letterSpacing: 0.25,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      key: const Key(
                                        'act0_shell_action_trail_street_badge',
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2.5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Act0ShellTokensV1.info
                                            .withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(
                                          Act0ShellTokensV1.radiusPill,
                                        ),
                                        border: Border.all(
                                          color: Act0ShellTokensV1.info
                                              .withValues(alpha: 0.34),
                                        ),
                                      ),
                                      child: Text(
                                        streetLabel,
                                        style: Act0ShellTokensV1.label.copyWith(
                                          fontSize: 7.2,
                                          color: Act0ShellTokensV1.info,
                                          letterSpacing: 0.1,
                                        ),
                                      ),
                                    ),
                            SizedBox(
                              width: scrollerWidth,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                child: Row(
                                  children: [
                                    for (var i = 0; i < visibleCount; i++) ...[
                                      if (i > 0 &&
                                          _streetNameFromLabel(
                                                items[i].label,
                                              ) !=
                                              null)
                                        Padding(
                                          padding: EdgeInsets.only(
                                            right: refined ? 4 : 5,
                                          ),
                                          child: _TrailStreetDividerV1(
                                            label: _streetNameFromLabel(
                                              items[i].label,
                                            )!,
                                            refined: refined,
                                          ),
                                        ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          right: i == visibleCount - 1
                                              ? 0
                                              : (refined ? 4 : 5),
                                        ),
                                        child: GestureDetector(
                                          onTap: () {
                                            _playbackTimer?.cancel();
                                            if (_isAutoPlaying) {
                                              setState(
                                                () => _isAutoPlaying = false,
                                              );
                                            }
                                            _focusStep(i);
                                          },
                                          child: _ActionTrailStepV1(
                                            item: items[i],
                                            index: i,
                                            isLatest: i == focusedIndex,
                                            refined: refined,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              if (items.length > 1 && !stackControls) ...[
                SizedBox(width: refined ? 7 : 8),
                trailControls,
              ],
            ],
          );
          if (!stackControls) {
            return trailMain;
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              trailMain,
              SizedBox(height: refined ? 6 : 8),
              Align(alignment: Alignment.centerRight, child: trailControls),
            ],
          );
        },
      ),
    );
  }
}

class _TrailStreetDividerV1 extends StatelessWidget {
  const _TrailStreetDividerV1({required this.label, this.refined = false});
  final String label;
  final bool refined;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Act0ShellTokensV1.gold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Act0ShellTokensV1.gold.withValues(alpha: 0.34),
        ),
      ),
      child: Text(
        label,
        style: Act0ShellTokensV1.label.copyWith(
          fontSize: refined ? 7.0 : 7.4,
          color: Act0ShellTokensV1.gold,
          letterSpacing: 0.4,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TrailPlaybackButtonV1 extends StatelessWidget {
  const _TrailPlaybackButtonV1({
    super.key,
    required this.icon,
    required this.onTap,
    this.active = false,
    this.compact = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool active;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final radius = compact
        ? Act0ShellTokensV1.radiusXs
        : Act0ShellTokensV1.radiusPill;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 5 : 4,
            vertical: compact ? 3 : 4,
          ),
          decoration: BoxDecoration(
            color: active
                ? Act0ShellTokensV1.primary.withValues(alpha: 0.16)
                : Colors.white.withValues(alpha: compact ? 0.025 : 0.04),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: active
                  ? Act0ShellTokensV1.primary.withValues(alpha: 0.48)
                  : Act0ShellTokensV1.border.withValues(
                      alpha: compact ? 0.28 : 0.44,
                    ),
            ),
          ),
          child: Icon(
            icon,
            size: compact ? 14 : 16,
            color: active
                ? Act0ShellTokensV1.primary
                : Act0ShellTokensV1.textMuted,
          ),
        ),
      ),
    );
  }
}

class _ActionTrailStepV1 extends StatefulWidget {
  const _ActionTrailStepV1({
    required this.item,
    required this.index,
    required this.isLatest,
    required this.refined,
  });

  final Act0ActionTrailItemV1 item;
  final int index;
  final bool isLatest;
  final bool refined;

  @override
  State<_ActionTrailStepV1> createState() => _ActionTrailStepV1State();
}

class _ActionTrailStepV1State extends State<_ActionTrailStepV1> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final refined = widget.refined;
    final isLatest = widget.isLatest;
    return AnimatedSlide(
      key: Key('act0_shell_action_trail_step_${widget.index}'),
      duration: Duration(milliseconds: refined ? 260 : 220),
      curve: Curves.easeOutCubic,
      offset: _visible ? Offset.zero : const Offset(0.10, 0),
      child: AnimatedOpacity(
        duration: Duration(milliseconds: refined ? 240 : 200),
        curve: Curves.easeOut,
        opacity: _visible ? 1 : 0,
        child: Container(
          key: isLatest
              ? const Key('act0_shell_action_trail_latest_step')
              : null,
          padding: EdgeInsets.symmetric(
            horizontal: refined ? 7 : 8,
            vertical: refined ? 3 : 4,
          ),
          decoration: BoxDecoration(
            color: isLatest
                ? Act0ShellTokensV1.gold.withValues(alpha: 0.14)
                : Colors.white.withValues(alpha: refined ? 0.035 : 0.05),
            borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
            border: Border.all(
              color: isLatest
                  ? Act0ShellTokensV1.gold.withValues(alpha: 0.36)
                  : Colors.white.withValues(alpha: refined ? 0.06 : 0.08),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: refined ? 4 : 5,
                height: refined ? 4 : 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isLatest
                      ? Act0ShellTokensV1.gold
                      : Act0ShellTokensV1.textMuted.withValues(
                          alpha: refined ? 0.46 : 0.58,
                        ),
                ),
              ),
              SizedBox(width: refined ? 5 : 6),
              Text(
                act0RuntimeLocalizedActionTrailLabelV1(
                  context,
                  widget.item.label,
                ),
                key: Key('act0_shell_action_trail_step_label_${widget.index}'),
                maxLines: 2,
                style: Act0ShellTokensV1.muted.copyWith(
                  fontSize: refined ? 8.8 : 9.5,
                  fontWeight: isLatest ? FontWeight.w900 : FontWeight.w800,
                  color: isLatest
                      ? Act0ShellTokensV1.gold
                      : Act0ShellTokensV1.textMuted.withValues(
                          alpha: refined ? 0.74 : 0.86,
                        ),
                ),
              ),
              if (isLatest) ...[
                SizedBox(width: refined ? 5 : 6),
                Container(
                  key: const Key('act0_shell_action_trail_latest_badge'),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Act0ShellTokensV1.gold.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(
                      Act0ShellTokensV1.radiusPill,
                    ),
                  ),
                  child: Text(
                    act0RuntimeLocalizedLatestBadgeV1(context),
                    style: Act0ShellTokensV1.label.copyWith(
                      color: Act0ShellTokensV1.gold,
                      fontSize: refined ? 7.4 : 7.8,
                      letterSpacing: 0.2,
                    ),
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

class _SeatMarkersV1 extends StatelessWidget {
  const _SeatMarkersV1({required this.seatId, required this.markers});

  final String seatId;
  final List<_SeatMarkerKindV1> markers;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      key: Key('act0_shell_marker_cluster_$seatId'),
      spacing: 3,
      runSpacing: 3,
      children: [
        for (final marker in markers)
          KeyedSubtree(
            key: Key('act0_shell_marker_${seatId}_${marker.name}'),
            child: _MarkerDotV1(
              label: switch (marker) {
                _SeatMarkerKindV1.dealer => 'D',
                _SeatMarkerKindV1.smallBlind => 'SB',
                _SeatMarkerKindV1.bigBlind => 'BB',
                _SeatMarkerKindV1.aggressor => 'Agg',
                _SeatMarkerKindV1.act => 'Act',
              },
            ),
          ),
      ],
    );
  }
}

class _SeatMarkerPlacementV1 extends StatelessWidget {
  const _SeatMarkerPlacementV1({
    required this.seatId,
    required this.leftSide,
    required this.markers,
    required this.hero,
    required this.visualVariant,
  });

  final String seatId;
  final bool leftSide;
  final List<_SeatMarkerKindV1> markers;
  final bool hero;
  final Act0ShellTableVisualVariantV1 visualVariant;

  @override
  Widget build(BuildContext context) {
    final refined = visualVariant == Act0ShellTableVisualVariantV1.refinedDev2;
    final bottomHero = hero;
    return Positioned(
      top: bottomHero ? (refined ? 6 : 4) : (refined ? -10 : -12),
      left: leftSide ? (refined ? -6 : -10) : null,
      right: bottomHero
          ? (refined ? -38 : -48)
          : (leftSide ? null : (refined ? -6 : -10)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: refined ? 42 : 50),
        child: _SeatMarkersV1(seatId: seatId, markers: markers),
      ),
    );
  }
}

class _MiniCardBackV1 extends StatelessWidget {
  const _MiniCardBackV1();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('act0_shell_face_down_card'),
      width: 18,
      height: 26,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Act0ShellTokensV1.runnerTagBlue,
            Act0ShellTokensV1.info.withValues(alpha: 0.58),
            Act0ShellTokensV1.feltLine.withValues(alpha: 0.34),
          ],
        ),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radius3xs),
        border: Border.all(color: Colors.white.withValues(alpha: 0.26)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Act0ShellTokensV1.shadowSoft,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    Act0ShellTokensV1.radius2xs,
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
              ),
            ),
          ),
          Align(
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(
                  Act0ShellTokensV1.radiusPill,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BetChipV1 extends StatelessWidget {
  const _BetChipV1({required this.bet, this.compact = false});

  final Act0SeatBetStateV1 bet;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final showLabelPill =
        !(compact &&
            bet.kind == Act0SeatBetKindV1.post &&
            (bet.label == 'SB' || bet.label == 'BB'));
    final color = switch (bet.kind) {
      Act0SeatBetKindV1.post => Act0ShellTokensV1.gold,
      Act0SeatBetKindV1.call => Act0ShellTokensV1.info,
      Act0SeatBetKindV1.bet ||
      Act0SeatBetKindV1.raise => Act0ShellTokensV1.primary,
      Act0SeatBetKindV1.allIn => Act0ShellTokensV1.danger,
    };
    return Container(
      key: Key('act0_shell_bet_chip_${bet.label}'),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 5 : 6,
        vertical: compact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Act0ShellTokensV1.runnerGlass.withValues(alpha: 0.96),
            Act0ShellTokensV1.surface.withValues(alpha: 0.94),
          ],
        ),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
        border: Border.all(color: color.withValues(alpha: 0.78), width: 1),
        boxShadow: <BoxShadow>[
          const BoxShadow(
            color: Act0ShellTokensV1.shadowSoftStrong,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
          BoxShadow(
            color: color.withValues(alpha: 0.20),
            blurRadius: 12,
            spreadRadius: -4,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _ChipStackIconV1(color: color, compact: compact),
          SizedBox(width: compact ? 3 : 4),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showLabelPill)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 3 : 4,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(
                      Act0ShellTokensV1.radiusPill,
                    ),
                  ),
                  child: Text(
                    bet.label,
                    style: TextStyle(
                      color: color,
                      fontSize: compact ? 5.6 : 6.1,
                      height: 0.95,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              if (showLabelPill) SizedBox(height: compact ? 1 : 2),
              Text(
                bet.amountLabel,
                style: TextStyle(
                  color: Act0ShellTokensV1.text,
                  fontSize: compact ? 7.0 : 7.8,
                  height: 0.98,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChipStackIconV1 extends StatelessWidget {
  const _ChipStackIconV1({required this.color, this.compact = false});

  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: compact ? 12 : 14,
      height: compact ? 14 : 16,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 0,
            child: _ChipDiscV1(
              color: color.withValues(alpha: 0.56),
              compact: compact,
            ),
          ),
          Positioned(
            top: 1,
            child: _ChipDiscV1(
              color: color.withValues(alpha: 0.78),
              compact: compact,
            ),
          ),
          _ChipDiscV1(color: color, compact: compact),
        ],
      ),
    );
  }
}

class _ChipDiscV1 extends StatelessWidget {
  const _ChipDiscV1({required this.color, this.compact = false});

  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: compact ? 10 : 12,
      height: compact ? 10 : 12,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: <Color>[Colors.white.withValues(alpha: 0.14), color],
          stops: const <double>[0, 0.72],
        ),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.28),
          width: 1,
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Act0ShellTokensV1.shadowSoft,
            blurRadius: 5,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: compact ? 3 : 4,
          height: compact ? 3 : 4,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.36),
            borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
          ),
        ),
      ),
    );
  }
}

class _FoldedBadgeV1 extends StatelessWidget {
  const _FoldedBadgeV1();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('act0_shell_folded_badge'),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Act0ShellTokensV1.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
        border: Border.all(
          color: Act0ShellTokensV1.border.withValues(alpha: 0.9),
        ),
      ),
      child: Text(
        'Folded',
        style: Act0ShellTokensV1.label.copyWith(
          color: Act0ShellTokensV1.textMuted,
          fontSize: 7,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _MarkerDotV1 extends StatelessWidget {
  const _MarkerDotV1({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
      decoration: BoxDecoration(
        color: Act0ShellTokensV1.gold.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Act0ShellTokensV1.runnerHintWarm,
          fontSize: 6.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _CardV1 extends StatelessWidget {
  const _CardV1({required this.card, this.cardId, this.highlighted = false});

  final Act0CardStateV1 card;
  final String? cardId;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final color = _cardInkColor(card);
    final suit = _displaySuit(card.suit);
    return Container(
      key: cardId != null ? Key('act0_shell_card_$cardId') : null,
      width: Act0ShellTokensV1.heroCardWidth,
      height: Act0ShellTokensV1.heroCardHeight,
      constraints: const BoxConstraints(
        minWidth: Act0ShellTokensV1.heroCardWidth,
      ),
      decoration: _playingCardDecorationV1(highlighted: highlighted),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusXs),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Colors.white.withValues(alpha: 0.28),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.05),
                  ],
                  stops: const <double>[0, 0.28, 1],
                ),
              ),
            ),
          ),
          Positioned(
            left: 4,
            top: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.rank,
                  style: TextStyle(
                    color: color,
                    fontSize: 15,
                    height: 0.9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Align(
            child: Text(
              suit.isEmpty ? card.rank : suit,
              style: TextStyle(
                color: color.withValues(alpha: 0.88),
                fontSize: 23,
                height: 1,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BoardCardV1 extends StatelessWidget {
  const _BoardCardV1({
    required this.card,
    this.cardId,
    this.highlighted = false,
    this.onTap,
  });

  final Act0CardStateV1 card;
  final String? cardId;
  final bool highlighted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = _cardInkColor(card);
    final suit = _displaySuit(card.suit);
    final child = Container(
      key: cardId != null
          ? Key('act0_shell_card_$cardId')
          : const Key('act0_shell_board_card'),
      width: Act0ShellTokensV1.boardCardWidth,
      height: Act0ShellTokensV1.boardCardHeight,
      decoration: _playingCardDecorationV1(
        board: true,
        highlighted: highlighted,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusXs),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Colors.white.withValues(alpha: 0.22),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.04),
                  ],
                  stops: const <double>[0, 0.26, 1],
                ),
              ),
            ),
          ),
          Positioned(
            left: 4,
            top: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.rank,
                  style: Act0ShellTokensV1.body.copyWith(
                    color: color,
                    fontSize: 13,
                    height: 0.9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Align(
            child: Text(
              suit.isEmpty ? card.rank : suit,
              style: TextStyle(
                color: color.withValues(alpha: 0.90),
                fontSize: 19,
                height: 1,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
    if (onTap == null) {
      return child;
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: child,
    );
  }
}

class _Act0ShowdownParticipantV1 {
  const _Act0ShowdownParticipantV1({
    required this.seatId,
    required this.displayLabel,
    required this.cards,
    required this.cardIdsBySolver,
  });

  final String seatId;
  final String displayLabel;
  final List<String> cards;
  final Map<String, List<String>> cardIdsBySolver;
}

class _Act0ShowdownInsightV1 {
  const _Act0ShowdownInsightV1({
    required this.highlightedCardIds,
    required this.summaryLine,
  });

  final List<String> highlightedCardIds;
  final String summaryLine;
}

BoxDecoration _playingCardDecorationV1({
  bool board = false,
  bool highlighted = false,
}) {
  return BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: board
          ? const <Color>[
              Act0ShellTokensV1.runnerSheetWarmStart,
              Act0ShellTokensV1.runnerSheetWarmEnd,
            ]
          : const <Color>[
              Act0ShellTokensV1.runnerSheetNeutralStart,
              Act0ShellTokensV1.runnerSheetNeutralEnd,
            ],
    ),
    borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusXs),
    border: Border.all(
      color: highlighted
          ? Act0ShellTokensV1.gold.withValues(alpha: 0.72)
          : Colors.black.withValues(alpha: 0.08),
      width: highlighted ? 1.6 : 1,
    ),
    boxShadow: <BoxShadow>[
      const BoxShadow(
        color: Act0ShellTokensV1.shadowSoft,
        blurRadius: 7,
        offset: Offset(0, 2),
      ),
      if (highlighted)
        BoxShadow(
          color: Act0ShellTokensV1.gold.withValues(alpha: 0.18),
          blurRadius: 10,
          spreadRadius: 0.6,
        ),
      BoxShadow(
        color: Colors.white.withValues(alpha: 0.18),
        blurRadius: 0,
        spreadRadius: -0.2,
      ),
    ],
  );
}

Color _cardInkColor(Act0CardStateV1 card) {
  return card.tone == Act0CardToneV1.red
      ? Act0ShellTokensV1.runnerAnswerDanger
      : Act0ShellTokensV1.runnerAnswerText;
}

String _displaySuit(String suit) {
  switch (suit.trim().toLowerCase()) {
    case 's':
    case 'spade':
    case 'spades':
    case '♠':
      return '♠';
    case 'h':
    case 'heart':
    case 'hearts':
    case '♥':
      return '♥';
    case 'd':
    case 'diamond':
    case 'diamonds':
    case '♦':
      return '♦';
    case 'c':
    case 'club':
    case 'clubs':
    case '♣':
      return '♣';
    default:
      return suit.toUpperCase();
  }
}

class _PhaseTrackerV1 extends StatelessWidget {
  const _PhaseTrackerV1({required this.phase});

  final Act0LessonPhaseV1 phase;

  @override
  Widget build(BuildContext context) {
    return Row(
      key: const Key('act0_shell_phase_tracker'),
      children: Act0LessonPhaseV1.values
          .map((item) {
            final active = item == phase;
            final label = switch (item) {
              Act0LessonPhaseV1.theory => 'Learn',
              Act0LessonPhaseV1.drill => 'Practice',
              Act0LessonPhaseV1.review => 'Review',
            };
            final activeColor = switch (item) {
              Act0LessonPhaseV1.theory => Act0ShellTokensV1.info,
              Act0LessonPhaseV1.drill => Act0ShellTokensV1.primary,
              Act0LessonPhaseV1.review => Act0ShellTokensV1.gold,
            };
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: active
                      ? activeColor.withValues(alpha: 0.18)
                      : Act0ShellTokensV1.surface2,
                  borderRadius: BorderRadius.circular(
                    Act0ShellTokensV1.radiusPill,
                  ),
                  border: Border.all(
                    color: active ? activeColor : Act0ShellTokensV1.border,
                  ),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: Act0ShellTokensV1.label.copyWith(
                    color: active ? activeColor : Act0ShellTokensV1.textMuted,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            );
          })
          .toList(growable: false),
    );
  }
}

class _ActionPanelV1 extends StatelessWidget {
  const _ActionPanelV1({
    required this.options,
    required this.selectedOptionId,
    required this.onChoose,
  });

  final List<Act0RunnerOptionV1> options;
  final String? selectedOptionId;
  final ValueChanged<Act0RunnerOptionV1> onChoose;

  bool _shouldStackCompactOptionsV1(BuildContext context) {
    if (options.length != 3) {
      return false;
    }
    final screenWidth = MediaQuery.sizeOf(context).width;
    if (screenWidth > 420) {
      return false;
    }
    var longestLabelLength = 0;
    for (final option in options) {
      final localizedLabel = act0RuntimeLocalizedOptionLabelV1(
        context,
        option.label,
      );
      if (localizedLabel.length > longestLabelLength) {
        longestLabelLength = localizedLabel.length;
      }
    }
    return longestLabelLength > 24;
  }

  @override
  Widget build(BuildContext context) {
    final stackCompactOptions = _shouldStackCompactOptionsV1(context);
    final buttons = options
        .map((option) {
          final selected = option.id == selectedOptionId;
          final actionTone = _ActionToneV1.fromOption(option);
          final tone = selected
              ? option.isCorrect
                    ? Act0ShellTokensV1.primary
                    : Act0ShellTokensV1.danger
              : actionTone.foreground;
          final background = selected
              ? tone.withValues(alpha: 0.16)
              : actionTone.background;
          return OutlinedButton(
            key: Key('act0_shell_option_${option.id}'),
            onPressed: () => onChoose(option),
            style: Act0ShellTokensV1.quietButtonStyle(height: 48).copyWith(
              foregroundColor: WidgetStatePropertyAll(
                selected ? tone : actionTone.foreground,
              ),
              backgroundColor: WidgetStatePropertyAll(background),
              side: WidgetStatePropertyAll(
                BorderSide(
                  color: tone.withValues(
                    alpha: selected ? 0.92 : actionTone.alpha,
                  ),
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(act0RuntimeLocalizedOptionLabelV1(context, option.label)),
                if (option.amountLabel.isNotEmpty)
                  Text(
                    option.amountLabel,
                    style: const TextStyle(fontSize: 9, height: 1.0),
                  ),
              ],
            ),
          );
        })
        .toList(growable: false);
    if (buttons.length <= 3 && !stackCompactOptions) {
      return Row(
        key: const Key('act0_shell_action_panel'),
        children: [
          for (var i = 0; i < buttons.length; i++) ...[
            Expanded(child: buttons[i]),
            if (i < buttons.length - 1)
              const SizedBox(width: Act0ShellTokensV1.gapSm),
          ],
        ],
      );
    }
    return Column(
      key: const Key('act0_shell_action_panel'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < buttons.length; i++) ...[
          buttons[i],
          if (i < buttons.length - 1)
            const SizedBox(height: Act0ShellTokensV1.gapSm),
        ],
      ],
    );
  }
}

class _ActionPromptPanelV1 extends StatelessWidget {
  const _ActionPromptPanelV1({
    required this.taskLabel,
    required this.questionBadgeLabel,
    required this.question,
    required this.child,
    this.contextLine,
    this.embedChildInSurface = false,
    this.onBack,
    this.recallLabel,
    this.onRecall,
  });

  final String taskLabel;
  final String questionBadgeLabel;
  final String question;
  final Widget child;
  final String? contextLine;
  final bool embedChildInSurface;
  final VoidCallback? onBack;
  final String? recallLabel;
  final VoidCallback? onRecall;

  @override
  Widget build(BuildContext context) {
    final formattedTaskLabel = _formatActionPromptCopyV1(
      taskLabel,
      shortThreshold: 32,
    );
    final formattedQuestion = _formatActionPromptCopyV1(
      question,
      shortThreshold: 58,
    );
    Widget buildPromptHeader({bool integrated = false}) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (onBack != null) ...[
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: _DockBackButtonV1(
                key: const Key('act0_shell_interaction_back_cta'),
                onPressed: onBack!,
              ),
            ),
            const SizedBox(width: Act0ShellTokensV1.gapSm),
          ],
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _DockStatusPillV1(
                  key: const Key('act0_shell_question_badge'),
                  label: questionBadgeLabel,
                  icon: Icons.help_outline_rounded,
                  tone: Act0ShellTokensV1.gold,
                ),
                const SizedBox(height: Act0ShellTokensV1.gapXs),
                Text(
                  formattedTaskLabel,
                  key: const Key('act0_shell_action_task_label'),
                  textAlign: TextAlign.center,
                  style: Act0ShellTokensV1.label.copyWith(
                    color: Act0ShellTokensV1.info,
                    letterSpacing: 0.2,
                  ),
                ),
                if (contextLine != null && contextLine!.trim().isNotEmpty) ...[
                  const SizedBox(height: Act0ShellTokensV1.gapXs),
                  Text(
                    contextLine!,
                    key: const Key('act0_shell_action_context_line'),
                    textAlign: TextAlign.center,
                    style: Act0ShellTokensV1.muted.copyWith(
                      color: Act0ShellTokensV1.textMuted,
                      fontSize: 11.0,
                      fontWeight: FontWeight.w800,
                      height: 1.08,
                    ),
                  ),
                ],
                const SizedBox(height: Act0ShellTokensV1.gapXs),
                Text(
                  formattedQuestion,
                  key: const Key('act0_shell_action_question'),
                  textAlign: TextAlign.center,
                  style: Act0ShellTokensV1.body.copyWith(
                    color: Act0ShellTokensV1.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    height: 1.12,
                  ),
                ),
                if (onRecall != null && recallLabel != null) ...[
                  const SizedBox(height: Act0ShellTokensV1.gapXs),
                  _TheoryRecallCtaV1(
                    label: recallLabel!,
                    onPressed: onRecall!,
                    centered: true,
                  ),
                ],
                if (integrated) ...[
                  const SizedBox(height: Act0ShellTokensV1.gapSm),
                  Container(
                    width: double.infinity,
                    height: 1,
                    color: Act0ShellTokensV1.info.withValues(alpha: 0.16),
                  ),
                  const SizedBox(height: Act0ShellTokensV1.gapSm),
                ],
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      key: const Key('act0_shell_action_prompt_panel'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (question.isNotEmpty && embedChildInSurface) ...[
          Container(
            key: const Key('act0_shell_action_prompt_integrated_surface'),
            padding: const EdgeInsets.fromLTRB(
              Act0ShellTokensV1.gapMd,
              Act0ShellTokensV1.gapSm,
              Act0ShellTokensV1.gapMd,
              Act0ShellTokensV1.gapMd,
            ),
            decoration: BoxDecoration(
              color: Act0ShellTokensV1.surface2.withValues(alpha: 0.86),
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
              border: Border.all(
                color: Act0ShellTokensV1.info.withValues(alpha: 0.24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [buildPromptHeader(integrated: true), child],
            ),
          ),
        ] else if (question.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.fromLTRB(
              Act0ShellTokensV1.gapMd,
              Act0ShellTokensV1.gapSm,
              Act0ShellTokensV1.gapMd,
              Act0ShellTokensV1.gapMd,
            ),
            decoration: BoxDecoration(
              color: Act0ShellTokensV1.surface2.withValues(alpha: 0.86),
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
              border: Border.all(
                color: Act0ShellTokensV1.info.withValues(alpha: 0.24),
              ),
            ),
            child: buildPromptHeader(),
          ),
          const SizedBox(height: Act0ShellTokensV1.gapSm),
        ] else if (onBack != null) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: _DockBackButtonV1(
              key: const Key('act0_shell_interaction_back_cta'),
              onPressed: onBack!,
            ),
          ),
          const SizedBox(height: Act0ShellTokensV1.gapSm),
        ],
        if (!embedChildInSurface) child,
      ],
    );
  }
}

class _TheoryRecallCtaV1 extends StatelessWidget {
  const _TheoryRecallCtaV1({
    required this.label,
    required this.onPressed,
    this.centered = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final button = TextButton.icon(
      key: const Key('act0_shell_theory_recall_cta'),
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
        minimumSize: const Size(0, 28),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        foregroundColor: Act0ShellTokensV1.info,
      ),
      icon: const Icon(Icons.auto_stories_rounded, size: 16),
      label: Text(
        label,
        style: Act0ShellTokensV1.label.copyWith(
          color: Act0ShellTokensV1.info,
          fontSize: 11.6,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.12,
        ),
      ),
    );
    if (centered) {
      return Align(alignment: Alignment.center, child: button);
    }
    return Align(alignment: Alignment.centerLeft, child: button);
  }
}

class _TheoryRecallSheetV1 extends StatelessWidget {
  const _TheoryRecallSheetV1({
    required this.label,
    required this.title,
    required this.bodyBlocks,
  });

  final String label;
  final String title;
  final List<String> bodyBlocks;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        child: Container(
          key: const Key('act0_shell_theory_recall_sheet'),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
          decoration: BoxDecoration(
            color: Act0ShellTokensV1.surface,
            borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
            border: Border.all(
              color: Act0ShellTokensV1.info.withValues(alpha: 0.26),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: Act0ShellTokensV1.label.copyWith(
                        color: Act0ShellTokensV1.info,
                        fontSize: 10.4,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.18,
                      ),
                    ),
                  ),
                  IconButton(
                    key: const Key('act0_shell_theory_recall_close_cta'),
                    onPressed: () => Navigator.of(context).pop(),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(
                      width: 28,
                      height: 28,
                    ),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    color: Act0ShellTokensV1.textMuted,
                  ),
                ],
              ),
              if (title.trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  title.trim(),
                  key: const Key('act0_shell_theory_recall_title'),
                  style: Act0ShellTokensV1.body.copyWith(
                    color: Act0ShellTokensV1.text,
                    fontSize: 16,
                    height: 1.08,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
              for (var i = 0; i < bodyBlocks.length; i++) ...[
                SizedBox(height: i == 0 ? 8 : 6),
                Text(
                  bodyBlocks[i],
                  key: i == 0
                      ? const Key('act0_shell_theory_recall_body')
                      : null,
                  style: Act0ShellTokensV1.body.copyWith(
                    color: Act0ShellTokensV1.textMuted,
                    fontSize: 13,
                    height: 1.14,
                    fontWeight: FontWeight.w700,
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

String _formatActionPromptCopyV1(String text, {required int shortThreshold}) {
  final normalized = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (normalized.length <= shortThreshold) {
    return normalized;
  }
  return _formatInstructionCopyV1(normalized, allowSingleClauseSplit: true);
}

class _DockStatusPillV1 extends StatelessWidget {
  const _DockStatusPillV1({
    super.key,
    required this.label,
    required this.icon,
    required this.tone,
  });

  final String label;
  final IconData icon;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
        border: Border.all(color: tone.withValues(alpha: 0.34)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: tone),
          const SizedBox(width: 5),
          Text(
            label,
            style: Act0ShellTokensV1.label.copyWith(
              color: tone,
              fontSize: 9.5,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionToneV1 {
  const _ActionToneV1({
    required this.foreground,
    required this.background,
    required this.alpha,
  });

  final Color foreground;
  final Color background;
  final double alpha;

  static _ActionToneV1 fromOption(Act0RunnerOptionV1 option) {
    final key = '${option.id} ${option.label}'.toLowerCase();
    if (key.contains('call')) {
      return _ActionToneV1(
        foreground: Act0ShellTokensV1.info,
        background: Act0ShellTokensV1.info.withValues(alpha: 0.15),
        alpha: 0.42,
      );
    }
    if (key.contains('raise') || key.contains('bet') || key.contains('all')) {
      return _ActionToneV1(
        foreground: Act0ShellTokensV1.primary,
        background: Act0ShellTokensV1.primary.withValues(alpha: 0.15),
        alpha: 0.50,
      );
    }
    if (key.contains('fold') || key.contains('check')) {
      return _ActionToneV1(
        foreground: Act0ShellTokensV1.text,
        background: Act0ShellTokensV1.surface2,
        alpha: 0.90,
      );
    }
    return _ActionToneV1(
      foreground: Act0ShellTokensV1.text,
      background: Act0ShellTokensV1.surface2.withValues(alpha: 0.72),
      alpha: 0.72,
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:poker_solver/poker_solver.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_content_copy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_sharky_presence_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_tokens_v1.dart';

enum Act0ShellTableVisualVariantV1 { classic, refinedDev2 }

class Act0RunnerCompletionSummaryV1 {
  const Act0RunnerCompletionSummaryV1({
    required this.xpGain,
    required this.startLevel,
    required this.endLevel,
    required this.startXp,
    required this.endXp,
    required this.xpTarget,
  });

  final int xpGain;
  final int startLevel;
  final int endLevel;
  final int startXp;
  final int endXp;
  final int xpTarget;

  bool get leveledUp => endLevel > startLevel;

  String get toastRewardLabel => leveledUp ? 'Level up' : 'Clean rep';
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

  bool get hasNextLesson =>
      nextLessonTitle != null && nextLessonTitle!.isNotEmpty;

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
          : 'Check your quick fixes in Review.';
    }
    if (hasNextLesson) {
      return 'Continue to ${nextLessonTitle!}.';
    }
    return 'All lessons done. Head to Review to track your progress.';
  }

  String get habitRewardLabel {
    if (deepLeakCount > 0) {
      return 'Repair streak';
    }
    if (quickFixCount > 0) {
      return 'Comeback win';
    }
    if (errorCount == 0 && taskCount > 0) {
      return 'Clean pass bonus';
    }
    if (qualifiesForNextLesson) {
      return 'Progress saved';
    }
    return 'Replay ready';
  }

  String get habitRewardDetail {
    if (deepLeakCount > 0) {
      return 'A real weak spot was caught. Fixing it now protects tomorrow from feeling heavier.';
    }
    if (quickFixCount > 0) {
      return 'You corrected a miss inside the lesson. That kind of comeback is how consistency starts to feel earned.';
    }
    if (errorCount == 0 && taskCount > 0) {
      return 'No repairs needed. This is exactly the kind of pass that makes tomorrow lighter.';
    }
    if (qualifiesForNextLesson) {
      return 'The block counts. A short sharp return tomorrow is enough.';
    }
    return 'Replay is the right move before adding new material. Clean it once and the route will feel lighter again.';
  }

  String get gateMessage {
    if (deepLeakCount > 0 && qualifiesForNextLesson) {
      return hasNextLesson
          ? 'Deep leak saved for Review. ${nextLessonTitle!} is unlocked, but repair should be next.'
          : 'Deep leak saved for Review. Clean it up before moving on.';
    }
    return qualifiesForNextLesson
        ? hasNextLesson
              ? 'Strong read. ${nextLessonTitle!} is unlocked.'
              : 'Clean finish. You completed all lessons.'
        : 'Need $unlockAccuracyPercent% accuracy to unlock ${nextLessonTitle!}. Replay this block and tighten up the mistakes.';
  }
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
    required this.onBack,
    required this.onContinueTheory,
    this.onPreviousTheory,
    this.onUndoInteraction,
    required this.onChooseOption,
    this.onChooseSeat,
    required this.onContinueReview,
    this.completionSummary,
    this.tableVisualVariant = Act0ShellTableVisualVariantV1.refinedDev2,
    this.relaxTheoryAdvanceLock = false,
    this.showLearningRailFocusLabels = false,
  });

  final Act0RunnerStateV1 runner;
  final String? selectedTaskId;
  final Act0TaskFamilyV1? selectedTaskFamily;
  final VoidCallback onBack;
  final VoidCallback onContinueTheory;
  final VoidCallback? onPreviousTheory;
  final VoidCallback? onUndoInteraction;
  final ValueChanged<Act0RunnerOptionV1> onChooseOption;
  final ValueChanged<String>? onChooseSeat;
  final VoidCallback onContinueReview;
  final Act0RunnerCompletionSummaryV1? completionSummary;
  final Act0ShellTableVisualVariantV1 tableVisualVariant;
  final bool relaxTheoryAdvanceLock;
  final bool showLearningRailFocusLabels;

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
  bool _canAdvanceTheory = true;
  String _advanceLockKey = '';
  String _showdownInteractionKey = '';
  List<String> _interactiveHighlightedCardIds = const <String>[];
  String _interactiveShowdownLine = '';
  int? _actionTrailFocusedIndex;

  @override
  void initState() {
    super.initState();
    _syncTheoryAdvanceLock(initial: true);
  }

  @override
  void didUpdateWidget(covariant Act0LessonRunnerShellV1 oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncTheoryAdvanceLock();
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
    super.dispose();
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
    final prompt = act0LocalizedRunnerPromptAtomByTaskIdV1(
      widget.selectedTaskId,
      fallback: isTeaching ? teachingStep!.title : runner.caption,
      isRu: act0IsRuLocaleV1(context),
    );
    final shouldShowRunnerHint = switch (runner.hintPolicy) {
      Act0HintPolicyV1.always => true,
      Act0HintPolicyV1.theoryOnly => isTheory,
      Act0HintPolicyV1.hidden => false,
    };
    final hint = act0LocalizedRunnerSupportAtomByTaskIdV1(
      widget.selectedTaskId,
      fallback: isTeaching
          ? teachingStep!.body
          : (shouldShowRunnerHint ? runner.hint : ''),
      isRu: act0IsRuLocaleV1(context),
    );
    final question = act0LocalizedRunnerQuestionAtomByTaskIdV1(
      widget.selectedTaskId,
      fallback: runner.question,
      isRu: act0IsRuLocaleV1(context),
    );
    final learningRailProgress = _learningRailProgressLabel(runner);
    final taskRailLabel = _taskRailLabelForRunner(
      isTeaching: isTeaching,
      isTheory: isTheory,
      isDrill: isDrill,
      isReview: isReview,
      hasSeatTargets: runner.options.any((option) => option.seatId != null),
      taskFamily: widget.selectedTaskFamily,
    );
    final table = isReview
        ? _repairTable(runner.table, runner.selectedOption)
        : _teachingTable(runner.table, teachingStep);
    final showStepIntro =
        isTeaching && runner.teachingStepIndex == 0 && runner.beatIndex > 1;
    final showTopInstructionCard = !isRefinedDev2;
    final pageX = isRefinedDev2 ? 8.0 : Act0ShellTokensV1.runnerPageX;
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
    return Column(
      key: const Key('act0_shell_runner_screen'),
      children: [
        Expanded(
          child: SingleChildScrollView(
            key: const Key('act0_shell_runner_scroll'),
            padding: EdgeInsets.fromLTRB(
              pageX,
              Act0ShellTokensV1.gapSm,
              pageX,
              Act0ShellTokensV1.gapMd,
            ),
            child: Column(
              children: [
                _RunnerProgressV1(runner: runner, onBack: widget.onBack),
                const SizedBox(height: Act0ShellTokensV1.gapSm),
                if (!isRefinedDev2) ...[
                  _PhaseTrackerV1(phase: runner.phase),
                  const SizedBox(height: Act0ShellTokensV1.gapSm),
                ],
                _RunnerInstructionSlotV1(
                  showContent: showTopInstructionCard,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (showStepIntro) ...[
                        _StepIntroPillV1(
                          label: 'New step',
                          title: '${runner.beatIndex}/${runner.beatCount}',
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
                Center(
                  child: _RunnerTableStageV1(
                    table: table,
                    highlightedCardIds: mergedHighlightIds,
                    interactiveCalloutLabel: interactiveCallout,
                    onBoardCardTap: _onBoardTappedForShowdown,
                    onChooseSeat: widget.onChooseSeat,
                    visualVariant: widget.tableVisualVariant,
                    playbackActiveSeatId: playbackActiveSeatId,
                    betOverride: betOverride,
                    potLabelOverride: playbackPotLabel,
                    streetLabelOverride: playbackStreetLabel,
                    completionSummary: showCompletionToast
                        ? widget.completionSummary
                        : null,
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
                        color: Act0ShellTokensV1.info.withValues(alpha: 0.34),
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
                if (table.actionTrail.isNotEmpty) ...[
                  const SizedBox(height: Act0ShellTokensV1.gapSm),
                  _ActionTrailV1(
                    items: table.actionTrail,
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
          ),
        ),
        _RunnerActionDockV1(
          pageX: pageX,
          taskRailLabel: isRefinedDev2 ? null : taskRailLabel,
          sizingPresets: runner.sizingConfig.isEnabled
              ? runner.sizingConfig.presets
              : null,
          selectedPresetId: runner.selectedPresetId,
          onSelectPreset: (preset) {
            widget.onChooseOption(
              Act0RunnerOptionV1(
                id: 'preset_${preset.id}',
                label: preset.label,
                amountLabel: '',
                isCorrect: true,
                preferredLabel: preset.label,
                quality: Act0FeedbackQualityV1.correct,
                feedbackTitle: '',
                feedbackReason: '',
              ),
            );
            setState(() {
              // Store selected preset in runner state via onChooseOption
              // The preset selection is tracked through the runner state update
            });
          },
          child: _showBottomLearningRail
              ? _LearningRailV1(
                  taskLabel: taskRailLabel,
                  prompt: prompt,
                  hint: hint,
                  focusLabels: widget.showLearningRailFocusLabels
                      ? teachingStep?.focusLabels ?? const <String>[]
                      : const <String>[],
                  progressLabel: learningRailProgress,
                  canGoBack: runner.teachingStepIndex > 0,
                  onBack: runner.teachingStepIndex > 0
                      ? widget.onPreviousTheory
                      : null,
                  canAdvance: _canAdvanceTheory,
                  onAdvance: widget.onContinueTheory,
                  sharkyLine: runner.sharky.preSessionLine,
                  sharkyMood: runner.sharky.preSessionMood,
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
                        taskLabel: taskRailLabel ?? 'Tap the correct seat',
                        question: question,
                        options: runner.options,
                        onBack: null,
                      )
                    : _ActionPromptPanelV1(
                        taskLabel: taskRailLabel ?? 'Choose the best action',
                        question: question,
                        onBack: null,
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
                      potLabel: runner.table.potLabel,
                      showPotSweep: _shouldShowPotSweep(runner),
                      contextLabels: runner.reviewContextLabels,
                      refined: isRefinedDev2,
                      completionSummary: widget.completionSummary,
                      onBack: null,
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
              const SizedBox(height: Act0ShellTokensV1.gapSm),
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
          'Bet amount',
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
            preset.label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
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

String? _taskRailLabelForRunner({
  required bool isTeaching,
  required bool isTheory,
  required bool isDrill,
  required bool isReview,
  required bool hasSeatTargets,
  Act0TaskFamilyV1? taskFamily,
}) {
  if (isReview) {
    return 'Check the reason, then continue';
  }
  if (isTeaching || isTheory) {
    return 'Read the table first';
  }
  if (isDrill && hasSeatTargets) {
    return 'Tap the correct seat';
  }
  if (isDrill) {
    if (taskFamily == Act0TaskFamilyV1.sizing) {
      return 'Choose the best size';
    }
    if (taskFamily == Act0TaskFamilyV1.compare) {
      return 'Choose the winning hand';
    }
    if (taskFamily == Act0TaskFamilyV1.counting) {
      return 'Choose the correct count';
    }
    return 'Choose the best action';
  }
  return null;
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
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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
    required this.hint,
    required this.focusLabels,
    required this.progressLabel,
    required this.canGoBack,
    required this.onBack,
    required this.canAdvance,
    required this.onAdvance,
    required this.sharkyLine,
    required this.sharkyMood,
  });

  final String? taskLabel;
  final String prompt;
  final String hint;
  final List<String> focusLabels;
  final String? progressLabel;
  final bool canGoBack;
  final VoidCallback? onBack;
  final bool canAdvance;
  final VoidCallback onAdvance;
  final String sharkyLine;
  final Act0SharkyMoodV1 sharkyMood;

  @override
  Widget build(BuildContext context) {
    final progressMatch = progressLabel == null
        ? null
        : RegExp(r'^(\d+)/(\d+)$').firstMatch(progressLabel!);
    final progressCurrent = progressMatch == null
        ? null
        : int.tryParse(progressMatch.group(1)!);
    final progressTotal = progressMatch == null
        ? null
        : int.tryParse(progressMatch.group(2)!);
    final showProgressDots =
        progressCurrent != null &&
        progressTotal != null &&
        progressTotal > 2 &&
        progressCurrent >= 1 &&
        progressCurrent <= progressTotal;
    final showTaskLabel = taskLabel != null && taskLabel!.trim().isNotEmpty;
    final hasSupportLine = hint.isNotEmpty || focusLabels.isNotEmpty;
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
            constraints: const BoxConstraints(minHeight: 110, maxHeight: 186),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compactRail = constraints.maxHeight <= 138;
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: compactRail ? 10 : 12,
                    vertical: compactRail ? 10 : 11,
                  ),
                  child: Column(
                    children: [
                      if (showTaskLabel || progressLabel != null) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (showTaskLabel)
                              Text(
                                taskLabel!,
                                key: const Key(
                                  'act0_shell_learning_rail_task_label',
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Act0ShellTokensV1.label.copyWith(
                                  color: Act0ShellTokensV1.textMuted,
                                  letterSpacing: 0.2,
                                  fontSize: compactRail ? 10 : 10.5,
                                ),
                              ),
                            const Spacer(),
                            if (progressLabel != null)
                              showProgressDots
                                  ? _RailProgressDotsV1(
                                      key: const Key(
                                        'act0_shell_learning_rail_progress',
                                      ),
                                      count: progressTotal,
                                      current: progressCurrent - 1,
                                    )
                                  : _DockStatusPillV1(
                                      key: const Key(
                                        'act0_shell_learning_rail_progress',
                                      ),
                                      label: progressLabel!,
                                      icon: Icons.notes_rounded,
                                      tone: Act0ShellTokensV1.primary,
                                    ),
                          ],
                        ),
                        SizedBox(height: compactRail ? 5 : 6),
                      ],
                      Expanded(
                        child: Row(
                          children: [
                            _LearningRailNavButtonV1(
                              icon: Icons.arrow_back_ios_new_rounded,
                              buttonKey: const Key('act0_shell_previous_cta'),
                              enabled: canGoBack,
                              onPressed: onBack,
                              compact: compactRail,
                            ),
                            const SizedBox(width: Act0ShellTokensV1.gapSm),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (sharkyLine.isNotEmpty) ...[
                                    _LearningRailSharkyHeaderV1(
                                      line: sharkyLine,
                                      mood: sharkyMood,
                                      compact: compactRail,
                                    ),
                                    SizedBox(height: compactRail ? 4 : 5),
                                  ],
                                  Text(
                                    prompt,
                                    key: const Key('act0_shell_runner_prompt'),
                                    maxLines: compactRail ? 3 : 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: Act0ShellTokensV1.body.copyWith(
                                      color: Act0ShellTokensV1.text,
                                      fontSize: compactRail ? 15 : 16,
                                      height: 1.08,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  if (hasSupportLine) ...[
                                    SizedBox(height: compactRail ? 4 : 6),
                                    Flexible(
                                      child: _LearningRailKeyIdeaV1(
                                        hint: hint,
                                        focusLabels: focusLabels,
                                        compact: compactRail,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: Act0ShellTokensV1.gapSm),
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

class _LearningRailSharkyHeaderV1 extends StatelessWidget {
  const _LearningRailSharkyHeaderV1({
    required this.line,
    required this.mood,
    this.compact = false,
  });

  final String line;
  final Act0SharkyMoodV1 mood;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Act0SharkyMascotV1(
          mood: mood,
          tone: Act0ShellTokensV1.primary,
          size: compact ? 24 : 28,
        ),
        SizedBox(width: compact ? 5 : 6),
        Expanded(
          child: Text(
            line,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Act0ShellTokensV1.muted.copyWith(
              color: Act0ShellTokensV1.textMuted,
              fontSize: compact ? 10.5 : 11,
              height: 1.0,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _LearningRailKeyIdeaV1 extends StatelessWidget {
  const _LearningRailKeyIdeaV1({
    required this.hint,
    required this.focusLabels,
    this.compact = false,
  });

  final String hint;
  final List<String> focusLabels;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final hasHint = hint.trim().isNotEmpty;
    final fallback = focusLabels.take(2).join(' · ');
    final line = hasHint ? hint : fallback;
    if (line.isEmpty) {
      return const SizedBox.shrink();
    }
    return Text(
      line,
      key: const Key('act0_shell_learning_rail_support_line'),
      maxLines: compact ? 3 : 4,
      overflow: TextOverflow.ellipsis,
      style: Act0ShellTokensV1.body.copyWith(
        color: Act0ShellTokensV1.textMuted,
        fontSize: compact ? 12 : 12.6,
        height: 1.15,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _RailProgressDotsV1 extends StatelessWidget {
  const _RailProgressDotsV1({
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
            width: i == current ? 12 : 5,
            height: 5,
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
      width: compact ? 36 : 40,
      height: compact ? 36 : 40,
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
        splashRadius: compact ? 18 : 20,
        padding: EdgeInsets.zero,
        icon: Icon(
          icon,
          size: compact ? 14 : 16,
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
    this.playbackActiveSeatId,
    this.betOverride,
    this.potLabelOverride,
    this.streetLabelOverride,
    this.completionSummary,
  });

  final Act0TableStateV1 table;
  final List<String> highlightedCardIds;
  final String interactiveCalloutLabel;
  final ValueChanged<Act0TableStateV1> onBoardCardTap;
  final ValueChanged<String>? onChooseSeat;
  final Act0ShellTableVisualVariantV1 visualVariant;
  final String? playbackActiveSeatId;
  final Act0SeatBetStateV1? betOverride;
  final String? potLabelOverride;
  final String? streetLabelOverride;
  final Act0RunnerCompletionSummaryV1? completionSummary;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        _Act0TableV1(
          table: table,
          highlightedCardIds: highlightedCardIds,
          interactiveCalloutLabel: interactiveCalloutLabel,
          onBoardCardTap: onBoardCardTap,
          onChooseSeat: onChooseSeat,
          visualVariant: visualVariant,
          playbackActiveSeatId: playbackActiveSeatId,
          betOverride: betOverride,
          potLabelOverride: potLabelOverride,
          streetLabelOverride: streetLabelOverride,
        ),
        if (completionSummary != null)
          Positioned(
            top: 16,
            child: IgnorePointer(
              child: _CompletionToastV1(summary: completionSummary!),
            ),
          ),
      ],
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
    required this.options,
    this.onBack,
  });

  final String taskLabel;
  final String question;
  final List<Act0RunnerOptionV1> options;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('act0_shell_seat_tap_prompt'),
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
      decoration: Act0ShellTokensV1.surfaceDecoration(
        color: Act0ShellTokensV1.surface2,
      ),
      child: Row(
        children: [
          if (onBack != null) ...[
            _DockBackButtonV1(onPressed: onBack!),
            const SizedBox(width: Act0ShellTokensV1.gapSm),
          ] else
            const Icon(
              Icons.touch_app_rounded,
              color: Act0ShellTokensV1.primary,
              size: 20,
            ),
          if (onBack == null) const SizedBox(width: Act0ShellTokensV1.gapSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _DockStatusPillV1(
                  key: Key('act0_shell_action_required_badge'),
                  label: 'Your move',
                  icon: Icons.touch_app_rounded,
                  tone: Act0ShellTokensV1.gold,
                ),
                const SizedBox(height: Act0ShellTokensV1.gapXs),
                Text(
                  taskLabel,
                  key: const Key('act0_shell_seat_tap_task_label'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Act0ShellTokensV1.label.copyWith(
                    color: Act0ShellTokensV1.info,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: Act0ShellTokensV1.gapXs),
                if (question.isNotEmpty)
                  Text(
                    question,
                    key: const Key('act0_shell_action_question'),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Act0ShellTokensV1.body.copyWith(
                      color: Act0ShellTokensV1.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                Text(
                  'Read the table, then tap one seat.',
                  key: const Key('act0_shell_seat_tap_prompt_text'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Act0ShellTokensV1.muted.copyWith(
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
            prompt,
            key: const Key('act0_shell_runner_prompt'),
            textAlign: refined ? TextAlign.left : TextAlign.center,
            maxLines: refined ? 4 : 3,
            overflow: TextOverflow.ellipsis,
            style: Act0ShellTokensV1.body.copyWith(
              color: Act0ShellTokensV1.text,
              fontSize: compact ? 13 : 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (hint.isNotEmpty) ...[
            const SizedBox(height: Act0ShellTokensV1.gapXs),
            Text(
              hint,
              textAlign: refined ? TextAlign.left : TextAlign.center,
              maxLines: refined ? 3 : 2,
              overflow: TextOverflow.ellipsis,
              style: Act0ShellTokensV1.muted.copyWith(
                fontSize: compact ? 11 : 13,
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
    this.potLabel = '',
    this.showPotSweep = false,
    this.contextLabels = const <String>[],
    this.refined = false,
    this.completionSummary,
    this.onBack,
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
  final String potLabel;
  final bool showPotSweep;
  final List<String> contextLabels;
  final bool refined;
  final Act0RunnerCompletionSummaryV1? completionSummary;
  final VoidCallback? onBack;
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
    final reactionLine = _feedbackReactionLineV1(
      sharkyLine: sharkyLine,
      title: title,
      quality: quality,
    );
    final showVerdictTitle = title.isNotEmpty;
    final actionPrefix = isWrong
        ? 'Better option'
        : (isSuboptimal ? 'Sharper line' : 'Best play');
    final actionLabel = isWrong ? betterLabel : preferredLabel;
    return Container(
      key: const Key('act0_shell_feedback_card'),
      padding: EdgeInsets.all(refined ? 10 : 12),
      decoration: Act0ShellTokensV1.surfaceDecoration(
        borderColor: tone.withValues(alpha: 0.46),
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
                size: refined ? 48 : 52,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (reactionLine.isNotEmpty)
                      Text(
                        reactionLine,
                        key: const Key('act0_shell_sharky_outcome_reaction'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Act0ShellTokensV1.muted.copyWith(
                          color: Act0ShellTokensV1.textMuted,
                          fontSize: 11.5,
                          height: 1.12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    if (reactionLine.isNotEmpty && showVerdictTitle)
                      const SizedBox(height: 5),
                    if (showVerdictTitle)
                      Row(
                        children: [
                          Icon(icon, key: iconKey, color: tone, size: 18),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Text(
                              title,
                              style: Act0ShellTokensV1.cardTitle.copyWith(
                                color: tone,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          if ((isWrong || isSuboptimal) && selectedLabel.isNotEmpty) ...[
            Text(
              'You picked $selectedLabel',
              key: const Key('act0_shell_feedback_selected_label'),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Act0ShellTokensV1.muted.copyWith(
                color: Act0ShellTokensV1.textMuted,
              ),
            ),
            const SizedBox(height: 4),
          ],
          if (actionLabel.isNotEmpty) ...[
            Text(
              '$actionPrefix: $actionLabel',
              key: const Key('act0_shell_feedback_preferred_label'),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Act0ShellTokensV1.body.copyWith(
                color: Act0ShellTokensV1.text,
                fontSize: refined ? 17 : 18,
                height: 1.08,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
          ],
          Text(
            reason,
            key: const Key('act0_shell_feedback_reason'),
            maxLines: refined ? 4 : 5,
            overflow: TextOverflow.ellipsis,
            style: Act0ShellTokensV1.body.copyWith(
              color: Act0ShellTokensV1.textMuted,
              fontSize: 13,
              height: 1.2,
            ),
          ),
          if (showPotSweep && potLabel.isNotEmpty) ...[
            const SizedBox(height: 10),
            _PotSweepMomentV1(potLabel: potLabel),
          ],
          if (contextLabels.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              key: const Key('act0_shell_feedback_context_labels'),
              spacing: 6,
              runSpacing: 5,
              children: [
                for (final label in contextLabels)
                  _DockStatusPillV1(
                    label: label,
                    icon: Icons.check_rounded,
                    tone: tone,
                  ),
              ],
            ),
          ],
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
      ),
    );
  }
}

String _feedbackReactionLineV1({
  required String sharkyLine,
  required String title,
  required Act0FeedbackQualityV1 quality,
}) {
  final normalizedLine = sharkyLine.trim().toLowerCase();
  final normalizedTitle = title.trim().toLowerCase();
  if (normalizedLine.isEmpty) {
    return '';
  }
  if (normalizedLine == normalizedTitle) {
    return '';
  }
  if (quality == Act0FeedbackQualityV1.correct && normalizedTitle.isNotEmpty) {
    return sharkyLine;
  }
  return sharkyLine;
}

class Act0BlockCompletionShellV1 extends StatelessWidget {
  const Act0BlockCompletionShellV1({
    super.key,
    required this.summary,
    required this.onReplay,
    required this.onContinue,
    required this.onBackToMap,
  });

  final Act0BlockCompletionSummaryV1 summary;
  final VoidCallback onReplay;
  final VoidCallback onContinue;
  final VoidCallback onBackToMap;

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
                summary.lessonTitle,
                style: Act0ShellTokensV1.screenTitle.copyWith(fontSize: 28),
              ),
              const SizedBox(height: 6),
              Text(
                summary.gateMessage,
                key: const Key('act0_shell_block_summary_gate_message'),
                style: Act0ShellTokensV1.body.copyWith(
                  color: Act0ShellTokensV1.textMuted,
                ),
              ),
              const SizedBox(height: Act0ShellTokensV1.gapMd),
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
                        mascotSize: 50,
                        bubblePadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: Act0ShellTokensV1.gapMd),
              _BlockXpProgressCardV1(summary: summary),
              const SizedBox(height: Act0ShellTokensV1.gapSm),
              Text(
                '${summary.accuracyPercent}% accuracy · ${summary.correctCount}/${summary.taskCount} correct · ${summary.errorCount} errors',
                key: const Key('act0_shell_block_summary_accuracy'),
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
                onPressed: summary.hasNextLesson
                    ? (summary.qualifiesForNextLesson ? onContinue : null)
                    : onBackToMap,
                style: Act0ShellTokensV1.primaryButtonStyle(),
                child: Text(
                  summary.hasNextLesson
                      ? 'Continue to next block'
                      : 'Back to map',
                ),
              ),
              const SizedBox(height: Act0ShellTokensV1.gapSm),
              OutlinedButton(
                key: const Key('act0_shell_block_summary_replay_cta'),
                onPressed: onReplay,
                style: Act0ShellTokensV1.quietButtonStyle(),
                child: const Text('Replay block'),
              ),
              if (summary.hasNextLesson) ...[
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
  const _CompletionToastV1({required this.summary});

  final Act0RunnerCompletionSummaryV1 summary;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 2200),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final appear = Curves.easeOut.transform((value / 0.18).clamp(0.0, 1.0));
        final disappear = Curves.easeIn.transform(
          ((value - 0.72) / 0.28).clamp(0.0, 1.0),
        );
        final opacity = (appear * (1 - disappear)).clamp(0.0, 1.0);
        final animatedGain = (summary.xpGain * appear).round();
        final progress = _feedbackProgressAtGain(summary, animatedGain);
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, (1 - appear) * -6),
            child: Container(
              key: const Key('act0_shell_completion_toast'),
              constraints: const BoxConstraints(minWidth: 94, maxWidth: 118),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              decoration: BoxDecoration(
                color: Act0ShellTokensV1.surface2.withValues(alpha: 0.96),
                borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusMd),
                border: Border.all(
                  color: summary.leveledUp
                      ? Act0ShellTokensV1.gold.withValues(alpha: 0.44)
                      : Act0ShellTokensV1.primary.withValues(alpha: 0.34),
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.24),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    summary.toastRewardLabel,
                    key: const Key('act0_shell_completion_toast_reward_label'),
                    textAlign: TextAlign.center,
                    style: Act0ShellTokensV1.label.copyWith(
                      color: summary.leveledUp
                          ? Act0ShellTokensV1.gold
                          : Act0ShellTokensV1.primary,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '+$animatedGain XP',
                    key: const Key('act0_shell_completion_toast_xp'),
                    style: Act0ShellTokensV1.label.copyWith(
                      color: Act0ShellTokensV1.primary,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (summary.leveledUp)
                    Text(
                      'Level ${summary.endLevel}',
                      key: const Key('act0_shell_completion_toast_level_up'),
                      textAlign: TextAlign.center,
                      style: Act0ShellTokensV1.body.copyWith(
                        color: Act0ShellTokensV1.gold,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    )
                  else
                    Text(
                      '${progress.endXp}/${summary.xpTarget} XP',
                      key: const Key('act0_shell_completion_toast_total'),
                      textAlign: TextAlign.center,
                      style: Act0ShellTokensV1.body.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
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
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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
    this.playbackActiveSeatId,
    this.betOverride,
    this.potLabelOverride,
    this.streetLabelOverride,
  });

  final Act0TableStateV1 table;
  final List<String> highlightedCardIds;
  final String interactiveCalloutLabel;
  final ValueChanged<Act0TableStateV1> onBoardCardTap;
  final ValueChanged<String>? onChooseSeat;
  final Act0ShellTableVisualVariantV1 visualVariant;
  final String? playbackActiveSeatId;
  final Act0SeatBetStateV1? betOverride;
  final String? potLabelOverride;
  final String? streetLabelOverride;

  @override
  Widget build(BuildContext context) {
    final seats = _visualSeatOrder(table.seats);
    final refined = visualVariant == Act0ShellTableVisualVariantV1.refinedDev2;
    var tableMaxWidth = switch (table.density) {
      Act0TableDensityV1.compactLesson => Act0ShellTokensV1.runnerTableMaxWidth,
      Act0TableDensityV1.handView => Act0ShellTokensV1.handTableMaxWidth,
    };
    if (visualVariant == Act0ShellTableVisualVariantV1.refinedDev2 &&
        table.density == Act0TableDensityV1.compactLesson) {
      tableMaxWidth += 32;
    }
    var tableAspect = switch (table.density) {
      Act0TableDensityV1.compactLesson => Act0ShellTokensV1.tableAspect,
      Act0TableDensityV1.handView => Act0ShellTokensV1.handTableAspect,
    };
    if (visualVariant == Act0ShellTableVisualVariantV1.refinedDev2 &&
        table.density == Act0TableDensityV1.compactLesson) {
      tableAspect = 0.69;
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
            final seatSlots = _seatSlotsForVariant(visualVariant);
            final chipSlots = _chipSlotsForVariant(visualVariant);
            final activeSeatId = (playbackActiveSeatId ?? '').trim().isNotEmpty
                ? playbackActiveSeatId
                : _resolveActiveSeatId(table);
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
                          widthFactor: refined ? 0.66 : 0.61,
                          heightFactor: refined ? 0.38 : 0.34,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                Act0ShellTokensV1.radiusPill,
                              ),
                              border: Border.all(
                                color: Act0ShellTokensV1.feltLine.withValues(
                                  alpha: refined ? 0.34 : 0.24,
                                ),
                                width: refined ? 1.4 : 1.0,
                              ),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.22),
                                  blurRadius: 24,
                                  spreadRadius: -18,
                                ),
                              ],
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
                      potLabelOverride: potLabelOverride,
                      streetLabelOverride: streetLabelOverride,
                    ),
                  ),
                  if (table.focusCalloutLabel.isNotEmpty ||
                      interactiveCalloutLabel.isNotEmpty)
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
                  for (var slot = 0; slot < seats.length; slot++)
                    _BetChipPlacementV1(
                      slot: slot,
                      seat: seats[slot],
                      betOverride: activeSeatId == seats[slot].seatId
                          ? betOverride
                          : null,
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
                      selected: table.selectedSeatId == seats[slot].seatId,
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
    final explicit = (table.activeSeatId ?? '').trim();
    if (explicit.isNotEmpty) {
      return explicit;
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
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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

List<Offset> _seatSlotsForVariant(Act0ShellTableVisualVariantV1 variant) {
  switch (variant) {
    case Act0ShellTableVisualVariantV1.classic:
      return _SeatPlacementV1.defaultSlots;
    case Act0ShellTableVisualVariantV1.refinedDev2:
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

List<Offset> _chipSlotsForVariant(Act0ShellTableVisualVariantV1 variant) {
  switch (variant) {
    case Act0ShellTableVisualVariantV1.classic:
      return _BetChipPlacementV1.defaultChipSlots;
    case Act0ShellTableVisualVariantV1.refinedDev2:
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
    this.potLabelOverride,
    this.streetLabelOverride,
  });

  final Act0TableStateV1 table;
  final List<String> highlightedCardIds;
  final VoidCallback onBoardCardTap;
  final Act0ShellTableVisualVariantV1 visualVariant;
  final String? potLabelOverride;
  final String? streetLabelOverride;

  @override
  Widget build(BuildContext context) {
    final refined = visualVariant == Act0ShellTableVisualVariantV1.refinedDev2;
    return Center(
      child: Container(
        key: const Key('act0_shell_center_info_card'),
        width: Act0ShellTokensV1.centerInfoWidth,
        padding: EdgeInsets.symmetric(
          horizontal: refined ? 7 : 4,
          vertical: refined ? 5 : 3,
        ),
        decoration: refined
            ? BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Colors.white.withValues(alpha: 0.04),
                    Colors.black.withValues(alpha: 0.15),
                    Colors.black.withValues(alpha: 0.20),
                  ],
                ),
                borderRadius: BorderRadius.circular(
                  Act0ShellTokensV1.radiusCard,
                ),
                border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.14),
                    blurRadius: 14,
                    offset: const Offset(0, 7),
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
                if (table.centerLabel.isNotEmpty)
                  _CenterInfoPillV1(
                    key: const Key('act0_shell_center_focus_badge'),
                    label: table.centerLabel,
                    tone: Act0ShellTokensV1.primary,
                    icon: Icons.visibility_rounded,
                    compact: refined,
                  ),
                _CenterInfoPillV1(
                  key: const Key('act0_shell_center_street_badge'),
                  label: (streetLabelOverride ?? table.streetLabel)
                      .toUpperCase(),
                  tone: Act0ShellTokensV1.gold,
                  icon: Icons.layers_rounded,
                  compact: refined,
                ),
              ],
            ),
            if (table.boardCards.isNotEmpty) ...[
              const SizedBox(height: Act0ShellTokensV1.gapSm),
              Row(
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
            ],
            const SizedBox(height: Act0ShellTokensV1.gapSm),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 6,
              runSpacing: 4,
              children: [
                _CenterInfoPillV1(
                  key: const Key('act0_shell_center_pot_stat'),
                  label: potLabelOverride ?? table.potLabel,
                  tone: Act0ShellTokensV1.text,
                  icon: Icons.casino_rounded,
                  compact: refined,
                  filled: true,
                  pulse: table.actionTrail.isNotEmpty,
                ),
                if (table.toCallLabel.isNotEmpty)
                  _CenterInfoPillV1(
                    key: const Key('act0_shell_center_to_call_stat'),
                    label: table.toCallLabel,
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
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 5,
      ),
      decoration: BoxDecoration(
        color: filled
            ? tone.withValues(alpha: 0.12)
            : Colors.black.withValues(alpha: compact ? 0.24 : 0.34),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
        border: Border.all(
          color: filled
              ? tone.withValues(alpha: 0.24)
              : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 11 : 12, color: tone),
          const SizedBox(width: 5),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Act0ShellTokensV1.label.copyWith(
              color: filled ? tone : Act0ShellTokensV1.text,
              fontSize: compact ? 8.6 : 9.2,
              letterSpacing: compact ? 0.2 : 0.4,
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
    this.betOverride,
  });

  final int slot;
  final Act0SeatStateV1 seat;
  final double tableWidth;
  final double tableHeight;
  final List<Offset> chipSlots;
  final List<Offset> seatSlots;
  final Act0ShellTableVisualVariantV1 visualVariant;

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
    return TweenAnimationBuilder<double>(
      key: Key('act0_shell_bet_chip_motion_${bet.label}'),
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeOutCubic,
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
      child: _BetChipV1(
        bet: bet,
        compact: visualVariant == Act0ShellTableVisualVariantV1.refinedDev2,
      ),
    );
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
    required this.selected,
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
  final bool selected;
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
          selected: selected,
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
    required this.selected,
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
  final bool selected;
  final Act0ShellTableVisualVariantV1 visualVariant;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final refined = visualVariant == Act0ShellTableVisualVariantV1.refinedDev2;
    final highlighted = active || emphasized || seat.isTarget || selected;
    final showsMarkerCluster =
        seat.isDealerButton ||
        seat.isLastAggressor ||
        (active && !hero) ||
        (!refined && (seat.isSmallBlind || seat.isBigBlind)) ||
        hero;
    final useSlimRefinedSeat = refined && !hero;
    final folded = seat.isFolded;
    final borderColor = highlighted
        ? Act0ShellTokensV1.gold
        : hero
        ? Act0ShellTokensV1.primary
        : selectable && refined
        ? Act0ShellTokensV1.info.withValues(alpha: 0.86)
        : Act0ShellTokensV1.border;
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
                        ? (hero
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
                      if (highlighted)
                        BoxShadow(
                          color: Act0ShellTokensV1.gold.withValues(alpha: 0.24),
                          blurRadius: refined ? 14 : 18,
                        ),
                      if (!highlighted && hero)
                        BoxShadow(
                          color: Act0ShellTokensV1.primary.withValues(
                            alpha: 0.20,
                          ),
                          blurRadius: refined ? 12 : 16,
                        ),
                      if (selectable && !highlighted)
                        BoxShadow(
                          color: Act0ShellTokensV1.info.withValues(alpha: 0.16),
                          blurRadius: refined ? 14 : 12,
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
                              ? Act0ShellTokensV1.surface2
                              : Act0ShellTokensV1.surface3,
                          borderRadius: BorderRadius.circular(
                            Act0ShellTokensV1.radiusPill,
                          ),
                          border: refined && !hero
                              ? Border.all(
                                  color: Act0ShellTokensV1.border.withValues(
                                    alpha: 0.9,
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
                                color: refined
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
                            hero
                                ? refined
                                      ? '${seat.seatLabel} Hero'
                                      : '${seat.seatLabel}  ${seat.displayName}'
                                : seat.seatLabel,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Act0ShellTokensV1.label.copyWith(
                              color: refined && !hero
                                  ? Act0ShellTokensV1.textMuted
                                  : Act0ShellTokensV1.text,
                              fontSize: useSlimRefinedSeat
                                  ? 8.8
                                  : (refined ? 9.2 : 10),
                              letterSpacing: refined ? 0.2 : 0.4,
                            ),
                          ),
                          if (_seatSubLabel(seat) != null)
                            Text(
                              _seatSubLabel(seat)!,
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
                if (showsMarkerCluster)
                  _SeatMarkerPlacementV1(
                    seat: seat,
                    active: active,
                    hero: hero,
                    visualVariant: visualVariant,
                  ),
                if (highlighted)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        key: const Key('act0_shell_active_seat_ring'),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            Act0ShellTokensV1.radiusSm,
                          ),
                          border: Border.all(
                            color: Act0ShellTokensV1.gold.withValues(
                              alpha: 0.42,
                            ),
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

  String? _seatSubLabel(Act0SeatStateV1 seat) {
    final refined = visualVariant == Act0ShellTableVisualVariantV1.refinedDev2;
    final explicitLabel =
        seat.currentBetLabel ?? seat.stackLabel ?? seat.blindAmountLabel;
    final toActAmountLabel = seat.currentBetLabel ?? seat.blindAmountLabel;
    if (!hero && active) {
      if (toActAmountLabel != null && toActAmountLabel.isNotEmpty) {
        return 'To act - $toActAmountLabel';
      }
      return 'To act';
    }
    if (explicitLabel != null && explicitLabel.isNotEmpty) {
      return explicitLabel;
    }
    if (refined && !hero) {
      if (seat.isDealerButton) {
        return 'Dealer';
      }
      if (seat.isSmallBlind) {
        return 'Small blind';
      }
      if (seat.isBigBlind) {
        return 'Big blind';
      }
    }
    return null;
  }
}

class _ActionTrailV1 extends StatefulWidget {
  const _ActionTrailV1({
    required this.items,
    this.streetLabel,
    this.refined = false,
    this.onFocusedIndexChanged,
  });

  final List<Act0ActionTrailItemV1> items;
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
    final streetLabel = widget.streetLabel?.trim() ?? '';
    final visibleCount = _visibleCount.clamp(0, items.length);
    final focusedIndex = items.isEmpty
        ? 0
        : _focusedIndex.clamp(0, visibleCount - 1);
    final text = items.map((item) => item.label).join('  .  ');
    return Container(
      key: const Key('act0_shell_action_trail'),
      constraints: BoxConstraints(maxWidth: refined ? 354 : 370),
      padding: EdgeInsets.symmetric(
        horizontal: refined ? 9 : 11,
        vertical: refined ? 5 : 7,
      ),
      decoration: BoxDecoration(
        color: refined
            ? Act0ShellTokensV1.surface.withValues(alpha: 0.34)
            : Act0ShellTokensV1.surface2.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusXl),
        border: Border.all(
          color: Act0ShellTokensV1.border.withValues(
            alpha: refined ? 0.22 : 0.44,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: refined ? 24 : 26,
            height: refined ? 24 : 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Act0ShellTokensV1.surface3.withValues(
                alpha: refined ? 0.46 : 0.62,
              ),
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
              border: Border.all(
                color: Act0ShellTokensV1.border.withValues(alpha: 0.40),
              ),
            ),
            child: Icon(
              Icons.timeline_rounded,
              key: const Key('act0_shell_action_trail_icon'),
              size: refined ? 13 : 14,
              color: Act0ShellTokensV1.textMuted.withValues(
                alpha: refined ? 0.72 : 0.82,
              ),
            ),
          ),
          SizedBox(width: refined ? 7 : 8),
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
                Row(
                  children: [
                    if (streetLabel.isNotEmpty) ...[
                      Container(
                        key: const Key('act0_shell_action_trail_street_badge'),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Act0ShellTokensV1.info.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(
                            Act0ShellTokensV1.radiusPill,
                          ),
                          border: Border.all(
                            color: Act0ShellTokensV1.info.withValues(
                              alpha: 0.34,
                            ),
                          ),
                        ),
                        child: Text(
                          streetLabel,
                          style: Act0ShellTokensV1.label.copyWith(
                            fontSize: 7.6,
                            color: Act0ShellTokensV1.info,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      SizedBox(width: refined ? 6 : 7),
                    ],
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: [
                            for (var i = 0; i < visibleCount; i++) ...[
                              if (i > 0 &&
                                  _streetNameFromLabel(items[i].label) != null)
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
                                      setState(() => _isAutoPlaying = false);
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
                ),
              ],
            ),
          ),
          if (items.length > 1) ...[
            SizedBox(width: refined ? 7 : 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _TrailPlaybackButtonV1(
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
                  icon: _isAutoPlaying
                      ? Icons.pause_circle_filled_rounded
                      : Icons.play_circle_fill_rounded,
                  onTap: _toggleAutoPlay,
                  active: _isAutoPlaying,
                  compact: refined,
                ),
                SizedBox(width: refined ? 4 : 5),
                _TrailPlaybackButtonV1(
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
            ),
          ],
        ],
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
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: EdgeInsets.all(compact ? 3 : 4),
          decoration: BoxDecoration(
            color: active
                ? Act0ShellTokensV1.primary.withValues(alpha: 0.20)
                : Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: active
                  ? Act0ShellTokensV1.primary.withValues(alpha: 0.62)
                  : Act0ShellTokensV1.border.withValues(alpha: 0.44),
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
                widget.item.label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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
                    'Now',
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
  const _SeatMarkersV1({
    required this.seat,
    required this.active,
    required this.hero,
    required this.visualVariant,
  });

  final Act0SeatStateV1 seat;
  final bool active;
  final bool hero;
  final Act0ShellTableVisualVariantV1 visualVariant;

  @override
  Widget build(BuildContext context) {
    final refined = visualVariant == Act0ShellTableVisualVariantV1.refinedDev2;
    return Wrap(
      key: Key('act0_shell_marker_cluster_${seat.seatId}'),
      spacing: 3,
      runSpacing: 3,
      children: [
        if (seat.isDealerButton) const _MarkerDotV1(label: 'D'),
        if (!refined && seat.isSmallBlind) const _MarkerDotV1(label: 'SB'),
        if (!refined && seat.isBigBlind) const _MarkerDotV1(label: 'BB'),
        if (seat.isLastAggressor) const _MarkerDotV1(label: 'Agg'),
        if (active && !hero) const _MarkerDotV1(label: 'Act'),
      ],
    );
  }
}

class _SeatMarkerPlacementV1 extends StatelessWidget {
  const _SeatMarkerPlacementV1({
    required this.seat,
    required this.active,
    required this.hero,
    required this.visualVariant,
  });

  final Act0SeatStateV1 seat;
  final bool active;
  final bool hero;
  final Act0ShellTableVisualVariantV1 visualVariant;

  @override
  Widget build(BuildContext context) {
    final refined = visualVariant == Act0ShellTableVisualVariantV1.refinedDev2;
    final leftSide = seat.seatLabel == 'SB' || seat.seatLabel == 'BB';
    final bottomHero = hero;
    return Positioned(
      top: bottomHero ? (refined ? 6 : 4) : (refined ? -10 : -12),
      left: leftSide ? (refined ? -6 : -10) : null,
      right: bottomHero
          ? (refined ? -38 : -48)
          : (leftSide ? null : (refined ? -6 : -10)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: refined ? 42 : 50),
        child: _SeatMarkersV1(
          seat: seat,
          active: active,
          hero: hero,
          visualVariant: visualVariant,
        ),
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
              SizedBox(height: compact ? 1 : 2),
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

  @override
  Widget build(BuildContext context) {
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
                Text(option.label),
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
    if (buttons.length <= 3) {
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
    required this.question,
    required this.child,
    this.onBack,
  });

  final String taskLabel;
  final String question;
  final Widget child;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('act0_shell_action_prompt_panel'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (question.isNotEmpty) ...[
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _DockStatusPillV1(
                      key: Key('act0_shell_question_badge'),
                      label: 'Spot check',
                      icon: Icons.help_outline_rounded,
                      tone: Act0ShellTokensV1.gold,
                    ),
                    const SizedBox(height: Act0ShellTokensV1.gapXs),
                    Text(
                      taskLabel,
                      key: const Key('act0_shell_action_task_label'),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Act0ShellTokensV1.label.copyWith(
                        color: Act0ShellTokensV1.info,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: Act0ShellTokensV1.gapXs),
                    Text(
                      question,
                      key: const Key('act0_shell_action_question'),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Act0ShellTokensV1.body.copyWith(
                        color: Act0ShellTokensV1.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
        child,
      ],
    );
  }
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

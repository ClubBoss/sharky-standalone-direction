import 'package:poker_analyzer/helpers/showdown_evaluator.dart';
import 'package:poker_analyzer/models/card_model.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

/// NEW_AUTHORING_2026_11_08. Private, unregistered instructional source.
/// Two known-hole-card turn decisions, not recovered historical catalog hands.
/// This is not a range solver, unrestricted strategy recommendation, generic
/// betting engine, or certificate for the existing Runner/PKR06 consumers.
enum Act0Asm05ActionV1 { fold, call }

enum Act0Asm05WinnerV1 { hero, villain, tie }

class Act0Asm05LedgerEventV1 {
  const Act0Asm05LedgerEventV1(
    this.street,
    this.seatId,
    this.action,
    this.addedHalfBb,
  );

  final String street;
  final String seatId;
  final String action;
  // Integer half-BB units keep the 0.5/1 blinds exact.
  final int addedHalfBb;
}

/// Only two closed, authored variants are admitted here. The final class and
/// fixed constructors prevent arbitrary cards/prices inheriting this model.
final class Act0Asm05TurnSnapshotV1 {
  const Act0Asm05TurnSnapshotV1.call10() : turnBetBb = 10;
  const Act0Asm05TurnSnapshotV1.call40() : turnBetBb = 40;

  final int turnBetBb;
  String get sourceId => 'asm05_new_known_holes_turn_call_$turnBetBb';
  String get provenance => 'NEW_AUTHORING_2026_11_08';
  List<String> get heroCards => const ['Kh', 'Qh'];
  List<String> get knownVillainCards => const ['As', 'Ad'];
  List<String> get turnBoard => const ['2h', '7h', '9s', '3c'];
  List<String> get seatIds => const ['utg', 'hj', 'co', 'btn', 'sb', 'bb'];
  List<String> get foldedSeatIds => const ['utg', 'hj', 'co', 'btn'];
  List<Act0Asm05ActionV1> get availableActions =>
      const [Act0Asm05ActionV1.fold, Act0Asm05ActionV1.call];

  /// The folds are prescribed independently of folded cards. Unknown burns
  /// and folded cards carry no additional information about the river.
  /// Villain's cards are intentionally disclosed in this teaching model.
  String get assumptions =>
      'New authored exercise. Six players started with 100 BB each, no ante '
      'or rake. Hero BB has Kh Qh; SB is known to hold As Ad. The deck is '
      'uniformly shuffled. The other four players were instructed to fold '
      'independently of their cards; their cards and burns are unknown and '
      'give no information. All prior actions and this bet are prescribed '
      'and give no additional card information. Compare call with fold only; '
      'raises are outside this exercise. After a call both players must check '
      'the river, with no more betting. Compare incremental expected value '
      'at this decision; the previous 20 BB is already spent in either case.';

  List<Act0Asm05LedgerEventV1> get ledger => List.unmodifiable([
    const Act0Asm05LedgerEventV1('preflop', 'sb', 'post', 1),
    const Act0Asm05LedgerEventV1('preflop', 'bb', 'post', 2),
    for (final seat in foldedSeatIds)
      Act0Asm05LedgerEventV1('preflop', seat, 'fold', 0),
    // SB's 0.5 blind plus 19.5 added = 20 total. BB adds 19 to its 1.
    const Act0Asm05LedgerEventV1('preflop', 'sb', 'raise_to_20', 39),
    const Act0Asm05LedgerEventV1('preflop', 'bb', 'call_to_20', 38),
    const Act0Asm05LedgerEventV1('flop', 'sb', 'check', 0),
    const Act0Asm05LedgerEventV1('flop', 'bb', 'check', 0),
    Act0Asm05LedgerEventV1('turn', 'sb', 'bet', turnBetBb * 2),
  ]);

  int committedHalfBb(String seatId) {
    if (!seatIds.contains(seatId)) throw ArgumentError.value(seatId);
    return ledger.where((e) => e.seatId == seatId).fold(
      0, (int sum, e) => sum + e.addedHalfBb,
    );
  }

  int remainingHalfBb(String seatId) => 200 - committedHalfBb(seatId);
  int get potBeforeBetBb => 40;
  int get potAtDecisionBb =>
      ledger.fold(0, (int sum, e) => sum + e.addedHalfBb) ~/ 2;
  int get additionalCallBb => turnBetBb;
  int get potAfterCallBb => potAtDecisionBb + additionalCallBb;

  /// Data-only pre-choice projection. It deliberately has no actual river,
  /// winner, EV, grade, preferred action, feedback, or highlighted answer.
  /// A future adapter must preserve that boundary in visible AND semantics UI.
  Map<String, Object> toPredecisionJson() => {
    'sourceId': sourceId,
    'provenance': provenance,
    'assumptions': assumptions,
    'tableFormat': 'sixMax',
    'street': 'turn',
    'pendingActor': 'bb',
    'heroCards': heroCards,
    'knownVillainCards': knownVillainCards,
    'board': turnBoard,
    'potBb': potAtDecisionBb,
    'additionalCallBb': additionalCallBb,
    'actions': availableActions.map((a) => a.name).toList(growable: false),
    'seats': [
      for (final seat in seatIds) {
        'seatId': seat,
        'startingHalfBb': 200,
        'committedHalfBb': committedHalfBb(seat),
        'remainingHalfBb': remainingHalfBb(seat),
        'folded': foldedSeatIds.contains(seat),
      },
    ],
    'ledger': [
      for (final e in ledger) {
        'street': e.street, 'seatId': e.seatId,
        'action': e.action, 'addedHalfBb': e.addedHalfBb,
      },
    ],
  };
}

CardModel _card(String id) => CardModel(rank: id[0], suit: id[1]);

List<String> _unseenRivers(Act0Asm05TurnSnapshotV1 source) {
  final known = {...source.heroCards, ...source.knownVillainCards,
    ...source.turnBoard};
  return [
    for (final rank in '23456789TJQKA'.split(''))
      for (final suit in 'cdhs'.split(''))
        if (!known.contains('$rank$suit')) '$rank$suit',
  ];
}

Act0Asm05WinnerV1 _winner(
  Act0Asm05TurnSnapshotV1 source,
  String river,
) {
  if (!_unseenRivers(source).contains(river)) {
    throw ArgumentError.value(river, 'river', 'Must be an unseen deck card');
  }
  // Reuse the existing poker_solver-backed evaluator, not the stub under
  // lib/engine/hand_evaluator.dart (that stub ranks by card count).
  final winners = determineWinners(
    [...source.turnBoard, river].map(_card).toList(growable: false),
    {0: source.heroCards.map(_card).toList(growable: false),
      1: source.knownVillainCards.map(_card).toList(growable: false)},
  );
  if (winners.length == 1 && winners.single == 0) {
    return Act0Asm05WinnerV1.hero;
  }
  if (winners.length == 1 && winners.single == 1) {
    return Act0Asm05WinnerV1.villain;
  }
  if (winners.length == 2 && winners.toSet().containsAll([0, 1])) {
    return Act0Asm05WinnerV1.tie;
  }
  throw StateError('Showdown evaluator returned no valid winner');
}

class Act0Asm05DecisionTruthV1 {
  const Act0Asm05DecisionTruthV1._({
    required this.sourceId,
    required this.riverCount,
    required this.heroWins,
    required this.ties,
    required this.callEvNumerator,
    required this.callEvDenominator,
  });

  final String sourceId;
  final int riverCount;
  final int heroWins;
  final int ties;
  // Exact rational BB, incremental from this decision, NOT whole-hand profit.
  final int callEvNumerator;
  final int callEvDenominator;
  double get callIncrementalEvBb => callEvNumerator / callEvDenominator;
  int get foldIncrementalEvBb => 0;
  bool accepts(Act0Asm05ActionV1 action) => switch (action) {
    Act0Asm05ActionV1.call => callEvNumerator >= 0,
    Act0Asm05ActionV1.fold => callEvNumerator <= 0,
  };
}

/// Independent of Runner option flags and of any selected/revealed river.
/// Enumerates every possible river; the chosen demonstration runout is NOT
/// an input. The separate Python review uses independent best-five ranking.
Act0Asm05DecisionTruthV1 act0Asm05DecisionTruthV1(
  Act0Asm05TurnSnapshotV1 source,
) {
  final rivers = _unseenRivers(source);
  var wins = 0;
  var ties = 0;
  for (final river in rivers) {
    switch (_winner(source, river)) {
      case Act0Asm05WinnerV1.hero:
        wins += 1;
        break;
      case Act0Asm05WinnerV1.tie:
        ties += 1;
        break;
      case Act0Asm05WinnerV1.villain: break;
    }
  }
  final denominator = rivers.length * 2;
  return Act0Asm05DecisionTruthV1._(
    sourceId: source.sourceId,
    riverCount: rivers.length,
    heroWins: wins,
    ties: ties,
    callEvNumerator: (2 * wins + ties) * source.potAfterCallBb -
        denominator * source.additionalCallBb,
    callEvDenominator: denominator,
  );
}

class Act0Asm05RealizedOutcomeV1 {
  const Act0Asm05RealizedOutcomeV1._({
    required this.river,
    required this.winner,
    required this.heroFinalStackBb,
    required this.villainFinalStackBb,
    required this.awardedPotBb,
    required this.uncalledReturnBb,
  });

  // Null after folding: no played river or showdown is fabricated.
  final String? river;
  final Act0Asm05WinnerV1 winner;
  final double heroFinalStackBb;
  final double villainFinalStackBb;
  final int awardedPotBb;
  final int uncalledReturnBb;
  double get heroWholeHandProfitBb => heroFinalStackBb - 100;
}

class Act0Asm05CommittedResultV1 {
  const Act0Asm05CommittedResultV1._({
    required this.choice, required this.truth, required this.outcome,
  });

  final Act0Asm05ActionV1 choice;
  final Act0Asm05DecisionTruthV1 truth;
  final Act0Asm05RealizedOutcomeV1 outcome;
  bool get isCorrect => truth.accepts(choice);
}

/// Owns a demonstration runout separately from the decision-visible snapshot.
/// The runout is an authored example, never a claimed random sample.
/// This pure function is not the Runner's submission/duplicate-callback guard.
final class Act0Asm05AuthoredExerciseV1 {
  Act0Asm05AuthoredExerciseV1({
    required this.preDecision,
    required String realizedRiver,
  }) : _realizedRiver = realizedRiver {
    if (!_unseenRivers(preDecision).contains(realizedRiver)) {
      throw ArgumentError.value(realizedRiver, 'realizedRiver');
    }
  }

  factory Act0Asm05AuthoredExerciseV1.goodCallLoses() =>
      Act0Asm05AuthoredExerciseV1(
        preDecision: const Act0Asm05TurnSnapshotV1.call10(),
        realizedRiver: 'Td',
      );

  factory Act0Asm05AuthoredExerciseV1.badCallWins() =>
      Act0Asm05AuthoredExerciseV1(
        preDecision: const Act0Asm05TurnSnapshotV1.call40(),
        realizedRiver: '5h',
      );

  final Act0Asm05TurnSnapshotV1 preDecision;
  final String _realizedRiver;
  // Evaluated once per immutable exercise. Neither option flags nor the
  // selected demonstration river is an argument to this independent oracle.
  late final Act0Asm05DecisionTruthV1 decisionTruth =
      act0Asm05DecisionTruthV1(preDecision);

  /// Pure source projection, not a user event. The factory may precompute
  /// review-only option data; the consumer must reveal it only after choice.
  /// Grade from the snapshot; then evaluate the actual runout separately.
  Act0Asm05CommittedResultV1 complete(Act0Asm05ActionV1 choice) {
    final truth = decisionTruth;
    if (choice == Act0Asm05ActionV1.fold) {
      return Act0Asm05CommittedResultV1._(
        choice: choice, truth: truth,
        outcome: Act0Asm05RealizedOutcomeV1._(
          river: null, winner: Act0Asm05WinnerV1.villain,
          heroFinalStackBb: 80, villainFinalStackBb: 120,
          awardedPotBb: preDecision.potBeforeBetBb,
          uncalledReturnBb: preDecision.turnBetBb,
        ),
      );
    }
    final winner = _winner(preDecision, _realizedRiver);
    final pot = preDecision.potAfterCallBb;
    final heroShare = switch (winner) {
      Act0Asm05WinnerV1.hero => pot.toDouble(),
      Act0Asm05WinnerV1.villain => 0.0,
      Act0Asm05WinnerV1.tie => pot / 2,
    };
    final behind = 80 - preDecision.additionalCallBb;
    return Act0Asm05CommittedResultV1._(
      choice: choice, truth: truth,
      outcome: Act0Asm05RealizedOutcomeV1._(
        river: _realizedRiver, winner: winner,
        heroFinalStackBb: behind + heroShare,
        villainFinalStackBb: behind + pot - heroShare,
        awardedPotBb: pot, uncalledReturnBb: 0,
      ),
    );
  }
}

Act0CardStateV1 _visibleCard(String id) => Act0CardStateV1(
  rank: id[0],
  suit: const {'c': '♣', 'd': '♦', 'h': '♥', 's': '♠'}[id[1]]!,
  tone: id[1] == 'h' || id[1] == 'd'
      ? Act0CardToneV1.red : Act0CardToneV1.dark,
);

String _bbText(num value) => value == value.roundToDouble()
    ? value.toInt().toString() : value.toString();

/// The fixed turn snapshot stays explicitly labelled as the decision basis.
/// The actual river and payout are reported in selected-option feedback;
/// no post-choice board animation or changing table state is fabricated.
Act0TableStateV1 _decisionTable(Act0Asm05TurnSnapshotV1 source) =>
    Act0TableStateV1(
      scope: Act0TableScopeV1.playedHand,
      tableFormat: Act0TableFormatV1.sixMax,
      playerCount: 6,
      seats: List.unmodifiable([
        for (final seat in source.seatIds)
          Act0SeatStateV1(
            seatId: seat, seatLabel: seat.toUpperCase(),
            displayName: seat == 'bb' ? 'You' : seat.toUpperCase(),
            isHero: seat == 'bb', isActive: seat == 'bb',
            isBigBlind: seat == 'bb', isSmallBlind: seat == 'sb',
            isDealerButton: seat == 'btn',
            blindAmountLabel: seat == 'sb' ? '0.5 BB'
                : seat == 'bb' ? '1 BB' : null,
            isFolded: source.foldedSeatIds.contains(seat),
            isInHand: !source.foldedSeatIds.contains(seat),
            hasActed: seat != 'bb', isLastAggressor: seat == 'sb',
            stackLabel: '${_bbText(source.remainingHalfBb(seat) / 2)} BB',
            currentBetLabel: '${seat == 'sb' ? source.turnBetBb : 0} BB',
            cardsVisibleMode: source.foldedSeatIds.contains(seat)
                ? Act0CardsVisibleModeV1.none : Act0CardsVisibleModeV1.faceUp,
            holeCards: List.unmodifiable((seat == 'bb' ? source.heroCards
                : seat == 'sb' ? source.knownVillainCards : <String>[])
                .map(_visibleCard)),
            bet: seat == 'sb' ? Act0SeatBetStateV1(
              kind: Act0SeatBetKindV1.bet, label: 'SB',
              amountLabel: '${source.turnBetBb} BB',
            ) : null,
          ),
      ]),
      heroCards: List.unmodifiable(source.heroCards.map(_visibleCard)),
      boardCards: List.unmodifiable(source.turnBoard.map(_visibleCard)),
      streetLabel: 'Turn',
      potLabel: 'Pot ${source.potAtDecisionBb} BB',
      toCallLabel: 'To call ${source.additionalCallBb} BB',
      centerLabel: 'Turn decision snapshot',
      actionTrail: List.unmodifiable([
        for (final e in source.ledger)
          Act0ActionTrailItemV1(label:
            '${e.street[0].toUpperCase()}${e.street.substring(1)}: '
            '${e.seatId.toUpperCase()} ${switch (e.action) {
              'post' => 'posts ${_bbText(e.addedHalfBb / 2)} BB',
              'fold' => 'folds',
              'raise_to_20' => 'raises to 20 BB',
              'call_to_20' => 'calls 20 BB',
              'check' => 'checks',
              'bet' => 'bets ${_bbText(e.addedHalfBb / 2)} BB',
              _ => throw StateError('Unsupported authored ledger event'),
            }}'),
      ]),
      activeSeatId: 'bb', heroSeatId: 'bb',
      highlightedSeatIds: const [], highlightedCardIds: const [],
    );

String _reviewOutcome(Act0Asm05CommittedResultV1 result) {
  final outcome = result.outcome;
  if (result.choice == Act0Asm05ActionV1.fold) {
    return 'Fold: SB gets ${outcome.uncalledReturnBb} BB back and takes '
        '${outcome.awardedPotBb} BB. No river is played. '
        'Stacks You ${_bbText(outcome.heroFinalStackBb)}, '
        'SB ${_bbText(outcome.villainFinalStackBb)}.';
  }
  final award = switch (outcome.winner) {
    Act0Asm05WinnerV1.hero => 'You receive ${outcome.awardedPotBb} BB',
    Act0Asm05WinnerV1.villain => 'SB receives ${outcome.awardedPotBb} BB',
    Act0Asm05WinnerV1.tie => 'Each receives ${outcome.awardedPotBb / 2} BB',
  };
  return 'River ${outcome.river}: $award. '
      'Stacks You ${_bbText(outcome.heroFinalStackBb)}, '
      'SB ${_bbText(outcome.villainFinalStackBb)}.';
}

/// Real existing Task/Runner types; no shared consumer changes or catalog
/// registration. Static option fields are OUTPUTS of one independent truth.
/// Existing Runner/Preview may consume them consistently without a second
/// grader. Display feedback is derived from actual evaluator/payout results,
/// not a manually swapped win/loss caption. It is review-only authored data.
/// Factory/source tests are not proof of real callback or UI compatibility.
Act0LessonTaskV1 act0Asm05AuthoredDecisionTaskV1({
  required Act0Asm05AuthoredExerciseV1 exercise,
  required String lessonId,
  required String lessonTitle,
  required int beatIndex,
  required int beatCount,
  required int rewardXp,
  required String returnTarget,
  required String? nextLessonId,
}) {
  final source = exercise.preDecision;
  final truth = exercise.decisionTruth;
  final expected = truth.accepts(Act0Asm05ActionV1.call)
      ? 'Call ${source.additionalCallBb} BB' : 'Fold';
  final ev = truth.callIncrementalEvBb.toStringAsFixed(2);
  final options = List<Act0RunnerOptionV1>.unmodifiable([
    for (final action in source.availableActions)
      Act0RunnerOptionV1(
        id: action.name, label: action == Act0Asm05ActionV1.call ? 'Call' : 'Fold',
        amountLabel: action == Act0Asm05ActionV1.call
            ? '${source.additionalCallBb} BB' : '',
        isCorrect: truth.accepts(action),
        quality: truth.accepts(action)
            ? Act0FeedbackQualityV1.correct : Act0FeedbackQualityV1.wrong,
        preferredLabel: expected,
        feedbackTitle: truth.accepts(action)
            ? 'Correct decision. Judge the choice, not the result.'
            : '$expected has the higher expected value.',
        feedbackReason: '${_reviewOutcome(exercise.complete(action))} '
            'Call EV $ev BB; Fold 0. The earlier 20 BB is sunk.',
      ),
  ]);
  return Act0LessonTaskV1(
    taskId: source.sourceId, title: 'Decision and outcome',
    phase: Act0LessonPhaseV1.drill, rewardXp: rewardXp,
    taskFamily: Act0TaskFamilyV1.decision,
    tablePresentation: Act0TaskTablePresentationV1.stablePractice,
    summary: source.assumptions,
    runner: Act0RunnerStateV1(
      lessonId: lessonId, lessonTitle: lessonTitle,
      lessonSubtitle: 'Known cards, fixed call-or-fold model',
      beatIndex: beatIndex, beatCount: beatCount,
      phase: Act0LessonPhaseV1.drill,
      caption: 'SB holds As Ad. If you call, both players must check the '
          'river. Raises are excluded. No ante or rake.',
      hint: 'All seats started with 100 BB. Uniform deck; prior actions '
          'and this bet were prescribed independently of unknown cards. '
          'The other four players folded without adding chips; their cards '
          'and burns are unknown and give no information. The earlier '
          '20 BB is already spent in either case.',
      hintPolicy: Act0HintPolicyV1.always,
      question: 'Call ${source.additionalCallBb} BB or fold: '
          'which has higher incremental expected value now?',
      options: options,
      // Neutral fallbacks: selected option supplies result only in review.
      feedbackTitle: 'Review the decision',
      feedbackReason: 'Compare the choice using the information available then.',
      // Explicit source signal avoids the generic price_read fallback.
      // The admitted lesson maps to existing process_over_outcome receipts;
      // other lesson identities stay fail-closed.
      feedbackSignalId: 'asm05_known_holes_ev',
      primaryCtaLabel: 'Choose', nextLessonId: nextLessonId,
      returnTarget: returnTarget, table: _decisionTable(source),
    ),
  );
}

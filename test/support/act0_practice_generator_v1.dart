import 'dart:math';

import 'package:poker_analyzer/models/poker_street.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_hand_contributions_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_practice_showdown_v1.dart';

import 'act0_catalog_poker_facts_v1.dart';
import 'act0_catalog_snapshot_v1.dart';
import 'act0_catalog_starting_chart_v1.dart';

part 'act0_postflop_practice_templates_v1.dart';

enum TurnOutsModeV1 { callOrFoldAllIn, outsPriceNumeric }

class GeneratedPracticeTaskV1 {
  const GeneratedPracticeTaskV1({
    required this.templateId,
    required this.worldNumber,
    required this.lessonId,
    required this.task,
    required this.metadata,
  });

  final String templateId;
  final int worldNumber;
  final String lessonId;
  final Act0LessonTaskV1 task;
  final Map<String, Object?> metadata;

  CatalogTask toCatalogRow({
    Act0WorldCardV1? world,
    Act0LessonCardV1? lesson,
    int lessonIndex = 0,
  }) {
    final targetWorld =
        world ??
        Act0WorldCardV1(
          worldId: 'world_$worldNumber',
          worldNumber: worldNumber,
          title: 'Generated Practice World $worldNumber',
          subtitle: 'Practice generated hand decisions.',
          status: Act0WorldStateV1.current,
          progressLabel: '0 of 1 lessons complete',
          primaryCtaLabel: 'Open lessons',
          unlockLabel: '',
          isSelectable: true,
          isLocked: false,
          rewardXp: task.rewardXp,
          lessons: const [],
        );
    final targetLesson =
        lesson ??
        Act0LessonCardV1(
          lessonId: lessonId,
          title: task.title,
          subtitle: 'Generated practice task.',
          state: Act0LessonStateV1.current,
          phaseLabel: 'Practice',
          primaryCtaLabel: 'Start',
          isSelectable: true,
          isLocked: false,
          rewardXp: task.rewardXp,
          runner: task.runner,
          tasks: [task],
        );
    return (
      world: targetWorld,
      lesson: targetLesson,
      task: task,
      lessonIndex: lessonIndex,
    );
  }
}

const _preflopSeats = ['utg', 'hj', 'co', 'btn', 'sb', 'bb'];
const _suits = ['s', 'h', 'd', 'c'];

String _bbLabel(double bb) {
  final rounded = bb.roundToDouble();
  if ((bb - rounded).abs() < 1e-6) {
    return '${rounded.toInt()} BB';
  }
  final tenths = (bb * 10).roundToDouble() / 10;
  if ((bb - tenths).abs() < 1e-6) {
    return '${tenths.toStringAsFixed(1)} BB';
  }
  return '${bb.toStringAsFixed(2)} BB';
}

Act0CardStateV1 _cardFromCode(String code) {
  final rank = code.substring(0, code.length - 1);
  final suit = code.substring(code.length - 1);
  return Act0CardStateV1(
    rank: rank == '10' ? 'T' : rank,
    suit: suit,
    tone: (suit == 'h' || suit == 'd')
        ? Act0CardToneV1.red
        : Act0CardToneV1.dark,
  );
}

List<String> _fullDeck() => [
  for (final r in pokerRanks.split(''))
    for (final s in _suits) '$r$s',
];

List<String> _cardsForHandCode(String handCode, Random rng) {
  final r1 = handCode[0];
  final r2 = handCode[1];
  if (r1 == r2) {
    final suits = [..._suits]..shuffle(rng);
    return ['$r1${suits[0]}', '$r2${suits[1]}'];
  }
  if (handCode.endsWith('s')) {
    final suit = _suits[rng.nextInt(_suits.length)];
    return ['$r1$suit', '$r2$suit'];
  }
  final suits = [..._suits]..shuffle(rng);
  return ['$r1${suits[0]}', '$r2${suits[1]}'];
}

List<String> _all169HandCodes() {
  final ranks = pokerRanks.split('');
  final codes = <String>[];
  for (var i = 0; i < ranks.length; i++) {
    codes.add('${ranks[i]}${ranks[i]}');
    for (var j = i + 1; j < ranks.length; j++) {
      codes.add('${ranks[i]}${ranks[j]}s');
      codes.add('${ranks[i]}${ranks[j]}o');
    }
  }
  return codes;
}

Act0TableStateV1 _buildPreflopTable({
  required String heroSeat,
  required List<String> cardCodes,
}) {
  final heroIndex = _preflopSeats.indexOf(heroSeat);
  final folded = _preflopSeats.take(heroIndex).toSet();
  final heroCards = cardCodes.map(_cardFromCode).toList(growable: false);
  final entries = <Act0ContributionV1>[
    const Act0ContributionV1(
      PokerStreet.preflop,
      'sb',
      Act0ContributionKindV1.blind,
      0.5,
    ),
    const Act0ContributionV1(
      PokerStreet.preflop,
      'bb',
      Act0ContributionKindV1.blind,
      1.0,
    ),
  ];
  final stacks = {for (final seat in _preflopSeats) seat: 100.0};
  final ledger = Act0HandContributionsV1(
    throughStreet: PokerStreet.preflop,
    startingStackBbBySeat: stacks,
    entries: entries,
  );
  final amounts = ledger.amounts(
    seatIds: _preflopSeats.toSet(),
    actorSeatId: heroSeat,
  );
  final price = amounts.toCallBb ?? 0;
  return Act0TableStateV1(
    scope: Act0TableScopeV1.playedHand,
    tableFormat: Act0TableFormatV1.sixMax,
    playerCount: 6,
    heroSeatId: heroSeat,
    activeSeatId: heroSeat,
    decisionSeatId: heroSeat,
    heroCards: heroCards,
    boardCards: const [],
    streetLabel: 'Preflop',
    potLabel: 'Pot ${_bbLabel(amounts.potBb)}',
    toCallLabel: price <= 0 ? '' : 'To call ${_bbLabel(price)}',
    centerLabel: '',
    actionTrail: [
      const Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
      const Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
      for (final seat in folded)
        Act0ActionTrailItemV1(label: '${seat.toUpperCase()} folds'),
    ],
    handContributions: ledger,
    autoPlayHistory: false,
    highlightedSeatIds: const [],
    highlightedCardIds: const [],
    seats: [
      for (final seat in _preflopSeats)
        Act0SeatStateV1(
          seatId: seat,
          seatLabel: seat.toUpperCase(),
          displayName: seat == heroSeat ? 'You' : seat.toUpperCase(),
          isHero: seat == heroSeat,
          isDealerButton: seat == 'btn',
          isSmallBlind: seat == 'sb',
          isBigBlind: seat == 'bb',
          isActive: seat == heroSeat,
          isInHand: !folded.contains(seat),
          isFolded: folded.contains(seat),
          hasActed: folded.contains(seat),
          stackLabel: _bbLabel(
            100.0 -
                (seat == 'sb'
                    ? 0.5
                    : seat == 'bb'
                    ? 1.0
                    : 0.0),
          ),
          holeCards: seat == heroSeat
              ? heroCards
              : const [
                  Act0CardStateV1(rank: '?', suit: ''),
                  Act0CardStateV1(rank: '?', suit: ''),
                ],
          cardsVisibleMode: seat == heroSeat
              ? Act0CardsVisibleModeV1.faceUp
              : folded.contains(seat)
              ? Act0CardsVisibleModeV1.none
              : Act0CardsVisibleModeV1.faceDown,
          bet: seat == 'sb'
              ? const Act0SeatBetStateV1(
                  kind: Act0SeatBetKindV1.post,
                  label: 'Post',
                  amountLabel: '0.5 BB',
                )
              : seat == 'bb'
              ? const Act0SeatBetStateV1(
                  kind: Act0SeatBetKindV1.post,
                  label: 'Post',
                  amountLabel: '1 BB',
                )
              : null,
          currentBetLabel: seat == 'sb'
              ? '0.5 BB'
              : seat == 'bb'
              ? '1 BB'
              : null,
        ),
    ],
  );
}

List<GeneratedPracticeTaskV1> generateOpenFoldByChartTasksV1({
  int count = 8,
  int seed = 1,
  List<String> seats = const ['utg', 'hj', 'co', 'btn'],
  int worldNumber = 3,
  String lessonId = 'position_open_fold_practice',
}) {
  final chart = CatalogStartingChart.foundation();
  final rng = Random(seed);
  final pool = _all169HandCodes()..shuffle(rng);
  final usedKeys = <String>{};
  var qqUsed = false;
  final tasks = <GeneratedPracticeTaskV1>[];

  for (var i = 0; i < count; i++) {
    final seat = seats[i % seats.length];
    final targetAction = i.isEven ? 'raise' : 'fold';
    String? chosenCode;
    List<String>? chosenCards;
    Act0TableStateV1? chosenTable;

    for (final code in pool) {
      if (code == 'QQ' && qqUsed) continue;
      final key = '$seat|$code';
      if (usedKeys.contains(key)) continue;
      final cards = _cardsForHandCode(code, rng);
      final table = _buildPreflopTable(heroSeat: seat, cardCodes: cards);
      final expected = chart.expected(table, groupOnly: false);
      if (expected == targetAction) {
        chosenCode = code;
        chosenCards = cards;
        chosenTable = table;
        usedKeys.add(key);
        if (code == 'QQ') qqUsed = true;
        break;
      }
    }
    if (chosenCode == null || chosenCards == null || chosenTable == null) {
      throw StateError(
        'Could not find unused ($seat, $targetAction) hand for open/fold batch.',
      );
    }

    final row = chart.opening[chosenCode];
    final seatUpper = seat.toUpperCase();
    final isOpen = targetAction == 'raise';
    final answerLabel = isOpen ? 'Raise' : 'Fold';
    final groupRule = row == null
        ? 'not listed in the opening rows (Weak)'
        : '${row.group} row (opens from ${row.seats.first} through BTN)';
    final handPretty = '${chosenCards[0]} and ${chosenCards[1]}';

    final options = <Act0RunnerOptionV1>[
      Act0RunnerOptionV1(
        id: 'raise',
        label: 'Raise',
        isCorrect: isOpen,
        preferredLabel: answerLabel,
        betterAnswerLabel: isOpen ? '' : 'Fold',
        quality: isOpen
            ? Act0FeedbackQualityV1.correct
            : Act0FeedbackQualityV1.wrong,
        feedbackTitle: isOpen ? 'Open raise.' : 'Fold preflop.',
        feedbackReason: isOpen
            ? '$chosenCode is in the $groupRule, so opening from $seatUpper is right.'
            : '$chosenCode is $groupRule, so raising from $seatUpper enters weak against players behind.',
      ),
      Act0RunnerOptionV1(
        id: 'call',
        label: 'Call',
        isCorrect: false,
        preferredLabel: answerLabel,
        betterAnswerLabel: answerLabel,
        quality: Act0FeedbackQualityV1.wrong,
        feedbackTitle: isOpen
            ? 'Raise rather than call.'
            : 'Fold rather than limp.',
        feedbackReason: isOpen
            ? '$chosenCode belongs in the $groupRule. Calling 1 BB first in leaves initiative away when a raise wins the blinds or builds a pot.'
            : 'Calling 1 BB first in with $chosenCode invests chips with a hand that is $groupRule instead of folding for free.',
      ),
      Act0RunnerOptionV1(
        id: 'fold',
        label: 'Fold',
        isCorrect: !isOpen,
        preferredLabel: answerLabel,
        betterAnswerLabel: !isOpen ? '' : 'Raise',
        quality: !isOpen
            ? Act0FeedbackQualityV1.correct
            : Act0FeedbackQualityV1.wrong,
        feedbackTitle: !isOpen ? 'Clean fold.' : 'Strong enough to open.',
        feedbackReason: !isOpen
            ? '$chosenCode is $groupRule, so saving the chips from $seatUpper is right.'
            : '$chosenCode sits in the $groupRule and deserves an open raise from $seatUpper.',
      ),
    ];

    final task = Act0LessonTaskV1(
      taskId: 'gen_open_fold_${seed}_${i + 1}',
      title: 'Open or fold · $seatUpper $chosenCode',
      phase: Act0LessonPhaseV1.drill,
      rewardXp: 15,
      stepKind: Act0LessonStepKindV1.practice,
      runner: Act0RunnerStateV1(
        lessonId: lessonId,
        lessonTitle: 'Open or fold from position',
        lessonSubtitle: 'Generated chart practice',
        beatIndex: i + 1,
        beatCount: count,
        phase: Act0LessonPhaseV1.drill,
        caption: 'Unopened pot preflop in $seatUpper with $handPretty.',
        hint:
            'Check the starting chart row for your two cards and compare it to your seat.',
        question:
            'Everyone folded to $seatUpper. You hold $handPretty. According to the starting chart, what is your play?',
        options: options,
        feedbackTitle: '',
        feedbackReason: '',
        primaryCtaLabel: 'Next',
        nextLessonId: null,
        returnTarget: '',
        table: chosenTable,
      ),
    );

    tasks.add(
      GeneratedPracticeTaskV1(
        templateId: 'open_fold_chart',
        worldNumber: worldNumber,
        lessonId: lessonId,
        task: task,
        metadata: {
          'seat': seatUpper,
          'hand_code': chosenCode,
          'cards': chosenCards,
          'expected': targetAction,
          'chart_group': row?.group ?? chart.weakGroup,
        },
      ),
    );
  }
  return tasks;
}

class _TurnDrawSpec {
  const _TurnDrawSpec({
    required this.kind,
    required this.outs,
    required this.approxOneInN,
    required this.heroCards,
    required this.boardCards,
  });

  final String kind; // 'flush', 'open_ended', 'gutshot'
  final int outs;
  final int approxOneInN;
  final List<String> heroCards;
  final List<String> boardCards;
}

_TurnDrawSpec _sampleCleanTurnDraw(
  Random rng,
  String targetKind,
  Set<String> usedHandSignatures,
  bool qqUsed,
) {
  final deck = _fullDeck();
  for (var attempt = 0; attempt < 5000; attempt++) {
    final copy = [...deck]..shuffle(rng);
    final hero = copy.sublist(0, 2);
    final board = copy.sublist(2, 6);
    final heroCode = startingHandCode(hero);
    if (heroCode == null || (heroCode == 'QQ' && qqUsed)) continue;
    final signature = '${hero.join(',')}|${board.join(',')}';
    if (usedHandSignatures.contains(signature)) continue;

    final dummySeat = const Act0SeatStateV1(
      seatId: 'btn',
      seatLabel: 'BTN',
      displayName: 'You',
      isHero: true,
    );
    final probeTable = Act0TableStateV1(
      tableFormat: Act0TableFormatV1.sixMax,
      playerCount: 6,
      heroSeatId: 'btn',
      heroCards: hero.map(_cardFromCode).toList(),
      boardCards: board.map(_cardFromCode).toList(),
      streetLabel: 'Turn',
      potLabel: 'Pot 10 BB',
      toCallLabel: 'To call 2 BB',
      centerLabel: '',
      highlightedSeatIds: const [],
      highlightedCardIds: const [],
      seats: [dummySeat],
    );
    final facts = CatalogPokerFacts(probeTable);
    if (!facts.complete || facts.rank != 'high card' || facts.pairedBoard) {
      continue;
    }

    final matches = switch (targetKind) {
      'flush' =>
        facts.flushSuits.length == 1 &&
            !facts.openEnded &&
            !facts.gutshot &&
            facts.completionCards.length == 9,
      'open_ended' =>
        facts.openEnded &&
            facts.flushSuits.isEmpty &&
            facts.completionCards.length == 8,
      'gutshot' =>
        facts.gutshot &&
            !facts.openEnded &&
            facts.flushSuits.isEmpty &&
            facts.completionCards.length == 4,
      _ => false,
    };
    if (!matches) continue;

    usedHandSignatures.add(signature);
    return _TurnDrawSpec(
      kind: targetKind,
      outs: facts.completionCards.length,
      approxOneInN: switch (facts.completionCards.length) {
        9 => 5,
        8 => 6,
        4 => 12,
        _ => (46 / facts.completionCards.length).round(),
      },
      heroCards: hero,
      boardCards: board,
    );
  }
  throw StateError('Failed to sample clean Turn $targetKind draw.');
}

({double potBeforeBetBb, double betBb}) _pickPriceSpot(
  int outs,
  bool shouldCall,
  Random rng,
) {
  final potCandidates = <double>[8, 10, 12, 14, 16, 18];
  final betCandidates = <double>[1, 1.5, 2, 3, 4, 5, 6, 8, 10, 12];
  final winProb = outs / 46.0;
  final matches = <({double potBeforeBetBb, double betBb})>[];
  for (final potBefore in potCandidates) {
    for (final bet in betCandidates) {
      final potOdds = bet / (potBefore + 2 * bet);
      if (shouldCall && winProb - potOdds >= 0.06) {
        matches.add((potBeforeBetBb: potBefore, betBb: bet));
      } else if (!shouldCall && potOdds - winProb >= 0.06) {
        matches.add((potBeforeBetBb: potBefore, betBb: bet));
      }
    }
  }
  if (matches.isEmpty) {
    throw StateError('No clean price geometry for outs=$outs call=$shouldCall');
  }
  return matches[rng.nextInt(matches.length)];
}

Act0TableStateV1 _buildTurnAllInTable({
  required String heroSeat,
  required _TurnDrawSpec spec,
  required double potBeforeBetBb,
  required double betBb,
}) {
  final opponent = heroSeat == 'bb' ? 'co' : 'bb';
  final heroFirstPreflop =
      _preflopSeats.indexOf(heroSeat) < _preflopSeats.indexOf(opponent);
  final preflopOpener = heroFirstPreflop ? heroSeat : opponent;
  final preflopCaller = heroFirstPreflop ? opponent : heroSeat;
  final openBb = preflopOpener == 'sb' ? 3.0 : 2.75;
  final preflopDead =
      (preflopOpener == 'sb' || preflopCaller == 'sb' ? 0.0 : 0.5) +
      (preflopOpener == 'bb' || preflopCaller == 'bb' ? 0.0 : 1.0);
  // Two-way preflop pot: dead blinds + openBb each from opener and caller.
  final preflopPot = preflopDead + openBb * 2;
  final flopBetBb = (potBeforeBetBb - preflopPot) / 2.0;
  assert(flopBetBb >= 0, 'Negative flop bet: $potBeforeBetBb vs $preflopPot');

  const postflopOrder = ['sb', 'bb', 'utg', 'hj', 'co', 'btn'];
  final firstPostflop =
      postflopOrder.indexOf(heroSeat) < postflopOrder.indexOf(opponent)
      ? heroSeat
      : opponent;
  final secondPostflop = firstPostflop == heroSeat ? opponent : heroSeat;

  final entries = <Act0ContributionV1>[
    const Act0ContributionV1(
      PokerStreet.preflop,
      'sb',
      Act0ContributionKindV1.blind,
      0.5,
    ),
    const Act0ContributionV1(
      PokerStreet.preflop,
      'bb',
      Act0ContributionKindV1.blind,
      1.0,
    ),
    Act0ContributionV1(
      PokerStreet.preflop,
      preflopOpener,
      Act0ContributionKindV1.wager,
      preflopOpener == 'sb' ? openBb - 0.5 : openBb,
    ),
    Act0ContributionV1(
      PokerStreet.preflop,
      preflopCaller,
      Act0ContributionKindV1.wager,
      preflopCaller == 'bb' ? openBb - 1.0 : openBb,
    ),
    if (flopBetBb > 0) ...[
      Act0ContributionV1(
        PokerStreet.flop,
        firstPostflop,
        Act0ContributionKindV1.wager,
        flopBetBb,
      ),
      Act0ContributionV1(
        PokerStreet.flop,
        secondPostflop,
        Act0ContributionKindV1.wager,
        flopBetBb,
      ),
    ],
    Act0ContributionV1(
      PokerStreet.turn,
      opponent,
      Act0ContributionKindV1.wager,
      betBb,
    ),
  ];

  final oppTotalInvested = entries
      .where((e) => e.seatId == opponent)
      .fold<double>(0, (sum, e) => sum + e.amountBb);
  final startingStacks = {
    for (final s in _preflopSeats) s: s == opponent ? oppTotalInvested : 100.0,
  };
  final ledger = Act0HandContributionsV1(
    throughStreet: PokerStreet.turn,
    startingStackBbBySeat: startingStacks,
    entries: entries,
  );
  final amounts = ledger.amounts(
    seatIds: _preflopSeats.toSet(),
    actorSeatId: heroSeat,
  );
  final price = amounts.toCallBb ?? 0;
  final heroCards = spec.heroCards.map(_cardFromCode).toList(growable: false);
  final boardCards = spec.boardCards.map(_cardFromCode).toList(growable: false);
  final folded = _preflopSeats
      .where((s) => s != heroSeat && s != opponent)
      .toSet();

  final history = <Act0ActionTrailItemV1>[
    const Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
    const Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
    for (final seat in _preflopSeats.takeWhile((s) => s != preflopCaller))
      if (seat == preflopOpener)
        Act0ActionTrailItemV1(
          label: '${seat.toUpperCase()} raises to ${_bbLabel(openBb)}',
        )
      else
        Act0ActionTrailItemV1(label: '${seat.toUpperCase()} folds'),
    Act0ActionTrailItemV1(
      label:
          '${preflopCaller.toUpperCase()} calls ${_bbLabel(preflopCaller == 'bb' ? openBb - 1.0 : openBb)} more',
    ),
    for (final seat
        in _preflopSeats.skipWhile((s) => s != preflopCaller).skip(1))
      if (seat != preflopOpener && seat != preflopCaller)
        Act0ActionTrailItemV1(label: '${seat.toUpperCase()} folds'),
    if (flopBetBb > 0) ...[
      Act0ActionTrailItemV1(
        label:
            'Flop: ${firstPostflop.toUpperCase()} bets ${_bbLabel(flopBetBb)}',
      ),
      Act0ActionTrailItemV1(
        label: '${secondPostflop.toUpperCase()} calls ${_bbLabel(flopBetBb)}',
      ),
    ] else ...[
      Act0ActionTrailItemV1(
        label: 'Flop: ${firstPostflop.toUpperCase()} checks',
      ),
      Act0ActionTrailItemV1(label: '${secondPostflop.toUpperCase()} checks'),
    ],
    if (firstPostflop == heroSeat) ...[
      Act0ActionTrailItemV1(label: 'Turn: ${heroSeat.toUpperCase()} checks'),
      Act0ActionTrailItemV1(
        label: '${opponent.toUpperCase()} all-in ${_bbLabel(betBb)}',
      ),
    ] else
      Act0ActionTrailItemV1(
        label: 'Turn: ${opponent.toUpperCase()} all-in ${_bbLabel(betBb)}',
      ),
  ];

  final oppBet = Act0SeatBetStateV1(
    kind: Act0SeatBetKindV1.allIn,
    label: 'All-in',
    amountLabel: _bbLabel(betBb),
  );

  return Act0TableStateV1(
    scope: Act0TableScopeV1.playedHand,
    showDecisionPremise: true,
    tableFormat: Act0TableFormatV1.sixMax,
    playerCount: 6,
    heroSeatId: heroSeat,
    activeSeatId: heroSeat,
    decisionSeatId: heroSeat,
    heroCards: heroCards,
    boardCards: boardCards,
    streetLabel: 'Turn',
    potLabel: 'Pot ${_bbLabel(amounts.potBb)}',
    toCallLabel: price <= 0 ? '' : 'To call ${_bbLabel(price)}',
    centerLabel: '',
    actionTrail: history,
    handContributions: ledger,
    autoPlayHistory: false,
    highlightedSeatIds: const [],
    highlightedCardIds: const [],
    seats: [
      for (final seat in _preflopSeats)
        Act0SeatStateV1(
          seatId: seat,
          seatLabel: seat.toUpperCase(),
          displayName: seat == heroSeat ? 'You' : seat.toUpperCase(),
          isHero: seat == heroSeat,
          isDealerButton: seat == 'btn',
          isSmallBlind: seat == 'sb',
          isBigBlind: seat == 'bb',
          isActive: seat == heroSeat,
          isInHand: !folded.contains(seat),
          isFolded: folded.contains(seat),
          hasActed: folded.contains(seat) || seat == opponent,
          isLastAggressor: seat == opponent,
          stackLabel: _bbLabel(
            startingStacks[seat]! -
                entries
                    .where((e) => e.seatId == seat)
                    .fold<double>(0, (total, e) => total + e.amountBb),
          ),
          holeCards: seat == heroSeat
              ? heroCards
              : const [
                  Act0CardStateV1(rank: '?', suit: ''),
                  Act0CardStateV1(rank: '?', suit: ''),
                ],
          cardsVisibleMode: seat == heroSeat
              ? Act0CardsVisibleModeV1.faceUp
              : folded.contains(seat)
              ? Act0CardsVisibleModeV1.none
              : Act0CardsVisibleModeV1.faceDown,
          bet: seat == opponent ? oppBet : null,
          currentBetLabel: seat == opponent ? _bbLabel(betBb) : null,
        ),
    ],
  );
}

List<GeneratedPracticeTaskV1> generateTurnCallPriceWithOutsTasksV1({
  int count = 8,
  int seed = 1,
  TurnOutsModeV1 mode = TurnOutsModeV1.callOrFoldAllIn,
  List<String> heroSeats = const ['utg', 'hj', 'co', 'btn', 'sb', 'bb'],
  int worldNumber = 7,
  String lessonId = 'turn_price_outs_practice',
}) {
  final rng = Random(seed);
  const drawKinds = ['flush', 'open_ended', 'gutshot'];
  final usedSignatures = <String>{};
  var qqUsed = false;
  final tasks = <GeneratedPracticeTaskV1>[];

  for (var i = 0; i < count; i++) {
    final heroSeat = heroSeats[i % heroSeats.length];
    final opponent = heroSeat == 'bb' ? 'co' : 'bb';
    final kind = drawKinds[i % drawKinds.length];
    final shouldCall = kind == 'gutshot' ? false : i.isEven;
    final spec = _sampleCleanTurnDraw(rng, kind, usedSignatures, qqUsed);
    if (startingHandCode(spec.heroCards) == 'QQ') qqUsed = true;

    final pricing = _pickPriceSpot(spec.outs, shouldCall, rng);
    final table = _buildTurnAllInTable(
      heroSeat: heroSeat,
      spec: spec,
      potBeforeBetBb: pricing.potBeforeBetBb,
      betBb: pricing.betBb,
    );
    final potAfter = pricing.potBeforeBetBb + pricing.betBb;
    final totalFinalPot = potAfter + pricing.betBb;
    final winPct = (spec.outs / 46.0 * 100).round();
    final reqPct = (pricing.betBb / totalFinalPot * 100).round();
    final drawLabel = switch (kind) {
      'flush' => 'flush',
      _ => 'straight',
    };
    final outsSentence =
        'You have ${spec.outs} $drawLabel outs (~$winPct% with one card left).';
    final priceSentence =
        'Calling ${_bbLabel(pricing.betBb)} to win ${_bbLabel(totalFinalPot)} needs ~$reqPct%.';

    final heroText = spec.heroCards.join(' ');
    final boardText = spec.boardCards.join(' ');
    final oppUpper = opponent.toUpperCase();
    final heroUpper = heroSeat.toUpperCase();

    final List<Act0RunnerOptionV1> options;
    final String question;
    if (mode == TurnOutsModeV1.callOrFoldAllIn) {
      question =
          'Turn on $boardText: you hold $heroText. $outsSentence $oppUpper moves all-in for ${_bbLabel(pricing.betBb)}. Call or fold?';
      final best = shouldCall ? 'Call' : 'Fold';
      options = [
        Act0RunnerOptionV1(
          id: 'call',
          label: 'Call',
          isCorrect: shouldCall,
          preferredLabel: best,
          betterAnswerLabel: shouldCall ? '' : 'Fold',
          quality: shouldCall
              ? Act0FeedbackQualityV1.correct
              : Act0FeedbackQualityV1.wrong,
          feedbackTitle: shouldCall ? 'Profitable call.' : 'Too pricey.',
          feedbackReason:
              '$outsSentence $priceSentence ${shouldCall ? 'Calling beats the price.' : 'Folding saves chips at a bad price.'}',
        ),
        Act0RunnerOptionV1(
          id: 'fold',
          label: 'Fold',
          isCorrect: !shouldCall,
          preferredLabel: best,
          betterAnswerLabel: !shouldCall ? '' : 'Call',
          quality: !shouldCall
              ? Act0FeedbackQualityV1.correct
              : Act0FeedbackQualityV1.wrong,
          feedbackTitle: !shouldCall ? 'Disciplined fold.' : 'Too tight.',
          feedbackReason:
              '$outsSentence $priceSentence ${!shouldCall ? 'Folding saves chips when the price is too high.' : 'You get a profitable price to draw.'}',
        ),
      ];
    } else {
      question =
          'With $heroText on turn $boardText facing all-in ${_bbLabel(pricing.betBb)} into ${_bbLabel(potAfter)}, how many $drawLabel outs and single-card odds do you have?';
      final answer = '${spec.outs} outs (~1 in ${spec.approxOneInN})';
      final distractors = switch (spec.outs) {
        9 => ['8 outs (~1 in 6)', '4 outs (~1 in 12)'],
        8 => ['9 outs (~1 in 5)', '4 outs (~1 in 12)'],
        _ => ['8 outs (~1 in 6)', '6 outs (~1 in 8)'],
      };
      final choices = [answer, ...distractors];
      final rotate = i % 3;
      final ordered = [
        choices[(0 + rotate) % 3],
        choices[(1 + rotate) % 3],
        choices[(2 + rotate) % 3],
      ];
      options = [
        for (final (idx, label) in ordered.indexed)
          Act0RunnerOptionV1(
            id: label == answer ? 'outs_${spec.outs}' : 'wrong_$idx',
            label: label,
            isCorrect: label == answer,
            preferredLabel: answer,
            betterAnswerLabel: label == answer ? '' : answer,
            quality: label == answer
                ? Act0FeedbackQualityV1.correct
                : Act0FeedbackQualityV1.wrong,
            feedbackTitle: label == answer
                ? 'Accurate out count.'
                : 'Recount the $drawLabel cards.',
            feedbackReason:
                '$outsSentence With 46 unseen cards remaining on the turn, ${spec.outs} outs hit roughly 1 in ${spec.approxOneInN}.',
          ),
      ];
    }

    final task = Act0LessonTaskV1(
      taskId: 'gen_turn_${mode.name}_${seed}_${i + 1}',
      title: 'Turn price · $heroText vs $oppUpper all-in',
      phase: Act0LessonPhaseV1.drill,
      rewardXp: 15,
      stepKind: Act0LessonStepKindV1.practice,
      runner: Act0RunnerStateV1(
        lessonId: lessonId,
        lessonTitle: 'Turn draw price and outs',
        lessonSubtitle: 'Generated turn practice',
        beatIndex: i + 1,
        beatCount: count,
        phase: Act0LessonPhaseV1.drill,
        caption:
            '$oppUpper started the hand short-stacked and moves all-in for ${_bbLabel(pricing.betBb)} into ${_bbLabel(potAfter)}; you act from $heroUpper.',
        hint:
            'Count only unseen cards that complete your draw out of 46 remaining cards.',
        question: question,
        options: options,
        feedbackTitle: '',
        feedbackReason: '',
        primaryCtaLabel: 'Next',
        nextLessonId: null,
        returnTarget: '',
        table: table,
      ),
    );

    tasks.add(
      GeneratedPracticeTaskV1(
        templateId: mode == TurnOutsModeV1.callOrFoldAllIn
            ? 'call_price_outs_decision'
            : 'call_price_outs_numeric',
        worldNumber: worldNumber,
        lessonId: lessonId,
        task: task,
        metadata: {
          'hero_seat': heroUpper,
          'opponent': oppUpper,
          'draw_kind': kind,
          'outs': spec.outs,
          'win_pct': winPct,
          'req_pct': reqPct,
          'pot_after_bb': potAfter,
          'to_call_bb': pricing.betBb,
          'hero': heroText,
          'board': boardText,
          'expected': mode == TurnOutsModeV1.callOrFoldAllIn
              ? (shouldCall ? 'call' : 'fold')
              : '${spec.outs} outs',
        },
      ),
    );
  }
  return tasks;
}

String renderGeneratedSummaryMarkdownV1(List<GeneratedPracticeTaskV1> tasks) {
  final buffer = StringBuffer()
    ..writeln('# Generated Act0 Practice Batch (${tasks.length} tasks)')
    ..writeln();
  for (final item in tasks) {
    final t = item.task;
    final r = t.runner;
    final correct = r.options.where((o) => o.isCorrect).first;
    buffer
      ..writeln('## ${t.taskId} (`${item.templateId}`, W${item.worldNumber})')
      ..writeln(
        '- **Table:** ${r.table.streetLabel} | ${r.table.potLabel} | ${r.table.toCallLabel} | Hero: ${r.table.heroCards.map((c) => c.label).join(" ")}${r.table.boardCards.isEmpty ? "" : " | Board: ${r.table.boardCards.map((c) => c.label).join(" ")}"}',
      )
      ..writeln('- **Caption:** ${r.caption}')
      ..writeln('- **Question:** ${r.question}')
      ..writeln('- **Answer:** ${correct.label} (${item.metadata})')
      ..writeln(
        '- **Options:** ${r.options.map((o) => o.isCorrect ? "**${o.label}**" : o.label).join(" / ")}',
      )
      ..writeln('- **Feedback:** ${correct.feedbackReason}')
      ..writeln();
  }
  return buffer.toString();
}

String renderGeneratedDay7DartV1(List<GeneratedPracticeTaskV1> tasks) {
  final buffer = StringBuffer()
    ..writeln(
      '// Auto-generated candidate entries for Act0 review/catalog inspection.',
    )
    ..writeln('final generatedPracticeCandidatesV1 = <Act0LessonTaskV1>[');
  for (final item in tasks) {
    final t = item.task;
    final r = t.runner;
    final heroStr = r.table.heroCards.map((c) => c.label).join(' ');
    final boardStr = r.table.boardCards.map((c) => c.label).join(' ');
    buffer
      ..writeln('  // ${t.taskId}: ${item.templateId} ${item.metadata}')
      ..writeln('  Act0LessonTaskV1(')
      ..writeln("    taskId: '${t.taskId}',")
      ..writeln("    title: '${t.title.replaceAll("'", r"\'")}',")
      ..writeln('    phase: Act0LessonPhaseV1.${t.phase.name},')
      ..writeln('    rewardXp: ${t.rewardXp},')
      ..writeln('    stepKind: Act0LessonStepKindV1.${t.stepKind.name},')
      ..writeln('    runner: Act0RunnerStateV1(')
      ..writeln("      lessonId: '${r.lessonId}',")
      ..writeln("      lessonTitle: '${r.lessonTitle.replaceAll("'", r"\'")}',")
      ..writeln(
        "      lessonSubtitle: '${r.lessonSubtitle.replaceAll("'", r"\'")}',",
      )
      ..writeln('      beatIndex: ${r.beatIndex},')
      ..writeln('      beatCount: ${r.beatCount},')
      ..writeln('      phase: Act0LessonPhaseV1.${r.phase.name},')
      ..writeln("      caption: '${r.caption.replaceAll("'", r"\'")}',")
      ..writeln("      hint: '${r.hint.replaceAll("'", r"\'")}',")
      ..writeln("      question: '${r.question.replaceAll("'", r"\'")}',")
      ..writeln(
        "      // hero: '$heroStr'${boardStr.isEmpty ? '' : ", board: '$boardStr'"}, pot: '${r.table.potLabel}', toCall: '${r.table.toCallLabel}'",
      )
      ..writeln('      options: const [');
    for (final o in r.options) {
      buffer
        ..writeln('        Act0RunnerOptionV1(')
        ..writeln("          id: '${o.id}',")
        ..writeln("          label: '${o.label.replaceAll("'", r"\'")}',")
        ..writeln('          isCorrect: ${o.isCorrect},')
        ..writeln(
          "          preferredLabel: '${o.preferredLabel.replaceAll("'", r"\'")}',",
        )
        ..writeln(
          "          betterAnswerLabel: '${o.betterAnswerLabel.replaceAll("'", r"\'")}',",
        )
        ..writeln('          quality: Act0FeedbackQualityV1.${o.quality.name},')
        ..writeln(
          "          feedbackTitle: '${o.feedbackTitle.replaceAll("'", r"\'")}',",
        )
        ..writeln(
          "          feedbackReason: '${o.feedbackReason.replaceAll("'", r"\'")}',",
        )
        ..writeln('        ),');
    }
    buffer
      ..writeln('      ],')
      ..writeln("      feedbackTitle: '',")
      ..writeln("      feedbackReason: '',")
      ..writeln("      primaryCtaLabel: '${r.primaryCtaLabel}',")
      ..writeln('      nextLessonId: null,')
      ..writeln("      returnTarget: '',")
      ..writeln('      // Insert table with Act0HandContributionsV1 here.')
      ..writeln('      table: /* see generated table metadata */,')
      ..writeln('    ),')
      ..writeln('  ),');
  }
  buffer.writeln('];');
  return buffer.toString();
}

part of 'act0_shell_state_v1.dart';

typedef _SpacedReviewEntryV1 = ({
  String worldId,
  String lessonId,
  String conceptFamilyId,
  Act0LessonTaskV1 task,
});

_SpacedReviewEntryV1 _day7ExampleV1(
  int world,
  String lesson,
  String family,
  Act0TableStateV1 table, {
  required String question,
  required List<String> choices,
  required int correct,
  required String reason,
  Map<int, String> wrongReasons = const {},
  String caption = '',
  String? savedTaskId,
}) {
  final answer = choices[correct];
  return (
    worldId: 'world_$world',
    lessonId: lesson,
    conceptFamilyId: family,
    task: Act0LessonTaskV1(
      taskId: savedTaskId ?? 'spaced_review_w${world}_${lesson}_${family}_v1',
      title: 'Review decision',
      phase: Act0LessonPhaseV1.drill,
      rewardXp: 0,
      runner: Act0RunnerStateV1(
        lessonId: lesson,
        lessonTitle: 'Spaced review',
        lessonSubtitle: '',
        beatIndex: 1,
        beatCount: 1,
        phase: Act0LessonPhaseV1.drill,
        caption: caption,
        hint: '',
        hintPolicy: Act0HintPolicyV1.hidden,
        question: question,
        options: [
          for (final (index, label) in choices.indexed)
            Act0RunnerOptionV1(
              id: switch (label.toLowerCase()) {
                final name
                    when const {
                      'fold',
                      'check',
                      'call',
                      'raise',
                      'premium',
                      'strong',
                      'medium',
                    }.contains(name) =>
                  name,
                'weak' => 'trash',
                _ => 'choice_$index',
              },
              label: label,
              isCorrect: index == correct,
              preferredLabel: answer,
              betterAnswerLabel: index == correct ? '' : answer,
              quality: index == correct
                  ? Act0FeedbackQualityV1.correct
                  : Act0FeedbackQualityV1.wrong,
              feedbackTitle: index == correct ? 'Correct.' : 'Look again.',
              feedbackReason: index == correct
                  ? reason
                  : wrongReasons[index] ?? reason,
            ),
        ],
        feedbackTitle: '',
        feedbackReason: '',
        primaryCtaLabel: '',
        nextLessonId: null,
        returnTarget: '',
        table: caption.isEmpty
            ? table
            : table.copyWith(showDecisionPremise: true),
      ),
    ),
  );
}

const _day7SeatsV1 = ['utg', 'hj', 'co', 'btn', 'sb', 'bb'];

Act0TableStateV1 _day7PreflopV1(
  String hero,
  String hand, {
  String? opener,
  double openBb = 2.5,
  double heroStartingBb = 100,
  bool allIn = false,
  bool showTurn = false,
}) {
  final heroIndex = _day7SeatsV1.indexOf(hero);
  final folded = _day7SeatsV1.take(heroIndex).where((s) => s != opener).toSet();
  final opening = opener == null ? 0.0 : openBb;
  const street = PokerStreet.preflop;
  return _day7TableV1(
    hero: hero,
    hand: hand,
    street: street,
    actor: showTurn ? hero : null,
    folded: folded,
    stacks: {hero: heroStartingBb, if (allIn) opener!: openBb},
    entries: [
      ..._act0LessonBlinds,
      if (opener != null)
        Act0ContributionV1(
          street,
          opener,
          Act0ContributionKindV1.wager,
          opening,
        ),
    ],
    history: [
      const Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
      const Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
      for (final seat in _day7SeatsV1.take(heroIndex))
        if (seat == opener)
          Act0ActionTrailItemV1(
            label:
                '${seat.toUpperCase()} ${allIn ? 'all-in' : 'raises to'} ${_act0BbLabelV1(opening)}',
          )
        else
          Act0ActionTrailItemV1(label: '${seat.toUpperCase()} folds'),
    ],
    bets: {
      'sb': _smallBlindPost,
      'bb': _bigBlindPost,
      if (opener != null)
        opener: Act0SeatBetStateV1(
          kind: allIn ? Act0SeatBetKindV1.allIn : Act0SeatBetKindV1.raise,
          label: allIn ? 'All-in' : 'Raise',
          amountLabel: _act0BbLabelV1(opening),
        ),
    },
  );
}

Act0TableStateV1 _day7PostflopV1(
  String hero,
  String hand,
  String board, {
  String? opponent,
  String shownHand = '',
  double openBb = 2.75,
  double betBb = 0,
  double heroLeadBb = 0,
  bool checkedToHero = false,
  bool showTurn = false,
}) {
  final other = opponent ?? (hero == 'bb' ? 'hj' : 'bb');
  final caller = hero == 'bb' ? hero : other;
  final opener = hero == 'bb' ? other : hero;
  final folded = _day7SeatsV1.where((s) => s != hero && s != other).toSet();
  final boardCards = _act0LessonCardsV1(board);
  final street = switch (boardCards.length) {
    3 => PokerStreet.flop,
    4 => PokerStreet.turn,
    5 => PokerStreet.river,
    _ => throw ArgumentError.value(board, 'board'),
  };
  final first = caller.toUpperCase();
  final last = opener.toUpperCase();
  final streetLabel = pokerStreetToString(street);
  final current = [
    if ((checkedToHero && hero != 'bb') ||
        heroLeadBb > 0 ||
        (betBb > 0 && hero == 'bb'))
      Act0ActionTrailItemV1(label: '$streetLabel: $first checks'),
    if (heroLeadBb > 0)
      Act0ActionTrailItemV1(label: '$last bets ${_act0BbLabelV1(heroLeadBb)}'),
    if (betBb > 0)
      Act0ActionTrailItemV1(
        label:
            '${heroLeadBb == 0 && hero != 'bb' ? '$streetLabel: ' : ''}'
            '${other.toUpperCase()} ${heroLeadBb > 0 ? 'raises to' : 'bets'} '
            '${_act0BbLabelV1(betBb)}',
      ),
    if (shownHand.isNotEmpty) ...[
      Act0ActionTrailItemV1(label: '$streetLabel: $first checks'),
      Act0ActionTrailItemV1(label: '$last checks'),
    ],
  ];
  return _day7TableV1(
    hero: hero,
    hand: hand,
    street: street,
    actor: showTurn ? hero : null,
    board: boardCards,
    shown: shownHand.isEmpty
        ? const {}
        : {other: _act0LessonCardsV1(shownHand)},
    folded: folded,
    entries: [
      ..._act0LessonBlinds,
      Act0ContributionV1(
        PokerStreet.preflop,
        opener,
        Act0ContributionKindV1.wager,
        openBb,
      ),
      Act0ContributionV1(
        PokerStreet.preflop,
        caller,
        Act0ContributionKindV1.wager,
        openBb - 1,
      ),
      if (heroLeadBb > 0)
        Act0ContributionV1(
          street,
          hero,
          Act0ContributionKindV1.wager,
          heroLeadBb,
        ),
      if (betBb > 0)
        Act0ContributionV1(street, other, Act0ContributionKindV1.wager, betBb),
    ],
    history: [
      const Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
      const Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
      for (final seat in _day7SeatsV1.takeWhile((s) => s != caller))
        if (seat == opener)
          Act0ActionTrailItemV1(
            label: '$last raises to ${_act0BbLabelV1(openBb)}',
          )
        else
          Act0ActionTrailItemV1(label: '${seat.toUpperCase()} folds'),
      Act0ActionTrailItemV1(
        label: '$first calls ${_act0BbLabelV1(openBb - 1)} more',
      ),
      for (final prior in [PokerStreet.flop, PokerStreet.turn])
        if (prior.index < street.index) ...[
          Act0ActionTrailItemV1(
            label: '${pokerStreetToString(prior)}: $first checks',
          ),
          Act0ActionTrailItemV1(label: '$last checks'),
        ],
      ...current,
    ],
    bets: {
      if (heroLeadBb > 0)
        hero: Act0SeatBetStateV1(
          kind: Act0SeatBetKindV1.bet,
          label: 'Bet',
          amountLabel: _act0BbLabelV1(heroLeadBb),
        ),
      if (betBb > 0)
        other: Act0SeatBetStateV1(
          kind: heroLeadBb > 0
              ? Act0SeatBetKindV1.raise
              : Act0SeatBetKindV1.bet,
          label: heroLeadBb > 0 ? 'Raise' : 'Bet',
          amountLabel: _act0BbLabelV1(betBb),
        ),
    },
  );
}

Act0TableStateV1 _day7TableV1({
  required String hero,
  required String hand,
  required PokerStreet street,
  required Set<String> folded,
  required List<Act0ContributionV1> entries,
  required List<Act0ActionTrailItemV1> history,
  required Map<String, Act0SeatBetStateV1> bets,
  String? actor,
  List<Act0CardStateV1> board = const [],
  Map<String, List<Act0CardStateV1>> shown = const {},
  Map<String, double> stacks = const {},
}) {
  final heroCards = _act0LessonCardsV1(hand);
  final startingStacks = {
    for (final seat in _day7SeatsV1) seat: stacks[seat] ?? 100.0,
  };
  final ledger = Act0HandContributionsV1(
    throughStreet: street,
    startingStackBbBySeat: startingStacks,
    entries: entries,
  );
  final amounts = ledger.amounts(
    seatIds: _day7SeatsV1.toSet(),
    actorSeatId: actor,
  );
  final price = amounts.toCallBb ?? 0;
  return Act0TableStateV1(
    scope: Act0TableScopeV1.playedHand,
    tableFormat: Act0TableFormatV1.sixMax,
    playerCount: 6,
    heroSeatId: hero,
    activeSeatId: actor,
    decisionSeatId: actor,
    heroCards: heroCards,
    boardCards: board,
    streetLabel: pokerStreetToString(street),
    potLabel: 'Pot ${_act0BbLabelV1(amounts.potBb)}',
    toCallLabel: price <= 0 ? '' : 'To call ${_act0BbLabelV1(price)}',
    centerLabel: '',
    actionTrail: history,
    handContributions: ledger,
    autoPlayHistory: false,
    highlightedSeatIds: const [],
    highlightedCardIds: const [],
    seats: [
      for (final seat in _day7SeatsV1)
        Act0SeatStateV1(
          seatId: seat,
          seatLabel: seat.toUpperCase(),
          displayName: seat == hero ? 'Hero' : seat.toUpperCase(),
          isHero: seat == hero,
          isDealerButton: seat == 'btn',
          isSmallBlind: seat == 'sb',
          isBigBlind: seat == 'bb',
          isActive: seat == actor,
          isInHand: !folded.contains(seat),
          isFolded: folded.contains(seat),
          hasActed:
              folded.contains(seat) ||
              (bets.containsKey(seat) &&
                  bets[seat]!.kind != Act0SeatBetKindV1.post),
          isLastAggressor:
              [
                for (final entry in entries)
                  if (entry.street == street &&
                      entry.kind == Act0ContributionKindV1.wager)
                    entry.seatId,
              ].lastOrNull ==
              seat,
          stackLabel: _act0BbLabelV1(
            startingStacks[seat]! -
                entries
                    .where((e) => e.seatId == seat)
                    .fold<double>(0, (total, e) => total + e.amountBb),
          ),
          holeCards: seat == hero
              ? heroCards
              : shown[seat] ?? _unknownHoleCards,
          cardsVisibleMode: seat == hero || shown.containsKey(seat)
              ? Act0CardsVisibleModeV1.faceUp
              : folded.contains(seat)
              ? Act0CardsVisibleModeV1.none
              : Act0CardsVisibleModeV1.faceDown,
          bet: bets[seat],
          currentBetLabel: bets[seat]?.amountLabel,
        ),
    ],
  );
}

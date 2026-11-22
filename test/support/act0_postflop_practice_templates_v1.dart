part of 'act0_practice_generator_v1.dart';

enum PostflopPracticeSkillV1 {
  outsVsPrice(5),
  continuationTexture(6),
  rangeBuckets(6),
  stackToPot(8),
  callingStation(10),
  multiwayPrice(11),
  riverBluffCatch(12);

  const PostflopPracticeSkillV1(this.world);
  final int world;
}

typedef _PracticeDeal = ({
  String hero,
  String board,
  List<String> opponents,
  Set<int> folds,
});

typedef _Showdown = ({double share, int wins, int outcomes});

_PracticeDeal _model(PostflopPracticeSkillV1 skill, bool first, Random rng) {
  String pick(String ranks) => ranks[rng.nextInt(ranks.length)];
  final middle = pick('56789');
  final blank = pick('23568');
  return switch (skill) {
    PostflopPracticeSkillV1.outsVsPrice => (
      hero: 'Ah 7h',
      board: 'Kh 9h ${pick('24568')}c ${pick('23568TJ')}d',
      opponents: const ['Kd Qs'],
      folds: const {},
    ),
    PostflopPracticeSkillV1.continuationTexture when first => (
      hero: 'Ks Qh',
      board: 'Kc ${pick('789')}d ${pick('234')}s',
      opponents: const ['Kd Jc', 'Kh Tc', '8h 5s'],
      folds: const {},
    ),
    PostflopPracticeSkillV1.continuationTexture => (
      hero: 'Ad ${pick('23456')}d',
      board: 'Jc Tc ${pick('89')}h',
      opponents: const ['Qh 9s', 'Jh 8h', 'Td 7d'],
      folds: const {},
    ),
    PostflopPracticeSkillV1.rangeBuckets when !first => (
      hero: 'Ts 8d',
      board: 'Qh ${pick('567')}c 3s ${pick('245')}d',
      opponents: const ['Ac 9d', 'Kh Jd', 'Qd 9s'],
      folds: const {0, 1},
    ),
    PostflopPracticeSkillV1.rangeBuckets ||
    PostflopPracticeSkillV1.stackToPot => (
      hero: 'Qs Jd',
      board: 'Qh ${middle}c 4s ${pick('23')}h',
      opponents: ['Qc Td', '${middle}s Td'],
      folds: const {},
    ),
    PostflopPracticeSkillV1.callingStation => (
      hero: first ? 'Ks Qh' : 'Qh Jd',
      board: 'Kc ${middle}d 2s ${pick('34')}c ${pick('789')}h',
      opponents: ['Kd Tc', '${middle}s Jc'],
      folds: const {},
    ),
    PostflopPracticeSkillV1.multiwayPrice => (
      hero: 'Ah Jh',
      board: '2h ${pick('5678T')}h 9s ${pick('34568')}c',
      opponents: const ['9d 9c', 'Kc Qd'],
      folds: const {},
    ),
    PostflopPracticeSkillV1.riverBluffCatch => (
      hero: 'Qh Jd',
      board: 'Qs ${middle}c 4s 2d ${blank}h',
      opponents: const ['Ah Qd', 'Ks Qc', 'Ad Qc', 'Jh Tc'],
      folds: const {},
    ),
  };
}

bool _jointOpponents(PostflopPracticeSkillV1 skill) =>
    skill == PostflopPracticeSkillV1.multiwayPrice;

Iterable<List<String>> _runouts(List<String> deck, int needed) sync* {
  if (needed == 0) {
    yield const [];
  } else if (needed == 1) {
    for (final card in deck) {
      yield [card];
    }
  } else {
    for (var i = 0; i < deck.length; i++) {
      for (var j = i + 1; j < deck.length; j++) {
        yield [deck[i], deck[j]];
      }
    }
  }
}

_Showdown _showdowns(_PracticeDeal model, List<String> opponents) {
  final hero = model.hero.split(' ');
  final board = model.board.split(' ');
  final villains = opponents.map((hand) => hand.split(' ')).toList();
  final seen = {...hero, ...board, ...villains.expand((hand) => hand)};
  final remaining = _fullDeck().where((card) => !seen.contains(card)).toList();
  var wins = 0;
  var outcomes = 0;
  var potShares = 0.0;
  for (final runout in _runouts(remaining, 5 - board.length)) {
    final complete = [...board, ...runout];
    final heroHand = Hand.solveHand([...hero, ...complete]);
    final comparisons = [
      for (final villain in villains)
        heroHand.compare(Hand.solveHand([...villain, ...complete])),
    ];
    outcomes++;
    if (comparisons.any((result) => result > 0)) continue;
    final tied = comparisons.where((result) => result == 0).length;
    if (tied == 0) wins++;
    potShares += 1 / (1 + tied);
  }
  return (share: potShares / outcomes, wins: wins, outcomes: outcomes);
}

List<_Showdown> _practiceEquities(
  _PracticeDeal deal,
  PostflopPracticeSkillV1 skill,
) => [
  if (_jointOpponents(skill))
    _showdowns(deal, deal.opponents)
  else
    for (final hand in deal.opponents) _showdowns(deal, [hand]),
];

_PracticeDeal _permuteSuits(_PracticeDeal model, Random rng) {
  final permutation = [..._suits]..shuffle(rng);
  String permute(String hand) => hand
      .split(' ')
      .map((card) => card[0] + permutation[_suits.indexOf(card[1])])
      .join(' ');
  return (
    hero: permute(model.hero),
    board: permute(model.board),
    opponents: model.opponents.map(permute).toList(),
    folds: model.folds,
  );
}

List<Act0ContributionV1> _practicePosts(double open, bool multiway) => [
  const Act0ContributionV1(
    PokerStreet.preflop,
    'sb',
    Act0ContributionKindV1.blind,
    .5,
  ),
  const Act0ContributionV1(
    PokerStreet.preflop,
    'bb',
    Act0ContributionKindV1.blind,
    1,
  ),
  if (multiway)
    Act0ContributionV1(
      PokerStreet.preflop,
      'hj',
      Act0ContributionKindV1.wager,
      open,
    ),
  Act0ContributionV1(
    PokerStreet.preflop,
    'co',
    Act0ContributionKindV1.wager,
    open,
  ),
  Act0ContributionV1(
    PokerStreet.preflop,
    'bb',
    Act0ContributionKindV1.wager,
    open - 1,
  ),
];

Act0HandContributionsV1 _practiceLedger(
  List<Act0ContributionV1> posts,
  PokerStreet street,
  double open,
  double wager, {
  required bool multiway,
  required bool allIn,
  required double opponentBehind,
}) => Act0HandContributionsV1(
  throughStreet: street,
  startingStackBbBySeat: {
    for (final seat in _preflopSeats)
      seat: seat == 'bb' ? open + (allIn ? wager : opponentBehind) : 100,
  },
  entries: [
    ...posts,
    if (wager > 0)
      Act0ContributionV1(street, 'bb', Act0ContributionKindV1.wager, wager),
    if (multiway && wager > 0)
      Act0ContributionV1(street, 'hj', Act0ContributionKindV1.wager, wager),
  ],
);

Act0TableStateV1 _postflopTable(
  _PracticeDeal deal,
  Act0HandContributionsV1 ledger,
  double open,
  double wager, {
  required bool multiway,
  required bool allIn,
}) {
  final street = ledger.throughStreet;
  final streetLabel = street.name[0].toUpperCase() + street.name.substring(1);
  final live = ['bb', if (multiway) 'hj', 'co'];
  final amounts = ledger.amounts(
    seatIds: _preflopSeats.toSet(),
    actorSeatId: 'co',
  );
  final hero = deal.hero.split(' ').map(_cardFromCode).toList();
  final wagerLabel = _bbLabel(wager);
  String stack(String seat) => _bbLabel(
    ledger.startingStackBbBySeat[seat]! -
        ledger.entries
            .where((entry) => entry.seatId == seat)
            .fold<double>(0, (sum, entry) => sum + entry.amountBb),
  );
  return Act0TableStateV1(
    scope: Act0TableScopeV1.playedHand,
    tableFormat: Act0TableFormatV1.sixMax,
    playerCount: 6,
    heroSeatId: 'co',
    activeSeatId: 'co',
    decisionSeatId: 'co',
    heroCards: hero,
    boardCards: deal.board.split(' ').map(_cardFromCode).toList(),
    streetLabel: streetLabel,
    potLabel: 'Pot ${_bbLabel(amounts.potBb)}',
    toCallLabel: wager == 0 ? '' : 'To call ${_bbLabel(amounts.toCallBb!)}',
    centerLabel: '',
    highlightedSeatIds: const [],
    highlightedCardIds: const [],
    actionTrail: [
      const Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
      const Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
      const Act0ActionTrailItemV1(label: 'UTG folds'),
      Act0ActionTrailItemV1(
        label: multiway ? 'HJ raises to ${_bbLabel(open)}' : 'HJ folds',
      ),
      Act0ActionTrailItemV1(
        label: multiway
            ? 'CO calls ${_bbLabel(open)}'
            : 'CO raises to ${_bbLabel(open)}',
      ),
      const Act0ActionTrailItemV1(label: 'BTN folds'),
      const Act0ActionTrailItemV1(label: 'SB folds'),
      Act0ActionTrailItemV1(label: 'BB calls ${_bbLabel(open - 1)} more'),
      for (final previous in [PokerStreet.flop, PokerStreet.turn])
        if (previous.index < street.index)
          for (final seat in live)
            Act0ActionTrailItemV1(
              label:
                  '${previous == PokerStreet.flop ? 'Flop' : 'Turn'}: ${seat.toUpperCase()} checks',
            ),
      Act0ActionTrailItemV1(
        label:
            '$streetLabel: BB ${wager == 0 ? 'checks' : '${allIn ? 'all-in' : 'bets'} $wagerLabel'}',
      ),
      if (multiway)
        Act0ActionTrailItemV1(label: '$streetLabel: HJ calls $wagerLabel'),
    ],
    handContributions: ledger,
    autoPlayHistory: false,
    seats: [
      for (final seat in _preflopSeats)
        Act0SeatStateV1(
          seatId: seat,
          seatLabel: seat.toUpperCase(),
          displayName: seat == 'co' ? 'You' : seat.toUpperCase(),
          isHero: seat == 'co',
          isDealerButton: seat == 'btn',
          isSmallBlind: seat == 'sb',
          isBigBlind: seat == 'bb',
          isActive: seat == 'co',
          isInHand: live.contains(seat),
          isFolded: !live.contains(seat),
          hasActed: seat != 'co',
          isLastAggressor:
              seat ==
              (wager > 0
                  ? 'bb'
                  : multiway
                  ? 'hj'
                  : 'co'),
          stackLabel: stack(seat),
          holeCards: seat == 'co'
              ? hero
              : const [
                  Act0CardStateV1(rank: '?', suit: ''),
                  Act0CardStateV1(rank: '?', suit: ''),
                ],
          cardsVisibleMode: seat == 'co'
              ? Act0CardsVisibleModeV1.faceUp
              : live.contains(seat)
              ? Act0CardsVisibleModeV1.faceDown
              : Act0CardsVisibleModeV1.none,
          bet: wager > 0 && (seat == 'bb' || (multiway && seat == 'hj'))
              ? Act0SeatBetStateV1(
                  kind: seat == 'hj'
                      ? Act0SeatBetKindV1.call
                      : allIn
                      ? Act0SeatBetKindV1.allIn
                      : Act0SeatBetKindV1.bet,
                  label: seat == 'hj'
                      ? 'Call'
                      : allIn
                      ? 'All-in'
                      : 'Bet',
                  amountLabel: wagerLabel,
                )
              : null,
        ),
    ],
  );
}

String _practicePercent(double value) => '${(100 * value).toStringAsFixed(1)}%';

typedef _PracticeAnswer = ({
  String title,
  String question,
  String premise,
  String a,
  String b,
  bool firstIsBest,
  String firstReason,
  String secondReason,
  Map<String, Object?> math,
});

_PracticeAnswer _priceAnswer(
  PostflopPracticeSkillV1 skill,
  _PracticeDeal deal,
  List<_Showdown> results,
  double equity,
  double pot,
  double price,
) {
  final multiway = _jointOpponents(skill);
  final river = skill == PostflopPracticeSkillV1.riverBluffCatch;
  final opponents = multiway
      ? 'Suppose BB holds ${deal.opponents[0]} and HJ holds ${deal.opponents[1]}.'
      : river
      ? 'Suppose BB bets one of these equally likely hands: ${deal.opponents.join(', ')}.'
      : 'Suppose BB holds ${deal.opponents.single}.';
  final threshold = price / (pot + price);
  final edge = equity * (pot + price) - price;
  final facts = river
      ? 'You win against ${results.where((result) => result.wins > 0).length} of the ${results.length} stated hands.'
      : '${results.single.wins} of ${results.single.outcomes} rivers win${multiway ? ' against both players' : ''}.';
  final equitySentence = 'Your pot share is ${_practicePercent(equity)}.';
  final priceSentence = 'The call needs ${_practicePercent(threshold)}.';
  return (
    title: switch (skill) {
      PostflopPracticeSkillV1.outsVsPrice => 'Compare your draw with the price',
      PostflopPracticeSkillV1.multiwayPrice => 'Price against two players',
      _ => 'Catch a river bluff',
    },
    question: 'Call or fold in this model?',
    premise:
        '$opponents ${multiway ? 'HJ has already matched the bet. ' : ''}No bets follow a call.',
    a: 'Call',
    b: 'Fold',
    firstIsBest: edge > 0,
    firstReason:
        '$facts $equitySentence $priceSentence ${edge > 0 ? 'A call earns more than folding.' : 'Calling pays too much for that share.'}',
    secondReason:
        '$priceSentence ${edge > 0 ? 'Folding gives up the gain from a ${_practicePercent(equity)} share.' : '$equitySentence Folding saves the price.'}',
    math: {'call_ev_bb': edge, 'required_share': threshold},
  );
}

_PracticeAnswer _depthAnswer(_PracticeDeal deal, double pot, double depth) {
  final secondBet = pot * 3;
  final required = pot + secondBet;
  final spr = depth / pot;
  return (
    title: 'Plan a second bet with SPR',
    question:
        'If BB calls, can both stacks cover one pot-size bet on each street?',
    premise:
        'Compare the current stack with the pot. Suppose BB holds ${deal.opponents.first} and calls the turn bet.',
    a: 'Both pot-size bets fit',
    b: 'The smaller stack limits the second bet',
    firstIsBest: depth >= required,
    firstReason:
        'Starting SPR is ${spr.toStringAsFixed(1)}. Two pot-size bets need ${_bbLabel(required)} in each stack. ${depth >= required ? 'Both stacks cover that total.' : 'The smaller stack is below that total.'}',
    secondReason:
        'After a pot-size bet and a call, the next pot is ${_bbLabel(secondBet)}. The smaller stack has ${_bbLabel(depth - pot)} left.',
    math: {
      'spr': spr,
      'required_stack_bb': required,
      'effective_stack_bb': depth,
    },
  );
}

_PracticeAnswer _betAnswer(
  PostflopPracticeSkillV1 skill,
  _PracticeDeal deal,
  List<_Showdown> results,
  double equity,
  double pot,
) {
  final bet = (pot / 3 * 2).roundToDouble() / 2;
  final checkEv = equity * pot;
  var betEv = 0.0;
  for (final (index, result) in results.indexed) {
    betEv += deal.folds.contains(index)
        ? pot
        : result.share * (pot + 2 * bet) - bet;
  }
  betEv /= results.length;
  final isBucket = skill == PostflopPracticeSkillV1.rangeBuckets;
  final isTexture = skill == PostflopPracticeSkillV1.continuationTexture;
  final title = isBucket
      ? 'Find the purpose of a bet'
      : isTexture
      ? 'Size a flop continuation bet'
      : 'Bet against a frequent caller';
  final calling = [
    for (final (i, hand) in deal.opponents.indexed)
      if (!deal.folds.contains(i)) hand,
  ].join(', ');
  final folding = [for (final i in deal.folds) deal.opponents[i]].join(', ');
  final best = betEv > checkEv;
  final rainbow =
      deal.board.split(' ').map((card) => card[1]).toSet().length == 3;
  final texture = isTexture
      ? rainbow
            ? 'The flop is rainbow with spread ranks. '
            : 'The flop has nearby ranks and two cards of one suit. '
      : '';
  final comparison =
      'Betting averages ${betEv.toStringAsFixed(2)} BB. Checking averages ${checkEv.toStringAsFixed(2)} BB.';
  return (
    title: title,
    question: isBucket
        ? 'Which range bucket fits this bet under the stated response?'
        : isTexture
        ? 'Which continuation play earns more on this flop?'
        : 'What earns more against this frequent caller?',
    premise:
        '${isTexture ? 'You raised preflop and BB checked this flop. ' : ''}Suppose BB holds one of the stated hands with equal weight. If BB holds $calling, BB calls ${_bbLabel(bet)}.${folding.isEmpty ? '' : ' If BB holds $folding, BB folds.'} No further bets.',
    a: isBucket ? 'Value, get weaker hands to call' : 'Bet ${_bbLabel(bet)}',
    b: isBucket ? 'Bluff candidate, make better hands fold' : 'Check behind',
    firstIsBest: isBucket ? deal.folds.isEmpty : best,
    firstReason: isBucket
        ? deal.folds.isEmpty
              ? 'The modeled calls come from hands you are ahead of now. $comparison'
              : 'The listed higher cards without a private-card pair fold. BB can still call with the queen that pairs the board.'
        : '$texture$comparison ${best ? 'The stated calls make the small bet earn more.' : 'The stated calls make the bet earn less.'}',
    secondReason: isBucket
        ? deal.folds.isEmpty
              ? 'BB calls with the listed weaker hands. The payment comes from calls, so the bet is for value.'
              : 'Both higher hands marked as folds leave the pot. $comparison'
        : '${texture}Checking keeps the pot at its current size. $comparison',
    math: {'bet_bb': bet, 'bet_ev_bb': betEv, 'check_ev_bb': checkEv},
  );
}

List<GeneratedPracticeTaskV1> generatePostflopPracticeV1(
  PostflopPracticeSkillV1 skill, {
  int count = 8,
  int seed = 1,
}) {
  if (count < 1) throw ArgumentError.value(count, 'count');
  final rng = Random(seed + skill.index * 97);
  final preferences = [for (var i = 0; i < count; i++) i.isEven]..shuffle(rng);
  final seen = <String>{};
  final cache = <String, List<_Showdown>>{};
  final generated = <GeneratedPracticeTaskV1>[];
  final multiway = _jointOpponents(skill);
  final allIn = skill == PostflopPracticeSkillV1.outsVsPrice;
  final priceTask =
      allIn || multiway || skill == PostflopPracticeSkillV1.riverBluffCatch;

  for (var attempt = 0; generated.length < count; attempt++) {
    if (attempt >= count * 100) {
      throw StateError(
        'Only generated ${generated.length} of $count for ${skill.name}',
      );
    }
    final first = preferences[generated.length];
    final model = _model(skill, first, rng);
    final models = multiway ? [model.opponents.join(' ')] : model.opponents;
    final heroBoard = '${model.hero} ${model.board}';
    if (models.any((hand) {
      final cards = '$heroBoard $hand'.split(' ');
      return cards.toSet().length != cards.length;
    })) {
      continue;
    }
    final deal = _permuteSuits(model, rng);
    final signature = '${deal.hero}|${deal.board}';
    if (seen.contains(signature)) continue;
    final open = [2.0, 2.5, 3.0, 3.5][rng.nextInt(4)];
    final posts = _practicePosts(open, multiway);
    final street = switch (deal.board.split(' ').length) {
      3 => PokerStreet.flop,
      4 => PokerStreet.turn,
      _ => PokerStreet.river,
    };
    final seatIds = _preflopSeats.toSet();
    final before = Act0HandContributionsV1(
      throughStreet: street,
      entries: posts,
    ).amounts(seatIds: seatIds).potBb;
    final results = cache.putIfAbsent(
      '${model.hero}|${model.board}|${model.opponents.join('|')}',
      () => _practiceEquities(model, skill),
    );
    final equity =
        results.fold<double>(0, (sum, result) => sum + result.share) /
        results.length;
    final depth = skill == PostflopPracticeSkillV1.stackToPot
        ? before * (first ? 5 : 2)
        : 96.0;
    var bet = 0.0;
    if (priceTask) {
      final sizes = [1.0, 1.5, 2.0, 3.0, 4.0, 6.0, 8.0, 12.0, 16.0, 20.0]
        ..shuffle(rng);
      for (final size in sizes) {
        final amounts = _practiceLedger(
          posts,
          street,
          open,
          size,
          multiway: multiway,
          allIn: allIn,
          opponentBehind: depth,
        ).amounts(seatIds: seatIds, actorSeatId: 'co');
        final price = amounts.toCallBb!;
        final edge = equity * (amounts.potBb + price) - price;
        if (edge.abs() > .05 && (edge > 0) == first) {
          bet = size;
          break;
        }
      }
      if (bet == 0) continue;
    }
    final ledger = _practiceLedger(
      posts,
      street,
      open,
      bet,
      multiway: multiway,
      allIn: allIn,
      opponentBehind: depth,
    );
    final amounts = ledger.amounts(seatIds: seatIds, actorSeatId: 'co');
    final answer = priceTask
        ? _priceAnswer(
            skill,
            deal,
            results,
            equity,
            amounts.potBb,
            amounts.toCallBb!,
          )
        : skill == PostflopPracticeSkillV1.stackToPot
        ? _depthAnswer(deal, amounts.potBb, depth)
        : _betAnswer(skill, deal, results, equity, amounts.potBb);
    if (answer.firstIsBest != first) continue;

    final correctLabel = first ? answer.a : answer.b;
    final options = [
      for (final (index, label, reason) in [
        (0, answer.a, answer.firstReason),
        (1, answer.b, answer.secondReason),
      ])
        Act0RunnerOptionV1(
          id: index == 0 ? 'first' : 'second',
          label: label,
          isCorrect: label == correctLabel,
          preferredLabel: correctLabel,
          betterAnswerLabel: label == correctLabel ? '' : correctLabel,
          quality: label == correctLabel
              ? Act0FeedbackQualityV1.correct
              : Act0FeedbackQualityV1.wrong,
          feedbackTitle: label == correctLabel ? 'Correct.' : 'Look again.',
          feedbackReason: 'With ${deal.hero} on ${deal.board}, $reason',
        ),
    ]..shuffle(rng);
    final lesson = 'generated_${skill.name}';
    final task = Act0LessonTaskV1(
      taskId: 'gen_${skill.name}_${seed}_${generated.length + 1}',
      title: answer.title,
      phase: Act0LessonPhaseV1.drill,
      rewardXp: 0,
      stepKind: Act0LessonStepKindV1.practice,
      runner: Act0RunnerStateV1(
        lessonId: lesson,
        lessonTitle: answer.title,
        lessonSubtitle: '',
        beatIndex: generated.length + 1,
        beatCount: count,
        phase: Act0LessonPhaseV1.drill,
        caption: answer.premise,
        hint: '',
        hintPolicy: Act0HintPolicyV1.hidden,
        question: answer.question,
        options: options,
        feedbackTitle: '',
        feedbackReason: '',
        primaryCtaLabel: 'Next',
        nextLessonId: null,
        returnTarget: '',
        table: _postflopTable(
          deal,
          ledger,
          open,
          bet,
          multiway: multiway,
          allIn: allIn,
        ),
      ),
    );
    seen.add(signature);
    generated.add(
      GeneratedPracticeTaskV1(
        templateId: skill.name,
        worldNumber: skill.world,
        lessonId: lesson,
        task: task,
        metadata: {
          'hero': deal.hero,
          'board': deal.board,
          'opponents': deal.opponents,
          'pot_bb': amounts.potBb,
          'to_call_bb': amounts.toCallBb,
          'equity': equity,
          'runouts': [for (final result in results) result.outcomes],
          'winning_runouts': [for (final result in results) result.wins],
          ...answer.math,
        },
      ),
    );
  }
  return generated;
}

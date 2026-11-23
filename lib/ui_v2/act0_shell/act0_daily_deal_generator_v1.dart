part of 'act0_shell_state_v1.dart';

enum Act0DailyDealTemplateV1 {
  callPrice,
  cleanOuts,
  open,
  defendBb,
  lowSpr,
  continuationTexture,
  riverBluffCatch,
}

const act0LegacyDailyDealTemplatesV1 = [
  Act0DailyDealTemplateV1.callPrice,
  Act0DailyDealTemplateV1.cleanOuts,
  Act0DailyDealTemplateV1.open,
  Act0DailyDealTemplateV1.defendBb,
  Act0DailyDealTemplateV1.lowSpr,
];

/// A rep is admitted only by a completed drill on the concrete skill. A lesson
/// title or high world number by itself cannot unlock a generated decision.
const act0DailyDealSourceTasksV1 = <String, Act0DailyDealTemplateV1>{
  'w3_play_from_blinds_big_blind_defend': Act0DailyDealTemplateV1.defendBb,
  'apply_btn_open': Act0DailyDealTemplateV1.open,
  'same_hand_different_seat_same_hand_late_open': Act0DailyDealTemplateV1.open,
  'position_apply_hj_fold': Act0DailyDealTemplateV1.open,
  'button_advantage_button_open': Act0DailyDealTemplateV1.open,
  'w4_good_price_call': Act0DailyDealTemplateV1.callPrice,
  'w4_bad_price_fold': Act0DailyDealTemplateV1.callPrice,
  'w4_checkpoint_price': Act0DailyDealTemplateV1.callPrice,
  'outs_improvement_w5_table_outs_flush_transfer':
      Act0DailyDealTemplateV1.cleanOuts,
  'outs_improvement_w5_table_outs_straight_transfer':
      Act0DailyDealTemplateV1.cleanOuts,
  'w7_clean_outs_lower_price': Act0DailyDealTemplateV1.cleanOuts,
  'w7_clean_outs_higher_price': Act0DailyDealTemplateV1.cleanOuts,
  'w11_multiway_dirty_outs': Act0DailyDealTemplateV1.cleanOuts,
  'w12_clean_outs_vs_set': Act0DailyDealTemplateV1.cleanOuts,
  'w12_bad_call_good_result': Act0DailyDealTemplateV1.cleanOuts,
  'w7_low_spr_commit': Act0DailyDealTemplateV1.lowSpr,
  'w11_spr_low_overpair': Act0DailyDealTemplateV1.lowSpr,
};

Act0DailyDealTemplateV1? act0DailyDealTemplateForSourceV1(String taskId) =>
    act0DailyDealSourceTasksV1[taskId] ??
    (act0CurriculumPilotEnabledV1
        ? _pilotDailySpotsV1[taskId]?.template
        : null);

bool act0IsPilotDailyDealSourceV1(String taskId) =>
    act0CurriculumPilotEnabledV1 && _pilotDailySpotsV1.containsKey(taskId);

typedef Act0DailyDealRecipeV1 = ({
  int day,
  Act0DailyDealTemplateV1 template,
  String lessonId,
  String sourceTaskId,
});

const _dailyDealPrefixV1 = 'daily_deal_v1';

String act0DailyDealIdV1(Act0DailyDealRecipeV1 recipe) =>
    '$_dailyDealPrefixV1:${recipe.day}:${recipe.template.name}:${recipe.lessonId}:${recipe.sourceTaskId}';

Act0DailyDealRecipeV1? act0DailyDealRecipeV1(String id) {
  final parts = id.split(':');
  if (parts.length != 5 || parts[0] != _dailyDealPrefixV1) return null;
  final day = int.tryParse(parts[1]);
  final template = act0DailyDealTemplateForSourceV1(parts[4]);
  if (day == null ||
      day < 0 ||
      parts[2] != template?.name ||
      parts[3].isEmpty) {
    return null;
  }
  return (
    day: day,
    template: template!,
    lessonId: parts[3],
    sourceTaskId: parts[4],
  );
}

int act0DailyDealDayV1(DateTime local) =>
    DateTime.utc(local.year, local.month, local.day).millisecondsSinceEpoch ~/
    Duration.millisecondsPerDay;

final _dailyDealDeck = [
  for (final rank in act0ChartRanksV1.split(''))
    for (final suit in 'shdc'.split('')) '$rank$suit',
];

String _dailyHandCodeV1(List<String> cards) {
  final a = cards[0];
  final b = cards[1];
  final ordered =
      act0ChartRanksV1.indexOf(a[0]) <= act0ChartRanksV1.indexOf(b[0])
      ? [a, b]
      : [b, a];
  final ranks = ordered[0][0] + ordered[1][0];
  return ordered[0][0] == ordered[1][0]
      ? ranks
      : ranks + (a[1] == b[1] ? 's' : 'o');
}

typedef _DailyDealContentV1 = ({
  Act0TableStateV1 table,
  String question,
  String premise,
  String preferred,
  String alternative,
  String explanation,
  String correction,
});

/// A bounded generator; it returns only deals whose visible decision matches
/// the contribution ledger, whose cards are legal, and whose choice is scored.
Act0LessonTaskV1? act0GenerateDailyDealV1({
  required String taskId,
  required String lessonId,
  required Act0DailyDealTemplateV1 template,
  required int seed,
  String? sourceTaskId,
}) {
  final rng = math.Random(seed);
  final deck = [..._dailyDealDeck]..shuffle(rng);
  final pilot = _pilotDailySpotsV1[sourceTaskId];
  if (pilot != null &&
      (!act0CurriculumPilotEnabledV1 || pilot.template != template))
    return null;
  final content = pilot != null
      ? _pilotDailyDealV1(pilot, rng)
      : switch (template) {
          Act0DailyDealTemplateV1.open => _dailyOpenV1(rng, seed),
          Act0DailyDealTemplateV1.defendBb => _dailyDefendV1(rng),
          Act0DailyDealTemplateV1.callPrice => _dailyPriceV1(deck, rng),
          Act0DailyDealTemplateV1.cleanOuts => _dailyTurnV1(rng),
          Act0DailyDealTemplateV1.lowSpr => _dailyLowSprV1(rng),
          Act0DailyDealTemplateV1.continuationTexture ||
          Act0DailyDealTemplateV1.riverBluffCatch => null,
        };
  if (content == null || !_dailyDealIsValidV1(content)) return null;
  final choices = [content.preferred, content.alternative]..shuffle(rng);
  return Act0LessonTaskV1(
    taskId: taskId,
    title: 'Daily practice',
    phase: Act0LessonPhaseV1.drill,
    rewardXp: 0,
    runner: Act0RunnerStateV1(
      lessonId: lessonId,
      lessonTitle: 'Daily practice',
      lessonSubtitle: '',
      beatIndex: 1,
      beatCount: 1,
      phase: Act0LessonPhaseV1.drill,
      caption: content.premise,
      hint: '',
      hintPolicy: Act0HintPolicyV1.hidden,
      question: content.question,
      options: [
        for (final label in choices)
          Act0RunnerOptionV1(
            id: label.toLowerCase(),
            label: label,
            isCorrect: label == content.preferred,
            preferredLabel: content.preferred,
            quality: label == content.preferred
                ? Act0FeedbackQualityV1.correct
                : Act0FeedbackQualityV1.wrong,
            feedbackTitle: label == content.preferred
                ? 'Correct.'
                : 'Look again.',
            feedbackReason: label == content.preferred
                ? content.explanation
                : content.correction,
            betterAnswerLabel: label == content.preferred
                ? ''
                : content.preferred,
          ),
      ],
      feedbackTitle: '',
      feedbackReason: '',
      primaryCtaLabel: '',
      nextLessonId: null,
      returnTarget: '',
      table: content.table.copyWith(
        showDecisionPremise: content.premise.isNotEmpty,
      ),
    ),
  );
}

List<String> _dailyCardsForHandV1(String hand, math.Random rng) {
  final suits = 'shdc'.split('')..shuffle(rng);
  return [
    '${hand[0]}${suits[0]}',
    '${hand[1]}${suits[hand.endsWith('s') ? 0 : 1]}',
  ];
}

typedef _DailyOpenPoolV1 = ({List<String> all, List<String> boundary});

final _dailyOpenPoolsV1 = {
  for (final seat in Act0ChartSeatV1.values.take(4))
    for (final action in [Act0ChartActionV1.raise, Act0ChartActionV1.fold])
      (seat, action): _dailyOpenPoolV1(seat, action),
};

_DailyOpenPoolV1 _dailyOpenPoolV1(
  Act0ChartSeatV1 seat,
  Act0ChartActionV1 action,
) {
  final all = <String>[];
  final other = <String>[];
  for (final hand in act0ChartHandsV1) {
    final actual = act0ChartActionV1(hand, seat, Act0ChartPrefixV1.unopened);
    (actual == action ? all : other).add(hand);
  }

  bool nextRank(String hand, String neighbor) {
    if (hand.substring(2) != neighbor.substring(2)) return false;
    int distance(int i) =>
        (act0ChartRanksV1.indexOf(hand[i]) -
                act0ChartRanksV1.indexOf(neighbor[i]))
            .abs();
    return hand.length == 2 ? distance(0) == 1 : distance(0) + distance(1) == 1;
  }

  return (
    all: all,
    boundary: [
      for (final hand in all)
        if (other.any((neighbor) => nextRank(hand, neighbor))) hand,
    ],
  );
}

_DailyDealContentV1 _dailyOpenV1(math.Random rng, int seed) {
  final seat = Act0ChartSeatV1.values[seed % 4];
  // Each seat gets both actions in every block of eight seeds.
  final opens = seed % 8 < 4;
  final action = opens ? Act0ChartActionV1.raise : Act0ChartActionV1.fold;
  final pool = _dailyOpenPoolsV1[(seat, action)]!;
  final candidates = pool.boundary.isNotEmpty && rng.nextInt(4) != 0
      ? pool.boundary
      : pool.all;
  final code = candidates[rng.nextInt(candidates.length)];
  final hand = _dailyCardsForHandV1(code, rng);
  final behind = [
    for (final player in Act0ChartSeatV1.values.skip(seat.index + 1))
      player.name.toUpperCase(),
  ].join(', ');
  final group = act0ChartGroupV1(code);
  final pair = code.length == 2;
  final value = switch ((pair, group)) {
    (true, Act0ChartGroupV1.premium || Act0ChartGroupV1.strong) =>
      'weaker pairs can call',
    (true, _) => 'you can win the blinds or flop a set when called',
    (false, _) when code[0] == 'A' =>
      'weaker aces can call, and your ace removes some strong ace combinations',
    (false, _) =>
      'you can win the blinds, and your high cards can make top pair when called',
  };
  final foldReason = group != Act0ChartGroupV1.weak
      ? 'a raise can run into higher pairs or strong aces'
      : pair
      ? 'higher pairs can continue and overcards often come on the flop'
      : 'a caller who shares one of your ranks can have a better kicker';
  return (
    table: _day7PreflopV1(seat.name, hand.join(' '), showTurn: true),
    question: 'You are first in. Raise or fold?',
    premise: 'Use the six-seat starting chart.',
    preferred: opens ? 'Raise' : 'Fold',
    alternative: opens ? 'Fold' : 'Raise',
    explanation: opens
        ? '$behind still act. Raise $code because $value. Folding gives up that chance.'
        : '$behind still act. Fold $code because $foldReason. A raise risks chips against those hands.',
    correction: opens
        ? 'Folding $code gives up the chance to win the blinds or play a stronger hand against callers. Raise from this seat.'
        : 'Fold $code. A raise risks chips when the players behind continue with stronger hands.',
  );
}

typedef _DailyDefenseSpotV1 = ({String hand, double open, double equity});

final _dailyDefenseSpotsV1 = {
  for (final seat in act0DefendOpeningSeatsV1)
    seat: _dailyDefenseSpotsForSeatV1(seat),
};

List<_DailyDefenseSpotV1> _dailyDefenseSpotsForSeatV1(Act0ChartSeatV1 opener) {
  final seats = _day7SeatsV1.toSet();
  final pricesByOpen = <double, double>{};
  for (var quarters = 8; quarters <= 24; quarters++) {
    final open = quarters / 4;
    final amounts = Act0HandContributionsV1(
      throughStreet: PokerStreet.preflop,
      entries: _day7OpeningContributionsV1(opener.name, open),
      startingStackBbBySeat: const {'bb': _day7DefaultStackBbV1},
    ).amounts(seatIds: seats, actorSeatId: 'bb');
    final due = amounts.toCallBb!;
    pricesByOpen[open] = act0CallPriceV1(amounts.potBb, due)!.equity;
  }

  return [
    for (final hand in act0ChartHandsV1)
      if (act0PreflopEquityTenthsV1(hand, opener) case final equity?)
        for (final price in pricesByOpen.entries)
          if ((equity / 1000 - price.value).abs() case final edge
              when edge >= 0.002 && edge <= 0.05)
            (hand: hand, open: price.key, equity: equity / 1000),
  ];
}

_DailyDealContentV1? _dailyDefendV1(math.Random rng) {
  final opener =
      act0DefendOpeningSeatsV1[rng.nextInt(act0DefendOpeningSeatsV1.length)];
  final spots = _dailyDefenseSpotsV1[opener]!;
  if (spots.isEmpty) return null;
  final spot = spots[rng.nextInt(spots.length)];
  final hand = _dailyCardsForHandV1(spot.hand, rng);
  final table = _day7PreflopV1(
    'bb',
    hand.join(' '),
    opener: opener.name,
    openBb: spot.open,
    showTurn: true,
  );
  final (potBb: pot, toCallBb: due) = _dailyDealAmountsV1(table);
  final needed = due! / (pot + due);
  final calls = spot.equity > needed;
  final seat = opener.name.toUpperCase();
  final equity = _dailyPctV1(spot.equity);
  final price = _dailyPctV1(needed);
  return (
    table: table,
    question: 'Defend the big blind by calling, or fold?',
    premise:
        "Your ${spot.hand} has $equity equity against $seat's chart opening range. Each legal combination is equally likely. If you call, both players check to showdown and ties split the pot.",
    preferred: calls ? 'Call' : 'Fold',
    alternative: calls ? 'Fold' : 'Call',
    explanation:
        "After $seat raises, you owe ${_act0BbLabelV1(due)}. Your ${spot.hand} has $equity equity against $seat's opening range, ${calls ? 'above' : 'below'} the $price price. ${calls ? 'Calling earns more than folding' : 'Folding saves more than calling'}.",
    correction: calls
        ? 'Folding gives up a profitable call. Your ${spot.hand} has $equity equity against $seat, above the $price price.'
        : 'Calling ${spot.hand} loses chips. Its $equity equity against $seat falls below the $price price.',
  );
}

_DailyDealContentV1 _dailyPriceV1(List<String> deck, math.Random rng) {
  final hero = ['bb', 'btn', 'co', 'hj'][rng.nextInt(4)];
  final opponent = hero == 'bb' ? 'btn' : 'bb';
  final table = _day7PostflopV1(
    hero,
    deck.take(2).join(' '),
    deck.skip(2).take(4).join(' '),
    opponent: opponent,
    betBb: 1.5 + 0.5 * rng.nextInt(13),
    openBb: 2.5 + 0.25 * rng.nextInt(7),
    showTurn: true,
  );
  final (potBb: pot, toCallBb: due) = _dailyDealAmountsV1(table);
  return _dailyPriceAnswerV1(
    table,
    due! / pot,
    question: 'How often must you win to break even on a call?',
    premise: 'Assume there are no ties or bets after a call.',
    opponent: opponent.toUpperCase(),
  );
}

_DailyDealContentV1 _dailyPriceAnswerV1(
  Act0TableStateV1 table,
  double alternative, {
  required String question,
  required String premise,
  String? opponent,
}) {
  final (potBb: pot, toCallBb: due) = _dailyDealAmountsV1(table);
  final pct = act0CallPriceV1(pot, due!)!.equity;
  final action = opponent == null ? '' : '$opponent has bet, and ';
  return (
    table: table,
    question: question,
    premise: premise,
    preferred: _dailyPctV1(pct),
    alternative: _dailyPctV1(alternative),
    explanation:
        '$action${opponent == null ? 'Your' : 'your'} ${_act0BbLabelV1(due)} call makes the final pot ${_act0BbLabelV1(pot + due)}. Dividing by that final pot gives ${_dailyPctV1(pct)}. Dividing by the current pot sets the bar too high.',
    correction:
        'That divides by the pot after the opponent’s bet. Include your call too. You need ${_dailyPctV1(pct)}.',
  );
}

_DailyDealContentV1? _dailyTurnV1(math.Random rng) {
  final suits = 'shdc'.split('')..shuffle(rng);
  final low = '234'.split('')..shuffle(rng);
  final middle = '56789T'.split('')..shuffle(rng);
  final (draw, side, turn, spare) = (suits[0], suits[1], suits[2], suits[3]);
  // A low flop and high turn keep a common straight off this board.
  final (one, two, set, last, kicker) = (
    low[0],
    low[1],
    middle[0],
    'JQK'[rng.nextInt(3)],
    middle[1],
  );
  final hand = ['A$draw', '$kicker$draw'];
  final board = ['$one$draw', '$two$draw', '$set$side', '$last$turn'];
  final villain = ['$set$turn', '$set$spare'];
  final hero = ['bb', 'btn', 'co', 'hj'][rng.nextInt(4)];
  final opponent = hero == 'bb' ? 'btn' : 'bb';
  final open = 2.5 + rng.nextInt(4) * 0.5;
  final bet = rng.nextBool() ? 1.0 : 4.0 + rng.nextInt(8);
  final base = _day7PostflopV1(
    hero,
    hand.join(' '),
    board.join(' '),
    opponent: opponent,
    openBb: open,
    betBb: bet,
    showTurn: true,
  );
  final table = _day7TableV1(
    hero: hero,
    hand: hand.join(' '),
    street: PokerStreet.turn,
    actor: hero,
    board: base.boardCards,
    shown: {opponent: _act0LessonCardsV1(villain.join(' '))},
    folded: _day7SeatsV1
        .where((seat) => seat != hero && seat != opponent)
        .toSet(),
    entries: base.handContributions!.entries,
    history: base.actionTrail,
    bets: {
      opponent: base.seats.firstWhere((seat) => seat.seatId == opponent).bet!,
    },
  );
  final (potBb: pot, toCallBb: callPrice) = _dailyDealAmountsV1(table);
  final due = callPrice!;
  final known = {...hand, ...board, ...villain};
  final ahead =
      solver.Hand.solveHand([
        ...hand,
        ...board,
      ]).compare(solver.Hand.solveHand([...villain, ...board])) <
      0;
  if (ahead) return null;
  var wins = 0;
  var ties = 0;
  for (final river in _dailyDealDeck.where((card) => !known.contains(card))) {
    final compared = solver.Hand.solveHand([
      ...hand,
      ...board,
      river,
    ]).compare(solver.Hand.solveHand([...villain, ...board, river]));
    if (compared < 0) wins++;
    if (compared == 0) ties++;
  }
  if (ties != 0) return null;
  final equity = act0OneCardOutsV1(wins, 52 - known.length)!;
  final price = act0CallPriceV1(pot, due)!.equity;
  if (equity == price) return null;
  final calls = equity > price;
  final other = opponent.toUpperCase();
  final comparison = calls
      ? 'calling earns more than folding'
      : 'folding saves more than calling';
  return (
    table: table,
    question: 'Count the rivers that win. Call or fold?',
    premise:
        '$other shows a set. Both players check the river after a call. Treat other cards as random.',
    preferred: calls ? 'Call' : 'Fold',
    alternative: calls ? 'Fold' : 'Call',
    explanation:
        '$other shows a set, so count only rivers that leave you ahead. The $wins winning rivers out of 44 give ${_dailyPctV1(equity)}, ${calls ? 'above' : 'below'} the ${_dailyPctV1(price)} price, so $comparison.',
    correction: calls
        ? 'Count the rivers that beat $other’s set. The $wins winning rivers out of 44 give ${_dailyPctV1(equity)}, above the ${_dailyPctV1(price)} price, so folding passes up value.'
        : 'Count only the rivers where you beat $other’s set. You have ${_dailyPctV1(equity)} from $wins winning rivers out of 44, below the ${_dailyPctV1(price)} price. Fold because calling loses chips.',
  );
}

String _dailyPctV1(double ratio) => '${(100 * ratio).toStringAsFixed(1)}%';

({double potBb, double? toCallBb}) _dailyDealAmountsV1(
  Act0TableStateV1 table,
) => table.handContributions!.amounts(
  seatIds: table.seats.map((seat) => seat.seatId).toSet(),
  actorSeatId: table.heroSeatId,
);

bool _dailyDealIsValidV1(_DailyDealContentV1 deal) {
  final table = deal.table;
  final cards = [
    ...table.boardCards,
    for (final seat in table.seats)
      if (seat.cardsVisibleMode == Act0CardsVisibleModeV1.faceUp)
        ...seat.holeCards,
  ].map((card) => card.label).toList();
  final active = table.seats.where((seat) => seat.isActive);
  final amounts = _dailyDealAmountsV1(table);
  final due = amounts.toCallBb;
  return table.usesCanonicalPlayerCount &&
      table.seats.length == table.playerCount &&
      table.heroCards.length == 2 &&
      active.singleOrNull?.seatId == table.heroSeatId &&
      !table.heroSeat.isFolded &&
      table.boardCards.length ==
          (switch (table.handContributions!.throughStreet) {
            PokerStreet.flop => 3,
            PokerStreet.turn => 4,
            PokerStreet.river => 5,
            _ => 0,
          }) &&
      cards.every(_dailyDealDeck.contains) &&
      cards.toSet().length == cards.length &&
      table.potLabel == 'Pot ${_act0BbLabelV1(amounts.potBb)}' &&
      due != null &&
      table.toCallLabel == (due == 0 ? '' : 'To call ${_act0BbLabelV1(due)}') &&
      deal.preferred != deal.alternative &&
      deal.explanation.split(RegExp(r'\s+')).length <= 40;
}

typedef _LowSprScenarioV1 = ({
  List<String> hand,
  List<String> flop,
  List<List<String>> range,
  String handName,
  String rangeRead,
});

const _lowSprScenariosV1 = <_LowSprScenarioV1>[
  (
    hand: ['Qs', 'Qd'],
    flop: ['Jh', '7d', '2c'],
    range: [
      ['Js', 'Jd'],
      ['7h', '7s'],
      ['Ah', 'Ad'],
    ],
    handName: 'Your overpair',
    rangeRead: 'BB shoves only sets or a higher pair',
  ),
  (
    hand: ['Qs', 'Qd'],
    flop: ['Jh', '7d', '2c'],
    range: [
      ['Jc', 'Tc'],
      ['9s', '9h'],
      ['As', 'Kh'],
    ],
    handName: 'Your overpair',
    rangeRead: 'BB shoves weaker pairs and overcards',
  ),
  (
    hand: ['Qs', 'Qd'],
    flop: ['Jh', '7d', '2c'],
    range: [
      ['Js', 'Jd'],
      ['Ah', 'Ad'],
      ['9s', '9h'],
    ],
    handName: 'Your overpair',
    rangeRead: 'BB shoves a set, aces or a lower pair',
  ),
  (
    hand: ['As', 'Qd'],
    flop: ['Ah', '8d', '3c'],
    range: [
      ['8c', '8s'],
      ['3h', '3d'],
      ['Ac', 'Kh'],
    ],
    handName: 'Your top pair',
    rangeRead: 'BB shoves only sets or a stronger ace',
  ),
  (
    hand: ['As', 'Qd'],
    flop: ['Ah', '8d', '3c'],
    range: [
      ['Ad', 'Jc'],
      ['8s', '9s'],
      ['Kh', 'Kd'],
    ],
    handName: 'Your top pair',
    rangeRead: 'BB shoves weaker pairs and a weaker ace',
  ),
];

// Relabelling every suit preserves the legal runouts and hand strengths.
final _lowSprEquitiesV1 = _lowSprScenariosV1.map(_dailyFlopEquityV1).toList();

double _dailyFlopEquityV1(_LowSprScenarioV1 scenario) {
  var halfShares = 0;
  var runouts = 0;
  for (final holding in scenario.range) {
    final seen = {...scenario.hand, ...scenario.flop, ...holding};
    final deck = _dailyDealDeck.where((card) => !seen.contains(card)).toList();
    for (var turn = 0; turn < deck.length - 1; turn++) {
      for (var river = turn + 1; river < deck.length; river++) {
        final board = [...scenario.flop, deck[turn], deck[river]];
        final hero = solver.Hand.solveHand([...scenario.hand, ...board]);
        final bettor = solver.Hand.solveHand([...holding, ...board]);
        final result = hero.compare(bettor);
        if (result < 0) halfShares += 2;
        if (result == 0) halfShares++;
        runouts++;
      }
    }
  }
  return halfShares / (2 * runouts);
}

_DailyDealContentV1? _dailyLowSprV1(math.Random rng) {
  final scenarioIndex = rng.nextInt(_lowSprScenariosV1.length);
  final scenario = _lowSprScenariosV1[scenarioIndex];
  final suits = 'shdc'.split('')..shuffle(rng);
  String cards(List<String> list) =>
      list.map((card) => card[0] + suits['shdc'.indexOf(card[1])]).join(' ');

  final hero = ['hj', 'co', 'btn'][rng.nextInt(3)];
  final hand = cards(scenario.hand);
  final open = 2.5 + rng.nextInt(5) * .25;
  final base = _day7PostflopV1(
    hero,
    hand,
    cards(scenario.flop),
    openBb: open,
    showTurn: true,
  );
  final flopPot = _dailyDealAmountsV1(base).potBb;
  final flopPotQuarters = (4 * flopPot).round();
  if (flopPotQuarters <= 0) return null;
  final bet = (flopPotQuarters + rng.nextInt(flopPotQuarters + 1)) / 4;
  final table = _day7TableV1(
    hero: hero,
    hand: hand,
    street: PokerStreet.flop,
    actor: hero,
    board: base.boardCards,
    folded: _day7SeatsV1.where((seat) => seat != hero && seat != 'bb').toSet(),
    entries: [
      ...base.handContributions!.entries,
      Act0ContributionV1(
        PokerStreet.flop,
        'bb',
        Act0ContributionKindV1.wager,
        bet,
      ),
    ],
    history: [
      ...base.actionTrail,
      Act0ActionTrailItemV1(label: 'Flop: BB all-in ${_act0BbLabelV1(bet)}'),
    ],
    bets: {
      'bb': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.allIn,
        label: 'All-in',
        amountLabel: _act0BbLabelV1(bet),
      ),
    },
    stacks: {'bb': open + bet},
  );
  final (potBb: pot, toCallBb: due) = _dailyDealAmountsV1(table);
  if (due == null || due <= 0) return null;
  final depth = act0EffectiveStacksV1(
    table.handContributions!,
    heroSeatId: hero,
    activeSeatIds: {hero, 'bb'},
  )['bb']!;
  final spr = depth / flopPot;
  if (spr > 2) return null;

  final equity = _lowSprEquitiesV1[scenarioIndex];
  final price = act0CallPriceV1(pot, due)!.equity;
  if (equity == price) return null;
  final calls = equity > price;
  // Keep close calls visibly distinct as well as mathematically distinct.
  final equityText = '${(100 * equity).toStringAsFixed(2)}%';
  final priceText = '${(100 * price).toStringAsFixed(2)}%';
  final comparison = calls ? 'clears' : 'falls short of';
  return (
    table: table,
    question: 'Call or fold to the flop all-in?',
    premise:
        'At the start of the flop, the effective stack was ${_act0BbLabelV1(depth)} and the pot was ${_act0BbLabelV1(flopPot)} (SPR ${spr.toStringAsFixed(2)}). '
        'BB could shove with any of these equally likely hands: ${scenario.range.map(cards).join(' / ')}. '
        'Your equity against that range is $equityText.',
    preferred: calls ? 'Call' : 'Fold',
    alternative: calls ? 'Fold' : 'Call',
    explanation:
        '${scenario.rangeRead}. At this SPR, it costs ${_act0BbLabelV1(due)} to call. ${scenario.handName} has $equityText equity, which $comparison the $priceText call price, so ${calls ? 'calling beats folding' : 'folding saves chips'}.',
    correction: calls
        ? 'Folding gives up value. Against BB’s stated range, $equityText equity clears the $priceText needed to call.'
        : 'Calling loses chips. Against BB’s stated range, $equityText equity falls short of the $priceText call price.',
  );
}

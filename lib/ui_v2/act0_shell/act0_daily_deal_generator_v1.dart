part of 'act0_shell_state_v1.dart';

enum Act0DailyDealTemplateV1 { callPrice, cleanOuts, open, defendBb }

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
};

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
  final template = act0DailyDealSourceTasksV1[parts[4]];
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
}) {
  final rng = math.Random(seed);
  final deck = [..._dailyDealDeck]..shuffle(rng);
  final content = switch (template) {
    Act0DailyDealTemplateV1.open || Act0DailyDealTemplateV1.defendBb =>
      _dailyPreflopV1(template, deck, rng, seed),
    Act0DailyDealTemplateV1.callPrice => _dailyPriceV1(deck, rng),
    Act0DailyDealTemplateV1.cleanOuts => _dailyTurnV1(rng),
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

_DailyDealContentV1? _dailyPreflopV1(
  Act0DailyDealTemplateV1 template,
  List<String> deck,
  math.Random rng,
  int seed,
) {
  final hand = deck.take(2).toList();
  if (template == Act0DailyDealTemplateV1.open) {
    final seat = Act0ChartSeatV1.values[seed % 4];
    final action = act0ChartActionV1(
      _dailyHandCodeV1(hand),
      seat,
      Act0ChartPrefixV1.unopened,
    );
    if (action != Act0ChartActionV1.raise && action != Act0ChartActionV1.fold) {
      return null;
    }
    final title = seat.name.toUpperCase();
    final remaining = 5 - seat.index;
    final opens = action == Act0ChartActionV1.raise;
    return (
      table: _day7PreflopV1(seat.name, hand.join(' '), showTurn: true),
      question: 'You are first in. Raise or fold?',
      premise: 'Use the six-seat starting chart.',
      preferred: opens ? 'Raise' : 'Fold',
      alternative: opens ? 'Fold' : 'Raise',
      explanation: opens
          ? 'From $title with $remaining players left, the chart opens this hand. Raising can win the blinds when those players fold, while folding gives up that chance.'
          : 'From $title with $remaining players left, this hand falls outside the opening row. Those players can continue with stronger hands, so folding keeps the chips a raise would risk.',
      correction: opens
          ? 'Folding gives up a chart opening. A raise also gives the blinds a chance to fold.'
          : 'A raise puts chips at risk against players still to act. Fold in this seat with this hand.',
    );
  }
  final opener = rng.nextBool() ? Act0ChartSeatV1.btn : Act0ChartSeatV1.co;
  final prefix = opener == Act0ChartSeatV1.btn
      ? Act0ChartPrefixV1.btnOpen
      : Act0ChartPrefixV1.coOpen;
  if (act0ChartActionV1(_dailyHandCodeV1(hand), Act0ChartSeatV1.bb, prefix) !=
      Act0ChartActionV1.priceDecision)
    return null;
  final openSize = [2.0, 2.5, 3.0, 4.0, 5.0][rng.nextInt(5)];
  final table = _day7PreflopV1(
    'bb',
    hand.join(' '),
    opener: opener.name,
    openBb: openSize,
    showTurn: true,
  );
  final (potBb: pot, toCallBb: callPrice) = _dailyDealAmountsV1(table);
  final due = callPrice!;
  const win = 0.30;
  final needed = due / (pot + due);
  final calls = win > needed;
  final seat = opener.name.toUpperCase();
  return (
    table: table,
    question: 'Defend the big blind by calling, or fold?',
    premise:
        'Against this opener, assume you win 30% after calling, with no ties or further bets.',
    preferred: calls ? 'Call' : 'Fold',
    alternative: calls ? 'Fold' : 'Call',
    explanation:
        'Against $seat, your posted blind leaves ${_act0BbLabelV1(due)} to call. The opener’s range gives you 30% in this exercise, ${calls ? 'above' : 'below'} the ${_dailyPctV1(needed)} price, so ${calls ? 'calling earns more than folding' : 'folding saves chips'}.',
    correction: calls
        ? 'Folding gives up a profitable call against this opener. Your 30% beats the ${_dailyPctV1(needed)} price.'
        : 'Calling needs ${_dailyPctV1(needed)} wins against the opener. The stated 30% falls short.',
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
  final (potBb: pot, toCallBb: callPrice) = _dailyDealAmountsV1(table);
  final due = callPrice!;
  final pct = due / (pot + due);
  final alternative = due / pot;
  return (
    table: table,
    question: 'How often must you win to break even on a call?',
    premise: 'Assume there are no ties or bets after a call.',
    preferred: _dailyPctV1(pct),
    alternative: _dailyPctV1(alternative),
    explanation:
        '${opponent.toUpperCase()} has bet, and your ${_act0BbLabelV1(due)} call makes the final pot ${_act0BbLabelV1(pot + due)}. Dividing by that final pot gives ${_dailyPctV1(pct)}. Dividing by the current pot sets the bar too high.',
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
  final equity = wins / (52 - known.length);
  final price = due / (pot + due);
  if (equity == price) return null;
  final calls = equity > price;
  final other = opponent.toUpperCase();
  final comparison = calls
      ? 'calling earns more than folding'
      : 'folding saves chips';
  return (
    table: table,
    question: 'Count the rivers that win. Call or fold?',
    premise:
        '$other shows a set. Both players check the river after a call. Treat other cards as random.',
    preferred: calls ? 'Call' : 'Fold',
    alternative: calls ? 'Fold' : 'Call',
    explanation:
        '$other shows a set, so count only rivers that leave you ahead. You win $wins of 44 rivers, ${calls ? 'above' : 'below'} the ${_dailyPctV1(price)} price, so $comparison.',
    correction: calls
        ? 'Count the rivers that beat $other’s set. The $wins winners clear the ${_dailyPctV1(price)} price, so folding passes up value.'
        : 'Count only the rivers where you beat $other’s set. The $wins winners fall short of the ${_dailyPctV1(price)} price.',
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
      table.boardCards.length == (table.streetLabel == 'Turn' ? 4 : 0) &&
      cards.every(_dailyDealDeck.contains) &&
      cards.toSet().length == cards.length &&
      table.potLabel == 'Pot ${_act0BbLabelV1(amounts.potBb)}' &&
      due != null &&
      table.toCallLabel == (due == 0 ? '' : 'To call ${_act0BbLabelV1(due)}') &&
      deal.preferred != deal.alternative &&
      deal.explanation.split(RegExp(r'\s+')).length <= 40;
}

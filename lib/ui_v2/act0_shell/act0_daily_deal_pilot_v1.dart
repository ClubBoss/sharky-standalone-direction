part of 'act0_shell_state_v1.dart';

typedef _PilotActionV1 = (PokerStreet, String, Act0HandVerbV1, int);

class _PilotDailySpotV1 {
  const _PilotDailySpotV1(
    this.template,
    this.hero,
    this.board, {
    this.layout = _PilotPreflopV1.singleRaise,
    this.range = '',
    this.continues = '',
    this.preferred = '',
    this.offer = 0,
    this.wager = 0,
    this.priorFlopBet = 0,
    this.priorTurnBet = 0,
    this.heroRiverBet = 0,
  });

  final Act0DailyDealTemplateV1 template;
  final String hero, board, range, continues, preferred;
  final _PilotPreflopV1 layout;
  final int offer, wager, priorFlopBet, priorTurnBet, heroRiverBet;
}

enum _PilotPreflopV1 {
  singleRaise,
  inPositionCaller,
  multiway,
  threeBet,
  fourBet,
}

// Source-drill parameters only. Payoffs and answers are recomputed by the
// same showdown/check-through models used by the existing practice templates.
const _pilotDailySpotsV1 = <String, _PilotDailySpotV1>{
  'w13_1_guided_top_pair_value': _PilotDailySpotV1(
    Act0DailyDealTemplateV1.continuationTexture,
    'Ah Qc',
    'Qh 7s 2d',
    range: 'KQs QJs QTs 77 22 JJ TT 98s 65s',
    continues: 'KQs QJs QTs 77 22 JJ TT',
    preferred: 'Bet',
    offer: 300,
  ),
  'w13_6_checkpoint_connected_flop': _PilotDailySpotV1(
    Act0DailyDealTemplateV1.continuationTexture,
    'Ac Qc',
    'Jh Ts 8h',
    layout: _PilotPreflopV1.inPositionCaller,
    range: 'Q9s 97s JJ TT 88 JTs AJs KJs QJs 55',
    continues: 'Q9s 97s JJ TT 88 JTs AJs KJs QJs',
    preferred: 'Check',
    offer: 400,
  ),
  'w15_1_transfer_connected_select': _PilotDailySpotV1(
    Act0DailyDealTemplateV1.continuationTexture,
    'Ac Qs',
    'Td 9d 7c',
    range:
        'J8s T9s 99 77 T8s JTs QJs 88 6c5c 6d5d 6h5h 6s5s KcQc KdQd KhQh KsQs',
    continues: 'J8s T9s 99 77 T8s JTs QJs 88 6d5d KdQd',
    preferred: 'Check',
    offer: 300,
  ),
  'w15_2_guided_protect_overpair': _PilotDailySpotV1(
    Act0DailyDealTemplateV1.continuationTexture,
    'Jc Jd',
    'Th 8s 4c',
    range: 'QTs JTs T9s 88 44 AQs KQs 76s 99 77',
    continues: 'QTs JTs T9s 88 44 99 77 76s',
    preferred: 'Bet',
    offer: 250,
  ),
  'w15_2_transfer_value_or_denial': _PilotDailySpotV1(
    Act0DailyDealTemplateV1.continuationTexture,
    '7h 7d',
    '9s 5d 2c',
    range: 'AJs AJo KQs KQo QJs 99 55 22 88',
    continues: '99 55 22 88',
    preferred: 'Bet',
    offer: 100,
  ),
  'w15_3_transfer_bet_wet_set': _PilotDailySpotV1(
    Act0DailyDealTemplateV1.continuationTexture,
    '9s 9d',
    '9c 8h 6h',
    range:
        'T7s 75s 98s 86s 88 66 AcQc AdQd AhQh AsQs AcJc AdJd AhJh AsJs KcTc KdTd KhTh KsTs 77 65s',
    continues: 'T7s 75s 98s 86s 88 66 77 65s AhQh AhJh KhTh',
    preferred: 'Bet',
    offer: 400,
  ),
  'w15_4_guided_check_monotone': _PilotDailySpotV1(
    Act0DailyDealTemplateV1.continuationTexture,
    'Ac Qd',
    'Jh 8h 3h',
    range:
        'AcKc AdKd AhKh AsKs AcTc AdTd AhTh AsTs KJs QJs 88 33 QcTc QdTd QhTh QsTs Tc9c Td9d Th9h Ts9s 7c6c 7d6d 7h6h 7s6s',
    continues: 'AhKh AhTh KJs QJs 88 33 QhTh Th9h 7h6h',
    preferred: 'Check',
    offer: 500,
  ),
  'w15_4_transfer_paired_high': _PilotDailySpotV1(
    Act0DailyDealTemplateV1.continuationTexture,
    'As Ad',
    'Kc Kd 4h',
    range: 'KQs KJs KTs 44 TT 99 88 AQo QJs 76s',
    continues: 'KQs KJs KTs 44 TT 99 88',
    preferred: 'Bet',
    offer: 200,
  ),
  'w13_2_transfer_second_straight': _PilotDailySpotV1(
    Act0DailyDealTemplateV1.cleanOuts,
    'Td 9s',
    '7d 8h 9c Jd',
    range: 'QTs QTo TT 99 88 76s',
    preferred: 'Call',
    wager: 300,
  ),
  'w13_3_guided_flush_draw_turn': _PilotDailySpotV1(
    Act0DailyDealTemplateV1.cleanOuts,
    'Ah Qh',
    '9c 6h 2h Kd',
    range: 'KQs KQo KJs 99 66 QJs JTs 87s',
    preferred: 'Call',
    wager: 200,
  ),
  'w13_3_transfer_pair_against_value': _PilotDailySpotV1(
    Act0DailyDealTemplateV1.cleanOuts,
    'Qh Js',
    'Qs 9c 6h 2d',
    range: 'AQs AQo KQs KQo 99 66 AJs JTs',
    preferred: 'Fold',
    wager: 400,
  ),
  'w13_5_guided_pair_plus_backdoor': _PilotDailySpotV1(
    Act0DailyDealTemplateV1.cleanOuts,
    'As Qs',
    'Qd 9s 4c',
    range: 'KQs KQo QJs 99 44 AJs KJs JTs T8s',
    preferred: 'Call',
    wager: 200,
  ),
  'w13_5_transfer_backdoor_not_a_call': _PilotDailySpotV1(
    Act0DailyDealTemplateV1.cleanOuts,
    'As 7s',
    'Kd 9s 3c',
    range: 'AKs AKo KQs KQo 99 33 K9s',
    preferred: 'Fold',
    wager: 300,
  ),
  'harder_dirty_flush': _PilotDailySpotV1(
    Act0DailyDealTemplateV1.cleanOuts,
    'Ah 6h',
    'Kh 8h 3c 2d',
    range: 'KsKd',
    preferred: 'Fold',
    wager: 300,
    priorFlopBet: 300,
  ),
  'harder_straight_price_rises': _PilotDailySpotV1(
    Act0DailyDealTemplateV1.cleanOuts,
    '7d 6c',
    '9h 8s 2c Qd',
    range: 'QhQs',
    preferred: 'Fold',
    wager: 650,
    priorFlopBet: 300,
  ),
  'w14_4_guided_spr_price': _PilotDailySpotV1(
    Act0DailyDealTemplateV1.cleanOuts,
    'Ah Kh',
    'Kd Jc 6h',
    layout: _PilotPreflopV1.threeBet,
    range: 'AKs KQs KJs JJ 66 AQs QTs T9s',
    preferred: 'Call',
    wager: 1200,
  ),
  'w17_3_transfer_defend_dry_3bet': _PilotDailySpotV1(
    Act0DailyDealTemplateV1.cleanOuts,
    'Qc Qd',
    'Jh 8s 4c 2d',
    layout: _PilotPreflopV1.threeBet,
    range: 'AA KK JJ 88 AKo AQs',
    preferred: 'Call',
    wager: 600,
  ),
  'w14_3_transfer_small_value_signal': _PilotDailySpotV1(
    Act0DailyDealTemplateV1.riverBluffCatch,
    'Kh Qd',
    'Kc Tc 8s 6d 3h',
    range: 'AKs AKo KTs 88 66 QJs',
    preferred: 'Fold',
    wager: 200,
  ),
  'harder_remove_missed_hearts': _PilotDailySpotV1(
    Act0DailyDealTemplateV1.riverBluffCatch,
    'Kd Qh',
    'Ks 8h 4h 7c 2s',
    range: '88 44 AhJh AhTh QhJh QhTh',
    preferred: 'Fold',
    wager: 700,
    priorFlopBet: 300,
  ),
  'harder_leave_misses_unblocked': _PilotDailySpotV1(
    Act0DailyDealTemplateV1.riverBluffCatch,
    'Ad Jh',
    'As 9c 5c 4d 2s',
    range: '99 55 AcKc KcJc QcJc KcTc',
    preferred: 'Call',
    wager: 800,
    priorFlopBet: 300,
  ),
  'harder_river_value_added': _PilotDailySpotV1(
    Act0DailyDealTemplateV1.riverBluffCatch,
    'Ks Qd',
    'Kh 8d 4c 3s 2c',
    range: '88 44 KJ JTs 76s',
    preferred: 'Call',
    wager: 900,
    priorFlopBet: 300,
  ),
  'harder_paired_river_boats': _PilotDailySpotV1(
    Act0DailyDealTemplateV1.riverBluffCatch,
    'As Qd',
    'Qs 9h 4c 9d 2h',
    range: '99 44 Q9s JTs 76s',
    preferred: 'Call',
    wager: 1000,
    priorFlopBet: 300,
  ),
  'w16_2_guided_bluff_catch_price': _PilotDailySpotV1(
    Act0DailyDealTemplateV1.riverBluffCatch,
    'Ah Jd',
    'Ac 9c 7s 3d 2h',
    range: 'AQo AKo KQs QJs JTs',
    preferred: 'Call',
    wager: 400,
  ),
  'w16_6_guided_scare_card_call': _PilotDailySpotV1(
    Act0DailyDealTemplateV1.riverBluffCatch,
    'Ah Qd',
    'Qs 8s 4d 6h 2s',
    range: 'AsJs KsJs JsTs 88 44 KQo QJo 99',
    preferred: 'Call',
    wager: 500,
    priorFlopBet: 200,
    priorTurnBet: 300,
  ),
  'w16_6_checkpoint_match_the_price': _PilotDailySpotV1(
    Act0DailyDealTemplateV1.riverBluffCatch,
    'Ac Jd',
    'Jh 8c 4s 2d 3c',
    range: 'KJs QJs JTs 88 44 76s',
    preferred: 'Call',
    wager: 1500,
    priorFlopBet: 200,
    priorTurnBet: 300,
  ),
  'w17_6_checkpoint_four_bet_shove': _PilotDailySpotV1(
    Act0DailyDealTemplateV1.lowSpr,
    'As Ks',
    'Th 7d 4s',
    layout: _PilotPreflopV1.fourBet,
    range: 'AA KK QQ JJ AKs',
    preferred: 'Fold',
    wager: 7500,
  ),
  'w14_6_read_induced_raise_price': _PilotDailySpotV1(
    Act0DailyDealTemplateV1.callPrice,
    'Qh Jc',
    'Js 9h 6c 4d 2h',
    wager: 800,
    heroRiverBet: 200,
  ),
  'w18_5_transfer_overcall_price': _PilotDailySpotV1(
    Act0DailyDealTemplateV1.callPrice,
    'Ks Qs',
    'Kh 7d 3c 2h 2s',
    layout: _PilotPreflopV1.multiway,
    wager: 400,
  ),
};

List<_PilotActionV1> _pilotPreflopActionsV1(_PilotPreflopV1 layout) {
  const p = PokerStreet.preflop;
  const fold = Act0HandVerbV1.fold;
  const raise = Act0HandVerbV1.raise;
  const call = Act0HandVerbV1.call;
  final coOpens =
      layout == _PilotPreflopV1.multiway ||
      layout == _PilotPreflopV1.inPositionCaller;
  return [
    (p, 'sb', Act0HandVerbV1.smallBlind, 50),
    (p, 'bb', Act0HandVerbV1.bigBlind, 100),
    (p, 'utg', fold, 0),
    (p, 'hj', fold, 0),
    if (coOpens) ...[
      (p, 'co', raise, 250),
      (p, 'btn', call, 250),
    ] else ...[
      (p, 'co', fold, 0),
      (p, 'btn', raise, 250),
    ],
    (p, 'sb', fold, 0),
    ...switch (layout) {
      _PilotPreflopV1.inPositionCaller => [(p, 'bb', fold, 0)],
      _PilotPreflopV1.threeBet => [
        (p, 'bb', raise, 900),
        (p, 'btn', call, 750),
      ],
      _PilotPreflopV1.fourBet => [
        (p, 'bb', raise, 900),
        (p, 'btn', raise, 2250),
        (p, 'bb', call, 1500),
      ],
      _ => [(p, 'bb', call, 150)],
    },
  ];
}

String _pilotTrailLabelV1(Act0HandActionV1 action) {
  final street = pokerStreetToString(action.street);
  final seat = action.seat.toUpperCase();
  final amount = _act0BbLabelV1(action.chipsAdded / 100);
  final total = _act0BbLabelV1(action.streetTotal / 100);
  return '$street: $seat ${switch (action.verb) {
    Act0HandVerbV1.smallBlind || Act0HandVerbV1.bigBlind => 'posts $amount',
    Act0HandVerbV1.fold => 'folds',
    Act0HandVerbV1.check => 'checks',
    Act0HandVerbV1.call => action.streetTotal > action.chipsAdded ? 'calls $amount more' : 'calls $amount',
    Act0HandVerbV1.bet => action.allIn ? 'shoves $amount' : 'bets $amount',
    Act0HandVerbV1.raise => 'raises to $total',
    _ => throw StateError('Unsupported practice action'),
  }}';
}

Set<(String, String)> _pilotCombosV1(String range, Set<String> known) {
  final tokens = range.split(' ').toSet();
  final available = act0PracticeDeckV1
      .where((card) => !known.contains(card))
      .toList();
  return {
    for (final (i, a) in available.indexed)
      for (final b in available.skip(i + 1))
        if (tokens.contains(a + b) ||
            tokens.contains(b + a) ||
            tokens.contains(
              a[0] +
                  b[0] +
                  (a[0] == b[0]
                      ? ''
                      : a[1] == b[1]
                      ? 's'
                      : 'o'),
            ) ||
            tokens.contains(a[0] + b[0]))
          (a, b),
  };
}

final _pilotShowdownCacheV1 = <_PilotDailySpotV1, List<(double, bool)>>{};

List<(double, bool)> _pilotShowdownsV1(_PilotDailySpotV1 spot) =>
    _pilotShowdownCacheV1.putIfAbsent(spot, () {
      final hero = spot.hero.split(' ');
      final board = spot.board.split(' ');
      final known = {...hero, ...board};
      final continues = _pilotCombosV1(spot.continues, known);
      return [
        for (final (a, b) in _pilotCombosV1(spot.range, known))
          (
            act0PracticeShowdownV1(hero, board, ['$a $b']).share,
            continues.contains((a, b)),
          ),
      ];
    });

_DailyDealContentV1? _pilotDailyDealV1(
  _PilotDailySpotV1 spot,
  math.Random rng,
) {
  final suits = 'shdc'.split('')..shuffle(rng);
  String permute(String cards) => cards.replaceAllMapped(
    RegExp(r'[2-9TJQKA]([shdc])'),
    (match) => match[0]![0] + suits['shdc'.indexOf(match[1]!)],
  );
  final board = permute(spot.board).split(' ');
  final hand = permute(spot.hero);
  final offset = (rng.nextInt(5) - 2) * 25;
  return _pilotDailyVariantV1(spot, board, hand, permute, offset) ??
      (offset == 0
          ? null
          : _pilotDailyVariantV1(spot, board, hand, permute, 0));
}

_DailyDealContentV1? _pilotDailyVariantV1(
  _PilotDailySpotV1 spot,
  List<String> board,
  String hand,
  String Function(String) permute,
  int offset,
) {
  final street = PokerStreet.values[board.length - 2];
  final outOfPosition = spot.layout == _PilotPreflopV1.inPositionCaller;
  final hero = outOfPosition ? 'co' : 'btn';
  final villain = outOfPosition ? 'BTN' : 'BB';
  final isOvercall = spot.layout == _PilotPreflopV1.multiway;
  final isPrice = spot.template == Act0DailyDealTemplateV1.callPrice;
  final isShove = spot.template == Act0DailyDealTemplateV1.lowSpr;
  final isBet = spot.offer > 0;
  final wager = spot.wager + offset;
  final actions = [
    ..._pilotPreflopActionsV1(spot.layout),
    for (final (earlier, bet) in [
      (PokerStreet.flop, spot.priorFlopBet),
      (PokerStreet.turn, spot.priorTurnBet),
    ])
      if (earlier.index < street.index) ...[
        (earlier, 'bb', Act0HandVerbV1.check, 0),
        if (isOvercall) (earlier, 'co', Act0HandVerbV1.check, 0),
        if (bet > 0) ...[
          (earlier, hero, Act0HandVerbV1.bet, bet),
          (earlier, 'bb', Act0HandVerbV1.call, bet),
        ] else
          (earlier, hero, Act0HandVerbV1.check, 0),
      ],
    if (spot.heroRiverBet > 0) ...[
      (street, 'bb', Act0HandVerbV1.check, 0),
      (street, hero, Act0HandVerbV1.bet, spot.heroRiverBet),
      (street, 'bb', Act0HandVerbV1.raise, wager),
    ] else if (spot.wager > 0) ...[
      (street, 'bb', Act0HandVerbV1.bet, wager),
      if (isOvercall) (street, 'co', Act0HandVerbV1.call, wager),
    ] else if (!outOfPosition)
      (street, 'bb', Act0HandVerbV1.check, 0),
  ];
  final prefix = Act0HandTimelineV1.fromDeltas(
    coverage: Act0HandHistoryCoverageV1.complete,
    startingStacks: {
      for (final seat in _day7SeatsV1)
        seat: (seat == 'bb' || seat == hero) && isShove ? 2500 + wager : 10000,
    },
    button: 'btn',
    smallBlind: 50,
    bigBlind: 100,
    board: board,
    actions: [
      for (final (street, seat, verb, chipsAdded) in actions)
        (street: street, seat: seat, verb: verb, chipsAdded: chipsAdded),
    ],
  ).beforeDecision;
  final ledger = prefix.contributions;
  final table = _day7TableV1(
    hero: hero,
    hand: hand,
    street: street,
    actor: hero,
    board: _act0LessonCardsV1(board.join(' ')),
    folded: {
      for (final (_, seat, verb, _) in actions)
        if (verb == Act0HandVerbV1.fold) seat,
    },
    entries: ledger.entries,
    stacks: ledger.startingStackBbBySeat,
    history: [
      for (final action in prefix.events.whereType<Act0HandActionV1>())
        Act0ActionTrailItemV1(label: _pilotTrailLabelV1(action)),
    ],
    bets: {
      for (final action in prefix.events.whereType<Act0HandActionV1>())
        if (action.street == street && action.chipsAdded > 0)
          action.seat: Act0SeatBetStateV1(
            kind: action.allIn
                ? Act0SeatBetKindV1.allIn
                : switch (action.verb) {
                    Act0HandVerbV1.raise => Act0SeatBetKindV1.raise,
                    Act0HandVerbV1.call => Act0SeatBetKindV1.call,
                    _ => Act0SeatBetKindV1.bet,
                  },
            label: action.allIn ? 'All-in' : action.verb.label,
            amountLabel: _act0BbLabelV1(action.streetTotal / 100),
          ),
    },
  ).copyWith(handTimelinePrefix: prefix);

  if (!act0PilotDailyDealTableIsValidV1(table)) return null;
  final (potBb: pot, toCallBb: due) = _dailyDealAmountsV1(table);
  if (isPrice) {
    return _dailyPriceAnswerV1(
      table,
      due! / pot,
      question: isOvercall
          ? 'What showdown share covers the overcall?'
          : 'What win rate covers the rest of your call?',
      premise: isOvercall
          ? 'BB bet and CO called. Assume a single pot and no more betting.'
          : 'BB raised after your river bet. Include only what you still owe.',
    );
  }
  final showdowns = _pilotShowdownsV1(spot);
  if (showdowns.isEmpty) return null;
  final equity =
      showdowns.fold<double>(0, (sum, row) => sum + row.$1) / showdowns.length;
  if (isBet) {
    final bet = (spot.offer + offset) / 100;
    final checkEv = equity * pot;
    final betEv =
        showdowns.fold<double>(
          0,
          (sum, row) =>
              sum +
              act0PracticeBetPayoffV1(
                equity: row.$1,
                pot: pot,
                bet: bet,
                folds: !row.$2,
              ),
        ) /
        showdowns.length;
    if ((betEv - checkEv).abs() < .05 ||
        (betEv > checkEv ? 'Bet' : 'Check') != spot.preferred)
      return null;
    final betLabel = 'Bet ${_act0BbLabelV1(bet)}';
    final best = betEv > checkEv;
    final reason =
        'Betting averages ${betEv.toStringAsFixed(2)} BB. '
        'Checking averages ${checkEv.toStringAsFixed(2)} BB.';
    return (
      table: table,
      question: 'Which play earns more under this response model?',
      premise:
          '$villain holds one legal combination from ${permute(spot.range)}, '
          'all equally likely. To a ${_act0BbLabelV1(bet)} bet, $villain calls with '
          '${permute(spot.continues)} and folds the rest. No further betting after a check or call.',
      preferred: best ? betLabel : 'Check',
      alternative: best ? 'Check' : betLabel,
      explanation: reason,
      correction: reason,
    );
  }
  if (due == null || due <= 0) return null;
  final price = act0CallPriceV1(pot, due)!.equity;
  final edge = equity * (pot + due) - due;
  final preferred = edge > 0 ? 'Call' : 'Fold';
  if (edge.abs() < .05 ||
      preferred != spot.preferred ||
      _dailyPctV1(equity) == _dailyPctV1(price))
    return null;
  final reason =
      'Your showdown share is ${_dailyPctV1(equity)}. '
      'Calling needs ${_dailyPctV1(price)}. $preferred.';
  final context = isShove
      ? 'After the preflop 4-bet, effective SPR was ${(due / (pot - due)).toStringAsFixed(2)}. '
      : '';
  return (
    table: table,
    question: 'Call or fold in this model?',
    premise:
        '${context}BB bets one legal combination from ${permute(spot.range)}, '
        'all equally likely. After a call, go to showdown with no more bets.',
    preferred: preferred,
    alternative: preferred == 'Call' ? 'Fold' : 'Call',
    explanation: reason,
    correction: reason,
  );
}

/// Every pilot rep must carry a complete, legal decision prefix consistent
/// with the displayed C1 stack, pot, price and board.
bool act0PilotDailyDealTableIsValidV1(Act0TableStateV1 table) {
  final prefix = table.handTimelinePrefix;
  final hero = table.heroSeatId;
  final ledger = table.handContributions;
  if (prefix == null ||
      ledger == null ||
      hero == null ||
      prefix.coverage != Act0HandHistoryCoverageV1.complete ||
      prefix.street != ledger.throughStreet ||
      prefix.decisionError(hero) != null ||
      table.heroCards.length != 2 ||
      table.boardCards.map((card) => card.label).join(' ') !=
          prefix.board.join(' '))
    return false;
  final actions = prefix.events.whereType<Act0HandActionV1>().toList();
  if (table.actionTrail.length != actions.length ||
      actions.indexed.any(
        (entry) =>
            table.actionTrail[entry.$1].learnerLabel !=
            _pilotTrailLabelV1(entry.$2),
      )) {
    return false;
  }
  final seats = table.seats.map((seat) => seat.seatId).toSet();
  final expected = prefix.contributions;
  try {
    final amounts = ledger.amounts(seatIds: seats, actorSeatId: hero);
    final due = amounts.toCallBb;
    return due != null &&
        amounts == expected.amounts(seatIds: seats, actorSeatId: hero) &&
        table.potLabel == 'Pot ${_act0BbLabelV1(amounts.potBb)}' &&
        table.toCallLabel ==
            (due == 0 ? '' : 'To call ${_act0BbLabelV1(due)}') &&
        table.seats.every((seat) {
          final stack = expected.startingStackBbBySeat[seat.seatId];
          final invested = expected.entries
              .where((row) => row.seatId == seat.seatId)
              .fold<double>(0, (sum, row) => sum + row.amountBb);
          return stack != null &&
              seat.stackLabel == _act0BbLabelV1(stack - invested);
        });
  } on FormatException {
    return false;
  }
}

part of 'act0_shell_state_v1.dart';

Act0TableStateV1 _y5dRiverAllInV1(
  String hero,
  String hand,
  String board, {
  required double openBb,
  required double betBb,
}) {
  final base = _day7PostflopV1(
    hero,
    hand,
    board,
    openBb: openBb,
    betBb: betBb,
    showTurn: true,
  );
  return _day7TableV1(
    hero: hero,
    hand: hand,
    street: PokerStreet.river,
    actor: hero,
    folded: _day7SeatsV1.where((seat) => seat != hero && seat != 'bb').toSet(),
    board: base.boardCards,
    entries: base.handContributions!.entries,
    history: [
      ...base.actionTrail.take(base.actionTrail.length - 1),
      Act0ActionTrailItemV1(label: 'River: BB all-in ${_act0BbLabelV1(betBb)}'),
    ],
    bets: {
      'bb': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.allIn,
        label: 'All-in',
        amountLabel: _act0BbLabelV1(betBb),
      ),
    },
    stacks: {'bb': openBb + betBb},
  );
}

Act0LessonTaskV1 _y5dPracticeV1(
  int world,
  String lesson,
  String id,
  String title,
  Act0TableStateV1 table, {
  required String caption,
  required String question,
  required List<String> choices,
  required int correct,
  required String reason,
  required Map<int, String> wrongReasons,
  String guidance = '',
}) {
  final runner = _day7ExampleV1(
    world,
    lesson,
    id,
    table,
    caption: caption,
    question: question,
    choices: choices,
    correct: correct,
    reason: reason,
    wrongReasons: wrongReasons,
  ).task.runner;
  return Act0LessonTaskV1(
    taskId: id,
    title: title,
    phase: Act0LessonPhaseV1.drill,
    rewardXp: 8,
    runner: guidance.isEmpty
        ? runner
        : runner.copyWith(hint: guidance, hintPolicy: Act0HintPolicyV1.always),
  );
}

final _w11Y5dSessionPlanV1 = [
  _y5dPracticeV1(
    11,
    'session_plan_basics',
    'w11_y5d_stop_after_three',
    'Session stop-loss',
    _act0HypotheticalConceptTableV1(
      _w11SessionPlanBasicsTasksV1.first.runner.table,
    ),
    caption:
        'Your session plan says to stop after losing three buy-ins. You are down three, and a new hand is about to start.',
    question: 'What follows your session plan?',
    choices: const [
      'End the session',
      'Play until one buy-in returns',
      'Move up one limit',
    ],
    correct: 0,
    reason:
        'Three buy-ins gone meets your stop-loss. End the session now. Playing for one buy-in back replaces your plan with a recovery target.',
    wrongReasons: const {
      1: 'Playing to recover a buy-in can deepen the loss. Three buy-ins lost already triggers the stop.',
      2: 'Moving up makes each loss cost more. End the session at the planned stop.',
    },
  ),
  _y5dPracticeV1(
    11,
    'session_plan_basics',
    'w11_y5d_stay_at_nl10',
    'Choose a stake for the session',
    _act0HypotheticalConceptTableV1(
      _w11SessionPlanBasicsTasksV1.first.runner.table,
    ),
    caption:
        'Your bankroll is \$475. A full buy-in costs \$10 at NL10 and \$25 at NL25. '
        'Move up when you have $act0CashBankrollBuyInsV1 buy-ins for the next stake. '
        'Move down below $act0CashBankrollBuyInsV1 buy-ins at the current stake.',
    question: 'Which stake fits your bankroll rule?',
    choices: const ['Stay at NL10', 'Move up to NL25', 'Move down to NL5'],
    correct: 0,
    reason:
        'Stay at NL10. Your \$475 buys 47.5 full buy-ins, above the '
        '$act0CashBankrollBuyInsV1-buy-in floor. Moving up to NL25 requires \$${act0CashBankrollBuyInsV1 * 25}.',
    wrongReasons: const {
      1:
          'At NL25, \$475 buys 19 full buy-ins. Wait until you have '
          '\$${act0CashBankrollBuyInsV1 * 25} before moving up.',
      2:
          'Move down from NL10 only below \$${act0CashBankrollBuyInsV1 * 10}. '
          'Your \$475 still covers the $act0CashBankrollBuyInsV1-buy-in floor.',
    },
  ),
  _y5dPracticeV1(
    11,
    'session_plan_basics',
    'w11_y5d_top_up_to_100',
    'Top up between hands',
    _act0HypotheticalConceptTableV1(
      _w11SessionPlanBasicsTasksV1.first.runner.table,
    ),
    caption:
        'Topping up means adding chips between hands. Your plan is to stay at 100 BB when the table allows it. After the hand your stack is 73 BB and your session stop has not been reached.',
    question: 'What action follows your 100 BB session plan?',
    choices: const ['Add 27 BB', 'Add 73 BB', 'Add nothing'],
    correct: 0,
    reason:
        'You have 73 BB left. Add 27 BB to start the next hand with 100 BB. Keeping 73 BB cuts the stack you can play against a deep opponent.',
    wrongReasons: const {
      1: 'Adding 73 BB would put 146 BB at the table. Your target leaves just 27 BB to add.',
      2: 'With no top-up you start at 73 BB. Add the 27 BB difference while the table allows it.',
    },
  ),
];

Act0TableStateV1 _w11Y5dSidePotTableV1() {
  const street = PokerStreet.turn;
  const hand = 'Qc Qd';
  final board = _act0LessonCardsV1('Js 8d 4h 2c');
  return _day7TableV1(
    hero: 'btn',
    hand: hand,
    street: street,
    actor: 'btn',
    board: board,
    folded: {'utg', 'co', 'sb'},
    shown: {
      'bb': _act0LessonCardsV1('8c 8s'),
      'hj': _act0LessonCardsV1('Jd Tc'),
    },
    stacks: {'bb': 6, 'hj': 30, 'btn': 40},
    entries: [
      ..._act0LessonBlinds,
      const Act0ContributionV1(
        PokerStreet.preflop,
        'hj',
        Act0ContributionKindV1.wager,
        3,
      ),
      const Act0ContributionV1(
        PokerStreet.preflop,
        'btn',
        Act0ContributionKindV1.wager,
        3,
      ),
      const Act0ContributionV1(
        PokerStreet.preflop,
        'bb',
        Act0ContributionKindV1.wager,
        2,
      ),
      const Act0ContributionV1(street, 'bb', Act0ContributionKindV1.wager, 3),
      const Act0ContributionV1(street, 'hj', Act0ContributionKindV1.wager, 9),
    ],
    history: const [
      Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
      Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
      Act0ActionTrailItemV1(label: 'UTG folds'),
      Act0ActionTrailItemV1(label: 'HJ raises to 3 BB'),
      Act0ActionTrailItemV1(label: 'CO folds'),
      Act0ActionTrailItemV1(label: 'BTN calls 3 BB'),
      Act0ActionTrailItemV1(label: 'SB folds'),
      Act0ActionTrailItemV1(label: 'BB calls 2 BB more'),
      Act0ActionTrailItemV1(label: 'Flop: BB checks'),
      Act0ActionTrailItemV1(label: 'HJ checks'),
      Act0ActionTrailItemV1(label: 'BTN checks'),
      Act0ActionTrailItemV1(label: 'Turn: BB all-in 3 BB'),
      Act0ActionTrailItemV1(label: 'HJ raises to 9 BB'),
    ],
    bets: const {
      'bb': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.allIn,
        label: 'All-in',
        amountLabel: '3 BB',
      ),
      'hj': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.raise,
        label: 'Raise',
        amountLabel: '9 BB',
      ),
    },
  );
}

final _w11Y5dSidePotV1 = _y5dPracticeV1(
  11,
  'post_session_review_loop',
  'w11_y5d_two_pot_call',
  'The short stack cannot win the side pot',
  _w11Y5dSidePotTableV1(),
  caption:
      'A side pot is a separate pot for players who can match the extra bet. HJ means hijack. That player holds a pair of jacks. BB is all-in for 3 BB with a set and HJ raises to 9 BB. Every remaining river card is equally likely and nobody bets after a call.',
  question: 'Call 9 BB or fold?',
  choices: const ['Call', 'Fold'],
  correct: 0,
  reason:
      'BB bets all-in with a set and can only win the main pot. HJ raises with jacks, giving your queens 37 of 42 side-pot wins. Calling 9 BB gains about 2.45 BB over folding.',
  wrongReasons: const {
    1: 'Folding gives up about 2.45 BB. BB can win only the main pot, and your queens beat HJ for the side pot on 37 of 42 rivers.',
  },
  guidance: 'Ask which opponents can win each pot after you call.',
);

Act0LessonTaskV1 _y5dRiverReadV1(
  int world,
  String lesson,
  String id,
  String title,
  String hand,
  String board, {
  required double open,
  required double bet,
  required int bluffs,
  required String guidance,
}) {
  final potAfterCall = 2 * open + .5 + 2 * bet;
  final cutoff = bet / potAfterCall;
  final calls = bluffs / 100 > cutoff;
  final price = (100 * cutoff).toStringAsFixed(1);
  final edge = (bluffs / 100 * potAfterCall - bet).abs().toStringAsFixed(2);
  return _y5dPracticeV1(
    world,
    lesson,
    id,
    title,
    _y5dRiverAllInV1('co', hand, board, openBb: open, betBb: bet),
    caption:
        'In this exercise, BB is all-in for ${_act0BbLabelV1(bet)}. Missed draws you beat are $bluffs% of the bets; sets are ${100 - bluffs}%. No ties.',
    question: guidance.isEmpty
        ? 'Call or fold?'
        : 'How does the bluff share compare with your call price?',
    choices: guidance.isEmpty
        ? const ['Call', 'Fold']
        : const ['Above the call price', 'Below the call price'],
    correct: calls ? 0 : 1,
    reason:
        'BB bets ${_act0BbLabelV1(bet)} all-in with missed draws $bluffs% of the time, ${calls ? 'above' : 'below'} the $price% price. ${calls ? 'Call because it earns $edge BB more than a fold' : 'Fold because a call loses $edge BB'}.',
    wrongReasons: {
      (calls ? 1 : 0): calls
          ? 'Folding gives up $edge BB because BB bluffs often enough to clear the $price% call price.'
          : 'Calling loses $edge BB because BB bets too few missed draws to clear the $price% price.',
    },
    guidance: guidance,
  );
}

final _w11Y5dRiverReadsV1 = [
  _y5dRiverReadV1(
    11,
    'post_session_review_loop',
    'w11_y5d_guided_river_read',
    'Read the river bettor',
    'Ah Jc',
    'As 8h 5h 4d 2s',
    open: 3.25,
    bet: 5,
    bluffs: 40,
    guidance:
        'Find the share of misses that your pair beats. Compare it with the price of a call.',
  ),
  _y5dRiverReadV1(
    11,
    'post_session_review_loop',
    'w11_y5d_river_read_transfer',
    'A bettor with fewer bluffs',
    'Kd Tc',
    'Kc 9d 6d 5h 2c',
    open: 3.5,
    bet: 6,
    bluffs: 15,
    guidance: '',
  ),
];

final _w12Y5dRiverReadsV1 = [
  _y5dRiverReadV1(
    12,
    'confidence_river_discipline',
    'w12_y5d_guided_range_read',
    'Use the bettor’s range',
    'Qd Jc',
    'Qs 9s 3h 5c 2d',
    open: 3,
    bet: 6,
    bluffs: 18,
    guidance:
        'Compare the hands you beat with the amount you still owe. Use the model shown before you act.',
  ),
  _y5dRiverReadV1(
    12,
    'confidence_river_discipline',
    'w12_y5d_range_read_transfer',
    'Same decision process in a new hand',
    'Ad Th',
    'As 9h 7h 4d 2c',
    open: 3.5,
    bet: 5,
    bluffs: 35,
    guidance: '',
  ),
];

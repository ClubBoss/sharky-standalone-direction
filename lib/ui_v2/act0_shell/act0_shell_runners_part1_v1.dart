part of 'act0_shell_state_v1.dart';

const _unknownHoleCards = <Act0CardStateV1>[
  Act0CardStateV1(rank: '?', suit: ''),
  Act0CardStateV1(rank: '?', suit: ''),
];

const _heroKtCards = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'K', suit: 's'),
  Act0CardStateV1(rank: 'T', suit: 's'),
];

const _heroAkCards = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'A', suit: 's'),
  Act0CardStateV1(rank: 'K', suit: 'd', tone: Act0CardToneV1.red),
];

const _heroQqCards = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'Q', suit: 'h', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: 'Q', suit: 's'),
];

const _heroQdQsCards = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'Q', suit: 'd', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: 'Q', suit: 's'),
];

const _heroA7oCards = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'A', suit: 's'),
  Act0CardStateV1(rank: '7', suit: 'd', tone: Act0CardToneV1.red),
];

const _heroAs7sCards = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'A', suit: 's'),
  Act0CardStateV1(rank: '7', suit: 's'),
];

const _hero7s7hCards = <Act0CardStateV1>[
  Act0CardStateV1(rank: '7', suit: 's'),
  Act0CardStateV1(rank: '7', suit: 'h', tone: Act0CardToneV1.red),
];

const _heroAjCards = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'A', suit: 's'),
  Act0CardStateV1(rank: 'J', suit: 'd', tone: Act0CardToneV1.red),
];

const _heroAJsCards = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'A', suit: 's'),
  Act0CardStateV1(rank: 'J', suit: 's'),
];

const _heroQJsCards = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'Q', suit: 's'),
  Act0CardStateV1(rank: 'J', suit: 's'),
];

const _flopA72Cards = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'A', suit: 'h', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: '7', suit: 'c'),
  Act0CardStateV1(rank: '2', suit: 'd', tone: Act0CardToneV1.red),
];

const _smallBlindPost = Act0SeatBetStateV1(
  kind: Act0SeatBetKindV1.post,
  label: 'SB',
  amountLabel: '0.5 BB',
);

List<Act0CardStateV1> _w7VisibleBoardCardsForSpecV1(
  Act0W7VisibleAceHiddenTaskSpecV1 spec,
) {
  switch (spec.taskId) {
    case 'visible_ace_combo_reduction_intro':
      return _flopA72Cards;
    case 'visible_king_combo_reduction_intro':
      return const <Act0CardStateV1>[
        Act0CardStateV1(rank: 'K', suit: 'h', tone: Act0CardToneV1.red),
        Act0CardStateV1(rank: '8', suit: 'c'),
        Act0CardStateV1(rank: '4', suit: 'd', tone: Act0CardToneV1.red),
      ];
    case 'paired_board_texture_lite_intro':
      return const <Act0CardStateV1>[
        Act0CardStateV1(rank: '7', suit: 'h', tone: Act0CardToneV1.red),
        Act0CardStateV1(rank: '7', suit: 'c'),
        Act0CardStateV1(rank: '2', suit: 'd', tone: Act0CardToneV1.red),
      ];
    case 'visible_card_combo_density_transfer_check':
      return const <Act0CardStateV1>[
        Act0CardStateV1(rank: 'Q', suit: 'h', tone: Act0CardToneV1.red),
        Act0CardStateV1(rank: 'J', suit: 'c'),
        Act0CardStateV1(rank: '5', suit: 'd', tone: Act0CardToneV1.red),
      ];
    default:
      return _flopA72Cards;
  }
}

const _bigBlindPost = Act0SeatBetStateV1(
  kind: Act0SeatBetKindV1.post,
  label: 'BB',
  amountLabel: '1 BB',
);

const _hjBet1Bb = Act0SeatBetStateV1(
  kind: Act0SeatBetKindV1.bet,
  label: 'HJ',
  amountLabel: '1 BB',
);

const _hjBet2Bb = Act0SeatBetStateV1(
  kind: Act0SeatBetKindV1.bet,
  label: 'HJ',
  amountLabel: '2 BB',
);

const _hjOpen25Bb = Act0SeatBetStateV1(
  kind: Act0SeatBetKindV1.raise,
  label: 'HJ',
  amountLabel: '2.5 BB',
);

const _coOpen25Bb = Act0SeatBetStateV1(
  kind: Act0SeatBetKindV1.raise,
  label: 'CO',
  amountLabel: '2.5 BB',
);

const _btnRaise3Bb = Act0SeatBetStateV1(
  kind: Act0SeatBetKindV1.raise,
  label: 'BTN',
  amountLabel: '3 BB',
);

const _btnBet2Bb = Act0SeatBetStateV1(
  kind: Act0SeatBetKindV1.bet,
  label: 'BTN',
  amountLabel: '2 BB',
);

const _heroKqCards = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'K', suit: 'd'),
  Act0CardStateV1(rank: 'Q', suit: 'c'),
];

const _villainKqCards = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'K', suit: 'c'),
  Act0CardStateV1(rank: 'Q', suit: 'h', tone: Act0CardToneV1.red),
];

const _villainK8Cards = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'K', suit: 'c'),
  Act0CardStateV1(rank: '8', suit: 's'),
];

const _heroA5Cards = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'A', suit: 'c'),
  Act0CardStateV1(rank: '5', suit: 'd', tone: Act0CardToneV1.red),
];

const _villainK4Cards = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'K', suit: 's'),
  Act0CardStateV1(rank: '4', suit: 'c'),
];

const _boardK7294Cards = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'K', suit: 'h', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: '7', suit: 'c'),
  Act0CardStateV1(rank: '2', suit: 'd', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: '9', suit: 's'),
  Act0CardStateV1(rank: '4', suit: 'c'),
];

const _boardJ8822Cards = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'J', suit: 'h', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: '8', suit: 'c'),
  Act0CardStateV1(rank: '8', suit: 'd', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: '2', suit: 's'),
  Act0CardStateV1(rank: '2', suit: 'c'),
];

const _boardBroadwayCards = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'A', suit: 'h', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: 'K', suit: 'd', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: 'Q', suit: 'c'),
  Act0CardStateV1(rank: 'J', suit: 's'),
  Act0CardStateV1(rank: 'T', suit: 'h', tone: Act0CardToneV1.red),
];

const _boardJ74FlopCards = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'J', suit: 'h', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: '7', suit: 'c'),
  Act0CardStateV1(rank: '4', suit: 'd', tone: Act0CardToneV1.red),
];

const _boardJ742TurnCards = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'J', suit: 'h', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: '7', suit: 'c'),
  Act0CardStateV1(rank: '4', suit: 'd', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: '2', suit: 's'),
];

const _boardA84TwoToneCards = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'A', suit: 'h', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: '8', suit: 'h', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: '4', suit: 'c'),
];

const _heroKhQhCards = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'K', suit: 'h', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: 'Q', suit: 'h', tone: Act0CardToneV1.red),
];

const _boardFlushHearts = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'A', suit: 'h', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: '7', suit: 'h', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: '2', suit: 'h', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: 'J', suit: 'c'),
  Act0CardStateV1(rank: '4', suit: 'd', tone: Act0CardToneV1.red),
];

const _boardFlushVsStraight = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'A', suit: 'h', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: '7', suit: 'h', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: '2', suit: 'h', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: 'J', suit: 'c'),
  Act0CardStateV1(rank: 'T', suit: 'd', tone: Act0CardToneV1.red),
];

const _boardTripsAces = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'A', suit: 'h', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: 'A', suit: 'd', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: 'A', suit: 'c'),
  Act0CardStateV1(rank: '2', suit: 'c'),
  Act0CardStateV1(rank: '4', suit: 'd', tone: Act0CardToneV1.red),
];

const _boardFullHouseVsFlush = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'A', suit: 'h', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: 'A', suit: 'd', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: '7', suit: 'h', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: '2', suit: 'h', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: '2', suit: 'c'),
];

const _boardQuadsQueens = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'Q', suit: 'c'),
  Act0CardStateV1(rank: 'Q', suit: 'd', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: '7', suit: 'c'),
  Act0CardStateV1(rank: '2', suit: 'd', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: 'J', suit: 'c'),
];

const _boardQuadsVsFullHouse = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'Q', suit: 'c'),
  Act0CardStateV1(rank: 'Q', suit: 'd', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: '7', suit: 'c'),
  Act0CardStateV1(rank: '7', suit: 'd', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: '2', suit: 's'),
];

const _boardRoyalFlushHearts = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'A', suit: 'h', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: 'J', suit: 'h', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: 'T', suit: 'h', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: '2', suit: 'c'),
  Act0CardStateV1(rank: '4', suit: 'd', tone: Act0CardToneV1.red),
];

const _boardThreeQueens = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'Q', suit: 'c'),
  Act0CardStateV1(rank: '7', suit: 'c'),
  Act0CardStateV1(rank: '2', suit: 'd', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: 'J', suit: 'c'),
  Act0CardStateV1(rank: '4', suit: 's'),
];

const _opponentAh7hCards = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'A', suit: 'h', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: '7', suit: 'h', tone: Act0CardToneV1.red),
];

const _opponentJd7hCards = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'J', suit: 'd', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: '7', suit: 'h', tone: Act0CardToneV1.red),
];

const _opponent8c9sCards = <Act0CardStateV1>[
  Act0CardStateV1(rank: '8', suit: 'c'),
  Act0CardStateV1(rank: '9', suit: 's'),
];

const _opponentKhQhCards = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'K', suit: 'h', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: 'Q', suit: 'h', tone: Act0CardToneV1.red),
];

const _opponentAc7hCards = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'A', suit: 'c'),
  Act0CardStateV1(rank: '7', suit: 'h', tone: Act0CardToneV1.red),
];

const _opponent9h3hCards = <Act0CardStateV1>[
  Act0CardStateV1(rank: '9', suit: 'h', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: '3', suit: 'h', tone: Act0CardToneV1.red),
];
const _hero89Cards = <Act0CardStateV1>[
  Act0CardStateV1(rank: '8', suit: 'h', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: '9', suit: 's'),
];

const _boardStraight = <Act0CardStateV1>[
  Act0CardStateV1(rank: '5', suit: 'd', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: '6', suit: 'c'),
  Act0CardStateV1(rank: '7', suit: 's'),
  Act0CardStateV1(rank: 'J', suit: 'h', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: 'Q', suit: 'd', tone: Act0CardToneV1.red),
];

const _opponentKhJhCards = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'K', suit: 'h', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: 'J', suit: 'h', tone: Act0CardToneV1.red),
];

const _boardAce = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'A', suit: 'c'),
  Act0CardStateV1(rank: '7', suit: 'c'),
  Act0CardStateV1(rank: '2', suit: 'd', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: 'J', suit: 'c'),
  Act0CardStateV1(rank: '4', suit: 's'),
];

const _heroAsKhCards = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'A', suit: 's'),
  Act0CardStateV1(rank: 'K', suit: 'h', tone: Act0CardToneV1.red),
];

const _opponentAdQdCards = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'A', suit: 'd', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: 'Q', suit: 'd', tone: Act0CardToneV1.red),
];

const _boardRoyalFlush = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'A', suit: 's'),
  Act0CardStateV1(rank: 'K', suit: 's'),
  Act0CardStateV1(rank: 'Q', suit: 's'),
  Act0CardStateV1(rank: 'J', suit: 's'),
  Act0CardStateV1(rank: 'T', suit: 's'),
];

const _heroQcQdCards = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'Q', suit: 'c'),
  Act0CardStateV1(rank: 'Q', suit: 'd', tone: Act0CardToneV1.red),
];

const _meetTableRunner = Act0RunnerStateV1(
  lessonId: 'meet_table',
  lessonTitle: 'Meet the table',
  lessonSubtitle: 'Find the Button, blinds, pot, and your seat.',
  beatIndex: 1,
  beatCount: 8,
  phase: Act0LessonPhaseV1.theory,
  caption: 'Your cards are at the bottom. Follow the action around the table.',
  hint:
      'Before the flop, action moves from early seats toward BTN, then the blinds.',
  question: 'UTG, HJ, and CO have acted before the flop. Which seat acts next?',
  options: <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'top',
      label: 'UTG',
      seatId: 'utg',
      isCorrect: false,
      preferredLabel: 'BTN',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason: 'UTG acts before HJ, CO, and BTN in preflop order.',
    ),
    Act0RunnerOptionV1(
      id: 'bottom',
      label: 'BTN',
      seatId: 'btn',
      isCorrect: true,
      preferredLabel: 'BTN',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Action order found!',
      feedbackReason: 'After UTG, HJ, and CO, BTN acts before SB and BB.',
    ),
    Act0RunnerOptionV1(
      id: 'random',
      label: 'BB',
      seatId: 'bb',
      isCorrect: false,
      preferredLabel: 'BTN',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'BB acts after BTN before the flop, so it is not next here.',
    ),
  ],
  feedbackTitle: 'Sharp read.',
  feedbackReason:
      'The order around the table matters: BTN acts after CO and before the blinds preflop.',
  primaryCtaLabel: 'Continue',
  nextLessonId: 'what_you_can_do',
  returnTarget: 'learn',
  table: Act0TableStateV1(
    scope: Act0TableScopeV1.orientation,
    tableFormat: Act0TableFormatV1.sixMax,
    playerCount: 6,
    seats: <Act0SeatStateV1>[
      Act0SeatStateV1(
        seatId: 'utg',
        seatLabel: 'UTG',
        displayName: 'Seat',
        holeCards: _unknownHoleCards,
      ),
      Act0SeatStateV1(
        seatId: 'hj',
        seatLabel: 'HJ',
        displayName: 'Seat',
        holeCards: _unknownHoleCards,
      ),
      Act0SeatStateV1(seatId: 'co', seatLabel: 'CO', displayName: 'Cutoff'),
      Act0SeatStateV1(
        seatId: 'btn',
        seatLabel: 'BTN',
        displayName: 'Hero',
        isHero: true,
        isDealerButton: true,
        isTarget: true,
        stackLabel: '100 BB',
        cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
      ),
      Act0SeatStateV1(
        seatId: 'sb',
        seatLabel: 'SB',
        displayName: 'Small blind',
        isSmallBlind: true,
        blindAmountLabel: '0.5 BB',
        currentBetLabel: '0.5 BB',
        bet: _smallBlindPost,
        holeCards: _unknownHoleCards,
      ),
      Act0SeatStateV1(
        seatId: 'bb',
        seatLabel: 'BB',
        displayName: 'Big blind',
        isBigBlind: true,
        blindAmountLabel: '1 BB',
        currentBetLabel: '1 BB',
        bet: _bigBlindPost,
        holeCards: _unknownHoleCards,
      ),
    ],
    heroCards: <Act0CardStateV1>[],
    boardCards: <Act0CardStateV1>[],
    streetLabel: 'Preflop',
    potLabel: 'Pot 1.5 BB',
    toCallLabel: '',
    centerLabel: 'Blinds posted',
    emptyBoardLabel: 'No board cards yet',
    actionTrail: <Act0ActionTrailItemV1>[
      Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
      Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
    ],
    heroSeatId: 'btn',
    highlightedSeatIds: <String>['btn', 'sb', 'bb'],
    highlightedCardIds: <String>[],
    selectableSeatIds: <String>['utg', 'btn', 'bb'],
    instructionAnchor: 'hero',
  ),
  teachingSteps: <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'We start with Hold\'em cash.',
      body:
          'Each player gets 2 private hole cards. The table shares 5 community cards. You build the best 5-card hand from those 7. This course starts with No-Limit Hold\'em cash, where chip values stay stable hand to hand.',
      focusLabels: <String>[
        '2 hole cards',
        'Cash vs tournament',
        'Stable value',
      ],
    ),
    Act0TeachingStepV1(
      title: 'This is a poker table.',
      body:
          'BTN is your button seat. SB and BB are the blind seats. UTG, HJ, and CO are the other positions.',
      focusSeatIds: <String>['btn', 'hj', 'sb', 'bb'],
      focusLabels: <String>['Hero', 'Opponents'],
      identityTeachingSemantics: Act0TableIdentityTeachingSemanticsV1.position,
    ),
    Act0TeachingStepV1(
      title: 'The goal is the pot.',
      body: 'Players put chips in the middle. The winner takes that pot.',
      focusSeatIds: <String>['sb', 'bb'],
      focusLabels: <String>['Pot', 'Blinds create it'],
    ),
    Act0TeachingStepV1(
      title: 'Blinds start the hand.',
      body:
          'SB posts 0.5 BB and BB posts 1 BB before anyone chooses. The blinds appear before the first decision, and the hole cards stay hidden so you can read the table cleanly.',
      focusSeatIds: <String>['sb', 'bb'],
      focusLabels: <String>['SB 0.5', 'BB 1', 'Cards hidden first'],
    ),
  ],
);

const _raisesThePriceChoices = <Act0RunnerOptionV1>[
  Act0RunnerOptionV1(
    id: 'fold',
    label: 'Fold',
    isCorrect: false,
    preferredLabel: 'Raise',
    betterAnswerLabel: 'Raise',
    quality: Act0FeedbackQualityV1.wrong,
    feedbackTitle: 'Not quite.',
    feedbackReason:
        'Folding gives up the hand without adding chips. It does not change what the next player needs to call.',
    repairFocusSeatIds: <String>['btn', 'sb', 'bb'],
    repairFocusCardIds: <String>['hero_0', 'hero_1'],
    repairFocusLabels: <String>['Your turn', 'Blinds posted', 'KTs'],
  ),
  Act0RunnerOptionV1(
    id: 'call',
    label: 'Call',
    amountLabel: '1 BB',
    isCorrect: false,
    preferredLabel: 'Raise',
    betterAnswerLabel: 'Raise',
    quality: Act0FeedbackQualityV1.wrong,
    feedbackTitle: 'Calling matches the blind.',
    feedbackReason:
        'Calling puts in 1 BB and matches the blind. Raising to 3 BB sets a higher price for the next player.',
    repairFocusSeatIds: <String>['btn', 'sb', 'bb'],
    repairFocusCardIds: <String>['hero_0', 'hero_1'],
    repairFocusLabels: <String>[
      'Matches 1 BB',
      'Sets a higher price',
      'Button',
    ],
  ),
  Act0RunnerOptionV1(
    id: 'raise',
    label: 'Raise',
    amountLabel: '3 BB',
    isCorrect: true,
    preferredLabel: 'Raise',
    quality: Act0FeedbackQualityV1.correct,
    feedbackTitle: 'Strong choice.',
    feedbackReason: 'Raising to 3 BB increases the price above the 1 BB blind.',
    repairFocusSeatIds: <String>['btn'],
    repairFocusCardIds: <String>['hero_0', 'hero_1'],
    repairFocusLabels: <String>['Button raise', 'Your turn'],
  ),
];

const _whatYouCanDoRunner = Act0RunnerStateV1(
  lessonId: 'what_you_can_do',
  lessonTitle: 'What you can do',
  lessonSubtitle: 'Use fold, call, and raise from one clear table spot.',
  beatIndex: 2,
  beatCount: 8,
  phase: Act0LessonPhaseV1.theory,
  caption: 'You are on the Button with KTs.',
  hint: 'Compare how many chips each action adds to the pot.',
  question: 'Which action increases the price above the big blind?',
  options: _raisesThePriceChoices,
  feedbackTitle: 'Solid understanding.',
  feedbackReason:
      'Raising sets a higher price. Calling pays the price already set.',
  primaryCtaLabel: 'Continue',
  nextLessonId: 'read_board',
  returnTarget: 'learn',
  table: Act0TableStateV1(
    scope: Act0TableScopeV1.playedHand,
    tableFormat: Act0TableFormatV1.sixMax,
    playerCount: 6,
    seats: <Act0SeatStateV1>[
      Act0SeatStateV1(
        seatId: 'utg',
        seatLabel: 'UTG',
        displayName: 'Seat',
        isInHand: false,
        isFolded: true,
        hasActed: true,
        cardsVisibleMode: Act0CardsVisibleModeV1.none,
      ),
      Act0SeatStateV1(
        seatId: 'hj',
        seatLabel: 'HJ',
        displayName: 'Seat',
        isFolded: true,
        isInHand: false,
        hasActed: true,
        holeCards: _unknownHoleCards,
      ),
      Act0SeatStateV1(
        seatId: 'co',
        seatLabel: 'CO',
        displayName: 'Cutoff',
        isFolded: true,
        isInHand: false,
        hasActed: true,
        cardsVisibleMode: Act0CardsVisibleModeV1.none,
        holeCards: _unknownHoleCards,
      ),
      Act0SeatStateV1(
        seatId: 'btn',
        seatLabel: 'BTN',
        displayName: 'Hero',
        isHero: true,
        isDealerButton: true,
        isActive: true,
        stackLabel: '100 BB',
        holeCards: _heroKtCards,
        cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
      ),
      Act0SeatStateV1(
        seatId: 'sb',
        seatLabel: 'SB',
        displayName: 'Small blind',
        isSmallBlind: true,
        blindAmountLabel: '0.5 BB',
        currentBetLabel: '0.5 BB',
        bet: _smallBlindPost,
        holeCards: _unknownHoleCards,
      ),
      Act0SeatStateV1(
        seatId: 'bb',
        seatLabel: 'BB',
        displayName: 'Big blind',
        isBigBlind: true,
        blindAmountLabel: '1 BB',
        currentBetLabel: '1 BB',
        bet: _bigBlindPost,
        holeCards: _unknownHoleCards,
      ),
    ],
    heroCards: _heroKtCards,
    boardCards: <Act0CardStateV1>[],
    streetLabel: 'Preflop',
    potLabel: 'Pot 1.5 BB',
    toCallLabel: 'To call 1 BB',
    centerLabel: 'Your turn',
    emptyBoardLabel: 'No board cards yet',
    handContributions: Act0HandContributionsV1(
      throughStreet: PokerStreet.preflop,
      startingStackBbBySeat: {'btn': 100},
      entries: _act0LessonBlinds,
    ),
    actionTrail: <Act0ActionTrailItemV1>[
      Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
      Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
      Act0ActionTrailItemV1(label: 'UTG folds'),
      Act0ActionTrailItemV1(label: 'HJ folds'),
      Act0ActionTrailItemV1(label: 'CO folds'),
      Act0ActionTrailItemV1(label: 'BTN acts'),
    ],
    activeSeatId: 'btn',
    heroSeatId: 'btn',
    highlightedSeatIds: <String>['btn'],
    highlightedCardIds: <String>[],
    instructionAnchor: 'hero',
  ),
  teachingSteps: <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Look before you act.',
      body: 'First ask: is anyone already in the pot?',
      focusSeatIds: <String>['btn', 'sb', 'bb'],
      focusLabels: <String>['Your turn', 'Blinds posted'],
    ),
    Act0TeachingStepV1(
      title: 'No one entered yet.',
      body:
          'First in means the first player to put chips in voluntarily after the blinds. Calling matches the blind. Raising increases the price.',
      focusSeatIds: <String>['btn'],
      focusLabels: <String>['First in', 'Button'],
    ),
  ],
);

const _firstHandRunner = Act0RunnerStateV1(
  lessonId: 'your_first_hand',
  lessonTitle: 'Your first hand',
  lessonSubtitle: 'See how one hand moves from deal to decision.',
  beatIndex: 3,
  beatCount: 8,
  phase: Act0LessonPhaseV1.theory,
  caption:
      'Preflop means no board cards yet. Your two private cards stay with you through the hand.',
  hint: 'Preflop means no board cards yet. The shared cards arrive later.',
  question: 'How many private cards do you start with?',
  options: <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'one',
      label: 'One',
      isCorrect: false,
      preferredLabel: 'Two',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Look at both private cards.',
      feedbackReason:
          'The dealer gave you both cards at your seat. Count them together before the shared cards arrive.',
      repairFocusCardIds: <String>['hero_0', 'hero_1'],
      repairFocusLabels: <String>['Your cards'],
    ),
    Act0RunnerOptionV1(
      id: 'two',
      label: 'Two',
      isCorrect: true,
      preferredLabel: 'Two',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Two cards: correct.',
      feedbackReason: 'You start with two private cards.',
      repairFocusCardIds: <String>['hero_0', 'hero_1'],
      repairFocusLabels: <String>['Your cards'],
    ),
    Act0RunnerOptionV1(
      id: 'five',
      label: 'Five',
      isCorrect: false,
      preferredLabel: 'Two',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason: 'Five cards can make a hand, but you start with two.',
      repairFocusCardIds: <String>['hero_0', 'hero_1'],
      repairFocusLabels: <String>['Your cards'],
    ),
  ],
  feedbackTitle: 'Two private cards: correct.',
  feedbackReason:
      'You start with two private cards. The board cards are shared by everyone.',
  primaryCtaLabel: 'Continue',
  nextLessonId: 'read_board',
  returnTarget: 'learn',
  table: Act0TableStateV1(
    scope: Act0TableScopeV1.playedHand,
    tableFormat: Act0TableFormatV1.sixMax,
    playerCount: 6,
    seats: <Act0SeatStateV1>[
      Act0SeatStateV1(
        seatId: 'utg',
        seatLabel: 'UTG',
        displayName: 'Seat',
        holeCards: _unknownHoleCards,
      ),
      Act0SeatStateV1(
        seatId: 'hj',
        seatLabel: 'HJ',
        displayName: 'Seat',
        holeCards: _unknownHoleCards,
      ),
      Act0SeatStateV1(
        seatId: 'co',
        seatLabel: 'CO',
        displayName: 'Cutoff',
        holeCards: _unknownHoleCards,
      ),
      Act0SeatStateV1(
        seatId: 'btn',
        seatLabel: 'BTN',
        displayName: 'Hero',
        isHero: true,
        isDealerButton: true,
        holeCards: _heroAkCards,
      ),
      Act0SeatStateV1(
        seatId: 'sb',
        seatLabel: 'SB',
        displayName: 'Small blind',
        isSmallBlind: true,
        blindAmountLabel: '0.5 BB',
        bet: _smallBlindPost,
        holeCards: _unknownHoleCards,
      ),
      Act0SeatStateV1(
        seatId: 'bb',
        seatLabel: 'BB',
        displayName: 'Big blind',
        isBigBlind: true,
        blindAmountLabel: '1 BB',
        bet: _bigBlindPost,
        holeCards: _unknownHoleCards,
      ),
    ],
    heroCards: _heroAkCards,
    boardCards: <Act0CardStateV1>[],
    streetLabel: 'Preflop',
    potLabel: 'Pot 1.5 BB',
    toCallLabel: '',
    centerLabel: 'Private cards',
    emptyBoardLabel: 'No board cards yet',
    highlightedSeatIds: <String>['btn'],
    highlightedCardIds: <String>[],
    instructionAnchor: 'cards',
  ),
  teachingSteps: <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'A hand starts preflop.',
      body:
          'Preflop means no board cards are out yet. You get two private cards at the start of the hand.',
      focusSeatIds: <String>['btn'],
      focusLabels: <String>['2 private cards', '0 board cards'],
    ),
    Act0TeachingStepV1(
      title: 'Private means yours.',
      body: 'Only you can use your private cards.',
      focusSeatIds: <String>['btn'],
      focusCardIds: <String>['hero_0', 'hero_1'],
      focusLabels: <String>['Private cards'],
    ),
  ],
);

final _privateCardsRecheckRunner = _firstHandRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'your_first_hand_private_cards_recheck',
  lessonTitle: 'Your first hand',
  lessonSubtitle: 'See your private cards before the board appears.',
  caption: 'You have two private cards before any board cards appear.',
  hint: 'Look at the two cards beside you.',
  question: 'Which two private cards are yours?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'ace_king',
      label: 'A and K',
      isCorrect: true,
      preferredLabel: 'A and K',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Clean private-card read.',
      feedbackReason: 'Your two cards are A and K. The board is still empty.',
      repairFocusCardIds: <String>['hero_0', 'hero_1'],
      repairFocusLabels: <String>['Your cards'],
    ),
    Act0RunnerOptionV1(
      id: 'queen_queen',
      label: 'Q and Q',
      isCorrect: false,
      preferredLabel: 'A and K',
      betterAnswerLabel: 'A and K',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason: 'Look again at the two cards beside you.',
      repairFocusCardIds: <String>['hero_0', 'hero_1'],
      repairFocusLabels: <String>['Your cards'],
    ),
    Act0RunnerOptionV1(
      id: 'board_cards',
      label: 'The board cards',
      isCorrect: false,
      preferredLabel: 'A and K',
      betterAnswerLabel: 'A and K',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not this street.',
      feedbackReason:
          'Board cards are shared later. This recheck asks for your two private cards.',
      repairFocusCardIds: <String>['hero_0', 'hero_1'],
      repairFocusLabels: <String>['Your cards'],
    ),
  ],
  feedbackTitle: 'Private cards locked in.',
  feedbackReason:
      'You found your two private cards before looking for any board cards.',
  table: _firstHandRunner.table.copyWith(
    boardCards: const <Act0CardStateV1>[],
    centerLabel: 'Your private cards',
    potLabel: 'Pot 1.5 BB',
    highlightedCardIds: const <String>['hero_0', 'hero_1'],
    emptyBoardLabel: 'No board cards yet',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Start with your cards.',
      body:
          'Before the board appears, you have exactly two private cards. Read those two cards first.',
      focusSeatIds: <String>['btn'],
      focusCardIds: <String>['hero_0', 'hero_1'],
      focusLabels: <String>['Your cards'],
    ),
  ],
);

const _readBoardRunner = Act0RunnerStateV1(
  lessonId: 'read_board',
  lessonTitle: 'Read the board',
  lessonSubtitle: 'Spot what changed on the flop, turn, and river.',
  beatIndex: 4,
  beatCount: 8,
  phase: Act0LessonPhaseV1.theory,
  caption: 'The flop puts three shared cards in the middle.',
  hint: 'Everyone can use the board.',
  question: 'How many cards are on this flop?',
  options: <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'two',
      label: 'Two',
      isCorrect: false,
      preferredLabel: 'Three',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason: 'The flop has three board cards.',
    ),
    Act0RunnerOptionV1(
      id: 'three',
      label: 'Three',
      isCorrect: true,
      preferredLabel: 'Three',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Well done.',
      feedbackReason: 'A flop has three board cards.',
    ),
    Act0RunnerOptionV1(
      id: 'five',
      label: 'Five',
      isCorrect: false,
      preferredLabel: 'Three',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'All five board cards are out only on the last street, the river.',
    ),
  ],
  feedbackTitle: 'Excellent spot.',
  feedbackReason:
      'A flop has three board cards. Turn and river add one card each.',
  primaryCtaLabel: 'Continue',
  nextLessonId: 'first_simple_decision',
  returnTarget: 'learn',
  table: Act0TableStateV1(
    scope: Act0TableScopeV1.playedHand,
    tableFormat: Act0TableFormatV1.sixMax,
    playerCount: 6,
    seats: <Act0SeatStateV1>[
      Act0SeatStateV1(
        seatId: 'utg',
        seatLabel: 'UTG',
        displayName: 'Seat',
        holeCards: _unknownHoleCards,
      ),
      Act0SeatStateV1(
        seatId: 'hj',
        seatLabel: 'HJ',
        displayName: 'Seat',
        holeCards: _unknownHoleCards,
      ),
      Act0SeatStateV1(
        seatId: 'co',
        seatLabel: 'CO',
        displayName: 'Cutoff',
        holeCards: _unknownHoleCards,
      ),
      Act0SeatStateV1(
        seatId: 'btn',
        seatLabel: 'BTN',
        displayName: 'Hero',
        isHero: true,
        isDealerButton: true,
        holeCards: _heroQqCards,
      ),
      Act0SeatStateV1(
        seatId: 'sb',
        seatLabel: 'SB',
        displayName: 'Small blind',
        isSmallBlind: true,
        holeCards: _unknownHoleCards,
      ),
      Act0SeatStateV1(
        seatId: 'bb',
        seatLabel: 'BB',
        displayName: 'Big blind',
        isBigBlind: true,
        holeCards: _unknownHoleCards,
      ),
    ],
    heroCards: _heroQqCards,
    boardCards: _flopA72Cards,
    streetLabel: 'Flop',
    potLabel: 'Pot 5 BB',
    toCallLabel: '',
    centerLabel: 'Shared board',
    highlightedSeatIds: <String>[],
    highlightedCardIds: <String>['board_0', 'board_1', 'board_2'],
    instructionAnchor: 'board',
  ),
  teachingSteps: <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'The board is shared.',
      body: 'Everyone still in the hand can use these middle cards.',
      focusCardIds: <String>['board_0', 'board_1', 'board_2'],
      focusLabels: <String>['Shared board'],
    ),
    Act0TeachingStepV1(
      title: 'The flop has three cards.',
      body: 'Turn adds one more. River adds the fifth.',
      focusCardIds: <String>['board_0', 'board_1', 'board_2'],
      focusLabels: <String>['Flop = 3'],
    ),
  ],
);

// The continuous first hand keeps the same cards, pot and action skills.
// Only your_first_hand_* uses this CO hand against the big blind.
const _firstHandPreflopTrail = <Act0ActionTrailItemV1>[
  Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
  Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
  Act0ActionTrailItemV1(label: 'UTG folds', displayLabel: 'First player folds'),
  Act0ActionTrailItemV1(
    label: 'HJ calls 1 BB',
    displayLabel: 'Player to your right calls 1 BB',
  ),
  Act0ActionTrailItemV1(
    label: 'CO raises to 3 BB',
    displayLabel: 'You raise to 3 BB',
  ),
  Act0ActionTrailItemV1(label: 'BTN folds'),
  Act0ActionTrailItemV1(label: 'SB folds'),
  Act0ActionTrailItemV1(
    label: 'BB calls 2 BB more',
    displayLabel: 'BB calls 2 more, 3 total',
  ),
  Act0ActionTrailItemV1(
    label: 'HJ folds',
    displayLabel: 'Player to your right folds',
  ),
];

// New, explicitly declared 100 BB starting context for four existing snapshots.
// This does not recover unknown historical stacks or change recorded actions.
Act0RunnerStateV1 _act0W01NewFirstHandStackContextV1(
  Act0RunnerStateV1 source, {
  bool earlierFlop = false,
}) {
  const remaining = <String, String>{
    'utg': '100 BB',
    'hj': '99 BB',
    'co': '97 BB',
    'btn': '100 BB',
    'sb': '99.5 BB',
    'bb': '97 BB',
  };
  return source.copyWith(
    caption: earlierFlop
        ? 'Read the action through the first check on the flop.'
        : 'The big blind checks on this ${source.table.streetLabel.toLowerCase()}.',
    table: source.table.copyWith(
      decisionSeatId: 'co',
      seats: [
        for (final seat in source.table.seats)
          _act0CopySeatStateV1(seat, stackLabel: remaining[seat.seatId]),
      ],
    ),
  );
}

Act0RunnerStateV1 _act0FirstHandAkRunnerV1(
  Act0RunnerStateV1 runner, {
  bool showdown = false,
  bool history = false,
}) {
  final street = history ? 'Flop' : runner.table.streetLabel;
  final streetIndex = ['Preflop', 'Flop', 'Turn', 'River'].indexOf(street);
  final finished = showdown || runner.lessonId == 'street_order_recap';
  final trail = <Act0ActionTrailItemV1>[..._firstHandPreflopTrail];
  for (var i = 1; i <= streetIndex; i++) {
    final name = ['Preflop', 'Flop', 'Turn', 'River'][i];
    trail.add(Act0ActionTrailItemV1(label: '$name: BB checks'));
    if (i < streetIndex || finished)
      trail.add(
        Act0ActionTrailItemV1(
          label: '$name: CO checks',
          displayLabel: '$name: You check',
        ),
      );
  }
  final sourceTable = _act0W1MoveHeroV1(runner.table, 'co');
  final table = _act0CurrentStreetTableV1(sourceTable).copyWith(
    heroCards: _heroAkCards,
    boardCards: history ? _flopA72Cards : runner.table.boardCards,
    streetLabel: street,
    highlightedSeatIds: showdown
        ? const <String>['bb']
        : sourceTable.highlightedSeatIds,
    highlightedCardIds: history
        ? const ['board_0', 'board_1', 'board_2']
        : runner.lessonId == 'your_first_hand_turn'
        ? const ['board_3']
        : runner.lessonId == 'your_first_hand_river'
        ? const ['board_4']
        : runner.table.highlightedCardIds,
    potLabel: 'Pot 7.5 BB',
    toCallLabel: '',
    activeSeatId: streetIndex > 0 && !finished ? 'co' : '',
    centerLabel: showdown
        ? 'Your pair of aces beats the big blind’s pair of jacks'
        : runner.table.centerLabel,
    handContributions: Act0HandContributionsV1(
      throughStreet: PokerStreet.values[streetIndex],
      entries: [
        ..._act0LessonBlinds,
        Act0ContributionV1(
          PokerStreet.preflop,
          'hj',
          Act0ContributionKindV1.wager,
          1,
        ),
        Act0ContributionV1(
          PokerStreet.preflop,
          'co',
          Act0ContributionKindV1.wager,
          3,
        ),
        Act0ContributionV1(
          PokerStreet.preflop,
          'bb',
          Act0ContributionKindV1.wager,
          2,
        ),
      ],
    ),
    actionTrail: trail,
    seats: [
      for (final seat in sourceTable.seats)
        _act0CopySeatStateV1(
          seat,
          isInHand: ['bb', 'co'].contains(seat.seatId),
          isFolded: !['bb', 'co'].contains(seat.seatId),
          isActive: seat.seatId == 'co' && streetIndex > 0 && !finished,
          holeCards: seat.isHero
              ? _heroAkCards
              : seat.seatId == 'bb' && finished
              ? _opponentKhJhCards
              : _unknownHoleCards,
          cardsVisibleMode: !['bb', 'co'].contains(seat.seatId)
              ? Act0CardsVisibleModeV1.none
              : seat.isHero || (seat.seatId == 'bb' && finished)
              ? Act0CardsVisibleModeV1.faceUp
              : Act0CardsVisibleModeV1.faceDown,
          clearCommitment: true,
        ),
    ],
  );
  return runner.copyWith(
    table: table,
    caption: history
        ? 'Replay the earlier flop snapshot. The action history records what happened up to BB checking.'
        : runner.caption,
    // Reuse accepted options unchanged: bb_check names the live BB check.
    teachingSteps: showdown
        ? const [
            Act0TeachingStepV1(
              title: 'Showdown compares hands.',
              body:
                  "Showdown is when players compare their best five after revealing their cards. Here, your aces beat the big blind's jacks.",
              focusCardIds: [
                'hero_0',
                'hero_1',
                'board_0',
                'board_1',
                'board_3',
              ],
              focusLabels: ['A-A-K-J-7', 'You win'],
            ),
          ]
        : runner.teachingSteps,
  );
}

final _cardsRanksRunner = _firstHandRunner.copyWith(
  lessonId: 'cards_ranks_suits',
  lessonTitle: 'Cards, ranks & suits',
  lessonSubtitle: 'Recognize ranks, suits, and private cards.',
  caption: 'Poker uses ranks and suits.',
  hint: 'Aces are high in this beginner drill.',
  question: 'Which rank is higher here?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'king',
      label: 'King',
      isCorrect: false,
      preferredLabel: 'Ace',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason: 'Ace is higher than king in this beginner drill.',
    ),
    Act0RunnerOptionV1(
      id: 'ace',
      label: 'Ace',
      isCorrect: true,
      preferredLabel: 'Ace',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Spot on.',
      feedbackReason: 'Compare top card first: ace outranks king in this spot.',
    ),
    Act0RunnerOptionV1(
      id: 'suit',
      label: 'Suit decides',
      isCorrect: false,
      preferredLabel: 'Ace',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason: 'Suit does not make one rank higher than another.',
    ),
  ],
  table: _firstHandRunner.table.copyWith(
    scope: Act0TableScopeV1.orientation,
    centerLabel: 'Ranks and suits',
    emptyBoardLabel: '',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Every card has two parts.',
      body: 'Rank tells how high it is. Suit tells the symbol family.',
      focusLabels: <String>['Rank', 'Suit'],
    ),
    Act0TeachingStepV1(
      title: 'Ranks have an order.',
      body:
          'The beginner order is 2, 3, 4, 5, 6, 7, 8, 9, 10, J, Q, K, A.\n\nAce is highest for now, so ace beats king in this drill.',
      focusLabels: <String>['2 ... 10', 'J Q K A', 'A beats K'],
    ),
  ],
);

final _deckIntroRunner = _cardsRanksRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'deck_intro',
  caption: 'A deck has 52 cards.',
  hint: 'Each card combines one rank with one suit.',
  question: 'What are the two parts of a card?',
  feedbackTitle: 'Rank and suit identify a card.',
  feedbackReason: 'Each card has one rank and one suit.',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'rank_only',
      label: 'The rank value',
      isCorrect: false,
      preferredLabel: 'Rank and suit',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Rank is one part.',
      feedbackReason: 'Rank names the value, but a card also has a suit.',
    ),
    Act0RunnerOptionV1(
      id: 'rank_and_suit',
      label: 'Rank and suit',
      isCorrect: true,
      preferredLabel: 'Rank and suit',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Both parts found.',
      feedbackReason: 'Rank names the value and suit names the symbol family.',
    ),
    Act0RunnerOptionV1(
      id: 'suit_only',
      label: 'The suit symbol',
      isCorrect: false,
      preferredLabel: 'Rank and suit',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Suit is one part.',
      feedbackReason:
          'Suit names the symbol family, but a card also has a rank.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Deck first.',
      body:
          "Hold'em uses a 52-card deck: 13 ranks across 4 suits. Numbers run from 2 up to 10. J means Jack, Q means Queen, K means King, and A means Ace.",
      focusLabels: <String>[
        '52 cards',
        '13 ranks',
        '4 suits',
        '2 ... 10',
        'J Q K A',
      ],
    ),
  ],
);

final _potStackRunner = _meetTableRunner.copyWith(
  lessonId: 'pot_stack',
  lessonTitle: 'What poker is',
  lessonSubtitle: 'Texas Hold\'em cash starts with stable table reads.',
  caption: 'Compare the chips at a seat with the chips in the middle.',
  hint: 'Compare the chips in the middle with the chips in front of you.',
  question: 'Which label shows the chips in the middle?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'pot',
      label: 'Pot',
      isCorrect: true,
      preferredLabel: 'Pot',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Clean execution.',
      feedbackReason: 'The pot is the chips in the middle.',
    ),
    Act0RunnerOptionV1(
      id: 'stack',
      label: 'Stack',
      isCorrect: false,
      preferredLabel: 'Pot',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'Your stack stays with your seat. The pot is the shared chips in the middle that everyone is playing for.',
    ),
  ],
  table: _meetTableRunner.table.copyWith(
    centerLabel: 'Pot vs stack',
    potLabel: 'Pot 1.5 BB',
  ),
  feedbackReason: 'The pot is contested. A stack is what a player has left.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'BB also counts chips.',
      body:
          'BB also measures chips. Pot 8 BB = eight big blinds.\n\nIn a \$1/\$2 game, 1 BB = \$2.\n\nA \$200 stack there is 100 BB. BB works across stakes.',
      focusLabels: <String>[
        'Pot in BB',
        '\$1/\$2 -> 1 BB = \$2',
        '\$200 = 100 BB',
      ],
    ),
    Act0TeachingStepV1(
      title: 'Pot and stack are different.',
      body: 'The pot is in the middle. Your stack stays with your seat.',
      focusSeatIds: <String>['btn'],
      focusLabels: <String>['Middle', 'Seat'],
    ),
  ],
);

final _allInMeaningRunner = _potStackRunner.copyWith(
  lessonId: 'all_in_meaning',
  caption:
      'You are all-in for 20 BB. CO called 20 BB and still has chips behind.',
  hint:
      'All-in means one player has put in all remaining chips. The cards or folds still decide the pot.',
  question: 'What does all-in mean here?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'all_remaining_committed',
      label: 'You put in all remaining chips',
      isCorrect: true,
      preferredLabel: 'You put in all remaining chips',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Correct table read.',
      feedbackReason:
          'All-in means you committed all remaining chips. It does not automatically win the pot, because cards or folds still decide what happens next.',
    ),
    Act0RunnerOptionV1(
      id: 'automatic_win',
      label: 'You win the pot right away',
      isCorrect: false,
      preferredLabel: 'You put in all remaining chips',
      betterAnswerLabel: 'You put in all remaining chips',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not a win condition.',
      feedbackReason:
          'All-in does not automatically win. If another player calls, the hand can still go to showdown and the cards still decide the pot.',
    ),
    Act0RunnerOptionV1(
      id: 'largest_stack_only',
      label: 'Only the bigger stack matters now',
      isCorrect: false,
      preferredLabel: 'You put in all remaining chips',
      betterAnswerLabel: 'You put in all remaining chips',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Stack size still has a role, but not that role.',
      feedbackReason:
          'CO has chips left. You put in your last chips. The hand still has to be decided.',
    ),
  ],
  table: _potStackRunner.table.copyWith(
    scope: Act0TableScopeV1.explanation,
    centerLabel: 'All-in is all remaining chips',
    potLabel: 'Pot 41.5 BB',
    toCallLabel: '',
    // Added authored hand history (PKR-06 content decision, 2026-11-08); these
    // actions were not in the earlier source. UTG/HJ fold, CO limps for 1 BB,
    // both blinds fold to Hero's all-in, then CO calls to 20 BB total, so
    // pot 41.5 BB = 0.5 + 1 + 20 + 20 is unchanged.
    handContributions: const Act0HandContributionsV1(
      throughStreet: PokerStreet.preflop,
      startingStackBbBySeat: {'btn': 20},
      entries: [
        ..._act0LessonBlinds,
        Act0ContributionV1(
          PokerStreet.preflop,
          'co',
          Act0ContributionKindV1.wager,
          1,
        ),
        Act0ContributionV1(
          PokerStreet.preflop,
          'btn',
          Act0ContributionKindV1.wager,
          20,
        ),
        Act0ContributionV1(
          PokerStreet.preflop,
          'co',
          Act0ContributionKindV1.wager,
          19,
        ),
      ],
    ),
    actionTrail: const <Act0ActionTrailItemV1>[
      Act0ActionTrailItemV1.note(label: 'Blinds: 1.5 BB'),
      Act0ActionTrailItemV1.note(label: 'UTG folds'),
      Act0ActionTrailItemV1.note(label: 'HJ folds'),
      Act0ActionTrailItemV1.note(label: 'CO calls 1 BB'),
      Act0ActionTrailItemV1.note(
        label: 'Hero all-in 20 BB',
        displayLabel: 'You go all-in for 20 BB',
      ),
      Act0ActionTrailItemV1.note(label: 'SB folds'),
      Act0ActionTrailItemV1.note(label: 'BB folds'),
      Act0ActionTrailItemV1.note(label: 'CO calls, 20 BB total'),
    ],
    highlightedSeatIds: const <String>['btn', 'co'],
    seats: _potStackRunner.table.seats
        .map<Act0SeatStateV1>(
          (seat) => seat.seatId == 'btn'
              ? Act0SeatStateV1(
                  seatId: seat.seatId,
                  seatLabel: seat.seatLabel,
                  displayName: 'Hero',
                  isHero: true,
                  isDealerButton: seat.isDealerButton,
                  isSmallBlind: seat.isSmallBlind,
                  isBigBlind: seat.isBigBlind,
                  blindAmountLabel: seat.blindAmountLabel,
                  isActive: seat.isActive,
                  isTarget: seat.isTarget,
                  isInHand: seat.isInHand,
                  isFolded: seat.isFolded,
                  hasActed: seat.hasActed,
                  isLastAggressor: seat.isLastAggressor,
                  isOccupied: seat.isOccupied,
                  stackLabel: '0 BB',
                  holeCards: seat.holeCards,
                  cardsVisibleMode: seat.cardsVisibleMode,
                  currentBetLabel: '20 BB',
                  bet: const Act0SeatBetStateV1(
                    kind: Act0SeatBetKindV1.allIn,
                    label: 'All-in',
                    amountLabel: '20 BB',
                  ),
                )
              : seat.seatId == 'co'
              ? Act0SeatStateV1(
                  seatId: seat.seatId,
                  seatLabel: seat.seatLabel,
                  displayName: 'CO',
                  isHero: seat.isHero,
                  isDealerButton: seat.isDealerButton,
                  isSmallBlind: seat.isSmallBlind,
                  isBigBlind: seat.isBigBlind,
                  blindAmountLabel: seat.blindAmountLabel,
                  isActive: false,
                  isTarget: seat.isTarget,
                  isInHand: seat.isInHand,
                  isFolded: seat.isFolded,
                  hasActed: seat.hasActed,
                  isLastAggressor: seat.isLastAggressor,
                  isOccupied: seat.isOccupied,
                  stackLabel: '80 BB',
                  holeCards: seat.holeCards,
                  cardsVisibleMode: seat.cardsVisibleMode,
                  currentBetLabel: '20 BB',
                  bet: const Act0SeatBetStateV1(
                    kind: Act0SeatBetKindV1.call,
                    label: 'Call',
                    amountLabel: '20 BB',
                  ),
                )
              // Out of this pot by the folds added to the trail above.
              : _act0CopySeatStateV1(
                  seat,
                  isInHand: false,
                  isFolded: true,
                  hasActed: true,
                  cardsVisibleMode: Act0CardsVisibleModeV1.none,
                ),
        )
        .toList(growable: false),
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'All-in means no chips behind.',
      body: '0 BB behind = all-in. Cards or folds still decide.',
      focusLabels: <String>['0 BB behind', '20 BB in', 'Cards still decide'],
    ),
  ],
);

final _matchedChipsTransferRunner = _allInMeaningRunner.copyWith(
  lessonId: 'matched_chips_transfer',
  caption:
      'You put in your last 20 BB. CO calls 20 BB and still has chips left.',
  hint: 'Count how much each player put in for this hand.',
  question: 'How many chips can you win from CO in this hand?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'matched_amount_only',
      label: 'Only the chips CO matched against the 20 BB all-in',
      isCorrect: true,
      preferredLabel: 'Only the chips CO matched against the 20 BB all-in',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Correct matched-chips read.',
      feedbackReason:
          'You can win the 20 BB CO matched. That limit stays fixed for this hand, even if CO bets more against another player.',
    ),
    Act0RunnerOptionV1(
      id: 'entire_covering_stack',
      label: "The other player's whole 100 BB stack",
      isCorrect: false,
      preferredLabel: 'Only the chips CO matched against the 20 BB all-in',
      betterAnswerLabel: 'Only the chips CO matched against the 20 BB all-in',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too many chips counted.',
      feedbackReason:
          'Your all-in caps CO’s contribution to the pot you can win at 20 BB. Any further chips CO bets against another player stay in a separate pot.',
    ),
    Act0RunnerOptionV1(
      id: 'nothing_until_showdown',
      label: 'Nothing counts until all stacks are equal',
      isCorrect: false,
      preferredLabel: 'Only the chips CO matched against the 20 BB all-in',
      betterAnswerLabel: 'Only the chips CO matched against the 20 BB all-in',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Matched already matters.',
      feedbackReason:
          'You can win the 20 BB that CO matched. CO keeps the chips they did not put in.',
    ),
  ],
  table: _allInMeaningRunner.table.copyWith(
    centerLabel: 'Matched chips set the contest',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Short stacks cannot win unmatched chips.',
      body: 'Only matched chips count. CO\'s 80 BB behind stays out.',
      focusLabels: <String>['Matched chips', '80 BB behind', 'Not contested'],
    ),
  ],
);

final _sidePotIntroRunner = _matchedChipsTransferRunner.copyWith(
  lessonId: 'side_pot_intro',
  caption:
      'Hero is all-in for 20 BB. CO and BB each contributed 50 BB total: 20 BB to match Hero, then 30 BB more against each other.',
  hint:
      'Main pot: 20 BB each from Hero, CO, and BB, plus the folded small blind\'s 0.5 BB. The big blind\'s 1 BB is already inside BB\'s 20 BB. Side pot: 30 BB each from CO and BB.',
  question: 'Which statement is true here?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'hero_main_only',
      label: 'Hero can win the main pot, but not the side pot',
      isCorrect: true,
      preferredLabel: 'Hero can win the main pot, but not the side pot',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Correct side-pot intro.',
      feedbackReason:
          'Hero matched only 20 BB, so Hero fights for the main pot. The extra 30 BB from CO and BB forms a side pot that only those bigger stacks can win.',
    ),
    Act0RunnerOptionV1(
      id: 'hero_wins_everything',
      label: 'Hero can win every chip once all-in',
      isCorrect: false,
      preferredLabel: 'Hero can win the main pot, but not the side pot',
      betterAnswerLabel: 'Hero can win the main pot, but not the side pot',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too many chips assigned.',
      feedbackReason:
          'All-in is not a claim on unmatched extra chips. Hero cannot win the side pot because Hero never matched those extra 30 BB between CO and BB.',
    ),
    Act0RunnerOptionV1(
      id: 'side_pot_is_penalty',
      label: 'The side pot is a penalty for the short stack',
      isCorrect: false,
      preferredLabel: 'Hero can win the main pot, but not the side pot',
      betterAnswerLabel: 'Hero can win the main pot, but not the side pot',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Not a penalty, just a separate contest.',
      feedbackReason:
          'A side pot is not punishment. It is just the extra chips that only the bigger stacks matched after the short stack was already all-in.',
    ),
  ],
  table: _matchedChipsTransferRunner.table.copyWith(
    scope: Act0TableScopeV1.explanation,
    activeSeatId: '',
    clearDecisionSeatId: true,
    centerLabel: 'Hero cannot win side pot',
    potLabel: 'Main 60.5 BB; side 60 BB',
    // Added authored hand history (PKR-06 content decision, 2026-11-08); not in
    // the earlier source. UTG and HJ put no chips in and are out of both pots.
    actionTrail: const <Act0ActionTrailItemV1>[
      Act0ActionTrailItemV1.note(label: 'UTG folds'),
      Act0ActionTrailItemV1.note(label: 'HJ folds'),
      Act0ActionTrailItemV1.note(label: 'SB posts 0.5 BB, then folds'),
      Act0ActionTrailItemV1.note(label: 'BB post is included in BB total'),
      Act0ActionTrailItemV1.note(
        label: 'Hero all-in 20 BB',
        displayLabel: 'You go all-in for 20 BB',
      ),
      Act0ActionTrailItemV1.note(label: 'CO contributes 50 BB total'),
      Act0ActionTrailItemV1.note(label: 'BB contributes 50 BB total'),
      Act0ActionTrailItemV1.note(label: 'CO and BB: 30 BB each to side'),
    ],
    highlightedSeatIds: const <String>['btn', 'co', 'bb'],
    seats: _matchedChipsTransferRunner.table.seats
        .map<Act0SeatStateV1>(
          (seat) => seat.seatId == 'btn'
              ? Act0SeatStateV1(
                  seatId: seat.seatId,
                  seatLabel: seat.seatLabel,
                  displayName: 'Hero',
                  isHero: true,
                  isDealerButton: seat.isDealerButton,
                  isSmallBlind: seat.isSmallBlind,
                  isBigBlind: seat.isBigBlind,
                  blindAmountLabel: seat.blindAmountLabel,
                  isActive: seat.isActive,
                  isTarget: seat.isTarget,
                  isInHand: seat.isInHand,
                  isFolded: seat.isFolded,
                  hasActed: seat.hasActed,
                  isLastAggressor: seat.isLastAggressor,
                  isOccupied: seat.isOccupied,
                  stackLabel: '0 BB',
                  holeCards: seat.holeCards,
                  cardsVisibleMode: seat.cardsVisibleMode,
                  currentBetLabel: '20 BB',
                  bet: const Act0SeatBetStateV1(
                    kind: Act0SeatBetKindV1.allIn,
                    label: 'All-in',
                    amountLabel: '20 BB',
                  ),
                )
              : seat.seatId == 'co'
              ? Act0SeatStateV1(
                  seatId: seat.seatId,
                  seatLabel: seat.seatLabel,
                  displayName: 'CO',
                  isHero: seat.isHero,
                  isDealerButton: seat.isDealerButton,
                  isSmallBlind: seat.isSmallBlind,
                  isBigBlind: seat.isBigBlind,
                  blindAmountLabel: seat.blindAmountLabel,
                  isTarget: seat.isTarget,
                  isInHand: seat.isInHand,
                  isFolded: seat.isFolded,
                  hasActed: true,
                  isLastAggressor: seat.isLastAggressor,
                  isOccupied: seat.isOccupied,
                  stackLabel: '50 BB',
                  holeCards: seat.holeCards,
                  cardsVisibleMode: seat.cardsVisibleMode,
                  currentBetLabel: '50 BB',
                  bet: const Act0SeatBetStateV1(
                    kind: Act0SeatBetKindV1.raise,
                    label: 'Total in',
                    amountLabel: '50 BB',
                  ),
                )
              : seat.seatId == 'utg' || seat.seatId == 'hj'
              ? _act0CopySeatStateV1(
                  seat,
                  isInHand: false,
                  isFolded: true,
                  hasActed: true,
                  cardsVisibleMode: Act0CardsVisibleModeV1.none,
                )
              : seat.seatId == 'bb'
              ? Act0SeatStateV1(
                  seatId: seat.seatId,
                  seatLabel: seat.seatLabel,
                  displayName: 'Big blind',
                  isHero: seat.isHero,
                  isDealerButton: seat.isDealerButton,
                  isSmallBlind: seat.isSmallBlind,
                  isBigBlind: seat.isBigBlind,
                  blindAmountLabel: seat.blindAmountLabel,
                  isActive: false,
                  isTarget: seat.isTarget,
                  // BB contributes 50 BB here (existing source fact), so it stays
                  // live even though the all-in scene it inherits folds BB.
                  isInHand: true,
                  isFolded: false,
                  hasActed: seat.hasActed,
                  isLastAggressor: seat.isLastAggressor,
                  isOccupied: seat.isOccupied,
                  stackLabel: '50 BB',
                  holeCards: seat.holeCards,
                  cardsVisibleMode: Act0CardsVisibleModeV1.faceDown,
                  currentBetLabel: '50 BB',
                  bet: const Act0SeatBetStateV1(
                    kind: Act0SeatBetKindV1.call,
                    label: 'Total in',
                    amountLabel: '50 BB',
                  ),
                )
              // Source-backed SB fold: blind remains dead money in main pot.
              : seat.seatId == 'sb'
              ? _act0CopySeatStateV1(
                  seat,
                  isInHand: false,
                  isFolded: true,
                  hasActed: true,
                  cardsVisibleMode: Act0CardsVisibleModeV1.none,
                )
              : seat,
        )
        .toList(growable: false),
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Main pot first, side pot second.',
      body:
          'Main: 20 BB each from Hero, CO, and BB, plus the folded SB\'s 0.5 BB. Side: CO and BB add 30 BB each.',
      focusLabels: <String>[
        'Main pot',
        'Side pot',
        'Hero did not match extra chips',
      ],
    ),
  ],
);

final _winWaysRunner = _meetTableRunner.copyWith(
  lessonId: 'win_ways',
  lessonTitle: 'What poker is',
  lessonSubtitle: 'A pot can end before showdown or at showdown.',
  caption: 'You win when others fold or when your hand wins showdown.',
  hint: 'Early lessons only need these two endings.',
  question: 'Which is a way to win the pot before showdown?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'everyone_folds',
      label: 'Everyone else folds',
      isCorrect: true,
      preferredLabel: 'Everyone else folds',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'That is the early ending.',
      feedbackReason:
          'If everyone else folds, the hand ends before showdown and the last player standing wins the pot immediately.',
    ),
    Act0RunnerOptionV1(
      id: 'largest_stack',
      label: 'Largest stack',
      isCorrect: false,
      preferredLabel: 'Everyone else folds',
      betterAnswerLabel: 'Everyone else folds',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'A larger stack can apply pressure later, but it does not end this pot by itself. Before showdown, you win only when everyone else folds.',
    ),
    Act0RunnerOptionV1(
      id: 'best_hand_showdown',
      label: 'Best hand at showdown',
      isCorrect: false,
      preferredLabel: 'Everyone else folds',
      betterAnswerLabel: 'Everyone else folds',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'That is the other ending.',
      feedbackReason:
          'Best hand at showdown is a real way to win, but this question asks for the early ending before cards are revealed.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'A pot can end two ways.',
      body: 'Everyone else folds, or players compare hands at showdown.',
      focusLabels: <String>['Folds', 'Showdown'],
    ),
  ],
);

final _suitsRunner = _firstHandRunner.copyWith(
  table: _firstHandRunner.table.copyWith(
    scope: Act0TableScopeV1.orientation,
    heroCards: const [
      Act0CardStateV1(rank: 'A', suit: 'h'),
      Act0CardStateV1(rank: 'K', suit: 'd'),
    ],
    seats: [
      for (final seat in _firstHandRunner.table.seats)
        if (seat.isHero)
          _act0CopySeatStateV1(
            seat,
            holeCards: const [
              Act0CardStateV1(rank: 'A', suit: 'h'),
              Act0CardStateV1(rank: 'K', suit: 'd'),
            ],
          )
        else
          seat,
    ],
  ),
  lessonId: 'suits_drill',
  lessonTitle: 'Cards, ranks & suits',
  caption: 'Each card has a rank and a suit. Ah means ace of hearts.',
  hint: 'Use the small letter beside the card rank.',
  question: 'In Ah, what suit does h mean?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'heart',
      label: 'Hearts',
      isCorrect: true,
      preferredLabel: 'Hearts',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Hearts is the suit.',
      feedbackReason: 'Card code check: A means ace and h means hearts.',
    ),
    Act0RunnerOptionV1(
      id: 'rank',
      label: 'Ace',
      isCorrect: false,
      preferredLabel: 'Hearts',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason: 'A is the rank. h is the suit.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Suits are card families.',
      body:
          'A means ace and T means ten. The suit letters are s for spades, h for hearts, d for diamonds, and c for clubs. Ah means ace of hearts.',
      focusLabels: <String>['s h d c', 'A = Ace', 'Ah = Ace of hearts'],
    ),
  ],
);

final _privateBoardRunner = _firstHandRunner.copyWith(
  lessonId: 'private_board',
  lessonTitle: 'Cards, ranks & suits',
  caption: 'Compare the cards at your seat and in the middle.',
  hint: 'Look at the cards in the middle.',
  question: 'Which cards can everyone use?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'board',
      label: 'Board cards',
      isCorrect: true,
      preferredLabel: 'Board cards',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Board cards are shared.',
      feedbackReason: 'Board cards are shared by everyone still in the hand.',
    ),
    Act0RunnerOptionV1(
      id: 'private',
      label: 'Private cards',
      isCorrect: false,
      preferredLabel: 'Board cards',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'Private cards belong only to one player. Board cards sit in the middle as shared cards, so everyone still in the hand can use them.',
    ),
  ],
  table: _readBoardRunner.table.copyWith(
    handContributions: _act0BoardReadingContributionsV1(PokerStreet.flop),
    centerLabel: '',
    highlightedCardIds: const <String>[],
    potLabel: 'Pot 5 BB',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Private cards stay private.',
      body: 'Board cards are shared by every player still in the hand.',
      focusSeatIds: <String>['btn'],
      focusCardIds: <String>['board_0', 'board_1', 'board_2'],
      focusLabels: <String>['Private', 'Shared'],
    ),
  ],
);

final _turnBoardRunner = _readBoardRunner.copyWith(
  lessonId: 'your_first_hand_turn',
  lessonTitle: 'Your first hand, dealt',
  lessonSubtitle: 'The turn adds one more shared card.',
  caption: 'The turn is the fourth board card.',
  hint: 'Flop has three cards. Turn makes four.',
  question: 'How many board cards are visible on the turn?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'three',
      label: 'Three',
      isCorrect: false,
      preferredLabel: 'Four',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason: 'Three cards is the flop. Turn makes four.',
    ),
    Act0RunnerOptionV1(
      id: 'four',
      label: 'Four',
      isCorrect: true,
      preferredLabel: 'Four',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Turn is the fourth board card.',
      feedbackReason: 'The turn is the fourth board card.',
    ),
    Act0RunnerOptionV1(
      id: 'five',
      label: 'Five',
      isCorrect: false,
      preferredLabel: 'Four',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason: 'Five board cards appear on the river.',
    ),
  ],
  table: _readBoardRunner.table.copyWith(
    streetLabel: 'Turn',
    boardCards: const <Act0CardStateV1>[
      ..._flopA72Cards,
      Act0CardStateV1(rank: 'J', suit: 'c'),
    ],
    potLabel: 'Pot 5 BB',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Turn means one more board card.',
      body: 'After the flop, exactly one shared card is added.',
      focusCardIds: <String>['board_3'],
      focusLabels: <String>['Fourth board card'],
    ),
  ],
);

final _riverBoardRunner = _readBoardRunner.copyWith(
  lessonId: 'your_first_hand_river',
  lessonTitle: 'Your first hand, dealt',
  lessonSubtitle: 'The river completes the board.',
  caption: 'The river is the fifth board card.',
  hint: 'Now the shared board is complete.',
  question: 'How many board cards are visible on the river?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'four',
      label: 'Four',
      isCorrect: false,
      preferredLabel: 'Five',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason: 'Four cards is the turn. River makes five.',
    ),
    Act0RunnerOptionV1(
      id: 'five',
      label: 'Five',
      isCorrect: true,
      preferredLabel: 'Five',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'River is the fifth board card.',
      feedbackReason: 'The river completes five board cards.',
    ),
    Act0RunnerOptionV1(
      id: 'six',
      label: 'Six',
      isCorrect: false,
      preferredLabel: 'Five',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason: "Hold'em uses five board cards, not six.",
    ),
  ],
  table: _readBoardRunner.table.copyWith(
    streetLabel: 'River',
    boardCards: const <Act0CardStateV1>[
      ..._flopA72Cards,
      Act0CardStateV1(rank: 'J', suit: 'c'),
      Act0CardStateV1(rank: '4', suit: 's'),
    ],
    potLabel: 'Pot 5 BB',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'River completes the board.',
      body: 'The fifth shared card is the last board card.',
      focusCardIds: <String>['board_4'],
      focusLabels: <String>['Fifth board card'],
    ),
  ],
);

const _noPriceActionChoices = <Act0RunnerOptionV1>[
  Act0RunnerOptionV1(
    id: 'fold',
    label: 'Fold',
    isCorrect: false,
    preferredLabel: 'Check',
    quality: Act0FeedbackQualityV1.wrong,
    feedbackTitle: 'Not quite.',
    feedbackReason: 'Folding gives up the hand. Checking is free here.',
  ),
  Act0RunnerOptionV1(
    id: 'check',
    label: 'Check',
    isCorrect: true,
    preferredLabel: 'Check',
    quality: Act0FeedbackQualityV1.correct,
    feedbackTitle: 'Check is legal with no bet to call.',
    feedbackReason: 'Checking keeps the hand going when no bet faces you.',
  ),
  Act0RunnerOptionV1(
    id: 'call',
    label: 'Call',
    isCorrect: false,
    preferredLabel: 'Check',
    quality: Act0FeedbackQualityV1.wrong,
    feedbackTitle: 'Not quite.',
    feedbackReason: 'Calling means matching a bet. There is no bet here.',
  ),
];

final _checkActionRunner = _firstHandRunner.copyWith(
  lessonId: 'actions_check',
  lessonTitle: 'Fold, check, call, raise',
  lessonSubtitle: 'No bet means checking is available.',
  caption: 'No one has bet on this street.',
  hint: 'Read the amount required to stay in the hand.',
  question: 'What action keeps playing for free?',
  options: _noPriceActionChoices,
  table: _act0CurrentStreetTableV1(
    _firstHandRunner.table.copyWith(
      streetLabel: 'Flop',
      boardCards: _flopA72Cards,
      potLabel: 'Pot 3 BB',
      toCallLabel: '',
      centerLabel: 'No bet yet',
    ),
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'No bet is facing you.',
      body: 'When no one has bet, check keeps playing for free.',
      focusSeatIds: <String>['btn'],
      focusLabels: <String>['No bet', 'Check is free'],
    ),
  ],
);

const _foldMeaningChoices = <Act0RunnerOptionV1>[
  Act0RunnerOptionV1(
    id: 'fold',
    label: 'Fold',
    isCorrect: true,
    preferredLabel: 'Fold',
    quality: Act0FeedbackQualityV1.correct,
    feedbackTitle: 'Fold gives up this hand.',
    feedbackReason: 'Fold gives up the hand and saves the call.',
  ),
  Act0RunnerOptionV1(
    id: 'call',
    label: 'Call',
    amountLabel: '2 BB',
    isCorrect: false,
    preferredLabel: 'Fold',
    quality: Act0FeedbackQualityV1.wrong,
    feedbackTitle: 'Not quite.',
    feedbackReason:
        'Calling pays 2 BB to stay in the hand. Your queens still beat some hands.',
  ),
  Act0RunnerOptionV1(
    id: 'raise',
    label: 'Raise',
    amountLabel: '6 BB',
    isCorrect: false,
    preferredLabel: 'Fold',
    quality: Act0FeedbackQualityV1.wrong,
    feedbackTitle: 'Not quite.',
    feedbackReason: 'Raising puts in more chips and keeps you in the hand.',
  ),
];

final _foldActionRunner = _readBoardRunner.copyWith(
  lessonId: 'actions_fold',
  lessonTitle: 'Fold, check, call, raise',
  lessonSubtitle: 'Folding gives up the hand.',
  caption: 'HJ bets 2 BB on an ace-high flop. You hold two queens.',
  hint: 'Folding saves chips when continuing is not worth it.',
  question: 'Which action gives up the hand?',
  options: _foldMeaningChoices,
  table: _readBoardRunner.table.copyWith(
    streetLabel: 'Flop',
    potLabel: 'Pot 7 BB',
    toCallLabel: 'To call 2 BB',
    centerLabel: 'Facing a bet',
    seats: <Act0SeatStateV1>[
      Act0SeatStateV1(
        seatId: 'utg',
        seatLabel: 'UTG',
        displayName: 'Seat',
        holeCards: _unknownHoleCards,
      ),
      Act0SeatStateV1(
        seatId: 'hj',
        seatLabel: 'HJ',
        displayName: 'Seat',
        bet: _hjBet2Bb,
        holeCards: _unknownHoleCards,
      ),
      Act0SeatStateV1(
        seatId: 'co',
        seatLabel: 'CO',
        displayName: 'Cutoff',
        holeCards: _unknownHoleCards,
      ),
      Act0SeatStateV1(
        seatId: 'btn',
        seatLabel: 'BTN',
        displayName: 'Hero',
        isHero: true,
        isDealerButton: true,
        holeCards: _heroQqCards,
      ),
      Act0SeatStateV1(
        seatId: 'sb',
        seatLabel: 'SB',
        displayName: 'Small blind',
        isSmallBlind: true,
        holeCards: _unknownHoleCards,
      ),
      Act0SeatStateV1(
        seatId: 'bb',
        seatLabel: 'BB',
        displayName: 'Big blind',
        isBigBlind: true,
        holeCards: _unknownHoleCards,
      ),
    ],
    actionTrail: const <Act0ActionTrailItemV1>[
      Act0ActionTrailItemV1(label: 'HJ bets 2 BB'),
      Act0ActionTrailItemV1(label: 'Hero acts', displayLabel: 'Your turn'),
    ],
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'A bet creates a price.',
      body:
          'Folding ends your part in the hand without paying the call. The flop alone does not tell you whether folding is best.',
      focusSeatIds: <String>['btn', 'hj'],
      focusLabels: <String>['Facing a bet', 'Gives up the hand'],
    ),
  ],
);

final _callActionRunner = _readBoardRunner.copyWith(
  lessonId: 'actions_call',
  lessonTitle: 'Fold, check, call, raise',
  lessonSubtitle: 'Calling matches the current price.',
  caption: 'You face a small bet and want the cheapest continue.',
  hint: 'Read the price and ask what each action changes.',
  question: 'Which action matches the 1 BB price?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'fold',
      label: 'Fold',
      isCorrect: false,
      preferredLabel: 'Call',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason: 'Folding gives up instead of continuing.',
    ),
    Act0RunnerOptionV1(
      id: 'call',
      label: 'Call',
      amountLabel: '1 BB',
      isCorrect: true,
      preferredLabel: 'Call',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Call matches the current bet.',
      feedbackReason: 'Calling matches the current price.',
    ),
    Act0RunnerOptionV1(
      id: 'raise',
      label: 'Raise',
      amountLabel: '4 BB',
      isCorrect: false,
      preferredLabel: 'Call',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'Raising adds more chips than calling, which only matches the current bet.',
    ),
  ],
  table: _readBoardRunner.table.copyWith(
    streetLabel: 'Flop',
    potLabel: 'Pot 5 BB',
    toCallLabel: 'To call 1 BB',
    centerLabel: 'Facing a price',
    seats: <Act0SeatStateV1>[
      Act0SeatStateV1(
        seatId: 'utg',
        seatLabel: 'UTG',
        displayName: 'Seat',
        holeCards: _unknownHoleCards,
      ),
      Act0SeatStateV1(
        seatId: 'hj',
        seatLabel: 'HJ',
        displayName: 'Seat',
        bet: _hjBet1Bb,
        holeCards: _unknownHoleCards,
      ),
      Act0SeatStateV1(
        seatId: 'co',
        seatLabel: 'CO',
        displayName: 'Cutoff',
        holeCards: _unknownHoleCards,
      ),
      Act0SeatStateV1(
        seatId: 'btn',
        seatLabel: 'BTN',
        displayName: 'Hero',
        isHero: true,
        isDealerButton: true,
        holeCards: _heroQqCards,
      ),
      Act0SeatStateV1(
        seatId: 'sb',
        seatLabel: 'SB',
        displayName: 'Small blind',
        isSmallBlind: true,
        holeCards: _unknownHoleCards,
      ),
      Act0SeatStateV1(
        seatId: 'bb',
        seatLabel: 'BB',
        displayName: 'Big blind',
        isBigBlind: true,
        holeCards: _unknownHoleCards,
      ),
    ],
    actionTrail: const <Act0ActionTrailItemV1>[
      Act0ActionTrailItemV1(label: 'HJ bets 1 BB'),
      Act0ActionTrailItemV1(label: 'Hero acts', displayLabel: 'Your turn'),
    ],
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Calling matches the price.',
      body: 'Call means put in exactly enough chips to continue.',
      focusSeatIds: <String>['btn'],
      focusLabels: <String>['To call 1 BB'],
    ),
  ],
);

// Explicit new mechanical frame for only three W01 task bindings. Existing
// strategy feedback and grades are preserved, not adjudicated by this repair.
// First in means an unopened pot after three folds, not absence of prior action.
Act0RunnerStateV1 _act0W01FoldedToBtnMechanicalContextV1(
  Act0RunnerStateV1 source, {
  List<Act0CardStateV1>? heroCards,
  String handDescription = 'K and T of the same suit',
}) {
  const hidden = <Act0CardStateV1>[
    Act0CardStateV1(rank: '?', suit: ''),
    Act0CardStateV1(rank: '?', suit: ''),
  ];
  return source.copyWith(
    caption:
        'Everyone before you folds. You have $handDescription on the Button. Calling costs 1 BB. Raising makes the price 3 BB total.',
    table: source.table.copyWith(
      scope: Act0TableScopeV1.playedHand,
      tableFormat: Act0TableFormatV1.sixMax,
      heroCards: heroCards,
      boardCards: const [],
      streetLabel: 'Preflop',
      potLabel: 'Pot 1.5 BB',
      toCallLabel: 'To call 1 BB',
      decisionSeatId: 'btn',
      activeSeatId: 'btn',
      heroSeatId: 'btn',
      handContributions: const Act0HandContributionsV1(
        throughStreet: PokerStreet.preflop,
        startingStackBbBySeat: {'btn': 100},
        entries: [..._act0LessonBlinds],
      ),
      actionTrail: const [
        Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
        Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
        Act0ActionTrailItemV1(label: 'UTG folds'),
        Act0ActionTrailItemV1(label: 'HJ folds'),
        Act0ActionTrailItemV1(label: 'CO folds'),
      ],
      seats: [
        for (final seat in source.table.seats)
          Act0SeatStateV1(
            seatId: seat.seatId,
            seatLabel: seat.seatLabel,
            displayName: seat.displayName,
            isHero: seat.seatId == 'btn',
            isDealerButton: seat.seatId == 'btn',
            isSmallBlind: seat.seatId == 'sb',
            isBigBlind: seat.seatId == 'bb',
            blindAmountLabel: seat.seatId == 'sb'
                ? '0.5 BB'
                : seat.seatId == 'bb'
                ? '1 BB'
                : null,
            isActive: seat.seatId == 'btn',
            isInHand: const ['btn', 'sb', 'bb'].contains(seat.seatId),
            isFolded: const ['utg', 'hj', 'co'].contains(seat.seatId),
            hasActed: const ['utg', 'hj', 'co'].contains(seat.seatId),
            isLastAggressor: false,
            stackLabel: seat.seatId == 'sb'
                ? '99.5 BB'
                : seat.seatId == 'bb'
                ? '99 BB'
                : '100 BB',
            currentBetLabel: seat.seatId == 'sb'
                ? '0.5 BB'
                : seat.seatId == 'bb'
                ? '1 BB'
                : null,
            bet: seat.seatId == 'sb'
                ? _smallBlindPost
                : seat.seatId == 'bb'
                ? _bigBlindPost
                : null,
            holeCards: seat.seatId == 'btn'
                ? source.table.heroCards
                : const ['sb', 'bb'].contains(seat.seatId)
                ? hidden
                : const [],
            cardsVisibleMode: seat.seatId == 'btn'
                ? Act0CardsVisibleModeV1.faceUp
                : const ['sb', 'bb'].contains(seat.seatId)
                ? Act0CardsVisibleModeV1.faceDown
                : Act0CardsVisibleModeV1.none,
          ),
      ],
    ),
  );
}

// NEW authored mechanical context, not a recovered history or strategy grade.
// Only actions_fold_drill binds this wrapper; shared donors remain unchanged.
Act0RunnerStateV1 _act0W01ExplicitFoldMechanicalContextV1(
  Act0RunnerStateV1 source,
) {
  return source.copyWith(
    teachingSteps: [
      ...source.teachingSteps,
      const Act0TeachingStepV1(
        title: 'A new mechanical example.',
        body:
            'HJ bets 2 BB after three checks. It is your turn. Calling costs 2 BB. Raising makes the price 6 BB total.',
        focusSeatIds: ['btn', 'hj'],
      ),
    ],
    table: source.table.copyWith(
      decisionSeatId: 'btn',
      activeSeatId: 'btn',
      heroSeatId: 'btn',
      handContributions: const Act0HandContributionsV1(
        throughStreet: PokerStreet.flop,
        startingStackBbBySeat: {'btn': 100},
        entries: [
          ..._act0LessonBlinds,
          Act0ContributionV1(
            PokerStreet.preflop,
            'utg',
            Act0ContributionKindV1.wager,
            1,
          ),
          Act0ContributionV1(
            PokerStreet.preflop,
            'hj',
            Act0ContributionKindV1.wager,
            1,
          ),
          Act0ContributionV1(
            PokerStreet.preflop,
            'btn',
            Act0ContributionKindV1.wager,
            1,
          ),
          Act0ContributionV1(
            PokerStreet.preflop,
            'sb',
            Act0ContributionKindV1.wager,
            0.5,
          ),
          Act0ContributionV1(
            PokerStreet.flop,
            'hj',
            Act0ContributionKindV1.wager,
            2,
          ),
        ],
      ),
      actionTrail: const [
        Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
        Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
        Act0ActionTrailItemV1(label: 'UTG calls 1 BB'),
        Act0ActionTrailItemV1(label: 'HJ calls 1 BB'),
        Act0ActionTrailItemV1(label: 'CO folds'),
        Act0ActionTrailItemV1(label: 'BTN calls 1 BB'),
        Act0ActionTrailItemV1(label: 'SB calls 1 BB'),
        Act0ActionTrailItemV1(label: 'BB checks'),
        Act0ActionTrailItemV1(label: 'Flop: SB checks'),
        Act0ActionTrailItemV1(label: 'BB checks'),
        Act0ActionTrailItemV1(label: 'UTG checks'),
        Act0ActionTrailItemV1(label: 'HJ bets 2 BB'),
        // Current-decision instruction, not an executed betting action.
        Act0ActionTrailItemV1.note(
          label: 'Hero acts',
          displayLabel: 'Your turn',
        ),
      ],
      seats: [
        for (final seat in source.table.seats)
          Act0SeatStateV1(
            seatId: seat.seatId,
            seatLabel: seat.seatLabel,
            displayName: seat.displayName,
            isHero: seat.isHero,
            isDealerButton: seat.isDealerButton,
            isSmallBlind: seat.isSmallBlind,
            isBigBlind: seat.isBigBlind,
            // These posts were collected into the preflop pot.
            blindAmountLabel: null,
            isActive: seat.seatId == 'btn',
            isTarget: seat.isTarget,
            isInHand: seat.seatId != 'co',
            isFolded: seat.seatId == 'co',
            hasActed: const ['sb', 'bb', 'utg', 'hj'].contains(seat.seatId),
            isLastAggressor: seat.seatId == 'hj',
            isOccupied: seat.isOccupied,
            stackLabel: seat.seatId == 'hj'
                ? '97 BB'
                : seat.seatId == 'co'
                ? '100 BB'
                : '99 BB',
            holeCards: seat.holeCards,
            cardsVisibleMode: seat.cardsVisibleMode,
            currentBetLabel: seat.seatId == 'hj' ? '2 BB' : '0 BB',
            bet: seat.seatId == 'hj' ? seat.bet : null,
          ),
      ],
    ),
  );
}

// Newly authored mechanical free-continuation frames for two W01 tasks only.
// The stipulated preflop raise is history, not a strategy recommendation.
Act0RunnerStateV1 _act0W01ExplicitFreeCheckContextV1(
  Act0RunnerStateV1 source, {
  String heroSeatId = 'btn',
  Act0CardStateV1 firstBoardCard = const Act0CardStateV1(
    rank: 'A',
    suit: 'h',
    tone: Act0CardToneV1.red,
  ),
}) {
  const heroCards = [
    Act0CardStateV1(rank: '9', suit: 'c'),
    Act0CardStateV1(rank: '8', suit: 'd', tone: Act0CardToneV1.red),
  ];
  final remaining = <String, String>{
    'utg': '100 BB',
    'hj': '100 BB',
    'co': heroSeatId == 'co' ? '98 BB' : '100 BB',
    'btn': heroSeatId == 'btn' ? '98 BB' : '100 BB',
    'sb': '99.5 BB',
    'bb': '98 BB',
  };
  return source.copyWith(
    caption:
        'BB checks on the flop. It is your turn and there is no bet to match.',
    table: source.table.copyWith(
      scope: Act0TableScopeV1.playedHand,
      heroCards: heroCards,
      boardCards: [
        firstBoardCard,
        const Act0CardStateV1(rank: '7', suit: 'c'),
        const Act0CardStateV1(rank: '2', suit: 'd', tone: Act0CardToneV1.red),
      ],
      streetLabel: 'Flop',
      potLabel: 'Pot 4.5 BB',
      toCallLabel: '',
      centerLabel: 'No bet faces you',
      decisionSeatId: heroSeatId,
      activeSeatId: heroSeatId,
      heroSeatId: heroSeatId,
      highlightedSeatIds: const [],
      highlightedCardIds: const [],
      selectableSeatIds: const [],
      selectedSeatId: '',
      focusCalloutLabel: '',
      handContributions: Act0HandContributionsV1(
        throughStreet: PokerStreet.flop,
        entries: [
          ..._act0LessonBlinds,
          Act0ContributionV1(
            PokerStreet.preflop,
            heroSeatId,
            Act0ContributionKindV1.wager,
            2,
          ),
          Act0ContributionV1(
            PokerStreet.preflop,
            'bb',
            Act0ContributionKindV1.wager,
            1,
          ),
        ],
      ),
      actionTrail: [
        Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
        Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
        Act0ActionTrailItemV1(label: 'UTG folds'),
        Act0ActionTrailItemV1(label: 'HJ folds'),
        if (heroSeatId == 'btn') const Act0ActionTrailItemV1(label: 'CO folds'),
        Act0ActionTrailItemV1(label: '${heroSeatId.toUpperCase()} raises 2 BB'),
        if (heroSeatId == 'co') const Act0ActionTrailItemV1(label: 'BTN folds'),
        Act0ActionTrailItemV1(label: 'SB folds'),
        Act0ActionTrailItemV1(
          label: 'BB calls 1 BB more',
          displayLabel: 'BB calls 1 more, 2 total',
        ),
        Act0ActionTrailItemV1(label: 'Flop: BB checks'),
      ],
      seats: [
        for (final seat in source.table.seats)
          Act0SeatStateV1(
            seatId: seat.seatId,
            seatLabel: seat.seatLabel,
            displayName: seat.seatId == heroSeatId
                ? 'Hero'
                : _act0DefaultSeatDisplayNameV1(seat),
            isHero: seat.seatId == heroSeatId,
            isDealerButton: seat.seatId == 'btn',
            isSmallBlind: seat.seatId == 'sb',
            isBigBlind: seat.seatId == 'bb',
            isActive: seat.seatId == heroSeatId,
            isInHand: seat.seatId == heroSeatId || seat.seatId == 'bb',
            isFolded: seat.seatId != heroSeatId && seat.seatId != 'bb',
            hasActed: seat.seatId != heroSeatId,
            isLastAggressor: false,
            stackLabel: remaining[seat.seatId],
            holeCards: seat.seatId == heroSeatId ? heroCards : const [],
            cardsVisibleMode: seat.seatId == heroSeatId
                ? Act0CardsVisibleModeV1.faceUp
                : Act0CardsVisibleModeV1.none,
          ),
      ],
    ),
  );
}

// Newly authored full price context for this one mechanical Call question.
// Shared Call templates and their later-world descendants remain unchanged.
Act0RunnerStateV1 _act0W01ExplicitCallPriceContextV1(Act0RunnerStateV1 source) {
  const remaining = <String, String>{
    'utg': '100 BB',
    'hj': '98 BB',
    'co': '100 BB',
    'btn': '99 BB',
    'sb': '99 BB',
    'bb': '99 BB',
  };
  return source.copyWith(
    caption:
        'HJ bets 1 BB on the flop. It is your turn. Raising makes the price 4 BB total.',
    table: source.table.copyWith(
      decisionSeatId: 'btn',
      activeSeatId: 'btn',
      heroSeatId: 'btn',
      highlightedSeatIds: const [],
      highlightedCardIds: const [],
      focusCalloutLabel: '',
      selectedSeatId: '',
      handContributions: const Act0HandContributionsV1(
        throughStreet: PokerStreet.flop,
        startingStackBbBySeat: {'btn': 100},
        entries: [
          ..._act0LessonBlinds,
          Act0ContributionV1(
            PokerStreet.preflop,
            'hj',
            Act0ContributionKindV1.wager,
            1,
          ),
          Act0ContributionV1(
            PokerStreet.preflop,
            'btn',
            Act0ContributionKindV1.wager,
            1,
          ),
          Act0ContributionV1(
            PokerStreet.preflop,
            'sb',
            Act0ContributionKindV1.wager,
            0.5,
          ),
          Act0ContributionV1(
            PokerStreet.flop,
            'hj',
            Act0ContributionKindV1.wager,
            1,
          ),
        ],
      ),
      actionTrail: const [
        Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
        Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
        Act0ActionTrailItemV1(label: 'UTG folds'),
        Act0ActionTrailItemV1(label: 'HJ calls 1 BB'),
        Act0ActionTrailItemV1(label: 'CO folds'),
        Act0ActionTrailItemV1(label: 'BTN calls 1 BB'),
        Act0ActionTrailItemV1(
          label: 'SB calls 0.5 BB more',
          displayLabel: 'SB calls 0.5 more, 1 total',
        ),
        Act0ActionTrailItemV1(label: 'BB checks'),
        Act0ActionTrailItemV1(label: 'Flop: SB checks'),
        Act0ActionTrailItemV1(label: 'Flop: BB checks'),
        Act0ActionTrailItemV1(label: 'Flop: HJ bets 1 BB'),
      ],
      seats: [
        for (final seat in source.table.seats)
          Act0SeatStateV1(
            seatId: seat.seatId,
            seatLabel: seat.seatLabel,
            displayName: seat.displayName,
            isHero: seat.seatId == 'btn',
            isDealerButton: seat.seatId == 'btn',
            isSmallBlind: seat.seatId == 'sb',
            isBigBlind: seat.seatId == 'bb',
            isActive: seat.seatId == 'btn',
            isInHand: seat.seatId != 'utg' && seat.seatId != 'co',
            isFolded: seat.seatId == 'utg' || seat.seatId == 'co',
            hasActed: seat.seatId != 'btn',
            isLastAggressor: seat.seatId == 'hj',
            stackLabel: remaining[seat.seatId],
            holeCards: seat.seatId == 'btn' ? seat.holeCards : const [],
            cardsVisibleMode: seat.seatId == 'btn'
                ? seat.cardsVisibleMode
                : Act0CardsVisibleModeV1.none,
            currentBetLabel: seat.seatId == 'hj' ? '1 BB' : null,
            bet: seat.seatId == 'hj'
                ? const Act0SeatBetStateV1(
                    kind: Act0SeatBetKindV1.bet,
                    label: 'Bet',
                    amountLabel: '1 BB',
                  )
                : null,
          ),
      ],
    ),
  );
}

final _blindsOrderRunner = _meetTableRunner.copyWith(
  lessonId: 'blinds_action_order',
  lessonTitle: 'Blinds & action order',
  lessonSubtitle: 'The blinds seed the pot before the hand begins.',
  caption: 'SB and BB post before cards are played.',
  hint: 'The first decision comes after the big blind.',
  question: 'Which blind posts 1 BB?',
  options: <Act0RunnerOptionV1>[
    const Act0RunnerOptionV1(
      id: 'button_is_not_a_blind',
      label: 'BTN',
      seatId: 'btn',
      isCorrect: false,
      preferredLabel: 'BB',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'The button is a position.',
      feedbackReason:
          'BTN marks the dealer button. BB posts the full 1 BB blind.',
    ),
    ..._bigBlindPostRunner.options,
  ],
  feedbackTitle: 'The big blind sets the unit.',
  feedbackReason:
      'BB posts the full 1 BB blind. SB posts 0.5 BB in this lesson.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Blinds force a starting pot.',
      body:
          'Blinds are real chips or money put in first. Players often count them in big blinds because BB is the clean shortcut for the price.',
      focusSeatIds: <String>['sb', 'bb'],
      focusLabels: <String>['Real money', 'Count in BB'],
    ),
    Act0TeachingStepV1(
      title: 'Action starts after BB.',
      body:
          'BB is a unit for chips. A bet of 3 BB is three times the big blind. UTG is first to choose before the flop.',
      focusSeatIds: <String>['utg', 'bb'],
      focusLabels: <String>['1 BB unit', 'UTG first'],
    ),
  ],
);

// New owner-admitted independent teaching hands. No old history is inferred.
enum _Act0W01OrderFrameV1 { first, option, flop }

Act0RunnerStateV1 _act0W01ExplicitOrderRunnerV1(
  Act0RunnerStateV1 source, {
  required _Act0W01OrderFrameV1 frame,
  required String taskId,
  String? question,
}) {
  final flop = frame == _Act0W01OrderFrameV1.flop;
  final matched = frame != _Act0W01OrderFrameV1.first;
  final actor = flop
      ? 'sb'
      : matched
      ? 'bb'
      : 'utg';
  final hero = switch (taskId) {
    'positions_utg' || 'blinds_first_actor' => 'hj',
    'blinds_last_actor' || 'blinds_review' => 'co',
    'positions_early_late' => 'hj',
    _ => 'co',
  };
  const cards = <Act0CardStateV1>[
    Act0CardStateV1(rank: '?', suit: ''),
    Act0CardStateV1(rank: '?', suit: ''),
  ];
  final trail = <Act0ActionTrailItemV1>[
    const Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
    const Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
    if (matched) ...const [
      Act0ActionTrailItemV1(label: 'UTG calls 1 BB'),
      Act0ActionTrailItemV1(label: 'HJ calls 1 BB'),
      Act0ActionTrailItemV1(label: 'CO calls 1 BB'),
      Act0ActionTrailItemV1(label: 'BTN calls 1 BB'),
      Act0ActionTrailItemV1(
        label: 'SB calls 0.5 BB more',
        displayLabel: 'SB calls 0.5 more, 1 total',
      ),
    ],
    if (flop) const Act0ActionTrailItemV1(label: 'BB checks'),
  ];
  final seats = <Act0SeatStateV1>[
    for (final id in const ['utg', 'hj', 'co', 'btn', 'sb', 'bb'])
      Act0SeatStateV1(
        seatId: id,
        seatLabel: id.toUpperCase(),
        displayName: id == hero ? 'Hero' : id.toUpperCase(),
        isHero: id == hero,
        isDealerButton: id == 'btn',
        isSmallBlind: id == 'sb',
        isBigBlind: id == 'bb',
        blindAmountLabel: flop
            ? null
            : id == 'sb'
            ? '0.5 BB'
            : id == 'bb'
            ? '1 BB'
            : null,
        // Remaining chips, not the starting 100 BB.
        stackLabel: matched || id == 'bb'
            ? '99 BB'
            : id == 'sb'
            ? '99.5 BB'
            : '100 BB',
        hasActed: !flop && matched && id != 'bb',
        holeCards: cards,
        cardsVisibleMode: Act0CardsVisibleModeV1.faceDown,
        currentBetLabel: flop
            ? null
            : matched || id == 'bb'
            ? '1 BB'
            : id == 'sb'
            ? '0.5 BB'
            : null,
        bet: flop || (!matched && id != 'sb' && id != 'bb')
            ? null
            : Act0SeatBetStateV1(
                kind: id == 'bb' || (!matched && id == 'sb')
                    ? Act0SeatBetKindV1.post
                    : Act0SeatBetKindV1.call,
                label: id == 'bb' || (!matched && id == 'sb') ? 'Post' : 'Call',
                amountLabel: matched || id == 'bb' ? '1 BB' : '0.5 BB',
              ),
      ),
  ];
  final context = flop
      ? 'All six players are still in the hand. No one has acted on the flop yet. Read the first pass around the table.'
      : matched
      ? 'Everyone has matched 1 BB. The big blind has yet to choose an action.'
      : 'The blinds have posted. No one has made a choice yet.';
  return source.copyWith(
    caption: context,
    question: question,
    hint: taskId == 'positions_review'
        ? source.hint
        : flop
        ? 'After the flop, count from the first live seat left of the button. BTN is last.'
        : 'Before the flop, start right after the big blind. BB is last.',
    feedbackReason: flop
        ? 'In the first pass after the flop, BTN comes after SB, BB, UTG, HJ and CO.'
        : matched
        ? 'After the five stated matches, BB has chips behind and has not acted voluntarily, so BB has the next option.'
        : 'In this six-seat preflop order, UTG acts before BTN.',
    options: [
      for (final o in source.options)
        Act0RunnerOptionV1(
          id: o.id,
          label: flop && o.seatId == 'btn' ? 'BTN' : o.label,
          amountLabel: o.amountLabel,
          seatId: o.seatId,
          isCorrect: o.isCorrect,
          preferredLabel: flop ? 'BTN' : o.preferredLabel,
          betterAnswerLabel: flop ? 'BTN' : o.betterAnswerLabel,
          quality: o.quality,
          feedbackTitle: o.feedbackTitle,
          feedbackReason: taskId == 'positions_early_late'
              ? (o.seatId == 'utg'
                    ? 'Five players can still act after UTG. The Button has only the two blinds behind.'
                    : 'Only the two blinds can act after the Button on this first pass.')
              : taskId == 'positions_late_seat'
              ? (o.seatId == 'btn'
                    ? 'The Button sees the earlier checks before choosing a response. UTG has less information when it acts.'
                    : 'UTG cannot act on a decision it has not seen. The Button can use the check before choosing.')
              : taskId == 'positions_utg'
              ? (o.seatId == 'utg'
                    ? 'UTG names the seat immediately after BB in this preflop order.'
                    : o.feedbackReason)
              : o.feedbackReason,
          repairFocusSeatIds: o.repairFocusSeatIds,
          repairFocusCardIds: o.repairFocusCardIds,
          repairFocusLabels: o.repairFocusLabels,
        ),
    ],
    table: source.table.copyWith(
      scope: Act0TableScopeV1.playedHand,
      seats: seats,
      heroCards: cards,
      boardCards: flop
          ? const [
              Act0CardStateV1(rank: '7', suit: 'h'),
              Act0CardStateV1(rank: '8', suit: 's'),
              Act0CardStateV1(rank: '2', suit: 'c'),
            ]
          : const [],
      streetLabel: flop ? 'Flop' : 'Preflop',
      potLabel: matched ? 'Pot 6 BB' : 'Pot 1.5 BB',
      toCallLabel: '',
      centerLabel: flop ? 'First pass on the flop' : 'Initial preflop pass',
      focusCalloutLabel: '',
      handContributions: Act0HandContributionsV1(
        throughStreet: flop ? PokerStreet.flop : PokerStreet.preflop,
        entries: [
          ..._act0LessonBlinds,
          if (matched) ...const [
            Act0ContributionV1(
              PokerStreet.preflop,
              'utg',
              Act0ContributionKindV1.wager,
              1,
            ),
            Act0ContributionV1(
              PokerStreet.preflop,
              'hj',
              Act0ContributionKindV1.wager,
              1,
            ),
            Act0ContributionV1(
              PokerStreet.preflop,
              'co',
              Act0ContributionKindV1.wager,
              1,
            ),
            Act0ContributionV1(
              PokerStreet.preflop,
              'btn',
              Act0ContributionKindV1.wager,
              1,
            ),
            Act0ContributionV1(
              PokerStreet.preflop,
              'sb',
              Act0ContributionKindV1.wager,
              0.5,
            ),
          ],
        ],
      ),
      actionTrail: trail,
      activeSeatId: '',
      decisionSeatId: actor,
      heroSeatId: hero,
      highlightedSeatIds: const [],
      highlightedCardIds: const [],
      selectedSeatId: '',
    ),
    teachingSteps: [
      Act0TeachingStepV1(
        title: flop
            ? 'After the flop, the button acts last.'
            : 'Preflop starts after the big blind.',
        body: flop
            ? 'From the flop on, the first live seat left of the button acts first. BTN acts last on every later street.'
            : 'Before the flop, UTG acts first, right after the big blind. Then HJ, CO, BTN and SB act, and BB acts last.',
        focusLabels: const ['Street', 'Recorded actions', 'Chips behind'],
      ),
    ],
  );
}

final _firstPreflopActorRunner = _meetTableRunner.copyWith(
  lessonId: 'first_preflop_actor',
  lessonTitle: 'Blinds & action order',
  caption: 'Preflop starts left of the big blind.',
  hint: 'Tap the first preflop actor.',
  question: 'Tap UTG.',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'utg',
      label: 'UTG',
      seatId: 'utg',
      isCorrect: true,
      preferredLabel: 'UTG',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'UTG acts first preflop.',
      feedbackReason: 'UTG acts first before the flop.',
    ),
    Act0RunnerOptionV1(
      id: 'btn',
      label: 'BTN',
      seatId: 'btn',
      isCorrect: false,
      preferredLabel: 'UTG',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason: 'The Button acts late, not first preflop.',
    ),
  ],
  table: _meetTableRunner.table.copyWith(
    selectableSeatIds: const <String>['utg', 'btn'],
    highlightedSeatIds: const <String>['utg'],
    activeSeatId: 'utg',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Preflop begins after BB.',
      body: 'The first seat left of the big blind is UTG.',
      focusSeatIds: <String>['utg', 'bb'],
      focusLabels: <String>['UTG first'],
    ),
  ],
);

final _lastPreflopActorRunner = _meetTableRunner.copyWith(
  lessonId: 'last_preflop_actor',
  lessonTitle: 'Blinds & action order',
  caption: 'The big blind closes preflop when nobody raises.',
  hint: 'Tap the last preflop actor.',
  question: 'Tap BB.',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'bb',
      label: 'BB',
      seatId: 'bb',
      isCorrect: true,
      preferredLabel: 'BB',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Sharp read.',
      feedbackReason: 'The big blind can act last before the flop.',
    ),
    Act0RunnerOptionV1(
      id: 'sb',
      label: 'SB',
      seatId: 'sb',
      isCorrect: false,
      preferredLabel: 'BB',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason: 'The small blind acts before the big blind preflop.',
    ),
  ],
  table: _meetTableRunner.table.copyWith(
    selectableSeatIds: const <String>['bb', 'sb'],
    highlightedSeatIds: const <String>['bb'],
    activeSeatId: 'bb',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Same BB, new job.',
      body:
          'After posting the full blind, the big blind can still act last preflop if nobody raises.',
      focusSeatIds: <String>['bb'],
      focusLabels: <String>['BB last preflop'],
    ),
  ],
);

const _lastSeatAfterFlopChoices = <Act0RunnerOptionV1>[
  Act0RunnerOptionV1(
    id: 'btn',
    label: 'BTN',
    seatId: 'btn',
    isCorrect: true,
    preferredLabel: 'BTN',
    quality: Act0FeedbackQualityV1.correct,
    feedbackTitle: 'BTN acts last after the flop.',
    feedbackReason: 'Button acts last after the flop in this hand.',
  ),
  Act0RunnerOptionV1(
    id: 'utg',
    label: 'UTG',
    seatId: 'utg',
    isCorrect: false,
    preferredLabel: 'BTN',
    quality: Act0FeedbackQualityV1.wrong,
    feedbackTitle: 'Not quite.',
    feedbackReason:
        'UTG is early, not the seat that acts last after the flop here.',
  ),
];

final _postflopButtonActorRunner = _meetTableRunner.copyWith(
  lessonId: 'postflop_button_actor',
  lessonTitle: 'Blinds & action order',
  caption: 'After the flop, Button often acts last.',
  hint: 'Trace one full round in the order shown.',
  question: 'Tap the seat that acts last after the flop.',
  options: _lastSeatAfterFlopChoices,
  table: _readBoardRunner.table.copyWith(
    handContributions: _act0FivePlayerPositionPot,
    selectableSeatIds: const <String>['btn', 'utg'],
    highlightedSeatIds: const <String>['btn'],
    activeSeatId: 'btn',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Order after the flop.',
      body: 'After the flop, blinds act early and Button often acts last.',
      focusSeatIds: <String>['btn', 'sb', 'bb'],
      focusLabels: <String>['BTN late'],
    ),
  ],
);

final _w3BtnLastPostflopRepairRunner = _postflopButtonActorRunner.copyWith(
  lessonId: 'w3_repair_btn_last_postflop',
  lessonTitle: 'Button advantage',
  caption: 'Read the first pass after the flop.',
  hint: 'Trace one full round in the order shown.',
  feedbackTitle: 'BTN-last repaired.',
  feedbackReason: 'Button acts after the blinds on the flop in this hand.',
  question: 'Which seat would end the first round of decisions after the flop?',
  options: _lastSeatAfterFlopChoices,
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Read the order after the flop.',
      body: 'After the flop, Button is the late seat and acts last here.',
      focusSeatIds: <String>['btn'],
      focusLabels: <String>['BTN acts last after the flop'],
    ),
  ],
);

final _positionsRunner = _meetTableRunner.copyWith(
  lessonId: 'positions',
  lessonTitle: 'The 6 positions',
  lessonSubtitle: 'Every seat has a name.',
  caption: 'The six seats are UTG, HJ, CO, BTN, SB, and BB.',
  hint: 'Follow the order from the blinds around the table.',
  question: 'Which seat is the Button?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'top',
      label: 'UTG',
      seatId: 'utg',
      isCorrect: false,
      preferredLabel: 'BTN',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Read the seat marker and order.',
      feedbackReason:
          'UTG is the first seat after the blinds. The dealer marker is at another seat.',
    ),
    Act0RunnerOptionV1(
      id: 'bottom',
      label: 'BTN',
      seatId: 'btn',
      isCorrect: true,
      preferredLabel: 'BTN',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'You found the seat.',
      feedbackReason: 'BTN marks the dealer button in this hand.',
    ),
    Act0RunnerOptionV1(
      id: 'random',
      label: 'BB',
      seatId: 'bb',
      isCorrect: false,
      preferredLabel: 'BTN',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Read the seat marker and order.',
      feedbackReason:
          'BB posts the big blind. It does not hold the dealer marker here.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Read the seat labels.',
      body:
          'BTN is Button. UTG means Under the Gun. HJ is Hijack. CO is Cutoff. Blinds are forced bets before the cards are played.',
    ),
    Act0TeachingStepV1(
      title: 'Seats have names.',
      body:
          'UTG means under the gun, the first seat to act. HJ is hijack. CO is cutoff. BTN is button, and SB plus BB are the blinds.',
      focusLabels: <String>['UTG', 'HJ', 'CO', 'BTN', 'SB', 'BB'],
    ),
    Act0TeachingStepV1(
      title: 'Position changes information.',
      body: 'Late seats see more actions before they decide.',
      focusSeatIds: <String>['btn', 'utg'],
      focusLabels: <String>['Early', 'Late'],
    ),
  ],
);

const _dealerMarkerChoices = <Act0RunnerOptionV1>[
  Act0RunnerOptionV1(
    id: 'btn',
    label: 'BTN',
    seatId: 'btn',
    isCorrect: true,
    preferredLabel: 'BTN',
    quality: Act0FeedbackQualityV1.correct,
    feedbackTitle: 'BTN seat found.',
    feedbackReason: 'BTN is the dealer button and acts last after the flop.',
  ),
  Act0RunnerOptionV1(
    id: 'co',
    label: 'CO',
    seatId: 'co',
    isCorrect: false,
    preferredLabel: 'BTN',
    quality: Act0FeedbackQualityV1.wrong,
    feedbackTitle: 'Not quite.',
    feedbackReason: 'CO is one seat before the Button.',
  ),
];

final _buttonSeatRunner = _meetTableRunner.copyWith(
  lessonId: 'button_seat',
  lessonTitle: 'The 6 positions',
  caption: 'Button is the dealer seat in this hand.',
  hint: 'Find the dealer marker beside a seat.',
  question: 'Tap the Button.',
  options: _dealerMarkerChoices,
  table: _meetTableRunner.table.copyWith(
    selectableSeatIds: const <String>['btn', 'co'],
    highlightedSeatIds: const <String>['btn'],
    activeSeatId: 'btn',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'BTN marks the Button.',
      body: 'The dealer button shows the late seat for this hand.',
      focusSeatIds: <String>['btn'],
      focusLabels: <String>['BTN'],
    ),
  ],
);

const _earliestSeatChoices = <Act0RunnerOptionV1>[
  Act0RunnerOptionV1(
    id: 'utg',
    label: 'UTG',
    seatId: 'utg',
    isCorrect: true,
    preferredLabel: 'UTG',
    quality: Act0FeedbackQualityV1.correct,
    feedbackTitle: 'UTG seat found.',
    feedbackReason: 'UTG acts first preflop, so UTG should open fewer hands.',
  ),
  Act0RunnerOptionV1(
    id: 'hj',
    label: 'HJ',
    seatId: 'hj',
    isCorrect: false,
    preferredLabel: 'UTG',
    quality: Act0FeedbackQualityV1.wrong,
    feedbackTitle: 'Not quite.',
    feedbackReason: 'HJ is after UTG in this order.',
  ),
];

final _utgSeatRunner = _meetTableRunner.copyWith(
  lessonId: 'utg_seat',
  lessonTitle: 'The 6 positions',
  caption: 'UTG is the earliest preflop seat.',
  hint: 'Tap UTG.',
  question: 'Tap UTG.',
  options: _earliestSeatChoices,
  table: _meetTableRunner.table.copyWith(
    selectableSeatIds: const <String>['utg', 'hj'],
    highlightedSeatIds: const <String>['utg'],
    activeSeatId: 'utg',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'UTG is early.',
      body: 'UTG acts first preflop and has the least information.',
      focusSeatIds: <String>['utg'],
      focusLabels: <String>['Early seat'],
    ),
  ],
);

final _w3SeatIdBtnRepairRunner = _buttonSeatRunner.copyWith(
  // The repair teaching step can point to BTN. The fresh choice cannot.
  table: _buttonSeatRunner.table.copyWith(
    highlightedSeatIds: const <String>[],
    activeSeatId: '',
  ),
  lessonId: 'w3_repair_seat_id_btn',
  caption: 'Find the dealer marker.',
  hint: 'Find the dealer marker at one of the seats.',
  feedbackTitle: 'BTN repaired.',
  feedbackReason: 'BTN is the Button seat and the late-position anchor.',
  question: 'Which of the shown seats has the dealer marker?',
  options: _dealerMarkerChoices,
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Repair the Button seat.',
      body: 'BTN is the seat marked by the dealer button.',
      focusSeatIds: <String>['btn'],
      focusLabels: <String>['Button seat'],
    ),
  ],
);

final _w3SeatIdUtgRepairRunner = _utgSeatRunner.copyWith(
  table: _utgSeatRunner.table.copyWith(
    highlightedSeatIds: const <String>[],
    activeSeatId: '',
  ),
  lessonId: 'w3_repair_seat_id_utg',
  caption: 'Read the first seat after the blind.',
  hint: 'Find the first seat after the big blind.',
  feedbackTitle: 'UTG repaired.',
  feedbackReason:
      'UTG is the early seat that acts first before the rest of the table.',
  question: 'Which seat is next clockwise after the big blind?',
  options: _earliestSeatChoices,
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Repair the UTG seat.',
      body: 'UTG is the first preflop seat after the blinds are posted.',
      focusSeatIds: <String>['utg'],
      focusLabels: <String>['UTG seat'],
    ),
  ],
);

Act0RunnerStateV1 _w3SeatRecognitionRunnerV1({
  required String lessonId,
  required String caption,
  required String hint,
  required String question,
  required String correctSeatId,
  required String correctLabel,
  required String distractorSeatId,
  required String distractorLabel,
  required String feedbackTitle,
  required String feedbackReason,
  List<String>? highlightedSeatIds,
  List<String> focusLabels = const <String>[],
}) {
  final highlighted = highlightedSeatIds ?? <String>[correctSeatId];
  return _meetTableRunner.copyWith(
    lessonId: lessonId,
    lessonTitle: 'The 6 positions',
    lessonSubtitle: 'Position Thinking',
    caption: caption,
    hint: hint,
    question: question,
    options: <Act0RunnerOptionV1>[
      Act0RunnerOptionV1(
        id: correctSeatId,
        label: correctLabel,
        seatId: correctSeatId,
        isCorrect: true,
        preferredLabel: correctLabel,
        quality: Act0FeedbackQualityV1.correct,
        feedbackTitle: feedbackTitle,
        feedbackReason: feedbackReason,
      ),
      Act0RunnerOptionV1(
        id: distractorSeatId,
        label: distractorLabel,
        seatId: distractorSeatId,
        isCorrect: false,
        preferredLabel: correctLabel,
        betterAnswerLabel: correctLabel,
        quality: Act0FeedbackQualityV1.wrong,
        feedbackTitle: 'Check the seat label.',
        feedbackReason:
            '$distractorLabel is close, but this drill is asking for $correctLabel.',
      ),
    ],
    table: _meetTableRunner.table.copyWith(
      selectableSeatIds: <String>[correctSeatId, distractorSeatId],
      // W3 identification is the question: do not pre-highlight the answer.
      // Teaching-step focus remains authored and appears during explanation.
      highlightedSeatIds: const <String>[],
      activeSeatId: '',
    ),
    teachingSteps: <Act0TeachingStepV1>[
      Act0TeachingStepV1(
        title: '$correctLabel recognition.',
        body: feedbackReason,
        focusSeatIds: highlighted,
        focusLabels: focusLabels.isEmpty ? <String>[correctLabel] : focusLabels,
      ),
    ],
  );
}

final _w3SixSeatsIntroRunner = _positionsRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w3_six_seats_intro',
  lessonTitle: 'The 6 positions',
  lessonSubtitle: 'Position Thinking',
  caption: 'Six seats, one order.',
  hint:
      'Use the table labels first. Button and blinds are only part of the map.',
  question: 'Read the seat order.',
  options: const <Act0RunnerOptionV1>[],
  feedbackTitle: 'Six-seat map.',
  feedbackReason: 'Recognize every seat label before using position to decide.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'All six seats matter.',
      body: 'Clockwise from UTG: HJ, CO, BTN, SB, BB.',
      focusLabels: <String>['UTG', 'HJ', 'CO', 'BTN', 'SB', 'BB'],
    ),
  ],
);

final _w3SeatIdUtgRunner = _w3SeatRecognitionRunnerV1(
  lessonId: 'w3_seat_id_utg',
  caption: 'Find the first non-blind seat before the flop.',
  hint: 'Start at the seat after the blinds, then read the label.',
  question: 'Tap UTG.',
  correctSeatId: 'utg',
  correctLabel: 'UTG',
  distractorSeatId: 'hj',
  distractorLabel: 'HJ',
  feedbackTitle: 'UTG recognized.',
  feedbackReason: 'UTG is the first non-blind seat to act before the flop.',
  focusLabels: <String>['First preflop'],
);

final _w3SeatIdHjRunner = _w3SeatRecognitionRunnerV1(
  lessonId: 'w3_seat_id_hj',
  caption: 'Find the seat after UTG.',
  hint: 'Choose the one directly after UTG.',
  question: 'Tap HJ.',
  correctSeatId: 'hj',
  correctLabel: 'HJ',
  distractorSeatId: 'co',
  distractorLabel: 'CO',
  feedbackTitle: 'HJ recognized.',
  feedbackReason: 'HJ sits after UTG and before CO.',
  highlightedSeatIds: <String>['hj', 'co'],
  focusLabels: <String>['After UTG', 'Before CO'],
);

final _w3SeatIdCoRunner = _w3SeatRecognitionRunnerV1(
  lessonId: 'w3_seat_id_co',
  caption: 'Find the seat directly before the Button.',
  hint: 'Do not use the blind markers; read the seat before BTN.',
  question: 'Tap CO.',
  correctSeatId: 'co',
  correctLabel: 'CO',
  distractorSeatId: 'hj',
  distractorLabel: 'HJ',
  feedbackTitle: 'CO recognized.',
  feedbackReason: 'CO is the cutoff, one seat before the Button.',
  highlightedSeatIds: <String>['hj', 'co', 'btn'],
  focusLabels: <String>['Before BTN'],
);

final _w3SeatIdBtnRunner = _w3SeatRecognitionRunnerV1(
  lessonId: 'w3_seat_id_btn',
  caption: 'Find the dealer-button seat.',
  hint: 'The Button anchors late position.',
  question: 'Tap BTN.',
  correctSeatId: 'btn',
  correctLabel: 'BTN',
  distractorSeatId: 'co',
  distractorLabel: 'CO',
  feedbackTitle: 'BTN recognized.',
  feedbackReason: 'BTN is the dealer-button seat and late-position anchor.',
  focusLabels: <String>['Dealer button'],
);

final _w3SeatIdSbRunner = _w3SeatRecognitionRunnerV1(
  lessonId: 'w3_seat_id_sb',
  caption: 'Find the smaller blind next to the Button.',
  hint: 'One blind posts half the big blind.',
  question: 'Tap SB.',
  correctSeatId: 'sb',
  correctLabel: 'SB',
  distractorSeatId: 'bb',
  distractorLabel: 'BB',
  feedbackTitle: 'SB recognized.',
  feedbackReason: 'SB is the small blind, posted before the big blind.',
  highlightedSeatIds: <String>['btn', 'sb', 'bb'],
  focusLabels: <String>['Small blind'],
);

final _w3SeatIdBbRunner = _w3SeatRecognitionRunnerV1(
  lessonId: 'w3_seat_id_bb',
  caption: 'Find the full blind seat.',
  hint: 'The big blind is the larger forced blind.',
  question: 'Tap BB.',
  correctSeatId: 'bb',
  correctLabel: 'BB',
  distractorSeatId: 'sb',
  distractorLabel: 'SB',
  feedbackTitle: 'BB recognized.',
  feedbackReason: 'BB is the big blind, the full forced blind before the hand.',
  highlightedSeatIds: <String>['sb', 'bb'],
  focusLabels: <String>['Big blind'],
);

final _w3SixSeatsRecapRunner = _w3SixSeatsIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w3_six_seats_recap',
  caption: 'Use all six seats.',
  hint: 'Read all six labels before using position.',
  question: 'Which list names the six seats?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'six_seats',
      label: 'UTG, HJ, CO, BTN, SB, BB',
      isCorrect: true,
      preferredLabel: 'UTG, HJ, CO, BTN, SB, BB',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Six-seat map complete.',
      feedbackReason:
          'Those are the six seat labels used by this table before position decisions.',
    ),
    Act0RunnerOptionV1(
      id: 'only_blinds',
      label: 'BTN, SB, and BB',
      isCorrect: false,
      preferredLabel: 'UTG, HJ, CO, BTN, SB, BB',
      betterAnswerLabel: 'UTG, HJ, CO, BTN, SB, BB',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too narrow.',
      feedbackReason:
          'Count all six seats, including the three between the big blind and the Button.',
    ),
  ],
);

const _laterSeatChoices = <Act0RunnerOptionV1>[
  Act0RunnerOptionV1(
    id: 'btn',
    label: 'BTN',
    seatId: 'btn',
    isCorrect: true,
    preferredLabel: 'BTN',
    quality: Act0FeedbackQualityV1.correct,
    feedbackTitle: 'Late seat found.',
    feedbackReason: 'BTN is late and often acts last after the flop.',
  ),
  Act0RunnerOptionV1(
    id: 'utg',
    label: 'UTG',
    seatId: 'utg',
    isCorrect: false,
    preferredLabel: 'BTN',
    quality: Act0FeedbackQualityV1.wrong,
    feedbackTitle: 'Not quite.',
    feedbackReason: 'UTG is early and has less information.',
  ),
];

final _latePositionRunner = _meetTableRunner.copyWith(
  lessonId: 'late_position',
  lessonTitle: 'The 6 positions',
  caption: 'Late seats see more actions before deciding.',
  hint: 'Button is the clearest late seat.',
  question: 'Which seat acts latest after the flop?',
  options: _laterSeatChoices,
  table: _meetTableRunner.table.copyWith(
    selectableSeatIds: const <String>['btn', 'utg'],
    highlightedSeatIds: const <String>['btn'],
    activeSeatId: 'btn',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Late means more information.',
      body:
          'Postflop means after the flop. The Button sees the other choices before it acts.',
      focusSeatIds: <String>['btn'],
      focusLabels: <String>['Late seat'],
    ),
  ],
);

final _handRankingsRunner = _readBoardRunner.copyWith(
  lessonId: 'hand_rankings_table',
  lessonTitle: 'Hand rankings, on the table',
  caption: 'Hands are compared by their best five cards.',
  hint: 'A pair beats one high card.',
  question: 'What hand do you have here?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'pair',
      label: 'Pair',
      isCorrect: true,
      preferredLabel: 'Pair',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Pair found.',
      feedbackReason: 'You have a pair with the board.',
    ),
    Act0RunnerOptionV1(
      id: 'high_card',
      label: 'High card',
      isCorrect: false,
      preferredLabel: 'Pair',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason: 'A matching rank makes a pair.',
    ),
  ],
  table: _readBoardRunner.table.copyWith(
    handContributions: _act0BoardReadingContributionsV1(PokerStreet.flop),
    heroCards: _heroAkCards,
    highlightedCardIds: const <String>['hero_0', 'board_0'],
    seats: _readBoardRunner.table.seats
        .map(
          (seat) => seat.seatId == 'btn'
              ? _act0CopySeatStateV1(seat, holeCards: _heroAkCards)
              : seat,
        )
        .toList(growable: false),
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Hands use the best five cards.',
      body: 'You combine private cards with the board, then compare hand rank.',
      focusCardIds: <String>['hero_0', 'hero_1', 'board_0', 'board_1'],
      focusLabels: <String>['Best five'],
    ),
    Act0TeachingStepV1(
      title: 'A pair beats high card.',
      body: 'Matching ranks make the first made hand beginners need.',
      focusLabels: <String>['Pair'],
    ),
  ],
);

final _handRankingIntroRunner = _handRankingsRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'hand_ranking_intro',
  caption: 'Hand rank names describe made hands.',
  hint: 'Start with high card, a pair, two pair, and three of a kind.',
  question: 'What do hand rankings compare?',
  feedbackTitle: 'Rankings compare hand strength.',
  feedbackReason: 'Hand rankings tell which made hand is stronger.',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'hand_strength',
      label: 'Hand strength',
      isCorrect: true,
      preferredLabel: 'Hand strength',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Hand strength is the comparison.',
      feedbackReason:
          'Rankings tell which made hand is stronger. A pair beats high card.',
    ),
    Act0RunnerOptionV1(
      id: 'seat_position',
      label: 'Seat order',
      isCorrect: false,
      preferredLabel: 'Hand strength',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Seat order is a different concept.',
      feedbackReason: 'Seat order affects action order, not the hand ranking.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Ranking ladder.',
      body:
          'Learn the first four ranks in order: high card, a pair, two pair, and three of a kind.',
      focusLabels: <String>['High card', 'Pair', 'Two pair', 'Three of a kind'],
    ),
  ],
);

final _flushRankRunner = _readBoardRunner.copyWith(
  lessonId: 'flush_rank',
  lessonTitle: 'Hand rankings, on the table',
  caption: 'You and the other player both show completed five-card hands.',
  hint: 'Compare the suit pattern and the rank sequence before choosing.',
  question: 'Which hand ranks higher?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'flush',
      label: 'Flush',
      isCorrect: true,
      preferredLabel: 'Flush',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Flush found.',
      feedbackReason:
          'Start with the suit match: five cards of one suit make a flush, and a flush ranks above a straight.',
    ),
    Act0RunnerOptionV1(
      id: 'straight',
      label: 'Straight',
      isCorrect: false,
      preferredLabel: 'Flush',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'A straight uses connected ranks, but it does not need five cards of one suit, so it stays below a flush.',
    ),
  ],
  table: _readBoardRunner.table.copyWith(
    handContributions: _act0FivePlayerComparisonPot,
    streetLabel: 'River',
    heroCards: _heroKhQhCards,
    boardCards: _boardFlushVsStraight,
    highlightedCardIds: const <String>[
      'hero_0',
      'hero_1',
      'board_0',
      'board_1',
      'board_2',
    ],
    centerLabel: 'Two completed hands',
    seats: _readBoardRunner.table.seats
        .map(
          (seat) => seat.seatId == 'btn'
              ? _act0CopySeatStateV1(
                  seat,
                  holeCards: _heroKhQhCards,
                  cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
                )
              : seat.seatId == 'co'
              ? _act0CopySeatStateV1(
                  seat,
                  holeCards: _opponent8c9sCards,
                  cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
                  isActive: false,
                )
              : seat,
        )
        .toList(growable: false),
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Flush means same suit.',
      body:
          'You use five hearts for a flush. The other player reaches a 7-8-9-T-J straight. This is an ace-high flush, not a royal flush, because the hearts do not run T-J-Q-K-A. A flush ranks above a straight.',
      focusLabels: <String>[
        'Same suit',
        'Ace-high flush',
        'Not royal',
        'Rarer = higher',
      ],
    ),
  ],
);

final _fullHouseRankRunner = _riverBoardRunner.copyWith(
  lessonId: 'full_house_rank',
  lessonTitle: 'Hand rankings, on the table',
  caption: 'A full house is three of one rank plus two of another.',
  hint: 'Trips plus a pair make a full house.',
  question: 'What hand do you have here?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'full_house',
      label: 'Full house',
      isCorrect: true,
      preferredLabel: 'Full house',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Full house found.',
      feedbackReason:
          'You use A-A-A with 7-7, which makes a full house. That rank sits above a flush because the hand is stronger and rarer.',
    ),
    Act0RunnerOptionV1(
      id: 'trips',
      label: 'Three of a kind',
      isCorrect: false,
      preferredLabel: 'Full house',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'One pair short.',
      feedbackReason:
          'You have three aces and a pair of sevens. Together they make a full house.',
    ),
  ],
  table: _riverBoardRunner.table.copyWith(
    handContributions: _act0BoardReadingContributionsV1(PokerStreet.river),
    heroCards: _hero7s7hCards,
    boardCards: _boardTripsAces,
    highlightedCardIds: const <String>[
      'board_0',
      'board_1',
      'board_2',
      'hero_0',
      'hero_1',
    ],
    centerLabel: 'Read the cards',
    seats: _riverBoardRunner.table.seats
        .map(
          (seat) => seat.seatId == 'btn'
              ? _act0CopySeatStateV1(
                  seat,
                  holeCards: _hero7s7hCards,
                  cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
                )
              : seat,
        )
        .toList(growable: false),
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'A full house has three of one rank and two of another.',
      body:
          'The board gives you three aces, and your pocket sevens add the pair. That makes a full house, which outranks a flush.',
      focusCardIds: <String>[
        'board_0',
        'board_1',
        'board_2',
        'hero_0',
        'hero_1',
      ],
      focusLabels: <String>['A-A-A', '7-7', 'Full house'],
    ),
  ],
);

final _quadsRankRunner = _riverBoardRunner.copyWith(
  lessonId: 'quads_rank',
  lessonTitle: 'Hand rankings, on the table',
  caption: 'Four of a kind means all four cards of one rank.',
  hint: 'Look for all four queens.',
  question: 'What hand do you have here?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'quads',
      label: 'Four of a kind',
      isCorrect: true,
      preferredLabel: 'Four of a kind',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Four queens.',
      feedbackReason:
          'You use all four queens. Four of a kind ranks above a full house because no extra pair can beat all four cards of one rank.',
    ),
    Act0RunnerOptionV1(
      id: 'full_house',
      label: 'Full house',
      isCorrect: false,
      preferredLabel: 'Four of a kind',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'A full house needs three of one rank and two of another. Here you have all four queens, so the hand is four of a kind.',
    ),
  ],
  table: _riverBoardRunner.table.copyWith(
    handContributions: _act0BoardReadingContributionsV1(PokerStreet.river),
    heroCards: _heroQqCards,
    boardCards: _boardQuadsQueens,
    highlightedCardIds: const <String>[
      'hero_0',
      'hero_1',
      'board_0',
      'board_1',
    ],
    centerLabel: 'Read the cards',
    seats: _riverBoardRunner.table.seats
        .map(
          (seat) => seat.seatId == 'btn'
              ? _act0CopySeatStateV1(
                  seat,
                  holeCards: _heroQqCards,
                  cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
                )
              : seat,
        )
        .toList(growable: false),
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Four of a kind uses all four of one rank.',
      body:
          'You use Q-Q from hand and Q-Q from the board. All four queens count, so this hand outranks a full house.',
      focusCardIds: <String>['hero_0', 'hero_1', 'board_0', 'board_1'],
      focusLabels: <String>['Q-Q-Q-Q'],
    ),
  ],
);

final _royalFlushRankRunner = _riverBoardRunner.copyWith(
  lessonId: 'royal_flush_rank',
  lessonTitle: 'Hand rankings, on the table',
  caption:
      'A straight flush is five ranks in a row in one suit. For example, 5-6-7-8-9 of hearts is a straight flush. T-J-Q-K-A in one suit is a royal flush.',
  hint: 'A flush with an ace is not royal unless the ranks run to ace.',
  question: 'What is the highest hand category you can make?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'royal_flush',
      label: 'Royal flush',
      isCorrect: true,
      preferredLabel: 'Royal flush',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Top of the ladder.',
      feedbackReason:
          'You make T-J-Q-K-A in hearts. That is a royal flush, which is the ace-high straight flush and beats every ordinary flush.',
    ),
    Act0RunnerOptionV1(
      id: 'ace_high_flush',
      label: 'Ace-high flush without a straight',
      isCorrect: false,
      preferredLabel: 'Royal flush',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Same suit, but stronger.',
      feedbackReason:
          'The five hearts run T-J-Q-K-A in sequence. An ace-high flush without a straight would have a gap in its ranks.',
    ),
  ],
  table: _riverBoardRunner.table.copyWith(
    handContributions: _act0BoardReadingContributionsV1(PokerStreet.river),
    heroCards: _heroKhQhCards,
    boardCards: _boardRoyalFlushHearts,
    highlightedCardIds: const <String>[
      'board_0',
      'board_1',
      'board_2',
      'hero_0',
      'hero_1',
    ],
    centerLabel: 'Read the cards',
    seats: _riverBoardRunner.table.seats
        .map(
          (seat) => seat.seatId == 'btn'
              ? _act0CopySeatStateV1(
                  seat,
                  holeCards: _heroKhQhCards,
                  cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
                )
              : seat,
        )
        .toList(growable: false),
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Royal flush is the ace-high straight flush.',
      body:
          'You use T-J-Q-K-A in hearts. A normal ace-high flush is not enough unless the five cards of one suit also run in sequence to the ace.',
      focusCardIds: <String>[
        'board_0',
        'board_1',
        'board_2',
        'hero_0',
        'hero_1',
      ],
      focusLabels: <String>['T-J-Q-K-A', 'Same suit', 'Royal flush'],
    ),
  ],
);

final _fullHouseVsFlushRunner = _riverBoardRunner.copyWith(
  lessonId: 'full_house_vs_flush',
  lessonTitle: 'Hand rankings, on the table',
  caption: 'When the cards are revealed, a full house beats a flush.',
  hint: 'Build both best five hands before choosing the stronger one.',
  // Only BTN and the other player are shown; four live seats stay hidden, so this compares
  // the two shown hands and does not name a winner of the whole pot.
  question: 'Which shown hand is stronger?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'hero_full_house',
      label: 'Your full house',
      isCorrect: true,
      preferredLabel: 'Your full house',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Correct comparison.',
      feedbackReason:
          'You make A-A-A-7-7 for a full house. The other player has a heart flush, but a full house ranks above a flush.',
    ),
    Act0RunnerOptionV1(
      id: 'co_flush',
      label: 'Other player: flush',
      isCorrect: false,
      preferredLabel: 'Your full house',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Strong hand, lower rank.',
      feedbackReason:
          'The other player does make a flush, but your full house is stronger. Always compare the hand rank before admiring a strong-looking suit pattern.',
    ),
  ],
  table: _riverBoardRunner.table.copyWith(
    handContributions: _act0FivePlayerComparisonPot,
    heroCards: _heroAs7sCards,
    boardCards: _boardFullHouseVsFlush,
    highlightedCardIds: const <String>[
      'hero_0',
      'hero_1',
      'board_0',
      'board_1',
      'board_2',
    ],
    centerLabel: 'Read the cards',
    seats: _riverBoardRunner.table.seats
        .map(
          (seat) => seat.seatId == 'btn'
              ? _act0CopySeatStateV1(
                  seat,
                  holeCards: _heroAs7sCards,
                  cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
                )
              : seat.seatId == 'co'
              ? _act0CopySeatStateV1(
                  seat,
                  holeCards: _opponentKhQhCards,
                  cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
                  isActive: false,
                )
              : seat,
        )
        .toList(growable: false),
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Compare the full best five.',
      body:
          'You use A-A-A with 7-7 for a full house. The other player uses five hearts for a flush, but the full house is stronger because it ranks higher.',
      focusCardIds: <String>[
        'hero_0',
        'hero_1',
        'board_0',
        'board_1',
        'board_2',
      ],
      focusLabels: <String>['A-A-A', '7-7', 'Full house ranks higher'],
    ),
  ],
);

final _quadsVsFullHouseRunner = _riverBoardRunner.copyWith(
  lessonId: 'quads_vs_full_house',
  lessonTitle: 'Hand rankings, on the table',
  caption: 'Four of a kind beats a full house.',
  hint: 'One player has all four queens. The other only has a full house.',
  question: 'Who wins when both hands are shown?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'hero_quads',
      label: 'Your four of a kind',
      isCorrect: true,
      preferredLabel: 'Your four of a kind',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Top hand found.',
      feedbackReason:
          'You use all four queens. The other player makes a full house with three sevens and two queens, but four of a kind ranks above a full house.',
    ),
    Act0RunnerOptionV1(
      id: 'co_full_house',
      label: 'Other player: full house',
      isCorrect: false,
      preferredLabel: 'Your four of a kind',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'The other player does make a full house, but you hold all four queens. Four of a kind outranks a full house when the cards are shown.',
    ),
  ],
  table: _riverBoardRunner.table.copyWith(
    handContributions: _act0FivePlayerComparisonPot,
    heroCards: _heroQqCards,
    boardCards: _boardQuadsVsFullHouse,
    highlightedCardIds: const <String>[
      'hero_0',
      'hero_1',
      'board_0',
      'board_1',
      'board_2',
    ],
    centerLabel: 'Read the cards',
    seats: _riverBoardRunner.table.seats
        .map(
          (seat) => seat.seatId == 'btn'
              ? _act0CopySeatStateV1(
                  seat,
                  holeCards: _heroQqCards,
                  cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
                )
              : seat.seatId == 'co'
              ? _act0CopySeatStateV1(
                  seat,
                  holeCards: _opponentAc7hCards,
                  cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
                  isActive: false,
                )
              : seat,
        )
        .toList(growable: false),
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Four of a kind outranks a full house.',
      body:
          'You use Q-Q-Q-Q with a seven as the fifth card. The other player uses 7-7-7 with Q-Q for a full house, but four of a kind still wins.',
      focusCardIds: <String>['hero_0', 'hero_1', 'board_0', 'board_1'],
      focusLabels: <String>['Q-Q-Q-Q'],
    ),
  ],
);

final _royalFlushVsFlushRunner = _riverBoardRunner.copyWith(
  lessonId: 'royal_flush_vs_flush',
  lessonTitle: 'Hand rankings, on the table',
  caption: 'A royal flush beats an ace-high flush.',
  hint: 'Same suit is not enough. Check whether the cards also run T-J-Q-K-A.',
  question: 'Which hand ranks higher?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'hero_royal_flush',
      label: 'Your royal flush',
      isCorrect: true,
      preferredLabel: 'Your royal flush',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Exactly.',
      feedbackReason:
          'You have the royal flush because the hearts run T-J-Q-K-A. The other player has only an ace-high flush, so you win with the higher flush type.',
    ),
    Act0RunnerOptionV1(
      id: 'co_ace_high_flush',
      label: 'Other player: ace-high flush',
      isCorrect: false,
      preferredLabel: 'Your royal flush',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Same suit, different ceiling.',
      feedbackReason:
          'The other player does make an ace-high flush, but the five hearts do not run to the ace in sequence. You make a straight flush all the way to A, so it is the royal flush.',
    ),
  ],
  table: _riverBoardRunner.table.copyWith(
    handContributions: _act0FivePlayerComparisonPot,
    heroCards: _heroKhQhCards,
    boardCards: _boardRoyalFlushHearts,
    highlightedCardIds: const <String>[
      'board_0',
      'board_1',
      'board_2',
      'hero_0',
      'hero_1',
    ],
    centerLabel: 'Read the cards',
    seats: _riverBoardRunner.table.seats
        .map(
          (seat) => seat.seatId == 'btn'
              ? _act0CopySeatStateV1(
                  seat,
                  holeCards: _heroKhQhCards,
                  cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
                )
              : seat.seatId == 'co'
              ? _act0CopySeatStateV1(
                  seat,
                  holeCards: _opponent9h3hCards,
                  cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
                  isActive: false,
                )
              : seat,
        )
        .toList(growable: false),
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Royal flush is more than ace-high.',
      body:
          'You use T-J-Q-K-A in hearts. The other player also has five hearts, but only you connect the ranks all the way to the ace.',
      focusCardIds: <String>[
        'board_0',
        'board_1',
        'board_2',
        'hero_0',
        'hero_1',
      ],
      focusLabels: <String>['T-J-Q-K-A', 'Royal flush wins'],
    ),
  ],
);

final _twoPairRunner = _riverBoardRunner.copyWith(
  lessonId: 'two_pair_rank',
  lessonTitle: 'Hand rankings, on the table',
  caption: 'Two pair beats one pair.',
  hint: 'Count matching ranks on the board and in hand.',
  question: 'Which hand is stronger?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'two_pair',
      label: 'Two pair',
      isCorrect: true,
      preferredLabel: 'Two pair',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Two pair spotted.',
      feedbackReason:
          'Count the matching ranks in the best five first: you make two pair, and two pair outranks one pair.',
    ),
    Act0RunnerOptionV1(
      id: 'one_pair',
      label: 'One pair',
      isCorrect: false,
      preferredLabel: 'Two pair',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'Count the matching ranks before judging the hand: one pair uses only one match, so it stays below your two pair in the best five.',
    ),
  ],
  table: _riverBoardRunner.table.copyWith(
    handContributions: _act0FivePlayerComparisonPot,
    heroCards: _heroA7oCards,
    highlightedCardIds: const <String>[
      'hero_0',
      'hero_1',
      'board_0',
      'board_1',
    ],
    centerLabel: 'Read the cards',
    seats: _riverBoardRunner.table.seats
        .map(
          (seat) => seat.seatId == 'btn'
              ? _act0CopySeatStateV1(
                  seat,
                  holeCards: _heroA7oCards,
                  cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
                )
              : seat.seatId == 'co'
              ? _act0CopySeatStateV1(
                  seat,
                  holeCards: _opponentKhJhCards,
                  cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
                  isActive: false,
                )
              : seat,
        )
        .toList(growable: false),
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Two pair uses two ranks.',
      body:
          'You use A with A and 7 with 7. The other player matches the J once, so your two pair is stronger than one pair.',
      focusCardIds: <String>['hero_0', 'hero_1', 'board_0', 'board_1'],
      focusLabels: <String>['A + A', '7 + 7', 'Two pair'],
    ),
  ],
);

const _foldoutChoices = <Act0RunnerOptionV1>[
  Act0RunnerOptionV1(
    id: 'win_now',
    label: 'Win now',
    isCorrect: true,
    preferredLabel: 'Win now',
    quality: Act0FeedbackQualityV1.correct,
    feedbackTitle: 'Sharp read.',
    feedbackReason: 'When everyone else folds, the last player wins the pot.',
  ),
  Act0RunnerOptionV1(
    id: 'show_cards',
    label: 'Show cards',
    isCorrect: false,
    preferredLabel: 'Win now',
    quality: Act0FeedbackQualityV1.wrong,
    feedbackTitle: 'Not quite.',
    feedbackReason: 'No showdown is needed when everyone else folds.',
  ),
];

final _showdownRunner = _readBoardRunner.copyWith(
  lessonId: 'showdown_winning',
  lessonTitle: 'Showdown & winning',
  caption: 'A hand can end by folds or by showdown.',
  hint: 'If everyone else folds, the last player wins now.',
  question: 'What happens if everyone else folds to you?',
  options: _foldoutChoices,
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Showdown means reveal.',
      body: 'If players remain after the river, hands are compared.',
      focusLabels: <String>['Reveal', 'Compare'],
    ),
    Act0TeachingStepV1(
      title: 'Folds can end earlier.',
      body: 'If everyone else folds, no reveal is needed.',
      focusLabels: <String>['Win by folds'],
    ),
  ],
);

final _showdownIntroRunner = _showdownRunner.copyWith(
  table: _showdownRunner.table.copyWith(
    handContributions: _act0BoardReadingContributionsV1(PokerStreet.flop),
  ),
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'showdown_intro',
  caption: 'A hand can end before or at showdown.',
  hint: 'Folds end it early. Showdown compares hands.',
  question: 'What happens if everyone else folds to you?',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Two endings.',
      body: 'Win when everyone else folds, or win by best hand at showdown.',
      focusLabels: <String>['Folds', 'Showdown'],
    ),
  ],
);

final _showdownBestHandRunner = _riverBoardRunner.copyWith(
  lessonId: 'showdown_best_hand',
  lessonTitle: 'Showdown & winning',
  caption: 'Start by reading the cards each player can use.',
  hint: 'Compare the final five-card hand.',
  question: 'What decides a showdown?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'best_hand',
      label: 'Best hand',
      isCorrect: true,
      preferredLabel: 'Best hand',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Strong choice.',
      feedbackReason:
          'At showdown, players use the best five-card hand they can make from private cards plus the shared board.',
    ),
    Act0RunnerOptionV1(
      id: 'first_actor',
      label: 'First actor',
      isCorrect: false,
      preferredLabel: 'Best hand',
      betterAnswerLabel: 'Best hand',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'Seat order decides who acts first, not who wins at showdown. Once cards are revealed, players compare the best full hand they can make from private cards plus the shared board.',
    ),
    Act0RunnerOptionV1(
      id: 'hero_cards_only',
      label: 'The two private cards at your seat',
      isCorrect: false,
      preferredLabel: 'Best hand',
      betterAnswerLabel: 'Best hand',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Only part of the hand.',
      feedbackReason:
          'Private cards matter, but showdown uses the whole five-card result. The shared board can help both players, so the best full hand decides it.',
    ),
  ],
  table: _riverBoardRunner.table.copyWith(
    handContributions: _act0HeadsUpShowdownPot,
    highlightedCardIds: const <String>[
      'hero_0',
      'hero_1',
      'board_0',
      'board_1',
      'board_3',
    ],
    centerLabel: 'Your pair of queens beats CO’s pair of jacks',
    seats: _riverBoardRunner.table.seats
        .map(
          (seat) => seat.seatId == 'co'
              ? _act0CopySeatStateV1(
                  seat,
                  holeCards: _opponentKhJhCards,
                  cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
                  isActive: false,
                )
              : seat.seatId == 'btn'
              ? _act0CopySeatStateV1(
                  seat,
                  cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
                )
              : seat,
        )
        .toList(growable: false),
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Showdown compares hands.',
      body:
          'Your best five are Q-Q-A-J-7. CO uses J-J-A-K-7. Your queens beat CO’s jacks.',
      focusCardIds: <String>[
        'hero_0',
        'hero_1',
        'board_0',
        'board_1',
        'board_3',
      ],
      focusLabels: <String>['Q-Q-A-J-7', 'You beat CO'],
    ),
  ],
);

final _showdownKickerRunner = _riverBoardRunner.copyWith(
  lessonId: 'showdown_kicker',
  lessonTitle: 'Showdown & winning',
  caption: 'Both players show their cards.',
  hint: 'Build each player’s best five on the same board.',
  question: 'Which pair of aces wins here?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'kicker',
      label: 'You, with a king',
      isCorrect: true,
      preferredLabel: 'You, with a king',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Solid understanding.',
      feedbackReason:
          'Each player has two aces. Your king beats the other player’s queen among the remaining cards.',
    ),
    Act0RunnerOptionV1(
      id: 'seat',
      label: 'Other player, with a queen',
      isCorrect: false,
      preferredLabel: 'You, with a king',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'Two aces tie at first. The other player’s queen loses to your king.',
    ),
  ],
  table: _riverBoardRunner.table.copyWith(
    handContributions: _act0HeadsUpShowdownPot,
    heroCards: _heroAsKhCards,
    boardCards: _boardAce,
    highlightedCardIds: const <String>[
      'hero_0',
      'hero_1',
      'board_0',
      'co_0',
      'co_1',
    ],
    centerLabel: 'Showdown',
    seats: _riverBoardRunner.table.seats
        .map(
          (seat) => seat.seatId == 'btn'
              ? _act0CopySeatStateV1(
                  seat,
                  holeCards: _heroAsKhCards,
                  cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
                )
              : seat.seatId == 'co'
              ? _act0CopySeatStateV1(
                  seat,
                  holeCards: _opponentAdQdCards,
                  cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
                  isActive: false,
                )
              : seat,
        )
        .toList(growable: false),
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Kickers break some ties.',
      body:
          'A kicker is a side card that can break a tie. If the pairs match, compare the next card in each best five.',
      focusCardIds: <String>['hero_1', 'co_1', 'board_0'],
      focusLabels: <String>['Best five', 'Side cards'],
    ),
  ],
);

final _tableObjectsRunner = _meetTableRunner.copyWith(
  lessonId: 'table_objects',
  lessonTitle: 'What poker is',
  caption: 'Button, small blind, and big blind explain the hand setup.',
  hint: 'The big blind posts 1 BB before action starts.',
  question: 'Which seat posted 1 BB?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'bb',
      label: 'BB',
      seatId: 'bb',
      isCorrect: true,
      preferredLabel: 'BB',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Well done.',
      feedbackReason: 'BB is the big blind and posts 1 BB.',
    ),
    Act0RunnerOptionV1(
      id: 'sb',
      label: 'SB',
      seatId: 'sb',
      isCorrect: false,
      preferredLabel: 'BB',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason: 'SB posts 0.5 BB. BB posts 1 BB.',
    ),
  ],
  table: _meetTableRunner.table.copyWith(
    selectableSeatIds: const <String>['bb', 'sb'],
    highlightedSeatIds: const <String>['bb', 'sb', 'btn'],
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Blinds are forced posts.',
      body: 'SB posts the small blind. BB posts the full big blind.',
      focusSeatIds: <String>['sb', 'bb'],
      focusLabels: <String>['0.5 BB', '1 BB'],
    ),
  ],
);

final _tableRecapRunner = _winWaysRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'table_recap',
  caption: 'Lesson learned: read the table before choosing.',
  hint: 'Separate chips in the middle from chips still in player stacks.',
  question: 'What is the pot?',
  feedbackTitle: 'Table takeaway.',
  feedbackReason:
      'The pot is the prize in the middle. Stacks belong to players until chips move in.',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'pot_committed_chips',
      label: 'Chips already committed to the middle',
      isCorrect: true,
      preferredLabel: 'Chips already committed to the middle',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'The shared prize.',
      feedbackReason:
          'The pot is the shared prize: chips already committed to the middle. Chips still in player stacks are not in the pot.',
    ),
    Act0RunnerOptionV1(
      id: 'largest_stack',
      label: 'The largest stack still held by a player',
      isCorrect: false,
      preferredLabel: 'Chips already committed to the middle',
      betterAnswerLabel: 'Chips already committed to the middle',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Separate the stack from the pot.',
      feedbackReason:
          'A stack belongs to a player until chips are committed. The pot is chips already committed to the middle, not the largest stack.',
    ),
    Act0RunnerOptionV1(
      id: 'everyone_folds',
      label: 'Everyone else folds before showdown',
      isCorrect: false,
      preferredLabel: 'Chips already committed to the middle',
      betterAnswerLabel: 'Chips already committed to the middle',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'An ending is not the prize.',
      feedbackReason:
          'Folding can decide who wins the pot; it does not define the pot. The pot is chips already committed to the middle.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Find the shared prize.',
      body:
          'Find the pot in the middle. Separate it from chips still in player stacks.',
      focusLabels: <String>['Pot'],
    ),
  ],
);

final _w1TableReadTransferRunner = _tableRecapRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w1_table_read_transfer',
  lessonTitle: 'What poker is',
  lessonSubtitle: 'Poker from Zero',
  caption: 'Real table. 2 cards, flop 3, pot 6 BB.',
  hint: 'Separate private cards, board cards, and pot before any action.',
  question: 'What is the clean first table read?',
  feedbackTitle: 'Table read first.',
  feedbackReason:
      'Real-table transfer starts with the same three checks every time: private cards, board cards, and chips in the pot.',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'two_three_six',
      label: '2 private cards, 3 board cards, 6 BB in the pot',
      isCorrect: true,
      preferredLabel: '2 private cards, 3 board cards, 6 BB in the pot',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Excellent spot.',
      feedbackReason:
          'That is the clean first live read. Separate hero cards, shared board, and chips in the middle before choosing anything.',
    ),
    Act0RunnerOptionV1(
      id: 'five_board_now',
      label: '5 board cards are already out',
      isCorrect: false,
      preferredLabel: '2 private cards, 3 board cards, 6 BB in the pot',
      betterAnswerLabel: '2 private cards, 3 board cards, 6 BB in the pot',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'Only three shared cards are visible here. More cards can appear later in the hand.',
    ),
    Act0RunnerOptionV1(
      id: 'hand_first_only',
      label: 'Only hero hand matters first',
      isCorrect: false,
      preferredLabel: '2 private cards, 3 board cards, 6 BB in the pot',
      betterAnswerLabel: '2 private cards, 3 board cards, 6 BB in the pot',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Playable instinct.',
      feedbackReason:
          'Hero cards matter, but a live table read also needs the shared board and pot before the decision starts.',
    ),
  ],
  table: _readBoardRunner.table.copyWith(
    handContributions: _act0BoardReadingContributionsV1(
      PokerStreet.flop,
      openBb: 2.75,
    ),
    heroCards: _heroAkCards,
    boardCards: _flopA72Cards,
    centerLabel: 'Read hand, board, pot',
    potLabel: 'Pot 6 BB',
    highlightedCardIds: const <String>[
      'hero_0',
      'hero_1',
      'board_0',
      'board_1',
      'board_2',
    ],
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Carry the first table scan.',
      body:
          'Real tables use the same simple scan.\n\nFind your two cards and the shared board.\n\nThen check how many chips are already in the pot.',
      focusLabels: <String>['2 private', '3 board', 'Pot'],
    ),
  ],
);

part of 'act0_shell_state_v1.dart';

final _world3CheckpointIntroRunner = _world3SameHandIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w3_checkpoint_intro',
  lessonTitle: 'Preflop checkpoint',
  caption: 'Checkpoint: bucket, position, frame, then action.',
  hint: 'Keep one reason in focus for each preflop decision.',
  question: 'What is the World 3 preflop order?',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Preflop order.',
      body: 'Name the bucket, read position, read frame, choose action.',
      focusLabels: <String>['Bucket', 'Position', 'Frame', 'Action'],
    ),
  ],
);

final _world3CheckpointRunner = _world3SameHandIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w3_checkpoint_review',
  lessonTitle: 'Preflop checkpoint',
  caption: 'Lesson learned: simple preflop choices need a framework.',
  hint: 'No charts yet. Just bucket, position, frame, action.',
  feedbackReason:
      'Bucket, seat, frame keeps preflop clear. Next, every bet needs a purpose too.',
  question: 'What makes preflop less random?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'framework',
      label: 'Bucket, seat, frame',
      isCorrect: true,
      preferredLabel: 'Bucket, seat, frame',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Sharp read.',
      feedbackReason:
          'That framework keeps preflop choices clear. Next, every bet needs a purpose too.',
    ),
    Act0RunnerOptionV1(
      id: 'one_answer',
      label: 'One answer per hand',
      isCorrect: false,
      preferredLabel: 'Bucket, seat, frame',
      betterAnswerLabel: 'Bucket, seat, frame',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'One hand can change action when position or action frame changes.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'World 3 checkpoint.',
      body: 'Use one compact read instead of guessing the first action.',
      focusLabels: <String>['Open', 'Call', 'Fold'],
    ),
  ],
);

final _w4TableFrameNoticeRunner = _world3FacingOpenIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w4_table_frame_notice',
  lessonTitle: 'Preflop checkpoint',
  lessonSubtitle: 'Bet Purpose / Price',
  caption: 'Real table. HJ opens 2.5 BB and hero is CO with AJo.',
  hint: 'Before deciding call, fold, or raise, name the frame cleanly.',
  question: 'What frame are you in?',
  feedbackTitle: 'Frame first.',
  feedbackReason: 'Name the frame before choosing the action.',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'facing_open',
      label: 'Facing an open',
      isCorrect: true,
      preferredLabel: 'Facing an open',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Strong choice.',
      feedbackReason:
          'That is the live-table transfer. Name the frame before choosing the action.',
    ),
    Act0RunnerOptionV1(
      id: 'unopened',
      label: 'Unopened pot',
      isCorrect: false,
      preferredLabel: 'Facing an open',
      betterAnswerLabel: 'Facing an open',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'The open already happened, so the clean frame is no longer unopened.',
    ),
    Act0RunnerOptionV1(
      id: 'call_first',
      label: 'Playable hand, so call first',
      isCorrect: false,
      preferredLabel: 'Facing an open',
      betterAnswerLabel: 'Facing an open',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Playable thought.',
      feedbackReason:
          'AJo may continue sometimes, but frame comes before action. Name facing open first.',
    ),
  ],
  table: _act0FacingOpenTableV1(
    _world3PlayableCallRunner.table.copyWith(
      heroCards: const <Act0CardStateV1>[
        Act0CardStateV1(rank: 'A', suit: 'h'),
        Act0CardStateV1(rank: 'J', suit: 'c'),
      ],
      centerLabel: 'HJ opens 2.5 BB',
    ),
    opener: 'hj',
    hero: 'co',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Frame before action.',
      body:
          'Real tables get simpler when you first ask whether the pot is unopened or facing an open.',
      focusSeatIds: <String>['hj', 'co'],
      focusLabels: <String>['Facing open', 'Price exists', 'Action comes next'],
    ),
  ],
);

// W3 position apply intro — used in the W3 apply lesson below.
final _w3PositionApplyIntroRunner = _world3PositionIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w3_position_apply_intro',
  lessonTitle: 'Position at the table',
  lessonSubtitle: 'Position Thinking',
  caption: 'Position tells you how comfortable a hand is before you act.',
  hint: 'Use the Sharky starting chart with your seat and earlier action.',
  question:
      'Which of these seats has fewer players still to act behind it before the flop?',
  options: _laterSeatChoices,
  feedbackTitle: 'Position habit.',
  feedbackReason:
      'Seat changes when you act and how much information you have before the decision.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Seat, then hand.',
      body: 'Check where you sit before deciding what to do with the hand.',
      focusSeatIds: <String>['utg', 'btn'],
      focusLabels: <String>['Early needs more', 'Late can open more'],
    ),
  ],
);

const _w4BtnBbSixBbFlopTrailV1 = <Act0ActionTrailItemV1>[
  Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
  Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
  Act0ActionTrailItemV1(label: 'UTG folds'),
  Act0ActionTrailItemV1(label: 'HJ folds'),
  Act0ActionTrailItemV1(label: 'CO folds'),
  Act0ActionTrailItemV1(label: 'BTN raises 2.75 BB'),
  Act0ActionTrailItemV1(label: 'SB folds'),
  Act0ActionTrailItemV1(
    label: 'BB calls 2.75 BB',
    displayLabel: 'BB calls 1.75 more, 2.75 total',
  ),
  Act0ActionTrailItemV1(label: 'Flop: BB checks'),
];

// The W4 BTN-vs-BB sizing family shares one legal history. Calls are total
// street commitments, so the calculator takes BB's 2.75 maximum rather than
// adding it to the posted 1 BB again; the folded SB's 0.5 post remains in pot.
Act0TableStateV1 _act0W4BtnBbSixBbFlopV1(
  Act0TableStateV1 table, {
  bool btnCheckedBehind = false,
}) {
  final seats =
      _act0WithAuthoredPreActionSeatsV1(
            table,
            foldedSeatIds: const <String>{'utg', 'hj', 'co', 'sb'},
          ).seats
          .map(
            (seat) => seat.seatId == 'bb'
                ? _act0CopySeatStateV1(seat, hasActed: true)
                : seat.seatId == 'btn' && btnCheckedBehind
                ? _act0CopySeatStateV1(seat, hasActed: true, isActive: false)
                : seat,
          )
          .toList(growable: false);
  return table.copyWith(
    potLabel: 'Pot 6 BB',
    toCallLabel: '',
    handContributions: const Act0HandContributionsV1(
      throughStreet: PokerStreet.flop,
      entries: [
        ..._act0LessonBlinds,
        Act0ContributionV1(
          PokerStreet.preflop,
          'btn',
          Act0ContributionKindV1.wager,
          2.75,
        ),
        Act0ContributionV1(
          PokerStreet.preflop,
          'bb',
          Act0ContributionKindV1.wager,
          1.75,
        ),
      ],
    ),
    actionTrail: <Act0ActionTrailItemV1>[
      ..._w4BtnBbSixBbFlopTrailV1,
      if (btnCheckedBehind) Act0ActionTrailItemV1(label: 'BTN checks'),
    ],
    activeSeatId: btnCheckedBehind ? '' : 'btn',
    seats: seats,
    highlightedSeatIds: const <String>['btn', 'bb'],
  );
}

// A checked-to-Hero W4 flop against the big blind. The button and
// blinds stay in their physical seats when a different seat opens.
Act0RunnerStateV1 _w4CheckedFlopScenarioV1(
  Act0RunnerStateV1 runner, {
  required String hero,
  String? hand,
}) {
  final original = runner.table;
  final position = hero.toUpperCase();
  final frame = _day7TableV1(
    hero: hero,
    hand: hand ?? original.heroCards.map((card) => card.label).join(' '),
    street: PokerStreet.flop,
    actor: hero,
    board: original.boardCards,
    folded: _day7SeatsV1.where((seat) => seat != hero && seat != 'bb').toSet(),
    entries: [
      ..._act0LessonBlinds,
      Act0ContributionV1(
        PokerStreet.preflop,
        hero,
        Act0ContributionKindV1.wager,
        2.75,
      ),
      const Act0ContributionV1(
        PokerStreet.preflop,
        'bb',
        Act0ContributionKindV1.wager,
        1.75,
      ),
    ],
    history: [
      const Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
      const Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
      for (final seat in _day7SeatsV1.where((seat) => seat != 'bb'))
        Act0ActionTrailItemV1(
          label: seat == hero
              ? '$position raises 2.75 BB'
              : '${seat.toUpperCase()} folds',
        ),
      const Act0ActionTrailItemV1(
        label: 'BB calls 2.75 BB',
        displayLabel: 'BB calls 1.75 more, 2.75 total',
      ),
      const Act0ActionTrailItemV1(label: 'Flop: BB checks'),
    ],
    bets: const {},
  );
  final seats = [
    for (final seat in frame.seats)
      if (seat.seatId == 'bb')
        _act0CopySeatStateV1(seat, hasActed: true)
      else
        seat,
  ];
  return runner.copyWith(
    table: original.copyWith(
      heroSeatId: hero,
      activeSeatId: hero,
      decisionSeatId: hero,
      heroCards: frame.heroCards,
      seats: seats,
      potLabel: frame.potLabel,
      toCallLabel: frame.toCallLabel,
      actionTrail: frame.actionTrail,
      handContributions: frame.handContributions,
      highlightedSeatIds: [hero, 'bb'],
      highlightedCardIds: original.highlightedCardIds,
    ),
  );
}

final _world4PurposeIntroRunner = _readBoardRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w4_purpose_intro',
  lessonTitle: 'Why bets happen',
  lessonSubtitle: 'Bet Purpose / Price',
  beatIndex: 1,
  beatCount: 4,
  caption: 'A bet should have a reason before it has a size.',
  hint: 'Ask whether you want a worse hand to call or a better hand to fold.',
  question: 'What should you name before sizing a bet?',
  options: const <Act0RunnerOptionV1>[],
  table: _act0W4BtnBbSixBbFlopV1(
    _readBoardRunner.table.copyWith(
      streetLabel: 'Flop',
      centerLabel: 'Name purpose',
      boardCards: _flopA72Cards,
    ),
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Purpose first.',
      body:
          'A value bet is a bet you expect weaker hands to call. A bluff tries to make better hands fold.',
      focusLabels: <String>['Weaker hands can call', 'Better hands can fold'],
    ),
  ],
);

final _world4ValuePurposeRunner = _world4PurposeIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w4_value_purpose',
  caption: 'BB checked on ace, seven and two.',
  hint: 'Compare each hand’s best five on the same board.',
  question:
      'If BB can have A-J, A-Q or A-K, which hand could call a 3 BB bet while behind yours?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'value',
      label: 'A-J',
      isCorrect: true,
      preferredLabel: 'A-J',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Your queen beats the jack.',
      feedbackReason:
          'A-Q and A-J both make a pair of aces. Your queen beats the jack, so a call from A-J can pay your value bet.',
    ),
    Act0RunnerOptionV1(
      id: 'bluff',
      label: 'A-K',
      isCorrect: false,
      preferredLabel: 'A-J',
      betterAnswerLabel: 'A-J',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'A-K is ahead on this flop because its king beats your queen. A-J makes the same pair with a lower side card.',
    ),
    Act0RunnerOptionV1(
      id: 'same_pair',
      label: 'A-Q',
      isCorrect: false,
      preferredLabel: 'A-J',
      betterAnswerLabel: 'A-J',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Same best five.',
      feedbackReason:
          'Both A-Q hands play aces with Q-7-2 on this flop. The value target is a hand with a weaker current best five, such as A-J.',
    ),
  ],
  table: _world4PurposeIntroRunner.table.copyWith(
    heroCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'A', suit: 's'),
      Act0CardStateV1(rank: 'Q', suit: 'd'),
    ],
    centerLabel: 'Flop',
    highlightedCardIds: const <String>['hero_0', 'hero_1', 'board_0'],
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Compare the two private cards with the board.',
      body:
          'If both players pair the same rank, compare the remaining cards in their best five.',
      focusCardIds: <String>['hero_0', 'hero_1', 'board_0'],
      focusLabels: <String>['Board', 'Private cards'],
    ),
  ],
);

final _world4BluffPurposeRunner = _world4PurposeIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w4_bluff_purpose',
  caption: 'BB checked on ace, seven and two.',
  hint: 'Compare what your cards and the other hand make on this board.',
  question:
      'If BB holds 7-6 and you bet, which result would make the bet a bluff?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'bluff',
      label: 'BB folds a better hand',
      isCorrect: true,
      preferredLabel: 'BB folds a better hand',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'A better hand could fold.',
      feedbackReason:
          'BB has a pair of sevens. You have no pair, so making BB fold that better hand is a bluff.',
    ),
    Act0RunnerOptionV1(
      id: 'value',
      label: 'BB calls with a weaker hand',
      isCorrect: false,
      preferredLabel: 'BB folds a better hand',
      betterAnswerLabel: 'BB folds a better hand',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'A pair of sevens beats your unpaired hand now. A call from that pair would not be a call from a weaker hand.',
    ),
    Act0RunnerOptionV1(
      id: 'better_calls',
      label: 'BB calls with the better hand',
      isCorrect: false,
      preferredLabel: 'BB folds a better hand',
      betterAnswerLabel: 'BB folds a better hand',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'The bluff did not work.',
      feedbackReason:
          'If BB calls with 7-6 on A-7-2, the pair of sevens stays in and is ahead of your K-Q. You risk chips without making the better hand fold.',
    ),
  ],
  table: _world4PurposeIntroRunner.table.copyWith(
    heroCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'K', suit: 'c'),
      Act0CardStateV1(rank: 'Q', suit: 'c'),
    ],
    centerLabel: 'Flop',
    highlightedSeatIds: const <String>['btn', 'bb'],
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Compare the hands.',
      body:
          'Read what each player can make with the shared cards. Then consider how each of the choices would affect the bettor.',
      focusLabels: <String>['Private cards', 'Board'],
    ),
  ],
);

final _world4PurposeRecapRunner = _world4PurposeIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w4_purpose_recap',
  caption: 'Lesson learned: name the purpose before the size.',
  hint: 'Compare what the bettor hopes a weaker or stronger hand will do.',
  question: 'What comes before the bet size?',
  feedbackTitle: 'Purpose takeaway.',
  feedbackReason:
      'With a value bet you want a weaker hand to call. With a bluff you want a stronger hand to fold.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Purpose checklist.',
      body: 'Ask what the bet wants before asking how big it should be.',
      focusLabels: <String>['Purpose', 'Then size'],
    ),
  ],
);

final _world4ValueIntroRunner = _world4ValuePurposeRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w4_value_intro',
  lessonTitle: 'Value bets',
  caption: 'A value bet targets weaker hands that can call.',
  hint: 'If no weaker hand can call, value is thin or missing.',
  question: 'Who should a value bet get called by?',
  options: const <Act0RunnerOptionV1>[],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Top pair.',
      body:
          'Top pair means a private card matches the highest rank on the board. On A-7-2, your ace makes top pair. A weaker ace, such as A-J, can call a value bet. Name the weaker hand before choosing your bet.',
      focusCardIds: <String>['hero_0', 'board_0'],
    ),
  ],
);

final _world4ValueBetRunner = _world4ValuePurposeRunner.copyWith(
  lessonId: 'w4_value_bet',
  lessonTitle: 'Value bets',
  caption: 'BB checked the ace-high flop.',
  hint: 'Ask which hands BB can call with and whether they beat yours.',
  question:
      'In this example, BB calls 3 BB and folds to 6 BB with a weaker ace. Which action earns chips from that hand?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'bet_half',
      label: 'Bet half-pot',
      amountLabel: '3 BB',
      isCorrect: true,
      preferredLabel: 'Bet half-pot',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Excellent spot.',
      feedbackReason:
          "Bet 3 BB because BB calls with a weaker ace on A-7-2. A bet of 6 BB loses that call.",
    ),
    Act0RunnerOptionV1(
      id: 'check',
      label: 'Check',
      isCorrect: false,
      preferredLabel: 'Bet half-pot',
      betterAnswerLabel: 'Bet half-pot',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason: 'Checking can miss value when worse hands can call.',
    ),
    Act0RunnerOptionV1(
      id: 'bet_pot',
      label: 'Bet pot-size',
      amountLabel: '6 BB',
      isCorrect: false,
      preferredLabel: 'Bet half-pot',
      betterAnswerLabel: 'Bet half-pot',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too large for the stated read.',
      feedbackReason:
          'You have A-Q on A-7-2. In this example a weaker ace calls 3 BB and folds to 6 BB. Betting 6 BB gives up the value that 3 BB can earn.',
    ),
  ],
  table: _act0W4BtnBbSixBbFlopV1(
    _world4ValuePurposeRunner.table.copyWith(centerLabel: 'Value spot'),
  ),
);

final _world4ValueCheckMissRunner = _world4ValueBetRunner.copyWith(
  lessonId: 'w4_value_missed',
  caption: 'BB checked. Your cards are an ace and a jack.',
  teachingSteps: const <Act0TeachingStepV1>[],
  table: _world4ValueBetRunner.table.copyWith(
    heroCards: const [
      Act0CardStateV1(rank: 'A', suit: 's'),
      Act0CardStateV1(rank: 'J', suit: 'd', tone: Act0CardToneV1.red),
    ],
  ),
  hint: 'Compare what happens to the pot after each choice.',
  question:
      'In this example, BB checks a weaker ace and calls 3 BB but folds to 6 BB. Which action gets paid this round?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'check',
      label: 'Check',
      isCorrect: false,
      preferredLabel: 'Bet half-pot',
      betterAnswerLabel: 'Bet half-pot',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Keep the value chance.',
      feedbackReason:
          "A check misses the 3 BB a weaker ace will pay for the flop bet.",
    ),
    Act0RunnerOptionV1(
      id: 'bet_half',
      label: 'Bet half-pot',
      amountLabel: '3 BB',
      isCorrect: true,
      preferredLabel: 'Bet half-pot',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Value collected.',
      feedbackReason:
          "A-J leads the weaker ace that BB calls with for 3 BB. A bet of 6 BB makes that ace fold and loses the payment.",
    ),
    Act0RunnerOptionV1(
      id: 'bet_pot',
      label: 'Bet pot-size',
      amountLabel: '6 BB',
      isCorrect: false,
      preferredLabel: 'Bet half-pot',
      betterAnswerLabel: 'Bet half-pot',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Keep the weaker ace in.',
      feedbackReason:
          'A-J can get 3 BB from a weaker ace on A-7-2. Under the stated read a 6 BB bet makes that ace fold, so you miss the chips it would have paid.',
    ),
  ],
);

final _world4ValueRecapRunner = _world4ValueIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w4_value_recap',
  caption: 'Lesson learned: value means worse can call.',
  hint: 'Do not hide strong but call-able hands every time.',
  question: 'What makes a bet value?',
  feedbackTitle: 'Value takeaway.',
  feedbackReason:
      'A value bet is not just betting a strong hand. It needs weaker hands that can call.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Value checklist.',
      body: 'Ask what worse hands can call before choosing a size.',
      focusLabels: <String>['Worse calls', 'Size next'],
    ),
  ],
);

final _world4BluffIntroRunner = _world4BluffPurposeRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w4_bluff_intro',
  lessonTitle: 'Bluff pressure',
  caption: 'A bluff tries to win when better hands fold.',
  hint: 'No fold chance, no clean bluff.',
  question: 'What does a bluff need?',
  options: const <Act0RunnerOptionV1>[],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Fold pressure.',
      body: 'A bluff is a story backed by chips, not random betting.',
      focusLabels: <String>['Better folds', 'Pressure'],
    ),
  ],
);

final _world4BluffPressureRunner = _world4BluffPurposeRunner.copyWith(
  lessonId: 'w4_bluff_pressure',
  lessonTitle: 'Bluff pressure',
  caption: 'The flop is ace, seven and two. BB checked.',
  hint: 'A small bet can apply pressure without risking too much.',
  question:
      'In this example, BB folds the target hands to either bet size. Which option makes a better hand fold while risking fewer chips?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'bet_small',
      label: 'Bet one-third',
      amountLabel: '2 BB',
      isCorrect: true,
      preferredLabel: 'Bet one-third',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Clean execution.',
      feedbackReason:
          "Bet 2 BB because BB folds the target hands to either size. A bet of 6 BB risks 4 BB more for the same folds.",
    ),
    Act0RunnerOptionV1(
      id: 'check',
      label: 'Check',
      isCorrect: false,
      preferredLabel: 'Bet one-third',
      betterAnswerLabel: 'Bet one-third',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Checking leaves both players in.',
      feedbackReason:
          'Checking closes this round without asking BB to fold. Betting gives BB a decision.',
    ),
    Act0RunnerOptionV1(
      id: 'bet_pot',
      label: 'Bet pot-size',
      amountLabel: '6 BB',
      isCorrect: false,
      preferredLabel: 'Bet one-third',
      betterAnswerLabel: 'Bet one-third',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Same fold, more risk.',
      feedbackReason:
          'In the 6 BB pot on A-7-2, a 2 BB bet makes the target hands fold. The 6 BB bet gets the same result from them but puts 4 BB more at risk if called.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Match the size to the same target.',
      body:
          'Start with a better hand you expect to fold. If a small bet gets that same fold, adding chips gives you no extra reward from that hand. Keep the pot size separate from the chips you risk.',
      focusLabels: <String>['Target hand', 'Chips at risk'],
    ),
  ],
  table: _act0W4BtnBbSixBbFlopV1(
    _world4BluffPurposeRunner.table.copyWith(centerLabel: 'Fold pressure'),
  ),
);

final _world4BadBluffRunner = _world4BluffPressureRunner.copyWith(
  lessonId: 'w4_bad_bluff',
  caption: 'You hold a king and a queen on ace, seven and two.',
  teachingSteps: const <Act0TeachingStepV1>[],
  hint: 'Use the response the question gives for better hands.',
  question:
      'In this example, BB calls both offered bet sizes with better hands and folds worse hands. Which option avoids paying for a bluff that cannot get a better hand to fold?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'check',
      label: 'Check',
      isCorrect: true,
      preferredLabel: 'Check',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Check is the cleaner line.',
      feedbackReason:
          "Check KQ on A-7-2 because BB calls either size with better hands. Betting one-third risks 2 BB and gains none of the folds you want.",
    ),
    Act0RunnerOptionV1(
      id: 'pot_bet',
      label: 'Bet pot-size',
      amountLabel: '6 BB',
      isCorrect: false,
      preferredLabel: 'Check',
      betterAnswerLabel: 'Check',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          "Betting 6 BB costs chips because the model has all better hands calling. A check gets you to the turn for free.",
    ),
    Act0RunnerOptionV1(
      id: 'bet_small',
      label: 'Bet one-third',
      amountLabel: '2 BB',
      isCorrect: false,
      preferredLabel: 'Check',
      betterAnswerLabel: 'Check',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'A smaller losing bet still costs chips.',
      feedbackReason:
          'A 2 BB bet risks less than 6 BB, but on A-7-2 the stated better hands still call. Checking lets K-Q see the turn without paying for those folds.',
    ),
  ],
  table: _act0W4BtnBbSixBbFlopV1(
    _world4BluffPressureRunner.table.copyWith(centerLabel: 'Low fold pressure'),
  ),
);

final _world4BluffRecapRunner = _world4BluffIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w4_bluff_recap',
  caption: 'Lesson learned: bluff only when folds can happen.',
  hint: 'Pressure matters, but not every missed hand must fire.',
  question: 'What does a bluff try to create?',
  feedbackTitle: 'Bluff takeaway.',
  feedbackReason:
      'Bluffing is pressure with a purpose: make better hands fold without risking chips blindly.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Bluff checklist.',
      body:
          'Ask whether better hands can fold before betting a miss. With K-Q on A-7-2, a bet needs to do more than chase away weaker hands. If the better hands stay in, save the chips and see the next card when you can.',
      focusLabels: <String>['Better folds', 'Controlled risk'],
    ),
  ],
);

final _world4ProtectionIntroRunner = _world4PurposeIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w4_protection_intro',
  lessonTitle: 'Protection and denial',
  caption: 'Protection bets make the next card cost something.',
  hint: 'A pair can be ahead now and fall behind on the next card.',
  question: 'What does protection deny?',
  options: const <Act0RunnerOptionV1>[],
  table: _world4PurposeIntroRunner.table.copyWith(
    heroCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'Q', suit: 's'),
      Act0CardStateV1(rank: 'J', suit: 'd'),
    ],
    boardCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'Q', suit: 'h'),
      Act0CardStateV1(rank: '9', suit: 'd'),
      Act0CardStateV1(rank: '4', suit: 'c'),
    ],
    centerLabel: 'Next card matters',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Deny free cards.',
      body:
          'Protection makes the next card cost chips. You have a pair of queens on Q-9-4. Overcards are the cards above the board’s highest rank. An ace or king can beat your queens if it pairs. A set means three of a kind made with a pair in your hand and one card on the board.',
      focusLabels: <String>['Next card', 'Cost', 'Deny'],
    ),
  ],
);

final _world4ProtectionBetRunner = _world4ProtectionIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w4_protection_bet',
  caption: 'BB checked on queen, nine and four.',
  teachingSteps: const <Act0TeachingStepV1>[],
  hint: 'Betting protects value by denying that free card.',
  question:
      'BB has checked. In this example, BB has ace-king, will call 3 BB and will fold to 6 BB. Which option charges A-K to see the next card and keeps the worse hand in?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'bet_half',
      label: 'Bet half-pot',
      amountLabel: '3 BB',
      isCorrect: true,
      preferredLabel: 'Bet half-pot',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Sharp read.',
      feedbackReason:
          "Bet 3 BB because BB calls with ace-king and pays for its chance to improve. A bet of 6 BB makes ace-king fold instead.",
    ),
    Act0RunnerOptionV1(
      id: 'check',
      label: 'Check',
      isCorrect: false,
      preferredLabel: 'Bet half-pot',
      betterAnswerLabel: 'Bet half-pot',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          "Checking gives BB a free card. Betting 3 BB charges ace-king for that chance.",
    ),
    Act0RunnerOptionV1(
      id: 'bet_pot',
      label: 'Bet pot-size',
      amountLabel: '6 BB',
      isCorrect: false,
      preferredLabel: 'Bet half-pot',
      betterAnswerLabel: 'Bet half-pot',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'This size gives up the stated call.',
      feedbackReason:
          'Betting 6 BB makes A-K fold and protects your Q-J, but 3 BB protects it and gets a call in this example. You miss that extra value with the larger bet.',
    ),
  ],
  table: _world4ProtectionIntroRunner.table.copyWith(
    highlightedCardIds: const <String>['hero_0', 'board_0', 'board_1'],
  ),
);

final _world4ProtectionCheckRunner = _world4ProtectionBetRunner.copyWith(
  lessonId: 'w4_protection_check',
  caption:
      'Both players check. BB can beat your pair if the next card pairs an ace or king in their hand.',
  hint: 'Ask what the opponent receives by not facing a bet.',
  question: 'What did your check give an opponent holding two overcards?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'free_card',
      label: 'Free card',
      isCorrect: true,
      preferredLabel: 'Free card',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Strong choice.',
      feedbackReason:
          'With two overcards to Q-9-4, BB can pair an ace or king without paying for the turn.',
    ),
    Act0RunnerOptionV1(
      id: 'made_pay',
      label: 'Made pay',
      isCorrect: false,
      preferredLabel: 'Free card',
      betterAnswerLabel: 'Free card',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'Both players checked, so neither paid to see the next card.',
    ),
    Act0RunnerOptionV1(
      id: 'got_fold',
      label: 'Won the pot now',
      isCorrect: false,
      preferredLabel: 'Free card',
      betterAnswerLabel: 'Free card',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Both players stayed in.',
      feedbackReason:
          'BB checked and BTN checked behind on Q-9-4. Without a bet, neither hand folded and BB could catch up on the turn for free.',
    ),
  ],
  table: _act0W4BtnBbSixBbFlopV1(
    _world4ProtectionBetRunner.table,
    btnCheckedBehind: true,
  ),
);

final _world4ProtectionRecapRunner = _world4ProtectionIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w4_protection_recap',
  caption: 'Lesson learned: protection denies a free next card.',
  hint: 'A value bet can also make the next card cost chips.',
  question: 'What does a protection bet deny?',
  feedbackTitle: 'Protection takeaway.',
  feedbackReason:
      'Protection means the next card is not free for the player trying to continue.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Protection checklist.',
      body:
          'Ask if checking gives away the next card too cheaply. When your made hand can be beaten by later cards, betting makes the other player pay chips to continue instead of seeing a free turn card.',
      focusLabels: <String>['Next card', 'Free card', 'Bet'],
    ),
  ],
);

final _world4PriceIntroRunner = _callActionRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w4_price_intro',
  lessonTitle: 'Call price',
  lessonSubtitle: 'Bet Purpose / Price',
  caption: 'When someone bets, they set your price to continue.',
  hint:
      'Price is what you must pay to continue. Read pot, to call, and hand strength together.',
  question: 'What does a bet give the caller?',
  options: const <Act0RunnerOptionV1>[],
  table: _act0W4FacingTurnPriceV1(
    _callActionRunner.table.copyWith(
      streetLabel: 'Turn',
      centerLabel: 'Facing price',
      heroCards: _act0LessonCardsV1('Jd Js'),
      boardCards: const <Act0CardStateV1>[
        Act0CardStateV1(rank: 'T', suit: 'h'),
        Act0CardStateV1(rank: '8', suit: 'c'),
        Act0CardStateV1(rank: '3', suit: 'd'),
        Act0CardStateV1(rank: '2', suit: 's'),
      ],
    ),
    potBeforeBet: 6,
    price: 2,
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Call 2 BB into a pot of 8 BB.',
      body:
          'Five calls cost 10 BB. One win returns 10 BB, so you break even at one in five. Middle pair means your private card matches the second-highest rank on the flop. Bottom pair means matching the lowest.',
      focusLabels: <String>['8 BB in the pot', '2 BB to call', '1 in 5'],
    ),
    Act0TeachingStepV1(
      title: 'Write the same chance as a percentage.',
      body:
          'One win in five is 20%. To call X into a pot of Y after the bet, you need to win at least X ÷ (X + Y) of the time when there are no ties or further bets.',
      focusLabels: <String>['1 in 5', '20%'],
    ),
  ],
);

// The two players reach the turn with the stated pot. Dead blinds are
// still in the pot, but the folded players have no current commitment.
Act0TableStateV1 _act0W4FacingTurnPriceV1(
  Act0TableStateV1 table, {
  required double potBeforeBet,
  required double price,
  String bettor = 'hj',
}) {
  final fromBigBlind = bettor == 'bb';
  final otherFolds = fromBigBlind
      ? const {'utg', 'hj', 'co', 'sb'}
      : const {'utg', 'co', 'sb', 'bb'};
  final preflopAmount = (potBeforeBet - (fromBigBlind ? 0.5 : 1.5)) / 2;
  final opponent = bettor.toUpperCase();
  final bet = Act0SeatBetStateV1(
    kind: Act0SeatBetKindV1.bet,
    label: opponent,
    amountLabel: _act0BbLabelV1(price),
  );
  return table.copyWith(
    autoPlayHistory: false,
    handContributions: Act0HandContributionsV1(
      throughStreet: PokerStreet.turn,
      startingStackBbBySeat: const {'btn': 100},
      entries: [
        ..._act0LessonBlinds,
        Act0ContributionV1(
          PokerStreet.preflop,
          'btn',
          Act0ContributionKindV1.wager,
          preflopAmount,
        ),
        Act0ContributionV1(
          PokerStreet.preflop,
          bettor,
          Act0ContributionKindV1.wager,
          preflopAmount - (fromBigBlind ? 1 : 0),
        ),
        Act0ContributionV1(
          PokerStreet.turn,
          bettor,
          Act0ContributionKindV1.wager,
          price,
        ),
      ],
    ),
    actionTrail: [
      const Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
      const Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
      const Act0ActionTrailItemV1(label: 'UTG folds'),
      if (fromBigBlind) ...[
        const Act0ActionTrailItemV1(label: 'HJ folds'),
        const Act0ActionTrailItemV1(label: 'CO folds'),
        Act0ActionTrailItemV1(
          label: 'BTN raises ${_act0BbLabelV1(preflopAmount)}',
        ),
        const Act0ActionTrailItemV1(label: 'SB folds'),
        Act0ActionTrailItemV1(
          label: 'BB calls ${_act0BbLabelV1(preflopAmount)}',
          displayLabel:
              'BB calls ${_act0BbLabelV1(preflopAmount - 1).split(' ').first} more, ${_act0BbLabelV1(preflopAmount).split(' ').first} total',
        ),
      ] else ...[
        Act0ActionTrailItemV1(
          label: 'HJ raises ${_act0BbLabelV1(preflopAmount)}',
        ),
        const Act0ActionTrailItemV1(label: 'CO folds'),
        Act0ActionTrailItemV1(
          label: 'BTN calls ${_act0BbLabelV1(preflopAmount)}',
        ),
        const Act0ActionTrailItemV1(label: 'SB folds'),
        const Act0ActionTrailItemV1(label: 'BB folds'),
      ],
      Act0ActionTrailItemV1(label: 'Flop: $opponent checks'),
      const Act0ActionTrailItemV1(label: 'BTN checks'),
      Act0ActionTrailItemV1(
        label: 'Turn: $opponent bets ${_act0BbLabelV1(price)}',
      ),
    ],
    activeSeatId: 'btn',
    decisionSeatId: 'btn',
    potLabel: 'Pot ${_act0BbLabelV1(potBeforeBet + price)}',
    toCallLabel: 'To call ${_act0BbLabelV1(price)}',
    seats: [
      for (final seat in table.seats)
        _act0CopySeatStateV1(
          seat,
          isOccupied: true,
          isInHand: !otherFolds.contains(seat.seatId),
          isFolded: otherFolds.contains(seat.seatId),
          isActive: seat.seatId == 'btn',
          hasActed: seat.seatId != 'btn',
          isLastAggressor: seat.seatId == bettor,
          clearCommitment: true,
          bet: seat.seatId == bettor ? bet : null,
          holeCards: seat.isHero ? table.heroCards : _unknownHoleCards,
          cardsVisibleMode: otherFolds.contains(seat.seatId)
              ? Act0CardsVisibleModeV1.none
              : seat.isHero
              ? Act0CardsVisibleModeV1.faceUp
              : Act0CardsVisibleModeV1.faceDown,
          stackLabel: _act0BbLabelV1(switch (seat.seatId) {
            'btn' => 100 - preflopAmount,
            'sb' => 99.5,
            _ when seat.seatId == bettor => 100 - preflopAmount - price,
            'bb' => 99,
            _ => 100.0,
          }),
        ),
    ],
  );
}

const _world4PriceReminder =
    'Compare your chance to win with the call divided by the pot after you call.';

final _world4GoodPriceCallRunner = _world4PriceIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w4_good_price_call',
  teachingSteps: const [],
  caption: 'HJ bet 1 BB on the turn. $_world4PriceReminder',
  hint: 'Compare the stated chance with the share of the final pot you pay.',
  question:
      'Two players, no ties or more bets. If you call, you win 1 time in 4 (25%). Which earns more, call or fold?',
  options: const [
    Act0RunnerOptionV1(
      id: 'call',
      label: 'Call',
      amountLabel: '1 BB',
      isCorrect: true,
      preferredLabel: 'Call',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Price and chance compared.',
      feedbackReason:
          "HJ bets 1 BB, so a call makes a 9 BB pot and needs 11.1%. Call because the stated 25% is higher. Folding gives up this gain.",
    ),
    Act0RunnerOptionV1(
      id: 'fold',
      label: 'Fold',
      isCorrect: false,
      preferredLabel: 'Call',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Compare with the break-even chance.',
      feedbackReason:
          'Folding gives up a profitable call in this model: 25% is higher than the roughly 11.1% you need.',
    ),
    Act0RunnerOptionV1(
      id: 'call_ignore_price',
      label: 'Call just because you paired the ten',
      isCorrect: false,
      preferredLabel: 'Call',
      betterAnswerLabel: 'Call',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'The action fits. Check the price too.',
      feedbackReason:
          'T-7 makes a pair of tens, but the 1 BB price and 25% win chance make this call profitable. Skipping the calculation can cost chips against a bigger bet.',
    ),
  ],
  table: _act0W4FacingTurnPriceV1(
    _world4PriceIntroRunner.table.copyWith(
      centerLabel: 'Turn decision',
      heroCards: const <Act0CardStateV1>[
        Act0CardStateV1(rank: 'T', suit: 's'),
        Act0CardStateV1(rank: '7', suit: 'd'),
      ],
      boardCards: const <Act0CardStateV1>[
        Act0CardStateV1(rank: 'T', suit: 'h'),
        Act0CardStateV1(rank: '8', suit: 'c'),
        Act0CardStateV1(rank: '3', suit: 'd'),
        Act0CardStateV1(rank: '2', suit: 's'),
      ],
      highlightedCardIds: const <String>[
        'hero_0',
        'hero_1',
        'board_0',
        'board_1',
      ],
    ),
    potBeforeBet: 7,
    price: 1,
  ),
);

final _world4BadPriceFoldRunner = _world4GoodPriceCallRunner.copyWith(
  lessonId: 'w4_bad_price_fold',
  caption: 'HJ bet 7 BB on the turn. $_world4PriceReminder',
  hint: 'Compare the stated chance with the share of the final pot you pay.',
  question:
      'Two players, no ties or more bets. If you call, you win 1 time in 4 (25%). Which earns more, call or fold?',
  options: const [
    Act0RunnerOptionV1(
      id: 'fold',
      label: 'Fold',
      isCorrect: true,
      preferredLabel: 'Fold',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Price and chance compared.',
      feedbackReason:
          "HJ bets 7 BB, so a call makes a 21 BB pot and needs 33.3%. Fold at the stated 25% because a call loses chips here.",
    ),
    Act0RunnerOptionV1(
      id: 'call',
      label: 'Call',
      amountLabel: '7 BB',
      isCorrect: false,
      preferredLabel: 'Fold',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Compare with the break-even chance.',
      feedbackReason:
          'Calling costs 7 BB with only 25% wins against a 33.3% price. Folding keeps those chips.',
    ),
    Act0RunnerOptionV1(
      id: 'fold_ignore_price',
      label: 'Fold because a pair of eights is too weak to call',
      isCorrect: false,
      preferredLabel: 'Fold',
      betterAnswerLabel: 'Fold',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'The action fits. Use the price.',
      feedbackReason:
          'Your pair of eights can win. The 7 BB call needs about 33% win chance in this model, above the stated 25%. Folding every pair of eights would also lose profitable calls.',
    ),
  ],
  table: _act0W4FacingTurnPriceV1(
    _world4GoodPriceCallRunner.table.copyWith(
      centerLabel: 'Turn decision',
      heroCards: const <Act0CardStateV1>[
        Act0CardStateV1(rank: '8', suit: 's'),
        Act0CardStateV1(rank: '7', suit: 'd'),
      ],
      boardCards: const <Act0CardStateV1>[
        Act0CardStateV1(rank: 'K', suit: 'h'),
        Act0CardStateV1(rank: '8', suit: 'c'),
        Act0CardStateV1(rank: '4', suit: 'd'),
        Act0CardStateV1(rank: '2', suit: 's'),
      ],
    ),
    potBeforeBet: 7,
    price: 7,
  ),
);

final _world4CheapPriceMarginalCallRunner = _world4GoodPriceCallRunner.copyWith(
  lessonId: 'w4_cheap_price_marginal_call',
  caption: 'The turn is a two. HJ bet 1 BB. $_world4PriceReminder',
  lessonSubtitle:
      'Middle pair means a private card matches the second-highest rank on the flop.',
  hint: 'Compare the stated chance with the share of the final pot you pay.',
  question:
      'Two players, no ties or more bets. You have middle pair. If you call, you win 3 times in 20, about 1 in 7 (15%). Which earns more, call or fold?',
  options: const [
    Act0RunnerOptionV1(
      id: 'call',
      label: 'Call',
      amountLabel: '1 BB',
      isCorrect: true,
      preferredLabel: 'Call',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Price and chance compared.',
      feedbackReason:
          "HJ bets 1 BB, so calling makes an 11 BB pot and needs about 9.1%. The stated 15% clears that price. Folding gives up the gain.",
    ),
    Act0RunnerOptionV1(
      id: 'fold',
      label: 'Fold',
      isCorrect: false,
      preferredLabel: 'Call',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Compare with the break-even chance.',
      feedbackReason:
          'Folding gives up a profitable call in this model: 15% is higher than the roughly 9.1% you need.',
    ),
    Act0RunnerOptionV1(
      id: 'call_ignore_price',
      label: 'Call because the opponent bet small',
      isCorrect: false,
      preferredLabel: 'Call',
      betterAnswerLabel: 'Call',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'The action fits. Check both sides.',
      feedbackReason:
          "Calling just because a bet looks small can cost chips. Here you need about 9% and the stated 15% covers it.",
    ),
  ],
  table: _act0W4FacingTurnPriceV1(
    _world4GoodPriceCallRunner.table.copyWith(
      centerLabel: 'Turn decision',
      heroCards: const <Act0CardStateV1>[
        Act0CardStateV1(rank: '9', suit: 's'),
        Act0CardStateV1(rank: '7', suit: 'd'),
      ],
      boardCards: const <Act0CardStateV1>[
        Act0CardStateV1(rank: 'K', suit: 'c'),
        Act0CardStateV1(rank: '9', suit: 'h', tone: Act0CardToneV1.red),
        Act0CardStateV1(rank: '4', suit: 'd'),
        Act0CardStateV1(rank: '2', suit: 's'),
      ],
      highlightedCardIds: const <String>['hero_0', 'board_1'],
    ),
    potBeforeBet: 9,
    price: 1,
  ),
);

final _world4BigPriceMarginalFoldRunner = _world4BadPriceFoldRunner.copyWith(
  lessonId: 'w4_big_price_marginal_fold',
  caption: 'The turn is a two. HJ bet 6 BB. $_world4PriceReminder',
  hint: 'Compare the stated chance with the share of the final pot you pay.',
  question:
      'Two players, no ties or more bets. If you call, you win 1 time in 4 (25%). Which break-even chance and action are right?',
  options: const [
    Act0RunnerOptionV1(
      id: 'fold',
      label: '32% · Fold',
      isCorrect: true,
      preferredLabel: '32% · Fold',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Price and chance compared.',
      feedbackReason:
          '6 ÷ (6 + 13) is about 31.6%. Your 25% chance is below that threshold, so fold.',
    ),
    Act0RunnerOptionV1(
      id: 'call',
      label: '46% · Call',
      amountLabel: '6 BB',
      isCorrect: false,
      preferredLabel: '32% · Fold',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Compare with the break-even chance.',
      feedbackReason:
          'The pot is 13 BB before you add your call, so include the 6 BB once more. The break-even chance is about 32%, and Q-7 wins 25%.',
    ),
    Act0RunnerOptionV1(
      id: 'wrong_threshold',
      label: '32% · Call',
      isCorrect: false,
      preferredLabel: '32% · Fold',
      betterAnswerLabel: '32% · Fold',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'The threshold is close. Compare it with your chance.',
      feedbackReason:
          'Calling 6 BB into the 13 BB pot makes 19 BB. Break-even is about 32%, and Q-7 wins 25%. Calling loses chips even though you identified the price.',
    ),
  ],
  table: _act0W4FacingTurnPriceV1(
    _world4BadPriceFoldRunner.table.copyWith(
      centerLabel: 'Turn decision',
      heroCards: const <Act0CardStateV1>[
        Act0CardStateV1(rank: 'Q', suit: 's'),
        Act0CardStateV1(rank: '7', suit: 'd'),
      ],
      boardCards: const <Act0CardStateV1>[
        Act0CardStateV1(rank: 'Q', suit: 'h', tone: Act0CardToneV1.red),
        Act0CardStateV1(rank: 'J', suit: 'c'),
        Act0CardStateV1(rank: '3', suit: 'd'),
        Act0CardStateV1(rank: '2', suit: 's'),
      ],
      highlightedCardIds: const <String>['hero_0', 'board_0'],
    ),
    potBeforeBet: 7,
    price: 6,
  ),
);

final _world4PriceRecapRunner = _world4PriceIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w4_price_recap',
  caption: 'Lesson learned: every call has a price.',
  hint:
      'Compare the chance of winning with the fraction of the final pot paid by the call.',
  question: 'What should you read before calling?',
  feedbackTitle: 'Price takeaway.',
  feedbackReason:
      'The price gives the required winning chance. Compare it with how often you expect to win.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Price checklist.',
      body:
          'Read the pot after the bet, the amount to call, and your chance to win.',
      focusLabels: <String>['Pot', 'To call', 'Chance to win'],
    ),
  ],
);

final _world4SizingIntroRunner = _world4PurposeIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w4_sizing_intro',
  lessonTitle: 'Small, half, pot',
  caption: 'Bet size changes pressure and price.',
  hint: 'Use the pot before the bet to work out the bet size.',
  question: 'What does size change?',
  options: const <Act0RunnerOptionV1>[],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Before and after a bet.',
      body:
          'The pot is 6 BB before your opponent bets 2 BB. The bet makes the pot 8 BB. Use the original 6 BB to measure the bet.',
      focusLabels: <String>['6 BB before', '8 BB after'],
    ),
    Act0TeachingStepV1(
      title: 'Use the pot before the bet.',
      body:
          'One-third pot means betting one-third of the pot before your bet. Half-pot means half the pot. Pot-size means a bet equal to the pot before your bet.',
      focusLabels: <String>['One-third', 'Half-pot', 'Pot-size'],
    ),
  ],
);

final _world4SmallBetRunner = _world4SizingIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w4_small_bet',
  caption: 'There are 6 BB in the pot.',
  teachingSteps: const <Act0TeachingStepV1>[],
  hint: 'One-third pot is the smallest simple pressure size here.',
  question: 'Which size is one-third pot?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'two',
      label: '2 BB',
      isCorrect: true,
      preferredLabel: '2 BB',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Excellent spot.',
      feedbackReason: '2 BB into 6 BB is one-third pot.',
    ),
    Act0RunnerOptionV1(
      id: 'six',
      label: '6 BB',
      isCorrect: false,
      preferredLabel: '2 BB',
      betterAnswerLabel: '2 BB',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason: '6 BB into 6 BB is pot-size, not one-third.',
    ),
    Act0RunnerOptionV1(
      id: 'three',
      label: '3 BB',
      isCorrect: false,
      preferredLabel: '2 BB',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Check the clue again.',
      feedbackReason: 'Three is half of six. One-third of six is two.',
    ),
  ],
  table: _world4SizingIntroRunner.table.copyWith(
    potLabel: 'Pot 6 BB',
    centerLabel: 'Before the bet',
  ),
);

final _world4HalfPotRunner = _world4SizingIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w4_half_pot_bet',
  caption: 'There are 6 BB in the pot.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Medium bet size.',
      body:
          'A half-pot bet equals half the current pot before you bet, sitting between one-third pot and pot-size.',
      focusLabels: <String>['One-third', 'Half-pot', 'Pot-size'],
    ),
  ],
  hint:
      'Half-pot means betting half the pot, not the smallest or biggest size.',
  question: 'Which size is half-pot?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'three',
      label: '3 BB',
      isCorrect: true,
      preferredLabel: '3 BB',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Spot on.',
      feedbackReason: 'Into a 6 BB pot, 3 BB is exactly a half-pot size.',
    ),
    Act0RunnerOptionV1(
      id: 'two',
      label: '2 BB',
      isCorrect: false,
      preferredLabel: '3 BB',
      betterAnswerLabel: '3 BB',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason: '2 BB into 6 BB is one-third pot, not half-pot.',
    ),
    Act0RunnerOptionV1(
      id: 'six',
      label: '6 BB',
      isCorrect: false,
      preferredLabel: '3 BB',
      betterAnswerLabel: '3 BB',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason: '6 BB into 6 BB is pot-size, not half-pot.',
    ),
  ],
  table: _world4SizingIntroRunner.table.copyWith(
    potLabel: 'Pot 6 BB',
    centerLabel: 'Before the bet',
  ),
);

final _world4PotBetRunner = _world4SizingIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w4_pot_bet',
  caption: 'Pot is 6 BB. A pot-size bet is heavy pressure.',
  teachingSteps: const <Act0TeachingStepV1>[],
  hint: 'Start with the pot just before the bet.',
  question: 'Which size is pot-size?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'six',
      label: '6 BB',
      isCorrect: true,
      preferredLabel: '6 BB',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Clean execution.',
      feedbackReason: '6 BB into 6 BB is a pot-size bet.',
    ),
    Act0RunnerOptionV1(
      id: 'two',
      label: '2 BB',
      isCorrect: false,
      preferredLabel: '6 BB',
      betterAnswerLabel: '6 BB',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason: '2 BB is one-third pot here, not pot-size.',
    ),
    Act0RunnerOptionV1(
      id: 'three',
      label: '3 BB',
      isCorrect: false,
      preferredLabel: '6 BB',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Check the clue again.',
      feedbackReason:
          'Three is half of six. A pot-size bet is equal to all six.',
    ),
  ],
  table: _world4SizingIntroRunner.table.copyWith(
    potLabel: 'Pot 6 BB',
    centerLabel: 'Before the bet',
  ),
);

Act0TableStateV1 _act0W4MinRaisePreflopTableV1() {
  final heroCards = _act0LessonCardsV1('As Ks');
  final base = _world4SizingIntroRunner.table;
  return base.copyWith(
    streetLabel: 'Preflop',
    centerLabel: 'Minimum reraise',
    potLabel: 'Pot 4.5 BB',
    toCallLabel: 'To call 3 BB',
    heroSeatId: 'co',
    activeSeatId: 'co',
    decisionSeatId: 'co',
    heroCards: heroCards,
    boardCards: const <Act0CardStateV1>[],
    highlightedCardIds: const <String>[],
    highlightedSeatIds: const <String>['hj', 'co'],
    autoPlayHistory: false,
    handContributions: const Act0HandContributionsV1(
      throughStreet: PokerStreet.preflop,
      startingStackBbBySeat: <String, double>{
        'utg': 100,
        'hj': 100,
        'co': 100,
        'btn': 100,
        'sb': 100,
        'bb': 100,
      },
      entries: <Act0ContributionV1>[
        ..._act0LessonBlinds,
        Act0ContributionV1(
          PokerStreet.preflop,
          'hj',
          Act0ContributionKindV1.wager,
          3,
        ),
      ],
    ),
    actionTrail: const <Act0ActionTrailItemV1>[
      Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
      Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
      Act0ActionTrailItemV1(label: 'UTG folds'),
      Act0ActionTrailItemV1(label: 'HJ raises to 3 BB'),
    ],
    seats: <Act0SeatStateV1>[
      for (final seat in base.seats)
        _act0CopySeatStateV1(
          seat,
          clearCommitment: true,
          isHero: seat.seatId == 'co',
          isActive: seat.seatId == 'co',
          hasActed: seat.seatId == 'utg' || seat.seatId == 'hj',
          isInHand: seat.seatId != 'utg',
          isFolded: seat.seatId == 'utg',
          isLastAggressor: seat.seatId == 'hj',
          stackLabel: switch (seat.seatId) {
            'hj' => '97 BB',
            'sb' => '99.5 BB',
            'bb' => '99 BB',
            _ => '100 BB',
          },
          bet: switch (seat.seatId) {
            'sb' => const Act0SeatBetStateV1(
              kind: Act0SeatBetKindV1.post,
              label: 'SB',
              amountLabel: '0.5 BB',
            ),
            'bb' => const Act0SeatBetStateV1(
              kind: Act0SeatBetKindV1.post,
              label: 'BB',
              amountLabel: '1 BB',
            ),
            'hj' => const Act0SeatBetStateV1(
              kind: Act0SeatBetKindV1.raise,
              label: 'HJ',
              amountLabel: '3 BB',
            ),
            _ => null,
          },
          holeCards: seat.seatId == 'co' ? heroCards : _unknownHoleCards,
          cardsVisibleMode: switch (seat.seatId) {
            'co' => Act0CardsVisibleModeV1.faceUp,
            'utg' => Act0CardsVisibleModeV1.none,
            _ => Act0CardsVisibleModeV1.faceDown,
          },
        ),
    ],
  );
}

Act0TableStateV1 _act0W4MinRaisePostflopTableV1() {
  final heroCards = _act0LessonCardsV1('Ah Qd');
  final boardCards = _act0LessonCardsV1('As 8c 3d');
  final base = _world4SizingIntroRunner.table;
  return base.copyWith(
    streetLabel: 'Flop',
    centerLabel: 'Minimum raise',
    potLabel: 'Pot 10.5 BB',
    toCallLabel: 'To call 4 BB',
    heroSeatId: 'co',
    activeSeatId: 'co',
    decisionSeatId: 'co',
    heroCards: heroCards,
    boardCards: boardCards,
    highlightedCardIds: const <String>[],
    highlightedSeatIds: const <String>['bb', 'co'],
    autoPlayHistory: false,
    handContributions: const Act0HandContributionsV1(
      throughStreet: PokerStreet.flop,
      startingStackBbBySeat: <String, double>{
        'utg': 100,
        'hj': 100,
        'co': 100,
        'btn': 100,
        'sb': 100,
        'bb': 100,
      },
      entries: <Act0ContributionV1>[
        ..._act0LessonBlinds,
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
        Act0ContributionV1(
          PokerStreet.flop,
          'bb',
          Act0ContributionKindV1.wager,
          4,
        ),
      ],
    ),
    actionTrail: const <Act0ActionTrailItemV1>[
      Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
      Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
      Act0ActionTrailItemV1(label: 'UTG folds'),
      Act0ActionTrailItemV1(label: 'HJ folds'),
      Act0ActionTrailItemV1(label: 'CO raises to 3 BB'),
      Act0ActionTrailItemV1(label: 'BTN folds'),
      Act0ActionTrailItemV1(label: 'SB folds'),
      Act0ActionTrailItemV1(
        label: 'BB calls 3 BB',
        displayLabel: 'BB calls 2 BB more',
      ),
      Act0ActionTrailItemV1(label: 'Flop: BB bets 4 BB'),
    ],
    seats: <Act0SeatStateV1>[
      for (final seat in base.seats)
        _act0CopySeatStateV1(
          seat,
          clearCommitment: true,
          isHero: seat.seatId == 'co',
          isActive: seat.seatId == 'co',
          hasActed: seat.seatId != 'co',
          isInHand: seat.seatId == 'co' || seat.seatId == 'bb',
          isFolded: seat.seatId != 'co' && seat.seatId != 'bb',
          isLastAggressor: seat.seatId == 'bb',
          stackLabel: switch (seat.seatId) {
            'co' => '97 BB',
            'sb' => '99.5 BB',
            'bb' => '93 BB',
            _ => '100 BB',
          },
          bet: seat.seatId == 'bb'
              ? const Act0SeatBetStateV1(
                  kind: Act0SeatBetKindV1.bet,
                  label: 'BB',
                  amountLabel: '4 BB',
                )
              : null,
          holeCards: seat.seatId == 'co' ? heroCards : _unknownHoleCards,
          cardsVisibleMode: switch (seat.seatId) {
            'co' => Act0CardsVisibleModeV1.faceUp,
            'bb' => Act0CardsVisibleModeV1.faceDown,
            _ => Act0CardsVisibleModeV1.none,
          },
        ),
    ],
  );
}

final _world4MinRaisePreflopRunner = _world4SizingIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w4_min_raise_preflop',
  caption: 'HJ raises to 3 BB over the 1 BB blind. Your turn from CO.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Minimum raise rule.',
      body:
          'A full raise must add at least the size of the last bet or full raise. A short all-in can be smaller. Over a 1 BB blind, a raise to 3 BB adds 2 BB, so the smallest full reraise is 5 BB total.',
      focusSeatIds: <String>['bb', 'hj', 'co'],
      focusLabels: <String>['+2 BB increase', '5 BB minimum'],
    ),
  ],
  hint:
      'Find how much HJ added above the 1 BB blind, then add at least that much to 3 BB.',
  question: 'What is the smallest legal reraise total from CO?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'four_bb',
      label: 'Raise to 4 BB',
      isCorrect: false,
      preferredLabel: 'Raise to 5 BB',
      betterAnswerLabel: 'Raise to 5 BB',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too small to be legal.',
      repairFocusLabels: <String>['Minimum raise'],
      feedbackReason:
          "A raise to 4 BB adds only 1 BB, below HJ’s 2 BB raise increment. Raise to at least 5 BB to make a legal reraise.",
    ),
    Act0RunnerOptionV1(
      id: 'five_bb',
      label: 'Raise to 5 BB',
      isCorrect: true,
      preferredLabel: 'Raise to 5 BB',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Legal minimum reraise.',
      repairFocusLabels: <String>['Minimum raise'],
      feedbackReason:
          "HJ raises from 1 BB to 3 BB, so your minimum adds 2 BB and totals 5 BB. A raise to 6 BB is legal but uses 1 BB more.",
    ),
    Act0RunnerOptionV1(
      id: 'six_bb',
      label: 'Raise to 6 BB',
      isCorrect: false,
      preferredLabel: 'Raise to 5 BB',
      betterAnswerLabel: 'Raise to 5 BB',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Larger than the minimum.',
      repairFocusLabels: <String>['Minimum raise'],
      feedbackReason:
          '6 BB adds 3 BB to HJ\'s 3 BB raise, which is legal but 1 BB larger than the 5 BB minimum reraise.',
    ),
  ],
  table: _act0W4MinRaisePreflopTableV1(),
);

final _world4MinRaisePostflopRunner = _world4SizingIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w4_min_raise_postflop',
  caption: 'BB bets 4 BB on the flop into a 6.5 BB pot. Your turn from CO.',
  teachingSteps: const <Act0TeachingStepV1>[],
  hint: 'Add at least the size of BB\'s 4 BB bet on top of the 4 BB call.',
  question:
      'BB bets 4 BB on the flop. What is the smallest legal raise total from CO?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'six_bb',
      label: '6 BB',
      isCorrect: false,
      preferredLabel: '8 BB',
      betterAnswerLabel: '8 BB',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too small to be legal.',
      repairFocusLabels: <String>['Minimum raise'],
      feedbackReason:
          '6 BB adds 2 BB to BB\'s 4 BB bet, which is below the 4 BB bet size, so 6 BB is illegal.',
    ),
    Act0RunnerOptionV1(
      id: 'twelve_bb',
      label: '12 BB',
      isCorrect: false,
      preferredLabel: '8 BB',
      betterAnswerLabel: '8 BB',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Larger than the minimum.',
      repairFocusLabels: <String>['Minimum raise'],
      feedbackReason:
          '12 BB adds 8 BB to BB\'s 4 BB bet, which is legal but 4 BB larger than the 8 BB minimum raise.',
    ),
    Act0RunnerOptionV1(
      id: 'eight_bb',
      label: '8 BB',
      isCorrect: true,
      preferredLabel: '8 BB',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Legal minimum raise.',
      repairFocusLabels: <String>['Minimum raise'],
      feedbackReason:
          'BB bet 4 BB on the flop, so adding 4 BB on top of 4 BB makes 8 BB the smallest legal raise.',
    ),
  ],
  table: _act0W4MinRaisePostflopTableV1(),
);

final _world4SizingRecapRunner = _world4SizingIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w4_sizing_recap',
  caption: 'Lesson learned: size sets pressure and price.',
  hint: 'Small, half-pot, and pot-size should match the purpose.',
  question: 'What should size match?',
  feedbackTitle: 'Sizing takeaway.',
  feedbackReason:
      'Size is not decoration. It creates the price your opponent must face.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Sizing checklist.',
      body:
          'Name purpose, then choose a size that fits the pressure: light, middle, or heavy.',
      focusLabels: <String>['Purpose', 'Pressure', 'Price'],
    ),
  ],
);

final _world4CheckpointIntroRunner = _world4PurposeIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w4_checkpoint_intro',
  lessonTitle: 'Price checkpoint',
  caption: 'Checkpoint: purpose, size, and price work together.',
  hint: 'The bettor sets pressure. The caller reads the price.',
  question: 'What are the three World 4 reads?',
  options: const <Act0RunnerOptionV1>[],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Three reads.',
      body:
          'Purpose explains why. Size creates pressure. Compare the price with your chance to win before calling.',
      focusLabels: <String>['Purpose', 'Size', 'Price'],
    ),
  ],
);

final _world4PriceTableTransferRunner = _world4GoodPriceCallRunner.copyWith(
  lessonId: 'w4_price_table_transfer',
  caption: 'BB bet 2 BB on the turn. $_world4PriceReminder',
  hint: 'Compare the stated chance with the share of the final pot you pay.',
  question:
      'Two players, no ties or more bets. If you call, you win 3 times in 10, about 1 in 3 (30%). Which earns more, call or fold?',
  options: const [
    Act0RunnerOptionV1(
      id: 'call',
      label: 'Call',
      amountLabel: '2 BB',
      isCorrect: true,
      preferredLabel: 'Call',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Price and chance compared.',
      feedbackReason:
          "BB bets 2 BB, so calling makes a 9 BB pot and needs about 22.2%. The stated 30% clears the price. Folding gives up the gain.",
    ),
    Act0RunnerOptionV1(
      id: 'fold',
      label: 'Fold',
      isCorrect: false,
      preferredLabel: 'Call',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Compare with the break-even chance.',
      feedbackReason:
          'Folding gives up a profitable call in this model: 30% is higher than the roughly 22.2% you need.',
    ),
    Act0RunnerOptionV1(
      id: 'call_ignore_price',
      label: 'Call because BB bet just 2 BB',
      isCorrect: false,
      preferredLabel: 'Call',
      betterAnswerLabel: 'Call',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'The action fits. Compare both numbers.',
      feedbackReason:
          "Calling just because the bet is small can cost chips. Here it works because the stated 30% is above the roughly 22% price.",
    ),
  ],
  table: _act0W4FacingTurnPriceV1(
    _world4GoodPriceCallRunner.table.copyWith(
      streetLabel: 'Turn',
      centerLabel: 'Turn decision',
      heroCards: const <Act0CardStateV1>[
        Act0CardStateV1(rank: 'A', suit: 'c'),
        Act0CardStateV1(rank: '9', suit: 'd'),
      ],
      boardCards: const <Act0CardStateV1>[
        Act0CardStateV1(rank: 'K', suit: 'h', tone: Act0CardToneV1.red),
        Act0CardStateV1(rank: '9', suit: 's'),
        Act0CardStateV1(rank: '4', suit: 'c'),
        Act0CardStateV1(rank: '2', suit: 'd'),
      ],
      highlightedSeatIds: const <String>['btn', 'bb'],
      highlightedCardIds: const <String>['hero_1', 'board_1'],
    ),
    potBeforeBet: 5,
    price: 2,
    bettor: 'bb',
  ),
);

final _world4PurposePriceTableTransferRunner = _world4ValueBetRunner.copyWith(
  lessonId: 'w4_purpose_price_table_transfer',
  caption: 'BTN bet 2 BB. It is BB’s turn.',
  hint: 'Compare the reason for the bet and the amount BB must add.',
  question:
      'In this example, BTN bets 2 BB into 6 BB to get called by weaker aces. What is the clean read?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'small_value_price',
      label: 'Value · 2 BB to call',
      isCorrect: true,
      preferredLabel: 'Value · 2 BB to call',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Exactly.',
      feedbackReason:
          'BTN targets weaker aces, so this is a value bet. BB has put in nothing on this street and must add 2 BB to call.',
    ),
    Act0RunnerOptionV1(
      id: 'pot_bluff',
      label: 'Bluff · 2 BB to call',
      isCorrect: false,
      preferredLabel: 'Value · 2 BB to call',
      betterAnswerLabel: 'Value · 2 BB to call',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not this frame.',
      feedbackReason:
          'The price is 2 BB. The stated weaker aces can call, so the purpose is value.',
    ),
    Act0RunnerOptionV1(
      id: 'random_size',
      label: 'Value · 6 BB to call',
      isCorrect: false,
      preferredLabel: 'Value · 2 BB to call',
      betterAnswerLabel: 'Value · 2 BB to call',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'The price is 2 BB.',
      feedbackReason:
          'The purpose is value. BB must match the 2 BB bet shown on the table.',
    ),
  ],
  table: _act0CurrentStreetTableV1(
    _world4ValueBetRunner.table.copyWith(
      potLabel: 'Pot 8 BB',
      toCallLabel: 'To call 2 BB',
      decisionSeatId: 'bb',
      seats: [
        for (final seat in _world4ValueBetRunner.table.seats)
          if (seat.seatId == 'bb')
            _act0CopySeatStateV1(seat, isActive: true, hasActed: false)
          else if (seat.seatId == 'btn')
            _act0CopySeatStateV1(
              seat,
              isActive: false,
              hasActed: true,
              isLastAggressor: true,
            )
          else
            seat,
      ],
      centerLabel: 'After the flop bet',
      activeSeatId: 'bb',
      heroCards: const <Act0CardStateV1>[
        Act0CardStateV1(rank: 'A', suit: 's'),
        Act0CardStateV1(rank: 'Q', suit: 'd'),
      ],
      boardCards: const <Act0CardStateV1>[
        Act0CardStateV1(rank: 'A', suit: 'h', tone: Act0CardToneV1.red),
        Act0CardStateV1(rank: '7', suit: 'c'),
        Act0CardStateV1(rank: '2', suit: 'd', tone: Act0CardToneV1.red),
      ],
      handContributions: const Act0HandContributionsV1(
        throughStreet: PokerStreet.flop,
        startingStackBbBySeat: {'bb': 100},
        entries: [
          ..._act0LessonBlinds,
          Act0ContributionV1(
            PokerStreet.preflop,
            'btn',
            Act0ContributionKindV1.wager,
            2.75,
          ),
          Act0ContributionV1(
            PokerStreet.preflop,
            'bb',
            Act0ContributionKindV1.wager,
            1.75,
          ),
          Act0ContributionV1(
            PokerStreet.flop,
            'btn',
            Act0ContributionKindV1.wager,
            2,
          ),
        ],
      ),
      actionTrail: const <Act0ActionTrailItemV1>[
        ..._w4BtnBbSixBbFlopTrailV1,
        Act0ActionTrailItemV1(label: 'BTN bets 2 BB'),
        Act0ActionTrailItemV1(label: 'BB acts'),
      ],
      highlightedSeatIds: const <String>['btn', 'bb'],
      highlightedCardIds: const <String>['hero_0', 'board_0'],
    ),
    bets: {
      'btn': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.bet,
        label: 'BTN',
        amountLabel: '2 BB',
      ),
    },
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Purpose and price travel together.',
      body:
          'Read what the bettor expects from the other hand. Then find what the other player must add.',
      focusLabels: <String>['Purpose', 'Amount to add'],
    ),
  ],
);

final _world4CheckpointRunner = _world4CheckpointIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w4_checkpoint_review',
  caption: 'Lesson learned: read the bet purpose, size, and call price.',
  hint: 'Value, bluff, protection, and call price are now one system.',
  question: 'What makes a bet easier to understand?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'purpose_price',
      label: 'Purpose and price',
      isCorrect: true,
      preferredLabel: 'Purpose and price',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Purpose and price connected.',
      feedbackReason:
          "A bet can ask a weaker hand to call or a better hand to fold. Looking at size alone misses which job the bet is doing.",
    ),
    Act0RunnerOptionV1(
      id: 'random_size',
      label: 'Random size',
      isCorrect: false,
      preferredLabel: 'Purpose and price',
      betterAnswerLabel: 'Purpose and price',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'Random sizes hide the lesson. Good beginner bets have a clear job.',
    ),
    Act0RunnerOptionV1(
      id: 'size_only',
      label: 'Size and pot, without purpose',
      isCorrect: false,
      preferredLabel: 'Purpose and price',
      betterAnswerLabel: 'Purpose and price',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'One part of the decision.',
      feedbackReason:
          'In a 6 BB pot the same 3 BB bet can ask a weaker hand to call or a better hand to fold. Reading size alone can make you pay or bet for the wrong reason.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'World 4 checkpoint.',
      body: 'Read what the bet wants and what it costs to continue.',
      focusLabels: <String>['Value', 'Bluff', 'Protection', 'Price'],
    ),
  ],
);

List<Act0CardStateV1> _act0LessonCardsV1(String cards) => [
  for (final card in cards.split(' '))
    Act0CardStateV1(
      rank: card[0],
      suit: card[1],
      tone: card[1] == 'h' || card[1] == 'd'
          ? Act0CardToneV1.red
          : Act0CardToneV1.dark,
    ),
];

// BTN opens, BB defends, and the small blind stays in the pot. Earlier
// streets either check through or close with BTN betting and BB calling.
const _act0LessonBlinds = [
  Act0ContributionV1(
    PokerStreet.preflop,
    'sb',
    Act0ContributionKindV1.blind,
    .5,
  ),
  Act0ContributionV1(
    PokerStreet.preflop,
    'bb',
    Act0ContributionKindV1.blind,
    1,
  ),
];

const _act0BlindsOnlyContributions = Act0HandContributionsV1(
  throughStreet: PokerStreet.preflop,
  entries: _act0LessonBlinds,
);

// Starting stacks belong to these authored examples, not the previous driver
// of the reused preflop table. Only the two forced posts precede this turn.
Act0HandContributionsV1 _act0UnopenedPriceContributionsV1(String actorSeatId) =>
    Act0HandContributionsV1(
      throughStreet: PokerStreet.preflop,
      startingStackBbBySeat: {actorSeatId: 100},
      entries: _act0LessonBlinds,
    );

// Cash examples without antes. These ledgers record chip movements, including
// folded blinds. Earlier postflop streets check through unless a bet is listed.
const _act0LessonWager = Act0ContributionKindV1.wager;

List<Act0ContributionV1> _act0ButtonVsBigBlindPreflopV1(double openBb) => [
  ..._act0LessonBlinds,
  Act0ContributionV1(PokerStreet.preflop, 'btn', _act0LessonWager, openBb),
  Act0ContributionV1(PokerStreet.preflop, 'bb', _act0LessonWager, openBb - 1),
];

Act0HandContributionsV1 _act0BoardReadingContributionsV1(
  PokerStreet street, {
  double openBb = 2.25,
}) => Act0HandContributionsV1(
  throughStreet: street,
  entries: _act0ButtonVsBigBlindPreflopV1(openBb),
);

// UTG and BTN limp, SB completes, BB checks.
const _act0FourPlayerLimpedEntries = [
  ..._act0LessonBlinds,
  Act0ContributionV1(PokerStreet.preflop, 'utg', _act0LessonWager, 1),
  Act0ContributionV1(PokerStreet.preflop, 'btn', _act0LessonWager, 1),
  Act0ContributionV1(PokerStreet.preflop, 'sb', _act0LessonWager, 0.5),
];

const _act0FourPlayerLimpedPot = Act0HandContributionsV1(
  throughStreet: PokerStreet.flop,
  entries: _act0FourPlayerLimpedEntries,
);

// For the action-order examples UTG is a live player and HJ also limps.
const _act0FivePlayerPositionPot = Act0HandContributionsV1(
  throughStreet: PokerStreet.flop,
  entries: [
    ..._act0LessonBlinds,
    Act0ContributionV1(PokerStreet.preflop, 'utg', _act0LessonWager, 1),
    Act0ContributionV1(PokerStreet.preflop, 'hj', _act0LessonWager, 1),
    Act0ContributionV1(PokerStreet.preflop, 'btn', _act0LessonWager, 1),
    Act0ContributionV1(PokerStreet.preflop, 'sb', _act0LessonWager, 0.5),
  ],
);

// Only the two compared hands are exposed in these five-way checkdowns.
const _act0FivePlayerComparisonPot = Act0HandContributionsV1(
  throughStreet: PokerStreet.river,
  entries: [
    ..._act0LessonBlinds,
    Act0ContributionV1(PokerStreet.preflop, 'hj', _act0LessonWager, 1),
    Act0ContributionV1(PokerStreet.preflop, 'co', _act0LessonWager, 1),
    Act0ContributionV1(PokerStreet.preflop, 'btn', _act0LessonWager, 1),
    Act0ContributionV1(PokerStreet.preflop, 'sb', _act0LessonWager, 0.5),
  ],
);

// CO and BTN limp, SB folds and BB checks. On the flop BB checks, CO
// commits their last 0.75 BB, BTN calls, and BB folds before the runout.
const _act0HeadsUpShowdownPot = Act0HandContributionsV1(
  throughStreet: PokerStreet.river,
  startingStackBbBySeat: {'co': 1.75, 'btn': 100},
  entries: [
    ..._act0LessonBlinds,
    Act0ContributionV1(PokerStreet.preflop, 'co', _act0LessonWager, 1),
    Act0ContributionV1(PokerStreet.preflop, 'btn', _act0LessonWager, 1),
    Act0ContributionV1(PokerStreet.flop, 'co', _act0LessonWager, 0.75),
    Act0ContributionV1(PokerStreet.flop, 'btn', _act0LessonWager, 0.75),
  ],
);

// BB folds to BTN's flop bet. The uncalled chip is returned before award.
final _act0FoldoutPot = Act0HandContributionsV1(
  throughStreet: PokerStreet.flop,
  entries: [
    ..._act0ButtonVsBigBlindPreflopV1(2.25),
    const Act0ContributionV1(PokerStreet.flop, 'btn', _act0LessonWager, 1),
    const Act0ContributionV1(
      PokerStreet.flop,
      'btn',
      Act0ContributionKindV1.uncalledReturn,
      1,
    ),
  ],
);

Act0TableStateV1 _act0BoardLessonTableV1({
  required List<Act0CardStateV1> heroCards,
  required List<Act0CardStateV1> boardCards,
  required String centerLabel,
  String openingSeat = 'btn',
  num openBb = 2.5,
  num flopBetBb = 0,
  num turnBetBb = 0,
  num facingBb = 0,
  num? heroBehindBb,
  num? bbBehindBb,
  List<String> highlightedCardIds = const [],
}) {
  final bettingStreet = switch (boardCards.length) {
    3 => PokerStreet.flop,
    4 => PokerStreet.turn,
    5 => PokerStreet.river,
    _ => throw ArgumentError.value(boardCards, 'boardCards'),
  };
  final street = pokerStreetToString(bettingStreet);
  final collectedPerPlayer = openBb + flopBetBb + turnBetBb;
  final heroBehind = heroBehindBb ?? 100 - collectedPerPlayer;
  final bigBlindBehind = bbBehindBb ?? 100 - collectedPerPlayer - facingBb;
  const wager = Act0ContributionKindV1.wager;
  final openingLabel = openingSeat.toUpperCase();
  const preflopBeforeBb = ['utg', 'hj', 'co', 'btn', 'sb'];
  return Act0TableStateV1(
    scope: Act0TableScopeV1.playedHand,
    tableFormat: Act0TableFormatV1.sixMax,
    playerCount: 6,
    heroSeatId: openingSeat,
    activeSeatId: openingSeat,
    decisionSeatId: openingSeat,
    heroCards: heroCards,
    boardCards: boardCards,
    streetLabel: street,
    potLabel: 'Pot ${_act0BbLabelV1(2 * collectedPerPlayer + 0.5 + facingBb)}',
    toCallLabel: facingBb > 0 ? 'To call ${_act0BbLabelV1(facingBb)}' : '',
    centerLabel: centerLabel,
    handContributions: Act0HandContributionsV1(
      throughStreet: bettingStreet,
      startingStackBbBySeat: {
        openingSeat: (heroBehind + collectedPerPlayer).toDouble(),
        'bb': (bigBlindBehind + collectedPerPlayer + facingBb).toDouble(),
      },
      entries: [
        ..._act0LessonBlinds,
        Act0ContributionV1(
          PokerStreet.preflop,
          openingSeat,
          wager,
          openBb.toDouble(),
        ),
        Act0ContributionV1(
          PokerStreet.preflop,
          'bb',
          wager,
          (openBb - 1).toDouble(),
        ),
        if (boardCards.length >= 4 && flopBetBb > 0) ...[
          Act0ContributionV1(
            PokerStreet.flop,
            openingSeat,
            wager,
            flopBetBb.toDouble(),
          ),
          Act0ContributionV1(
            PokerStreet.flop,
            'bb',
            wager,
            flopBetBb.toDouble(),
          ),
        ],
        if (boardCards.length == 5 && turnBetBb > 0) ...[
          Act0ContributionV1(
            PokerStreet.turn,
            openingSeat,
            wager,
            turnBetBb.toDouble(),
          ),
          Act0ContributionV1(
            PokerStreet.turn,
            'bb',
            wager,
            turnBetBb.toDouble(),
          ),
        ],
        if (facingBb > 0)
          Act0ContributionV1(bettingStreet, 'bb', wager, facingBb.toDouble()),
      ],
    ),
    autoPlayHistory: false,
    highlightedSeatIds: const [],
    highlightedCardIds: highlightedCardIds,
    actionTrail: [
      const Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
      const Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
      for (final seat in preflopBeforeBb)
        Act0ActionTrailItemV1(
          label: seat == openingSeat
              ? '$openingLabel raises ${_act0BbLabelV1(openBb)}'
              : '${seat.toUpperCase()} folds',
        ),
      Act0ActionTrailItemV1(
        label: 'BB calls ${_act0BbLabelV1(openBb)}',
        displayLabel: 'BB calls ${_act0BbLabelV1(openBb - 1)} more',
      ),
      if (boardCards.length >= 4) ...[
        const Act0ActionTrailItemV1(label: 'Flop: BB checks'),
        if (flopBetBb == 0)
          Act0ActionTrailItemV1(label: '$openingLabel checks')
        else ...[
          Act0ActionTrailItemV1(
            label: '$openingLabel bets ${_act0BbLabelV1(flopBetBb)}',
          ),
          Act0ActionTrailItemV1(label: 'BB calls ${_act0BbLabelV1(flopBetBb)}'),
        ],
      ],
      if (boardCards.length == 5) ...[
        const Act0ActionTrailItemV1(label: 'Turn: BB checks'),
        if (turnBetBb == 0)
          Act0ActionTrailItemV1(label: '$openingLabel checks')
        else ...[
          Act0ActionTrailItemV1(
            label: '$openingLabel bets ${_act0BbLabelV1(turnBetBb)}',
          ),
          Act0ActionTrailItemV1(label: 'BB calls ${_act0BbLabelV1(turnBetBb)}'),
        ],
      ],
      Act0ActionTrailItemV1(
        label: facingBb == 0
            ? '$street: BB checks'
            : '$street: BB bets ${_act0BbLabelV1(facingBb)}',
      ),
    ],
    seats: [
      for (final seat in _readBoardRunner.table.seats)
        _act0CopySeatStateV1(
          seat,
          displayName: seat.seatId == openingSeat
              ? 'Hero'
              : seat.isHero
              ? seat.seatLabel
              : seat.displayName,
          isHero: seat.seatId == openingSeat,
          isInHand: seat.seatId == openingSeat || seat.seatId == 'bb',
          isFolded: seat.seatId != openingSeat && seat.seatId != 'bb',
          isActive: seat.seatId == openingSeat,
          hasActed: seat.seatId != openingSeat,
          isLastAggressor: seat.seatId == 'bb' && facingBb > 0,
          clearCommitment: true,
          stackLabel: _act0BbLabelV1(switch (seat.seatId) {
            _ when seat.seatId == openingSeat => heroBehind,
            'bb' => bigBlindBehind,
            'sb' => 99.5,
            _ => 100,
          }),
          bet: seat.seatId == 'bb' && facingBb > 0
              ? Act0SeatBetStateV1(
                  kind: Act0SeatBetKindV1.bet,
                  label: 'BB',
                  amountLabel: _act0BbLabelV1(facingBb),
                )
              : null,
          holeCards: seat.seatId == openingSeat ? heroCards : _unknownHoleCards,
          cardsVisibleMode: seat.seatId != openingSeat && seat.seatId != 'bb'
              ? Act0CardsVisibleModeV1.none
              : seat.seatId == openingSeat
              ? Act0CardsVisibleModeV1.faceUp
              : Act0CardsVisibleModeV1.faceDown,
        ),
    ],
  );
}

Act0TableStateV1 _act0UnopenedLessonTableV1({
  required List<Act0CardStateV1> heroCards,
  required String centerLabel,
}) {
  const format = Act0TableFormatV1.sixMax;
  final seatOrder = act0CanonicalSeatOrderForFormatV1(format);
  return Act0TableStateV1(
    scope: Act0TableScopeV1.playedHand,
    tableFormat: format,
    playerCount: seatOrder.length,
    heroSeatId: 'utg',
    activeSeatId: 'utg',
    decisionSeatId: 'utg',
    heroCards: heroCards,
    boardCards: const [],
    streetLabel: 'Preflop',
    potLabel: 'Pot 1.5 BB',
    toCallLabel: 'To call 1 BB',
    centerLabel: centerLabel,
    handContributions: const Act0HandContributionsV1(
      throughStreet: PokerStreet.preflop,
      startingStackBbBySeat: {'utg': 100},
      entries: _act0LessonBlinds,
    ),
    autoPlayHistory: false,
    highlightedSeatIds: const [],
    highlightedCardIds: const [],
    actionTrail: const [
      Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
      Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
    ],
    seats: [
      for (final position in seatOrder)
        Act0SeatStateV1(
          seatId: position.toLowerCase(),
          seatLabel: position,
          displayName: position == 'UTG' ? 'Hero' : position,
          isHero: position == 'UTG',
          isActive: position == 'UTG',
          isDealerButton: position == 'BTN',
          isSmallBlind: position == 'SB',
          isBigBlind: position == 'BB',
          blindAmountLabel: switch (position) {
            'SB' => '0.5 BB',
            'BB' => '1 BB',
            _ => null,
          },
          stackLabel: switch (position) {
            'SB' => '99.5 BB',
            'BB' => '99 BB',
            _ => '100 BB',
          },
          bet: switch (position) {
            'SB' => _smallBlindPost,
            'BB' => _bigBlindPost,
            _ => null,
          },
          holeCards: position == 'UTG' ? heroCards : _unknownHoleCards,
          cardsVisibleMode: position == 'UTG' && heroCards != _unknownHoleCards
              ? Act0CardsVisibleModeV1.faceUp
              : Act0CardsVisibleModeV1.faceDown,
        ),
    ],
  );
}

final _world5TextureIntroRunner = _readBoardRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w5_texture_intro',
  lessonTitle: 'Dry or wet board',
  lessonSubtitle: 'Board Awareness',
  caption: 'Board texture asks how much the next cards can change.',
  hint: 'Dry boards change less. Wet boards create more threats.',
  question: 'What does board texture describe?',
  options: const <Act0RunnerOptionV1>[],
  table: _act0BoardLessonTableV1(
    openingSeat: 'hj',
    heroCards: _act0LessonCardsV1('Ac Jd'),
    boardCards: _act0LessonCardsV1('Ks 8h 3c'),
    centerLabel: 'Read the flop',
    highlightedCardIds: const ['board_0', 'board_1', 'board_2'],
  ),
  teachingSteps: <Act0TeachingStepV1>[
    const Act0TeachingStepV1(
      title: 'What can change?',
      body:
          "A dry board has few ways for the next card to change who leads. A wet board has many. When ranks sit close together or suits match, more hands can improve.",
      focusLabels: <String>['Rank gaps', 'Suits'],
    ),
    Act0TeachingStepV1(
      title: 'Three of one suit.',
      body:
          'These three spades are called a monotone flop. A player with two more spades already has a flush.',
      table: _act0BoardLessonTableV1(
        openingSeat: 'hj',
        heroCards: _act0LessonCardsV1('Ac Jd'),
        boardCards: _act0LessonCardsV1('Ks 8s 3s'),
        centerLabel: 'Read the flop',
        highlightedCardIds: const ['board_0', 'board_1', 'board_2'],
      ),
    ),
  ],
  feedbackTitle: 'Texture first.',
  feedbackReason:
      'Rank gaps and matching suits tell you how much the next card can change.',
);

final _world5DryBoardRunner = _world5TextureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w5_dry_board',
  caption: 'Read the three flop cards.',
  teachingSteps: const <Act0TeachingStepV1>[],
  hint: 'Few obvious straight or flush paths are visible.',
  question: 'What texture is this?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'dry',
      label: 'Dry',
      isCorrect: true,
      preferredLabel: 'Dry',
      repairFocusCardIds: <String>['board_0', 'board_1', 'board_2'],
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Sharp read.',
      feedbackReason: 'Spread ranks and mixed suits make this a dry board.',
    ),
    Act0RunnerOptionV1(
      id: 'wet',
      label: 'Wet',
      isCorrect: false,
      preferredLabel: 'Dry',
      betterAnswerLabel: 'Dry',
      repairFocusCardIds: <String>['board_0', 'board_1', 'board_2'],
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'K-7-2 has three suits and wide gaps. Treating it as wet can make you pay to protect against unlikely straights and flushes.',
    ),
    Act0RunnerOptionV1(
      id: 'semi_wet',
      label: 'Semi-wet',
      isCorrect: false,
      preferredLabel: 'Dry',
      betterAnswerLabel: 'Dry',
      repairFocusCardIds: <String>['board_0', 'board_1', 'board_2'],
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'The flop has few short paths.',
      feedbackReason:
          'K-7-2 has wide rank gaps and three suits. Marking it semi-wet gives too much weight to hands that still need both remaining cards.',
    ),
  ],
  table: _act0BoardLessonTableV1(
    openingSeat: 'co',
    heroCards: _act0LessonCardsV1('Ah Tc'),
    boardCards: _act0LessonCardsV1('Kc 7d 2s'),
    centerLabel: 'Read the flop',
    highlightedCardIds: const ['board_0', 'board_1', 'board_2'],
  ),
);

final _world5WetBoardRunner = _world5TextureIntroRunner.copyWith(
  caption: 'Look at the flop ranks and suits.',
  lessonId: 'w5_wet_board',
  hint: 'Notice the connected ranks and two hearts before choosing texture.',
  question: 'What texture is this?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'wet',
      label: 'Wet',
      isCorrect: true,
      preferredLabel: 'Wet',
      repairFocusCardIds: <String>['board_0', 'board_1', 'board_2'],
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Strong choice.',
      feedbackReason:
          'The connected ranks and two hearts create many changes. Straight paths, heart pressure, and future cards can all change the next decision quickly.',
    ),
    Act0RunnerOptionV1(
      id: 'dry',
      label: 'Dry',
      isCorrect: false,
      preferredLabel: 'Wet',
      betterAnswerLabel: 'Wet',
      repairFocusCardIds: <String>['board_0', 'board_1', 'board_2'],
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'On T-9-8 with two hearts, a straight can already be made and another heart can complete a flush. Treating the flop as dry risks giving a free card on a board with several ways to make a better hand.',
    ),
    Act0RunnerOptionV1(
      id: 'semi_wet',
      label: 'Semi-wet',
      isCorrect: false,
      preferredLabel: 'Wet',
      betterAnswerLabel: 'Wet',
      repairFocusCardIds: <String>['board_0', 'board_1', 'board_2'],
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Both ways to improve are present.',
      feedbackReason:
          'T-9-8 has consecutive ranks and two hearts. Calling it semi-wet misses one set of threats and makes the next card easier to underestimate.',
    ),
  ],
  table: _act0BoardLessonTableV1(
    openingSeat: 'co',
    heroCards: _act0LessonCardsV1('Js Td'),
    boardCards: _act0LessonCardsV1('Th 9h 8c'),
    centerLabel: 'Read the flop',
    highlightedCardIds: const ['board_0', 'board_1', 'board_2'],
  ),
  teachingSteps: const [],
);

final _world5TextureRecapRunner = _world5TextureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w5_texture_recap',
  caption: 'Lesson learned: texture says how fast a board can change.',
  hint: 'Dry is calmer. Wet has more obvious improvement paths.',
  question: 'What is the first board read?',
  feedbackTitle: 'Texture takeaway.',
  feedbackReason:
      'Read dry or wet first so the board tells you how much can change.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Texture checklist.',
      body:
          'Read the gaps between ranks and count matching suits. Those two facts tell you how much the next card may change.',
      focusLabels: <String>['Ranks', 'Suits', 'Change'],
    ),
  ],
  table: _act0BoardLessonTableV1(
    openingSeat: 'hj',
    heroCards: _act0LessonCardsV1('As Jc'),
    boardCards: _act0LessonCardsV1('9d 9h 3s'),
    centerLabel: 'Read the flop',
  ),
);

final _world5ConnectedIntroRunner = _world5TextureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w5_connected_intro',
  lessonTitle: 'Connected boards',
  caption: 'Connected ranks sit close together, like 9-8-7.',
  hint: 'Close ranks create more straight paths.',
  question: 'What makes a board connected?',
  options: const <Act0RunnerOptionV1>[],
  table: _act0BoardLessonTableV1(
    openingSeat: 'co',
    heroCards: _act0LessonCardsV1('Qd Jc'),
    boardCards: _act0LessonCardsV1('9h 8s 7d'),
    centerLabel: 'Read the ranks',
    highlightedCardIds: const ['board_0', 'board_1', 'board_2'],
  ),
  teachingSteps: <Act0TeachingStepV1>[
    const Act0TeachingStepV1(
      title: 'Ranks can connect.',
      body:
          'Check the gap on each side of the middle rank. On 9-8-7, a player holding J-T can use every flop rank to make a straight. That possibility exists before anyone bets. With Q-J instead, you still need a ten to make five consecutive ranks.',
      focusLabels: <String>['9', '8', '7', 'Connected'],
    ),
    Act0TeachingStepV1(
      title: 'Ranks and suits describe different things.',
      table: _day7PostflopV1(
        'co',
        'Qd Jc',
        '9c 9h 4c',
        openBb: 2.5,
        checkedToHero: true,
      ),
      body:
          'A paired board repeats one of its ranks. Two-tone means two flop cards share a suit. A draw is a hand that needs another card to complete.',
    ),
  ],
  feedbackTitle: 'Read the rank gaps.',
  feedbackReason:
      'Three nearby ranks, such as 9-8-7, give private cards more ways to complete a straight.',
);

final _world5DisconnectedBoardRunner = _world5DryBoardRunner.copyWith(
  caption: 'Look at the flop ranks.',
  lessonId: 'w5_disconnected_board',
  hint: 'The ranks are far apart.',
  question: 'Which rank pattern fits the flop?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'disconnected',
      label: 'Disconnected',
      isCorrect: true,
      preferredLabel: 'Disconnected',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Solid understanding.',
      feedbackReason: 'The ranks are far apart, so it is disconnected.',
    ),
    Act0RunnerOptionV1(
      id: 'connected',
      label: 'Connected',
      isCorrect: false,
      preferredLabel: 'Disconnected',
      betterAnswerLabel: 'Disconnected',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'The ace, eight and two leave a wide gap around the eight. Reading the ranks as closely connected exaggerates the straight danger.',
    ),
    Act0RunnerOptionV1(
      id: 'paired',
      label: 'Paired',
      isCorrect: false,
      preferredLabel: 'Disconnected',
      betterAnswerLabel: 'Disconnected',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Check for a repeated rank.',
      feedbackReason:
          'A-8-2 has three different ranks. The spacing leaves few straight paths, and thinking there is a pair distorts the hands you expect to face.',
    ),
  ],
  table: _act0BoardLessonTableV1(
    openingSeat: 'co',
    heroCards: _act0LessonCardsV1('Jh 9c'),
    boardCards: _act0LessonCardsV1('As 8d 2c'),
    centerLabel: 'Read the flop',
  ),
  teachingSteps: const [],
);

final _world5ConnectedBoardRunner = _world5WetBoardRunner.copyWith(
  caption: 'Compare the ranks on the flop.',
  lessonId: 'w5_connected_board',
  hint: "Close board ranks can connect with an opponent's private cards.",
  question: 'What is the key board clue?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'connected_ranks',
      label: 'Connected ranks',
      isCorrect: true,
      preferredLabel: 'Connected ranks',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Well done.',
      feedbackReason:
          '9-8-7 leaves room for straights. For example, a player holding J-T already has one.',
    ),
    Act0RunnerOptionV1(
      id: 'paired_board',
      label: 'Paired board',
      isCorrect: false,
      preferredLabel: 'Connected ranks',
      betterAnswerLabel: 'Connected ranks',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          '9-8-7 has three distinct ranks. Looking for a nonexistent pair can distract you from a made straight such as J-T.',
    ),
    Act0RunnerOptionV1(
      id: 'disconnected_ranks',
      label: 'Disconnected ranks',
      isCorrect: false,
      preferredLabel: 'Connected ranks',
      betterAnswerLabel: 'Connected ranks',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Read all three ranks together.',
      feedbackReason:
          'The 9, 8 and 7 are consecutive. Missing that connection can make you overlook a made straight such as J-T.',
    ),
  ],
  table: _act0BoardLessonTableV1(
    openingSeat: 'co',
    heroCards: _act0LessonCardsV1('Qh Tc'),
    boardCards: _act0LessonCardsV1('9s 8h 7c'),
    centerLabel: 'Read the flop',
  ),
  teachingSteps: const [],
);

final _world5ConnectedRecapRunner = _world5ConnectedIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w5_connected_recap',
  caption: 'Lesson learned: connected boards create straight pressure.',
  hint: 'Close ranks matter even before anyone bets.',
  question: 'What do connected ranks create?',
  feedbackTitle: 'Connected takeaway.',
  feedbackReason: 'Close ranks create more straight paths and more change.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Check your own five cards too.',
      body:
          'The board on this recap is Q-9-8. Your J-T fits between the queen and the nine, so you have five in a row. Board connection is a warning for the whole table. Your two private cards determine whether you hold the straight or still need help.',
      focusLabels: <String>['Board ranks', 'Your five-card hand'],
    ),
    Act0TeachingStepV1(
      title: 'Connected checklist.',
      body: 'If ranks sit close together, slow down and watch straight paths.',
      focusLabels: <String>['Close ranks', 'Straight path'],
    ),
  ],
  table: _act0BoardLessonTableV1(
    openingSeat: 'co',
    heroCards: _act0LessonCardsV1('Js Td'),
    boardCards: _act0LessonCardsV1('Qc 9s 8h'),
    centerLabel: 'Read the ranks',
  ),
);

final _world5FlushIntroRunner = _world5TextureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w5_flush_intro',
  lessonTitle: 'Flush draws',
  caption: 'A flush draw appears when one more suit card can help.',
  hint: 'Count suits on the board and in hand.',
  question: 'What does a flush draw need?',
  options: const <Act0RunnerOptionV1>[],
  table: _act0BoardLessonTableV1(
    openingSeat: 'hj',
    heroCards: _act0LessonCardsV1('Kh Jh'),
    boardCards: _act0LessonCardsV1('Qh 8h 3s'),
    centerLabel: 'Count matching suits',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Four cards of the same suit.',
      body:
          'A flush draw has four cards of one suit between your hand and the board. '
          'There are 13 cards in a suit. If four are visible and the others are unknown, nine cards can complete your flush.'
          ' “The nuts” means the best possible hand on the current board.',
      focusLabels: <String>['Suit', 'Heart', 'Flush draw'],
    ),
    Act0TeachingStepV1(
      title: 'Allow for both remaining cards.',
      body:
          'Rainbow means the three flop cards have different suits. A backdoor draw needs both the turn and the river to help.',
    ),
  ],
  feedbackTitle: 'Count matching suits.',
  feedbackReason: 'Four cards of one suit leave you one card short of a flush.',
);

final _world5FlushDrawRunner = _world5FlushIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w5_flush_draw',
  caption: 'You have hearts and the board has hearts.',
  hint: 'One more heart can improve your hand to a flush.',
  question: 'What draw is visible?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'flush_draw',
      label: 'Flush draw',
      isCorrect: true,
      preferredLabel: 'Flush draw',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Excellent spot.',
      feedbackReason:
          'This is a flush draw, not a flush yet. Four hearts are visible, so one more heart can complete the hand.',
    ),
    Act0RunnerOptionV1(
      id: 'made_flush',
      label: 'Made flush',
      isCorrect: false,
      preferredLabel: 'Flush draw',
      betterAnswerLabel: 'Flush draw',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'Not complete yet. With four hearts showing, flush pressure is live, but a made flush needs five cards of the same suit.',
    ),
    Act0RunnerOptionV1(
      id: 'straight_draw',
      label: 'Straight draw',
      isCorrect: false,
      preferredLabel: 'Flush draw',
      betterAnswerLabel: 'Flush draw',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Suit clue first.',
      feedbackReason:
          'The visible clue is the four-heart story. Start with same-suit pressure before inventing a rank-ladder draw.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Four hearts is pressure, not a made hand.',
      body:
          'Do not stop at matching suits. Four hearts means the draw is live, and one more heart changes the hand. Until then, it is still only a draw.',
      focusLabels: <String>['Four hearts', 'Not made yet', 'One more heart'],
    ),
  ],
  table: _act0BoardLessonTableV1(
    openingSeat: 'co',
    heroCards: _act0LessonCardsV1('Ah 7h'),
    boardCards: _act0LessonCardsV1('Th 4h 2c'),
    centerLabel: 'Read the suits',
  ),
);

final _world5NoFlushDrawRunner = _world5TextureIntroRunner.copyWith(
  caption: 'Scan your cards and the flop.',
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w5_no_flush_draw',
  lessonTitle: 'Flush draws',
  hint: 'Rainbow means three different suits on the flop.',
  question:
      'Do you have a backdoor draw to a club flush? How many clubs do you need?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'no',
      label: '3 · not enough cards remain',
      isCorrect: true,
      preferredLabel: '3 · not enough cards remain',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Spot on.',
      feedbackReason:
          'You need three more clubs, and only the turn and river remain. You cannot finish a flush with this hand.',
    ),
    Act0RunnerOptionV1(
      id: 'yes',
      label: '1 · flush draw',
      isCorrect: false,
      preferredLabel: '3 · not enough cards remain',
      betterAnswerLabel: '3 · not enough cards remain',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'J of clubs and 4 of clubs bring you to two clubs. A single club would only make three, so treating it as a flush draw can make you pay for a hand that cannot get there.',
    ),
    Act0RunnerOptionV1(
      id: 'backdoor',
      label: '2 · backdoor flush',
      isCorrect: false,
      preferredLabel: '3 · not enough cards remain',
      betterAnswerLabel: '3 · not enough cards remain',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Count the clubs you can see.',
      feedbackReason:
          'Your J of clubs and the 4 of clubs make two clubs so far. Two more bring the total to four and cannot make a flush.',
    ),
  ],
  table: _act0BoardLessonTableV1(
    openingSeat: 'co',
    heroCards: _act0LessonCardsV1('Kd Jc'),
    boardCards: _act0LessonCardsV1('As 9h 4c'),
    centerLabel: 'Read the flop',
  ),
  teachingSteps: const [],
);

final _world5FlushRecapRunner = _world5FlushIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w5_flush_recap',
  caption: 'Lesson learned: suits can create flush pressure.',
  hint: 'Count matching suits before calling a board safe.',
  question: 'What do you count for flush draws?',
  feedbackTitle: 'Flush takeaway.',
  feedbackReason:
      'Count suits in your hand and on the board before calling it safe.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Flush checklist.',
      body: 'Same-suit cards show whether one more suit can change the hand.',
      focusLabels: <String>['Suits', 'One more card'],
    ),
  ],
  table: _act0BoardLessonTableV1(
    openingSeat: 'co',
    heroCards: _act0LessonCardsV1('Kc 9c'),
    boardCards: _act0LessonCardsV1('Ac 6c 3d'),
    centerLabel: 'Read the suits',
  ),
);

final _world5MadeHandVsFlushDrawTransferRunner = _world5FlushDrawRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w5_made_hand_vs_flush_draw_transfer',
  caption:
      'Real table. You hold A-spade and J-club on A-heart, 8-heart, 4-club.',
  hint: 'Name your made hand, then read what the board could give an opponent.',
  question: 'What is the clean read first?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'made_hand_with_draw_pressure',
      label: 'You have top pair. An opponent could be drawing to a flush',
      isCorrect: true,
      preferredLabel:
          'You have top pair. An opponent could be drawing to a flush',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Correct live read.',
      feedbackReason:
          'You have top pair and no hearts. An opponent with two hearts can make a flush if another heart comes.',
    ),
    Act0RunnerOptionV1(
      id: 'made_flush_now',
      label: 'You already have a flush',
      isCorrect: false,
      preferredLabel:
          'You have top pair. An opponent could be drawing to a flush',
      betterAnswerLabel:
          'You have top pair. An opponent could be drawing to a flush',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not made yet.',
      feedbackReason:
          'You have no hearts. With two hearts on the board, even an opponent holding two hearts would still need one more.',
    ),
    Act0RunnerOptionV1(
      id: 'draw_means_pair_does_not_count',
      label: 'A possible flush draw cancels your pair',
      isCorrect: false,
      preferredLabel:
          'You have top pair. An opponent could be drawing to a flush',
      betterAnswerLabel:
          'You have top pair. An opponent could be drawing to a flush',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Current hand first.',
      feedbackReason:
          'Your pair of aces already counts. Another heart could help an opponent later.',
    ),
  ],
  table: _act0BoardLessonTableV1(
    openingSeat: 'co',
    heroCards: _act0LessonCardsV1('As Jc'),
    boardCards: _act0LessonCardsV1('Ah 8h 4c'),
    centerLabel: 'Made hand or draw?',
    openBb: 3.75,
    highlightedCardIds: const ['hero_0', 'board_0', 'board_1'],
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Made hand first, draw pressure second.',
      body:
          'You have top pair and no hearts. An opponent holding two hearts can complete a flush with one more heart on the board.',
      focusLabels: <String>['Top pair', 'Two hearts', 'Not made yet'],
    ),
  ],
);

final _world5FlushDrawRecheckTransferRunner = _world5FlushDrawRunner.copyWith(
  caption: 'Your hand and the flop are shown. The next card is still unknown.',
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w5_flush_draw_recheck_transfer',
  hint:
      'Use the visible hearts on the table first. One more heart can change the hand, but it has not arrived yet.',
  question: 'What is true right now?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'flush_draw_only',
      label: 'You have a flush draw, not a made flush yet',
      isCorrect: true,
      preferredLabel: 'You have a flush draw, not a made flush yet',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Correct recovery.',
      feedbackReason:
          'There are four hearts visible, so you are one heart short of a flush. That keeps the hand in draw territory until one more heart appears.',
    ),
    Act0RunnerOptionV1(
      id: 'made_flush_now',
      label: 'You already have a made flush',
      isCorrect: false,
      preferredLabel: 'You have a flush draw, not a made flush yet',
      betterAnswerLabel: 'You have a flush draw, not a made flush yet',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Still one card short.',
      feedbackReason:
          'Four hearts create strong pressure, but four hearts are still not a made flush yet. You need one more heart before calling it complete.',
    ),
    Act0RunnerOptionV1(
      id: 'no_flush_pressure',
      label: 'There is no flush pressure yet',
      isCorrect: false,
      preferredLabel: 'You have a flush draw, not a made flush yet',
      betterAnswerLabel: 'You have a flush draw, not a made flush yet',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Count the hearts.',
      feedbackReason:
          'The visible table already shows four hearts between your hand and the board. That creates real flush pressure even though the flush is not made yet.',
    ),
  ],
  table: _act0BoardLessonTableV1(
    heroCards: _act0LessonCardsV1('Qh 7h'),
    boardCards: _act0LessonCardsV1('Ah 8c 2h'),
    centerLabel: 'Read the draw',
    openBb: 3.25,
  ),
  teachingSteps: const [],
);

final _world5StraightIntroRunner = _world5ConnectedIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w5_straight_intro',
  lessonTitle: 'Straight draws',
  caption: 'A straight draw uses nearby ranks to chase a five-card line.',
  hint: 'Look for rank ladders.',
  question: 'What does a straight draw use?',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Count the ranks that finish a straight.',
      body:
          'An open-ended draw can finish at either end of four ranks in a row. Here, 8-9-T-J can be finished by any 7 or queen: 8 outs. '
          'A gutshot has one gap, like 5-6-8-9. Only a 7 fills it: 4 outs.',
      focusLabels: <String>['Ranks', 'Ladder', 'Straight draw'],
    ),
  ],
  table: _act0BoardLessonTableV1(
    openingSeat: 'co',
    heroCards: _act0LessonCardsV1('Ts 9d'),
    boardCards: _act0LessonCardsV1('Jh 8c 3s'),
    centerLabel: 'Read the ranks',
  ),
  feedbackTitle: 'Follow the ranks.',
  feedbackReason:
      'Check which next rank could give you five consecutive cards.',
);

final _world5StraightDrawRunner = _world5StraightIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  teachingSteps: const [],
  lessonId: 'w5_straight_draw',
  caption: 'You have 6-5 and the board shows 8-7-2.',
  hint: 'A 4 or 9 can improve the rank ladder.',
  question: 'How many different ranks finish your straight on the next card?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'straight_draw',
      label: '2 · open-ended straight draw',
      isCorrect: true,
      preferredLabel: '2 · open-ended straight draw',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Clean execution.',
      feedbackReason:
          'Your 5-6 and the board’s 7-8 form a four-card run. A 4 finishes it at the low end and a 9 at the high end.',
    ),
    Act0RunnerOptionV1(
      id: 'flush_draw',
      label: '0 · flush draw instead',
      isCorrect: false,
      preferredLabel: '2 · open-ended straight draw',
      betterAnswerLabel: '2 · open-ended straight draw',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'There are no four matching suits between your cards and the board. The 5-6-7-8 run can improve immediately on a 4 or a 9. Ignoring those ranks misses part of your chance to win.',
    ),
    Act0RunnerOptionV1(
      id: 'one_rank',
      label: '1 · inside straight draw',
      isCorrect: false,
      preferredLabel: '2 · open-ended straight draw',
      betterAnswerLabel: '2 · open-ended straight draw',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Check both ends of the run.',
      feedbackReason:
          'With 6-5 on 8-7-2, either a 4 or a 9 completes a straight. Counting just one end discounts half the completion cards.',
    ),
  ],
  table: _act0BoardLessonTableV1(
    heroCards: _act0LessonCardsV1('6s 5d'),
    boardCards: _act0LessonCardsV1('8c 7h 2s'),
    centerLabel: 'Read the ranks',
  ),
);

final _world5GutshotDrawRunner = _world5StraightIntroRunner.copyWith(
  caption: 'Check which ranks could finish your hand.',
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w5_gutshot_draw',
  hint: 'Only a 6 completes the missing middle rank.',
  question: 'What draw is visible?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'gutshot',
      label: 'Gutshot straight draw',
      isCorrect: true,
      preferredLabel: 'Gutshot straight draw',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Exact read.',
      feedbackReason:
          'This is a gutshot. 5-7-8-9 are close, but only the 6 fills the missing middle rank.',
    ),
    Act0RunnerOptionV1(
      id: 'open_ended',
      label: 'Open-ended straight draw',
      isCorrect: false,
      preferredLabel: 'Gutshot straight draw',
      betterAnswerLabel: 'Gutshot straight draw',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Only a six completes it.',
      feedbackReason:
          'Open-ended draws improve from either end. Here only the 6 works, so the draw is narrower than open-ended.',
    ),
    Act0RunnerOptionV1(
      id: 'made_straight',
      label: 'Made straight',
      isCorrect: false,
      preferredLabel: 'Gutshot straight draw',
      betterAnswerLabel: 'Gutshot straight draw',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not complete yet.',
      feedbackReason:
          'The straight is not complete yet. The board and hand still miss the 6, so this stays a draw, not a made hand.',
    ),
  ],
  table: _act0BoardLessonTableV1(
    heroCards: _act0LessonCardsV1('9s 8d'),
    boardCards: _act0LessonCardsV1('Kc 7h 5s'),
    centerLabel: 'Read the draw',
  ),
  teachingSteps: const [],
);

final _world5GutshotContrastTransferRunner = _world5GutshotDrawRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w5_gutshot_contrast_transfer',
  caption: 'Read your cards together with the flop.',
  hint: 'Check both ends of the four ranks.',
  question: 'Which straight draw do you have?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'gutshot',
      label: 'Gutshot straight draw',
      isCorrect: false,
      preferredLabel: 'Open-ended straight draw',
      betterAnswerLabel: 'Open-ended straight draw',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Two ranks complete it.',
      feedbackReason:
          'A gutshot has one missing middle rank. Your 6-7-8-9 already run in order. A 5 or a ten completes the straight.',
    ),
    Act0RunnerOptionV1(
      id: 'open_ended',
      label: 'Open-ended straight draw',
      isCorrect: true,
      preferredLabel: 'Open-ended straight draw',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Either end can finish it.',
      feedbackReason:
          'Your 6-7-8-9 run in order. Four fives and four tens can finish the straight, so there are eight outs to make it.',
    ),
    Act0RunnerOptionV1(
      id: 'made_straight',
      label: 'Made straight',
      isCorrect: false,
      preferredLabel: 'Open-ended straight draw',
      betterAnswerLabel: 'Open-ended straight draw',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'You still need a fifth rank.',
      feedbackReason: 'Your four ranks need a 5 or a ten to make a straight.',
    ),
  ],
  table: _act0BoardLessonTableV1(
    heroCards: _act0LessonCardsV1('9d 8s'),
    boardCards: _act0LessonCardsV1('Qh 7c 6d'),
    centerLabel: 'Read the draw',
    openBb: 2.75,
  ),
  teachingSteps: const [],
);

final _world5GapBoardRunner = _world5StraightIntroRunner.copyWith(
  caption: 'Look at the ranks on the flop.',
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w5_gap_board',
  hint: 'Big gaps mean no obvious straight draw.',
  question: 'Is straight pressure obvious?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'no',
      label: 'No',
      isCorrect: true,
      preferredLabel: 'No',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Gap board identified.',
      feedbackReason:
          'The ranks are too far apart for an obvious straight path.',
    ),
    Act0RunnerOptionV1(
      id: 'yes',
      label: 'Yes',
      isCorrect: false,
      preferredLabel: 'No',
      betterAnswerLabel: 'No',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason: 'Straight pressure needs closer ranks.',
    ),
    Act0RunnerOptionV1(
      id: 'ace_to_six',
      label: 'Yes, because ace connects directly to six',
      isCorrect: false,
      preferredLabel: 'No',
      betterAnswerLabel: 'No',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Place the ace at an end.',
      feedbackReason:
          'An ace can be high or low, but A-6-2 still leaves wide gaps. Treating ace and six as neighbors overstates how easily a straight can arrive.',
    ),
  ],
  table: _act0BoardLessonTableV1(
    heroCards: _act0LessonCardsV1('Jc 8h'),
    boardCards: _act0LessonCardsV1('Ad 6s 2c'),
    centerLabel: 'Read the flop',
  ),
  teachingSteps: const [],
);

final _world5StraightRecapRunner = _world5StraightIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w5_straight_recap',
  caption: 'Lesson learned: straight draws are rank stories.',
  hint: 'Suits do not make straights. Nearby ranks do.',
  question: 'What do you inspect for straight draws?',
  feedbackTitle: 'Straight takeaway.',
  feedbackReason: 'Look for nearby ranks that can form a five-card line.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Straight checklist.',
      body: 'Find nearby ranks, then ask which next cards complete the line.',
      focusLabels: <String>['Nearby ranks', 'Outs'],
    ),
  ],
  table: _act0BoardLessonTableV1(
    heroCards: _act0LessonCardsV1('8s 6d'),
    boardCards: _act0LessonCardsV1('9c 5h 2s'),
    centerLabel: 'Read the ranks',
  ),
);

final _world5OutsIntroRunner = _world5TextureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w5_outs_intro',
  lessonTitle: 'Outs as improvement cards',
  caption: 'Outs are cards that can improve your hand.',
  hint:
      'Count the cards that complete the draw. Then compare the chance with the price.',
  question: 'What is an out?',
  options: const <Act0RunnerOptionV1>[],
  table: _act0BoardLessonTableV1(
    openingSeat: 'co',
    heroCards: _act0LessonCardsV1('Js Tc'),
    boardCards: _act0LessonCardsV1('Qd 9h 3c'),
    centerLabel: 'Read the draw',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Count the cards that help.',
      body:
          'Outs are the unseen cards that can improve your hand. With one card left and 46 unseen, '
          '9 outs hit about 1 time in 5, 8 about 1 in 6, and 4 about 1 in 12.',
      focusLabels: <String>['Outs', 'One card left'],
    ),
    Act0TeachingStepV1(
      title: 'Compare with the price from World 4.',
      body:
          'A 1 BB call into a 7 BB pot needs 1 win in 8. '
          'If only those 8 outs win and there are no more bets, about 1 win in 6 beats that price.',
      focusLabels: <String>['Call 1 BB', 'Pot 7 BB', 'Chance to win'],
    ),
  ],
  feedbackTitle: 'Name the improving cards.',
  feedbackReason:
      'Identify the cards that complete your draw before deciding what price is worth paying.',
);

final _world5FlushOutRunner = _world5FlushDrawRunner.copyWith(
  caption: 'Compare the cards by suit.',
  lessonId: 'w5_flush_out',
  lessonTitle: 'Outs as improvement cards',
  hint: 'Any heart is the improvement card type.',
  feedbackReason:
      'Four hearts are visible. One more heart completes the flush.',
  question: 'Which card type is the out?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'heart',
      label: 'Heart',
      isCorrect: true,
      preferredLabel: 'Heart',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Sharp read.',
      feedbackReason: 'A heart can complete the flush.',
    ),
    Act0RunnerOptionV1(
      id: 'club',
      label: 'Club',
      isCorrect: false,
      preferredLabel: 'Heart',
      betterAnswerLabel: 'Heart',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason: 'The flush path is hearts, so hearts are the outs.',
    ),
    Act0RunnerOptionV1(
      id: 'spade',
      label: 'Spade',
      isCorrect: false,
      preferredLabel: 'Heart',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Check the clue again.',
      feedbackReason:
          'A spade adds a spade to the turn without adding a heart. The flush needs one more heart.',
    ),
  ],
  table: _act0BoardLessonTableV1(
    openingSeat: 'co',
    heroCards: _act0LessonCardsV1('Kh 8h'),
    boardCards: _act0LessonCardsV1('Jh 3h 7s'),
    centerLabel: 'Read the draw',
  ),
  teachingSteps: const [],
);

final _world5StraightOutRunner = _world5StraightDrawRunner.copyWith(
  caption: 'Compare your ranks with the flop.',
  lessonId: 'w5_straight_out',
  lessonTitle: 'Outs as improvement cards',
  hint: 'Those cards complete the straight line.',
  feedbackReason: 'The 5-6-7-8 sequence can finish with a 4 or a 9.',
  question: 'Which out improves your hand?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'nine',
      label: '9',
      isCorrect: true,
      preferredLabel: '9',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Strong choice.',
      feedbackReason:
          'Private 5-6, shared board cards 7-8: any 9 completes the straight.',
    ),
    Act0RunnerOptionV1(
      id: 'king',
      label: 'K',
      isCorrect: false,
      preferredLabel: '9',
      betterAnswerLabel: '9',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason: 'A king does not connect this rank ladder.',
    ),
    Act0RunnerOptionV1(
      id: 'ten',
      label: 'T',
      isCorrect: false,
      preferredLabel: '9',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Check the clue again.',
      feedbackReason:
          'A ten skips the nine. You need five consecutive ranks for a straight.',
    ),
  ],
  table: _act0BoardLessonTableV1(
    heroCards: _act0LessonCardsV1('6h 5c'),
    boardCards: _act0LessonCardsV1('8s 7d 2h'),
    centerLabel: 'Read the draw',
    highlightedCardIds: const [
      'hero_0',
      'hero_1',
      'board_0',
      'board_1',
      'board_2',
    ],
  ),
  teachingSteps: const [],
);

final _world5OutsRecapRunner = _world5OutsIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w5_outs_recap',
  caption: 'Lesson learned: outs are improvement cards.',
  hint: 'Name what can help before paying a price.',
  question: 'What is an out?',
  feedbackTitle: 'Outs takeaway.',
  feedbackReason:
      'An out is a card that can improve the hand on a later street.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Outs checklist.',
      body: 'Ask what future card improves you, then decide if the price fits.',
      focusLabels: <String>['Improve', 'Future card', 'Price'],
    ),
  ],
  table: _act0BoardLessonTableV1(
    heroCards: _act0LessonCardsV1('9s 8h'),
    boardCards: _act0LessonCardsV1('Td 7c 4h'),
    centerLabel: 'Read the draw',
  ),
);

final _world5TableOutsFlushTransferRunner = _world5FlushOutRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w5_table_outs_flush_transfer',
  caption:
      'Assume every flush wins and all other rivers lose. No more betting.',
  hint:
      'Count the hearts you cannot see, then compare your chance with 2 out of 12.',
  question: 'Call 2 BB into the 10 BB pot, or fold?',
  feedbackTitle: 'Compare the hit rate and the price.',
  feedbackReason:
      'Count only winning cards and compare that chance with the call divided by the final pot.',
  teachingSteps: const [],
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'heart_outs',
      label: 'Call 2 BB',
      isCorrect: true,
      preferredLabel: 'Call 2 BB',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Nine outs are enough at this price.',
      feedbackReason:
          "BB bets 2 BB, so calling needs two wins per 12. Under the stated rule your flush wins on nine of 46 rivers, so folding gives up the gain.",
    ),
    Act0RunnerOptionV1(
      id: 'price_only',
      label: 'Fold',
      isCorrect: false,
      preferredLabel: 'Call 2 BB',
      betterAnswerLabel: 'Call 2 BB',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Compare the chance with the price.',
      feedbackReason:
          "Folding misses a call that needs only 2 in 12 when 9 of 46 rivers win. In a real hand, an opponent holding two tens would make a full house on the 2 of hearts.",
    ),
    Act0RunnerOptionV1(
      id: 'call_draw_alone',
      label: 'Call because nine outs is a big draw',
      isCorrect: false,
      preferredLabel: 'Call 2 BB',
      betterAnswerLabel: 'Call 2 BB',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'The action fits. Compare it with the cost.',
      feedbackReason:
          "Calling just because you have nine outs can cost chips when the price is high. Here 9 out of 46 beat the 2-in-12 price.",
    ),
  ],
  table: _act0BoardLessonTableV1(
    heroCards: _act0LessonCardsV1('Ah 7h'),
    boardCards: _act0LessonCardsV1('Th 4h 2c 9s'),
    centerLabel: 'Draw and price',
    openBb: 3.75,
    facingBb: 2,
  ),
);

final _world5CleanVsRiskyOutTransferRunner = _world5TableOutsStraightTransferRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w5_clean_vs_risky_out_transfer',
  caption:
      'Real table. Turn board shows A-heart, 7-heart, 6-club, 2-diamond. You have 9-spade and 8-diamond.',
  hint:
      'Both a 5-club and a 5-heart complete your straight. Ask which one helps more cleanly and which one adds extra board danger.',
  question: 'Which river is the safer out for your hand?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'five_clubs_cleaner',
      label: '5-club is safer',
      isCorrect: true,
      preferredLabel: '5-club is safer',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Correct intro read.',
      feedbackReason:
          'Both cards complete the straight, but 5-club is safer because it helps you without adding a third heart. The straight is real either way, but this river keeps the board calmer.',
    ),
    Act0RunnerOptionV1(
      id: 'five_hearts_riskier',
      label: '5-heart is just as clean',
      isCorrect: false,
      preferredLabel: '5-club is safer',
      betterAnswerLabel: '5-club is safer',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'It still helps, but it is riskier.',
      feedbackReason:
          '5-heart still completes your straight, so it is not useless. But it is riskier because it also adds a third heart to the board, which makes the river more dangerous than 5-club.',
    ),
    Act0RunnerOptionV1(
      id: 'neither_helps',
      label: 'Neither card helps yet',
      isCorrect: false,
      preferredLabel: '5-club is safer',
      betterAnswerLabel: '5-club is safer',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'The straight really does complete.',
      feedbackReason:
          'You already have 9-8 with 7-6 on the board, so any 5 completes the straight. The beginner question is not whether you improve, but which completing card is safer.',
    ),
  ],
  table: _act0BoardLessonTableV1(
    heroCards: _act0LessonCardsV1('9s 8d'),
    boardCards: _act0LessonCardsV1('Ah 7h 6c 2d'),
    centerLabel: 'Compare two river cards',
    openBb: 3,
    flopBetBb: 2,
    highlightedCardIds: const ['hero_0', 'hero_1', 'board_1', 'board_2'],
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Not every helping card is equally clean.',
      body:
          'A card can improve your hand and still make the board more dangerous. Start with simple language: safer out when the board stays calmer, riskier out when the board adds new danger.',
      focusLabels: <String>['Safer card', 'Riskier card', 'Third heart'],
    ),
  ],
);

final _world5TableOutsStraightTransferRunner = _world5StraightOutRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w5_table_outs_straight_transfer',
  caption:
      'Assume every straight wins and all other rivers lose. No more betting.',
  hint: 'Count the ranks that finish your straight and the cards of each rank.',
  question: 'Call 3 BB into the 9 BB pot, or fold?',
  feedbackTitle: 'Compare the hit rate and the price.',
  feedbackReason:
      'Count only winning cards and compare that chance with the call divided by the final pot.',
  teachingSteps: const [],
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'four_or_nine',
      label: 'Fold',
      isCorrect: true,
      preferredLabel: 'Fold',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Eight outs are too few at this price.',
      feedbackReason:
          "BB bets 3 BB, so calling needs three wins per 12. Under the stated rule a four or nine wins eight of 46 rivers, so fold.",
    ),
    Act0RunnerOptionV1(
      id: 'blank_turn_killed',
      label: 'Call 3 BB',
      isCorrect: false,
      preferredLabel: 'Fold',
      betterAnswerLabel: 'Fold',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'A live draw can still cost too much.',
      feedbackReason:
          "A call needs 25% because it costs 3 BB for a final 12 BB pot. Eight of 46 is about 17%, so fold. In a real hand, a 9 can give an opponent holding J-T a higher straight.",
    ),
    Act0RunnerOptionV1(
      id: 'fold_wrong_out_count',
      label: 'Fold because four nines give too small a chance to win',
      isCorrect: false,
      preferredLabel: 'Fold',
      betterAnswerLabel: 'Fold',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'The action fits. Count both ends.',
      feedbackReason:
          'With 6-5 on 8-7-2-K, a 4 also makes a straight. Four cards of each rank still fall short of the 3-in-12 price. Miscounting can lose a profitable call at a lower price.',
    ),
  ],
  table: _act0BoardLessonTableV1(
    heroCards: _act0LessonCardsV1('6s 5d'),
    boardCards: _act0LessonCardsV1('8c 7h 2s Kd'),
    centerLabel: 'Draw and price',
    openBb: 2.75,
    facingBb: 3,
  ),
);

final _world5StreetChangeIntroRunner = _world5TextureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w5_street_change_intro',
  lessonTitle: 'Turn and river changes',
  caption: 'Turn and river can complete draws or miss them.',
  hint: 'Read the same draw story again after each new street card.',
  question: 'What changes after the flop?',
  options: const <Act0RunnerOptionV1>[],
  table: _act0BoardLessonTableV1(
    openingSeat: 'hj',
    heroCards: _act0LessonCardsV1('Ks 9s'),
    boardCards: _act0LessonCardsV1('As 7s 4c 2s'),
    centerLabel: 'Read the turn',
    highlightedCardIds: const ['board_3'],
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'One card can matter.',
      body:
          'The turn and river each add one shared card. A blank is a card that changes little for the hand or draw you are tracking. '
          'Check whether the new card completes the draw, adds more outs, or leaves it unchanged.',
      focusLabels: <String>['Turn', 'River', 'Draw story'],
    ),
  ],
  feedbackTitle: 'Read the new card.',
  feedbackReason:
      'Compare the new card to the previous board to see which draws finished or stayed open.',
);

final _world5TurnHitsRunner = _world5StreetChangeIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w5_turn_hits',
  lessonTitle: 'Turn and river changes',
  caption: 'Compare the first three flop cards with the turn card.',
  teachingSteps: const <Act0TeachingStepV1>[],
  hint: 'Count matching suits before and after the turn.',
  question: 'What happened on the turn?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'draw_hit',
      label: 'Draw hit',
      isCorrect: true,
      preferredLabel: 'Draw hit',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Solid understanding.',
      feedbackReason:
          'The turn jack brings the fifth club between your hand and the flop and turn. You now have a flush.',
    ),
    Act0RunnerOptionV1(
      id: 'blank',
      label: 'Blank',
      isCorrect: false,
      preferredLabel: 'Draw hit',
      betterAnswerLabel: 'Draw hit',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'The turn adds a club to the four clubs you could see on the flop. That changes the hand.',
    ),
    Act0RunnerOptionV1(
      id: 'one_club_short',
      label: 'Still one club short',
      isCorrect: false,
      preferredLabel: 'Draw hit',
      betterAnswerLabel: 'Draw hit',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Count the clubs in both places.',
      feedbackReason:
          'Your Q and 9 of clubs plus K, 6 and J of clubs on the flop and turn make five. Missing a club in your hand can cost value from a made flush.',
    ),
  ],
  table: _act0BoardLessonTableV1(
    openingSeat: 'co',
    heroCards: _act0LessonCardsV1('Qc 9c'),
    boardCards: _act0LessonCardsV1('Kc 6c 2h Jc'),
    centerLabel: 'Read the turn',
    highlightedCardIds: const ['board_3'],
  ),
);

final _world5RiverMissesRunner = _world5StreetChangeIntroRunner.copyWith(
  caption: 'Compare the river with the draw you started with.',
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w5_river_misses',
  hint: 'Count matching suits on the final board.',
  question: 'What happened by the river?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'draw_missed',
      label: 'Draw missed',
      isCorrect: true,
      preferredLabel: 'Draw missed',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Well done.',
      feedbackReason:
          'You still see only four spades. The river queen is a diamond, so the flush draw missed.',
    ),
    Act0RunnerOptionV1(
      id: 'draw_hit',
      label: 'Draw hit',
      isCorrect: false,
      preferredLabel: 'Draw missed',
      betterAnswerLabel: 'Draw missed',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'No spade arrived on the turn or river. The flop draw never completed.',
    ),
    Act0RunnerOptionV1(
      id: 'made_straight',
      label: 'Missed the flush but made a straight',
      isCorrect: false,
      preferredLabel: 'Draw missed',
      betterAnswerLabel: 'Draw missed',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Check for five consecutive ranks.',
      feedbackReason:
          'On T-7-3-6-Q, A-8 has neither five spades nor five consecutive ranks. Mistaking the gaps for a straight can make you pay with ace-high.',
    ),
  ],
  table: _act0BoardLessonTableV1(
    heroCards: _act0LessonCardsV1('As 8s'),
    boardCards: _act0LessonCardsV1('Ts 7s 3d 6c Qd'),
    centerLabel: 'Read the river',
    highlightedCardIds: const ['board_4'],
  ),
  teachingSteps: const [],
);

final _world5StreetRepairRunner = _world5StreetChangeIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w5_street_repair',
  hint: 'Repair the street-change read before repeating the flop plan.',
  question: 'What needs fixing first?',
  feedbackTitle: 'Repair the street read.',
  feedbackReason:
      'When a turn card changes the draw story, thin one-pair plans need more caution. Repair the board read before copying the flop line.',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'repair_story',
      label:
          'The board got more dangerous, so the old easy-value story needs caution',
      isCorrect: true,
      preferredLabel:
          'The board got more dangerous, so the old easy-value story needs caution',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Nice repair.',
      feedbackReason:
          'You still have top pair. The eight connects the six and seven and adds a second club. Check which weaker hands still call on the new board.',
    ),
    Act0RunnerOptionV1(
      id: 'same_story',
      label: 'Nothing changed, so keep the same flop plan',
      isCorrect: false,
      preferredLabel:
          'The board got more dangerous, so the old easy-value story needs caution',
      betterAnswerLabel:
          'The board got more dangerous, so the old easy-value story needs caution',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'The turn links 6-7-8 and brings a second club. Read the new draws before repeating a flop bet.',
    ),
    Act0RunnerOptionV1(
      id: 'small_same_story',
      label: 'Bet smaller but keep the same old story',
      isCorrect: false,
      preferredLabel:
          'The board got more dangerous, so the old easy-value story needs caution',
      betterAnswerLabel:
          'The board got more dangerous, so the old easy-value story needs caution',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Read the new board first.',
      feedbackReason:
          'Changing the size without repairing the board story still leaves the core read behind.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Repair story before line.',
      body:
          'Turn and river are not cosmetic. If the board got more connected or completed a draw, re-read the whole story before acting.',
      focusLabels: <String>['Turn change', 'Repair read', 'One-pair caution'],
    ),
  ],
  table: _act0BoardLessonTableV1(
    heroCards: _act0LessonCardsV1('Ad Qs'),
    boardCards: _act0LessonCardsV1('Ah 7c 6d 8c'),
    centerLabel: 'Read the turn',
    flopBetBb: 2,
    highlightedCardIds: const ['board_3'],
  ),
  caption:
      'The 8 of clubs arrives on A-7-6. You still treat top pair like the flop stayed easy.',
);

final _world5TurnTextureShiftTransferRunner = _world5StreetChangeIntroRunner.copyWith(
  caption: 'Compare the board before and after the turn.',
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w5_turn_texture_shift_transfer',
  feedbackSignalId: 'board_texture_change',
  hint:
      'Do not replay the flop read. Ask what the new turn card changed first.',
  question: 'What new danger does the turn add?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'board_got_wetter',
      label: 'An opponent can now have a flush',
      isCorrect: true,
      preferredLabel: 'An opponent can now have a flush',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Clean street read.',
      feedbackReason:
          'The flop had two hearts. The turn adds a third, so a player holding two hearts can now have a flush. Your pair of nines stays a pair.',
    ),
    Act0RunnerOptionV1(
      id: 'nothing_changed',
      label: 'Nothing changed, so keep the same easy plan',
      isCorrect: false,
      preferredLabel: 'An opponent can now have a flush',
      betterAnswerLabel: 'An opponent can now have a flush',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'One more street read.',
      feedbackReason:
          'The turn adds a third heart. Two private hearts can now make a flush.',
    ),
    Act0RunnerOptionV1(
      id: 'size_only_changed',
      label: 'Focus on bet size before checking the third heart',
      isCorrect: false,
      preferredLabel: 'An opponent can now have a flush',
      betterAnswerLabel: 'An opponent can now have a flush',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Notice the third heart.',
      feedbackReason:
          'Before choosing a size, notice that the third heart lets an opponent make a flush.',
    ),
  ],
  table: _act0BoardLessonTableV1(
    heroCards: _act0LessonCardsV1('9s Qd'),
    boardCards: _act0LessonCardsV1('9d 5h 2h 8h'),
    centerLabel: 'Read the turn',
    openBb: 2.75,
    flopBetBb: 1,
    highlightedCardIds: const ['board_3'],
  ),
  teachingSteps: const [],
);

final _world5RiverDrawStoryTransferRunner = _world5StreetChangeIntroRunner.copyWith(
  caption: 'Compare the turn card with the river.',
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w5_river_draw_story_transfer',
  hint:
      'Keep the same draw story in mind and decide whether it finished or missed.',
  question: 'What did the river do to your turn draw?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'draw_missed_story',
      label: 'The river missed the straight draw',
      isCorrect: true,
      preferredLabel: 'The river missed the straight draw',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Exactly.',
      feedbackReason:
          'Your 4-5-6-7 needed a 3 or an 8. The river ace is neither, so the straight draw missed.',
    ),
    Act0RunnerOptionV1(
      id: 'river_restarts_story',
      label: 'The river starts a new story from zero',
      isCorrect: false,
      preferredLabel: 'The river missed the straight draw',
      betterAnswerLabel: 'The river missed the straight draw',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too disconnected.',
      feedbackReason:
          'Compare the ace with the two ranks you needed on the turn. You still have only four connected ranks.',
    ),
    Act0RunnerOptionV1(
      id: 'draw_hit_anyway',
      label: 'The draw probably got there anyway',
      isCorrect: false,
      preferredLabel: 'The river missed the straight draw',
      betterAnswerLabel: 'The river missed the straight draw',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'The ace misses the draw.',
      feedbackReason: 'The river ace does not extend 4-5-6-7 to a straight.',
    ),
  ],
  table: _act0BoardLessonTableV1(
    heroCards: _act0LessonCardsV1('6c 5d'),
    boardCards: _act0LessonCardsV1('Js 7h 2d 4c As'),
    centerLabel: 'Read the river',
    openBb: 2.75,
    flopBetBb: 2,
    highlightedCardIds: const ['board_4'],
  ),
  teachingSteps: const [],
);

final _world5BoardCheckpointRunner = _world5TextureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w5_board_checkpoint',
  lessonTitle: 'Turn and river changes',
  caption: 'Lesson learned: board reading starts before the action.',
  hint: 'Board first. Action second.',
  question: 'What is the World 5 read?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'texture_draw_outs',
      label: 'Texture, draw, outs',
      isCorrect: true,
      preferredLabel: 'Texture, draw, outs',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Excellent spot.',
      feedbackReason:
          'Board reading starts with texture, visible draws, and improvement cards. Next, you will sort hands into simple groups.',
    ),
    Act0RunnerOptionV1(
      id: 'just_outs',
      label: 'Just count outs',
      isCorrect: false,
      preferredLabel: 'Texture, draw, outs',
      betterAnswerLabel: 'Texture, draw, outs',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Playable start.',
      feedbackReason:
          'Counting outs is a real skill, but texture and draws round out the full board read.',
    ),
    Act0RunnerOptionV1(
      id: 'random_guess',
      label: 'Random guess',
      isCorrect: false,
      preferredLabel: 'Texture, draw, outs',
      betterAnswerLabel: 'Texture, draw, outs',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason: 'The board gives clues before you guess.',
    ),
  ],
  feedbackTitle: 'Board takeaway.',
  feedbackReason:
      'Texture, draws, outs, and later streets explain how the board changes.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'World 5 checkpoint.',
      body:
          'Pause the board, name texture, find draws, then re-read the same story when the next card lands.',
      focusLabels: <String>['Texture', 'Draws', 'Outs', 'Street change'],
    ),
  ],
  table: _act0BoardLessonTableV1(
    heroCards: _act0LessonCardsV1('Qh Js'),
    boardCards: _act0LessonCardsV1('Td 9c 3h'),
    centerLabel: 'Read the flop',
  ),
);

// Preserve the general review runner used by the W6 checkpoint family.
final _world5DrawPriceCheckpointRunner = _world5BoardCheckpointRunner.copyWith(
  caption:
      'Assume every straight wins and all other rivers lose. No more betting.',
  hint: 'Find the gap in your four ranks. Compare your chance to the price.',
  question: 'Call 1 BB into the 12 BB pot, or fold?',
  feedbackTitle: 'Even four outs can be worth calling.',
  feedbackReason:
      'Four sevens out of 46 hit about 1 time in 12. Calling 1 BB makes a 13 BB pot. Your chance is enough at this price.',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'texture_draw_outs',
      label: 'Call 1 BB',
      isCorrect: true,
      preferredLabel: 'Call 1 BB',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'The low price makes a call worthwhile.',
      feedbackReason:
          "BB bets 1 BB, so calling needs 1 win per 13. Four sevens out of 46 clear that price in this model. Folding gives up that gain.",
    ),
    Act0RunnerOptionV1(
      id: 'just_outs',
      label: 'Fold',
      isCorrect: false,
      preferredLabel: 'Call 1 BB',
      betterAnswerLabel: 'Call 1 BB',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Check the price before folding.',
      feedbackReason:
          "Folding misses a small gain: four winning rivers out of 46 beat the 1-in-13 call price.",
    ),
    Act0RunnerOptionV1(
      id: 'call_cheap_only',
      label: 'Call because the bet is small',
      isCorrect: false,
      preferredLabel: 'Call 1 BB',
      betterAnswerLabel: 'Call 1 BB',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'The action fits. Count the winners.',
      feedbackReason:
          'On 6-5-2-K, a 7 is the winning rank for 9-8 under this rule. Four wins in 46 are enough for the 1-in-13 price. Calling small bets without counting can still lose chips.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Put the chance and price together.',
      body:
          'First find which river cards would win. Then compare the chance of hitting with the call divided by the final pot.',
      focusLabels: <String>['Winning cards', 'Call price'],
    ),
  ],
  table: _act0BoardLessonTableV1(
    heroCards: _act0LessonCardsV1('9c 8d'),
    boardCards: _act0LessonCardsV1('6d 5h 2c Ks'),
    centerLabel: 'Draw and price',
    openBb: 2.75,
    flopBetBb: 2.5,
    facingBb: 1,
  ),
);

final _world6RangeCheckpointRunner = _world5BoardCheckpointRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w6_range_checkpoint',
  lessonTitle: 'Range thinking checkpoint',
  caption: 'Lesson learned: range buckets need board-fit context.',
  hint: 'Bucket first, board fit second, stack depth next.',
  question: 'What carries this read into World 8?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'range_plus_pot_size',
      label: 'Range plus pot size',
      isCorrect: false,
      preferredLabel: 'Range plus stack depth',
      betterAnswerLabel: 'Range plus stack depth',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Useful, not the bridge.',
      feedbackReason:
          'Pot size matters, but this bridge is about carrying range reads into stack-depth risk. Depth changes how much pressure those ranges can absorb.',
    ),
    Act0RunnerOptionV1(
      id: 'range_plus_stack_depth',
      label: 'Range plus stack depth',
      isCorrect: true,
      preferredLabel: 'Range plus stack depth',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Spot on.',
      feedbackReason:
          'Range buckets map likely hands, and stack depth sets the risk profile for those hands.',
    ),
    Act0RunnerOptionV1(
      id: 'range_only',
      label: 'Range plus board texture only',
      isCorrect: false,
      preferredLabel: 'Range plus stack depth',
      betterAnswerLabel: 'Range plus stack depth',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Still missing depth.',
      feedbackReason:
          'Board texture helps you sort the range, but World 8 adds stack depth. The next layer is how much risk remains behind.',
    ),
  ],
  feedbackTitle: 'Range takeaway.',
  feedbackReason:
      'Use bucketed ranges with board texture first, then carry the read into stack-depth risk decisions.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'World 6 checkpoint.',
      body:
          'Group hands into ranges, fit them to texture, then adjust risk by stack depth.',
      focusLabels: <String>['Range buckets', 'Texture fit', 'Stack depth'],
    ),
  ],
  table: _act0BoardLessonTableV1(
    heroCards: _act0LessonCardsV1('As Kc'),
    boardCards: _act0LessonCardsV1('Kh 9s 5d'),
    centerLabel: 'Read the flop',
  ),
);

// These questions assess a supplied premise, not an observed hand history.
// Do not inherit unrelated cards, street or pot as evidence for that premise.
Act0TableStateV1 _act0HypotheticalConceptTableV1(Act0TableStateV1 base) =>
    base.copyWith(
      scope: Act0TableScopeV1.explanation,
      showDecisionPremise: true,
      heroCards: const <Act0CardStateV1>[],
      boardCards: const <Act0CardStateV1>[],
      streetLabel: '',
      potLabel: '',
      toCallLabel: '',
      centerLabel: 'Hypothetical example',
      focusCalloutLabel: '',
      emptyBoardLabel: 'Use the stated premise',
      actionTrail: const <Act0ActionTrailItemV1>[],
      highlightedSeatIds: const <String>[],
      highlightedCardIds: const <String>[],
      instructionAnchor: '',
    );

final _w6WetBoardRepairRunner = _w6WrongBoardRunner.copyWith(
  caption:
      'BB called your flop bluff and checks this turn. Assume BB will call again with the better hands in its range.',
  table: _act0BoardLessonTableV1(
    heroCards: _act0LessonCardsV1('5c 4d'),
    boardCards: _act0LessonCardsV1('Kc 9s 2d Ts'),
    centerLabel: 'Read the turn',
    flopBetBb: 2,
    highlightedCardIds: const ['board_3'],
  ),
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w6_wet_board_repair',
  feedbackSignalId: 'board_texture_change',
  lessonTitle: 'Range meets board',
  lessonSubtitle: 'Range Thinking',
  hint: 'Use the stated behavior of the other player.',
  feedbackTitle: 'Repair the board read.',
  feedbackReason:
      'A bluff needs better hands to fold. The new turn model says BB will call with those hands.',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'respect_wetter_board',
      label: 'Check instead of betting again',
      isCorrect: true,
      preferredLabel: 'Check instead of betting again',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Nice repair.',
      feedbackReason:
          "Check because BB calls again with better hands. If you make the same bluff again, it pays those hands and gets no folds.",
    ),
    Act0RunnerOptionV1(
      id: 'nothing_changed',
      label: 'Make the same bluff again',
      isCorrect: false,
      preferredLabel: 'Check instead of betting again',
      betterAnswerLabel: 'Check instead of betting again',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          "Repeating the bluff costs chips when the better hands call again. Check because the turn changed which hands can continue.",
    ),
    Act0RunnerOptionV1(
      id: 'smaller_same_story',
      label: 'Bet smaller but keep the same dry-board story',
      isCorrect: false,
      preferredLabel: 'Check instead of betting again',
      betterAnswerLabel: 'Check instead of betting again',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Read the new board first.',
      feedbackReason:
          "A smaller bet still costs chips against better hands that call again. A check fits the wetter board and the stated reaction.",
    ),
  ],
  teachingSteps: const [],
  question: 'Which plan fits the stated turn behavior?',
);

// ── W7: Visible Cards Change Ranges — fresh runners ──────────────────────────────

final _w6RangeIntroRunner = _world5TextureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w6_range_intro',
  lessonTitle: 'Range buckets',
  lessonSubtitle: 'Range Thinking',
  caption: 'A range is the group of hands that fit a situation.',
  hint: 'Value, bluff candidate, and missed are the three range buckets.',
  question: 'What are range buckets?',
  options: const <Act0RunnerOptionV1>[],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Three buckets.',
      body:
          'For this exercise, choose a plan after the flop. Value bets target weaker calls. Bluff candidates can make better hands fold. With a miss and no good target to bluff, start by checking or folding.',
      focusLabels: <String>['Hand strength', 'Can it improve?', 'What folds?'],
    ),
  ],
  table: _act0BoardLessonTableV1(
    heroCards: _act0LessonCardsV1('Ad Js'),
    boardCards: _act0LessonCardsV1('Jh 8c 3d'),
    centerLabel: 'Read the flop',
  ),
  feedbackTitle: 'Read the range.',
  feedbackReason:
      'A range collects the hands that fit a situation. Read the flop before placing a hand in a bucket.',
);

// K-7-2 rainbow: hero has KQ → value range (top pair, good kicker)
final _w6ValueDryBoardRunner = _w6RangeIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w6_value_dry_board',
  caption: 'K-7-2 rainbow. You hold K-Q.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Dry-board range buckets.',
      body:
          'After the flop, sort your hand into value (weaker hands can call), '
          'bluff candidate (better hands can fold), or missed (usually check or fold).',
      focusLabels: <String>['Hand strength', 'Can it improve?', 'What folds?'],
    ),
  ],
  hint: 'Top pair with a good kicker.',
  question: 'Which range bucket is K-Q on this board?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'value',
      label: 'Value',
      isCorrect: true,
      preferredLabel: 'Value',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Clean execution.',
      feedbackReason:
          'Top pair with a good kicker is a strong value hand on this dry board.',
    ),
    Act0RunnerOptionV1(
      id: 'bluff',
      label: 'Bluff candidate',
      isCorrect: false,
      preferredLabel: 'Value',
      betterAnswerLabel: 'Value',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'K-Q hit the king. Bluff candidates are hands that missed and can still fold opponents out.',
    ),
    Act0RunnerOptionV1(
      id: 'missed',
      label: 'Missed',
      isCorrect: false,
      preferredLabel: 'Value',
      betterAnswerLabel: 'Value',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'K-Q flopped top pair. Missed hands do not connect to the board at all.',
    ),
  ],
  table: _act0BoardLessonTableV1(
    heroCards: _act0LessonCardsV1('Kd Qc'),
    boardCards: _act0LessonCardsV1('Kc 7d 2s'),
    centerLabel: 'Range bucket?',
  ),
);

// K-7-2 rainbow: hero has J-T → missed, but bluff-candidate is suboptimal
final _w6MissedDryBoardRunner = _w6RangeIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w6_missed_dry_board',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Compare the three buckets.',
      body:
          'Before acting postflop, sort your hand into value, bluff candidate, '
          'or missed by asking what calls and what folds.',
      focusLabels: <String>['Hand strength', 'Can it improve?', 'What folds?'],
    ),
  ],
  caption:
      'BB checks with a pair, Q-J, or A-9. BB calls a half-pot bet with any pair and folds Q-J and A-9. In this example, check if you can already beat either unpaired hand.',
  hint: 'Compare the high cards if neither hand improves.',
  question: 'What do you do with ace-queen after BB checks?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'missed',
      label: 'Check',
      isCorrect: true,
      preferredLabel: 'Check',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Ace-high can win.',
      feedbackReason:
          "Check A-Q because you already lead BB’s Q-J and A-9, and the rule says only pairs call a bet. Bluffing forces out the hands you already beat.",
    ),
    Act0RunnerOptionV1(
      id: 'bluff',
      label: 'Bet half pot as a bluff',
      isCorrect: false,
      preferredLabel: 'Check',
      betterAnswerLabel: 'Check',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Ace-high has a reason to check.',
      feedbackReason:
          "A bluff folds the two hands you beat and risks chips against the pairs that call. A check keeps the weaker hands in.",
    ),
    Act0RunnerOptionV1(
      id: 'value',
      label: 'Bet half pot for value',
      isCorrect: false,
      preferredLabel: 'Check',
      betterAnswerLabel: 'Check',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'The weaker hands would fold.',
      feedbackReason:
          "A value bet costs chips against pairs. The two weaker hands fold and cannot pay you in this model.",
    ),
  ],
  table: _act0BoardLessonTableV1(
    heroCards: _act0LessonCardsV1('As Qd'),
    boardCards: _act0LessonCardsV1('Kh 7s 2c'),
    centerLabel: 'Range bucket?',
  ),
);

final _w6TableBucketNoticeRunner = _w6RangeIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w6_table_bucket_notice',
  caption: 'Real table. K-7-2 rainbow lands and you hold A-Q.',
  teachingSteps: const <Act0TeachingStepV1>[],
  hint: 'Before picking a size, make the first useful read.',
  question: 'What should you ask first?',
  table: _act0BoardLessonTableV1(
    heroCards: _act0LessonCardsV1('As Qc'),
    boardCards: _act0LessonCardsV1('Kd 7c 2h'),
    centerLabel: 'Read the flop',
  ),
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'bucket_first',
      label: 'Which bucket is my hand in?',
      isCorrect: true,
      preferredLabel: 'Which bucket is my hand in?',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Nice start.',
      feedbackReason:
          "Read A-Q against the K-7-2 board first, because the best bet depends on what you can get to call or fold now. The preflop label misses that change.",
    ),
    Act0RunnerOptionV1(
      id: 'size_first',
      label: 'What size should I bet right now?',
      isCorrect: false,
      preferredLabel: 'Which bucket is my hand in?',
      betterAnswerLabel: 'Which bucket is my hand in?',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too fast.',
      feedbackReason:
          'Size comes after the bucket. First decide if the hand is value, bluff candidate, or missed.',
    ),
    Act0RunnerOptionV1(
      id: 'preflop_only',
      label: 'Was this hand strong preflop?',
      isCorrect: false,
      preferredLabel: 'Which bucket is my hand in?',
      betterAnswerLabel: 'Which bucket is my hand in?',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Useful start.',
      feedbackReason:
          'Preflop strength matters, but the flop bucket is the first sharp live-table read now.',
    ),
  ],
);

final _w6BucketsRecapRunner = _w6RangeIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w6_buckets_recap',
  caption: 'Lesson learned: range buckets start with board fit.',
  hint: 'Ask which bucket before choosing an action.',
  question: 'What do you read before putting your hand in a bucket?',
  feedbackTitle: 'Buckets takeaway.',
  feedbackReason:
      'Value, bluff candidate, and missed. Board fit decides which bucket your hand lands in.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Bucket before action.',
      body:
          'Assign your hand to a range bucket before choosing to bet, check, or fold.',
      focusLabels: <String>['Value', 'Bluff candidate', 'Missed', 'Board fit'],
    ),
  ],
  table: _act0BoardLessonTableV1(
    heroCards: _act0LessonCardsV1('Ts Tc'),
    boardCards: _act0LessonCardsV1('Td 5h 2s'),
    centerLabel: 'Read the flop',
  ),
);

// Board-fit lesson: 8-7-6 two-tone board ─────────────────────────────────

final _w6BoardFitIntroRunner = _w6RangeIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w6_board_fit_intro',
  lessonTitle: 'Range meets board',
  caption: 'Board texture can shift a hand from value to missed.',
  hint: 'The same hand can be value on one board and missed on another.',
  question: 'What changes a hand\'s range bucket?',
  options: const <Act0RunnerOptionV1>[],
  table: _act0BoardLessonTableV1(
    heroCards: _act0LessonCardsV1('Ad Jc'),
    boardCards: _act0LessonCardsV1('8h 7h 6c'),
    centerLabel: 'Read the flop',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Board changes the bucket.',
      body:
          'A preflop strong hand can become missed if it does not connect with the flop. An overpair is a pocket pair higher than every rank on the flop. An underpair is a pocket pair lower than every rank on the flop.',
      focusLabels: <String>['Board fit', 'Value', 'Missed', 'Texture'],
    ),
    Act0TeachingStepV1(
      title: 'Compare both ranges.',
      body:
          'Range advantage asks which player’s range makes strong hands more often on this board. '
          'In this lesson, use only the hands listed for each player and count hand types that make two pair or better.',
      focusLabels: <String>['Preflop raiser', 'Caller', 'Two pair or better'],
    ),
  ],
  feedbackTitle: 'Read how the board fits.',
  feedbackReason:
      'The same private cards can make a strong hand on one board and miss another.',
);

// 8-7-6 two-tone: hero has K-Q (no pair, no draw) → missed, bluff-candidate suboptimal
final _w6WrongBoardRunner = _w6BoardFitIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  teachingSteps: const [],
  lessonId: 'w6_wrong_board',
  caption: '8-7-6 two-tone. You hold K-Q.',
  hint: 'K-Q was strong preflop, but this board changed everything.',
  question: 'Which range bucket is K-Q on 8-7-6?',
  table: _act0BoardLessonTableV1(
    heroCards: _act0LessonCardsV1('Kd Qc'),
    boardCards: _act0LessonCardsV1('8h 7h 6c'),
    centerLabel: 'Read the flop',
  ),
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'missed',
      label: 'Missed',
      isCorrect: true,
      preferredLabel: 'Missed',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'K-Q missed this flop.',
      feedbackReason:
          'K-Q has neither a pair nor a one-card straight or flush draw on this flop.',
    ),
    Act0RunnerOptionV1(
      id: 'bluff',
      label: 'Bluff candidate',
      isCorrect: false,
      preferredLabel: 'Missed',
      betterAnswerLabel: 'Missed',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Read the board before choosing a bet.',
      feedbackReason:
          'K-Q missed. To decide whether to bluff, you still need to know which better hands the other player would fold.',
    ),
    Act0RunnerOptionV1(
      id: 'value',
      label: 'Value',
      isCorrect: false,
      preferredLabel: 'Missed',
      betterAnswerLabel: 'Missed',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Value depends on weaker calls.',
      feedbackReason:
          'K-Q missed this flop. An overpair such as J-J can bet for value if enough weaker hands call, even with no jack on the board.',
    ),
  ],
);

const _w6RangeAdvantageModelV1 =
    'BTN opens A-A, K-K, A-K, A-Q. BB calls 8-8, 7-7, 6-6, suited T-9.';

final _w6ValueWetBoardRunner = _w6BoardFitIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w6_value_wet_board',
  caption: _w6RangeAdvantageModelV1,
  hint: 'Look for two pair, three of a kind, and straights in each list.',
  question: 'In these ranges, who has more hand types at two pair or better?',
  feedbackTitle: 'The caller has more strong hands.',
  feedbackReason:
      'BB has three sets and the T-9 straight in this model. BTN has no hand that makes two pair or better.',
  table: _act0BoardLessonTableV1(
    heroCards: _act0LessonCardsV1('Ad Qc'),
    boardCards: _act0LessonCardsV1('8h 7h 6c'),
    centerLabel: 'Compare the ranges',
  ),
  teachingSteps: const [],
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'bluff',
      label: 'BTN, the raiser',
      isCorrect: false,
      preferredLabel: 'BB, the caller',
      betterAnswerLabel: 'BB, the caller',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'The board fits the caller here.',
      feedbackReason:
          'A-A and K-K are one pair. BB can make a set with 8-8, 7-7, or 6-6, or a straight with T-9.',
    ),
    Act0RunnerOptionV1(
      id: 'value',
      label: 'BB, the caller',
      isCorrect: true,
      preferredLabel: 'BB, the caller',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'The low ranks fit the caller.',
      feedbackReason:
          'BB has four strong hand types: three sets and the T-9 straight. BTN has zero in the listed range.',
    ),
    Act0RunnerOptionV1(
      id: 'missed',
      label: 'They have the same number',
      isCorrect: false,
      preferredLabel: 'BB, the caller',
      betterAnswerLabel: 'BB, the caller',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Count both lists.',
      feedbackReason:
          'BB has three sets and a straight. None of the listed BTN hands make two pair or better.',
    ),
  ],
);

final _w6TurnShiftBucketRunner = _w6BoardFitIntroRunner.copyWith(
  table: _act0BoardLessonTableV1(
    heroCards: _act0LessonCardsV1('Jh 9d'),
    boardCards: _act0LessonCardsV1('Ad 7s 4c 4h'),
    centerLabel: 'Read the turn',
    flopBetBb: 2,
  ),
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w6_turn_shift_bucket',
  feedbackSignalId: 'range_bucket_shift',
  caption:
      'BTN bet the flop and BB called. After checking the paired turn, BB calls with every hand that beats J9.',
  hint: 'When pressure drops, the bucket can slide.',
  question:
      'With J9 on this turn, what should you do with your earlier bluff plan?',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'A bucket can change.',
      body:
          'Suppose a bluff candidate loses fold pressure on the turn. It can move toward missed; it does not become value automatically.',
      focusLabels: <String>['Fold pressure', 'Missed'],
    ),
  ],
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'slide_missed',
      label: 'Check behind',
      isCorrect: true,
      preferredLabel: 'Check behind',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Solid understanding.',
      feedbackReason:
          "Check J9 on A-7-4-4 because BB calls with every better hand in this model. An extra bet pays those hands without getting the folds a bluff needs.",
    ),
    Act0RunnerOptionV1(
      id: 'always_value',
      label: 'Bet for value',
      isCorrect: false,
      preferredLabel: 'Check behind',
      betterAnswerLabel: 'Check behind',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'J9 did not improve when the fours paired. Because weaker hands are not the stated callers, betting for value risks chips against better hands.',
    ),
    Act0RunnerOptionV1(
      id: 'never_changes',
      label: 'Bet as another bluff',
      isCorrect: false,
      preferredLabel: 'Check behind',
      betterAnswerLabel: 'Check behind',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too static.',
      feedbackReason:
          'The paired turn changes which hands BB continues with. Another bet risks chips without folding out a better hand.',
    ),
  ],
);

final _w6BoardFitRecapRunner = _w6BoardFitIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w6_board_fit_recap',
  caption: _w6RangeAdvantageModelV1,
  hint: 'Look for two pair and three of a kind in each list.',
  question: 'In these ranges, who has more hand types at two pair or better?',
  feedbackTitle: 'The raiser has more strong hands.',
  feedbackReason:
      'BTN can make two pair with A-K, or a set with A-A or K-K. BB has none of those hands in this model.',
  table: _act0BoardLessonTableV1(
    heroCards: _act0LessonCardsV1('As Qd'),
    boardCards: _act0LessonCardsV1('Ah Kc 4s'),
    centerLabel: 'Compare the ranges',
  ),
  teachingSteps: const [],
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'caller',
      label: 'BB, the caller',
      isCorrect: false,
      preferredLabel: 'BTN, the raiser',
      betterAnswerLabel: 'BTN, the raiser',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'The caller has no two pair or set.',
      feedbackReason:
          'BB’s pocket pairs stay one pair. Only the raiser has A-A, K-K, and A-K in this model.',
    ),
    Act0RunnerOptionV1(
      id: 'same',
      label: 'They have the same number',
      isCorrect: false,
      preferredLabel: 'BTN, the raiser',
      betterAnswerLabel: 'BTN, the raiser',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Count the strong hands on A-K-4.',
      feedbackReason:
          'The raiser has two sets and one two-pair hand type. The caller has zero hand types at that strength.',
    ),
    Act0RunnerOptionV1(
      id: 'raiser',
      label: 'BTN, the raiser',
      isCorrect: true,
      preferredLabel: 'BTN, the raiser',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'The high ranks fit the raiser.',
      feedbackReason:
          'Only BTN has A-K for two pair and A-A or K-K for a set. A-Q makes one pair, so it does not count.',
    ),
  ],
);

// Pressure lines lesson ───────────────────────────────────────────────────

final _w6PressureLinesIntroRunner = _w6RangeIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w6_pressure_lines_intro',
  lessonTitle: 'Value, bluff, missed',
  caption: 'Each range bucket suggests a different action direction.',
  hint:
      'Value bets to get called. Bluff candidates can bet to fold out better hands.',
  question: 'What does a value hand do?',
  options: const <Act0RunnerOptionV1>[],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Bucket shapes action.',
      body:
          'Value bets can be paid by worse hands. Fold equity comes from the chance an opponent folds to your bet. '
          'Missed hands usually check or fold.',
      focusLabels: <String>['Bet value', 'Bluff', 'Check-fold'],
    ),
  ],
  table: _act0BoardLessonTableV1(
    heroCards: _act0LessonCardsV1('Ac Qd'),
    boardCards: _act0LessonCardsV1('Qh 8s 3d'),
    centerLabel: 'Read the flop',
  ),
  feedbackTitle: 'Ask what the bet earns.',
  feedbackReason:
      'Before betting, decide whether you want a weaker hand to call or a better hand to fold.',
);

// K-7-2: Hero has K-Q and acts after BB checks.
final _w6ValueRangeActionRunner = _w6PressureLinesIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w6_value_range_action',
  teachingSteps: const <Act0TeachingStepV1>[],
  caption:
      'BB checks, then calls half-pot bets with weaker pairs such as K-J and 7-6.',
  hint: 'Think about which hands would pay to see the turn.',
  question: 'What is the purpose of a half-pot bet here?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'bet',
      label: 'Bet for value',
      isCorrect: true,
      preferredLabel: 'Bet for value',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Weaker pairs can pay.',
      feedbackReason:
          "Bet for value because BB calls with K-J or 7-6. Checking misses those calls. Against a broader range, profit depends on how often BB calls or raises.",
    ),
    Act0RunnerOptionV1(
      id: 'check',
      label: 'Check',
      isCorrect: false,
      preferredLabel: 'Bet for value',
      betterAnswerLabel: 'Bet for value',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'A check gives a free card.',
      feedbackReason:
          'Checking is legal. The question asks what a half-pot bet does under the stated rule. It can get a call from a weaker pair.',
    ),
    Act0RunnerOptionV1(
      id: 'bet_bluff',
      label: 'Bet as a bluff',
      isCorrect: false,
      preferredLabel: 'Bet for value',
      betterAnswerLabel: 'Bet for value',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'The bet earns a call.',
      feedbackReason:
          "Calling it a bluff misses the source of profit. The bet earns chips when weaker pairs call.",
    ),
  ],
  table: _act0BoardLessonTableV1(
    heroCards: _act0LessonCardsV1('Kh Qs'),
    boardCards: _act0LessonCardsV1('Kd 7s 2c'),
    centerLabel: 'After BB checks',
  ),
);

// K-7-2: hero has A-Q (overcards, no pair) → bluff candidate (correct), value=wrong, missed=suboptimal
List<Act0RunnerOptionV1> _w6BluffCandidateOptionsV1(
  String hand,
) => <Act0RunnerOptionV1>[
  Act0RunnerOptionV1(
    id: 'bluff',
    label: 'Bet half pot as a bluff',
    isCorrect: true,
    preferredLabel: 'Bet half pot as a bluff',
    quality: Act0FeedbackQualityV1.correct,
    feedbackTitle: 'A bet can fold out a better hand.',
    feedbackReason:
        'Bluff because BB folds Q-J and A-9, both ahead of $hand if you check. Profit depends on how often BB has those hands.',
  ),
  Act0RunnerOptionV1(
    id: 'missed',
    label: 'Check',
    isCorrect: false,
    preferredLabel: 'Bet half pot as a bluff',
    betterAnswerLabel: 'Bet half pot as a bluff',
    quality: Act0FeedbackQualityV1.suboptimal,
    feedbackTitle: 'Both high-card hands beat yours.',
    feedbackReason:
        '$hand missed the board. You might improve after checking, but in this example a bet can make two better hands fold.',
  ),
  Act0RunnerOptionV1(
    id: 'value',
    label: 'Bet half pot for value',
    isCorrect: false,
    preferredLabel: 'Bet half pot as a bluff',
    betterAnswerLabel: 'Bet half pot as a bluff',
    quality: Act0FeedbackQualityV1.wrong,
    feedbackTitle: 'Worse calls are missing.',
    feedbackReason:
        'A value bet misses which hands would pay. This bluff asks better hands like Q-J and A-9 to fold because they already lead $hand.',
  ),
];

final _w6BluffCandidateRunner = _w6PressureLinesIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w6_bluff_candidate',
  teachingSteps: const <Act0TeachingStepV1>[],
  caption:
      'BB checks this K-7-2 flop. In this example, BB calls a half-pot bet with any pair and folds unpaired A-9 and Q-J. Check if you can already beat either of those two hands.',
  hint: 'Would you beat either unpaired hand if no one improves?',
  question: 'With jack-ten, which action can make a better unpaired hand fold?',
  options: _w6BluffCandidateOptionsV1('J-T'),
  table: _act0BoardLessonTableV1(
    heroCards: _act0LessonCardsV1('Js Tc'),
    boardCards: _act0LessonCardsV1('Kh 7d 2c'),
    centerLabel: 'Read the flop',
  ),
);

final _w6MissedHandActionRunner = _w6PressureLinesIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w6_missed_hand_action',
  caption: 'K-7-2 rainbow. You hold J-T with no draw.',
  teachingSteps: const <Act0TeachingStepV1>[],
  hint: 'Pure missed hands usually do not want a big pot.',
  question: 'What is the clean action direction?',
  table: _act0BoardLessonTableV1(
    heroCards: _act0LessonCardsV1('Jd Th'),
    boardCards: _act0LessonCardsV1('Ks 7h 2c'),
    centerLabel: 'After BB checks',
  ),
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'check_fold',
      label: 'Usually check or fold',
      isCorrect: true,
      preferredLabel: 'Usually check or fold',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Spot on.',
      feedbackReason:
          "On K-7-2, your J-T missed and has no draw, so checking keeps the next card free. Keep betting and you risk chips when BB continues with a made hand.",
    ),
    Act0RunnerOptionV1(
      id: 'value_bet',
      label: 'Bet for value',
      isCorrect: false,
      preferredLabel: 'Usually check or fold',
      betterAnswerLabel: 'Usually check or fold',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Wrong bucket.',
      feedbackReason:
          'Your jack-ten missed the flop. The exercise gives you no weaker hand that could pay this bet.',
    ),
    Act0RunnerOptionV1(
      id: 'always_barrel',
      label: 'Keep betting across streets',
      isCorrect: false,
      preferredLabel: 'Usually check or fold',
      betterAnswerLabel: 'Usually check or fold',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Too aggressive.',
      feedbackReason:
          'Some missed hands can bluff, but pure missed hands usually check or fold more often than they force large pressure.',
    ),
  ],
);

final _w6TableValueLineTransferRunner = _w6ValueRangeActionRunner.copyWith(
  lessonId: 'w6_table_value_line_transfer',
  caption:
      'BB checks. In this example, BB calls a half-pot bet with weaker kings and hands such as 8-7.',
  hint: 'Compare your hand with the hands BB will call with.',
  question:
      'What should you do to earn chips from the weaker hands BB will call with?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'bet_value',
      label: 'Bet for value',
      isCorrect: true,
      preferredLabel: 'Bet for value',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'A worse hand can call.',
      feedbackReason:
          "Bet for value because BB calls with weaker kings and 8-7. Checking misses those calls. Profit across hands depends on the full response range.",
    ),
    Act0RunnerOptionV1(
      id: 'check_back',
      label: 'Check',
      isCorrect: false,
      preferredLabel: 'Bet for value',
      betterAnswerLabel: 'Bet for value',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'A check gives up the weaker calls.',
      feedbackReason:
          'You can check after BB checks. The stated calling rule gives you a reason to bet instead.',
    ),
    Act0RunnerOptionV1(
      id: 'bet_bluff',
      label: 'Bet as a bluff',
      isCorrect: false,
      preferredLabel: 'Bet for value',
      betterAnswerLabel: 'Bet for value',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Look for the weaker calls.',
      feedbackReason:
          "Calling it a bluff misses who pays. Bet for value when weaker kings and smaller pairs are the intended callers.",
    ),
  ],
  table: _act0BoardLessonTableV1(
    heroCards: _act0LessonCardsV1('Ks Jc'),
    boardCards: _act0LessonCardsV1('Kh 8d 4c'),
    centerLabel: 'After BB checks',
    openBb: 2.75,
    highlightedCardIds: const ['hero_0', 'board_0'],
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Bucket first, line second.',
      body:
          'A bet can earn chips when the opponent calls with a worse hand. Start by deciding which hands would call.',
      focusLabels: <String>['Hand strength', 'Weaker hands', 'What calls?'],
    ),
  ],
);

final _w6TurnPressureShiftTransferRunner = _w6BluffCandidateRunner.copyWith(
  lessonId: 'w6_turn_pressure_shift_transfer',
  feedbackSignalId: 'range_bucket_shift',
  caption:
      'You bluffed the K-7-2 flop with J-T and BB called. The turn pairs the 2. BB checks and calls either bet with every better hand in this example.',
  hint:
      'When the board pairs and the first bluff gets called, some pressure lines cool off.',
  question: 'Fold pressure dropped on this turn. What do you do now?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'check_more',
      label: 'Check',
      isCorrect: true,
      preferredLabel: 'Check',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Good pressure reset.',
      feedbackReason:
          "Check for a free river. The paired turn leaves J-T behind the hands BB calls with, and neither bet makes those hands fold.",
    ),
    Act0RunnerOptionV1(
      id: 'barrel_big',
      label: 'Bet big again',
      isCorrect: false,
      preferredLabel: 'Check',
      betterAnswerLabel: 'Check',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Tempting, but noisy.',
      feedbackReason:
          "A bigger second bet risks more chips. In this model every hand ahead of you still calls, so check for a free next card.",
    ),
    Act0RunnerOptionV1(
      id: 'bet_value',
      label: 'Bet for value',
      isCorrect: false,
      preferredLabel: 'Check',
      betterAnswerLabel: 'Check',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Wrong bucket now.',
      feedbackReason:
          'J-T has not paired either private card on K-7-2-2. Under this lower-pressure premise, treating it as automatic value misses the point.',
    ),
  ],
  table: _act0BoardLessonTableV1(
    heroCards: _act0LessonCardsV1('Jd Ts'),
    boardCards: _act0LessonCardsV1('Kc 7h 2s 2d'),
    centerLabel: 'After BB checks',
    openBb: 2.75,
    flopBetBb: 2.5,
    highlightedCardIds: const ['board_2', 'board_3'],
  ),
  teachingSteps: const [],
);

final _w6PressureLinesRecapRunner = _w6PressureLinesIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w6_pressure_lines_recap',
  caption: 'Lesson learned: bucket decides the action direction.',
  hint: 'Value bets. Bluff candidates can bet or fold. Missed usually folds.',
  question: 'What does each range bucket suggest?',
  feedbackTitle: 'Pressure takeaway.',
  feedbackReason:
      'Value bets for profit. Bluff candidates apply fold pressure. '
      'Missed hands conserve chips by folding or checking.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Action follows bucket.',
      body: 'Assign the bucket first, then let it guide your action.',
      focusLabels: <String>['Value bets', 'Bluff folds out', 'Missed folds'],
    ),
  ],
  table: _act0BoardLessonTableV1(
    heroCards: _act0LessonCardsV1('Ad Tc'),
    boardCards: _act0LessonCardsV1('As 7s 4h'),
    centerLabel: 'Read the flop',
  ),
);

// Combo-count lesson ───────────────────────────────────────────────────────

final _w6ComboCountsIntroRunner = _w6RangeIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w6_combo_counts_intro',
  lessonTitle: 'Count the combos',
  caption: 'Ranges are not just hand names. They also have combo counts.',
  hint:
      'First count the possible hands. To weigh a range, ask how often each one takes the action.',
  question: 'Why do combo counts matter?',
  options: const <Act0RunnerOptionV1>[],
  table: _act0UnopenedLessonTableV1(
    heroCards: _act0LessonCardsV1('Jc 9d'),
    centerLabel: 'Count combinations',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Families have counts.',
      body:
          'A combo is one exact two-card hand. Four aces times four kings gives 16 A-K combos. '
          'Four share a suit and 12 do not. A pocket pair has six ways to choose two of its four cards. '
          'A blocker is a known card, such as one you hold, that rules out any opponent combo containing it.',
      focusLabels: <String>['16 combos', '6 combos', 'Range density'],
    ),
  ],
  feedbackTitle: 'Count the actual hands.',
  feedbackReason:
      'A hand family represents several different two-card combinations. Count them to see how much weight each family has.',
);

final _w6AkComboRunner = _w6ComboCountsIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Count the cards of each rank.',
      body:
          'For two different ranks, each available card of the first rank can pair with each available card of the second rank.',
      focusLabels: <String>['Available cards', 'Two ranks', 'Pair the cards'],
    ),
  ],
  lessonId: 'w6_ak_combos',
  caption: 'A-K can be suited or offsuit.',
  hint:
      'Four aces can pair with four kings. A blocker is a visible or known card that removes possible private-card combinations.',
  question: 'How many combos does A-K have before blockers?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'sixteen',
      label: '16 combos',
      isCorrect: true,
      preferredLabel: '16 combos',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Nice count.',
      feedbackReason:
          'A-K has 16 combos before blockers: 4 suited and 12 offsuit combinations. Blockers would remove visible or known cards from those private-card combinations.',
    ),
    Act0RunnerOptionV1(
      id: 'twelve',
      label: '12 combos',
      isCorrect: false,
      preferredLabel: '16 combos',
      betterAnswerLabel: '16 combos',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          '12 counts only the offsuit versions. Add the 4 suited combos and A-K reaches 16 total combinations.',
    ),
    Act0RunnerOptionV1(
      id: 'six',
      label: '6 combos',
      isCorrect: false,
      preferredLabel: '16 combos',
      betterAnswerLabel: '16 combos',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'Six combos is the count for a pocket pair. A-K has 16 possible suit combinations before removing known cards.',
    ),
  ],
  table: _act0UnopenedLessonTableV1(
    heroCards: _act0LessonCardsV1('Tc 9h'),
    centerLabel: 'Count combinations',
  ),
);

final _w6PairComboRunner = _w6ComboCountsIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  teachingSteps: const [],
  lessonId: 'w6_pair_combos',
  caption: 'Pocket eights are one pair family.',
  hint: 'You pick 2 suits out of the 4 eights in the deck.',
  question: 'How many combos does 8-8 have?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'six',
      label: '6 combos',
      isCorrect: true,
      preferredLabel: '6 combos',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Nice count.',
      feedbackReason:
          'Choose two of the four suits. That gives six possible pairs before removing known cards.',
    ),
    Act0RunnerOptionV1(
      id: 'twelve',
      label: '12 combos',
      isCorrect: false,
      preferredLabel: '6 combos',
      betterAnswerLabel: '6 combos',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'Twelve is too high for one pair family. With four eights in the deck, only 6 suit pairings are possible.',
    ),
    Act0RunnerOptionV1(
      id: 'sixteen',
      label: '16 combos',
      isCorrect: false,
      preferredLabel: '6 combos',
      betterAnswerLabel: '6 combos',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'Sixteen combos belongs to two different ranks like A-K, not to one pocket pair.',
    ),
  ],
  table: _act0UnopenedLessonTableV1(
    heroCards: _act0LessonCardsV1('8h 8c'),
    centerLabel: 'Count combinations',
  ),
);

final _w6ComboWeightCompareRunner = _w6ComboCountsIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w6_combo_weight_compare',
  teachingSteps: const <Act0TeachingStepV1>[],
  caption: 'Compare A-K with pocket eights before blockers.',
  hint: 'One family has 16 combos. The other has 6.',
  question: 'Which family has more possible combos?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'ak_more',
      label: 'A-K has more combos',
      isCorrect: true,
      preferredLabel: 'A-K has more combos',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Nice count.',
      feedbackReason:
          'Before removing known cards, A-K has 16 combos and pocket eights have 6.',
    ),
    Act0RunnerOptionV1(
      id: 'same_weight',
      label: 'They have the same combo count',
      isCorrect: false,
      preferredLabel: 'A-K has more combos',
      betterAnswerLabel: 'A-K has more combos',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'The hand names may feel equally important, but combo weight is not equal: 16 beats 6.',
    ),
    Act0RunnerOptionV1(
      id: 'pair_more',
      label: 'Pocket eights have more combos',
      isCorrect: false,
      preferredLabel: 'A-K has more combos',
      betterAnswerLabel: 'A-K has more combos',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'Pocket pairs have only 6 combos. Broad non-pair families like A-K are denser.',
    ),
  ],
  table: _act0UnopenedLessonTableV1(
    heroCards: _act0LessonCardsV1('7d 6d'),
    centerLabel: 'Count combinations',
  ),
);

final _w6ComboCountsRecapRunner = _w6ComboCountsIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w6_combo_counts_recap',
  caption:
      'Lesson learned: count the possible hands, then account for the action.',
  hint: 'A-K = 16 combos. A pocket pair = 6 combos.',
  question: 'What do combo counts help you measure?',
  feedbackTitle: 'Combo takeaway.',
  feedbackReason:
      'Combo counts tell you how many ways a hand can be dealt. The range also depends on how often each hand takes the action.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Count before you guess.',
      body:
          'Count the available combos, then account for the action. Ten available combos count as five on average if each takes this action half the time.',
      focusLabels: <String>['16 combos', '6 combos', 'Range density'],
    ),
  ],
  table: _act0UnopenedLessonTableV1(
    heroCards: _act0LessonCardsV1('9c 8c'),
    centerLabel: 'Count combinations',
  ),
);

final _w6SuitedOffsuitWeightCompareRunner = _w6ComboCountsIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w6_suited_offsuit_weight_compare',
  lessonTitle: 'Range thinking checkpoint',
  lessonSubtitle: 'Range Thinking',
  caption: 'Compare A-K suited with A-K offsuit before blockers.',
  hint: 'Offsuit hands usually have more combinations than suited hands.',
  feedbackReason:
      'With no cards removed, four combinations are suited and twelve are offsuit.',
  question: 'How many combinations are suited and how many are offsuit?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'ak_offsuit',
      label: '4 suited, 12 offsuit',
      isCorrect: true,
      preferredLabel: '4 suited, 12 offsuit',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Clean weight read.',
      feedbackReason:
          'A-K offsuit has 12 possible combos, while A-K suited has 4.',
    ),
    Act0RunnerOptionV1(
      id: 'ak_suited',
      label: '12 suited, 4 offsuit',
      isCorrect: false,
      preferredLabel: '4 suited, 12 offsuit',
      betterAnswerLabel: '4 suited, 12 offsuit',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Easy trap.',
      feedbackReason:
          'Suited feels special, but it is rarer. Only 4 suited combinations exist, while the offsuit family has 12.',
    ),
    Act0RunnerOptionV1(
      id: 'same_weight',
      label: '8 suited, 8 offsuit',
      isCorrect: false,
      preferredLabel: '4 suited, 12 offsuit',
      betterAnswerLabel: '4 suited, 12 offsuit',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Count the suited and offsuit combos.',
      feedbackReason:
          'The rank names match, but combo weight does not. Twelve offsuit combos clearly outweigh four suited combos.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Suited is rarer.',
      body:
          'Four aces can go with four kings. Four combinations match suits, leaving twelve offsuit combinations.',
      focusLabels: <String>['12 offsuit', '4 suited', 'Range weight'],
    ),
  ],
  table: _act0UnopenedLessonTableV1(
    heroCards: _act0LessonCardsV1('Jh Th'),
    centerLabel: 'Count combinations',
  ),
);

final _w6PairVsSuitedWeightCompareRunner = _w6ComboCountsIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w6_pair_vs_suited_weight_compare',
  lessonTitle: 'Range thinking checkpoint',
  lessonSubtitle: 'Range Thinking',
  caption: 'Compare pocket nines with K-Q suited before blockers.',
  hint: 'Not every unpaired hand is denser than a pocket pair.',
  feedbackReason:
      'A pocket pair has six combinations. A specific suited hand has four.',
  question: 'Which family has more possible combos?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'pair_nines',
      label: 'Pocket nines',
      isCorrect: true,
      preferredLabel: 'Pocket nines',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Good compare.',
      feedbackReason:
          'Pocket nines have 6 possible combos, compared with 4 for K-Q suited.',
    ),
    Act0RunnerOptionV1(
      id: 'kq_suited',
      label: 'K-Q suited',
      isCorrect: false,
      preferredLabel: 'Pocket nines',
      betterAnswerLabel: 'Pocket nines',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'One more count.',
      feedbackReason:
          'Unpaired does not always mean more common. Once you limit K-Q to suited only, it drops to 4 combos and loses to the pair family at 6.',
    ),
    Act0RunnerOptionV1(
      id: 'same_weight',
      label: 'They have the same combo count',
      isCorrect: false,
      preferredLabel: 'Pocket nines',
      betterAnswerLabel: 'Pocket nines',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Count the pairs and suited combos.',
      feedbackReason:
          'These families are closer than A-K versus a pocket pair, but they are still not equal. Six pair combos outweigh four suited combos.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Weight beats intuition.',
      body:
          'A pocket pair has six possible combos. A specified suited hand has four, one per suit.',
      focusLabels: <String>[
        '6 pair combos',
        '4 suited combos',
        'Use the count',
      ],
    ),
  ],
  table: _act0UnopenedLessonTableV1(
    heroCards: _act0LessonCardsV1('Ac Jc'),
    centerLabel: 'Count combinations',
  ),
);

final _w6CheckpointTableComboWeightRunner = _w6ComboCountsIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w6_checkpoint_table_combo_weight',
  lessonTitle: 'Range thinking checkpoint',
  lessonSubtitle: 'Range Thinking',
  caption:
      'CO opens preflop. Assume CO opens every A-K offsuit and every 9-9 combo.',
  hint:
      'Here every combo from either family takes the same action. Compare counts before removing known cards.',
  question: 'How many combos does each family contribute before blockers?',
  table: _act0CoOpenLessonTableV1(
    startingDepthBb: 100,
    heroCards: _unknownHoleCards,
    centerLabel: 'Count combinations',
  ),
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'ak_offsuit',
      label: '12 AK offsuit, 6 pairs',
      isCorrect: true,
      preferredLabel: '12 AK offsuit, 6 pairs',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Practical read.',
      feedbackReason:
          'With every combo of both hands included, A-K offsuit contributes 12 and pocket nines contribute 6.',
    ),
    Act0RunnerOptionV1(
      id: 'pair_nines',
      label: '6 AK offsuit, 12 pairs',
      isCorrect: false,
      preferredLabel: '12 AK offsuit, 6 pairs',
      betterAnswerLabel: '12 AK offsuit, 6 pairs',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Count the off-suit combinations.',
      feedbackReason:
          'CO opens all six pocket-nine combos here and all twelve A-K offsuit combos.',
    ),
    Act0RunnerOptionV1(
      id: 'same_weight',
      label: '9 AK offsuit, 9 pairs',
      isCorrect: false,
      preferredLabel: '12 AK offsuit, 6 pairs',
      betterAnswerLabel: '12 AK offsuit, 6 pairs',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'CO opens both families at the same frequency per combo, so twelve A-K offsuit combos carry twice the weight of six pocket-nine combos.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Count the combos that take the action.',
      body:
          'Here every listed combo opens, so the count is enough. If CO opens some combos only part of the time, those combos count for less.',
      focusLabels: <String>['12 beats 6', 'Range weight', 'First read'],
    ),
  ],
);

// Stack depth and risk ────────────────────────────────────────────────────

final _w7EffectiveStackIntroRunner = _w6ComboCountsIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w7_effective_stack_intro',
  lessonTitle: 'Effective stack',
  lessonSubtitle: 'Stack Depth And Risk',
  caption: 'The smaller of two stacks caps what those players can match.',
  hint: 'Compare the two players who can put chips in against each other.',
  question: 'What is the effective stack?',
  table: _act0BoardLessonTableV1(
    openingSeat: 'co',
    heroCards: _act0LessonCardsV1('Ac Qd'),
    boardCards: _act0LessonCardsV1('Qs 8c 3h'),
    centerLabel: 'Compare the stacks',
    heroBehindBb: 200,
    bbBehindBb: 30,
    openBb: 2.5,
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Smaller stack rules.',
      body:
          'If you have 200 BB and the other player has 30 BB, the effective stack is 30 BB. That smaller stack sets the real risk.',
      focusLabels: <String>['200 BB', '30 BB', 'Effective stack'],
    ),
  ],
  feedbackTitle: 'Find the smaller stack.',
  feedbackReason:
      'Between two players, the smaller stack caps what the two can still match.',
);

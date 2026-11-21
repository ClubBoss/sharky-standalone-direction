part of 'act0_shell_state_v1.dart';

final _w7EffectiveStackThirtyRunner = _w7EffectiveStackIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  teachingSteps: const [],
  lessonId: 'w7_effective_stack_30bb',
  caption: 'You have 200 BB. The other player has 30 BB.',
  hint: 'Look for the smaller stack.',
  question: 'What is the effective stack?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: '30',
      label: '30 BB',
      isCorrect: true,
      preferredLabel: '30 BB',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Clean execution.',
      feedbackReason:
          'Against this opponent, each player can put in up to 30 BB from these stacks.',
    ),
    Act0RunnerOptionV1(
      id: '200',
      label: '200 BB',
      isCorrect: false,
      preferredLabel: '30 BB',
      betterAnswerLabel: '30 BB',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'Your own stack can be deeper, but the hand risk is capped by the smaller stack across from you.',
    ),
    Act0RunnerOptionV1(
      id: '115',
      label: '115 BB',
      isCorrect: false,
      preferredLabel: '30 BB',
      betterAnswerLabel: '30 BB',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Use the smaller stack.',
      feedbackReason:
          'The average is 115 BB, but these players can only match 30 BB each.',
    ),
  ],
  table: _act0BoardLessonTableV1(
    heroCards: _act0LessonCardsV1('7s 7c'),
    boardCards: _act0LessonCardsV1('Ad 9h 3c'),
    centerLabel: 'Compare the stacks',
    heroBehindBb: 200,
    bbBehindBb: 30,
    openBb: 3,
  ),
);

final _w7EffectiveStackEvenRunner = _w7EffectiveStackIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w7_effective_stack_100bb',
  caption: 'Both players have the same stack behind on this flop.',
  teachingSteps: const <Act0TeachingStepV1>[],
  hint: 'Equal stacks keep the full depth in play.',
  question: 'What is the effective stack?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: '100',
      label: '100 BB',
      isCorrect: true,
      preferredLabel: '100 BB',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'The matching stacks set the limit.',
      feedbackReason:
          'When both stacks are equal, that shared stack is the effective stack.',
    ),
    Act0RunnerOptionV1(
      id: '50',
      label: '50 BB',
      isCorrect: false,
      preferredLabel: '100 BB',
      betterAnswerLabel: '100 BB',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'Nothing cuts the stack in half here. With equal 100 BB stacks, the full 100 BB remains in play.',
    ),
    Act0RunnerOptionV1(
      id: '200',
      label: '200 BB',
      isCorrect: false,
      preferredLabel: '100 BB',
      betterAnswerLabel: '100 BB',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'Add the stacks and you get total chips, not effective stack. The hand still plays 100 BB deep.',
    ),
  ],
  table: _act0BoardLessonTableV1(
    heroCards: _act0LessonCardsV1('Kd Td'),
    boardCards: _act0LessonCardsV1('Th 8d 3c'),
    centerLabel: 'Compare the stacks',
    heroBehindBb: 100,
    bbBehindBb: 100,
    openBb: 2.75,
  ),
);

final _w7EffectiveStackTableNoticeRunner = _w7EffectiveStackIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w7_table_effective_notice',
  caption: 'You cover a player 120 BB to 18 BB on a real table.',
  teachingSteps: const <Act0TeachingStepV1>[],
  hint: 'Notice the number that caps the real risk.',
  question: 'What should you notice first before planning?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'eighteen_effective',
      label: '18 BB effective stack',
      isCorrect: true,
      preferredLabel: '18 BB effective stack',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Sharp read.',
      feedbackReason:
          'That is the real live-table risk. The smaller stack sets the hand depth.',
    ),
    Act0RunnerOptionV1(
      id: 'your_120',
      label: 'Your own 120 BB stack',
      isCorrect: false,
      preferredLabel: '18 BB effective stack',
      betterAnswerLabel: '18 BB effective stack',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'That answer is tempting because your stack looks bigger and feels more powerful. The cleaner read is the smaller 18 BB stack, because that is the number that actually caps what can go in.',
    ),
    Act0RunnerOptionV1(
      id: 'total_138',
      label: '138 BB total in play',
      isCorrect: false,
      preferredLabel: '18 BB effective stack',
      betterAnswerLabel: '18 BB effective stack',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'Total chips are a real table detail, so this looks useful at first. But total chips do not drive the plan here. The dominant cue is the effective stack that caps the real risk.',
    ),
  ],
  table: _act0BoardLessonTableV1(
    heroCards: _act0LessonCardsV1('Js Jc'),
    boardCards: _act0LessonCardsV1('Td 7c 3h'),
    centerLabel: 'Compare the stacks',
    heroBehindBb: 120,
    bbBehindBb: 18,
    openBb: 2.5,
  ),
);

final _w7EffectiveStackRecapRunner = _w7EffectiveStackIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w7_effective_stack_recap',
  caption: 'Lesson learned: the smaller stack sets the hand risk.',
  hint: 'Effective stack tells you how much room the hand really has.',
  question: 'Why does effective stack matter?',
  feedbackTitle: 'Effective-stack takeaway.',
  feedbackReason:
      'Effective stack tells you the real risk in the hand. Deep stacks leave room. Short stacks simplify decisions.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Risk starts here.',
      body:
          'Find the smaller stack first. That tells you how deep the hand really plays.',
      focusLabels: <String>['Smaller stack', 'Real risk', 'Hand depth'],
    ),
  ],
  table: _act0BoardLessonTableV1(
    heroCards: _act0LessonCardsV1('Kh Qh'),
    boardCards: _act0LessonCardsV1('Qc 9s 2d'),
    centerLabel: 'Compare the stacks',
    heroBehindBb: 43,
    bbBehindBb: 75,
    openBb: 3,
  ),
);

final _w7DepthShiftIntroRunner = _w7EffectiveStackIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w7_depth_shift_intro',
  lessonTitle: 'Same hand, different depth',
  caption:
      'Compare a short stack here with a deeper stack holding the same hand.',
  hint: 'Short stacks simplify decisions. Deep stacks create more future risk.',
  question: 'Why does stack depth change the plan?',
  table: _act0BoardLessonTableV1(
    heroCards: _act0LessonCardsV1('As Js'),
    boardCards: _act0LessonCardsV1('Ac 7h 2c'),
    centerLabel: 'Read the stack depth',
    heroBehindBb: 20,
    bbBehindBb: 20,
    openBb: 2.5,
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Depth changes commitment.',
      body:
          'A short stack runs out sooner. It also limits how much you can win when a small pair makes a set or suited connectors make a strong hand. At 100 BB, you have more chips for bets on the same streets.',
      focusLabels: <String>['20 BB', '100 BB', 'More room', 'More risk'],
    ),
  ],
  feedbackTitle: 'Check how much is behind.',
  feedbackReason:
      'The same hand can face bigger bets on the same streets when more chips are left.',
);

final _w7TwentyBbWiderRunner = _w7DepthShiftIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  teachingSteps: const [],
  lessonId: 'w7_20bb_wider',
  caption:
      'BB checks. You have top pair and want to keep at least 18 BB for later streets.',
  hint: 'Subtract each possible bet from the stack you have left.',
  question: 'Which bet fits your plan?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: '20bb',
      label: 'Bet 2 BB',
      isCorrect: true,
      preferredLabel: 'Bet 2 BB',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'You keep 18 BB.',
      feedbackReason:
          'You have 20 BB behind. Betting 2 BB leaves 18 BB for the turn and river.',
    ),
    Act0RunnerOptionV1(
      id: '100bb',
      label: 'Bet 4 BB',
      isCorrect: false,
      preferredLabel: 'Bet 2 BB',
      betterAnswerLabel: 'Bet 2 BB',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Four leaves 16 BB.',
      feedbackReason:
          'Subtract the 4 BB bet from your 20 BB stack. That leaves 16 BB, below your 18 BB target.',
    ),
    Act0RunnerOptionV1(
      id: 'same',
      label: 'Go all-in',
      isCorrect: false,
      preferredLabel: 'Bet 2 BB',
      betterAnswerLabel: 'Bet 2 BB',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'All-in leaves nothing behind.',
      feedbackReason:
          'At 20 BB behind, an all-in uses the entire stack. Top pair does not require you to go all-in.',
    ),
  ],
  table: _act0BoardLessonTableV1(
    heroCards: _act0LessonCardsV1('Ah Jh'),
    boardCards: _act0LessonCardsV1('Ad 8c 4h'),
    centerLabel: 'Read the stack depth',
    heroBehindBb: 20,
    bbBehindBb: 20,
    openBb: 2.5,
  ),
);

final _w7HundredBbTighterRunner = _w7DepthShiftIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w7_100bb_tighter',
  teachingSteps: const <Act0TeachingStepV1>[],
  caption:
      'BB checks. Plan a 4 BB flop bet and an 8 BB turn bet. Assume BB calls both.',
  hint: 'Subtract both earlier bets from the smaller stack.',
  question: 'Which river bet would both stacks still cover?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'more_risk',
      label: '75 BB',
      isCorrect: true,
      preferredLabel: '75 BB',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Both stacks cover 75 BB.',
      feedbackReason:
          'Both started the flop with 100 BB behind. After putting in 12 BB each, both have 88 BB left. A 75 BB river bet fits.',
    ),
    Act0RunnerOptionV1(
      id: 'less_risk',
      label: '90 BB',
      isCorrect: false,
      preferredLabel: '75 BB',
      betterAnswerLabel: '75 BB',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Both stacks are now below 90 BB.',
      feedbackReason:
          'After 4 BB and 8 BB, only 88 BB is left per player. The flop and turn used part of both stacks.',
    ),
    Act0RunnerOptionV1(
      id: 'forced_jam',
      label: '100 BB',
      isCorrect: false,
      preferredLabel: '75 BB',
      betterAnswerLabel: '75 BB',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'The original stack has already shrunk.',
      feedbackReason:
          'There are no additional streets at this depth. There are more chips to bet on the same streets, but here the most either player can put in on the river is 88 BB.',
    ),
  ],
  table: _act0BoardLessonTableV1(
    heroCards: _act0LessonCardsV1('Ad Jd'),
    boardCards: _act0LessonCardsV1('Ah 8s 4d'),
    centerLabel: 'Read the stack depth',
    heroBehindBb: 100,
    bbBehindBb: 100,
    openBb: 2.5,
  ),
);

final _w7FortyBbMiddleRunner = _w7DepthShiftIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w7_40bb_middle',
  teachingSteps: const <Act0TeachingStepV1>[],
  caption:
      'BB checks. Plan a 5 BB flop bet and a 10 BB turn bet. Assume BB calls both.',
  hint: 'Track the chips left after each bet.',
  question: 'What is the largest river bet both stacks could cover?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'middle_ground',
      label: '25 BB',
      isCorrect: true,
      preferredLabel: '25 BB',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Both players have 25 BB left.',
      feedbackReason:
          'Each puts in 5 BB and then 10 BB. From 40 BB behind on the flop, that leaves 25 BB on the river.',
    ),
    Act0RunnerOptionV1(
      id: 'pure_jam',
      label: '40 BB',
      isCorrect: false,
      preferredLabel: '25 BB',
      betterAnswerLabel: '25 BB',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Some of the stack went in earlier.',
      feedbackReason:
          '40 BB is the depth before the two bets. Once each player has put in 15 BB, the river limit is lower.',
    ),
    Act0RunnerOptionV1(
      id: 'same_100',
      label: '30 BB',
      isCorrect: false,
      preferredLabel: '25 BB',
      betterAnswerLabel: '25 BB',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Count the flop bet as well.',
      feedbackReason:
          'Subtracting the turn bet alone leaves 30 BB. Subtract the 5 BB flop bet too, which leaves 25 BB.',
    ),
  ],
  table: _act0BoardLessonTableV1(
    heroCards: _act0LessonCardsV1('Ac Jc'),
    boardCards: _act0LessonCardsV1('As 8d 4c'),
    centerLabel: 'Read the stack depth',
    heroBehindBb: 40,
    bbBehindBb: 40,
    openBb: 2.5,
  ),
);

Act0TableStateV1 _act0CoOpenLessonTableV1({
  required num startingDepthBb,
  required List<Act0CardStateV1> heroCards,
  required String centerLabel,
}) {
  final table = _act0FacingOpenTableV1(
    _legacyFacingOpenTableV1.copyWith(
      heroCards: heroCards,
      centerLabel: centerLabel,
      autoPlayHistory: false,
      highlightedSeatIds: const [],
    ),
    opener: 'co',
  );
  return table.copyWith(
    handContributions: Act0HandContributionsV1(
      throughStreet: PokerStreet.preflop,
      startingStackBbBySeat: {
        'btn': startingDepthBb.toDouble(),
        'co': startingDepthBb.toDouble(),
      },
      entries: const [
        ..._act0LessonBlinds,
        Act0ContributionV1(
          PokerStreet.preflop,
          'co',
          Act0ContributionKindV1.wager,
          2.5,
        ),
      ],
    ),
    actionTrail: [
      for (final item in table.actionTrail)
        if (item.label == 'CO opens 2.5 BB')
          const Act0ActionTrailItemV1(label: 'CO raises 2.5 BB')
        else
          item,
    ],
    seats: [
      for (final seat in table.seats)
        switch (seat.seatId) {
          'btn' => _act0CopySeatStateV1(
            seat,
            stackLabel: _act0BbLabelV1(startingDepthBb),
            cardsVisibleMode: heroCards == _unknownHoleCards
                ? Act0CardsVisibleModeV1.faceDown
                : Act0CardsVisibleModeV1.faceUp,
          ),
          'co' => _act0CopySeatStateV1(
            seat,
            stackLabel: _act0BbLabelV1(startingDepthBb - 2.5),
          ),
          _ => seat,
        },
    ],
  );
}

final _w7AjsButtonTwentyFiveBbRunner = _w7DepthShiftIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w7_ajs_btn_25bb_transfer',
  caption:
      'CO opens to 2.5 BB. Assume the blinds fold. CO calls a raise to 7.5 BB with A-T suited, but folds A-T suited to an all-in.',
  hint: 'Look for the raise that a weaker ace will call.',
  question: 'Which raise gets more chips from the weaker ace?',
  table: _act0CoOpenLessonTableV1(
    startingDepthBb: 25,
    heroCards: _heroAJsCards,
    centerLabel: 'Compare the stacks',
  ),
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'cleaner_shallow',
      label: 'Raise to 7.5 BB',
      isCorrect: true,
      preferredLabel: 'Raise to 7.5 BB',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'A-T suited calls the raise.',
      feedbackReason:
          'Under the stated rule, A-T suited pays the extra 5 BB. Both players then have 17.5 BB behind. The best line against CO’s full range would depend on what else opens and responds to a raise.',
    ),
    Act0RunnerOptionV1(
      id: 'same_as_100',
      label: 'Call 2.5 BB',
      isCorrect: false,
      preferredLabel: 'Raise to 7.5 BB',
      betterAnswerLabel: 'Raise to 7.5 BB',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'A call does not make CO add chips.',
      feedbackReason:
          'Calling keeps A-T suited in, but puts no extra chips in from CO. The question asks which raise gets paid.',
    ),
    Act0RunnerOptionV1(
      id: 'too_fragile_now',
      label: 'Go all-in for 25 BB',
      isCorrect: false,
      preferredLabel: 'Raise to 7.5 BB',
      betterAnswerLabel: 'Raise to 7.5 BB',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'A-T suited folds to an all-in bet.',
      feedbackReason:
          'CO folds the weaker ace to an all-in bet in this example. The smaller raise gets the call instead.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Same hand, simpler shallow.',
      body:
          'A shorter effective stack caps how much more you can lose with a second-best hand.',
      focusLabels: <String>['25 BB', 'Position', 'Less future risk'],
    ),
  ],
);

final _w7AjsButtonHundredBbRunner = _w7DepthShiftIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w7_ajs_btn_100bb_transfer',
  caption:
      'CO opens to 2.5 BB. Assume the blinds fold. CO folds weaker aces to any raise. A-Q and A-K reraise a small raise and call an all-in bet.',
  hint: 'Find the action that keeps weaker aces in.',
  question: 'Which action keeps the weaker aces in the pot?',
  table: _act0CoOpenLessonTableV1(
    startingDepthBb: 100,
    heroCards: _heroAJsCards,
    centerLabel: 'Compare the stacks',
  ),
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'more_fragile_deep',
      label: 'Call 2.5 BB',
      isCorrect: true,
      preferredLabel: 'Call 2.5 BB',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'A call keeps the weaker aces in.',
      feedbackReason:
          'Under the stated rule, a call keeps weaker aces in and leaves both players 97.5 BB behind. The best line against CO’s full range depends on the mix of hands and how they play later.',
    ),
    Act0RunnerOptionV1(
      id: 'same_clean_call',
      label: 'Raise to 7.5 BB',
      isCorrect: false,
      preferredLabel: 'Call 2.5 BB',
      betterAnswerLabel: 'Call 2.5 BB',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'A raise folds the hands you want to keep.',
      feedbackReason:
          'In this example CO folds the weaker aces to either raise and raises again with stronger hands such as A-Q.',
    ),
    Act0RunnerOptionV1(
      id: 'shove_now',
      label: 'Go all-in for 100 BB',
      isCorrect: false,
      preferredLabel: 'Call 2.5 BB',
      betterAnswerLabel: 'Call 2.5 BB',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Going all-in risks the whole stack.',
      feedbackReason:
          'Under the stated model, the weaker aces fold. The larger stack lets you lose more when your ace is outkicked.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Same hand, deeper caution.',
      body:
          'Deep stacks give more room, but they also punish dominated and fragile hands more because more money can keep flowing later.',
      focusLabels: <String>['100 BB', 'More room', 'More risk'],
    ),
  ],
);

final _w7DepthShiftRecapRunner = _w7DepthShiftIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w7_depth_shift_recap',
  caption: 'Lesson learned: stack depth changes hand value and plan.',
  hint: 'Short stacks simplify. Deep stacks ask for more caution.',
  question: 'What changes when stack depth changes?',
  feedbackTitle: 'Depth takeaway.',
  feedbackReason:
      'A shorter stack limits future losses, but also limits what you can win when a small pair makes a set or suited connectors make a big hand.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Same hand, new plan.',
      body:
          'Do not memorize one answer for every hand. Depth changes what the hand can safely do.',
      focusLabels: <String>['Short stack', 'Deep stack', 'Risk', 'Commitment'],
    ),
  ],
  table: _act0BoardLessonTableV1(
    heroCards: _act0LessonCardsV1('As Js'),
    boardCards: _act0LessonCardsV1('Jh 9c 3d'),
    centerLabel: 'Read the stack depth',
    heroBehindBb: 78,
    bbBehindBb: 36,
    openBb: 3,
  ),
);

final _w7SprIntroRunner = _w7EffectiveStackIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w7_spr_intro',
  lessonTitle: 'Room or commitment',
  caption: 'SPR tells you how much room is left after the flop.',
  hint:
      'Low SPR means less money is left relative to the pot. Check your hand and the price before going all-in.',
  question: 'What does low SPR usually mean?',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Divide the smaller stack by the pot.',
      body:
          'SPR is the stack-to-pot ratio: effective stack divided by the current pot. '
          'Here the smaller stack is 20 BB and the pot is 5 BB, so the SPR is 4.',
      focusLabels: <String>['Low SPR', 'Commitment', 'High SPR', 'Room'],
    ),
  ],
  table: _act0BoardLessonTableV1(
    heroCards: _act0LessonCardsV1('Ah Tc'),
    boardCards: _act0LessonCardsV1('Ac 8s 3d'),
    centerLabel: 'Stack and pot',
    heroBehindBb: 20,
    bbBehindBb: 35,
    openBb: 2.25,
  ),
  feedbackTitle: 'Compare stack and pot.',
  feedbackReason:
      'Compare the smaller remaining stack with the pot to see how much could still go in.',
);

final _w7LowSprCommitRunner = _w7SprIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w7_low_spr_commit',
  caption: 'SPR is 2 on the flop and you hold top pair.',
  teachingSteps: const <Act0TeachingStepV1>[],
  hint: 'Little room is left.',
  question: 'What does low SPR usually tell you?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'commit',
      label: 'One bet can commit the hand',
      isCorrect: true,
      preferredLabel: 'One bet can commit the hand',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Excellent spot.',
      feedbackReason:
          'At SPR 2 there are two pots left in the effective stack. A large bet can put much of it at risk, but whether to commit depends on your hand and the price.',
    ),
    Act0RunnerOptionV1(
      id: 'float',
      label: 'Plenty of chips left for later bets',
      isCorrect: false,
      preferredLabel: 'One bet can commit the hand',
      betterAnswerLabel: 'One bet can commit the hand',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'That is the opposite of low SPR. Low SPR reduces room and speeds up commitment.',
    ),
    Act0RunnerOptionV1(
      id: 'same',
      label: 'It plays the same as SPR 8',
      isCorrect: false,
      preferredLabel: 'One bet can commit the hand',
      betterAnswerLabel: 'One bet can commit the hand',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'SPR changes the hand structure. SPR 2 is a much more commit-heavy situation than SPR 8.',
    ),
  ],
  table: _act0BoardLessonTableV1(
    heroCards: _act0LessonCardsV1('Kd Qc'),
    boardCards: _act0LessonCardsV1('Kh 7d 3s'),
    centerLabel: 'Stack and pot',
    heroBehindBb: 10,
    bbBehindBb: 12,
    openBb: 2.25,
  ),
);

final _w7HighSprRoomRunner = _w7SprIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w7_high_spr_room',
  caption: 'SPR is 8 on the flop.',
  teachingSteps: const <Act0TeachingStepV1>[],
  hint: 'A lot of stack is still behind.',
  question: 'What does high SPR usually give you?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'room',
      label: 'More options for later bets',
      isCorrect: true,
      preferredLabel: 'More options for later bets',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Spot on.',
      feedbackReason:
          'High SPR leaves more stack behind, so you still have room to bet, check, fold, or plan later streets.',
    ),
    Act0RunnerOptionV1(
      id: 'force',
      label: 'Immediate commitment',
      isCorrect: false,
      preferredLabel: 'More options for later bets',
      betterAnswerLabel: 'More options for later bets',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'Immediate commitment is a low-SPR feature. High SPR creates more room, not less.',
    ),
    Act0RunnerOptionV1(
      id: 'none',
      label: 'No difference from preflop',
      isCorrect: false,
      preferredLabel: 'More options for later bets',
      betterAnswerLabel: 'More options for later bets',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'SPR changes how postflop decisions feel. High SPR leaves more chips for later bets on the same streets.',
    ),
  ],
  table: _act0BoardLessonTableV1(
    heroCards: _act0LessonCardsV1('As 9c'),
    boardCards: _act0LessonCardsV1('Ad 7h 2s'),
    centerLabel: 'Stack and pot',
    heroBehindBb: 40,
    bbBehindBb: 42,
    openBb: 2.25,
  ),
);

final _w7SprFourRunner = _w7SprIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w7_spr4_middle',
  caption: 'SPR is 4 with one pair and some stack still behind.',
  teachingSteps: const <Act0TeachingStepV1>[],
  hint: 'Middle SPR is neither pure all-in nor huge freedom.',
  question: 'What does SPR 4 usually feel like?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'middle_spr',
      label: 'Middle ground: some room, some commitment',
      isCorrect: true,
      preferredLabel: 'Middle ground: some room, some commitment',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Clean execution.',
      feedbackReason:
          'SPR 4 often means you still have choices, but commitment pressure is already starting to matter.',
    ),
    Act0RunnerOptionV1(
      id: 'auto_commit',
      label: 'Automatic commitment right now',
      isCorrect: false,
      preferredLabel: 'Middle ground: some room, some commitment',
      betterAnswerLabel: 'Middle ground: some room, some commitment',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too shallow.',
      feedbackReason:
          'That is more like very low SPR. SPR 4 is tighter than SPR 8, but not auto-commit by default.',
    ),
    Act0RunnerOptionV1(
      id: 'same_as_eight',
      label: 'The same as SPR 8',
      isCorrect: false,
      preferredLabel: 'Middle ground: some room, some commitment',
      betterAnswerLabel: 'Middle ground: some room, some commitment',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too loose.',
      feedbackReason:
          'At SPR 4, the smaller stack is four times the pot. At SPR 8, it is eight times the pot, leaving more chips for later bets.',
    ),
  ],
  table: _act0BoardLessonTableV1(
    heroCards: _act0LessonCardsV1('Jd 9d'),
    boardCards: _act0LessonCardsV1('Js 8c 3h'),
    centerLabel: 'Stack and pot',
    heroBehindBb: 20,
    bbBehindBb: 27,
    openBb: 2.25,
  ),
);

final _w7TopPairSprTwoRunner = _w7SprIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w7_top_pair_spr2_transfer',
  caption: 'Real table. K-7-2 rainbow flop. You have K-Q and SPR is 2.',
  question: 'What does low SPR add to this top-pair spot?',
  table: _act0BoardLessonTableV1(
    heroCards: _act0LessonCardsV1('Kd Qc'),
    boardCards: _act0LessonCardsV1('Kc 7d 2s'),
    centerLabel: 'Stack and pot',
    heroBehindBb: 16,
    bbBehindBb: 18,
    openBb: 3.75,
  ),
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'faster_commitment',
      label: 'Less room, more commitment pressure',
      isCorrect: true,
      preferredLabel: 'Less room, more commitment pressure',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Clean SPR contrast.',
      feedbackReason:
          'That is the low-SPR lesson in action. Top pair still needs board discipline, but SPR 2 leaves much less room and makes one bet push the hand closer to commitment.',
    ),
    Act0RunnerOptionV1(
      id: 'same_as_spr8',
      label: 'Treat it like SPR 8',
      isCorrect: false,
      preferredLabel: 'Less room, more commitment pressure',
      betterAnswerLabel: 'Less room, more commitment pressure',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Depth changed the job.',
      feedbackReason:
          'The board and hand stayed the same, but SPR did not. At SPR 2, low room changes the pressure and makes the hand much closer to commitment than at SPR 8.',
    ),
    Act0RunnerOptionV1(
      id: 'ignore_stack_pressure',
      label: 'Top pair matters, so stack pressure can wait',
      isCorrect: false,
      preferredLabel: 'Less room, more commitment pressure',
      betterAnswerLabel: 'Less room, more commitment pressure',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Only part of the picture.',
      feedbackReason:
          'Top pair is the made hand, but low SPR is the pressure clue. Name the reduced room first, then judge how willing the hand is to keep money flowing.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Same top pair, tighter room.',
      body:
          'Low SPR keeps less room behind, so commitment pressure becomes part of the first read instead of a later warning.',
      focusLabels: <String>['Top pair', 'SPR 2', 'Less room', 'Commitment'],
    ),
  ],
  hint: 'Compare the smaller stack with the pot. How much is left to bet?',
);

final _w7TopPairSprEightRunner = _w7SprIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w7_top_pair_spr8_transfer',
  caption: 'Real table. K-7-2 rainbow flop. You have K-Q and SPR is 8.',
  hint: 'Top pair is good, but deep room keeps future-street risk alive.',
  question: 'What does stack depth add to this top-pair spot?',
  table: _act0BoardLessonTableV1(
    heroCards: _act0LessonCardsV1('Kh Qd'),
    boardCards: _act0LessonCardsV1('Ks 7c 2h'),
    centerLabel: 'Stack and pot',
    heroBehindBb: 64,
    bbBehindBb: 66,
    openBb: 3.75,
  ),
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'room_and_risk',
      label: 'More room, more risk',
      isCorrect: true,
      preferredLabel: 'More room, more risk',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Sharp stack read.',
      feedbackReason:
          'Top pair looks strong, but SPR 8 means a lot of stack is still behind. Deep room gives flexibility, yet it also creates more chances to overplay a fragile made hand.',
    ),
    Act0RunnerOptionV1(
      id: 'same_as_spr2',
      label: 'Treat it like SPR 2',
      isCorrect: false,
      preferredLabel: 'More room, more risk',
      betterAnswerLabel: 'More room, more risk',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Tempting shortcut.',
      feedbackReason:
          'Top pair makes this answer tempting, but SPR changes the structure. At SPR 8, one bet does not commit the hand the way SPR 2 can.',
    ),
    Act0RunnerOptionV1(
      id: 'stack_irrelevant',
      label: 'Ignore the depth cue',
      isCorrect: false,
      preferredLabel: 'More room, more risk',
      betterAnswerLabel: 'More room, more risk',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Only part of the picture.',
      feedbackReason:
          'Board texture still matters, but stack depth changes how much that one-pair hand can safely absorb across later streets.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Top pair is not the same at every SPR.',
      body:
          'Read hand, board, and price first, then ask how much stack is still behind. High SPR keeps more room and more ways to make a costly mistake.',
      focusLabels: <String>['Top pair', 'SPR 8', 'Future risk'],
    ),
  ],
);

final _w7SprRecapRunner = _w7SprIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w7_spr_recap',
  caption: 'Lesson learned: low SPR pushes commitment, high SPR keeps room.',
  hint: 'Do not treat every flop the same when stack room changes.',
  question: 'What does SPR help you feel?',
  feedbackTitle: 'SPR takeaway.',
  feedbackReason:
      'SPR tells you whether the hand is room-heavy or commitment-heavy. That changes what a normal action looks like.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Room matters.',
      body:
          'Low SPR speeds up commitment. High SPR keeps later-street choices alive.',
      focusLabels: <String>['Low SPR', 'Commitment', 'High SPR', 'Room'],
    ),
  ],
  table: _act0BoardLessonTableV1(
    heroCards: _act0LessonCardsV1('Ad Tc'),
    boardCards: _act0LessonCardsV1('Ac 7s 4c'),
    centerLabel: 'Stack and pot',
    heroBehindBb: 24,
    bbBehindBb: 30,
    openBb: 3.75,
  ),
);

const _w7FullRingComparisonV1 =
    'This table is 6-max. At a nine-player full-ring table, '
    'UTG+1, UTG+2, and LJ also act after UTG.';

final _w7FormatPressureIntroRunner = _w7EffectiveStackIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w7_format_intro',
  lessonTitle: '6-max vs full ring',
  caption: _w7FullRingComparisonV1,
  hint:
      'Fewer players behind means less chance someone wakes up with a premium hand.',
  question: 'Why does 6-max usually widen ranges?',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Fewer players behind.',
      body:
          'A full-ring table seats nine players. From UTG, eight players still act behind you, compared with five at a six-player table. '
          'With more players to act, open fewer hands.',
      focusLabels: <String>['6-max', 'Full ring', 'Fewer players behind'],
    ),
  ],
  table: _act0UnopenedLessonTableV1(
    heroCards: _act0LessonCardsV1('Kd Jc'),
    centerLabel: 'Players behind',
  ),
  feedbackTitle: 'Count the players behind.',
  feedbackReason:
      'From first position, a nine-handed table leaves more players to act than a six-handed table.',
);

final _w7SixMaxWiderRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w7_6max_wider',
  caption:
      "Practice rule for A-J offsuit: raise to 2.5 BB with at most five players still to act. Otherwise fold.",
  hint: 'Check the given limits before choosing.',
  question: "You are first to act. What fits this table?",
  feedbackTitle: "Count the players behind.",
  feedbackReason:
      "The table has six players, including you. The other five remain, so the rule allows the 2.5 BB raise.",
  table: _act0UnopenedLessonTableV1(
    heroCards: _act0LessonCardsV1('Ac Jd'),
    centerLabel: 'Read the seats',
  ),
  teachingSteps: const [],
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: '6max',
      label: "Raise to 2.5 BB",
      isCorrect: true,
      preferredLabel: "Raise to 2.5 BB",
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: "Five players are left to act.",
      feedbackReason:
          "The table has six players, including you. The other five remain, so the rule allows the 2.5 BB raise.",
    ),
    Act0RunnerOptionV1(
      id: 'fullring',
      label: "Fold",
      isCorrect: false,
      preferredLabel: "Raise to 2.5 BB",
      betterAnswerLabel: "Raise to 2.5 BB",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "The rule allows a raise here.",
      feedbackReason:
          "Count the players besides you. There are five, so A-J offsuit can open in this example.",
    ),
    Act0RunnerOptionV1(
      id: 'same',
      label: "Raise to 8 BB",
      isCorrect: false,
      preferredLabel: "Raise to 2.5 BB",
      betterAnswerLabel: "Raise to 2.5 BB",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Use the size in the rule.",
      feedbackReason:
          "A raise fits the five players behind. In this example, the given size is 2.5 BB.",
    ),
  ],
);

final _w7FullRingTighterRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w7_fullring_tighter',
  caption:
      "Add UTG+1, UTG+2 and LJ after you. Open A-J offsuit for 2.5 BB with at most five to act. Otherwise fold.",
  hint: 'Check the given limits before choosing.',
  question: "What fits the nine-player version of this hand?",
  feedbackTitle: "More players can act after you.",
  feedbackReason:
      "Five seats are visible after yours. Add UTG+1, UTG+2 and LJ. With eight players left, the named rule says to fold.",
  table: _act0UnopenedLessonTableV1(
    heroCards: _act0LessonCardsV1('Ah Js'),
    centerLabel: 'Read the seats',
  ),
  teachingSteps: const [],
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'tighter',
      label: "Fold",
      isCorrect: true,
      preferredLabel: "Fold",
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: "Eight players are left to act.",
      feedbackReason:
          "Five seats are visible after yours. Add UTG+1, UTG+2 and LJ. With eight players left, the named rule says to fold.",
    ),
    Act0RunnerOptionV1(
      id: 'wider',
      label: "Raise to 2.5 BB",
      isCorrect: false,
      preferredLabel: "Fold",
      betterAnswerLabel: "Fold",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Count the three extra players.",
      feedbackReason:
          "A 2.5 BB raise fit the six-player example. With eight players left, the rule says to fold instead.",
    ),
    Act0RunnerOptionV1(
      id: 'depth',
      label: "Raise to 8 BB",
      isCorrect: false,
      preferredLabel: "Fold",
      betterAnswerLabel: "Fold",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "The number of players still matters.",
      feedbackReason:
          "A different bet size does not change how many players are left to act. Use the fold in the stated model.",
    ),
  ],
);

final _w7FormatTableNoticeRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w7_format_table_notice',
  caption:
      "BB checks. Pick a bet that leaves both players at least 9 BB if it is called.",
  hint: 'Check the given limits before choosing.',
  question: "Which bet fits that plan?",
  feedbackTitle: "Track what remains after a call.",
  feedbackReason:
      "With 18 BB and 42 BB behind, a 6 BB bet and call leave 12 BB and 36 BB. Both are above 9 BB.",
  table: _act0BoardLessonTableV1(
    heroCards: _act0LessonCardsV1('Ad Td'),
    boardCards: _act0LessonCardsV1('Ac 8h 4s'),
    centerLabel: 'Read the stacks',
    heroBehindBb: 18,
    bbBehindBb: 42,
    openBb: 3.75,
    facingBb: 0,
  ),
  teachingSteps: const [],
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'open_same',
      label: "Bet 10 BB",
      isCorrect: false,
      preferredLabel: "Bet 6 BB",
      betterAnswerLabel: "Bet 6 BB",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "The shorter stack would have 8 BB.",
      feedbackReason:
          "After matching 10 BB, your 18 BB stack would have 8 BB left. That is below the target.",
    ),
    Act0RunnerOptionV1(
      id: 'tighten_early',
      label: "Bet 6 BB",
      isCorrect: true,
      preferredLabel: "Bet 6 BB",
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: "Both players keep enough chips.",
      feedbackReason:
          "With 18 BB and 42 BB behind, a 6 BB bet and call leave 12 BB and 36 BB. Both are above 9 BB.",
    ),
    Act0RunnerOptionV1(
      id: 'depth_only',
      label: "Bet 12 BB",
      isCorrect: false,
      preferredLabel: "Bet 6 BB",
      betterAnswerLabel: "Bet 6 BB",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Follow the smaller stack.",
      feedbackReason:
          "A 12 BB bet can be called, but leaves only 6 BB in the shorter stack.",
    ),
  ],
);

final _w7FormatRecapRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w7_format_recap',
  caption: _w7FullRingComparisonV1,
  hint: 'Format changes pressure before the cards even hit the flop.',
  question: 'Why does format change opening pressure?',
  feedbackTitle: 'Format takeaway.',
  feedbackReason:
      'Format changes how many players still act behind you. Fewer players behind usually widen ranges. More players behind tighten them.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Format shapes pressure.',
      body:
          'The hand is the same, but table format changes how often someone behind wakes up with strength.',
      focusLabels: <String>['6-max', 'Full ring', 'Players behind'],
    ),
  ],
  table: _act0UnopenedLessonTableV1(
    heroCards: _act0LessonCardsV1('Kc Td'),
    centerLabel: 'Players behind',
  ),
);

final _world7StackCheckpointRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w7_stack_checkpoint',
  caption: "BB checks on the flop. Read both stacks and the current pot.",
  hint: 'Check the given limits before choosing.',
  question: "What is the SPR here?",
  feedbackTitle: "Calculate the stack-to-pot ratio.",
  feedbackReason:
      "The effective stack is 32 BB and the pot is 8 BB. The SPR is 4. In World 9 you will also consider the cost of losing your tournament stack.",
  table: _act0BoardLessonTableV1(
    heroCards: _act0LessonCardsV1('Qd Js'),
    boardCards: _act0LessonCardsV1('Jc 9h 3s'),
    centerLabel: 'Read the stacks',
    heroBehindBb: 32,
    bbBehindBb: 43,
    openBb: 3.75,
    facingBb: 0,
  ),
  teachingSteps: const [],
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'range_only',
      label: "About 5.4",
      isCorrect: false,
      preferredLabel: "4",
      betterAnswerLabel: "4",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Start with the smaller stack.",
      feedbackReason:
          "43 divided by 8 uses the larger stack. The 32 BB stack sets how much both players can match.",
    ),
    Act0RunnerOptionV1(
      id: 'range_plus_depth',
      label: "4",
      isCorrect: true,
      preferredLabel: "4",
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: "32 divided by 8 is 4.",
      feedbackReason:
          "The effective stack is 32 BB and the pot is 8 BB. The SPR is 4. In World 9 you will also consider the cost of losing your tournament stack.",
    ),
    Act0RunnerOptionV1(
      id: 'chips_only',
      label: "32",
      isCorrect: false,
      preferredLabel: "4",
      betterAnswerLabel: "4",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Divide by the pot.",
      feedbackReason:
          "32 BB is the effective stack. Divide it by the 8 BB pot to get an SPR of 4.",
    ),
  ],
);

final _w9ExampleTableBase = _readBoardRunner.table.copyWith(
  boardCards: _act0LessonCardsV1('Kc 7d 2s'),
  potLabel: 'Pot 5 BB',
  centerLabel: 'Combo count',
  highlightedCardIds: const ['board_0', 'board_1', 'board_2'],
);

final _w9SurvivalIntroRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w9_survival_intro',
  lessonTitle: 'Chips are not life',
  lessonSubtitle: 'Tournament Pressure',
  caption: 'Tournament chips carry survival value, not only chip EV.',
  hint: 'When you bust, your tournament run ends.',
  question: 'What makes tournament chips different from cash chips?',
  feedbackTitle: 'Survival foundation.',
  feedbackReason:
      'Tournament pressure means survival has value. Losing all chips ends the run, so not every thin chip-EV spot is equal.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Life has value.',
      body:
          'In cash you can reload. In tournaments, stack loss can end your whole run. That creates survival pressure before payouts and near the bubble.',
      focusLabels: <String>['Tournament life', 'Survival', 'Bubble'],
    ),
  ],
  table: _act0HypotheticalConceptTableV1(_w9ExampleTableBase),
);

final _w9CashVsTournamentRunner = _w9SurvivalIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w9_cash_vs_tournament',
  caption: 'You face a thin all-in edge with 20 BB.',
  teachingSteps: const <Act0TeachingStepV1>[],
  hint: 'Compare cash-game reload logic with tournament survival.',
  question: 'Which frame should be stronger in a tournament?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'survival',
      label: 'Survival pressure matters more',
      isCorrect: true,
      preferredLabel: 'Survival pressure matters more',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Well done.',
      feedbackReason:
          'Tournament chips are tied to staying alive. You still seek EV, but survival pressure changes which thin spots are worth taking.',
    ),
    Act0RunnerOptionV1(
      id: 'same_cash',
      label: 'Play it exactly like cash',
      isCorrect: false,
      preferredLabel: 'Survival pressure matters more',
      betterAnswerLabel: 'Survival pressure matters more',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'With 20 BB facing a thin all-in edge, using cash-game standards overlooks the cost of elimination in a tournament.',
    ),
    Act0RunnerOptionV1(
      id: 'fold_everything',
      label: 'Fold even premium hands until payouts begin',
      isCorrect: false,
      preferredLabel: 'Survival pressure matters more',
      betterAnswerLabel: 'Survival pressure matters more',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Playable caution.',
      feedbackReason:
          'At 20 BB, tournament life can make a thin all-in edge worth passing up. Folding even premium hands until payouts begin also gives up the much larger edges those hands can offer.',
    ),
  ],
);

final _w9ShortStackSurvivalRunner = _w9SurvivalIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w9_short_stack_survival',
  caption: 'You have 9 BB with blinds about to hit.',
  teachingSteps: const <Act0TeachingStepV1>[],
  hint: 'Very short stacks cannot wait forever.',
  question: 'What is usually the sharper plan?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'take_spot',
      label: 'Take a reasonable all-in spot, first in or over a raise',
      isCorrect: true,
      preferredLabel: 'Take a reasonable all-in spot, first in or over a raise',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Excellent spot.',
      feedbackReason:
          'At very low stack depth, survival comes from acting before you get blinded out. Controlled urgency beats passive waiting.',
    ),
    Act0RunnerOptionV1(
      id: 'wait_premium',
      label: 'Wait for AA or KK before entering a pot',
      isCorrect: false,
      preferredLabel: 'Take a reasonable all-in spot, first in or over a raise',
      betterAnswerLabel:
          'Take a reasonable all-in spot, first in or over a raise',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Too tight here.',
      feedbackReason:
          'At 9 BB with blinds about to hit, waiting for AA or KK can cost you a chance to go all-in while your stack can still make opponents fold.',
    ),
    Act0RunnerOptionV1(
      id: 'open_fold',
      label: 'Open small and fold to pressure',
      isCorrect: false,
      preferredLabel: 'Take a reasonable all-in spot, first in or over a raise',
      betterAnswerLabel:
          'Take a reasonable all-in spot, first in or over a raise',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'At 9 BB with blinds about to hit, automatically folding after a small open costs chips and leaves you with less leverage on your next all-in.',
    ),
  ],
);

final _w9SurvivalTradeoffRunner = _w9SurvivalIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w9_survival_stack_tradeoff',
  caption: 'Cash table can reload. Tournament table cannot.',
  teachingSteps: const <Act0TeachingStepV1>[],
  hint: 'The same thin edge does not carry the same downside.',
  question: 'Which table should pass more thin stack-off spots?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'tournament_table',
      label: 'Tournament table',
      isCorrect: true,
      preferredLabel: 'Tournament table',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Spot on.',
      feedbackReason:
          'Tournament life adds elimination risk. That makes thin stack-offs more expensive than in reloadable cash spots.',
    ),
    Act0RunnerOptionV1(
      id: 'cash_table',
      label: 'Cash table',
      isCorrect: false,
      preferredLabel: 'Tournament table',
      betterAnswerLabel: 'Tournament table',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'Passing thin edges at a reloadable cash table gives up profitable chip-EV spots where busting does not end your tournament life.',
    ),
    Act0RunnerOptionV1(
      id: 'same_both',
      label: 'Both should pass equally',
      isCorrect: false,
      preferredLabel: 'Tournament table',
      betterAnswerLabel: 'Tournament table',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Elimination changes the downside.',
      feedbackReason:
          'On a tournament table, treating both formats equally ignores elimination cost and risks tournament survival on thin stack-offs.',
    ),
  ],
);

final _w9SurvivalRecapRunner = _w9SurvivalIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w9_survival_recap',
  caption: 'Lesson learned: tournament chips include survival value.',
  teachingSteps: const <Act0TeachingStepV1>[],
  hint: 'Life pressure changes which thin spots are worth taking.',
  question: 'What is the key survival takeaway?',
  feedbackTitle: 'Survival takeaway.',
  feedbackReason:
      'Tournament pressure does not remove aggression. It asks for cleaner risk selection because busting ends your run.',
);

final _w9MRatioIntroRunner = _w9SurvivalIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w9_m_ratio_intro',
  lessonTitle: 'M-ratio zones',
  caption: 'M-ratio gives a quick urgency signal for tournament decisions.',
  hint: 'Think in simple zones first, not formulas.',
  question: 'What does M-ratio help you read?',
  feedbackTitle: 'Zone foundation.',
  feedbackReason:
      'M-ratio is a practical urgency signal. Lower zones mean less time and more pressure to act.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Urgency by zone.',
      body:
          'Green zone has room. Yellow zone needs planning. Red zone demands action soon. Use this to avoid both panic and passivity.',
      focusLabels: <String>['M-ratio', 'Green', 'Yellow', 'Red'],
    ),
  ],
);

final _w9MZoneRedRunner = _w9MRatioIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w9_m_ratio_red_zone',
  caption: 'Your M-ratio is in the red zone.',
  teachingSteps: const <Act0TeachingStepV1>[],
  hint: 'Low zone means blinds are hurting fast.',
  question: 'What is the sharper mindset?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'urgent',
      label: 'Use controlled urgency',
      isCorrect: true,
      preferredLabel: 'Use controlled urgency',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Clean execution.',
      feedbackReason:
          'Red-zone stacks cannot drift. Tournament pressure rewards timely commitment when edges appear.',
    ),
    Act0RunnerOptionV1(
      id: 'wait',
      label: 'Wait for a big pocket pair like AA or KK',
      isCorrect: false,
      preferredLabel: 'Use controlled urgency',
      betterAnswerLabel: 'Use controlled urgency',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Too narrow.',
      feedbackReason:
          'Waiting for AA or KK can cost you the chance to win the blinds uncontested while your stack can still threaten opponents. Look for a playable hand and a good position to act sooner.',
    ),
    Act0RunnerOptionV1(
      id: 'flat_call',
      label: 'Flat-call wide and see flops',
      isCorrect: false,
      preferredLabel: 'Use controlled urgency',
      betterAnswerLabel: 'Use controlled urgency',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'In the red zone, frequent flat-calls quickly commit a large share of your stack. Calling gives the raiser no chance to fold preflop.',
    ),
  ],
);

final _w9MZoneGreenRunner = _w9MRatioIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w9_m_ratio_green_zone',
  caption: 'Your M-ratio is in the green zone.',
  teachingSteps: const <Act0TeachingStepV1>[],
  hint: 'You still have room to pick spots.',
  question: 'What usually improves in green zone?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'patience',
      label: 'Patience and table selection',
      isCorrect: true,
      preferredLabel: 'Patience and table selection',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Green zone gives room.',
      feedbackReason:
          'With room in green zone, you can pass thin spots and choose cleaner pressure lines.',
    ),
    Act0RunnerOptionV1(
      id: 'panic',
      label: 'Force all-ins quickly',
      isCorrect: false,
      preferredLabel: 'Patience and table selection',
      betterAnswerLabel: 'Patience and table selection',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not needed.',
      feedbackReason:
          'With your M-ratio in the green zone, forcing early all-ins risks a healthy stack unnecessarily when you still have room to pick better spots.',
    ),
    Act0RunnerOptionV1(
      id: 'never_risk',
      label: 'Avoid pressure spots entirely',
      isCorrect: false,
      preferredLabel: 'Patience and table selection',
      betterAnswerLabel: 'Patience and table selection',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Too passive.',
      feedbackReason:
          'In the green zone M-ratio spot, avoiding pressure spots entirely gives up profitable steals and lets your stack drift downward.',
    ),
  ],
);

final _w9MZoneYellowRunner = _w9MRatioIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w9_m_ratio_yellow_zone',
  caption: 'Your M-ratio is in the yellow zone.',
  teachingSteps: const <Act0TeachingStepV1>[],
  hint: 'Yellow zone asks for planning before panic.',
  question: 'What usually becomes sharper in yellow zone?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'prepare_windows',
      label: 'Prepare action windows before red-zone panic',
      isCorrect: true,
      preferredLabel: 'Prepare action windows before red-zone panic',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Sharp read.',
      feedbackReason:
          'Yellow zone is not emergency mode yet, but it is no longer pure patience. Good tournament play starts planning cleaner all-in and steal windows here.',
    ),
    Act0RunnerOptionV1(
      id: 'ignore',
      label: 'Ignore urgency until the red zone',
      isCorrect: false,
      preferredLabel: 'Prepare action windows before red-zone panic',
      betterAnswerLabel: 'Prepare action windows before red-zone panic',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'When your M-ratio is in the yellow zone, ignoring urgency until the red zone loses fold pressure and forces desperate decisions later.',
    ),
    Act0RunnerOptionV1(
      id: 'panic_now',
      label: 'Go all-in with the next playable hand right away',
      isCorrect: false,
      preferredLabel: 'Prepare action windows before red-zone panic',
      betterAnswerLabel: 'Prepare action windows before red-zone panic',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Too rushed.',
      feedbackReason:
          'With an M-ratio in the yellow zone, going all-in with your next playable hand can risk your tournament life before position and the action give you a good opening.',
    ),
  ],
);

final _w9MTableWindowTransferRunner = _w9MRatioIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w9_m_ratio_table_window_transfer',
  caption: 'Real table. You are BTN with A-J offsuit at 12 BB in yellow zone.',
  hint:
      'This is not red-zone panic yet, but the stack should not drift. Read what yellow-zone urgency changes first.',
  question: 'What is the cleaner first zone adjustment here?',
  table: _w9ExampleTableBase.copyWith(
    heroCards: _heroAjCards,
    streetLabel: 'Preflop',
    boardCards: const <Act0CardStateV1>[],
    highlightedCardIds: const ['hero_0', 'hero_1'],
    potLabel: 'Pot 1.5 BB',
    toCallLabel: '',
    centerLabel: 'BTN, 12 BB, yellow zone',
    actionTrail: const <Act0ActionTrailItemV1>[
      Act0ActionTrailItemV1(label: 'Folded to BTN'),
    ],
  ),
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'prepare_now',
      label: 'Plan a practical action window now',
      isCorrect: true,
      preferredLabel: 'Plan a practical action window now',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Sharp live read.',
      feedbackReason:
          'That is the live-table yellow-zone adjustment. You still have a little room, but urgency is real enough that you should prepare an action window before the stack slips into red zone.',
    ),
    Act0RunnerOptionV1(
      id: 'wait_for_red',
      label: 'Wait until red zone before changing anything',
      isCorrect: false,
      preferredLabel: 'Plan a practical action window now',
      betterAnswerLabel: 'Plan a practical action window now',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too late.',
      feedbackReason:
          'With 12 BB in the stated yellow zone, waiting for the red zone gives the blinds more time to shrink your stack. Plan ahead while an all-in can still put opponents under pressure.',
    ),
    Act0RunnerOptionV1(
      id: 'panic_now',
      label: 'Treat yellow zone like instant all-in panic',
      isCorrect: false,
      preferredLabel: 'Plan a practical action window now',
      betterAnswerLabel: 'Plan a practical action window now',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Right idea, wrong speed.',
      feedbackReason:
          'The spot gives you 12 BB and time to plan. Going all-in before the action gives you a suitable opening can put your tournament life at risk too early.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Yellow zone starts the countdown.',
      body:
          'This is the changed frame: same M-ratio idea, live table now. Yellow zone is not freeze mode and not red-zone panic. It is the spot where urgency becomes actionable before the stack gets desperate.',
      focusLabels: <String>['Yellow zone', '12 BB', 'Urgency', 'Plan early'],
    ),
  ],
);

final _w9MRatioRecapRunner = _w9MRatioIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w9_m_ratio_recap',
  caption: 'Lesson learned: M-ratio zones map urgency.',
  teachingSteps: const <Act0TeachingStepV1>[],
  hint: 'Green keeps room. Red needs action soon.',
  question: 'What is the M-ratio takeaway?',
  feedbackTitle: 'M-ratio takeaway.',
  feedbackReason:
      'Use M-ratio as a quick pressure map. The lower the zone, the less freedom you have to wait.',
);

final _w9BubblePressureIntroRunner = _w9SurvivalIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w9_bubble_intro',
  lessonTitle: 'Bubble risk premium',
  caption:
      'Near the bubble, losing chips can hurt more than winning chips helps.',
  hint: 'Medium stacks often feel this pressure most.',
  question: 'What is risk premium in simple terms?',
  feedbackTitle: 'Bubble foundation.',
  feedbackReason:
      'Risk premium means you need extra hand strength before risking tournament life near payout pressure.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Bubble pressure shifts ranges.',
      body:
          'Medium stacks tighten because busting hurts. Big stacks can apply leverage. Short stacks still need practical spots to survive.',
      focusLabels: <String>[
        'Bubble',
        'Risk premium',
        'Medium stack',
        'Leverage',
      ],
    ),
  ],
);

final _w9MediumStackTightenRunner = _w9BubblePressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w9_medium_stack_tighten',
  caption: 'You are a medium stack two spots from the money.',
  teachingSteps: const <Act0TeachingStepV1>[],
  hint: 'Bust risk is expensive here.',
  question: 'What is usually the sharper adjustment?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'tighten_calls',
      label: 'Tighten marginal calls',
      isCorrect: true,
      preferredLabel: 'Tighten marginal calls',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Strong choice.',
      feedbackReason:
          'Risk premium near the bubble means medium stacks should avoid thin call-offs and protect tournament life.',
    ),
    Act0RunnerOptionV1(
      id: 'call_wide',
      label: 'Call off as wide as chip EV says',
      isCorrect: false,
      preferredLabel: 'Tighten marginal calls',
      betterAnswerLabel: 'Tighten marginal calls',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'With a medium stack two spots from the money, calling off as wide as chip EV risks tournament elimination right before payouts begin.',
    ),
    Act0RunnerOptionV1(
      id: 'fold_all',
      label: 'Fold everything until paid',
      isCorrect: false,
      preferredLabel: 'Tighten marginal calls',
      betterAnswerLabel: 'Tighten marginal calls',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Playable caution.',
      feedbackReason:
          'Two spots from the money, folding until payouts begin can cost a medium stack profitable steals and lets the blinds erode its stack.',
    ),
  ],
);

final _w9BigStackLeverageRunner = _w9BubblePressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w9_big_stack_leverage',
  caption: 'You cover both blinds near the bubble.',
  teachingSteps: const <Act0TeachingStepV1>[],
  hint: 'Leverage works because others face elimination risk.',
  question: 'What usually improves for the big stack?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'apply_pressure',
      label: 'Apply selective open pressure',
      isCorrect: true,
      preferredLabel: 'Apply selective open pressure',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Solid understanding.',
      feedbackReason:
          'Big stacks can leverage bubble pressure because medium stacks cannot call as freely.',
    ),
    Act0RunnerOptionV1(
      id: 'freeze',
      label: 'Avoid stealing to protect stack',
      isCorrect: false,
      preferredLabel: 'Apply selective open pressure',
      betterAnswerLabel: 'Apply selective open pressure',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Too passive.',
      feedbackReason:
          'Near the bubble you cover both blinds. Passing up steals gives up the chance to win pots uncontested when those players tighten to protect their tournament lives.',
    ),
    Act0RunnerOptionV1(
      id: 'jam_any_two',
      label: 'Go all-in with wide hands without checking position',
      isCorrect: false,
      preferredLabel: 'Apply selective open pressure',
      betterAnswerLabel: 'Apply selective open pressure',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not that extreme.',
      feedbackReason:
          'With a big stack near the bubble, going all-in with a wider range without checking position risks running into strong hands from players who still have to act.',
    ),
  ],
);

final _w9BubbleShortStackRunner = _w9BubblePressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w9_bubble_short_stack',
  caption: 'You are the short stack near the bubble.',
  teachingSteps: const <Act0TeachingStepV1>[],
  hint: 'Short stacks still need survival spots, not endless folding.',
  question: 'What usually stays true for the short stack?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'still_take_spots',
      label: 'Still take practical all-in spots before blinded out',
      isCorrect: true,
      preferredLabel: 'Still take practical all-in spots before blinded out',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Well done.',
      feedbackReason:
          'Bubble pressure matters, but short stacks cannot fold forever. Survival still needs practical action windows before the stack disappears.',
    ),
    Act0RunnerOptionV1(
      id: 'fold_to_money',
      label: 'Fold playable all-in hands to try to ladder into the money',
      isCorrect: false,
      preferredLabel: 'Still take practical all-in spots before blinded out',
      betterAnswerLabel: 'Still take practical all-in spots before blinded out',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Too passive.',
      feedbackReason:
          'As the short stack near the bubble, passing up playable all-in spots lets the blinds shrink your stack and makes later all-ins easier to call.',
    ),
    Act0RunnerOptionV1(
      id: 'call_off_light',
      label: 'Call off too light',
      isCorrect: false,
      preferredLabel: 'Still take practical all-in spots before blinded out',
      betterAnswerLabel: 'Still take practical all-in spots before blinded out',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'For a short stack near the bubble, calling light risks elimination against a stronger range. Acting first in a suitable spot also gives opponents a chance to fold.',
    ),
  ],
);

final _w9BubbleTableRiskTransferRunner = _w9BubblePressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w9_bubble_table_risk_transfer',
  caption:
      'BTN holds A-J offsuit with a medium stack near the bubble. There are no antes. BB goes all-in for 18 BB, 15.5 BB more than BTN put in. BTN’s remaining stack caps the call.',
  hint:
      'Check whether losing the hand could eliminate you. That changes how much of an edge you need.',
  question: 'How should you adjust if losing to BB would eliminate you?',
  table: _act0CurrentStreetTableV1(
    _act0ExplicitFoldsV1(
      _w9ExampleTableBase.copyWith(
        heroCards: _heroAjCards,
        boardCards: const [],
        streetLabel: 'Preflop',
        activeSeatId: 'btn',
        highlightedCardIds: const ['hero_0', 'hero_1'],
        potLabel: 'Pot 21 BB',
        toCallLabel: '',
        centerLabel: 'BTN, medium stack, bubble pressure',
        handContributions: const Act0HandContributionsV1(
          throughStreet: PokerStreet.preflop,
          startingStackBbBySeat: {'bb': 18},
          entries: [
            ..._act0LessonBlinds,
            Act0ContributionV1(
              PokerStreet.preflop,
              'btn',
              Act0ContributionKindV1.wager,
              2.5,
            ),
            Act0ContributionV1(
              PokerStreet.preflop,
              'bb',
              Act0ContributionKindV1.wager,
              17,
            ),
          ],
        ),
        actionTrail: const [
          Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
          Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
          Act0ActionTrailItemV1(label: 'UTG folds'),
          Act0ActionTrailItemV1(label: 'HJ folds'),
          Act0ActionTrailItemV1(label: 'CO folds'),
          Act0ActionTrailItemV1(label: 'BTN raises to 2.5 BB'),
          Act0ActionTrailItemV1(label: 'SB folds'),
          Act0ActionTrailItemV1(label: 'BB all-in 18 BB'),
        ],
      ),
      {'utg', 'hj', 'co', 'sb'},
    ),
    bets: const {
      'btn': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.raise,
        label: 'BTN',
        amountLabel: '2.5 BB',
      ),
      'bb': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.allIn,
        label: 'BB',
        amountLabel: '18 BB',
      ),
    },
  ),
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'tighten_stackoff',
      label: 'Tighten thin stack-offs versus the covering blind',
      isCorrect: true,
      preferredLabel: 'Tighten thin stack-offs versus the covering blind',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Strong table read.',
      feedbackReason:
          'If BB can eliminate you, you may need more equity than chip odds suggest. That extra equity is the risk premium. Whether A-J should call depends on BB’s all-in range, the remaining stacks and the payouts.',
    ),
    Act0RunnerOptionV1(
      id: 'call_chip_ev',
      label: 'Call as wide as normal chip EV allows',
      isCorrect: false,
      preferredLabel: 'Tighten thin stack-offs versus the covering blind',
      betterAnswerLabel: 'Tighten thin stack-offs versus the covering blind',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too loose for bubble pressure.',
      feedbackReason:
          'With A-J offsuit facing BB’s 18 BB all-in, chip odds price the call. If losing would eliminate you near the bubble, you may need extra equity because missing the payouts has a cost.',
    ),
    Act0RunnerOptionV1(
      id: 'fold_anything_close',
      label:
          'Plan to fold borderline hands like A-J against the covering blind',
      isCorrect: false,
      preferredLabel: 'Tighten thin stack-offs versus the covering blind',
      betterAnswerLabel: 'Tighten thin stack-offs versus the covering blind',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Right caution, too extreme.',
      feedbackReason:
          'Folding A-J can be right if calling the covering blind risks elimination. Deciding in advance ignores how often BB goes all-in with worse hands and how the remaining stacks and payouts affect your risk premium.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Bubble pressure changes the stack-off bar.',
      body:
          'An all-in for 18 BB tells you the big blind’s wager. To know whether a loss would eliminate you, compare it with your own stack. Payouts and other stacks determine how much extra equity you need.',
      focusLabels: <String>[
        'Real table',
        'Bubble',
        'Medium stack',
        'Big blind leverage',
      ],
    ),
  ],
);

final _w9BubbleRecapRunner = _w9BubblePressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w9_bubble_recap',
  caption: 'Lesson learned: bubble pressure changes who can risk chips.',
  teachingSteps: const <Act0TeachingStepV1>[],
  hint: 'Medium stacks tighten more; big stacks can lean with leverage.',
  question: 'What is the bubble-pressure takeaway?',
  feedbackTitle: 'Bubble takeaway.',
  feedbackReason:
      'Risk premium is not fear. It is a context shift: medium stacks defend life, big stacks can pressure selectively.',
);

final _w9CheckpointSurvivalLineRunner = _w9BubblePressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w9_checkpoint_survival_line',
  caption: 'You are short with one orbit left.',
  hint: 'Tournament life still needs action windows.',
  question: 'What is the best pressure line?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'disciplined_urgency',
      label: 'Disciplined urgency in reasonable spots',
      isCorrect: true,
      preferredLabel: 'Disciplined urgency in reasonable spots',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Excellent spot.',
      feedbackReason:
          'Good tournament pressure play combines survival with timely action, not passive waiting.',
    ),
    Act0RunnerOptionV1(
      id: 'panic_any_two',
      label:
          'Go all-in with 7-2 offsuit over a tight early-position raise and a call',
      isCorrect: false,
      preferredLabel: 'Disciplined urgency in reasonable spots',
      betterAnswerLabel: 'Disciplined urgency in reasonable spots',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too extreme.',
      feedbackReason:
          'After a tight early raise and a call, two players have already committed chips. With 7-2 offsuit you have little chance to win when called and little leverage to make both fold. Look for a spot where you can act first.',
    ),
    Act0RunnerOptionV1(
      id: 'wait_only_aa',
      label: 'Fold until you pick up pocket aces',
      isCorrect: false,
      preferredLabel: 'Disciplined urgency in reasonable spots',
      betterAnswerLabel: 'Disciplined urgency in reasonable spots',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Too tight.',
      feedbackReason:
          'With a short stack and one orbit left, waiting for pocket aces gives up playable spots before the blinds come around and reduce your fold equity.',
    ),
  ],
);

final _w9CheckpointZoneLineRunner = _w9BubblePressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w9_checkpoint_zone_line',
  caption: 'Two players face similar hand strength in different M-ratio zones.',
  teachingSteps: const <Act0TeachingStepV1>[],
  hint: 'Zone changes urgency.',
  question: 'Which player should act sooner?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'red_zone',
      label: 'Red-zone player',
      isCorrect: true,
      preferredLabel: 'Red-zone player',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Spot on.',
      feedbackReason:
          'Lower M-ratio means fewer orbits and higher urgency. Red-zone stacks need earlier action windows.',
    ),
    Act0RunnerOptionV1(
      id: 'green_zone',
      label: 'Green-zone player',
      isCorrect: false,
      preferredLabel: 'Red-zone player',
      betterAnswerLabel: 'Red-zone player',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'With similar hands, the red-zone player has fewer orbits before the blinds erode their ability to make opponents fold. The green-zone player has more time to choose a spot.',
    ),
    Act0RunnerOptionV1(
      id: 'same_zone',
      label: 'Both should act the same way',
      isCorrect: false,
      preferredLabel: 'Red-zone player',
      betterAnswerLabel: 'Red-zone player',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'The red-zone player has fewer orbits.',
      feedbackReason:
          'Across M-ratio zones, acting the same way in both zones either bleeds a red zone short stack through passivity or risks a green zone stack too loosely.',
    ),
  ],
);

final _w9CheckpointBubbleLineRunner = _w9BubblePressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w9_checkpoint_bubble_line',
  caption: 'Near bubble: medium stack faces big-stack open.',
  teachingSteps: const <Act0TeachingStepV1>[],
  hint: 'Risk premium should influence the response.',
  question: 'What is often the cleaner medium-stack plan?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'tighten_defense',
      label: 'Tighten defend and avoid thin all-ins',
      isCorrect: true,
      preferredLabel: 'Tighten defend and avoid thin all-ins',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Clean execution.',
      feedbackReason:
          'Bubble risk premium raises the bar for medium-stack stack-offs against covering stacks.',
    ),
    Act0RunnerOptionV1(
      id: 'chip_ev_only',
      label: 'Defend as wide as normal chip EV spot',
      isCorrect: false,
      preferredLabel: 'Tighten defend and avoid thin all-ins',
      betterAnswerLabel: 'Tighten defend and avoid thin all-ins',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'Near the bubble when a medium stack faces a big stack open, defending as wide as chip EV risks tournament elimination without accounting for the payout risk premium.',
    ),
    Act0RunnerOptionV1(
      id: 'fold_everything',
      label:
          'Fold borderline hands like A-J by default against a big-stack open',
      isCorrect: false,
      preferredLabel: 'Tighten defend and avoid thin all-ins',
      betterAnswerLabel: 'Tighten defend and avoid thin all-ins',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Too passive.',
      feedbackReason:
          'Folding A-J can be right against a tight opener. A big stack can also open wide to pressure you, so read its range and your position before folding. Calling a raise and calling off your stack carry different risks.',
    ),
  ],
);

final _world9TournamentCheckpointRunner = _w9BubblePressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w9_tournament_checkpoint',
  caption:
      'Lesson learned: tournament pressure changes risk and adjustment windows.',
  hint:
      'Next you will convert pressure reads into opponent-specific player adjustments.',
  question:
      'What does tournament-pressure thinking add before player adjustment?',
  feedbackTitle: 'Tournament-pressure checkpoint.',
  feedbackReason:
      'You now read survival pressure, M-ratio urgency, and bubble risk premium. Next, apply those reads against specific player types.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Pressure before adjustment.',
      body:
          'First map pressure with stack and payout context. Then choose targeted lines based on who is overfolding, calling too wide, or avoiding risk.',
      focusLabels: <String>[
        'Survival pressure',
        'M-ratio',
        'Risk premium',
        'Player adjustment',
      ],
    ),
  ],
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'player_only',
      label: 'Adjust by player type and ignore stack pressure',
      isCorrect: false,
      preferredLabel: 'Map pressure first, then adjust by player',
      betterAnswerLabel: 'Map pressure first, then adjust by player',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Playable start.',
      feedbackReason:
          'Across M-ratio zones and medium stack bubble spots, adjusting by player type while ignoring stack pressure can lead to thin stack-offs that put your tournament life at risk near the bubble.',
    ),
    Act0RunnerOptionV1(
      id: 'pressure_then_adjust',
      label: 'Map pressure first, then adjust by player',
      isCorrect: true,
      preferredLabel: 'Map pressure first, then adjust by player',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Pressure comes first.',
      feedbackReason:
          'That sequence is the bridge to World 10: pressure context first, player-specific adjustment second.',
    ),
    Act0RunnerOptionV1(
      id: 'cards_only',
      label: 'Map pressure, then copy broad player reads',
      isCorrect: false,
      preferredLabel: 'Map pressure first, then adjust by player',
      betterAnswerLabel: 'Map pressure first, then adjust by player',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Order is right, adjustment is too broad.',
      feedbackReason:
          'After mapping M-ratio and medium stack bubble pressure, copying broad player reads without a specific tendency wastes chips against opponents who do not share that leak.',
    ),
  ],
);

final _w9TablePressureNoticeRunner = _w9BubblePressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w9_table_pressure_notice',
  lessonTitle: 'Tournament pressure checkpoint',
  lessonSubtitle: 'Tournament Pressure',
  caption:
      'Near the bubble, suppose a covering big stack opens into your medium stack.',
  hint: 'Consider who could be eliminated if the stacks go in.',
  question: 'What is the clean first pressure read?',
  feedbackTitle: 'Pressure read first.',
  feedbackReason:
      'Tournament pressure starts with naming who carries the risk premium and who carries the leverage.',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'medium_stack_pressure',
      label: 'Respect bubble pressure',
      isCorrect: true,
      preferredLabel: 'Respect bubble pressure',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Sharp read.',
      feedbackReason:
          'That is the key shift. Bubble pressure hits the medium stack harder, while the covering stack can apply leverage.',
    ),
    Act0RunnerOptionV1(
      id: 'same_cash_logic',
      label: 'Treat it like cash',
      isCorrect: false,
      preferredLabel: 'Respect bubble pressure',
      betterAnswerLabel: 'Respect bubble pressure',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'Near the bubble when a covering big stack opens into your medium stack, treating the spot like cash ignores the payout risk premium and risks elimination on thin calls.',
    ),
    Act0RunnerOptionV1(
      id: 'fold_everything_bubble',
      label: 'Fold everything',
      isCorrect: false,
      preferredLabel: 'Respect bubble pressure',
      betterAnswerLabel: 'Respect bubble pressure',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Playable caution.',
      feedbackReason:
          'When a covering big stack opens into your medium stack near the bubble, folding without looking at your hand or the opener’s range passes up profitable spots that still justify continuing under bubble pressure.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Name pressure before action.',
      body:
          'Real tournament spots get easier when you first identify who can pressure and who pays the bigger busting cost.',
      focusLabels: <String>['Bubble', 'Medium stack', 'Leverage'],
    ),
  ],
);

final _w10PlayerTypeIntroRunner = _w9BubblePressureIntroRunner.copyWith(
  table: _act0HypotheticalConceptTableV1(_w9ExampleTableBase),
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w10_player_type_intro',
  lessonTitle: 'Who is at the table',
  lessonSubtitle: 'Player Adjustment',
  caption: 'Tag one clear tendency before you change strategy.',
  hint: 'One useful read beats five vague labels.',
  question: 'What is the first step in player adjustment?',
  feedbackTitle: 'Adjustment foundation.',
  feedbackReason:
      'Start by naming one reliable tendency. Then apply one targeted change instead of a full strategy rewrite.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Tag first, adjust second.',
      body:
          'Look for repeated behavior: overfolding, calling too wide, bluffing too much, or bluffing too little. Build the adjustment from that one signal.',
      focusLabels: <String>['Tendency', 'Tag', 'Adjust'],
    ),
  ],
);

final _w10NitTagRunner = _w10PlayerTypeIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w10_nit_tag',
  caption: 'Opponent folds to steals repeatedly and rarely 3-bets.',
  teachingSteps: const <Act0TeachingStepV1>[],
  hint: 'Tight fold-heavy behavior has one obvious label.',
  question: 'What is the most useful quick tag?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'maniac',
      label: 'Overbluffing maniac',
      isCorrect: false,
      preferredLabel: 'Tight-folding profile (nit)',
      betterAnswerLabel: 'Tight-folding profile (nit)',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Opposite profile.',
      feedbackReason:
          'When an opponent repeatedly folds to steals and rarely puts in a 3-bet, tagging a maniac misreads a tight profile and forfeits easy blind-steal profit.',
    ),
    Act0RunnerOptionV1(
      id: 'nit',
      label: 'Tight-folding profile (nit)',
      isCorrect: true,
      preferredLabel: 'Tight-folding profile (nit)',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Strong choice.',
      feedbackReason:
          'Frequent folds and low aggression map to a tight profile. That supports selective steal pressure.',
    ),
    Act0RunnerOptionV1(
      id: 'unknown',
      label: 'Wait for one more orbit before adjusting',
      isCorrect: false,
      preferredLabel: 'Tight-folding profile (nit)',
      betterAnswerLabel: 'Tight-folding profile (nit)',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Playable caution.',
      feedbackReason:
          'After seeing repeated folds to steals and a low 3-bet rate, waiting another orbit leaves uncontested blind pots on the table.',
    ),
  ],
);

final _w10LoosePassiveTagRunner = _w10PlayerTypeIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w10_loose_passive_tag',
  caption: 'Opponent calls often preflop and postflop but rarely raises.',
  teachingSteps: const <Act0TeachingStepV1>[],
  hint: 'Calling wide without raises signals a common profile.',
  question: 'Which profile matches the repeated calling pattern?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'tight_aggressive',
      label: 'Tight-aggressive reg',
      isCorrect: false,
      preferredLabel: 'Loose-passive caller',
      betterAnswerLabel: 'Loose-passive caller',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not this one.',
      feedbackReason:
          'When an opponent calls often preflop and postflop without raising, tagging a tight-aggressive profile misses thin value bets against a passive caller.',
    ),
    Act0RunnerOptionV1(
      id: 'random',
      label: 'Possible sample noise, keep the tag light',
      isCorrect: false,
      preferredLabel: 'Loose-passive caller',
      betterAnswerLabel: 'Loose-passive caller',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Could happen short term.',
      feedbackReason:
          'After repeated preflop and postflop calls without raises, dismissing the pattern as noise forfeits extra value against a loose-passive opponent.',
    ),
    Act0RunnerOptionV1(
      id: 'loose_passive',
      label: 'Loose-passive caller',
      isCorrect: true,
      preferredLabel: 'Loose-passive caller',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Solid understanding.',
      feedbackReason:
          'Frequent calls with low raise rate is the classic loose-passive tendency.',
    ),
  ],
);

final _w10OveraggressiveTagRunner = _w10PlayerTypeIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w10_overaggressive_tag',
  caption:
      'Opponent raises often. In several earlier hands, you saw them make two bets and then show a weak hand.',
  teachingSteps: const <Act0TeachingStepV1>[],
  hint: 'Frequent pressure with weak showdowns points to one useful tag.',
  question: 'Which tag fits repeated pressure with weak showdowns?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'overaggressive',
      label: 'Over-aggressive bluffer',
      isCorrect: true,
      preferredLabel: 'Over-aggressive bluffer',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Well done.',
      feedbackReason:
          'The frequent raises and weak hands shown after two bets suggest a possible over-aggressive pattern. Keep watching for more examples.',
    ),
    Act0RunnerOptionV1(
      id: 'nit',
      label: 'Tight-folding nit',
      isCorrect: false,
      preferredLabel: 'Over-aggressive bluffer',
      betterAnswerLabel: 'Over-aggressive bluffer',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Wrong direction.',
      feedbackReason:
          'Frequent raises and weak hands shown after two bets point toward aggression. Treating this player as tight can lead you to fold hands that beat their bluffs.',
    ),
    Act0RunnerOptionV1(
      id: 'unknown',
      label: 'No useful read yet',
      isCorrect: false,
      preferredLabel: 'Over-aggressive bluffer',
      betterAnswerLabel: 'Over-aggressive bluffer',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Careful instinct.',
      feedbackReason:
          'After seeing repeated raises and two-street pressure with weak showdowns, claiming no read yet leaves you open to being bluffed off medium hands.',
    ),
  ],
);

final _w10PlayerTypeRecapRunner = _w10PlayerTypeIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w10_player_type_recap',
  caption:
      'Lesson learned: one tendency tag creates a cleaner adjustment plan.',
  teachingSteps: const <Act0TeachingStepV1>[],
  hint: 'Avoid complex labels before evidence is stable.',
  question: 'What is the tagging takeaway?',
  feedbackTitle: 'Player-type takeaway.',
  feedbackReason:
      'Start with one repeated tendency and one actionable adjustment. Complexity comes later if the read stays stable.',
);

final _w10OneLeverIntroRunner = _w10PlayerTypeIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w10_one_lever_intro',
  lessonTitle: 'Adjust one piece',
  caption:
      'Change one piece first: opening width, value density, or bluff rate.',
  hint: 'Small precise changes are easier to trust and test.',
  question: 'Why adjust one piece at a time?',
  feedbackTitle: 'One-piece foundation.',
  feedbackReason:
      'Single-piece changes reduce chaos. You can see if the adjustment works before layering more changes.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Precision over chaos.',
      body:
          'If a player overfolds, widen steals first. If a player overcalls, value-bet heavier first. Do not rewrite everything at once.',
      focusLabels: <String>['One piece', 'Steal wider', 'Value heavier'],
    ),
  ],
);

final _w10VsNitOpenWiderRunner = _w10OneLeverIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w10_vs_nit_open_wider',
  caption: 'Blinds fold too much to late-position steals.',
  teachingSteps: const <Act0TeachingStepV1>[],
  hint: 'Overfolding behind you increases steal EV.',
  question: 'What is the clean first adjustment?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'bluff_more_streets',
      label: 'Add more turn pressure first',
      isCorrect: false,
      preferredLabel: 'Open slightly wider in late position',
      betterAnswerLabel: 'Open slightly wider in late position',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too much change.',
      feedbackReason:
          'When the blinds overfold to late-position steals, adding turn barrels risks extra chips postflop when a wider preflop open already wins the blinds.',
    ),
    Act0RunnerOptionV1(
      id: 'open_wider',
      label: 'Open slightly wider in late position',
      isCorrect: true,
      preferredLabel: 'Open slightly wider in late position',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Excellent spot.',
      feedbackReason:
          'Against overfolders, wider late opens capture blinds more often with low resistance.',
    ),
    Act0RunnerOptionV1(
      id: 'no_change',
      label: 'Keep default play until blinds show it again',
      isCorrect: false,
      preferredLabel: 'Open slightly wider in late position',
      betterAnswerLabel: 'Open slightly wider in late position',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Safe but misses value.',
      feedbackReason:
          'When the blinds fold too much to late-position steals, keeping default play forfeits low-risk preflop blind steals.',
    ),
  ],
);

final _w10VsCallerValueHeavierRunner = _w10OneLeverIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w10_vs_caller_value_heavier',
  caption: 'Opponent calls down too wide with weak pairs.',
  teachingSteps: const <Act0TeachingStepV1>[],
  hint: 'Call-heavy opponents pay off thin value more often.',
  question: 'What is the cleaner adjustment?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'bluff_heavier',
      label: 'Bluff more anyway',
      isCorrect: false,
      preferredLabel: 'Value-bet heavier, bluff less often',
      betterAnswerLabel: 'Value-bet heavier, bluff less often',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Opposite adjustment.',
      feedbackReason:
          'This opponent calls down with weak pairs, so an extra bluff gets fewer folds and loses chips more often.',
    ),
    Act0RunnerOptionV1(
      id: 'allin_only',
      label: 'Value-bet your strongest hands and check the rest',
      isCorrect: false,
      preferredLabel: 'Value-bet heavier, bluff less often',
      betterAnswerLabel: 'Value-bet heavier, bluff less often',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Too coarse.',
      feedbackReason:
          'Strong hands earn value, and some thinner bets do too when this opponent calls with weak pairs. Checking every medium-strength hand gives up those calls from worse.',
    ),
    Act0RunnerOptionV1(
      id: 'value_heavier',
      label: 'Value-bet heavier, bluff less often',
      isCorrect: true,
      preferredLabel: 'Value-bet heavier, bluff less often',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Spot on.',
      feedbackReason:
          'Overcallers pay value and resist bluffs. Shift the mix toward value first.',
    ),
  ],
);

final _w10VsStickyDefenderTightenStealsRunner = _w10OneLeverIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w10_vs_sticky_defender_tighten_steals',
  caption: 'Blinds defend wide and call postflop too often.',
  teachingSteps: const <Act0TeachingStepV1>[],
  hint: 'A sticky defender changes the cleanest steal focus.',
  question: 'What is the better first adjustment?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'tighten_steals',
      label: 'Tighten the weakest steals and keep stronger value',
      isCorrect: true,
      preferredLabel: 'Tighten the weakest steals and keep stronger value',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Clean execution.',
      feedbackReason:
          'If blinds defend too wide, weak auto-steals lose value. Keep the adjustment specific by trimming trash and preserving stronger opens.',
    ),
    Act0RunnerOptionV1(
      id: 'steal_wider_anyway',
      label: 'Steal even wider',
      isCorrect: false,
      preferredLabel: 'Tighten the weakest steals and keep stronger value',
      betterAnswerLabel: 'Tighten the weakest steals and keep stronger value',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too loose.',
      feedbackReason:
          'When the blinds defend wide and call postflop too often, stealing even wider bleeds chips out of weak hands with little fold equity.',
    ),
    Act0RunnerOptionV1(
      id: 'no_change',
      label: 'Make no change until the sample is huge',
      isCorrect: false,
      preferredLabel: 'Tighten the weakest steals and keep stronger value',
      betterAnswerLabel: 'Tighten the weakest steals and keep stronger value',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Safe default.',
      feedbackReason:
          'Against sticky blinds who defend wide and overcall postflop, waiting for a huge sample keeps funding losing auto-steals with weak hands.',
    ),
  ],
);

final _w10TableValueVsCallerTransferRunner = _w10OneLeverIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w10_table_value_vs_caller_transfer',
  caption:
      'You hold K-Q on K-7-2 rainbow. BB checks. In earlier hands, you saw BB call flop bets with weak pairs.',
  hint:
      'Call-heavy opponents pay value more often. Ask what changes first before adding more bluffs.',
  question: 'What is the cleaner first adjustment here?',
  table: _w6ValueRangeActionRunner.table.copyWith(
    heroCards: _heroKqCards,
    boardCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'K', suit: 's'),
      Act0CardStateV1(rank: '7', suit: 'd'),
      Act0CardStateV1(rank: '2', suit: 'c'),
    ],
    centerLabel: 'Top pair vs caller',
    handContributions: _w6ValueRangeActionRunner.table.handContributions,
    actionTrail: const <Act0ActionTrailItemV1>[
      Act0ActionTrailItemV1(label: 'BTN opens 2.5 BB'),
      Act0ActionTrailItemV1(label: 'BB calls'),
      Act0ActionTrailItemV1(label: 'BB checks'),
    ],
  ),
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'bluff_more',
      label: 'Bluff more versus passive BB',
      isCorrect: false,
      preferredLabel: 'Lean value, bluff less',
      betterAnswerLabel: 'Lean value, bluff less',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Wrong mix shift.',
      feedbackReason:
          'On the K-7-2 flop from BTN after BB calls your 2.5 BB open and checks, bluffing more burns chips against a BB who already called flop bets with weak pairs.',
    ),
    Act0RunnerOptionV1(
      id: 'lean_value',
      label: 'Lean value, bluff less',
      isCorrect: true,
      preferredLabel: 'Lean value, bluff less',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Sharp live adjustment.',
      feedbackReason:
          'The earlier weak-pair calls support trying a value bet with top pair. The best size and whether a bet beats checking depend on how often this BB calls, folds or raises with each hand.',
    ),
    Act0RunnerOptionV1(
      id: 'force_big_pot',
      label: 'Push top pair into a huge pot immediately',
      isCorrect: false,
      preferredLabel: 'Lean value, bluff less',
      betterAnswerLabel: 'Lean value, bluff less',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Too coarse.',
      feedbackReason:
          'On the K-7-2 flop from BTN after BB calls 2.5 BB and checks, forcing a huge pot immediately risks too many chips when controlled value betting gets paid by worse hands.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Caller changes the mix.',
      body:
          'Use the check in this hand and the calling pattern from earlier hands. A value bet aims to get called by worse hands.',
      focusLabels: <String>['Real table', 'Calls too wide', 'Value', 'Bluff'],
    ),
  ],
);

final _w10OneLeverRecapRunner = _w10OneLeverIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w10_one_lever_recap',
  caption: 'Lesson learned: one change gives cleaner feedback.',
  teachingSteps: const <Act0TeachingStepV1>[],
  hint: 'Test one change before stacking new assumptions.',
  question: 'What is the one-change takeaway?',
  feedbackTitle: 'One-change takeaway.',
  feedbackReason:
      'Adjustment quality improves when changes are precise and testable. Broad rewrites create noise and confusion.',
);

final _w10ExploitGuardrailsIntroRunner = _w10OneLeverIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w10_guardrails_intro',
  lessonTitle: 'Adjustment guardrails',
  caption: 'Adjusting does not mean abandoning discipline or hand quality.',
  hint: 'Guardrails keep you from over-adjusting on thin evidence.',
  question: 'Why do adjustment guardrails matter?',
  feedbackTitle: 'Guardrail foundation.',
  feedbackReason:
      'Guardrails stop you from turning a useful adjustment into a leak. Strong adaptive play stays selective and evidence-based.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Adjust with control.',
      body:
          'Use sample-aware reads, keep standard anchors, and avoid extreme swings from one or two hands.',
      focusLabels: <String>['Sample quality', 'Standard', 'Control'],
    ),
  ],
);

final _w10OverbluffPunishRunner = _w10ExploitGuardrailsIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w10_overbluff_punish',
  caption:
      'In earlier river showdowns on this line, an opponent repeatedly showed missed draws after betting.',
  hint: 'Overbluffing can be punished by wider bluff-catch windows.',
  question: 'What is the cleaner adjustment response?',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'A blocker removes possible opponent hands.',
      body:
          'An opponent cannot hold a card you hold. A card that removes some of their strong value hands can make a close call more reasonable. Removing their missed draws instead can make a call worse.',
      focusLabels: <String>[],
    ),
    Act0TeachingStepV1(
      title: 'One repeated read, one measured adjustment.',
      body:
          'A bluff-catcher beats bluffs but loses to value bets. Repeated overbluffing can justify defending a little more selectively. This is not a reason to call every river: keep the observed tendency and which hands your cards remove in view.',
      focusLabels: <String>[],
    ),
  ],
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'fold_everything',
      label: 'Fold the weakest bluff-catchers first',
      isCorrect: false,
      preferredLabel: 'Bluff-catch a bit wider with blockers',
      betterAnswerLabel: 'Bluff-catch a bit wider with blockers',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too passive.',
      feedbackReason:
          'The opponent has repeatedly bet this river line and shown a missed draw at showdown. Folding more can give up profitable calls when there are enough bluffs for the price.',
    ),
    Act0RunnerOptionV1(
      id: 'hero_call_any',
      label: 'Call more rivers without checking blockers',
      isCorrect: false,
      preferredLabel: 'Bluff-catch a bit wider with blockers',
      betterAnswerLabel: 'Bluff-catch a bit wider with blockers',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Too extreme.',
      feedbackReason:
          'On the river against an overbluffer, calling more rivers without checking blockers can pay off value hands. Your cards can make the missed draws you want to catch less likely.',
    ),
    Act0RunnerOptionV1(
      id: 'bluffcatch_more',
      label: 'Bluff-catch a bit wider with blockers',
      isCorrect: true,
      preferredLabel: 'Bluff-catch a bit wider with blockers',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Selective bluff-catch works.',
      feedbackReason:
          'Against overbluffs, selective wider bluff-catching is profitable when your line blocks value combos.',
    ),
  ],
);

final _w10UnderbluffFoldMoreRunner = _w10ExploitGuardrailsIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w10_underbluff_fold_more',
  caption: 'Opponent reaches river with strong value and few bluffs.',
  teachingSteps: const <Act0TeachingStepV1>[],
  hint: 'Underbluffing changes bluff-catch requirements.',
  question: 'How should low bluff frequency change your river calls?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'fold_more',
      label: 'Fold more marginal bluff-catchers',
      isCorrect: true,
      preferredLabel: 'Fold more marginal bluff-catchers',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Sharp read.',
      feedbackReason:
          'If bluff frequency is too low, marginal calls lose EV. Disciplined folds become the adjustment.',
    ),
    Act0RunnerOptionV1(
      id: 'call_normal',
      label: 'Call normal standard frequency',
      isCorrect: false,
      preferredLabel: 'Fold more marginal bluff-catchers',
      betterAnswerLabel: 'Fold more marginal bluff-catchers',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Reasonable default.',
      feedbackReason:
          'Against a river range with strong value and few bluffs, some usual calls lose chips because they beat too little of the betting range.',
    ),
    Act0RunnerOptionV1(
      id: 'raise_bluff',
      label: 'Raise bluff more often',
      isCorrect: false,
      preferredLabel: 'Fold more marginal bluff-catchers',
      betterAnswerLabel: 'Fold more marginal bluff-catchers',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Wrong direction.',
      feedbackReason:
          'On the river against an underbluffing opponent, bluff-raising burns extra chips against a range weighted toward strong value hands.',
    ),
  ],
);

final _w10GuardrailSampleSizeRunner = _w10ExploitGuardrailsIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w10_guardrail_sample_size',
  caption: 'You saw two odd hands but no long pattern yet.',
  teachingSteps: const <Act0TeachingStepV1>[],
  hint: 'Guardrails protect you when evidence is still thin.',
  question: 'What is the cleaner adjustment posture?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'full_counter',
      label: 'Commit to a full counter-strategy immediately',
      isCorrect: false,
      preferredLabel: 'Make only a small adjustment and keep watching',
      betterAnswerLabel: 'Make only a small adjustment and keep watching',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too reactive.',
      feedbackReason:
          'After seeing only two odd hands, committing to a full counter-strategy overreacts to noise and exposes you to costly counter-leaks.',
    ),
    Act0RunnerOptionV1(
      id: 'small_probe',
      label: 'Make only a small adjustment and keep watching',
      isCorrect: true,
      preferredLabel: 'Make only a small adjustment and keep watching',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Strong choice.',
      feedbackReason:
          'Two hands can justify attention, not a full strategy swing. Small probes plus more evidence keep your line disciplined.',
    ),
    Act0RunnerOptionV1(
      id: 'ignore_everything',
      label: 'Ignore the hands completely',
      isCorrect: false,
      preferredLabel: 'Make only a small adjustment and keep watching',
      betterAnswerLabel: 'Make only a small adjustment and keep watching',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Too rigid.',
      feedbackReason:
          'With a two-hand sample, ignoring the hands completely misses an early table cue when a small, low-risk probe could test the read safely.',
    ),
  ],
);

final _w10ExploitGuardrailsRecapRunner = _w10ExploitGuardrailsIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w10_guardrails_recap',
  caption:
      'Lesson learned: adjustments work best with guardrails and evidence.',
  teachingSteps: const <Act0TeachingStepV1>[],
  hint: 'Do not let one read become a full strategy collapse.',
  question: 'What is the guardrail takeaway?',
  feedbackTitle: 'Guardrail takeaway.',
  feedbackReason:
      'Adjustment discipline means selective changes, stable standards, and enough evidence before major shifts.',
);

final _w10CheckpointTagLineRunner = _w10ExploitGuardrailsIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w10_checkpoint_tag_line',
  caption: 'Opponent folds blinds often but calls rivers too wide.',
  hint: 'You can tag both tendencies, then choose one main focus first.',
  question: 'What is the cleaner first step?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'all_changes',
      label: 'Pair the blind steal with thinner river value',
      isCorrect: false,
      preferredLabel: 'Choose one primary tendency and act on it',
      betterAnswerLabel: 'Choose one primary tendency and act on it',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too chaotic.',
      feedbackReason:
          'When an opponent folds blinds often and calls rivers too wide, changing both preflop steals and river sizing at once muddies your feedback and risks mis-sizing both spots.',
    ),
    Act0RunnerOptionV1(
      id: 'ignore_read',
      label: 'Wait for one more round before tagging',
      isCorrect: false,
      preferredLabel: 'Choose one primary tendency and act on it',
      betterAnswerLabel: 'Choose one primary tendency and act on it',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Safe default.',
      feedbackReason:
          'When an opponent repeatedly folds blinds and overcalls rivers, waiting another round forfeits immediate profit from a clear one-piece adjustment.',
    ),
    Act0RunnerOptionV1(
      id: 'primary_tag',
      label: 'Choose one primary tendency and act on it',
      isCorrect: true,
      preferredLabel: 'Choose one primary tendency and act on it',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Solid understanding.',
      feedbackReason:
          'Prioritizing one tendency keeps the adjustment coherent and measurable before layering more changes.',
    ),
  ],
);

final _w10CheckpointLeverLineRunner = _w10ExploitGuardrailsIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w10_checkpoint_lever_line',
  caption: 'A tight blind fold profile appears in your sample.',
  teachingSteps: const <Act0TeachingStepV1>[],
  hint: 'Single-change adjustment is the test.',
  question: 'Which adjustment line is the cleanest first move?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'widen_steal',
      label: 'Widen late steals slightly',
      isCorrect: true,
      preferredLabel: 'Widen late steals slightly',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Well done.',
      feedbackReason:
          'That is a clear one-piece adjustment against fold-heavy blinds and is easy to track.',
    ),
    Act0RunnerOptionV1(
      id: 'raise_all_sizes',
      label: 'Change open sizings across early and late seats',
      isCorrect: false,
      preferredLabel: 'Widen late steals slightly',
      betterAnswerLabel: 'Widen late steals slightly',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Over-adjustment.',
      feedbackReason:
          'When a tight blind-fold profile appears, changing open sizes from early and late seats reaches beyond the evidence. The pattern supports stealing a little wider when those blinds are left to act.',
    ),
    Act0RunnerOptionV1(
      id: 'flat_everything',
      label: 'Flat-call wider from early and middle seats',
      isCorrect: false,
      preferredLabel: 'Widen late steals slightly',
      betterAnswerLabel: 'Widen late steals slightly',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Not targeted.',
      feedbackReason:
          'Against a tight blind-fold profile, flat-calling wider from early and middle seats adds hands to pots before the blinds act. It misses the chance to win the blinds uncontested with a late open.',
    ),
  ],
);

final _w10CheckpointGuardrailLineRunner = _w10ExploitGuardrailsIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w10_checkpoint_guardrail_line',
  caption: 'You saw one wild bluff from an opponent this orbit.',
  teachingSteps: const <Act0TeachingStepV1>[],
  hint: 'Single hand reads can be noisy.',
  question: 'What is the best guardrail action?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'hard_counter',
      label: 'Overhaul your three-street calling plan right away',
      isCorrect: false,
      preferredLabel: 'Make a small adjustment and gather more evidence',
      betterAnswerLabel: 'Make a small adjustment and gather more evidence',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too reactive.',
      feedbackReason:
          'One wild bluff this orbit gives little evidence about the full betting range. Changing your calls across three streets can put extra chips in against stronger hands.',
    ),
    Act0RunnerOptionV1(
      id: 'small_adjust',
      label: 'Make a small adjustment and gather more evidence',
      isCorrect: true,
      preferredLabel: 'Make a small adjustment and gather more evidence',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Excellent spot.',
      feedbackReason:
          'Guardrails mean respecting uncertainty. Small moves plus more data beat extreme reactions.',
    ),
    Act0RunnerOptionV1(
      id: 'no_adjust',
      label: 'Stick to default chart lines and ignore the table cue',
      isCorrect: false,
      preferredLabel: 'Make a small adjustment and gather more evidence',
      betterAnswerLabel: 'Make a small adjustment and gather more evidence',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Too rigid.',
      feedbackReason:
          'One wild bluff this orbit is worth remembering while you keep your usual line. If the same betting pattern produces more bluffs, you have better evidence for adjusting.',
    ),
  ],
);

final _world10PlayerAdjustmentCheckpointRunner = _w10ExploitGuardrailsIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w10_player_adjustment_checkpoint',
  caption: 'Lesson learned: tag tendency, make one change, keep guardrails.',
  hint:
      'Next you will carry these guardrails-based adjustments into real-play decisions across mixed table conditions.',
  question: 'What does player adjustment add before real-play practice?',
  feedbackTitle: 'Player-adjustment checkpoint.',
  feedbackReason:
      'You can now convert pressure reads and tendency tags into opponent-specific lines while keeping guardrails and discipline. Real-play habits are the next layer.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Adjust with structure.',
      body:
          'Tag one tendency, choose one focus, keep guardrails, then test across table dynamics instead of one isolated hand.',
      focusLabels: <String>[
        'Tendency tag',
        'One focus',
        'Guardrails',
        'Real-play habits',
      ],
    ),
  ],
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'structured_exploit',
      label: 'Structured adjustment before live play',
      isCorrect: true,
      preferredLabel: 'Structured adjustment before live play',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Spot on.',
      feedbackReason:
          'That is the W10 bridge to W11: structured adaptation first, then reliable habits across live play conditions.',
    ),
    Act0RunnerOptionV1(
      id: 'intuition_only',
      label: 'Use table feel without a written routine',
      isCorrect: false,
      preferredLabel: 'Structured adjustment before live play',
      betterAnswerLabel: 'Structured adjustment before live play',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too loose.',
      feedbackReason:
          'Across preflop and postflop spots, relying on raw table feel without a structured tendency tag leads to erratic swings and costly misreads.',
    ),
    Act0RunnerOptionV1(
      id: 'baseline_only',
      label: 'Stay standard until another table cue confirms it',
      isCorrect: false,
      preferredLabel: 'Structured adjustment before live play',
      betterAnswerLabel: 'Structured adjustment before live play',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Safe but capped.',
      feedbackReason:
          'When opponents show repeated blind folds or loose calls, staying strictly standard leaves profitable adjustments uncollected before real play.',
    ),
  ],
);

final _w10TableAdjustmentNoticeRunner = _w10CheckpointLeverLineRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w10_table_adjustment_notice',
  lessonTitle: 'Player-adjustment checkpoint',
  lessonSubtitle: 'Player Adjustment',
  caption: 'Suppose both blinds keep folding to your late steals.',
  hint: 'Choose the first adjustment you can actually track at the table.',
  question: 'What is the clean first live adjustment?',
  feedbackTitle: 'Adjustment first, not chaos.',
  feedbackReason:
      'Real-table adjustment works when one repeated tendency turns into one small tracked change.',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'rewrite_everything',
      label: 'Widen steals and add more barrels too',
      isCorrect: false,
      preferredLabel: 'Widen late steals a bit',
      betterAnswerLabel: 'Widen late steals a bit',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too broad.',
      feedbackReason:
          'When both blinds keep folding to late steals, adding multi-street barrels on top of wider steals risks big postflop pots on a purely preflop read.',
    ),
    Act0RunnerOptionV1(
      id: 'never_adjust',
      label: 'Ignore the pattern',
      isCorrect: false,
      preferredLabel: 'Widen late steals a bit',
      betterAnswerLabel: 'Widen late steals a bit',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Safe fallback.',
      feedbackReason:
          'When both blinds repeatedly fold to your late steals, ignoring the pattern leaves free blind money uncollected every orbit.',
    ),
    Act0RunnerOptionV1(
      id: 'widen_late_steals_small',
      label: 'Widen late steals a bit',
      isCorrect: true,
      preferredLabel: 'Widen late steals a bit',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Clean execution.',
      feedbackReason:
          'That is the clean live move: repeated blind overfolding supports one small late-position widen, not a full strategy rewrite.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Carry one change to the table.',
      body:
          'Tag the tendency, pick one focus, and keep the change small enough that you can see whether it is working.',
      focusLabels: <String>['Repeated fold', 'One focus', 'Trackable change'],
    ),
  ],
);

final _w11SessionPlanIntroRunner = _w10ExploitGuardrailsIntroRunner.copyWith(
  table: _act0HypotheticalConceptTableV1(_w9ExampleTableBase),
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w11_session_plan_intro',
  lessonTitle: 'Session plan in 30 seconds',
  lessonSubtitle: 'Real-Play Habits',
  caption: 'Pick one concrete focus before each real session starts.',
  hint: 'One focus keeps decisions clear under pressure.',
  question: 'What is the best pre-session plan style?',
  feedbackTitle: 'Habit foundation.',
  feedbackReason:
      'Real-play habits improve when your session starts with one target behavior, not a long checklist.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'One focus, many reps.',
      body:
          'Choose one focus like blind steals, value sizing, or fold discipline. Then evaluate that same focus after the session.',
      focusLabels: <String>['One focus', 'Reps', 'Post-session review'],
    ),
  ],
);

final _w11PlanFocusChoiceRunner = _w11SessionPlanIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w11_plan_focus_choice',
  caption: 'You have 45 minutes and noisy tables today.',
  hint: 'Simple focus beats wide ambition.',
  question: 'What is the cleaner session objective?',
  teachingSteps: const <Act0TeachingStepV1>[],
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'many_focuses',
      label: 'Track six improvements at once',
      isCorrect: false,
      preferredLabel: 'One measurable focus for the whole session',
      betterAnswerLabel: 'One measurable focus for the whole session',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too much load.',
      feedbackReason:
          'In a 45-minute session on noisy tables, tracking six improvements at once overloads your attention and causes missed live cues.',
    ),
    Act0RunnerOptionV1(
      id: 'one_focus',
      label: 'One measurable focus for the whole session',
      isCorrect: true,
      preferredLabel: 'One measurable focus for the whole session',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'One measurable focus.',
      feedbackReason:
          'A single measurable focus carries study into real play with less mental overload.',
    ),
    Act0RunnerOptionV1(
      id: 'no_plan',
      label: 'No plan, just react',
      isCorrect: false,
      preferredLabel: 'One measurable focus for the whole session',
      betterAnswerLabel: 'One measurable focus for the whole session',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Playable fallback.',
      feedbackReason:
          'Across a 45-minute session, playing with no plan leaves you drifting into reactive mistakes instead of building one repeatable skill.',
    ),
  ],
);

final _w11PlanAvoidOverloadRunner = _w11SessionPlanIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w11_plan_avoid_overload',
  caption: 'Your prior session had scattered notes and no clear pattern.',
  hint: 'Reduce cognitive load first.',
  question: 'How should this session goal be narrowed?',
  teachingSteps: const <Act0TeachingStepV1>[],
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'more_complexity',
      label: 'Add more tracking categories',
      isCorrect: false,
      preferredLabel: 'Narrow to one session goal next time',
      betterAnswerLabel: 'Narrow to one session goal next time',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Wrong direction.',
      feedbackReason:
          'After a prior session with scattered notes, adding more tracking categories increases mental noise and hides your main table leak.',
    ),
    Act0RunnerOptionV1(
      id: 'repeat_none',
      label: 'Play the next session without a focus target',
      isCorrect: false,
      preferredLabel: 'Narrow to one session goal next time',
      betterAnswerLabel: 'Narrow to one session goal next time',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Too passive.',
      feedbackReason:
          'With scattered notes from the last session, playing without a focus target gives you no consistent decision to track this time.',
    ),
    Act0RunnerOptionV1(
      id: 'narrow_goal',
      label: 'Narrow to one session goal next time',
      isCorrect: true,
      preferredLabel: 'Narrow to one session goal next time',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'One goal clears the noise.',
      feedbackReason:
          'Carryover improves when you narrow scope and collect cleaner evidence on one behavior.',
    ),
  ],
);

final _w11PlanTableFocusTransferRunner = _w11SessionPlanIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w11_plan_table_focus_transfer',
  caption:
      'Your evening session starts in an hour. You are tired and the first orbit will move fast.',
  hint:
      'Pick one focus you can notice as a trigger during the session and review after the session ends.',
  question: 'What should you choose before sitting in?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'one_focus_loop',
      label: 'Track only the blind-defense leak today',
      isCorrect: true,
      preferredLabel: 'Track only the blind-defense leak today',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Clean session plan.',
      feedbackReason:
          'That is the real-table habit. One focus keeps the session executable, gives you one trigger to notice live, and leaves one clean review target after the session.',
    ),
    Act0RunnerOptionV1(
      id: 'many_focuses_now',
      label: 'Track all leaks from the start',
      isCorrect: false,
      preferredLabel: 'Track only the blind-defense leak today',
      betterAnswerLabel: 'Track only the blind-defense leak today',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too noisy.',
      feedbackReason:
          'When you are tired and the first orbit moves fast, tracking several leaks can distract you from the cues you need for blind defense.',
    ),
    Act0RunnerOptionV1(
      id: 'no_focus_until_review',
      label: 'Play first and decide later',
      isCorrect: false,
      preferredLabel: 'Track only the blind-defense leak today',
      betterAnswerLabel: 'Track only the blind-defense leak today',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Too loose a cycle.',
      feedbackReason:
          'If you play first and decide later, you start a fast first orbit tired and without a specific blind-defense cue to look for.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Plan the routine before the cards fly.',
      body:
          'Real-table practice starts before the first hand. One focus sets the session goal, one trigger tells you when to apply it, and one review note closes the cycle after play.',
      focusLabels: <String>['Real table', 'One focus', 'Trigger', 'Review'],
    ),
  ],
);

final _w11SessionPlanRecapRunner = _w11SessionPlanIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w11_session_plan_recap',
  caption: 'Lesson learned: one focus plan creates cleaner real-play habits.',
  hint: 'Simple plan first, then repetitions.',
  question: 'What is the session-plan takeaway?',
  feedbackTitle: 'Plan takeaway.',
  feedbackReason:
      'Consistent one-focus planning improves execution quality and makes post-session review actionable.',
  teachingSteps: const <Act0TeachingStepV1>[],
);

final _w11TriggerReadIntroRunner = _w11SessionPlanIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w11_trigger_intro',
  lessonTitle: 'In-session trigger reads',
  caption: 'When a trigger appears, apply one prepared adjustment quickly.',
  hint: 'Trigger -> one adjustment -> observe result.',
  question: 'What is a trigger read for real play?',
  feedbackTitle: 'Trigger foundation.',
  feedbackReason:
      'A trigger read is a repeated in-session pattern that activates one preplanned adjustment.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Pattern to action.',
      body:
          'If blinds overfold, steal a bit wider. If a player overcalls, value heavier. Use one adjustment per trigger.',
      focusLabels: <String>['Trigger', 'One change', 'Observe result'],
    ),
  ],
);

final _w11TriggerOverfoldBlindsRunner = _w11TriggerReadIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w11_trigger_overfold_blinds',
  caption: 'Both blinds folded to 5 of your last 6 steals.',
  hint: 'Overfold trigger supports a preflop widen adjustment.',
  question: 'What is the cleaner table action?',
  teachingSteps: const <Act0TeachingStepV1>[],
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'threebarrel_all',
      label: 'Add turn barrels against the blinds too',
      isCorrect: false,
      preferredLabel: 'Widen late steals slightly',
      betterAnswerLabel: 'Widen late steals slightly',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too broad.',
      feedbackReason:
          'After both blinds folded to 5 of your last 6 preflop steals, adding turn barrels risks extra postflop chips on a purely preflop overfold read.',
    ),
    Act0RunnerOptionV1(
      id: 'widen_late_steal',
      label: 'Widen late steals slightly',
      isCorrect: true,
      preferredLabel: 'Widen late steals slightly',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Overfold means widen.',
      feedbackReason:
          'This is a direct trigger-to-action adjustment with clear evidence and low complexity.',
    ),
    Act0RunnerOptionV1(
      id: 'ignore_trigger',
      label: 'Wait one more orbit before using the trigger',
      isCorrect: false,
      preferredLabel: 'Widen late steals slightly',
      betterAnswerLabel: 'Widen late steals slightly',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Safe but misses edge.',
      feedbackReason:
          'When both blinds have folded to 5 of your last 6 preflop steals, waiting another orbit forfeits high-frequency preflop blind profit.',
    ),
  ],
);

final _w11TriggerOvercallFlopRunner = _w11TriggerReadIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w11_trigger_overcall_flop',
  caption:
      'In several earlier showdowns, an opponent showed a weak pair after calling bets on both flop and turn.',
  hint: 'Overcall trigger points to value-density change.',
  question: 'What is the sharper one-change response?',
  teachingSteps: const <Act0TeachingStepV1>[],
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'bluff_more',
      label: 'Probe with more bluffs first',
      isCorrect: false,
      preferredLabel: 'Bet value heavier and trim bluffs',
      betterAnswerLabel: 'Bet value heavier and trim bluffs',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Wrong adjustment.',
      feedbackReason:
          'This opponent has repeatedly called flop and turn bets and shown a weak pair at showdown. Extra bluffs are less likely to get folds.',
    ),
    Act0RunnerOptionV1(
      id: 'no_change',
      label: 'Wait to adjust until post-session review',
      isCorrect: false,
      preferredLabel: 'Bet value heavier and trim bluffs',
      betterAnswerLabel: 'Bet value heavier and trim bluffs',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Too rigid.',
      feedbackReason:
          'The earlier weak-pair showdowns give you a cue for thinner value bets now. Waiting for post-session review gives up that opportunity.',
    ),
    Act0RunnerOptionV1(
      id: 'value_heavier',
      label: 'Bet value heavier and trim bluffs',
      isCorrect: true,
      preferredLabel: 'Bet value heavier and trim bluffs',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Callers want value.',
      feedbackReason:
          'Those showdowns give you a reason to try more value bets and fewer bluffs against this player. Keep checking whether the pattern holds.',
    ),
  ],
);

// The same dealt hand continues from the flop to the turn. Forced
// contributions are context notes, so replay lists only authored actions.
const _w11QJsPreflopTrail = <Act0ActionTrailItemV1>[
  Act0ActionTrailItemV1.note(label: 'SB blind 0.5 BB'),
  Act0ActionTrailItemV1.note(label: 'BB blind 1 BB'),
  Act0ActionTrailItemV1.note(label: '6 antes of 0.25 BB each'),
  Act0ActionTrailItemV1(label: 'CO raises 2.5 BB'),
  Act0ActionTrailItemV1(label: 'BTN calls 2.5 BB'),
];

const _w11QJsPreflopContributions = [
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
  Act0ContributionV1(
    PokerStreet.preflop,
    'utg',
    Act0ContributionKindV1.ante,
    .25,
  ),
  Act0ContributionV1(
    PokerStreet.preflop,
    'hj',
    Act0ContributionKindV1.ante,
    .25,
  ),
  Act0ContributionV1(
    PokerStreet.preflop,
    'co',
    Act0ContributionKindV1.ante,
    .25,
  ),
  Act0ContributionV1(
    PokerStreet.preflop,
    'btn',
    Act0ContributionKindV1.ante,
    .25,
  ),
  Act0ContributionV1(
    PokerStreet.preflop,
    'sb',
    Act0ContributionKindV1.ante,
    .25,
  ),
  Act0ContributionV1(
    PokerStreet.preflop,
    'bb',
    Act0ContributionKindV1.ante,
    .25,
  ),
  Act0ContributionV1(
    PokerStreet.preflop,
    'co',
    Act0ContributionKindV1.wager,
    2.5,
  ),
  Act0ContributionV1(
    PokerStreet.preflop,
    'btn',
    Act0ContributionKindV1.wager,
    2.5,
  ),
];
const _w11QJsFlopBet = Act0ContributionV1(
  PokerStreet.flop,
  'co',
  Act0ContributionKindV1.wager,
  2,
);
const _w11QJsStartingStacks = {'btn': 37.75, 'co': 37.75};

final _w11TriggerSmallPriceContinueRunner = _w11TriggerReadIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w11_trigger_small_price_continue',
  caption:
      'Six-handed, 0.25 BB ante each. CO opens to 2.5 BB, BTN calls with QJs. Both started the flop with 35 BB behind. On J-7-4 rainbow, CO bets 2 BB into 8 BB.',
  hint: 'Real play means combining cues, not naming one concept.',
  question:
      'Which line keeps weaker bets in and lets you reassess after the next card?',
  table: _act0CurrentStreetTableV1(
    _legacyFacingOpenTableV1.copyWith(
      heroCards: _heroQJsCards,
      boardCards: _boardJ74FlopCards,
      streetLabel: 'Flop',
      potLabel: 'Pot 10 BB',
      toCallLabel: 'To call 2 BB',
      centerLabel: 'BTN, top pair, small price',
      handContributions: const Act0HandContributionsV1(
        throughStreet: PokerStreet.flop,
        startingStackBbBySeat: _w11QJsStartingStacks,
        entries: [..._w11QJsPreflopContributions, _w11QJsFlopBet],
      ),
      actionTrail: const <Act0ActionTrailItemV1>[
        ..._w11QJsPreflopTrail,
        Act0ActionTrailItemV1(label: 'Flop: CO bets 2 BB'),
      ],
    ),
    bets: const {
      'co': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.bet,
        label: 'CO',
        amountLabel: '2 BB',
      ),
    },
  ),
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'call_once',
      label: 'Call once in position',
      isCorrect: true,
      preferredLabel: 'Call once in position',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Clean table read.',
      feedbackReason:
          'A 2 BB call makes a 12 BB pot, an immediate threshold of about 17%. A call in position is reasonable if CO bets enough hands you beat. CO’s range and later betting determine how much equity you realize.',
    ),
    Act0RunnerOptionV1(
      id: 'fold_now',
      label: 'Fold now',
      isCorrect: false,
      preferredLabel: 'Call once in position',
      betterAnswerLabel: 'Call once in position',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'A fold ends this hand.',
      feedbackReason:
          'On the J-7-4 flop from BTN at 35 BB effective facing CO\'s 2 BB bet into an 8 BB pot, folding immediately surrenders your equity against CO\'s weaker flop bets at a cheap 2 BB price.',
    ),
    Act0RunnerOptionV1(
      id: 'raise_now',
      label: 'Raise for protection now',
      isCorrect: false,
      preferredLabel: 'Call once in position',
      betterAnswerLabel: 'Call once in position',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Playable but noisy.',
      feedbackReason:
          'CO bets 2 BB on J-7-4 and the pot is now 10 BB. Raising can drive out weaker bets that a call in position would keep in.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Price plus position can support a continue.',
      body:
          'Read seat, hand, board, and price together. A marginal made hand can continue when the price is small and position keeps control.',
      focusLabels: <String>['Position', 'Top pair', 'Small price', 'Dry board'],
    ),
  ],
);

final _w11TriggerBadPriceFoldRunner = _w11TriggerReadIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w11_trigger_bad_price_fold',
  caption:
      'Same hand again. BTN called 2 BB on J-7-4. Both started the turn with 33 BB behind. Tight CO rarely bluffs big turn bets and now bets 12 BB into 12 BB.',
  hint:
      'Combine a large second-barrel price with this opponent\'s unusually value-heavy betting range.',
  question: 'What is the cleaner response now?',
  table: _act0CurrentStreetTableV1(
    _legacyFacingOpenTableV1.copyWith(
      heroCards: _heroQJsCards,
      boardCards: _boardJ742TurnCards,
      streetLabel: 'Turn',
      potLabel: 'Pot 24 BB',
      toCallLabel: 'To call 12 BB',
      centerLabel: 'BTN top pair, tight CO barrel',
      handContributions: const Act0HandContributionsV1(
        throughStreet: PokerStreet.turn,
        startingStackBbBySeat: _w11QJsStartingStacks,
        entries: [
          ..._w11QJsPreflopContributions,
          _w11QJsFlopBet,
          Act0ContributionV1(
            PokerStreet.flop,
            'btn',
            Act0ContributionKindV1.wager,
            2,
          ),
          Act0ContributionV1(
            PokerStreet.turn,
            'co',
            Act0ContributionKindV1.wager,
            12,
          ),
        ],
      ),
      actionTrail: const <Act0ActionTrailItemV1>[
        ..._w11QJsPreflopTrail,
        Act0ActionTrailItemV1(label: 'Flop: CO bets 2 BB'),
        Act0ActionTrailItemV1(label: 'BTN calls 2 BB'),
        Act0ActionTrailItemV1(label: 'Turn: CO bets 12 BB'),
      ],
    ),
    bets: const {
      'co': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.bet,
        label: 'CO',
        amountLabel: '12 BB',
      ),
    },
  ),
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'call_top_pair',
      label: 'Call the top pair',
      isCorrect: false,
      preferredLabel: 'Fold the turn',
      betterAnswerLabel: 'Fold the turn',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Tempting hand-label trap.',
      feedbackReason:
          'Tight CO bets 12 BB into a 12 BB pot. Calling makes the pot 36 BB, so top pair needs about 33% equity. The read that CO rarely bluffs big on the turn makes that harder to find.',
    ),
    Act0RunnerOptionV1(
      id: 'fold_turn',
      label: 'Fold the turn',
      isCorrect: true,
      preferredLabel: 'Fold the turn',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Strong contrast read.',
      feedbackReason:
          'Calling 12 BB makes a 36 BB pot, about 33% immediate pot odds. Folding is reasonable given that CO rarely bluffs this size. How often CO bets hands you beat and what happens on the river determine the best line.',
    ),
    Act0RunnerOptionV1(
      id: 'jam_turn',
      label: 'Go all-in to deny equity',
      isCorrect: false,
      preferredLabel: 'Fold the turn',
      betterAnswerLabel: 'Fold the turn',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too much pressure back.',
      feedbackReason:
          'The pot is now 24 BB and you have 33 BB behind. Going all-in with one pair risks your stack when a tight CO rarely bluffs big on this turn and may continue with better hands.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Same hand, worse continue.',
      body:
          'A small flop bet can justify a call, yet a pot-sized turn barrel from an opponent who rarely bluffs can make the same top pair a fold. The range read matters as much as the price.',
      focusLabels: <String>[
        'Same hand',
        'Pot-size bet',
        'Tight CO read',
        'River risk',
      ],
    ),
  ],
);

final _w11TriggerReadRecapRunner = _w11TriggerReadIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w11_trigger_recap',
  caption:
      'Lesson learned: trigger reads convert pattern into one focused adjustment.',
  hint: 'Trigger must be repeated, not imagined.',
  question: 'What is the trigger-read takeaway?',
  feedbackTitle: 'Trigger takeaway.',
  feedbackReason:
      'Strong play uses repeated triggers and simple single adjustments you can track over time.',
  teachingSteps: const <Act0TeachingStepV1>[],
);

final _w11ReviewLoopIntroRunner = _w11SessionPlanIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w11_review_loop_intro',
  lessonTitle: 'Post-session review habit',
  caption: 'After play, name one leak and one repair target for tomorrow.',
  hint: 'One leak, one fix, one next session test.',
  question: 'What makes review actionable?',
  feedbackTitle: 'Review foundation.',
  feedbackReason:
      'Actionable review links one observed leak to one concrete repair task for the next session.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Close the cycle daily.',
      body:
          'Session plan starts the day, trigger reads guide live play, and review sets tomorrow’s focus. That cycle compounds skill.',
      focusLabels: <String>['Plan', 'Trigger', 'Review', 'Daily cycle'],
    ),
  ],
);

final _w11ReviewPickLeakRunner = _w11ReviewLoopIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w11_review_pick_leak',
  caption: 'Today you missed thin value and overcalled one river.',
  hint: 'Pick the leak that repeats most often first.',
  question: 'What is the clean first review action?',
  teachingSteps: const <Act0TeachingStepV1>[],
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'fix_everything',
      label: 'Tackle both leaks together in the next session',
      isCorrect: false,
      preferredLabel: 'Select one repeated leak as priority',
      betterAnswerLabel: 'Select one repeated leak as priority',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Overload risk.',
      feedbackReason:
          'After a session where you missed thin value and overcalled one river, trying to repair both leaks next session divides your attention between thin value and river calls, making it harder to tell which decision improved.',
    ),
    Act0RunnerOptionV1(
      id: 'skip_review',
      label: 'Skip review and just play more volume',
      isCorrect: false,
      preferredLabel: 'Select one repeated leak as priority',
      betterAnswerLabel: 'Select one repeated leak as priority',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Volume helps.',
      feedbackReason:
          'After missing thin value and overcalling a river today, skipping review to grind more volume repeats the same chip-losing habits next session.',
    ),
    Act0RunnerOptionV1(
      id: 'pick_priority',
      label: 'Select one repeated leak as priority',
      isCorrect: true,
      preferredLabel: 'Select one repeated leak as priority',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Pick the repeat leak.',
      feedbackReason:
          'Choosing one repeated leak gives the highest value for the next focused session.',
    ),
  ],
);

final _w11ReviewDefineFixRunner = _w11ReviewLoopIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w11_review_define_fix',
  caption: 'Priority leak: overcalling rivers vs tight players.',
  hint: 'Define an if-then fix for next session.',
  question: 'Which repair target is most actionable?',
  teachingSteps: const <Act0TeachingStepV1>[],
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'if_then_fix',
      label: 'If an opponent underbluffs, fold marginal bluff-catchers',
      isCorrect: true,
      preferredLabel:
          'If an opponent underbluffs, fold marginal bluff-catchers',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Specific fix carries over.',
      feedbackReason:
          'Specific if-then repair targets carry directly into live decisions better than generic intentions.',
    ),
    Act0RunnerOptionV1(
      id: 'generic_fix',
      label: 'Play better rivers somehow',
      isCorrect: false,
      preferredLabel:
          'If an opponent underbluffs, fold marginal bluff-catchers',
      betterAnswerLabel:
          'If an opponent underbluffs, fold marginal bluff-catchers',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too vague.',
      feedbackReason:
          'When your priority leak is overcalling on the river against tight players, a vague goal gives you no clear river fold rule and keeps costing chips.',
    ),
    Act0RunnerOptionV1(
      id: 'no_fix',
      label: 'Leave the river leak unwritten and move on',
      isCorrect: false,
      preferredLabel:
          'If an opponent underbluffs, fold marginal bluff-catchers',
      betterAnswerLabel:
          'If an opponent underbluffs, fold marginal bluff-catchers',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Missed chance.',
      feedbackReason:
          'After identifying river overcalls against tight players, leaving the river leak unwritten gives you no specific cue to check the next time a tight player bets.',
    ),
  ],
);

final _w11ReviewLoopRecapRunner = _w11ReviewLoopIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w11_review_loop_recap',
  caption: 'Lesson learned: review carries your work forward into tomorrow.',
  hint: 'Write one leak and one fix before ending session.',
  question: 'What is the post-session review takeaway?',
  feedbackTitle: 'Review takeaway.',
  feedbackReason:
      'Post-session review converts play into learning only when it outputs one clear repair target for the next day.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Carry one fix forward.',
      body:
          'A session only teaches if your review stays small and concrete. Pick one repeated mistake from today, ignore lucky or unlucky short-term noise, and write one clear if-then habit for tomorrow. Bringing that single note into the next pre-session plan turns daily hands into steady skill.',
      focusLabels: <String>['One leak', 'If-then fix', 'Next session'],
    ),
  ],
);

final _w11CheckpointPlanLineRunner = _w11ReviewLoopIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w11_checkpoint_plan_line',
  caption: 'You start a session after a long workday with low energy.',
  hint: 'Plan should stay simple and executable.',
  question: 'What is the clean session plan?',
  teachingSteps: const <Act0TeachingStepV1>[],
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'complex_plan',
      label: 'Set a complex multi-phase improvement plan',
      isCorrect: false,
      preferredLabel: 'Set one low-friction focus target',
      betterAnswerLabel: 'Set one low-friction focus target',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too heavy.',
      feedbackReason:
          'When starting a session with low energy after a long workday, a complex multi-phase plan collapses under fatigue and causes sloppy table decisions.',
    ),
    Act0RunnerOptionV1(
      id: 'simple_focus',
      label: 'Set one low-friction focus target',
      isCorrect: true,
      preferredLabel: 'Set one low-friction focus target',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Low-energy plan first.',
      feedbackReason:
          'Low-energy sessions still teach well when focus is clear, small, and measurable.',
    ),
    Act0RunnerOptionV1(
      id: 'no_objective',
      label: 'Play with no objective',
      isCorrect: false,
      preferredLabel: 'Set one low-friction focus target',
      betterAnswerLabel: 'Set one low-friction focus target',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Simpler, but blind.',
      feedbackReason:
          'In a low-energy session, playing with no objective lets tired autopilot take over and wastes the session\'s learning value.',
    ),
  ],
);

final _w11CheckpointTriggerLineRunner = _w11ReviewLoopIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w11_checkpoint_trigger_line',
  caption: 'You notice repeated blind overfold and river underbluff patterns.',
  hint: 'Pick one prepared live cue first.',
  question: 'Which table action is best?',
  teachingSteps: const <Act0TeachingStepV1>[],
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'all_trigger_actions',
      label: 'Use both trigger and review changes now',
      isCorrect: false,
      preferredLabel: 'Use one prepared live cue now',
      betterAnswerLabel: 'Use one prepared live cue now',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too broad.',
      feedbackReason:
          'When you notice both blind overfolding and river underbluffing, applying multiple changes at once causes execution mix-ups across preflop and river spots.',
    ),
    Act0RunnerOptionV1(
      id: 'ignore_triggers',
      label: 'Log the trigger and wait for review',
      isCorrect: false,
      preferredLabel: 'Use one prepared live cue now',
      betterAnswerLabel: 'Use one prepared live cue now',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Review matters.',
      feedbackReason:
          'After spotting repeated blind overfold and river underbluff patterns, logging the patterns for review delays an adjustment already supported by repeated observations, such as stealing a little wider against the overfolding blinds.',
    ),
    Act0RunnerOptionV1(
      id: 'one_trigger_action',
      label: 'Use one prepared live cue now',
      isCorrect: true,
      preferredLabel: 'Use one prepared live cue now',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'One cue, one action.',
      feedbackReason:
          'A single prepared cue keeps table play disciplined and observable.',
    ),
  ],
);

final _w11CheckpointReviewLineRunner = _w11ReviewLoopIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w11_checkpoint_review_line',
  caption: 'Session ends with mixed results and two recurring mistakes.',
  hint: 'Review should output one next-session repair task.',
  question: 'What is the strongest closeout action?',
  teachingSteps: const <Act0TeachingStepV1>[],
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'one_repair_output',
      label: 'Review one leak',
      isCorrect: true,
      preferredLabel: 'Review one leak',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Cycle closed cleanly.',
      feedbackReason:
          'Progress compounds when review creates one actionable output that directly shapes the next session plan.',
    ),
    Act0RunnerOptionV1(
      id: 'long_notes',
      label: 'Write long notes',
      isCorrect: false,
      preferredLabel: 'Review one leak',
      betterAnswerLabel: 'Review one leak',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Incomplete review.',
      feedbackReason:
          'After a session with two recurring mistakes, writing long notes without picking one priority repair leaves tomorrow\'s session plan unfocused and repeats the leaks.',
    ),
    Act0RunnerOptionV1(
      id: 'skip_closeout',
      label: 'Skip closeout',
      isCorrect: false,
      preferredLabel: 'Review one leak',
      betterAnswerLabel: 'Review one leak',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Common habit.',
      feedbackReason:
          'When a session ends with two recurring mistakes, skipping closeout lets the details fade and carries the same unfixed leaks into tomorrow.',
    ),
  ],
);

final _w11CheckpointMixedTableLineRunner = _w11ReviewLoopIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w11_checkpoint_mixed_table_line',
  caption:
      'Real table. HJ opens 2.5 BB. You call BTN with A-J suited at 30 BB effective. Flop is A-8-4 two-tone. HJ bets 5 BB into 8 BB.',
  hint: 'Read seat, hand, board, price, and stack before choosing.',
  question: 'Which line continues in position and keeps HJ’s weaker bets in?',
  table: _act0CurrentStreetTableV1(
    _legacyFacingOpenTableV1.copyWith(
      heroCards: _heroAJsCards,
      boardCards: _boardA84TwoToneCards,
      streetLabel: 'Flop',
      potLabel: 'Pot 13 BB',
      toCallLabel: 'To call 5 BB',
      centerLabel: 'BTN, top pair, 30 BB',
      highlightedSeatIds: const ['hj', 'btn'],
      handContributions: _act0SingleStreetBetContributionsV1(
        street: PokerStreet.flop,
        bettor: 'hj',
        betBb: 5,
        effectiveStackAtHandStartBb: 30,
        potBeforeBetBb: 8,
      ),
      actionTrail: const <Act0ActionTrailItemV1>[
        Act0ActionTrailItemV1(label: 'HJ opens 2.5 BB'),
        Act0ActionTrailItemV1(label: 'BTN calls'),
        Act0ActionTrailItemV1(label: 'HJ bets 5 BB'),
      ],
    ),
    bets: {
      'hj': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.bet,
        label: 'HJ',
        amountLabel: '5 BB',
      ),
    },
  ),
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'raise_for_protection',
      label: 'Raise now for protection',
      isCorrect: false,
      preferredLabel: 'Call in position and keep the range wide',
      betterAnswerLabel: 'Call in position and keep the range wide',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Tempting pressure line.',
      feedbackReason:
          'HJ bets 5 BB into an 8 BB pot on A-8-4. Raising may fold the weaker bets you want to keep in and build a bigger pot against the range that continues.',
    ),
    Act0RunnerOptionV1(
      id: 'call_in_position',
      label: 'Call in position and keep the range wide',
      isCorrect: true,
      preferredLabel: 'Call in position and keep the range wide',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Integrated read.',
      feedbackReason:
          'A 5 BB call makes an 18 BB pot, an immediate threshold of about 28%. Calling in position can keep weaker bets and draws in. HJ’s betting range and later action determine the best line.',
    ),
    Act0RunnerOptionV1(
      id: 'fold_to_pressure',
      label: 'Fold to the c-bet',
      isCorrect: false,
      preferredLabel: 'Call in position and keep the range wide',
      betterAnswerLabel: 'Call in position and keep the range wide',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'A fold ends this hand.',
      feedbackReason:
          'On A-8-4, HJ has bet 5 BB and the pot is now 13 BB. Folding gives up your in-position equity against HJ\'s weaker flop bets and draws.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Real play combines cues.',
      body:
          'Real play means combining seat, hand, board, price, and stack depth before acting. One cue alone is usually too thin.',
      focusLabels: <String>['Position', 'Top pair', 'Two-tone board', '30 BB'],
    ),
  ],
);

final _world11RealPlayCheckpointRunner = _w11ReviewLoopIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w11_real_play_checkpoint',
  caption:
      'Lesson learned: plan, trigger, and review form one daily practice cycle.',
  hint:
      'This closes the core route and feeds your daily play-review habit. Next you build the mindset bridge.',
  question: 'What does real-play carryover produce when done well?',
  feedbackTitle: 'Real-play checkpoint.',
  feedbackReason:
      'You can now carry course logic into real sessions through a repeatable routine: one plan, one trigger adjustment, and one review repair output. The mindset bridge is the next layer.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Cycle beats intensity.',
      body:
          'Sustainable progress comes from repeating a clean study-to-table cycle daily, not from occasional complex sessions.',
      focusLabels: <String>[
        'Session plan',
        'Trigger action',
        'Review repair',
        'Daily habit',
      ],
    ),
  ],
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'one_time_mastery',
      label: 'One large review block after the session',
      isCorrect: false,
      preferredLabel: 'A repeatable daily practice cycle',
      betterAnswerLabel: 'A repeatable daily practice cycle',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too brittle.',
      feedbackReason:
          'One large review block can identify a leak. A small plan, trigger, and review cycle makes it easier to practise the fix on the next session.',
    ),
    Act0RunnerOptionV1(
      id: 'content_only',
      label: 'Study another concept before applying it',
      isCorrect: false,
      preferredLabel: 'A repeatable daily practice cycle',
      betterAnswerLabel: 'A repeatable daily practice cycle',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Partial progress.',
      feedbackReason:
          'Before live play, studying another concept without applying a plan-trigger-review habit leaves your existing table leaks costing chips.',
    ),
    Act0RunnerOptionV1(
      id: 'repeatable_loop',
      label: 'A repeatable daily practice cycle',
      isCorrect: true,
      preferredLabel: 'A repeatable daily practice cycle',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Sharp read.',
      feedbackReason:
          'That is the intended endpoint: practical, repeatable carryover from learning into daily table decisions.',
    ),
  ],
);

final _w12DecisionQualityIntroRunner = _w11ReviewLoopIntroRunner.copyWith(
  table: _act0ReassignHeroSeatV1(
    _act0HypotheticalConceptTableV1(_w9ExampleTableBase),
    heroSeatId: 'co',
    activeSeatId: '',
  ),
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w12_decision_quality_intro',
  lessonTitle: 'Decision quality over outcome',
  lessonSubtitle: 'Mindset Bridge',
  caption: 'A good choice can lose. A poor choice can win.',
  hint: 'Judge choices by logic, not one card on river.',
  question: 'What should be judged first after a hand?',
  feedbackTitle: 'Mindset foundation.',
  feedbackReason:
      'Check how you made the choice. Then look at how the hand ends.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Judge the choice',
      body:
          'Check the facts you had when you chose. One win or loss does not prove the choice was sound. Tilt is when a strong feeling starts to steer how you play.',
      focusLabels: <String>['Process', 'Variance', 'Outcome bias'],
    ),
  ],
);

final _w12GoodFoldBadResultRunner = _w12DecisionQualityIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w12_good_fold_bad_result',
  caption:
      'You folded a marginal bluff-catcher and an opponent later showed a bluff.',
  hint: 'Do not auto-label by reveal result only.',
  question: 'How should you review this fold?',
  teachingSteps: const <Act0TeachingStepV1>[],
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'process_review',
      label: 'Check the cues before judging the result',
      isCorrect: true,
      preferredLabel: 'Check the cues before judging the result',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Process beats reveal.',
      feedbackReason:
          'Review the price and the range you could reasonably give the opponent before they showed the bluff. This reveal can inform future decisions.',
    ),
    Act0RunnerOptionV1(
      id: 'instant_regret',
      label: 'Mark the fold suspicious because it lost',
      isCorrect: false,
      preferredLabel: 'Check the cues before judging the result',
      betterAnswerLabel: 'Check the cues before judging the result',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Outcome trap.',
      feedbackReason:
          'After folding a marginal bluff-catcher when an opponent shows a bluff, judging by the single reveal pushes you into loose, losing calls next time.',
    ),
    Act0RunnerOptionV1(
      id: 'ignore_hand',
      label: 'Skip the cue check and move to the next hand',
      isCorrect: false,
      preferredLabel: 'Check the cues before judging the result',
      betterAnswerLabel: 'Check the cues before judging the result',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Avoids tilt.',
      feedbackReason:
          'After folding a marginal bluff-catcher against a shown bluff, moving on without checking the price and range cues misses valuable information about that opponent.',
    ),
  ],
);

final _w12BadCallGoodResultRunner = _w12DecisionQualityIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w12_bad_call_good_result',
  feedbackSignalId: 'process_over_outcome',
  caption: 'Suppose a loose call wins after a lucky river.',
  hint: 'Winning the pot does not guarantee a good decision.',
  question:
      'Suppose a loose call wins after a lucky river. What is the best mindset response?',
  teachingSteps: const <Act0TeachingStepV1>[],
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'celebrate_only',
      label: 'Result was good so process is good',
      isCorrect: false,
      preferredLabel: 'Flag the loose call as a possible leak',
      betterAnswerLabel: 'Flag the loose call as a possible leak',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Result bias.',
      feedbackReason:
          'A lucky river tells you how this loose call turned out. Calling it good process without checking the price and range can hide a leak.',
    ),
    Act0RunnerOptionV1(
      id: 'flag_leak',
      label: 'Flag the loose call as a possible leak',
      isCorrect: true,
      preferredLabel: 'Flag the loose call as a possible leak',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Win can hide a leak.',
      feedbackReason:
          'Good results can mask weak process. Flagging the decision keeps your learning honest.',
    ),
    Act0RunnerOptionV1(
      id: 'self_blame',
      label: 'Call was lucky so confidence is gone',
      isCorrect: false,
      preferredLabel: 'Flag the loose call as a possible leak',
      betterAnswerLabel: 'Flag the loose call as a possible leak',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too harsh.',
      feedbackReason:
          'After a loose call wins on a lucky river, letting confidence collapse turns a calm process audit into emotional tilt on the next hands.',
    ),
  ],
);

final _w12DecisionQualityRecapRunner = _w12DecisionQualityIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w12_decision_quality_recap',
  caption: 'Lesson learned: process quality is the anchor under variance.',
  hint: 'Outcome is data, not verdict.',
  question: 'What is the process-quality takeaway?',
  feedbackTitle: 'Process takeaway.',
  feedbackReason:
      'Stable improvement comes from process audits that survive both wins and losses.',
  teachingSteps: const <Act0TeachingStepV1>[],
);

final _w12TiltResetIntroRunner = _w12DecisionQualityIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w12_tilt_reset_intro',
  lessonTitle: 'Tilt reset protocol',
  caption: 'A loss or a big win can make you rush. A short pause can help.',
  hint: 'Take one breath and come back to your plan.',
  question: 'What is the purpose of a tilt reset?',
  feedbackTitle: 'Reset foundation.',
  feedbackReason: 'A pause gives you time to see the new hand clearly.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Fast reset routine.',
      body:
          'Name what you feel. Take a breath. Look at your cards, the board, and the next bet. Take a break if you still feel the urge to rush.',
      focusLabels: <String>['Name the feeling', 'Breathe', 'Read the new hand'],
    ),
  ],
);

final _w12AfterBadBeatResetRunner = _w12TiltResetIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w12_after_bad_beat_reset',
  caption: 'You lose a big all-in as favorite and feel immediate anger.',
  hint: 'Reset before next hand starts.',
  question: 'What is the cleaner immediate action?',
  teachingSteps: const <Act0TeachingStepV1>[],
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'revenge_hand',
      label: 'Take the next thin edge to regain chips',
      isCorrect: false,
      preferredLabel: 'Run short reset protocol before next major spot',
      betterAnswerLabel: 'Run short reset protocol before next major spot',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Tilt pattern.',
      feedbackReason:
          'Right after losing a big all-in as favorite, forcing the next thin edge to win chips back compounds variance losses with tilt mistakes.',
    ),
    Act0RunnerOptionV1(
      id: 'quit_immediately',
      label: 'End the orbit before deciding to continue',
      isCorrect: false,
      preferredLabel: 'Run short reset protocol before next major spot',
      betterAnswerLabel: 'Run short reset protocol before next major spot',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Sometimes valid.',
      feedbackReason:
          'After losing an all-in as the favorite, a short pause gives you a chance to settle before deciding whether you are ready to play the next hand.',
    ),
    Act0RunnerOptionV1(
      id: 'reset_protocol',
      label: 'Run short reset protocol before next major spot',
      isCorrect: true,
      preferredLabel: 'Run short reset protocol before next major spot',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Reset before next hand.',
      feedbackReason:
          'A fast reset protects your next decisions from emotional carryover.',
    ),
  ],
);

final _w12AfterMistakeResetRunner = _w12TiltResetIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w12_after_mistake_reset',
  caption: 'You realize you made an avoidable call error.',
  hint: 'Use reset to prevent second error spiral.',
  question: 'What response keeps discipline highest?',
  teachingSteps: const <Act0TeachingStepV1>[],
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'note_and_reset',
      label: 'Log leak briefly and reset to current hand',
      isCorrect: true,
      preferredLabel: 'Log leak briefly and reset to current hand',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Log it, then reset.',
      feedbackReason:
          'Quick logging plus reset preserves learning without carrying emotional noise into next hands.',
    ),
    Act0RunnerOptionV1(
      id: 'self_attack',
      label: 'Replay the mistake for the next few hands',
      isCorrect: false,
      preferredLabel: 'Log leak briefly and reset to current hand',
      betterAnswerLabel: 'Log leak briefly and reset to current hand',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Harmful spiral.',
      feedbackReason:
          'After making an avoidable call error, replaying the mistake across the next few hands distracts from live cues and triggers a second costly error.',
    ),
    Act0RunnerOptionV1(
      id: 'deny_mistake',
      label: 'Skip the note and rely on memory',
      isCorrect: false,
      preferredLabel: 'Log leak briefly and reset to current hand',
      betterAnswerLabel: 'Log leak briefly and reset to current hand',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Protects emotion short term.',
      feedbackReason:
          'After an avoidable call error, skipping the note to rely on memory lets the leak slip away unreviewed after the session.',
    ),
  ],
);

final _w12TiltResetRecapRunner = _w12TiltResetIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w12_tilt_reset_recap',
  caption: 'Lesson learned: reset protects process under emotional pressure.',
  hint: 'Fast reset now prevents leak cascade later.',
  question: 'What is the reset takeaway?',
  feedbackTitle: 'Reset takeaway.',
  feedbackReason:
      'Consistent small resets are a core bridge from knowledge to stable execution.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Reset before the next deal.',
      body:
          'After a bad beat or a clear error, pause for one breath and label the reaction without judging yourself. Restate your single session focus and shrink the next few hands to simple, clean choices. A short deliberate reset keeps one rough pot from spreading across the rest of your session.',
      focusLabels: <String>['Pause briefly', 'Reset focus', 'Clean next hand'],
    ),
  ],
);

final _w12ConfidenceDisciplineIntroRunner = _w12TiltResetIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w12_confidence_intro',
  lessonTitle: 'Confidence with discipline',
  caption: 'Confident play means clear actions, not ego battles.',
  hint: 'Assertive decisions still obey plan and evidence.',
  question: 'What balance should confidence hold?',
  feedbackTitle: 'Confidence foundation.',
  feedbackReason:
      'Best mindset combines calm assertiveness with disciplined filters on risk and evidence.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Assertive, not reckless.',
      body:
          'Take clear lines when evidence supports them. Avoid ego calls, revenge bluffs, or proving points.',
      focusLabels: <String>['Assertive', 'Evidence', 'Discipline'],
    ),
  ],
);

final _w12AssertiveNotEgoRunner = _w12ConfidenceDisciplineIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w12_assertive_not_ego',
  caption: 'An opponent needles you after winning a pot.',
  hint: 'Decision quality should not react to table talk.',
  question: 'What is the stronger mindset line?',
  teachingSteps: const <Act0TeachingStepV1>[],
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'prove_point',
      label: 'Widen the next close spot to answer back',
      isCorrect: false,
      preferredLabel: 'Stick to process and your planned line',
      betterAnswerLabel: 'Stick to process and your planned line',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Ego trap.',
      feedbackReason:
          'After an opponent needles you for winning a pot, widening your next close spot to answer back risks chips on weak hands just to satisfy ego.',
    ),
    Act0RunnerOptionV1(
      id: 'stick_process',
      label: 'Stick to process and your planned line',
      isCorrect: true,
      preferredLabel: 'Stick to process and your planned line',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Process ignores table talk.',
      feedbackReason:
          'Process-led confidence ignores ego hooks and preserves decision quality.',
    ),
    Act0RunnerOptionV1(
      id: 'play_scared',
      label: 'Play overly scared to avoid conflict',
      isCorrect: false,
      preferredLabel: 'Stick to process and your planned line',
      betterAnswerLabel: 'Stick to process and your planned line',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Safer but capped.',
      feedbackReason:
          'After table talk from an opponent, playing overly scared forfeits profitable value and steal spots out of fear of conflict.',
    ),
  ],
);

final _w12DisciplineUnderPressureRunner = _w12ConfidenceDisciplineIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w12_discipline_under_pressure',
  caption: 'Deep in session, fatigue rises and decisions speed up.',
  hint: 'Discipline means slowing only the critical spots.',
  question: 'What is the best pressure adjustment?',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Slow down on large pots.',
      body:
          'Fatigue speeds up choices. Take one brief pause before you call, bet, or fold in a large pot.',
      focusLabels: <String>['Fatigue cue', 'Brief pause', 'Large pot'],
    ),
  ],
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'autopilot',
      label: 'Keep normal pace through large pots',
      isCorrect: false,
      preferredLabel: 'Pause briefly on high-EV decision nodes',
      betterAnswerLabel: 'Pause briefly on high-EV decision nodes',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Leak risk.',
      feedbackReason:
          'Deep in a session when fatigue rises, keeping fast autopilot pace through large pots leads to rushed, expensive mistakes on high-EV decisions.',
    ),
    Act0RunnerOptionV1(
      id: 'tank_every_spot',
      label: 'Slow medium pots as much as major ones',
      isCorrect: false,
      preferredLabel: 'Pause briefly on high-EV decision nodes',
      betterAnswerLabel: 'Pause briefly on high-EV decision nodes',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Overcorrection.',
      feedbackReason:
          'Late-session fatigue makes attention scarce. Spending the same extra time on medium pots can leave less attention for the decisions with the most at stake.',
    ),
    Act0RunnerOptionV1(
      id: 'critical_pause',
      label: 'Pause briefly on high-EV decision nodes',
      isCorrect: true,
      preferredLabel: 'Pause briefly on high-EV decision nodes',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Pause on big nodes.',
      feedbackReason:
          'Small targeted pauses preserve discipline where it matters most without killing flow.',
    ),
  ],
);

final _w12PrettyHandBadPriceFoldRunner = _w12ConfidenceDisciplineIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w12_pretty_hand_bad_price_fold',
  caption:
      "CO bets both the flop and the turn. Both start the river with 100 BB behind. CO rarely bluffs and bets 18 BB into 20 BB.",
  hint: 'Do not make a stubborn call only because the hand looks pretty.',
  question: 'What is the cleaner disciplined action?',
  table: _day7TableV1(
    hero: 'btn',
    hand: _heroKqCards.map((card) => card.label).join(' '),
    street: PokerStreet.river,
    actor: 'btn',
    board: _boardK7294Cards,
    folded: const {"utg", "hj", "sb", "bb"},
    stacks: const {'btn': 108.75, 'co': 108.75},
    entries: [
      ..._w11QJsPreflopContributions,
      const Act0ContributionV1(
        PokerStreet.flop,
        'co',
        Act0ContributionKindV1.wager,
        2.5,
      ),
      const Act0ContributionV1(
        PokerStreet.flop,
        'btn',
        Act0ContributionKindV1.wager,
        2.5,
      ),
      const Act0ContributionV1(
        PokerStreet.turn,
        'co',
        Act0ContributionKindV1.wager,
        3.5,
      ),
      const Act0ContributionV1(
        PokerStreet.turn,
        'btn',
        Act0ContributionKindV1.wager,
        3.5,
      ),
      const Act0ContributionV1(
        PokerStreet.river,
        'co',
        Act0ContributionKindV1.wager,
        18,
      ),
    ],
    history: const [
      Act0ActionTrailItemV1.note(label: "SB blind 0.5 BB"),
      Act0ActionTrailItemV1.note(label: "BB blind 1 BB"),
      Act0ActionTrailItemV1.note(label: "6 antes of 0.25 BB each"),
      Act0ActionTrailItemV1(label: "UTG folds"),
      Act0ActionTrailItemV1(label: "HJ folds"),
      Act0ActionTrailItemV1(label: "CO raises to 2.5 BB"),
      Act0ActionTrailItemV1(label: "BTN calls 2.5 BB"),
      Act0ActionTrailItemV1(label: "SB folds"),
      Act0ActionTrailItemV1(label: "BB folds"),
      Act0ActionTrailItemV1(label: "Flop: CO bets 2.5 BB"),
      Act0ActionTrailItemV1(label: "BTN calls 2.5 BB"),
      Act0ActionTrailItemV1(label: "Turn: CO bets 3.5 BB"),
      Act0ActionTrailItemV1(label: "BTN calls 3.5 BB"),
      Act0ActionTrailItemV1(label: "River: CO bets 18 BB"),
    ],
    bets: const {
      'co': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.bet,
        label: 'Bet',
        amountLabel: '18 BB',
      ),
    },
  ).copyWith(showDecisionPremise: true),
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'fold_river',
      label: 'Fold the river',
      isCorrect: true,
      preferredLabel: 'Fold the river',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Calm fold.',
      feedbackReason:
          'Calling 18 BB makes a 56 BB pot, so you need about 32% equity if the call closes the action. Folding is reasonable if K-Q falls below that threshold against CO’s betting range. The tight read supports caution, and the exact range is unknown.',
    ),
    Act0RunnerOptionV1(
      id: 'hero_call',
      label: 'Call down anyway with top pair',
      isCorrect: false,
      preferredLabel: 'Fold the river',
      betterAnswerLabel: 'Fold the river',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Pretty-hand trap.',
      feedbackReason:
          'Tight CO bets 18 BB into 20 BB on K-7-2-9-4. Calling makes the pot 56 BB, so K-Q needs about 32% equity. The tight read makes it harder to find enough bluffs or worse value hands.',
    ),
    Act0RunnerOptionV1(
      id: 'jam_back',
      label: 'Raise large to end the decision now',
      isCorrect: false,
      preferredLabel: 'Fold the river',
      betterAnswerLabel: 'Fold the river',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too dramatic.',
      feedbackReason:
          'The river pot is now 38 BB after CO’s 18 BB bet. A large raise adds risk against a tight range when better hands may call and worse hands may fold.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Pretty hands still obey price.',
      body:
          'Use the same routine even when the hand looks attractive: seat, hand, board, price, stack and action, then the clean action.',
      focusLabels: <String>[
        'Top pair',
        'Bad price',
        'Tight action',
        'Fold clean',
      ],
    ),
  ],
);

final _w12RevengeRaiseTrapRunner = _w12ConfidenceDisciplineIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w12_revenge_raise_trap',
  caption:
      "CO bluffed you last orbit and taunts you now. Both start the flop with 35 BB behind. CO bets 2 BB into 8 BB.",
  hint:
      'Do not raise just to take control when the table read says stay simple.',
  question: 'What is the clean discipline line?',
  table: _day7TableV1(
    hero: 'btn',
    hand: _heroQJsCards.map((card) => card.label).join(' '),
    street: PokerStreet.flop,
    actor: 'btn',
    board: _boardJ74FlopCards,
    folded: const {"utg", "hj", "sb", "bb"},
    stacks: const {'btn': 37.75, 'co': 37.75},
    entries: [
      ..._w11QJsPreflopContributions,
      const Act0ContributionV1(
        PokerStreet.flop,
        'co',
        Act0ContributionKindV1.wager,
        2,
      ),
    ],
    history: const [
      Act0ActionTrailItemV1.note(label: "SB blind 0.5 BB"),
      Act0ActionTrailItemV1.note(label: "BB blind 1 BB"),
      Act0ActionTrailItemV1.note(label: "6 antes of 0.25 BB each"),
      Act0ActionTrailItemV1.note(label: "CO needled you last orbit"),
      Act0ActionTrailItemV1(label: "UTG folds"),
      Act0ActionTrailItemV1(label: "HJ folds"),
      Act0ActionTrailItemV1(label: "CO raises to 2.5 BB"),
      Act0ActionTrailItemV1(label: "BTN calls 2.5 BB"),
      Act0ActionTrailItemV1(label: "SB folds"),
      Act0ActionTrailItemV1(label: "BB folds"),
      Act0ActionTrailItemV1(label: "Flop: CO bets 2 BB"),
    ],
    bets: const {
      'co': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.bet,
        label: 'Bet',
        amountLabel: '2 BB',
      ),
    },
  ).copyWith(showDecisionPremise: true),
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'raise_to_take_control',
      label: 'Raise now to take control back',
      isCorrect: false,
      preferredLabel: 'Call once and keep the pot controlled',
      betterAnswerLabel: 'Call once and keep the pot controlled',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Revenge leak.',
      feedbackReason:
          'On the J-7-4 flop from BTN at 35 BB effective facing CO\'s 2 BB bet into an 8 BB pot, raising out of revenge can grow the pot and fold out CO\'s bluffs while isolating you against stronger hands.',
    ),
    Act0RunnerOptionV1(
      id: 'call_once',
      label: 'Call once and keep the pot controlled',
      isCorrect: true,
      preferredLabel: 'Call once and keep the pot controlled',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Stable line.',
      feedbackReason:
          'A 2 BB call makes a 12 BB pot, about 17% immediate pot odds. Calling is a reasonable way to keep the pot small if CO bets enough weaker hands. One earlier bluff gives little evidence about CO’s range here.',
    ),
    Act0RunnerOptionV1(
      id: 'snap_fold_noise',
      label: 'Fold now to avoid the annoying player',
      isCorrect: false,
      preferredLabel: 'Call once and keep the pot controlled',
      betterAnswerLabel: 'Call once and keep the pot controlled',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Emotion still steering.',
      feedbackReason:
          'CO’s 2 BB bet on J-7-4 brings the pot to 10 BB. Folding out of irritation gives up a low-cost chance to continue in position against weaker bets.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Noise is not a cue.',
      body:
          'Real play rewards stable decisions more than dramatic decisions. Ignore ego hooks and return to the table read.',
      focusLabels: <String>['Position', 'Small price', 'Top pair', 'No ego'],
    ),
  ],
);

final _w12ConfidenceDisciplineRecapRunner = _w12ConfidenceDisciplineIntroRunner
    .copyWith(
      phase: Act0LessonPhaseV1.review,
      lessonId: 'w12_confidence_recap',
      caption:
          'Lesson learned: calm confidence plus discipline is stable edge.',
      hint: 'Assertive line, evidence filter, no ego side quests.',
      question: 'What is the confidence-discipline takeaway?',
      feedbackTitle: 'Discipline takeaway.',
      feedbackReason:
          'Mindset edge comes from repeatable emotional control and disciplined execution, not mood swings.',
      teachingSteps: const <Act0TeachingStepV1>[
        Act0TeachingStepV1(
          title: 'Calm lines over ego.',
          body:
              'Confident discipline means choosing to bet, call, or fold from table evidence rather than table talk.',
          focusLabels: <String>['Evidence', 'Calm line', 'No ego'],
        ),
      ],
    );

final _w12CheckpointProcessLineRunner = _w12ConfidenceDisciplineIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w12_checkpoint_process_line',
  feedbackSignalId: 'process_over_outcome',
  caption: 'A correct line loses in a high-variance pot.',
  hint: 'Process verdict comes before emotional verdict.',
  question:
      'Suppose a sound decision loses a high-variance pot. What is the best immediate response?',
  teachingSteps: const <Act0TeachingStepV1>[],
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'outcome_only',
      label: 'Outcome proves decision quality',
      isCorrect: false,
      preferredLabel: 'Audit process first, then outcome',
      betterAnswerLabel: 'Audit process first, then outcome',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Bias warning.',
      feedbackReason:
          'When a sound line loses a high-variance pot, treating the outcome as proof of a bad decision causes you to abandon winning plays.',
    ),
    Act0RunnerOptionV1(
      id: 'avoid_review',
      label: 'Skip review to avoid frustration',
      isCorrect: false,
      preferredLabel: 'Audit process first, then outcome',
      betterAnswerLabel: 'Audit process first, then outcome',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Protective instinct.',
      feedbackReason:
          'After a sound decision loses a high-variance pot, skipping review to avoid frustration leaves you unsure whether the price and range read were actually solid.',
    ),
    Act0RunnerOptionV1(
      id: 'process_first',
      label: 'Audit process first, then outcome',
      isCorrect: true,
      preferredLabel: 'Audit process first, then outcome',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Process held steady.',
      feedbackReason:
          'That sequence keeps you grounded through variance and supports long-term growth.',
    ),
  ],
);

final _w12CheckpointResetLineRunner = _w12ConfidenceDisciplineIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w12_checkpoint_reset_line',
  caption: 'You feel tilt signs after two rough spots in a row.',
  hint: 'Reset should be fast and repeatable.',
  question: 'What is the cleaner bridge action?',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Reset before the next pot.',
      body:
          'Two rough pots in a row are a cue to pause, reset your focus, and return to disciplined call-or-fold choices.',
      focusLabels: <String>['Pause', 'Reset', 'Re-anchor'],
    ),
  ],
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'run_reset',
      label: 'Run brief reset and re-anchor to plan',
      isCorrect: true,
      preferredLabel: 'Run brief reset and re-anchor to plan',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Reset keeps quality steady.',
      feedbackReason:
          'Reset and re-anchor protects next decisions without derailing session rhythm.',
    ),
    Act0RunnerOptionV1(
      id: 'revenge_mode',
      label: 'Take the next close spot to recover momentum',
      isCorrect: false,
      preferredLabel: 'Run brief reset and re-anchor to plan',
      betterAnswerLabel: 'Run brief reset and re-anchor to plan',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Tilt escalation.',
      feedbackReason:
          'When tilt signs appear after two rough spots in a row, jumping into the next close spot to recover momentum bleeds more chips while emotions are hot.',
    ),
    Act0RunnerOptionV1(
      id: 'deny_tilt',
      label: 'Keep playing and check emotions later',
      isCorrect: false,
      preferredLabel: 'Run brief reset and re-anchor to plan',
      betterAnswerLabel: 'Run brief reset and re-anchor to plan',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Common response.',
      feedbackReason:
          'After two rough spots in a row, continuing without an explicit reset lets hidden tilt degrade your next high-stakes decision.',
    ),
  ],
);

final _w12CheckpointDisciplineLineRunner = _w12ConfidenceDisciplineIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w12_checkpoint_discipline_line',
  caption: 'A player taunts you into marginal high-variance spots.',
  hint: 'Discipline means evidence over ego.',
  question: 'Which line is strongest?',
  teachingSteps: const <Act0TeachingStepV1>[],
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'ego_line',
      label: 'Take thin line to win respect',
      isCorrect: false,
      preferredLabel: 'Take only evidence-backed lines',
      betterAnswerLabel: 'Take only evidence-backed lines',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Ego leak.',
      feedbackReason:
          'When a player taunts you into marginal high-variance spots, taking a thin line to win respect risks big pots without the range or price edge to back it up.',
    ),
    Act0RunnerOptionV1(
      id: 'evidence_line',
      label: 'Take only evidence-backed lines',
      isCorrect: true,
      preferredLabel: 'Take only evidence-backed lines',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Evidence beats respect.',
      feedbackReason:
          'Evidence-first discipline is the stable bridge into deeper strategic worlds.',
    ),
    Act0RunnerOptionV1(
      id: 'fear_line',
      label: 'Fold all close spots now',
      isCorrect: false,
      preferredLabel: 'Take only evidence-backed lines',
      betterAnswerLabel: 'Take only evidence-backed lines',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Defensive but capped.',
      feedbackReason:
          'Folding a close spot to avoid a player’s taunts can surrender an edge your read of their range and the price still support.',
    ),
  ],
);

final _w12CheckpointFullLoopLineRunner = _w12ConfidenceDisciplineIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w12_checkpoint_full_loop_line',
  caption:
      "Your bluff failed last orbit. Both start this flop with 25 BB behind. CO bets 2 BB into 8 BB.",
  hint:
      'Use the same decision routine even after a mistake: seat, hand, board, price, stack and action, then the clean action.',
  question: 'What keeps the next decision stable?',
  table: _day7TableV1(
    hero: 'btn',
    hand: _heroAJsCards.map((card) => card.label).join(' '),
    street: PokerStreet.flop,
    actor: 'btn',
    board: _boardA84TwoToneCards,
    folded: const {"utg", "hj", "sb", "bb"},
    stacks: const {'btn': 27.75, 'co': 27.75},
    entries: [
      ..._w11QJsPreflopContributions,
      const Act0ContributionV1(
        PokerStreet.flop,
        'co',
        Act0ContributionKindV1.wager,
        2,
      ),
    ],
    history: const [
      Act0ActionTrailItemV1.note(label: "SB blind 0.5 BB"),
      Act0ActionTrailItemV1.note(label: "BB blind 1 BB"),
      Act0ActionTrailItemV1.note(label: "6 antes of 0.25 BB each"),
      Act0ActionTrailItemV1.note(label: "Last orbit: loose bluff"),
      Act0ActionTrailItemV1(label: "UTG folds"),
      Act0ActionTrailItemV1(label: "HJ folds"),
      Act0ActionTrailItemV1(label: "CO raises to 2.5 BB"),
      Act0ActionTrailItemV1(label: "BTN calls 2.5 BB"),
      Act0ActionTrailItemV1(label: "SB folds"),
      Act0ActionTrailItemV1(label: "BB folds"),
      Act0ActionTrailItemV1(label: "Flop: CO bets 2 BB"),
    ],
    bets: const {
      'co': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.bet,
        label: 'Bet',
        amountLabel: '2 BB',
      ),
    },
  ).copyWith(showDecisionPremise: true),
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'raise_to_recover',
      label: 'Raise to recover confidence',
      isCorrect: false,
      preferredLabel: 'Call with the same routine',
      betterAnswerLabel: 'Call with the same routine',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Confidence chase.',
      feedbackReason:
          'CO bets 2 BB into 8 BB on A-8-4. Raising to make up for last orbit’s loose bluff builds a larger pot and may drive out the weaker hands you could keep in by calling.',
    ),
    Act0RunnerOptionV1(
      id: 'fold_scared',
      label: 'Fold to play safer now',
      isCorrect: false,
      preferredLabel: 'Call with the same routine',
      betterAnswerLabel: 'Call with the same routine',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too reactive.',
      feedbackReason:
          'CO’s 2 BB bet brings the pot to 10 BB. Folding because of last orbit’s mistake gives up a low-cost chance to continue in position with top pair.',
    ),
    Act0RunnerOptionV1(
      id: 'call_clean',
      label: 'Call with the same routine',
      isCorrect: true,
      preferredLabel: 'Call with the same routine',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Strong reset.',
      feedbackReason:
          'Start with top pair, position and the 2 BB price. Calling is a reasonable controlled line if CO bets enough weaker hands. The optimal line depends on CO’s range and later action. Review the previous bluff separately.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Stable routine beats emotional correction.',
      body:
          'A prior mistake should not rewrite the next decision. Real play gets stronger when the same clean routine survives noise, temptation, and regret.',
      focusLabels: <String>[
        'After mistake',
        'Seat-hand-board-price',
        '25 BB',
        'Stay stable',
      ],
    ),
  ],
);

Act0LessonTaskV1 _w12Task(
  String id,
  String title,
  String caption,
  String question, {
  required int correct,
  required List<(String, String, String, String?)> choices,
  Act0TableStateV1? table,
  Act0TeachingStepV1? teaching,
}) {
  final answer = choices[correct].$2;
  return Act0LessonTaskV1(
    taskId: id,
    title: title,
    phase: Act0LessonPhaseV1.drill,
    rewardXp: 10,
    stepKind: Act0LessonStepKindV1.practice,
    runner: _w12DecisionQualityIntroRunner.copyWith(
      lessonId: id,
      phase: Act0LessonPhaseV1.drill,
      caption: caption,
      question: question,
      hint: '',
      hintPolicy: Act0HintPolicyV1.hidden,
      feedbackTitle: 'Review your choice.',
      feedbackReason: choices[correct].$3,
      teachingSteps: [if (teaching != null) teaching],
      table: table ?? _w12DecisionQualityIntroRunner.table,
      options: [
        for (final (index, (choiceId, label, reason, seat)) in choices.indexed)
          Act0RunnerOptionV1(
            id: choiceId,
            label: label,
            seatId: seat,
            isCorrect: index == correct,
            preferredLabel: answer,
            quality: index == correct
                ? Act0FeedbackQualityV1.correct
                : Act0FeedbackQualityV1.wrong,
            feedbackTitle: index == correct ? 'Correct.' : 'Look again.',
            feedbackReason: reason,
          ),
      ],
    ),
  );
}

final _w12_river_ev_small_price = _w12Task(
  'w12_river_ev_small_price',
  'A small river price',
  'CO bets 2 BB. Your model has seven better hands and three bluffs out of ten bets. CO will call a raise with the better hands and fold the bluffs.',
  'Which action has the best EV in this model?',
  correct: 1,
  choices: const [
    (
      'fold',
      'Fold',
      'Fold gives up a gain. You win 3 times in 10 at a price that needs about 21%.',
      null,
    ),
    (
      'call',
      'Call',
      'A 2 BB call needs 2 out of 9.5, or about 21%. You win 30% in the model. A call gains 0.85 BB on average.',
      null,
    ),
    (
      'raise',
      'Raise',
      'Raising puts in extra chips when the better hands call. Against bluffs it earns no more than a call.',
      null,
    ),
  ],
  table: _day7PostflopV1(
    'bb',
    'Ac 8c',
    'As Td 7h 3c 2d',
    opponent: 'co',
    openBb: 2.5,
    betBb: 2,
    showTurn: true,
  ).copyWith(showDecisionPremise: true),
  teaching: const Act0TeachingStepV1(
    title: 'What is EV?',
    body:
        'Expected value, or EV, is the average gain or loss from a choice made many times. Recall W4. Divide the call by the pot after your call. Compare that price with your chance to win. On the river, no more cards come. Work out which bets you beat now.',
  ),
);

final _w12_river_ev_costly_call = _w12Task(
  'w12_river_ev_costly_call',
  'A costly river call',
  'BB bets 5 BB. Two of ten bets are bluffs you beat. The rest beat your kings. BB folds the bluffs to a raise and calls with the better hands.',
  'Which action has the best EV in this model?',
  correct: 0,
  choices: const [
    (
      'fold',
      'Fold',
      'Five out of 15.5 is about 32%. Your chance to win is 20%. Fold to save the 5 BB.',
      null,
    ),
    (
      'call',
      'Call',
      'The bet costs 5 BB to call. With just two wins in ten bets, the cost of the eight losses is too high.',
      null,
    ),
    (
      'raise',
      'Raise',
      'A raise asks BB to fold. The model says the better hands stay and make you pay more.',
      null,
    ),
  ],
  table: _day7PostflopV1(
    'co',
    'Kd 9c',
    'Ks Jh 8d 4s 2h',
    openBb: 2.5,
    betBb: 5,
    showTurn: true,
  ).copyWith(showDecisionPremise: true),
);

final _w12_confidence_spr = _w12Task(
  'w12_confidence_spr',
  'Check how much is at risk',
  'You were quick to call in the last hand. Stop and read this flop. Both live stacks have 16.5 BB left. The pot is 5.5 BB.',
  'What is the SPR at the start of this flop?',
  correct: 0,
  choices: const [
    (
      'choice_1',
      '3',
      '16.5 divided by 5.5 is 3. The most either player can put in from here is three times the pot.',
      null,
    ),
    (
      'choice_2',
      '6',
      'Six would count both stacks. Use just the smaller stack to see what each player can risk.',
      null,
    ),
    (
      'choice_3',
      '9',
      'Nine would need a stack of 49.5 BB. The live stacks are 16.5 BB each.',
      null,
    ),
  ],
  table: _day7TableV1(
    hero: 'bb',
    hand: 'Kc Js',
    street: PokerStreet.flop,
    board: _act0LessonCardsV1('Kd 8c 3h'),
    folded: const {'utg', 'co', 'btn', 'sb'},
    stacks: const {'hj': 19, 'bb': 19},
    entries: const [
      ..._act0LessonBlinds,
      Act0ContributionV1(
        PokerStreet.preflop,
        'hj',
        Act0ContributionKindV1.wager,
        2.5,
      ),
      Act0ContributionV1(
        PokerStreet.preflop,
        'bb',
        Act0ContributionKindV1.wager,
        1.5,
      ),
    ],
    history: const [
      Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
      Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
      Act0ActionTrailItemV1(label: 'UTG folds'),
      Act0ActionTrailItemV1(label: 'HJ raises to 2.5 BB'),
      Act0ActionTrailItemV1(label: 'CO folds'),
      Act0ActionTrailItemV1(label: 'BTN folds'),
      Act0ActionTrailItemV1(label: 'SB folds'),
      Act0ActionTrailItemV1(label: 'BB calls 1.5 BB'),
    ],
    bets: const {},
  ).copyWith(showDecisionPremise: true),
);

final _w12_river_ev_turn_draw_miss = _w12Task(
  'w12_river_ev_turn_draw_miss',
  'The draw missed',
  'You had a heart draw with one card to come. The river is Jd. You beat one in 10 CO bets. CO bets 3 BB and will call a raise with its value hands.',
  'Which action has the best EV in this model?',
  correct: 0,
  choices: const [
    (
      'fold',
      'Fold',
      'The river is a diamond. The price is 3 out of 11.5, about 26%. One win in ten is too few.',
      null,
    ),
    (
      'call',
      'Call',
      'There are no cards to come after Jd. Counting the old heart outs would sell you a chance that has passed.',
      null,
    ),
    (
      'raise',
      'Raise',
      'With ace high on this river, the raise spends more against CO’s better hands, which will call.',
      null,
    ),
  ],
  table: _day7PostflopV1(
    'bb',
    'Ah Qh',
    'Kh 8h 3c 2s Jd',
    opponent: 'co',
    openBb: 2.5,
    betBb: 3,
    showTurn: true,
  ).copyWith(showDecisionPremise: true),
);

final _w12_river_ev_draw_hit = _w12Task(
  'w12_river_ev_draw_hit',
  'The draw hit',
  'A heart lands on the river. BB bets 4 BB with a lower flush and will call one raise. Use this fixed hand model.',
  'Which action has the best EV in this model?',
  correct: 2,
  choices: const [
    (
      'fold',
      'Fold',
      'Your ace-high flush wins against BB’s lower flush on this board. A fold gives up the pot.',
      null,
    ),
    (
      'call',
      'Call',
      'Calling wins the pot, but BB would put in more with a lower flush in this model.',
      null,
    ),
    (
      'raise',
      'Raise',
      'Ah Th makes the best possible flush. BB will call one raise with a lower flush. Get paid for the out that hit.',
      null,
    ),
  ],
  table: _day7PostflopV1(
    'co',
    'Ah Th',
    'Kh 6h 2s 8c 3h',
    openBb: 2.5,
    betBb: 4,
    showTurn: true,
  ).copyWith(showDecisionPremise: true),
);

final _w12_river_ev_new_sample = _w12Task(
  'w12_river_ev_new_sample',
  'Price the last hand',
  'You lost a close call last hand. In this new hand you beat four of ten CO bets. CO bets 4 BB and keeps just the better hands if raised.',
  'Which action has the best EV in this model?',
  correct: 1,
  choices: const [
    (
      'fold',
      'Fold',
      '4 BB needs about 30% to call. This hand wins 40% in the model. The last result does not take that edge away.',
      null,
    ),
    (
      'call',
      'Call',
      '4 divided by 13.5 is about 30%. You win 40%. A call gains 1.4 BB on average in this model.',
      null,
    ),
    (
      'raise',
      'Raise',
      'The hands that beat your jacks will call a raise. Making the bet larger just adds a cost against those hands.',
      null,
    ),
  ],
  table: _day7PostflopV1(
    'bb',
    'Jh Tc',
    'Js 9h 6d 4c 2s',
    opponent: 'co',
    openBb: 2.5,
    betBb: 4,
    showTurn: true,
  ).copyWith(showDecisionPremise: true),
);

final _w12_turn_count_heart_outs = _w12Task(
  'w12_turn_count_heart_outs',
  'Count before the last card',
  'At the turn, you hold two hearts and see two more on the board. Recall the outs from W5 before you move on.',
  'How many unseen heart outs could fill the flush?',
  correct: 1,
  choices: const [
    (
      'choice_1',
      '7',
      'Four hearts are seen. Taking six out of 13 would remove two hearts you have not seen.',
      null,
    ),
    (
      'choice_2',
      '9',
      '13 hearts minus the four you see leaves nine. A heart on the river makes your flush.',
      null,
    ),
    (
      'choice_3',
      '11',
      'Eleven skips the two hearts at your seat. Both private and board cards are already known.',
      null,
    ),
  ],
  table: _day7PostflopV1(
    'bb',
    'Ah Qh',
    'Kh 8h 3c 2s',
    opponent: 'co',
    openBb: 2.5,
  ).copyWith(showDecisionPremise: true),
);

final _w12_tilt_after_river_beat = _w12Task(
  'w12_tilt_after_river_beat',
  'Pause after a bad beat',
  'Last hand, your kings lost when an ace fell as the last card. Now CO bets on a new flop. You feel a rush to win it back.',
  'What should you do before you pick an action?',
  correct: 1,
  choices: const [
    (
      'speed',
      'Speed up so you do not freeze',
      'The board is Q-7-2 and CO just put in 2 BB. Acting fast skips the new facts and can cost chips.',
      null,
    ),
    (
      'pause',
      'Take one breath and read the new hand',
      'You have a new pair on Q-7-2. Take a breath. Then read the price and the board before you choose.',
      null,
    ),
    (
      'target',
      'Focus on bets from CO for this orbit',
      'CO’s 2 BB bet belongs to this hand. Targeting a seat after a loss can make you pay for a grudge.',
      null,
    ),
  ],
  table: _day7PostflopV1(
    'bb',
    'Qc Td',
    'Qh 7d 2c',
    opponent: 'co',
    openBb: 2.5,
    betBb: 2,
    showTurn: true,
  ).copyWith(showDecisionPremise: true),
  teaching: const Act0TeachingStepV1(
    title: 'What is tilt?',
    body:
        'Tilt is when a strong feeling starts to steer how you play. After a loss, you may rush. After a big win, you may take risks you would not take before. Pause and read the new hand. If the urge stays, take a break.',
  ),
);

final _w12_tilt_after_lucky_win = _w12Task(
  'w12_tilt_after_lucky_win',
  'Pause after a lucky win',
  'You won a pot after a loose call last hand. In this new hand HJ opens, and you feel like your cards cannot miss. Take one breath and use the course chart.',
  'What action fits the new hand?',
  correct: 0,
  choices: const [
    (
      'fold',
      'Fold',
      'J-5 off suit is Weak. The good result last hand does not move it to a new row.',
      null,
    ),
    (
      'call',
      'Call',
      'HJ made it 2.5 BB. The first blind is already in. Calling pays another 1.5 BB with J-5 off suit.',
      null,
    ),
    (
      'raise',
      'Raise',
      'A raise risks more chips with J-5 off suit against an HJ open. The last win does not give this hand a better chance.',
      null,
    ),
  ],
  table: _day7TableV1(
    hero: 'bb',
    hand: 'Js 5d',
    street: PokerStreet.preflop,
    actor: 'bb',

    folded: const {'utg', 'co', 'btn', 'sb'},
    stacks: const {
      'utg': 40,
      'hj': 40,
      'co': 40,
      'btn': 40,
      'sb': 40,
      'bb': 40,
    },
    entries: const [
      ..._act0LessonBlinds,
      Act0ContributionV1(
        PokerStreet.preflop,
        'hj',
        Act0ContributionKindV1.wager,
        2.5,
      ),
    ],
    history: const [
      Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
      Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
      Act0ActionTrailItemV1(label: 'UTG folds'),
      Act0ActionTrailItemV1(label: 'HJ raises to 2.5 BB'),
      Act0ActionTrailItemV1(label: 'CO folds'),
      Act0ActionTrailItemV1(label: 'BTN folds'),
      Act0ActionTrailItemV1(label: 'SB folds'),
    ],
    bets: const {
      'sb': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.post,
        label: 'SB',
        amountLabel: '0.5 BB',
      ),
      'bb': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.post,
        label: 'BB',
        amountLabel: '1 BB',
      ),
      'hj': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.raise,
        label: 'Raise',
        amountLabel: '2.5 BB',
      ),
    },
  ).copyWith(showDecisionPremise: true),
);

final _world12MindsetCheckpointRunner = _w12ConfidenceDisciplineIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w12_mindset_checkpoint',
  caption:
      'Lesson learned: process, reset, and discipline stabilize your game.',
  hint:
      'Next you carry this mindset into deeper postflop decision trees and pressure spots.',
  question: 'What does this final mindset checkpoint add?',
  feedbackTitle: 'Mindset checkpoint.',
  feedbackReason:
      'You now have emotional, process, and discipline guardrails that keep strategic learning stable under variance and pressure.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Stability before complexity.',
      body:
          'Strong strategy growth requires stable mindset habits. Process audits, resets, and discipline make advanced learning stick.',
      focusLabels: <String>[
        'Process quality',
        'Tilt reset',
        'Discipline',
        'Postflop growth',
      ],
    ),
  ],
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'stable_bridge',
      label: 'A repeatable process-reset-discipline cycle',
      isCorrect: true,
      preferredLabel: 'A repeatable process-reset-discipline cycle',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Solid understanding.',
      feedbackReason:
          'Mindset stability is what lets complex strategic lessons stick instead of collapsing under pressure.',
    ),
    Act0RunnerOptionV1(
      id: 'optional_soft',
      label: 'Optional soft skill with little EV impact',
      isCorrect: false,
      preferredLabel: 'A repeatable process-reset-discipline cycle',
      betterAnswerLabel: 'A repeatable process-reset-discipline cycle',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Underestimation.',
      feedbackReason:
          'Across preflop and postflop spots, treating mindset as an optional soft skill leaves tilt and ego leaks draining chips from your technical edge.',
    ),
    Act0RunnerOptionV1(
      id: 'done_forever',
      label: 'One-time fix, no daily upkeep needed',
      isCorrect: false,
      preferredLabel: 'A repeatable process-reset-discipline cycle',
      betterAnswerLabel: 'A repeatable process-reset-discipline cycle',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Partly true start.',
      feedbackReason:
          'Across daily sessions, treating mindset as a one-time fix lets emotional drift and result bias creep back into large pots.',
    ),
  ],
);

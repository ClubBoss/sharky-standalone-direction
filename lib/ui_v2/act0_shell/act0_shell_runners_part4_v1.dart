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
  caption: 'Real table. K-7-2 rainbow flop. Hero has K-Q and SPR is 2.',
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
          'That is the low-SPR transfer. Top pair still needs board discipline, but SPR 2 leaves much less room and makes one bet push the hand closer to commitment.',
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
  caption: 'Real table. K-7-2 rainbow flop. Hero has K-Q and SPR is 8.',
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
          'Cash and tournament contexts are not the same. Tournament life creates extra downside for busting.',
    ),
    Act0RunnerOptionV1(
      id: 'fold_everything',
      label: 'Avoid all risk until paid',
      isCorrect: false,
      preferredLabel: 'Survival pressure matters more',
      betterAnswerLabel: 'Survival pressure matters more',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Playable caution.',
      feedbackReason:
          'Risk control is useful, but freezing is too passive. Good tournament play balances survival with selective aggression.',
    ),
  ],
);

final _w9ShortStackSurvivalRunner = _w9SurvivalIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w9_short_stack_survival',
  caption: 'You have 9 BB with blinds about to hit.',
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
      label: 'Wait only for premium pairs',
      isCorrect: false,
      preferredLabel: 'Take a reasonable all-in spot, first in or over a raise',
      betterAnswerLabel:
          'Take a reasonable all-in spot, first in or over a raise',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Too tight here.',
      feedbackReason:
          'Waiting only for monsters often costs too many blinds. In short-stack spots you need practical urgency, not perfect cards.',
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
          'Open-fold lines with very short stacks burn too many chips. Tournament pressure rewards cleaner commit-or-fold plans.',
    ),
  ],
);

final _w9SurvivalTradeoffRunner = _w9SurvivalIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w9_survival_stack_tradeoff',
  caption: 'Cash table can reload. Tournament table cannot.',
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
          'Cash chips still matter, but reload makes busting less final. Tournament pressure creates the bigger penalty for thin stack-offs.',
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
          'Hand strength matters in both formats, but tournament life changes the downside. The risk tradeoff is not equal.',
    ),
  ],
);

final _w9SurvivalRecapRunner = _w9SurvivalIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w9_survival_recap',
  caption: 'Lesson learned: tournament chips include survival value.',
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
      label: 'Wait for perfect premium only',
      isCorrect: false,
      preferredLabel: 'Use controlled urgency',
      betterAnswerLabel: 'Use controlled urgency',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Too narrow.',
      feedbackReason:
          'Perfect-card waiting in red zone usually leaks fold equity and stack health. You need practical action windows.',
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
          'Short tournament stacks often play poorly as passive flats. Clearer commit-or-fold lines are usually stronger.',
    ),
  ],
);

final _w9MZoneGreenRunner = _w9MRatioIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w9_m_ratio_green_zone',
  caption: 'Your M-ratio is in the green zone.',
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
          'Green zone does not require panic. You have time to use stronger setup and seat selection.',
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
          'Patience is good, but full passivity leaks value. Green zone is for selective pressure, not fear-based folding.',
    ),
  ],
);

final _w9MZoneYellowRunner = _w9MRatioIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w9_m_ratio_yellow_zone',
  caption: 'Your M-ratio is in the yellow zone.',
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
          'Waiting until the stack is critical often removes good options. Yellow zone is where you prepare instead of drift.',
    ),
    Act0RunnerOptionV1(
      id: 'panic_now',
      label: 'Force any spot immediately',
      isCorrect: false,
      preferredLabel: 'Prepare action windows before red-zone panic',
      betterAnswerLabel: 'Prepare action windows before red-zone panic',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Too rushed.',
      feedbackReason:
          'Yellow zone needs sharper planning, not panic. You still want selective aggression with room for better spots.',
    ),
  ],
);

final _w9MTableWindowTransferRunner = _w9MRatioIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w9_m_ratio_table_window_transfer',
  caption: 'Real table. Hero is BTN with A-J offsuit at 12 BB in yellow zone.',
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
      feedbackTitle: 'Sharp transfer.',
      feedbackReason:
          'That is the live-table yellow-zone transfer. You still have a little room, but urgency is real enough that you should prepare an action window before the stack slips into red zone.',
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
          'Yellow zone is where urgency starts to matter. If you wait for red zone, you lose cleaner timing and let the stack drift into panic decisions.',
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
          'Urgency is real, but yellow zone still leaves some room. The cleaner read is plan practical action windows before red-zone panic, not force every spot immediately.',
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
          'Pure chip-EV calls can be too loose near bubble pressure. Tournament survival increases the cost of busting.',
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
          'Over-folding gives away too much. The sharper line is selective discipline, not total shutdown.',
    ),
  ],
);

final _w9BigStackLeverageRunner = _w9BubblePressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w9_big_stack_leverage',
  caption: 'You cover both blinds near the bubble.',
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
          'Protection matters, but freezing misses one of the strongest bubble advantages of covering stacks.',
    ),
    Act0RunnerOptionV1(
      id: 'jam_any_two',
      label: 'Go all-in with any two cards every hand',
      isCorrect: false,
      preferredLabel: 'Apply selective open pressure',
      betterAnswerLabel: 'Apply selective open pressure',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not that extreme.',
      feedbackReason:
          'Leverage is selective, not reckless. You still need position, blockers, and player tendencies.',
    ),
  ],
);

final _w9BubbleShortStackRunner = _w9BubblePressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w9_bubble_short_stack',
  caption: 'You are the short stack near the bubble.',
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
      label: 'Fold every hand until payouts begin',
      isCorrect: false,
      preferredLabel: 'Still take practical all-in spots before blinded out',
      betterAnswerLabel: 'Still take practical all-in spots before blinded out',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Too passive.',
      feedbackReason:
          'Short stacks lose too much by freezing completely. Bubble caution is real, but waiting forever often removes all fold equity.',
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
          'Calling off light near bubble pressure is still expensive. The better plan is selective action, not loose stack-offs.',
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
      feedbackTitle: 'Strong transfer.',
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
          'Chip-only odds tell you the price of a call. If the call puts your tournament life at risk, payouts and the other stacks also matter.',
    ),
    Act0RunnerOptionV1(
      id: 'fold_anything_close',
      label: 'Over-fold every close hand',
      isCorrect: false,
      preferredLabel: 'Tighten thin stack-offs versus the covering blind',
      betterAnswerLabel: 'Tighten thin stack-offs versus the covering blind',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Right caution, too extreme.',
      feedbackReason:
          'If losing would eliminate you, tighten marginal calls. Strong hands can still call when the edge is large enough.',
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
      label: 'Panic with any two cards now',
      isCorrect: false,
      preferredLabel: 'Disciplined urgency in reasonable spots',
      betterAnswerLabel: 'Disciplined urgency in reasonable spots',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too extreme.',
      feedbackReason:
          'Urgency is real, but panic all-ins are not the target. You still choose spots with fold equity and blockers.',
    ),
    Act0RunnerOptionV1(
      id: 'wait_only_aa',
      label: 'Wait only for aces',
      isCorrect: false,
      preferredLabel: 'Disciplined urgency in reasonable spots',
      betterAnswerLabel: 'Disciplined urgency in reasonable spots',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Too tight.',
      feedbackReason:
          'Waiting for perfect hands often runs out the clock. Tournament pressure rewards practical urgency.',
    ),
  ],
);

final _w9CheckpointZoneLineRunner = _w9BubblePressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w9_checkpoint_zone_line',
  caption: 'Two players face similar hand strength in different M-ratio zones.',
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
          'Green-zone players usually have room to wait for cleaner spots.',
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
          'Hand class matters, but pressure context differs by zone. Urgency is not equal across stacks.',
    ),
  ],
);

final _w9CheckpointBubbleLineRunner = _w9BubblePressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w9_checkpoint_bubble_line',
  caption: 'Near bubble: medium stack faces big-stack open.',
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
          'Near bubble, tournament pressure changes the downside of busting. Pure chip-EV defense can be too loose.',
    ),
    Act0RunnerOptionV1(
      id: 'fold_everything',
      label: 'Fold every hand until payout',
      isCorrect: false,
      preferredLabel: 'Tighten defend and avoid thin all-ins',
      betterAnswerLabel: 'Tighten defend and avoid thin all-ins',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Too passive.',
      feedbackReason:
          'Full shutdown leaks too much equity. The stronger line is disciplined but still competitive.',
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
      title: 'Pressure before exploit.',
      body:
          'First map pressure with stack and payout context. Then choose exploit lines based on who is overfolding, calling too wide, or avoiding risk.',
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
      label: 'Adjust only by player type',
      isCorrect: false,
      preferredLabel: 'Map pressure first, then adjust by player',
      betterAnswerLabel: 'Map pressure first, then adjust by player',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Playable start.',
      feedbackReason:
          'Player reads matter, but tournament pressure changes incentives first. Good exploits combine both layers.',
    ),
    Act0RunnerOptionV1(
      id: 'pressure_then_adjust',
      label: 'Map pressure first, then adjust by player',
      isCorrect: true,
      preferredLabel: 'Map pressure first, then adjust by player',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Pressure comes first.',
      feedbackReason:
          'That sequence is the bridge to World 10: pressure context first, player-specific exploit second.',
    ),
    Act0RunnerOptionV1(
      id: 'cards_only',
      label: 'Map pressure, then copy every player read',
      isCorrect: false,
      preferredLabel: 'Map pressure first, then adjust by player',
      betterAnswerLabel: 'Map pressure first, then adjust by player',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Order is right, adjustment is too broad.',
      feedbackReason:
          'Pressure comes first, but player reads still need a specific tendency. Do not copy every exploit before checking who is overfolding, overcalling, or avoiding risk.',
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
          'That is the transfer. Bubble pressure hits the medium stack harder, while the covering stack can apply leverage.',
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
          'That answer is tempting because the hand may still look playable in chip-EV terms. But the dominant cue is bubble pressure: the medium stack pays a much bigger bust-out cost than in cash, so call freedom tightens.',
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
          'This looks disciplined because bubble fear is real. But full shutdown folds too much. The cleaner read is selective pressure awareness: tighten versus leverage, not panic-fold every spot.',
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
      title: 'Tag first, exploit second.',
      body:
          'Look for repeated behavior: overfolding, calling too wide, bluffing too much, or bluffing too little. Build the exploit from that one signal.',
      focusLabels: <String>['Tendency', 'Tag', 'Exploit'],
    ),
  ],
);

final _w10NitTagRunner = _w10PlayerTypeIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w10_nit_tag',
  caption: 'Villain folds to steals repeatedly and rarely 3-bets.',
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
          'A maniac over-aggresses. Here the evidence is repeated folds and low contest frequency; if the same player were raising and barreling often, the aggressive tag would become stronger.',
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
          'Avoid overfitting tiny samples, but repeated folds are enough to begin a light exploit adjustment. If this were only one folded orbit, waiting would be stronger.',
    ),
  ],
);

final _w10LoosePassiveTagRunner = _w10PlayerTypeIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w10_loose_passive_tag',
  caption: 'Villain calls often preflop and postflop but rarely raises.',
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
          'Tight-aggressive profiles fold more and raise more. This pattern is call-heavy and passive; if raises appeared with tight selection, the aggressive tag would fit better.',
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
          'Short samples can mislead, but repeated call-heavy behavior is actionable enough for mild value-heavy adjustment. If calls were isolated, keeping the tag light would be better.',
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
      'Villain raises often. In several earlier hands, you saw them make two bets and then show a weak hand.',
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
          'Nits fold and avoid pressure. This player is doing the opposite by pushing action too often.',
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
          'Tiny samples can be noisy, but repeated pressure plus weak showdowns is enough for a light over-aggressive tag.',
    ),
  ],
);

final _w10PlayerTypeRecapRunner = _w10PlayerTypeIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w10_player_type_recap',
  caption: 'Lesson learned: one tendency tag creates a cleaner exploit plan.',
  hint: 'Avoid complex labels before evidence is stable.',
  question: 'What is the tagging takeaway?',
  feedbackTitle: 'Player-type takeaway.',
  feedbackReason:
      'Start with one repeated tendency and one actionable adjustment. Complexity comes later if the read stays stable.',
);

final _w10OneLeverIntroRunner = _w10PlayerTypeIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w10_one_lever_intro',
  lessonTitle: 'Adjust one lever',
  caption:
      'Change one lever first: opening width, value density, or bluff rate.',
  hint: 'Small precise changes are easier to trust and test.',
  question: 'Why adjust one lever at a time?',
  feedbackTitle: 'One-lever foundation.',
  feedbackReason:
      'Single-lever changes reduce chaos. You can see if the exploit works before layering more adjustments.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Precision over chaos.',
      body:
          'If a player overfolds, widen steals first. If a player overcalls, value-bet heavier first. Do not rewrite everything at once.',
      focusLabels: <String>['One lever', 'Steal wider', 'Value heavier'],
    ),
  ],
);

final _w10VsNitOpenWiderRunner = _w10OneLeverIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w10_vs_nit_open_wider',
  caption: 'Blinds fold too much to late-position steals.',
  hint: 'Overfolding behind you increases steal EV.',
  question: 'What is the clean first exploit?',
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
          'That is a broad multi-lever shift. Start with a simpler preflop widen exploit first; extra barrels become better only after postflop folds also show up.',
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
      label: 'Keep baseline until blinds show it again',
      isCorrect: false,
      preferredLabel: 'Open slightly wider in late position',
      betterAnswerLabel: 'Open slightly wider in late position',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Safe but misses value.',
      feedbackReason:
          'Baseline is okay when uncertain, but repeated overfolding supports a measured widen adjustment. If the blinds defend again, baseline becomes stronger.',
    ),
  ],
);

final _w10VsCallerValueHeavierRunner = _w10OneLeverIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w10_vs_caller_value_heavier',
  caption: 'Villain calls down too wide with weak pairs.',
  hint: 'Call-heavy opponents pay off thin value more often.',
  question: 'What is the cleaner exploit lever?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'bluff_heavier',
      label: 'Bluff more anyway',
      isCorrect: false,
      preferredLabel: 'Value-bet heavier, bluff less often',
      betterAnswerLabel: 'Value-bet heavier, bluff less often',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Inverse exploit.',
      feedbackReason:
          'If opponents call too much, bluffs lose EV. Heavier value is the direct exploit.',
    ),
    Act0RunnerOptionV1(
      id: 'allin_only',
      label: 'Only go all-in with strong hands',
      isCorrect: false,
      preferredLabel: 'Value-bet heavier, bluff less often',
      betterAnswerLabel: 'Value-bet heavier, bluff less often',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Too coarse.',
      feedbackReason:
          'You want a value-heavy mix, not a one-size all-in strategy. Keep your line flexible and disciplined.',
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
  hint: 'A sticky defender changes the cleanest steal lever.',
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
          'If blinds defend too wide, weak auto-steals lose value. Keep the exploit specific by trimming trash and preserving stronger opens.',
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
          'Sticky defenders reduce fold equity. The cleaner lever is to drop the weakest steals and rely on stronger value-heavy opens.',
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
          'Massive samples are not required for a light one-lever adjustment. Repeated sticky defense is enough to trim the weakest steals.',
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
          'The weak-pair calls you saw are a reason to try value first. Whether extra bluffs pay depends on how often BB folds to your size.',
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
      label: 'Make every top pair hand huge immediately',
      isCorrect: false,
      preferredLabel: 'Lean value, bluff less',
      betterAnswerLabel: 'Lean value, bluff less',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Too coarse.',
      feedbackReason:
          'The exploit is not to inflate every pot blindly. Keep the shift controlled: extract more value from callers without turning one read into a reckless line.',
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
  caption: 'Lesson learned: one lever gives cleaner exploit feedback loops.',
  hint: 'Test one change before stacking new assumptions.',
  question: 'What is the one-lever takeaway?',
  feedbackTitle: 'One-lever takeaway.',
  feedbackReason:
      'Exploit quality improves when changes are precise and testable. Broad rewrites create noise and confusion.',
);

final _w10ExploitGuardrailsIntroRunner = _w10OneLeverIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w10_guardrails_intro',
  lessonTitle: 'Exploit guardrails',
  caption: 'Exploit does not mean abandoning discipline or hand quality.',
  hint: 'Guardrails keep you from over-adjusting on thin evidence.',
  question: 'Why do exploit guardrails matter?',
  feedbackTitle: 'Guardrail foundation.',
  feedbackReason:
      'Guardrails stop you from turning a useful exploit into a leak. Strong exploit play stays selective and evidence-based.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Exploit with control.',
      body:
          'Use sample-aware reads, keep baseline anchors, and avoid extreme swings from one or two hands.',
      focusLabels: <String>['Sample quality', 'Baseline', 'Control'],
    ),
  ],
);

final _w10OverbluffPunishRunner = _w10ExploitGuardrailsIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w10_overbluff_punish',
  caption:
      'In earlier river showdowns on this line, Villain repeatedly showed missed draws after betting.',
  hint: 'Overbluffing can be punished by wider bluff-catch windows.',
  question: 'What is the cleaner exploit response?',
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
          'Versus overbluffers, over-folding gives away too much EV. You need selective bluff-catch defense; tighter folding becomes better against value-heavy lines.',
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
          'You should widen selectively, not call blindly. Guardrails keep exploit from becoming a punt; broader calls need blockers and a cleaner bluff-heavy read.',
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
  caption: 'Villain reaches river with strong value and few bluffs.',
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
          'If bluff frequency is too low, marginal calls lose EV. Disciplined folds become the exploit.',
    ),
    Act0RunnerOptionV1(
      id: 'call_normal',
      label: 'Call normal baseline frequency',
      isCorrect: false,
      preferredLabel: 'Fold more marginal bluff-catchers',
      betterAnswerLabel: 'Fold more marginal bluff-catchers',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Reasonable default.',
      feedbackReason:
          'Baseline is okay with uncertainty, but clear underbluff evidence supports tighter bluff-catch calls.',
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
          'Against underbluffers, aggressive bluff-raise lines usually burn chips. Tighten instead.',
    ),
  ],
);

final _w10GuardrailSampleSizeRunner = _w10ExploitGuardrailsIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w10_guardrail_sample_size',
  caption: 'You saw two odd hands but no long pattern yet.',
  hint: 'Guardrails protect you when evidence is still thin.',
  question: 'What is the cleaner exploit posture?',
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
          'Guardrails exist to stop overreaction on thin samples. Extreme counters create noise faster than value.',
    ),
    Act0RunnerOptionV1(
      id: 'small_probe',
      label: 'Make only a small adjustment and keep watching',
      isCorrect: true,
      preferredLabel: 'Make only a small adjustment and keep watching',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Strong choice.',
      feedbackReason:
          'Two hands can justify attention, not a full strategy swing. Small exploit probes plus more evidence keep your line disciplined.',
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
          'You should not overreact, but ignoring useful early evidence also wastes exploit edge. Watch and adjust lightly.',
    ),
  ],
);

final _w10ExploitGuardrailsRecapRunner = _w10ExploitGuardrailsIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w10_guardrails_recap',
  caption: 'Lesson learned: exploits work best with guardrails and evidence.',
  hint: 'Do not let one read become a full strategy collapse.',
  question: 'What is the guardrail takeaway?',
  feedbackTitle: 'Guardrail takeaway.',
  feedbackReason:
      'Exploit discipline means selective changes, stable baselines, and enough evidence before major shifts.',
);

final _w10CheckpointTagLineRunner = _w10ExploitGuardrailsIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w10_checkpoint_tag_line',
  caption: 'Opponent folds blinds often but calls rivers too wide.',
  hint: 'You can tag both tendencies, then choose one main lever first.',
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
          'Pairing two levers hides whether your exploit is working. Start with one controllable lever; the second adjustment is stronger after the first read holds.',
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
          'Waiting can be reasonable with a thin sample, but reliable repeated reads deserve small targeted adjustment now.',
    ),
    Act0RunnerOptionV1(
      id: 'primary_tag',
      label: 'Choose one primary tendency and act on it',
      isCorrect: true,
      preferredLabel: 'Choose one primary tendency and act on it',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Solid understanding.',
      feedbackReason:
          'Prioritizing one tendency keeps the exploit coherent and measurable before layering more changes.',
    ),
  ],
);

final _w10CheckpointLeverLineRunner = _w10ExploitGuardrailsIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w10_checkpoint_lever_line',
  caption: 'A tight blind fold profile appears in your sample.',
  hint: 'Single-lever adjustment is the test.',
  question: 'Which exploit line is the cleanest first move?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'widen_steal',
      label: 'Widen late steals slightly',
      isCorrect: true,
      preferredLabel: 'Widen late steals slightly',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Well done.',
      feedbackReason:
          'That is a clear one-lever exploit against fold-heavy blinds and is easy to track.',
    ),
    Act0RunnerOptionV1(
      id: 'raise_all_sizes',
      label: 'Change every sizing in all positions',
      isCorrect: false,
      preferredLabel: 'Widen late steals slightly',
      betterAnswerLabel: 'Widen late steals slightly',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Over-adjustment.',
      feedbackReason:
          'This creates too much noise. One measured lever gives better feedback and lower risk.',
    ),
    Act0RunnerOptionV1(
      id: 'flat_everything',
      label: 'Flat-call more in every seat',
      isCorrect: false,
      preferredLabel: 'Widen late steals slightly',
      betterAnswerLabel: 'Widen late steals slightly',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Not targeted.',
      feedbackReason:
          'Calling wider everywhere does not directly attack blind overfolding. Keep the exploit specific.',
    ),
  ],
);

final _w10CheckpointGuardrailLineRunner = _w10ExploitGuardrailsIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w10_checkpoint_guardrail_line',
  caption: 'You saw one wild bluff from villain this orbit.',
  hint: 'Single hand reads can be noisy.',
  question: 'What is the best guardrail action?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'hard_counter',
      label: 'Hard-counter every future street now',
      isCorrect: false,
      preferredLabel: 'Make a small adjustment and gather more evidence',
      betterAnswerLabel: 'Make a small adjustment and gather more evidence',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too reactive.',
      feedbackReason:
          'One hand is rarely enough for a full counter-strategy. Overreaction creates new leaks.',
    ),
    Act0RunnerOptionV1(
      id: 'small_adjust',
      label: 'Make a small adjustment and gather more evidence',
      isCorrect: true,
      preferredLabel: 'Make a small adjustment and gather more evidence',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Excellent spot.',
      feedbackReason:
          'Guardrails mean respecting uncertainty. Small exploit moves plus more data beats extreme reactions.',
    ),
    Act0RunnerOptionV1(
      id: 'no_adjust',
      label: 'Ignore all reads forever',
      isCorrect: false,
      preferredLabel: 'Make a small adjustment and gather more evidence',
      betterAnswerLabel: 'Make a small adjustment and gather more evidence',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Too rigid.',
      feedbackReason:
          'You should avoid overreaction, but never adjusting also misses exploit value. Baseline is best only if the table cue stops repeating.',
    ),
  ],
);

final _world10PlayerAdjustmentCheckpointRunner = _w10ExploitGuardrailsIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w10_player_adjustment_checkpoint',
  caption: 'Lesson learned: tag tendency, adjust one lever, keep guardrails.',
  hint:
      'Next you will transfer these guardrails-based adjustments into real-play decisions across mixed table conditions.',
  question: 'What does player adjustment add before real-play transfer?',
  feedbackTitle: 'Player-adjustment checkpoint.',
  feedbackReason:
      'You can now convert pressure reads and tendency tags into opponent-specific exploit lines while keeping guardrails and discipline. Real-play transfer is the next layer.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Exploit with structure.',
      body:
          'Tag one tendency, choose one lever, keep guardrails, then test across table dynamics instead of one isolated hand.',
      focusLabels: <String>[
        'Tendency tag',
        'One lever',
        'Guardrails',
        'Real-play transfer',
      ],
    ),
  ],
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'structured_exploit',
      label: 'Structured exploit before transfer',
      isCorrect: true,
      preferredLabel: 'Structured exploit before transfer',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Spot on.',
      feedbackReason:
          'That is the W10 bridge to W11: structured adaptation first, then robust transfer across live play conditions.',
    ),
    Act0RunnerOptionV1(
      id: 'intuition_only',
      label: 'Use table feel without a written loop',
      isCorrect: false,
      preferredLabel: 'Structured exploit before transfer',
      betterAnswerLabel: 'Structured exploit before transfer',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too loose.',
      feedbackReason:
          'Intuition helps, but without structure your adjustments become inconsistent and hard to trust. Table feel becomes useful after it is tied to one repeatable cue.',
    ),
    Act0RunnerOptionV1(
      id: 'baseline_only',
      label: 'Stay baseline until another table cue confirms it',
      isCorrect: false,
      preferredLabel: 'Structured exploit before transfer',
      betterAnswerLabel: 'Structured exploit before transfer',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Safe but capped.',
      feedbackReason:
          'Baseline protects you, but learning to exploit safely is the point of this world before real-play transfer. Staying baseline is stronger when no tendency is reliable.',
    ),
  ],
);

final _w10TableAdjustmentNoticeRunner = _w10CheckpointLeverLineRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w10_table_adjustment_notice',
  lessonTitle: 'Player-adjustment checkpoint',
  lessonSubtitle: 'Player Adjustment',
  caption: 'Suppose both blinds keep folding to your late steals.',
  hint: 'Choose the first exploit you can actually track at the table.',
  question: 'What is the clean first live adjustment?',
  feedbackTitle: 'Adjustment first, not chaos.',
  feedbackReason:
      'Real-table exploit transfer works when one repeated tendency turns into one small tracked adjustment.',
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
          'That answer is tempting because the pattern feels obvious and profitable. But the dominant cue is sample quality: one repeated blind-fold pattern supports one small tracked lever, not a whole strategy rewrite.',
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
          'Baseline feels safe because it avoids overreaction. But repeated overfolding is enough evidence for one small exploit shift. The cleaner read is measured adjustment, not permanent passivity.',
    ),
    Act0RunnerOptionV1(
      id: 'widen_late_steals_small',
      label: 'Widen late steals a bit',
      isCorrect: true,
      preferredLabel: 'Widen late steals a bit',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Clean execution.',
      feedbackReason:
          'That is the clean transfer: repeated blind overfolding supports one small late-position widen, not a full strategy rewrite.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Carry one exploit to the table.',
      body:
          'Tag the tendency, pick one lever, and keep the change small enough that you can see whether it is working.',
      focusLabels: <String>['Repeated fold', 'One lever', 'Trackable change'],
    ),
  ],
);

final _w11SessionPlanIntroRunner = _w10ExploitGuardrailsIntroRunner.copyWith(
  table: _act0HypotheticalConceptTableV1(_w9ExampleTableBase),
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w11_session_plan_intro',
  lessonTitle: 'Session plan in 30 seconds',
  lessonSubtitle: 'Real Play Transfer',
  caption: 'Pick one concrete focus before each real session starts.',
  hint: 'One focus keeps decisions clear under pressure.',
  question: 'What is the best pre-session plan style?',
  feedbackTitle: 'Transfer foundation.',
  feedbackReason:
      'Real-play transfer improves when your session starts with one target behavior, not a long checklist.',
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
          'Too many goals blur feedback and weaken transfer. One target gives cleaner repetition.',
    ),
    Act0RunnerOptionV1(
      id: 'one_focus',
      label: 'One measurable focus for the whole session',
      isCorrect: true,
      preferredLabel: 'One measurable focus for the whole session',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'One measurable focus.',
      feedbackReason:
          'A single measurable focus transfers training into real play with less mental overload.',
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
          'Reactive play can still work, but transfer quality rises when one focus is defined before action starts.',
    ),
  ],
);

final _w11PlanAvoidOverloadRunner = _w11SessionPlanIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w11_plan_avoid_overload',
  caption: 'Your prior session had scattered notes and no clear pattern.',
  hint: 'Reduce cognitive load first.',
  question: 'How should this session goal be narrowed?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'more_complexity',
      label: 'Add more tracking categories',
      isCorrect: false,
      preferredLabel: 'Narrow to one transfer goal next session',
      betterAnswerLabel: 'Narrow to one transfer goal next session',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Wrong direction.',
      feedbackReason:
          'More categories usually increase noise. Start simpler to get stable transfer behavior first.',
    ),
    Act0RunnerOptionV1(
      id: 'repeat_none',
      label: 'Avoid setting any goal again',
      isCorrect: false,
      preferredLabel: 'Narrow to one transfer goal next session',
      betterAnswerLabel: 'Narrow to one transfer goal next session',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Too passive.',
      feedbackReason:
          'Removing goals avoids overload but also weakens deliberate transfer. Keep one simple target.',
    ),
    Act0RunnerOptionV1(
      id: 'narrow_goal',
      label: 'Narrow to one transfer goal next session',
      isCorrect: true,
      preferredLabel: 'Narrow to one transfer goal next session',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'One goal clears the noise.',
      feedbackReason:
          'Transfer improves when you narrow scope and collect cleaner evidence on one behavior.',
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
  question: 'What should Hero choose before sitting in?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'one_focus_loop',
      label: 'Track only the blind-defense leak today',
      isCorrect: true,
      preferredLabel: 'Track only the blind-defense leak today',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Clean transfer plan.',
      feedbackReason:
          'That is the real-table transfer. One focus keeps the session executable, gives you one trigger to notice live, and leaves one clean review target after the session.',
    ),
    Act0RunnerOptionV1(
      id: 'many_focuses_now',
      label: 'Track every leak from the start',
      isCorrect: false,
      preferredLabel: 'Track only the blind-defense leak today',
      betterAnswerLabel: 'Track only the blind-defense leak today',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too noisy.',
      feedbackReason:
          'A crowded plan weakens transfer. If the session starts with too many goals, the live trigger is harder to see and the review becomes blur instead of one actionable output.',
    ),
    Act0RunnerOptionV1(
      id: 'no_focus_until_review',
      label: 'Play first and decide later',
      isCorrect: false,
      preferredLabel: 'Track only the blind-defense leak today',
      betterAnswerLabel: 'Track only the blind-defense leak today',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Too loose a loop.',
      feedbackReason:
          'Review still matters, but the loop is weaker without a one-focus plan. Real table transfer is stronger when the session starts with one focus, then checks one trigger, then closes with one review note.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Plan the loop before the cards fly.',
      body:
          'Real table transfer starts before the first hand. One focus sets the session goal, one trigger tells you when to apply it, and one review note closes the loop after play.',
      focusLabels: <String>['Real table', 'One focus', 'Trigger', 'Review'],
    ),
  ],
);

final _w11SessionPlanRecapRunner = _w11SessionPlanIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w11_session_plan_recap',
  caption: 'Lesson learned: one focus plan creates cleaner real-play transfer.',
  hint: 'Simple plan first, then repetitions.',
  question: 'What is the session-plan takeaway?',
  feedbackTitle: 'Plan takeaway.',
  feedbackReason:
      'Consistent one-focus planning improves execution quality and makes post-session review actionable.',
);

final _w11TriggerReadIntroRunner = _w11SessionPlanIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w11_trigger_intro',
  lessonTitle: 'In-session trigger reads',
  caption: 'When a trigger appears, apply one prepared adjustment quickly.',
  hint: 'Trigger -> one lever -> observe result.',
  question: 'What is a trigger read for transfer play?',
  feedbackTitle: 'Trigger foundation.',
  feedbackReason:
      'A trigger read is a repeated in-session pattern that activates one preplanned adjustment.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Pattern to action.',
      body:
          'If blinds overfold, steal a bit wider. If a player overcalls, value heavier. Use one lever per trigger.',
      focusLabels: <String>['Trigger', 'One lever', 'Observe result'],
    ),
  ],
);

final _w11TriggerOverfoldBlindsRunner = _w11TriggerReadIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w11_trigger_overfold_blinds',
  caption: 'Both blinds folded to 5 of your last 6 steals.',
  hint: 'Overfold trigger supports a preflop widen lever.',
  question: 'What is the cleaner transfer action?',
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
          'The trigger is preflop overfolding. Use a matching preflop lever first, not a full postflop rewrite.',
    ),
    Act0RunnerOptionV1(
      id: 'widen_late_steal',
      label: 'Widen late steals slightly',
      isCorrect: true,
      preferredLabel: 'Widen late steals slightly',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Overfold means widen.',
      feedbackReason:
          'This is a direct trigger-to-lever transfer with clear evidence and low complexity.',
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
          'Static play is stable, but repeated triggers support small targeted transfer adjustments.',
    ),
  ],
);

final _w11TriggerOvercallFlopRunner = _w11TriggerReadIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w11_trigger_overcall_flop',
  caption:
      'In several earlier showdowns, Villain showed a weak pair after calling bets on both flop and turn.',
  hint: 'Overcall trigger points to value-density change.',
  question: 'What is the sharper one-lever response?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'bluff_more',
      label: 'Probe with more bluffs first',
      isCorrect: false,
      preferredLabel: 'Bet value heavier and trim bluffs',
      betterAnswerLabel: 'Bet value heavier and trim bluffs',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Inverse exploit.',
      feedbackReason:
          'Frequent callers reduce bluff EV. Value density is the cleaner transfer adjustment.',
    ),
    Act0RunnerOptionV1(
      id: 'no_change',
      label: 'Save the adjustment for review only',
      isCorrect: false,
      preferredLabel: 'Bet value heavier and trim bluffs',
      betterAnswerLabel: 'Bet value heavier and trim bluffs',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Too rigid.',
      feedbackReason:
          'Rigid baseline avoids errors but gives up clear transfer edges from repeated triggers.',
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
          'A call keeps CO’s weaker bets in and gives you a turn decision. If CO’s betting range is very strong, folding can still be reasonable.',
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
          'Raising can feel proactive, but it bloats the pot too early. The sharper transfer line is use position and the cheap price first.',
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
          'Top pair makes calling tempting, but this tight CO rarely bluffs a full-pot second barrel. Calling 12 BB adds to the 24 BB already in the pot. You need about 33% equity at this price before accounting for the river.',
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
          'Going all-in with a single pair into a tight CO\'s value-heavy barrel magnifies risk without a credible reason to expect enough folds.',
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
      'Lesson learned: trigger reads convert pattern into one action lever.',
  hint: 'Trigger must be repeated, not imagined.',
  question: 'What is the trigger-read takeaway?',
  feedbackTitle: 'Trigger takeaway.',
  feedbackReason:
      'Strong transfer uses repeated triggers and simple one-lever responses you can track over time.',
);

final _w11ReviewLoopIntroRunner = _w11SessionPlanIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w11_review_loop_intro',
  lessonTitle: 'Post-session review loop',
  caption: 'After play, name one leak and one repair target for tomorrow.',
  hint: 'One leak, one fix, one next session test.',
  question: 'What makes review actionable?',
  feedbackTitle: 'Review-loop foundation.',
  feedbackReason:
      'Actionable review links one observed leak to one concrete repair task for the next session.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Close the loop daily.',
      body:
          'Session plan starts the day, trigger reads guide live play, review loop sets tomorrow focus. That cycle compounds skill.',
      focusLabels: <String>['Plan', 'Trigger', 'Review', 'Daily loop'],
    ),
  ],
);

final _w11ReviewPickLeakRunner = _w11ReviewLoopIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w11_review_pick_leak',
  caption: 'Today you missed thin value and overcalled one river.',
  hint: 'Pick the leak that repeats most often first.',
  question: 'What is the clean first review action?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'fix_everything',
      label: 'Fix all leaks at once tomorrow',
      isCorrect: false,
      preferredLabel: 'Select one repeated leak as priority',
      betterAnswerLabel: 'Select one repeated leak as priority',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Overload risk.',
      feedbackReason:
          'Trying to repair everything usually weakens execution. Prioritize one leak for stronger transfer.',
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
          'Volume without structured review slows improvement. One focused repair keeps the loop productive.',
    ),
    Act0RunnerOptionV1(
      id: 'pick_priority',
      label: 'Select one repeated leak as priority',
      isCorrect: true,
      preferredLabel: 'Select one repeated leak as priority',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Pick the repeat leak.',
      feedbackReason:
          'Choosing one repeated leak gives the highest transfer value for the next focused session.',
    ),
  ],
);

final _w11ReviewDefineFixRunner = _w11ReviewLoopIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w11_review_define_fix',
  caption: 'Priority leak: overcalling rivers vs tight players.',
  hint: 'Define an if-then fix for next session.',
  question: 'Which repair target is most actionable?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'if_then_fix',
      label: 'If villain underbluffs, fold marginal bluff-catchers',
      isCorrect: true,
      preferredLabel: 'If villain underbluffs, fold marginal bluff-catchers',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Specific fix transfers.',
      feedbackReason:
          'Specific if-then repair targets transfer directly into live decisions better than generic intentions.',
    ),
    Act0RunnerOptionV1(
      id: 'generic_fix',
      label: 'Play better rivers somehow',
      isCorrect: false,
      preferredLabel: 'If villain underbluffs, fold marginal bluff-catchers',
      betterAnswerLabel: 'If villain underbluffs, fold marginal bluff-catchers',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too vague.',
      feedbackReason:
          'Vague goals are hard to execute. Use behavior-specific repair rules instead.',
    ),
    Act0RunnerOptionV1(
      id: 'no_fix',
      label: 'Do not set any repair task',
      isCorrect: false,
      preferredLabel: 'If villain underbluffs, fold marginal bluff-catchers',
      betterAnswerLabel: 'If villain underbluffs, fold marginal bluff-catchers',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Missed chance.',
      feedbackReason:
          'Skipping repair leaves the leak unchanged. A simple explicit fix improves next-session transfer.',
    ),
  ],
);

final _w11ReviewLoopRecapRunner = _w11ReviewLoopIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w11_review_loop_recap',
  caption: 'Lesson learned: review closes the transfer loop into tomorrow.',
  hint: 'Write one leak and one fix before ending session.',
  question: 'What is the review-loop takeaway?',
  feedbackTitle: 'Review-loop takeaway.',
  feedbackReason:
      'Post-session review converts play into learning only when it outputs one clear repair target for the next day.',
);

final _w11CheckpointPlanLineRunner = _w11ReviewLoopIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w11_checkpoint_plan_line',
  caption: 'You start a session after a long workday with low energy.',
  hint: 'Plan should stay simple and executable.',
  question: 'What is the clean transfer plan?',
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
          'Complex plans collapse under fatigue. Transfer needs practical execution, not idealized complexity.',
    ),
    Act0RunnerOptionV1(
      id: 'simple_focus',
      label: 'Set one low-friction focus target',
      isCorrect: true,
      preferredLabel: 'Set one low-friction focus target',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Low-energy plan first.',
      feedbackReason:
          'Low-energy sessions still transfer well when focus is clear, small, and measurable.',
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
          'No objective removes overload but also removes learning direction. One simple target is better.',
    ),
  ],
);

final _w11CheckpointTriggerLineRunner = _w11ReviewLoopIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w11_checkpoint_trigger_line',
  caption: 'You notice repeated blind overfold and river underbluff patterns.',
  hint: 'Pick one prepared live cue first.',
  question: 'Which transfer action is best?',
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
          'Multiple changes create noise and execution errors. Start with one live cue.',
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
          'Review is important, but the prepared cue has to guide the live decision.',
    ),
    Act0RunnerOptionV1(
      id: 'one_trigger_action',
      label: 'Use one prepared live cue now',
      isCorrect: true,
      preferredLabel: 'Use one prepared live cue now',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'One cue, one action.',
      feedbackReason:
          'A single prepared cue keeps transfer disciplined and observable in real play.',
    ),
  ],
);

final _w11CheckpointReviewLineRunner = _w11ReviewLoopIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w11_checkpoint_review_line',
  caption: 'Session ends with mixed results and two recurring mistakes.',
  hint: 'Review should output one next-session repair task.',
  question: 'What is the strongest closeout action?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'one_repair_output',
      label: 'Review one leak',
      isCorrect: true,
      preferredLabel: 'Review one leak',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Loop closed cleanly.',
      feedbackReason:
          'Transfer compounds when review creates one actionable output that directly shapes the next session plan.',
    ),
    Act0RunnerOptionV1(
      id: 'long_notes',
      label: 'Write long notes',
      isCorrect: false,
      preferredLabel: 'Review one leak',
      betterAnswerLabel: 'Review one leak',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Incomplete loop.',
      feedbackReason:
          'Long notes feel productive because they capture a lot. But the dominant cue here is actionability. Without one chosen repair, the next session still starts fuzzy.',
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
          'Skipping closeout is tempting because the session is over and the key hands still feel fresh. But memory fades fast. The cleaner read is protect tomorrow with one explicit leak-and-fix note.',
    ),
  ],
);

final _w11CheckpointMixedTableLineRunner = _w11ReviewLoopIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w11_checkpoint_mixed_table_line',
  caption:
      'Real table. HJ opens 2.5 BB. Hero calls BTN with A-J suited at 30 BB effective. Flop is A-8-4 two-tone. HJ bets 5 BB into 8 BB.',
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
          'Protection is the tempting idea, but the full table read is more mixed: position helps, stack depth still leaves risk, and the board is not dry enough to force a bigger pot now.',
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
          'A call keeps HJ’s weaker bets and draws in and lets you act last on the turn. A very strong HJ betting range could still make folding reasonable.',
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
      'Lesson learned: plan, trigger, and review form one daily transfer loop.',
  hint:
      'This closes the core route and feeds your daily play-review habit loop. Next you build the mindset bridge.',
  question: 'What does real-play transfer produce when done well?',
  feedbackTitle: 'Real-play checkpoint.',
  feedbackReason:
      'You can now carry course logic into real sessions through a repeatable transfer loop: one plan, one trigger lever, one review repair output. The mindset bridge is the next layer.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Loop beats intensity.',
      body:
          'Sustainable progress comes from repeating a clean transfer loop daily, not from occasional complex sessions.',
      focusLabels: <String>[
        'Session plan',
        'Trigger action',
        'Review repair',
        'Daily habit loop',
      ],
    ),
  ],
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'one_time_mastery',
      label: 'One large review block after the session',
      isCorrect: false,
      preferredLabel: 'A repeatable daily transfer loop',
      betterAnswerLabel: 'A repeatable daily transfer loop',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too brittle.',
      feedbackReason:
          'Transfer is compounding and iterative. One massive session is less reliable than steady loops.',
    ),
    Act0RunnerOptionV1(
      id: 'content_only',
      label: 'Study another concept before looping it',
      isCorrect: false,
      preferredLabel: 'A repeatable daily transfer loop',
      betterAnswerLabel: 'A repeatable daily transfer loop',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Partial progress.',
      feedbackReason:
          'Content helps, but transfer happens only when lessons are converted into repeated session behavior and review.',
    ),
    Act0RunnerOptionV1(
      id: 'repeatable_loop',
      label: 'A repeatable daily transfer loop',
      isCorrect: true,
      preferredLabel: 'A repeatable daily transfer loop',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Sharp read.',
      feedbackReason:
          'That is the intended endpoint: practical, repeatable transfer from learning into daily table decisions.',
    ),
  ],
);

final _w12DecisionQualityIntroRunner = _w11ReviewLoopIntroRunner.copyWith(
  table: _act0HypotheticalConceptTableV1(_w9ExampleTableBase),
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w12_decision_quality_intro',
  lessonTitle: 'Decision quality over outcome',
  lessonSubtitle: 'Mindset Bridge',
  caption: 'Short-term outcomes can lie. Process quality must stay the anchor.',
  hint: 'Judge choices by logic, not one card on river.',
  question: 'What should be judged first after a hand?',
  feedbackTitle: 'Mindset foundation.',
  feedbackReason:
      'A strong mindset evaluates whether the decision process was sound before reacting to outcome variance.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Process beats variance.',
      body:
          'Good decisions can lose and bad decisions can win. Improvement comes from process quality, not short-term emotional swings.',
      focusLabels: <String>['Process', 'Variance', 'Outcome bias'],
    ),
  ],
);

final _w12GoodFoldBadResultRunner = _w12DecisionQualityIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w12_good_fold_bad_result',
  caption:
      'You folded a marginal bluff-catcher and villain later showed a bluff.',
  hint: 'Do not auto-label by reveal result only.',
  question: 'How should you review this fold?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'process_review',
      label: 'Check the cues before judging the result',
      isCorrect: true,
      preferredLabel: 'Check the cues before judging the result',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Process beats reveal.',
      feedbackReason:
          'Review the price and the range you could reasonably give Villain before they showed the bluff. This reveal can inform future decisions.',
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
          'Single-hand reveal can mislead. Decision quality should be judged by range logic and context.',
    ),
    Act0RunnerOptionV1(
      id: 'ignore_hand',
      label: 'Move on after a quick note only',
      isCorrect: false,
      preferredLabel: 'Check the cues before judging the result',
      betterAnswerLabel: 'Check the cues before judging the result',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Avoids tilt.',
      feedbackReason:
          'Ignoring helps emotions, but quick process review is better for learning transfer.',
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
          'Outcome can be lucky. Process discipline means auditing suspicious calls even after wins.',
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
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Too harsh.',
      feedbackReason:
          'Leak review should be calm and specific, not confidence collapse. Keep a constructive audit tone.',
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
);

final _w12TiltResetIntroRunner = _w12DecisionQualityIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w12_tilt_reset_intro',
  lessonTitle: 'Tilt reset protocol',
  caption:
      'One short reset can protect decision quality after emotional spikes.',
  hint: 'Pause, breathe, re-anchor to plan.',
  question: 'What is the purpose of a tilt reset?',
  feedbackTitle: 'Reset foundation.',
  feedbackReason:
      'Tilt reset prevents one hand from contaminating the next decisions and keeps session discipline alive.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Fast reset loop.',
      body:
          'Name the emotion, take one breath cycle, restate your one-focus plan, then continue with smaller decision scope.',
      focusLabels: <String>['Emotion label', 'Breath', 'Re-anchor'],
    ),
  ],
);

final _w12AfterBadBeatResetRunner = _w12TiltResetIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w12_after_bad_beat_reset',
  caption: 'You lose a big all-in as favorite and feel immediate anger.',
  hint: 'Reset before next hand starts.',
  question: 'What is the cleaner immediate action?',
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
          'Revenge actions usually worsen variance damage. Reset first, then return to plan.',
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
          'Ending session can help if control is gone, but the first step is a brief reset and re-check.',
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
      feedbackTitle: 'Harmful loop.',
      feedbackReason:
          'Self-attack increases future mistake risk. Keep review structured and calm.',
    ),
    Act0RunnerOptionV1(
      id: 'deny_mistake',
      label: 'Skip the note and rely on memory',
      isCorrect: false,
      preferredLabel: 'Log leak briefly and reset to current hand',
      betterAnswerLabel: 'Log leak briefly and reset to current hand',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Protects emotion short term.',
      feedbackReason:
          'Ignoring may reduce pain now, but short structured logging improves long-term transfer.',
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
  caption: 'Villain needles you after winning a pot.',
  hint: 'Decision quality should not react to table talk.',
  question: 'What is the stronger mindset line?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'prove_point',
      label: 'Widen the next close spot to answer back',
      isCorrect: false,
      preferredLabel: 'Stick to process and planned exploit line',
      betterAnswerLabel: 'Stick to process and planned exploit line',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Ego trap.',
      feedbackReason:
          'Point-proving lines usually detach from EV and increase variance mistakes.',
    ),
    Act0RunnerOptionV1(
      id: 'stick_process',
      label: 'Stick to process and planned exploit line',
      isCorrect: true,
      preferredLabel: 'Stick to process and planned exploit line',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Process ignores table talk.',
      feedbackReason:
          'Process-led confidence ignores ego hooks and preserves decision quality.',
    ),
    Act0RunnerOptionV1(
      id: 'play_scared',
      label: 'Play overly scared to avoid conflict',
      isCorrect: false,
      preferredLabel: 'Stick to process and planned exploit line',
      betterAnswerLabel: 'Stick to process and planned exploit line',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Safer but capped.',
      feedbackReason:
          'Fear-based tightening can avoid blowups but also leaks EV. Keep calm assertive discipline instead.',
    ),
  ],
);

final _w12DisciplineUnderPressureRunner = _w12ConfidenceDisciplineIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w12_discipline_under_pressure',
  caption: 'Deep in session, fatigue rises and decisions speed up.',
  hint: 'Discipline means slowing only the critical spots.',
  question: 'What is the best pressure adjustment?',
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
          'Normal pace is fine in routine spots, but fatigue often degrades decision quality in the largest pots.',
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
          'Over-slowing routine spots burns energy. Discipline should be targeted to meaningful nodes.',
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
      'Real table. A tight player barrels into river and now bets 18 BB into 20 BB on K-7-2-9-4. Hero holds K-Q at 100 BB effective.',
  hint: 'Do not hero call only because the hand looks pretty.',
  question: 'What is the cleaner disciplined action?',
  table: _act0CurrentStreetTableV1(
    _legacyFacingOpenTableV1.copyWith(
      heroCards: _heroKqCards,
      boardCards: _boardK7294Cards,
      streetLabel: 'River',
      potLabel: 'Pot 38 BB',
      toCallLabel: 'To call 18 BB',
      centerLabel: 'Top pair, bad river price',
      handContributions: _act0SingleStreetBetContributionsV1(
        street: PokerStreet.river,
        bettor: 'co',
        betBb: 18,
        effectiveStackAtHandStartBb: 100,
        potBeforeBetBb: 20,
      ),
      actionTrail: const <Act0ActionTrailItemV1>[
        Act0ActionTrailItemV1(label: 'CO opens 2.5 BB'),
        Act0ActionTrailItemV1(label: 'BTN calls'),
        Act0ActionTrailItemV1(label: 'CO barrels flop'),
        Act0ActionTrailItemV1(label: 'CO barrels turn'),
        Act0ActionTrailItemV1(label: 'CO bets 18 BB'),
      ],
    ),
    bets: {
      'co': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.bet,
        label: 'CO',
        amountLabel: '18 BB',
      ),
    },
  ),
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
      label: 'Hero-call top pair',
      isCorrect: false,
      preferredLabel: 'Fold the river',
      betterAnswerLabel: 'Fold the river',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Pretty-hand trap.',
      feedbackReason:
          'The hand label makes this tempting, but real play rewards the full read: action trail, price, and opponent profile matter more than wanting to be right.',
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
          'A raise risks more chips. It needs a reason to expect worse hands to call or better hands to fold. The bet size and the tight read give no evidence of either.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Pretty hands still obey price.',
      body:
          'Use the same loop even when the hand looks attractive: seat, hand, board, price, stack and action, then the clean action.',
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
      'The same villain bluffed you last orbit and needles you now. New hand: Hero holds Q-J suited on J-7-4 rainbow. CO bets 2 BB into 8 BB at 35 BB effective.',
  hint:
      'Do not raise just to take control when the table read says stay simple.',
  question: 'What is the clean discipline line?',
  table: _act0CurrentStreetTableV1(
    _legacyFacingOpenTableV1.copyWith(
      heroCards: _heroQJsCards,
      boardCards: _boardJ74FlopCards,
      streetLabel: 'Flop',
      potLabel: 'Pot 10 BB',
      toCallLabel: 'To call 2 BB',
      centerLabel: 'Top pair, ego trap',
      handContributions: _act0SingleStreetBetContributionsV1(
        street: PokerStreet.flop,
        bettor: 'co',
        betBb: 2,
        effectiveStackAtHandStartBb: 35,
        potBeforeBetBb: 8,
      ),
      actionTrail: const <Act0ActionTrailItemV1>[
        Act0ActionTrailItemV1.note(label: 'Villain needled you last orbit'),
        Act0ActionTrailItemV1(label: 'Flop: CO bets 2 BB'),
      ],
    ),
    bets: {
      'co': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.bet,
        label: 'CO',
        amountLabel: '2 BB',
      ),
    },
  ),
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
          'Taking control sounds assertive, but here it is emotional, not evidence-based. The clean action comes from hand, board, price, and position, not from wanting the last word.',
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
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Emotion still steering.',
      feedbackReason:
          'Folding out of irritation is still letting emotion drive. A calm continue is cleaner than either revenge or avoidance here.',
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
    );

final _w12CheckpointProcessLineRunner = _w12ConfidenceDisciplineIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w12_checkpoint_process_line',
  feedbackSignalId: 'process_over_outcome',
  caption: 'A correct line loses in a high-variance pot.',
  hint: 'Process verdict comes before emotional verdict.',
  question:
      'Suppose a sound decision loses a high-variance pot. What is the best immediate response?',
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
          'Outcome-first judgment is tempting because the result feels vivid and final. But the dominant cue is decision quality. One result cannot grade the process by itself.',
    ),
    Act0RunnerOptionV1(
      id: 'avoid_review',
      label: 'Skip review to avoid frustration',
      isCorrect: false,
      preferredLabel: 'Audit process first, then outcome',
      betterAnswerLabel: 'Audit process first, then outcome',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Protective instinct.',
      feedbackReason:
          'Avoiding review feels protective because it lowers frustration in the moment. But the cleaner bridge is short cue review first, so emotion does not hide the actual lesson.',
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
          'Recovering momentum sounds useful, but tilt turns that into loose action. Controlled reset is the bridge habit; taking a close edge is better after the reset.',
    ),
    Act0RunnerOptionV1(
      id: 'deny_tilt',
      label: 'Keep playing and check emotions later',
      isCorrect: false,
      preferredLabel: 'Run brief reset and re-anchor to plan',
      betterAnswerLabel: 'Run brief reset and re-anchor to plan',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Common response.',
      feedbackReason:
          'Continuing can work briefly, but explicit reset better preserves quality under pressure. Delaying the emotion check is safer only when decisions are low stakes.',
    ),
  ],
);

final _w12CheckpointDisciplineLineRunner = _w12ConfidenceDisciplineIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w12_checkpoint_discipline_line',
  caption: 'A player taunts you into marginal high-variance spots.',
  hint: 'Discipline means evidence over ego.',
  question: 'Which line is strongest?',
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
          'Respect-seeking lines detach from quality logic and create avoidable variance.',
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
      label: 'Fold every close spot now',
      isCorrect: false,
      preferredLabel: 'Take only evidence-backed lines',
      betterAnswerLabel: 'Take only evidence-backed lines',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Defensive but capped.',
      feedbackReason:
          'Overfolding avoids ego spots but also misses edges. Evidence-based selectivity is stronger.',
    ),
  ],
);

final _w12CheckpointFullLoopLineRunner = _w12ConfidenceDisciplineIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w12_checkpoint_full_loop_line',
  caption:
      'You made a loose bluff last orbit. New hand: CO opens, Hero calls BTN with A-J suited at 25 BB effective. Flop is A-8-4 two-tone. CO bets 2 BB into 8 BB.',
  hint:
      'Use the same decision loop even after a mistake: seat, hand, board, price, stack and action, then the clean action.',
  question: 'What keeps the next decision stable?',
  table: _act0CurrentStreetTableV1(
    _legacyFacingOpenTableV1.copyWith(
      heroCards: _heroAJsCards,
      boardCards: _boardA84TwoToneCards,
      streetLabel: 'Flop',
      potLabel: 'Pot 10 BB',
      toCallLabel: 'To call 2 BB',
      centerLabel: 'After mistake, stay clean',
      handContributions: _act0SingleStreetBetContributionsV1(
        street: PokerStreet.flop,
        bettor: 'co',
        betBb: 2,
        effectiveStackAtHandStartBb: 25,
        potBeforeBetBb: 8,
      ),
      actionTrail: const <Act0ActionTrailItemV1>[
        Act0ActionTrailItemV1.note(label: 'Last orbit: loose bluff'),
        Act0ActionTrailItemV1(label: 'CO raises 2.5 BB'),
        Act0ActionTrailItemV1(label: 'BTN calls 2.5 BB'),
        Act0ActionTrailItemV1(label: 'Flop: CO bets 2 BB'),
      ],
    ),
    bets: {
      'co': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.bet,
        label: 'CO',
        amountLabel: '2 BB',
      ),
    },
  ),
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'raise_to_recover',
      label: 'Raise to recover confidence',
      isCorrect: false,
      preferredLabel: 'Call with the same loop',
      betterAnswerLabel: 'Call with the same loop',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Confidence chase.',
      feedbackReason:
          'This is exactly the wrong bridge habit. Confidence should come from following the loop, not from forcing a louder action after a mistake.',
    ),
    Act0RunnerOptionV1(
      id: 'fold_scared',
      label: 'Fold to play safer now',
      isCorrect: false,
      preferredLabel: 'Call with the same loop',
      betterAnswerLabel: 'Call with the same loop',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Too reactive.',
      feedbackReason:
          'Fear after a mistake is still emotion steering the next hand. The cleaner bridge is keep the same seat-hand-board-price-stack loop and follow what this spot says.',
    ),
    Act0RunnerOptionV1(
      id: 'call_clean',
      label: 'Call with the same loop',
      isCorrect: true,
      preferredLabel: 'Call with the same loop',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Strong reset.',
      feedbackReason:
          'Start with top pair, position and the 2 BB price. Calling is a reasonable controlled line if CO bets enough weaker hands. The optimal line depends on CO’s range and later action. Review the previous bluff separately.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Stable loop beats emotional correction.',
      body:
          'A prior mistake should not rewrite the next decision. Real play gets stronger when the same clean loop survives noise, temptation, and regret.',
      focusLabels: <String>[
        'After mistake',
        'Seat-hand-board-price',
        '25 BB',
        'Stay stable',
      ],
    ),
  ],
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
          'Strong strategy growth requires stable mindset loops. Process audits, resets, and discipline make advanced learning stick.',
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
      label: 'A repeatable process-reset-discipline loop',
      isCorrect: true,
      preferredLabel: 'A repeatable process-reset-discipline loop',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Solid understanding.',
      feedbackReason:
          'Mindset stability is what lets complex strategic lessons transfer instead of collapsing under pressure.',
    ),
    Act0RunnerOptionV1(
      id: 'optional_soft',
      label: 'Optional soft skill with little EV impact',
      isCorrect: false,
      preferredLabel: 'A repeatable process-reset-discipline loop',
      betterAnswerLabel: 'A repeatable process-reset-discipline loop',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Underestimation.',
      feedbackReason:
          'Mindset errors are EV errors. Stability directly affects execution of every strategic concept.',
    ),
    Act0RunnerOptionV1(
      id: 'done_forever',
      label: 'One-time fix, no daily upkeep needed',
      isCorrect: false,
      preferredLabel: 'A repeatable process-reset-discipline loop',
      betterAnswerLabel: 'A repeatable process-reset-discipline loop',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Partly true start.',
      feedbackReason:
          'Initial tools help, but mindset edge stays strong only through repeated daily use.',
    ),
  ],
);

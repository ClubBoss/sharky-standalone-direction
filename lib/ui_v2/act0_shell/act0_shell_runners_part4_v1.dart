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
          'CO has 200 BB and BB has 30 BB. Planning a 200 BB wager overlooks that BB can match only 30 BB.',
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
          'Averaging 200 BB and 30 BB gives 115 BB. That counts 85 BB that BB could never match.',
    ),
  ],
  table: _act0BoardLessonTableV1(
    openingSeat: 'co',
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
          'CO and BB each have 100 BB behind. Either player can match the other up to 100 BB.',
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
          'Both players have 100 BB remaining on T-8-3. Calling the limit 50 BB loses sight of half the amount each can match.',
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
          'These 100 BB stacks sum to 200 BB, but a bet has to be covered by the other player. Each can match only 100 BB.',
    ),
  ],
  table: _act0BoardLessonTableV1(
    openingSeat: 'co',
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
  caption: 'Compare your 120 BB behind with BB’s 18 BB behind.',
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
          'On T-7-3, BB’s 18 BB behind caps how much more your jacks can earn from that player.',
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
          'Your 120 BB is visible, but BB can match only 18 BB. Starting from 120 BB exaggerates how much this opponent can pay.',
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
          'You added the two displayed stacks correctly. For a bet, compare them instead: BB can match just 18 BB, so 138 BB overstates the risk.',
    ),
  ],
  table: _act0BoardLessonTableV1(
    openingSeat: 'co',
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
    openingSeat: 'co',
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
      "BB checks. You have top pair and want to keep at least 18 BB for later streets, so you can bet for value or respond to a raise later.",
  hint: 'Subtract each possible bet from the stack you have left.',
  question: 'Which bet fits your plan?',
  sizingConfig: const Act0SizingConfigV1(
    mode: Act0SizingUiModeV1.presetsOnly,
    showGuidance: false,
    presets: [
      Act0SizingPresetV1(id: '20bb', label: 'Bet 2 BB', potFraction: 2 / 5.5),
      Act0SizingPresetV1(id: '100bb', label: 'Bet 4 BB', potFraction: 4 / 5.5),
      Act0SizingPresetV1(id: 'same', label: 'Go all-in', potFraction: 20 / 5.5),
    ],
  ),
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: '20bb',
      label: 'Bet 2 BB',
      isCorrect: true,
      preferredLabel: 'Bet 2 BB',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'You keep 18 BB.',
      feedbackReason:
          "BB checks and you have 20 BB behind. Bet 2 BB because the 4 BB size leaves just 16 BB to play later. The smaller size holds 18 BB for a turn or river bet.",
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
          "Betting 4 BB leaves just 16 BB to play later. The 2 BB bet keeps the 18 BB you want.",
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
          "An all-in risks the full 20 BB and leaves nothing for later bets. The 2 BB bet keeps 18 BB.",
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
          "CO calls the 7.5 BB raise with A-T suited but folds to an all-in. That gains 5 BB from that hand; the best line overall depends on CO’s full range.",
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
          "Call 2.5 BB because CO keeps weaker aces in. Raising folds them out and invites stronger hands to raise again. Profit overall depends on CO’s full range.",
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
          "Raising folds weaker aces and brings in a reraise from stronger aces. Calling keeps the weaker hands in for 2.5 BB.",
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
    openingSeat: 'co',
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
          'With 10 BB behind and 5 BB in the pot, a large bet can risk most of your remaining stack. Use your KQ top pair and the price before committing.',
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
          'The 10 BB left is only two times the 5 BB pot. Planning several large bets would use up those chips earlier than expected.',
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
          'A pot-sized 5 BB bet would put half of your 10 BB at risk. At SPR 8, it would risk only one eighth of the effective stack.',
    ),
  ],
  table: _act0BoardLessonTableV1(
    openingSeat: 'co',
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
          'The 5 BB pot is small next to your 40 BB stack. You can choose a smaller bet or check and keep room for later streets.',
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
          'Putting in 40 BB right away would risk eight times the 5 BB pot with one pair. You can keep chips for later decisions.',
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
          'You have 40 BB behind after the preflop action, with 5 BB in the pot. Ignoring that ratio leaves you without a plan for the turn and river.',
    ),
  ],
  table: _act0BoardLessonTableV1(
    openingSeat: 'co',
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
          'On J-8-3 you have 20 BB behind and a 5 BB pot. A small bet leaves room for later streets, while large bets can commit you quickly.',
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
          'Going all-in for your 20 BB over the 5 BB pot could risk your entire stack with one pair. A smaller bet preserves other choices.',
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
          'With 20 BB behind, a pot bet costs one quarter of your stack. Treating it like SPR 8 underestimates how fast two bets can use up those chips.',
    ),
  ],
  table: _act0BoardLessonTableV1(
    openingSeat: 'co',
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
          "Comparing this with SPR 8 misses how much the same bet uses from a smaller stack. With 16 BB behind and 8 BB in the pot, one bet moves you closer to playing for the whole stack.",
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
          "Treating this like SPR 2 risks building a large pot with one pair. With 64 BB behind, you can still fold if BB puts much more in.",
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
          "Ignoring depth risks paying off a stronger hand over several rounds of betting. At SPR 8, top pair can keep the pot smaller before BB commits a large stack.",
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
      "Practice rule for A-J suited: raise to 2.5 BB with at most five players still to act. Otherwise fold.",
  hint: 'Check the given limits before choosing.',
  question: "You are first to act. What fits this table?",
  feedbackTitle: "Count the players behind.",
  feedbackReason:
      "Open AJs for 2.5 BB because only five players act after UTG and they may fold and leave the blinds. Folding passes up that chance when fewer players remain who might hold a stronger hand.",
  table: _act0UnopenedLessonTableV1(
    heroCards: _act0LessonCardsV1('Ad Jd'),
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
          "Open AJs for 2.5 BB because only five players act after UTG and they may fold and leave the blinds. Folding passes up that chance when fewer players remain who might hold a stronger hand.",
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
          "Five players remain in 6-max. Folding A-J suited passes up the chance to open a Strong hand and win the 1.5 BB in blinds.",
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
          "Five players remain, so the rule allows an open. An 8 BB raise puts 5.5 BB more at risk than the stated 2.5 BB size.",
    ),
  ],
);

final _w7FullRingTighterRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w7_fullring_tighter',
  caption:
      "Add UTG+1, UTG+2 and LJ after you. Open A-J suited for 2.5 BB with at most five to act. Otherwise fold.",
  hint: 'Check the given limits before choosing.',
  question: "What fits the nine-player version of this hand?",
  feedbackTitle: "More players can act after you.",
  feedbackReason:
      "Fold AJs because eight players still act from UTG, increasing the chance someone has a stronger ace or a high pair. Raising to 2.5 BB risks chips against more possible callers and reraises.",
  table: _act0UnopenedLessonTableV1(
    heroCards: _act0LessonCardsV1('Ah Jh'),
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
          "Fold AJs because eight players still act from UTG, increasing the chance someone has a stronger ace or a high pair. Raising to 2.5 BB risks chips against more possible callers and reraises.",
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
          "Eight players can still wake up with a stronger hand. This full-ring rule folds A-J suited and saves the 2.5 BB open.",
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
          "An 8 BB raise still faces the same eight players. It puts 8 BB at risk in a spot where the example calls for a fold.",
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
      "Bet 6 BB because BB can call while your shorter stack keeps 12 BB. The 10 BB size leaves just 8 BB, below the amount you want for later bets.",
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
  sizingConfig: const Act0SizingConfigV1(
    mode: Act0SizingUiModeV1.presetsOnly,
    showGuidance: false,
    presets: [
      Act0SizingPresetV1(
        id: 'open_same',
        label: 'Bet 10 BB',
        potFraction: 1.25,
      ),
      Act0SizingPresetV1(
        id: 'depth_only',
        label: 'Bet 12 BB',
        potFraction: 1.5,
      ),
      Act0SizingPresetV1(
        id: 'tighten_early',
        label: 'Bet 6 BB',
        potFraction: 0.75,
      ),
    ],
  ),
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
          "Betting 10 BB leaves just 8 BB if called and misses the target. A 6 BB bet holds 12 BB for later.",
    ),
    Act0RunnerOptionV1(
      id: 'tighten_early',
      label: "Bet 6 BB",
      isCorrect: true,
      preferredLabel: "Bet 6 BB",
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: "Both players keep enough chips.",
      feedbackReason:
          "Bet 6 BB because BB can call while your shorter stack keeps 12 BB. The 10 BB size leaves just 8 BB, below the amount you want for later bets.",
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

// Concept questions carry text, with no authored deal or seat cue.
const _w9TextStudyTableV1 = Act0TableStateV1(
  scope: Act0TableScopeV1.explanation,
  showDecisionPremise: true,
  tableFormat: Act0TableFormatV1.sixMax,
  playerCount: 6,
  seats: [],
  heroCards: [],
  boardCards: [],
  streetLabel: '',
  potLabel: '',
  toCallLabel: '',
  centerLabel: '',
  highlightedSeatIds: [],
  highlightedCardIds: [],
);

final _w9SurvivalIntroRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w9_survival_intro',
  lessonTitle: "Chips and prizes",
  lessonSubtitle: 'Tournament Pressure',
  caption: "Chips and expected prize money are different measures.",
  hint: '',
  hintPolicy: Act0HintPolicyV1.theoryOnly,
  question: "What does EV describe?",
  feedbackTitle: "Chips and prizes",
  feedbackReason:
      "EV includes winning and losing outcomes, weighted by their chances; one lost hand can come from a profitable decision.",
  teachingSteps: const [
    Act0TeachingStepV1(
      title: "Chips and prizes",
      body:
          "EV stands for expected value. It is your average result if you make the same choice many times. Chip EV counts chips. Prize EV counts prize money. Your run ends if you lose your stack. Near a payout, a small gain in chips can cost prize value. M = stack / (SB + BB + antes for one lap). Green is 20 or more. Yellow is 10 to under 20. Red is below 10.",
    ),
  ],
  options: const [],
  table: _w9TextStudyTableV1,
);

final _w9CashVsTournamentRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w9_cash_vs_tournament',
  lessonTitle: "A close river call",
  lessonSubtitle: 'Tournament Pressure',
  caption:
      "Six left, five paid. Prizes in order: 500, 250, 120, 80, 50. BTN bets 16 BB into 8.5 BB and can bust you. The given range is 60% AQ or KQ and 40% missed JT. You win 40% with no ties. The prize model needs a 62.4% win rate.",
  hint: '',
  hintPolicy: Act0HintPolicyV1.theoryOnly,
  question: "Call or fold?",
  feedbackTitle: "A close river call",
  feedbackReason:
      "BTN bets missed jack-ten and stronger queens. Folding saves your last 16 BB because calling with 40% wins earns a little in chips but falls below the 62.4% needed for prizes.",
  teachingSteps: const [
    Act0TeachingStepV1(
      title: "A close river call",
      body:
          "When a call can bust you, check both costs. First work out the chip price from the pot and call. Then compare your win rate with the prize model.",
    ),
  ],
  options: const [
    Act0RunnerOptionV1(
      id: "fold",
      label: "Fold",
      isCorrect: true,
      preferredLabel: "Fold",

      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: "Correct.",
      feedbackReason:
          "BTN bets missed jack-ten and stronger queens. Folding saves your last 16 BB because calling with 40% wins earns a little in chips but falls below the 62.4% needed for prizes.",
    ),
    Act0RunnerOptionV1(
      id: "call_16_bb",
      label: "Call 16 BB",
      isCorrect: false,
      preferredLabel: "Fold",
      betterAnswerLabel: "Fold",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "QJ beats the missed JT but loses to AQ/KQ. Calling earns 0.20 BB in chips yet drops modeled prize value from \$192.16 to \$123.25.",
    ),
  ],
  table: _day7TableV1(
    hero: 'bb',
    hand: "Qh Jh",
    street: PokerStreet.river,
    actor: 'bb',
    board: _act0LessonCardsV1("Qs 9c 5d 2h 3s"),
    folded: const {"utg", "hj", "co", "sb"},
    stacks: const {"utg": 2, "hj": 10, "co": 8, "btn": 50, "sb": 10, "bb": 20},
    entries: const [
      ..._act0LessonBlinds,
      Act0ContributionV1(
        PokerStreet.preflop,
        'btn',
        Act0ContributionKindV1.wager,
        2,
      ),
      Act0ContributionV1(
        PokerStreet.preflop,
        'bb',
        Act0ContributionKindV1.wager,
        1,
      ),
      Act0ContributionV1(
        PokerStreet.flop,
        'btn',
        Act0ContributionKindV1.wager,
        2,
      ),
      Act0ContributionV1(
        PokerStreet.flop,
        'bb',
        Act0ContributionKindV1.wager,
        2,
      ),
      Act0ContributionV1(
        PokerStreet.river,
        'btn',
        Act0ContributionKindV1.wager,
        16,
      ),
    ],
    history: const [
      Act0ActionTrailItemV1(label: "SB blind 0.5 BB"),
      Act0ActionTrailItemV1(label: "BB blind 1 BB"),
      Act0ActionTrailItemV1(label: "UTG folds"),
      Act0ActionTrailItemV1(label: "HJ folds"),
      Act0ActionTrailItemV1(label: "CO folds"),
      Act0ActionTrailItemV1(label: "BTN raises to 2 BB"),
      Act0ActionTrailItemV1(label: "SB folds"),
      Act0ActionTrailItemV1(label: "BB calls 2 BB"),
      Act0ActionTrailItemV1(label: "Flop: BB checks"),
      Act0ActionTrailItemV1(label: "BTN bets 2 BB"),
      Act0ActionTrailItemV1(label: "BB calls 2 BB"),
      Act0ActionTrailItemV1(label: "Turn: BB checks"),
      Act0ActionTrailItemV1(label: "BTN checks"),
      Act0ActionTrailItemV1(label: "River: BB checks"),
      Act0ActionTrailItemV1(label: "BTN bets 16 BB"),
    ],
    bets: const {
      'btn': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.bet,
        label: 'Bet',
        amountLabel: '16 BB',
      ),
    },
  ),
);

final _w9EvTwoResultsRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w9_ev_two_results',
  lessonTitle: "Average chip gain",
  lessonSubtitle: 'Tournament Pressure',
  caption: "You gain 3 BB half the time. You lose 1 BB the other half.",
  hint: '',
  hintPolicy: Act0HintPolicyV1.theoryOnly,
  question: "What is your chip EV?",
  feedbackTitle: "Average chip gain",
  feedbackReason: "Half of 3 BB minus half of 1 BB leaves a gain of 1 BB.",
  teachingSteps: const [],
  options: const [
    Act0RunnerOptionV1(
      id: "1_bb",
      label: "1 BB",
      isCorrect: true,
      preferredLabel: "1 BB",

      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: "Correct.",
      feedbackReason: "Half of 3 BB minus half of 1 BB leaves a gain of 1 BB.",
    ),
    Act0RunnerOptionV1(
      id: "2_bb",
      label: "2 BB",
      isCorrect: false,
      preferredLabel: "1 BB",
      betterAnswerLabel: "1 BB",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "3 BB minus 1 BB is the sum of both results. It is twice the gain per try.",
    ),
    Act0RunnerOptionV1(
      id: "3_bb",
      label: "3 BB",
      isCorrect: false,
      preferredLabel: "1 BB",
      betterAnswerLabel: "1 BB",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "3 BB counts the wins. Skip the losses and the bet looks too good.",
    ),
  ],
  table: _w9TextStudyTableV1,
);

final _w9ShortStackSurvivalRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w9_short_stack_survival',
  lessonTitle: "Small blind choice",
  lessonSubtitle: 'Tournament Pressure',
  caption:
      "You start with 9 BB. It folds to you in the small blind. The money is far off. Assume each legal hand is equally likely before BB decides. BB calls an all-in with 77+, A9s+, ATo+ or KQs and folds the rest.",
  hint: '',
  hintPolicy: Act0HintPolicyV1.theoryOnly,
  question: "Go all-in or fold?",
  feedbackTitle: "Small blind choice",
  feedbackReason:
      "BB folds 1,117 of 1,225 equally likely hands, about 91.2%. Going all-in for 8.5 BB more earns at least 0.62 BB on average even if every call beats you, so folding misses a profitable chance.",
  teachingSteps: const [
    Act0TeachingStepV1(
      title: "Small blind choice",
      body:
          "An all-in puts your whole stack in. When just one player is left to act, an all-in can win the blinds. Check how often that player will call. This short-stack drill asks you to choose between an all-in and a fold.",
    ),
  ],
  options: const [
    Act0RunnerOptionV1(
      id: "fold",
      label: "Fold",
      isCorrect: false,
      preferredLabel: "All-in to 9 BB",
      betterAnswerLabel: "All-in to 9 BB",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "You start with 9 BB and face one tight caller. Folding K9s gives up the shot at the 1.5 BB pot.",
    ),
    Act0RunnerOptionV1(
      id: "take_spot",
      label: "All-in to 9 BB",
      isCorrect: true,
      preferredLabel: "All-in to 9 BB",

      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: "Correct.",
      feedbackReason:
          "BB folds 1,117 of 1,225 equally likely hands, about 91.2%. Going all-in for 8.5 BB more earns at least 0.62 BB on average even if every call beats you, so folding misses a profitable chance.",
    ),
  ],
  table: _day7TableV1(
    hero: 'sb',
    hand: "Kd 9d",
    street: PokerStreet.preflop,
    actor: 'sb',

    folded: const {"utg", "hj", "co", "btn"},
    stacks: const {"utg": 28, "hj": 24, "co": 35, "btn": 22, "sb": 9, "bb": 30},
    entries: const [..._act0LessonBlinds],
    history: const [
      Act0ActionTrailItemV1(label: "SB blind 0.5 BB"),
      Act0ActionTrailItemV1(label: "BB blind 1 BB"),
      Act0ActionTrailItemV1(label: "UTG folds"),
      Act0ActionTrailItemV1(label: "HJ folds"),
      Act0ActionTrailItemV1(label: "CO folds"),
      Act0ActionTrailItemV1(label: "BTN folds"),
    ],
    bets: const {
      'sb': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.post,
        label: 'Post',
        amountLabel: '0.5 BB',
      ),
      'bb': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.post,
        label: 'Post',
        amountLabel: '1 BB',
      ),
    },
  ),
);

final _w9SurvivalTradeoffRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w9_survival_stack_tradeoff',
  lessonTitle: "Price of busting",
  lessonSubtitle: 'Tournament Pressure',
  caption: "Two players have the same cards and chip price in two events.",
  hint: '',
  hintPolicy: Act0HintPolicyV1.theoryOnly,
  question: "What shapes the cost of busting?",
  feedbackTitle: "Price of busting",
  feedbackReason:
      "These describe what you can gain by advancing and how much prize value you risk by busting.",
  teachingSteps: const [],
  options: const [
    Act0RunnerOptionV1(
      id: "payouts_without_the_other_stacks",
      label: "Payouts without the other stacks",
      isCorrect: false,
      preferredLabel: "Payouts and the remaining stacks",
      betterAnswerLabel: "Payouts and the remaining stacks",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "You have the prize ladder, but a 2 BB rival changes the cost of risking a medium stack; omitting that stack misses potential payout value.",
    ),
    Act0RunnerOptionV1(
      id: "payouts_and_the_remaining_stacks",
      label: "Payouts and the remaining stacks",
      isCorrect: true,
      preferredLabel: "Payouts and the remaining stacks",

      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: "Correct.",
      feedbackReason:
          "These describe what you can gain by advancing and how much prize value you risk by busting.",
    ),
    Act0RunnerOptionV1(
      id: "same_both",
      label: "Whether a reload is available",
      isCorrect: false,
      preferredLabel: "Payouts and the remaining stacks",
      betterAnswerLabel: "Payouts and the remaining stacks",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "Reload availability does not supply the prize ladder or stack distribution; it cannot tell you whether a particular tournament call is profitable.",
    ),
  ],
  table: _w9TextStudyTableV1,
);

final _w9SurvivalRecapRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w9_survival_recap',
  lessonTitle: "Chips and prizes recap",
  lessonSubtitle: 'Tournament Pressure',
  caption: "Think back to the 20 BB call and the 9 BB all-in.",
  hint: '',
  hintPolicy: Act0HintPolicyV1.theoryOnly,
  question: "Which plan balances growth and survival?",
  feedbackTitle: "Chips and prizes recap",
  feedbackReason:
      "That includes folding a costly bubble call and taking a sound first-in short-stack all-in.",
  teachingSteps: const [],
  options: const [
    Act0RunnerOptionV1(
      id: "avoid_thin_calls_but_skip_sound_steals",
      label: "Avoid thin calls but skip sound steals",
      isCorrect: false,
      preferredLabel: "Take risks that improve prize EV",
      betterAnswerLabel: "Take risks that improve prize EV",
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: "Look again.",
      feedbackReason:
          "Avoiding thin calls protects the stack, but passing the 9 BB SB opportunity also gives up chips available through folds.",
    ),
    Act0RunnerOptionV1(
      id: "wait_for_aa_before_entering",
      label: "Wait for AA before entering",
      isCorrect: false,
      preferredLabel: "Take risks that improve prize EV",
      betterAnswerLabel: "Take risks that improve prize EV",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "The 9 BB K9s example already offered a sound first-in all-in; waiting for AA lets forced bets consume opportunities.",
    ),
    Act0RunnerOptionV1(
      id: "take_risks_that_improve_prize_ev",
      label: "Take risks that improve prize EV",
      isCorrect: true,
      preferredLabel: "Take risks that improve prize EV",

      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: "Correct.",
      feedbackReason:
          "That includes folding a costly bubble call and taking a sound first-in short-stack all-in.",
    ),
  ],
  table: _w9TextStudyTableV1,
);

final _w9MRatioIntroRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w9_m_ratio_intro',
  lessonTitle: "How long will your stack last?",
  lessonSubtitle: 'Tournament Pressure',
  caption: "Sharky Three-Zone M",
  hint: '',
  hintPolicy: Act0HintPolicyV1.theoryOnly,
  question: "What does M estimate?",
  feedbackTitle: "How long will your stack last?",
  feedbackReason:
      "Divide the starting stack by the blinds and orbit's antes; future blind rises and pots won or lost can change that estimate.",
  teachingSteps: const [
    Act0TeachingStepV1(
      title: "How long will your stack last?",
      body:
          "M = stack / (SB + BB + antes for one lap). An ante is a forced fee. Green is 20 or more. Yellow is 10 to under 20. Red is below 10. At 0.5/1 with no ante, 12 BB gives M = 8.",
    ),
  ],
  options: const [],
  table: _w9TextStudyTableV1,
);

final _w9MRatioLapCountRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w9_m_ratio_lap_count',
  lessonTitle: "Laps left",
  lessonSubtitle: 'Tournament Pressure',
  caption: "Stack: 24 BB. Blinds: 0.5 and 1 BB. No antes.",
  hint: '',
  hintPolicy: Act0HintPolicyV1.theoryOnly,
  question: "How many laps does M give you?",
  feedbackTitle: "Laps left",
  feedbackReason: "Each lap costs 1.5 BB. Divide 24 by 1.5 to get 16.",
  teachingSteps: const [],
  options: const [
    Act0RunnerOptionV1(
      id: "16_laps",
      label: "16 laps",
      isCorrect: true,
      preferredLabel: "16 laps",

      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: "Correct.",
      feedbackReason: "Each lap costs 1.5 BB. Divide 24 by 1.5 to get 16.",
    ),
    Act0RunnerOptionV1(
      id: "24_laps",
      label: "24 laps",
      isCorrect: false,
      preferredLabel: "16 laps",
      betterAnswerLabel: "16 laps",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "The big blind costs 1 BB. If you leave out the small blind, the stack seems to last too long.",
    ),
    Act0RunnerOptionV1(
      id: "12_laps",
      label: "12 laps",
      isCorrect: false,
      preferredLabel: "16 laps",
      betterAnswerLabel: "16 laps",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "The two blinds cost 1.5 BB, not 2 BB. Use the real cost or you may rush into a poor spot.",
    ),
  ],
  table: _w9TextStudyTableV1,
);

final _w9MZoneRedRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w9_m_ratio_red_zone',
  lessonTitle: "Facing two ranges",
  lessonSubtitle: 'Tournament Pressure',
  caption:
      "You start with 7.5 BB. UTG raises with QQ+ or AK. CO calls with JJ, TT, 99 or AQs.",
  hint: '',
  hintPolicy: Act0HintPolicyV1.theoryOnly,
  question: "What should you do?",
  feedbackTitle: "Facing two ranges",
  feedbackReason:
      "Your M is 5 from 7.5 BB and 1.5 BB per lap. Fold Q8o to UTG’s raise and CO’s call because going all-in risks the last 6.5 BB against two strong ranges.",
  teachingSteps: const [],
  options: const [
    Act0RunnerOptionV1(
      id: "call_to_3_bb",
      label: "Call to 3 BB",
      isCorrect: false,
      preferredLabel: "Fold",
      betterAnswerLabel: "Fold",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "Calling costs 2 BB with Q8o against two strong ranges. Folding saves that payment and keeps 6.5 BB behind.",
    ),
    Act0RunnerOptionV1(
      id: "fold",
      label: "Fold",
      isCorrect: true,
      preferredLabel: "Fold",

      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: "Correct.",
      feedbackReason:
          "Your M is 5 from 7.5 BB and 1.5 BB per lap. Fold Q8o to UTG’s raise and CO’s call because going all-in risks the last 6.5 BB against two strong ranges.",
    ),
    Act0RunnerOptionV1(
      id: "all_in_to_7_5_bb",
      label: "All-in to 7.5 BB",
      isCorrect: false,
      preferredLabel: "Fold",
      betterAnswerLabel: "Fold",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "UTG and CO have put in 3 BB each. An all-in with Q8o has little chance to win by folds.",
    ),
  ],
  table: _day7TableV1(
    hero: 'bb',
    hand: "Qc 8d",
    street: PokerStreet.preflop,
    actor: 'bb',

    folded: const {"hj", "btn", "sb"},
    stacks: const {
      "utg": 30,
      "hj": 25,
      "co": 24,
      "btn": 18,
      "sb": 22,
      "bb": 7.5,
    },
    entries: const [
      ..._act0LessonBlinds,
      Act0ContributionV1(
        PokerStreet.preflop,
        'utg',
        Act0ContributionKindV1.wager,
        3,
      ),
      Act0ContributionV1(
        PokerStreet.preflop,
        'co',
        Act0ContributionKindV1.wager,
        3,
      ),
    ],
    history: const [
      Act0ActionTrailItemV1(label: "SB blind 0.5 BB"),
      Act0ActionTrailItemV1(label: "BB blind 1 BB"),
      Act0ActionTrailItemV1(label: "UTG raises to 3 BB"),
      Act0ActionTrailItemV1(label: "HJ folds"),
      Act0ActionTrailItemV1(label: "CO calls 3 BB"),
      Act0ActionTrailItemV1(label: "BTN folds"),
      Act0ActionTrailItemV1(label: "SB folds"),
    ],
    bets: const {
      'sb': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.post,
        label: 'Post',
        amountLabel: '0.5 BB',
      ),
      'bb': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.post,
        label: 'Post',
        amountLabel: '1 BB',
      ),
      'utg': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.raise,
        label: 'Raise',
        amountLabel: '3 BB',
      ),
      'co': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.call,
        label: 'Call',
        amountLabel: '3 BB',
      ),
    },
  ),
);

final _w9MRatioAnteCostRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w9_m_ratio_ante_cost',
  lessonTitle: "Add the antes",
  lessonSubtitle: 'Tournament Pressure',
  caption:
      "Six players each pay 0.1 BB per hand. The blinds are 0.5 BB and 1 BB.",
  hint: '',
  hintPolicy: Act0HintPolicyV1.theoryOnly,
  question: "What does a full lap cost?",
  feedbackTitle: "Add the antes",
  feedbackReason:
      "Six antes cost 0.6 BB. Add both blinds for a total of 2.1 BB.",
  teachingSteps: const [],
  options: const [
    Act0RunnerOptionV1(
      id: "1_6_bb",
      label: "1.6 BB",
      isCorrect: false,
      preferredLabel: "2.1 BB",
      betterAnswerLabel: "2.1 BB",
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: "Look again.",
      feedbackReason:
          "Counting only one ante misses five more payments. The full lap costs 2.1 BB.",
    ),
    Act0RunnerOptionV1(
      id: "1_5_bb",
      label: "1.5 BB",
      isCorrect: false,
      preferredLabel: "2.1 BB",
      betterAnswerLabel: "2.1 BB",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "Leaving out six antes understates the cost by 0.6 BB. The full lap costs 2.1 BB.",
    ),
    Act0RunnerOptionV1(
      id: "2_1_bb",
      label: "2.1 BB",
      isCorrect: true,
      preferredLabel: "2.1 BB",

      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: "Correct.",
      feedbackReason:
          "Six antes cost 0.6 BB. Add both blinds for a total of 2.1 BB.",
    ),
  ],
  table: _w9TextStudyTableV1,
);

final _w9MZoneGreenRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w9_m_ratio_green_zone',
  lessonTitle: "First raise from HJ",
  lessonSubtitle: 'Tournament Pressure',
  caption: "Stack: 30 BB. No antes. No special read.",
  hint: '',
  hintPolicy: Act0HintPolicyV1.theoryOnly,
  question: "Which opening size fits?",
  feedbackTitle: "First raise from HJ",
  feedbackReason:
      "Raise AJs from HJ to 2 BB because M is 20 and you can still play later streets. Raising to 3 BB risks another blind with no read that the remaining seats fold or call differently.",
  teachingSteps: const [
    Act0TeachingStepV1(
      title: "First raise from HJ",
      body: "A small first raise leaves room to play after the flop.",
    ),
  ],
  options: const [
    Act0RunnerOptionV1(
      id: "raise_to_2_bb",
      label: "Raise to 2 BB",
      isCorrect: true,
      preferredLabel: "Raise to 2 BB",

      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: "Correct.",
      feedbackReason:
          "Raise AJs from HJ to 2 BB because M is 20 and you can still play later streets. Raising to 3 BB risks another blind with no read that the remaining seats fold or call differently.",
    ),
    Act0RunnerOptionV1(
      id: "raise_to_3_bb",
      label: "Raise to 3 BB",
      isCorrect: false,
      preferredLabel: "Raise to 2 BB",
      betterAnswerLabel: "Raise to 2 BB",
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: "Look again.",
      feedbackReason:
          "From HJ with 30 BB, a 3 BB open loses one more chip if you fold to a raise. There is no read to pay for it.",
    ),
    Act0RunnerOptionV1(
      id: "all_in_to_30_bb",
      label: "All-in to 30 BB",
      isCorrect: false,
      preferredLabel: "Raise to 2 BB",
      betterAnswerLabel: "Raise to 2 BB",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "At M = 20, risking 30 BB all-in for the blinds wastes the room you have. Raise to 2 BB instead.",
    ),
  ],
  table: _day7TableV1(
    hero: 'hj',
    hand: "Ac Jc",
    street: PokerStreet.preflop,
    actor: 'hj',

    folded: const {"utg"},
    stacks: const {
      "utg": 24,
      "hj": 30,
      "co": 34,
      "btn": 32,
      "sb": 28,
      "bb": 35,
    },
    entries: const [..._act0LessonBlinds],
    history: const [
      Act0ActionTrailItemV1(label: "SB blind 0.5 BB"),
      Act0ActionTrailItemV1(label: "BB blind 1 BB"),
      Act0ActionTrailItemV1(label: "UTG folds"),
    ],
    bets: const {
      'sb': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.post,
        label: 'Post',
        amountLabel: '0.5 BB',
      ),
      'bb': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.post,
        label: 'Post',
        amountLabel: '1 BB',
      ),
    },
  ),
);

final _w9MZoneYellowRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w9_m_ratio_yellow_zone',
  lessonTitle: "First seat choice",
  lessonSubtitle: 'Tournament Pressure',
  caption: "First to act. Stack: 18 BB. No antes.",
  hint: '',
  hintPolicy: Act0HintPolicyV1.theoryOnly,
  question: "What should you do?",
  feedbackTitle: "First seat choice",
  feedbackReason:
      "Fold KQo from UTG because five players can still call or raise with stronger hands. Raising from this seat spends chips at M = 12 before you see what those players do.",
  teachingSteps: const [
    Act0TeachingStepV1(
      title: "First seat choice",
      body:
          "First-in chart: Premium AA–QQ and AKs, plus Strong JJ–TT, AKo, AQs and AJs, open from UTG to BTN. Medium AQo, AJo, KQ and AT open from HJ to BTN. Medium 99–22, KJ, QJ, KT and QT open from CO to BTN. Fold Weak hands.",
    ),
  ],
  options: const [
    Act0RunnerOptionV1(
      id: "raise_to_2_bb",
      label: "Raise to 2 BB",
      isCorrect: false,
      preferredLabel: "Fold",
      betterAnswerLabel: "Fold",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "Raising risks 2 BB while five players can call or raise with a stronger hand. Fold and look for a later seat.",
    ),
    Act0RunnerOptionV1(
      id: "fold",
      label: "Fold",
      isCorrect: true,
      preferredLabel: "Fold",

      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: "Correct.",
      feedbackReason:
          "Fold KQo from UTG because five players can still call or raise with stronger hands. Raising from this seat spends chips at M = 12 before you see what those players do.",
    ),
    Act0RunnerOptionV1(
      id: "all_in_to_18_bb",
      label: "All-in to 18 BB",
      isCorrect: false,
      preferredLabel: "Fold",
      betterAnswerLabel: "Fold",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "At M = 12, going all-in risks the full 18 BB against stronger hands behind. Folding keeps those chips.",
    ),
  ],
  table: _day7TableV1(
    hero: 'utg',
    hand: "Kc Qd",
    street: PokerStreet.preflop,
    actor: 'utg',

    folded: const {},
    stacks: const {
      "utg": 18,
      "hj": 24,
      "co": 22,
      "btn": 30,
      "sb": 20,
      "bb": 27,
    },
    entries: const [..._act0LessonBlinds],
    history: const [
      Act0ActionTrailItemV1(label: "SB blind 0.5 BB"),
      Act0ActionTrailItemV1(label: "BB blind 1 BB"),
    ],
    bets: const {
      'sb': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.post,
        label: 'Post',
        amountLabel: '0.5 BB',
      ),
      'bb': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.post,
        label: 'Post',
        amountLabel: '1 BB',
      ),
    },
  ),
);

final _w9MTableWindowTransferRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w9_m_ratio_table_window_transfer',
  lessonTitle: "Stack and seat",
  lessonSubtitle: 'Tournament Pressure',
  caption: "Stack: 18 BB. No antes. SB limps for 1 BB.",
  hint: '',
  hintPolicy: Act0HintPolicyV1.theoryOnly,
  question: "Which zone and plan fit?",
  feedbackTitle: "Stack and seat",
  feedbackReason:
      "18 BB pays for 12 orbits. You already put in the big blind and can see a flop for free.",
  teachingSteps: const [],
  options: const [
    Act0RunnerOptionV1(
      id: "green_zone",
      label: "Green. Check.",
      isCorrect: false,
      preferredLabel: "Yellow. Check.",
      betterAnswerLabel: "Yellow. Check.",
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: "Look again.",
      feedbackReason:
          "Checking is fine in BB, but M is 12. That gives you less time than a green stack.",
    ),
    Act0RunnerOptionV1(
      id: "wait_for_red",
      label: "Red. Fold.",
      isCorrect: false,
      preferredLabel: "Yellow. Check.",
      betterAnswerLabel: "Yellow. Check.",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason: "M is 12. A fold gives up a free flop after SB calls.",
    ),
    Act0RunnerOptionV1(
      id: "prepare_now",
      label: "Yellow. Check.",
      isCorrect: true,
      preferredLabel: "Yellow. Check.",

      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: "Correct.",
      feedbackReason:
          "18 BB pays for 12 orbits. You already put in the big blind and can see a flop for free.",
    ),
  ],
  table: _day7TableV1(
    hero: 'bb',
    hand: "7d 2c",
    street: PokerStreet.preflop,
    actor: 'bb',

    folded: const {"utg", "hj", "co", "btn"},
    stacks: const {
      "utg": 25,
      "hj": 30,
      "co": 24,
      "btn": 12,
      "sb": 20,
      "bb": 18,
    },
    entries: const [
      ..._act0LessonBlinds,
      Act0ContributionV1(
        PokerStreet.preflop,
        'sb',
        Act0ContributionKindV1.wager,
        0.5,
      ),
    ],
    history: const [
      Act0ActionTrailItemV1(label: "SB blind 0.5 BB"),
      Act0ActionTrailItemV1(label: "BB blind 1 BB"),
      Act0ActionTrailItemV1(label: "UTG folds"),
      Act0ActionTrailItemV1(label: "HJ folds"),
      Act0ActionTrailItemV1(label: "CO folds"),
      Act0ActionTrailItemV1(label: "BTN folds"),
      Act0ActionTrailItemV1(label: "SB calls 1 BB"),
    ],
    bets: const {
      'sb': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.call,
        label: 'Call',
        amountLabel: '1 BB',
      ),
      'bb': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.post,
        label: 'Post',
        amountLabel: '1 BB',
      ),
    },
  ),
);

final _w9MRatioRedZoneShoveRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w9_m_ratio_red_zone_shove',
  lessonTitle: "A short stack on BTN",
  lessonSubtitle: 'Tournament Pressure',
  caption:
      "Stack: 12 BB. No antes. Each blind calls an all-in with 77+, ATs+, AJo+ or KQs.",
  hint: '',
  hintPolicy: Act0HintPolicyV1.theoryOnly,
  question: "Go all-in or fold?",
  feedbackTitle: "A short stack on BTN",
  feedbackReason:
      "At M = 8, go all-in with AJo from BTN because both blinds fold outside their tight ranges. Folding gives up the 1.5 BB you can collect when both pass.",
  teachingSteps: const [
    Act0TeachingStepV1(
      title: "A short stack on BTN",
      body:
          "For push or fold, check your hand and seat. Think about what the blinds call with.",
    ),
  ],
  options: const [
    Act0RunnerOptionV1(
      id: "all_in_to_12_bb",
      label: "All-in to 12 BB",
      isCorrect: true,
      preferredLabel: "All-in to 12 BB",

      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: "Correct.",
      feedbackReason:
          "At M = 8, go all-in with AJo from BTN because both blinds fold outside their tight ranges. Folding gives up the 1.5 BB you can collect when both pass.",
    ),
    Act0RunnerOptionV1(
      id: "fold",
      label: "Fold",
      isCorrect: false,
      preferredLabel: "All-in to 12 BB",
      betterAnswerLabel: "All-in to 12 BB",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "With AJo first-in on BTN, folding passes a sound 12 BB all-in against the specified tight blind ranges; red-zone urgency is useful in this opening.",
    ),
  ],
  table: _day7TableV1(
    hero: 'btn',
    hand: "As Jd",
    street: PokerStreet.preflop,
    actor: 'btn',

    folded: const {"utg", "hj", "co"},
    stacks: const {
      "utg": 25,
      "hj": 30,
      "co": 24,
      "btn": 12,
      "sb": 20,
      "bb": 22,
    },
    entries: const [..._act0LessonBlinds],
    history: const [
      Act0ActionTrailItemV1(label: "SB blind 0.5 BB"),
      Act0ActionTrailItemV1(label: "BB blind 1 BB"),
      Act0ActionTrailItemV1(label: "UTG folds"),
      Act0ActionTrailItemV1(label: "HJ folds"),
      Act0ActionTrailItemV1(label: "CO folds"),
    ],
    bets: const {
      'sb': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.post,
        label: 'Post',
        amountLabel: '0.5 BB',
      ),
      'bb': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.post,
        label: 'Post',
        amountLabel: '1 BB',
      ),
    },
  ),
);

final _w9MRatioRecapRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w9_m_ratio_recap',
  lessonTitle: "When M helps",
  lessonSubtitle: 'Tournament Pressure',
  caption: "Use the cost of a lap.",
  hint: '',
  hintPolicy: Act0HintPolicyV1.theoryOnly,
  question: "How should you use the zone?",
  feedbackTitle: "When M helps",
  feedbackReason:
      "The red-zone examples differed in position, cards and action, so their correct decisions differed too.",
  teachingSteps: const [],
  options: const [
    Act0RunnerOptionV1(
      id: "combine_m_with_the_hand_and_tournament_context",
      label: "Combine M with the hand and tournament context",
      isCorrect: true,
      preferredLabel: "Combine M with the hand and tournament context",

      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: "Correct.",
      feedbackReason:
          "The red-zone examples differed in position, cards and action, so their correct decisions differed too.",
    ),
    Act0RunnerOptionV1(
      id: "use_m_and_cards_but_skip_the_payout_context",
      label: "Use M and cards but skip the payout context",
      isCorrect: false,
      preferredLabel: "Combine M with the hand and tournament context",
      betterAnswerLabel: "Combine M with the hand and tournament context",
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: "Look again.",
      feedbackReason:
          "Ignoring prizes misses what a bust costs with a 2 BB rival. Use the hand, stack pressure and payout context together.",
    ),
    Act0RunnerOptionV1(
      id: "shove_because_the_zone_is_red",
      label: "Commit your stack based on the red zone",
      isCorrect: false,
      preferredLabel: "Combine M with the hand and tournament context",
      betterAnswerLabel: "Combine M with the hand and tournament context",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "Going all-in with Q8o risks 6.5 BB more against a tight raise and a call. A stack that lasts five rounds still needs a hand and a betting spot that can win.",
    ),
  ],
  table: _w9TextStudyTableV1,
);

final _w9BubblePressureIntroRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w9_bubble_intro',
  lessonTitle: "What does a call cost?",
  lessonSubtitle: 'Tournament Pressure',
  caption: "The money bubble is the last stage before those left win a prize.",
  hint: '',
  hintPolicy: Act0HintPolicyV1.theoryOnly,
  question: "What is this example's risk premium?",
  feedbackTitle: "What does a call cost?",
  feedbackReason:
      "Subtract the chip threshold from the payout threshold: 55%-40%=15 percentage points.",
  teachingSteps: const [
    Act0TeachingStepV1(
      title: "What does a call cost?",
      body:
          "Equity is your share of a pot on average. A tie gets its share too. Near a prize, a call that could bust you may need more equity than the chip price asks for. The gap is the risk premium. A stack that can bust yours covers you. Check the rest of the stacks and the prizes too.",
    ),
  ],
  options: const [],
  table: _w9TextStudyTableV1,
);

final _w9BubblePremiumGapRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w9_bubble_premium_gap',
  lessonTitle: "The extra cost of a call",
  lessonSubtitle: 'Tournament Pressure',
  caption:
      "You need to win 36% of the time for chips. The prize model needs 51%.",
  hint: '',
  hintPolicy: Act0HintPolicyV1.theoryOnly,
  question: "How much extra equity does the call need?",
  feedbackTitle: "The extra cost of a call",
  feedbackReason: "The gap from 36% to 51% is 15 points.",
  teachingSteps: const [],
  options: const [
    Act0RunnerOptionV1(
      id: "36_points",
      label: "36 points",
      isCorrect: false,
      preferredLabel: "15 points",
      betterAnswerLabel: "15 points",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "36% is the chip price. Using it as the gap overstates the extra cost.",
    ),
    Act0RunnerOptionV1(
      id: "15_points",
      label: "15 points",
      isCorrect: true,
      preferredLabel: "15 points",

      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: "Correct.",
      feedbackReason: "The gap from 36% to 51% is 15 points.",
    ),
    Act0RunnerOptionV1(
      id: "51_points",
      label: "51 points",
      isCorrect: false,
      preferredLabel: "15 points",
      betterAnswerLabel: "15 points",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "51% is the whole target. Treating it as a gap counts the chip price twice.",
    ),
  ],
  table: _w9TextStudyTableV1,
);

final _w9MediumStackTightenRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w9_medium_stack_tighten',
  lessonTitle: "A raise behind you",
  lessonSubtitle: 'Tournament Pressure',
  caption:
      "Six left, five paid. Prizes in order: 500, 250, 120, 80, 50. BTN has you covered. BTN makes the third bet with JJ+ or AK. A call uses your last 16 BB. UTG has 2 BB.",
  hint: '',
  hintPolicy: Act0HintPolicyV1.theoryOnly,
  question: "Call or fold?",
  feedbackTitle: "A raise behind you",
  feedbackReason:
      "BTN raises with JJ or better or AK, so a 16 BB call risks your last chips against a strong range. Fold because UTG has just 2 BB and surviving can pay.",
  teachingSteps: const [
    Act0TeachingStepV1(
      title: "A raise behind you",
      body:
          "A 3-bet is the next raise after the first raise. Think about the hands that make that raise. The strength to open a hand can fall short of the strength to call a re-raise.",
    ),
  ],
  options: const [
    Act0RunnerOptionV1(
      id: "call_16_bb",
      label: "Call 16 BB",
      isCorrect: false,
      preferredLabel: "Fold",
      betterAnswerLabel: "Fold",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "Calling AQo costs 16 BB and needs 42.7% in chips. The strong range and the cost of busting give you a reason to fold.",
    ),
    Act0RunnerOptionV1(
      id: "fold",
      label: "Fold",
      isCorrect: true,
      preferredLabel: "Fold",

      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: "Correct.",
      feedbackReason:
          "BTN raises with JJ or better or AK, so a 16 BB call risks your last chips against a strong range. Fold because UTG has just 2 BB and surviving can pay.",
    ),
  ],
  table: _day7TableV1(
    hero: 'co',
    hand: "Ah Qd",
    street: PokerStreet.preflop,
    actor: 'co',

    folded: const {"utg", "hj", "sb", "bb"},
    stacks: const {"utg": 2, "hj": 12, "co": 18, "btn": 50, "sb": 8, "bb": 10},
    entries: const [
      ..._act0LessonBlinds,
      Act0ContributionV1(
        PokerStreet.preflop,
        'co',
        Act0ContributionKindV1.wager,
        2,
      ),
      Act0ContributionV1(
        PokerStreet.preflop,
        'btn',
        Act0ContributionKindV1.wager,
        18,
      ),
    ],
    history: const [
      Act0ActionTrailItemV1(label: "SB blind 0.5 BB"),
      Act0ActionTrailItemV1(label: "BB blind 1 BB"),
      Act0ActionTrailItemV1(label: "UTG folds"),
      Act0ActionTrailItemV1(label: "HJ folds"),
      Act0ActionTrailItemV1(label: "CO raises to 2 BB"),
      Act0ActionTrailItemV1(label: "BTN raises to 18 BB"),
      Act0ActionTrailItemV1(label: "SB folds"),
      Act0ActionTrailItemV1(label: "BB folds"),
    ],
    bets: const {
      'sb': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.post,
        label: 'Post',
        amountLabel: '0.5 BB',
      ),
      'bb': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.post,
        label: 'Post',
        amountLabel: '1 BB',
      ),
      'co': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.raise,
        label: 'Raise',
        amountLabel: '2 BB',
      ),
      'btn': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.raise,
        label: 'Raise',
        amountLabel: '18 BB',
      ),
    },
  ),
);

final _w9BigStackLeverageRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w9_big_stack_leverage',
  lessonTitle: "Three players left to act",
  lessonSubtitle: 'Tournament Pressure',
  caption:
      "Six left, five paid. You cover BTN, SB and BB. They all fold 85% of the time to either size. When one re-raises, you fold.",
  hint: '',
  hintPolicy: Act0HintPolicyV1.theoryOnly,
  question: "How should you open?",
  feedbackTitle: "Three players left to act",
  feedbackReason:
      "Raise to 2 BB from CO because BTN and both blinds all fold 85% of the time at either size. Raising to 3 BB costs another blind when they raise and you fold.",
  teachingSteps: const [
    Act0TeachingStepV1(
      title: "Three players left to act",
      body:
          "A big stack can put a smaller one at risk. Choose a size based on how the other players will act.",
    ),
  ],
  options: const [
    Act0RunnerOptionV1(
      id: "raise_to_3_bb",
      label: "Raise to 3 BB",
      isCorrect: false,
      preferredLabel: "Raise to 2 BB",
      betterAnswerLabel: "Raise to 2 BB",
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: "Look again.",
      feedbackReason:
          "You use the right pressure opportunity, but the same 85% fold rate means the extra 1 BB is lost on the 15% resistance branch.",
    ),
    Act0RunnerOptionV1(
      id: "fold",
      label: "Fold",
      isCorrect: false,
      preferredLabel: "Raise to 2 BB",
      betterAnswerLabel: "Raise to 2 BB",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "With KJo in CO and 85% joint folds behind, folding gives up a profitable chance to collect 1.5 BB from stacks you cover.",
    ),
    Act0RunnerOptionV1(
      id: "raise_to_2_bb",
      label: "Raise to 2 BB",
      isCorrect: true,
      preferredLabel: "Raise to 2 BB",

      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: "Correct.",
      feedbackReason:
          "Raise to 2 BB from CO because BTN and both blinds all fold 85% of the time at either size. Raising to 3 BB costs another blind when they raise and you fold.",
    ),
  ],
  table: _day7TableV1(
    hero: 'co',
    hand: "Kc Jd",
    street: PokerStreet.preflop,
    actor: 'co',

    folded: const {"utg", "hj"},
    stacks: const {"utg": 3, "hj": 12, "co": 60, "btn": 28, "sb": 24, "bb": 26},
    entries: const [..._act0LessonBlinds],
    history: const [
      Act0ActionTrailItemV1(label: "SB blind 0.5 BB"),
      Act0ActionTrailItemV1(label: "BB blind 1 BB"),
      Act0ActionTrailItemV1(label: "UTG folds"),
      Act0ActionTrailItemV1(label: "HJ folds"),
    ],
    bets: const {
      'sb': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.post,
        label: 'Post',
        amountLabel: '0.5 BB',
      ),
      'bb': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.post,
        label: 'Post',
        amountLabel: '1 BB',
      ),
    },
  ),
);

final _w9BubbleCoverSeatRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w9_bubble_cover_seat',
  lessonTitle: "Read the stacks",
  lessonSubtitle: 'Tournament Pressure',
  caption:
      "You have 32 BB. Three stacks behind you have 9 BB, 14 BB and 30 BB.",
  hint: '',
  hintPolicy: Act0HintPolicyV1.theoryOnly,
  question: "How many of those stacks can bust you?",
  feedbackTitle: "Read the stacks",
  feedbackReason:
      "You have more than each stack. One of those players can take chips but cannot bust you heads-up.",
  teachingSteps: const [],
  options: const [
    Act0RunnerOptionV1(
      id: "0_stacks",
      label: "0 stacks",
      isCorrect: true,
      preferredLabel: "0 stacks",

      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: "Correct.",
      feedbackReason:
          "You have more than each stack. One of those players can take chips but cannot bust you heads-up.",
    ),
    Act0RunnerOptionV1(
      id: "1_stack",
      label: "1 stack",
      isCorrect: false,
      preferredLabel: "0 stacks",
      betterAnswerLabel: "0 stacks",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "30 BB comes close. You still have 2 BB if you lose 30 BB to that stack.",
    ),
    Act0RunnerOptionV1(
      id: "3_stacks",
      label: "3 stacks",
      isCorrect: false,
      preferredLabel: "0 stacks",
      betterAnswerLabel: "0 stacks",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "Each stack has less than 32 BB. Adding them up gives the wrong risk for a heads-up pot.",
    ),
  ],
  table: _w9TextStudyTableV1,
);

final _w9BubbleShortStackRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w9_bubble_short_stack',
  lessonTitle: "Shortest stack",
  lessonSubtitle: 'Tournament Pressure',
  caption:
      "Six left, five paid. You start with 6 BB, the shortest stack. It folds to you in HJ.",
  hint: '',
  hintPolicy: Act0HintPolicyV1.theoryOnly,
  question: "Go all-in or fold?",
  feedbackTitle: "Shortest stack",
  feedbackReason:
      "Go all-in with AKo from HJ because you are the 6 BB shortest stack and others can fold. Folding forfeits the chance to win the 1.5 BB in blinds while you can still threaten a raise.",
  teachingSteps: const [
    Act0TeachingStepV1(
      title: "Shortest stack",
      body:
          "When you act first, an all-in can win the blinds. Compare the short stack and the hand with the cost of waiting.",
    ),
  ],
  options: const [
    Act0RunnerOptionV1(
      id: "all_in_to_6_bb",
      label: "All-in to 6 BB",
      isCorrect: true,
      preferredLabel: "All-in to 6 BB",

      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: "Correct.",
      feedbackReason:
          "Go all-in with AKo from HJ because you are the 6 BB shortest stack and others can fold. Folding forfeits the chance to win the 1.5 BB in blinds while you can still threaten a raise.",
    ),
    Act0RunnerOptionV1(
      id: "fold",
      label: "Fold",
      isCorrect: false,
      preferredLabel: "All-in to 6 BB",
      betterAnswerLabel: "All-in to 6 BB",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "Folding misses a chance to take the blinds because AKo can go all-in first at 6 BB. No smaller stack can bust ahead of you.",
    ),
  ],
  table: _day7TableV1(
    hero: 'hj',
    hand: "Ac Kh",
    street: PokerStreet.preflop,
    actor: 'hj',

    folded: const {"utg"},
    stacks: const {"utg": 18, "hj": 6, "co": 20, "btn": 24, "sb": 12, "bb": 20},
    entries: const [..._act0LessonBlinds],
    history: const [
      Act0ActionTrailItemV1(label: "SB blind 0.5 BB"),
      Act0ActionTrailItemV1(label: "BB blind 1 BB"),
      Act0ActionTrailItemV1(label: "UTG folds"),
    ],
    bets: const {
      'sb': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.post,
        label: 'Post',
        amountLabel: '0.5 BB',
      ),
      'bb': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.post,
        label: 'Post',
        amountLabel: '1 BB',
      ),
    },
  ),
);

final _w9BubbleTableRiskTransferRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w9_bubble_table_risk_transfer',
  lessonTitle: "A raise from BB",
  lessonSubtitle: 'Tournament Pressure',
  caption:
      "Six left, five paid. Prizes in order: 500, 250, 120, 80, 50. BB starts with 50 BB and raises to 18 BB with JJ+ or AK. You opened to 2.5 BB.",
  hint: '',
  hintPolicy: Act0HintPolicyV1.theoryOnly,
  question: "Call or fold?",
  feedbackTitle: "A raise from BB",
  feedbackReason:
      "BB raises with JJ+ or AK, leaving AJo under 31%. Fold because calling 15.5 BB needs 42.5% and risks elimination. A different raise range, set of stacks or set of prizes can change the answer.",
  teachingSteps: const [],
  options: const [
    Act0RunnerOptionV1(
      id: "call_15_5_bb",
      label: "Call 15.5 BB",
      isCorrect: false,
      preferredLabel: "Fold",
      betterAnswerLabel: "Fold",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "Calling 15.5 BB needs 42.5% before payout pressure. AJo falls short against JJ+ or AK, so folding keeps your last chips.",
    ),
    Act0RunnerOptionV1(
      id: "fold",
      label: "Fold",
      isCorrect: true,
      preferredLabel: "Fold",

      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: "Correct.",
      feedbackReason:
          "BB raises with JJ+ or AK, leaving AJo under 31%. Fold because calling 15.5 BB needs 42.5% and risks elimination. A different raise range, set of stacks or set of prizes can change the answer.",
    ),
  ],
  table: _day7TableV1(
    hero: 'btn',
    hand: "As Jd",
    street: PokerStreet.preflop,
    actor: 'btn',

    folded: const {"utg", "hj", "co", "sb"},
    stacks: const {"utg": 2, "hj": 12, "co": 10, "btn": 18, "sb": 8, "bb": 50},
    entries: const [
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
    history: const [
      Act0ActionTrailItemV1(label: "SB blind 0.5 BB"),
      Act0ActionTrailItemV1(label: "BB blind 1 BB"),
      Act0ActionTrailItemV1(label: "UTG folds"),
      Act0ActionTrailItemV1(label: "HJ folds"),
      Act0ActionTrailItemV1(label: "CO folds"),
      Act0ActionTrailItemV1(label: "BTN raises to 2.5 BB"),
      Act0ActionTrailItemV1(label: "SB folds"),
      Act0ActionTrailItemV1(label: "BB raises to 18 BB"),
    ],
    bets: const {
      'sb': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.post,
        label: 'Post',
        amountLabel: '0.5 BB',
      ),
      'bb': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.raise,
        label: 'Raise',
        amountLabel: '18 BB',
      ),
      'btn': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.raise,
        label: 'Raise',
        amountLabel: '2.5 BB',
      ),
    },
  ).copyWith(autoPlayHistory: true),
);

final _w9BubbleRecapRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w9_bubble_recap',
  lessonTitle: "Three stacks recap",
  lessonSubtitle: 'Tournament Pressure',
  caption: "Recall the three stack sizes in this lesson.",
  hint: '',
  hintPolicy: Act0HintPolicyV1.theoryOnly,
  question: "What guides the bubble adjustment?",
  feedbackTitle: "Three stacks recap",
  feedbackReason:
      "These explain why the 18 BB AJo fold, 60 BB pressure open and 6 BB AKo all-in can coexist.",
  teachingSteps: const [],
  options: const [
    Act0RunnerOptionV1(
      id: "stack_size_and_cards_without_the_payouts",
      label: "Stack size and cards without the payouts",
      isCorrect: false,
      preferredLabel: "Coverage, payouts, ranges and the remaining stacks",
      betterAnswerLabel: "Coverage, payouts, ranges and the remaining stacks",
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: "Look again.",
      feedbackReason:
          "Ignoring prizes misses the cost of busting before a 2 BB rival. Include payouts, the hands in play and who covers whom.",
    ),
    Act0RunnerOptionV1(
      id: "coverage_payouts_ranges_and_the_remaining_stacks",
      label: "Coverage, payouts, ranges and the remaining stacks",
      isCorrect: true,
      preferredLabel: "Coverage, payouts, ranges and the remaining stacks",

      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: "Correct.",
      feedbackReason:
          "These explain why the 18 BB AJo fold, 60 BB pressure open and 6 BB AKo all-in can coexist.",
    ),
    Act0RunnerOptionV1(
      id: "being_short_justifies_a_loose_call_off",
      label: "Being short justifies a loose call-off",
      isCorrect: false,
      preferredLabel: "Coverage, payouts, ranges and the remaining stacks",
      betterAnswerLabel: "Coverage, payouts, ranges and the remaining stacks",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "The 7.5 BB Q8o deal still faced strong ranges; calling or going all-in with weak cards can remove the stack before a suitable opportunity.",
    ),
  ],
  table: _w9TextStudyTableV1,
);

final _w9CheckpointIntroRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w9_checkpoint_intro',
  lessonTitle: "Read stack pressure",
  lessonSubtitle: 'Tournament Pressure',
  caption: "Five deals test how you read risk.",
  hint: '',
  hintPolicy: Act0HintPolicyV1.theoryOnly,
  question: "What belongs in the pressure read?",
  feedbackTitle: "Read stack pressure",
  feedbackReason:
      "Together these describe both the poker decision and the cost of tournament elimination.",
  teachingSteps: const [
    Act0TeachingStepV1(
      title: "Read stack pressure",
      body:
          "Read the hand and the action. Work out how long the stack can last. Check who can bust whom. When a prize model is given, use its inputs. The next five deals ask you to put these steps together.",
    ),
  ],
  options: const [],
  table: _w9TextStudyTableV1,
);

final _w9PrizeModelInputsRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w9_prize_model_inputs',
  lessonTitle: "What a prize model needs",
  lessonSubtitle: 'Tournament Pressure',
  caption:
      "One model gives a chip price. A second model gives the win rate you need to keep prize value.",
  hint: '',
  hintPolicy: Act0HintPolicyV1.theoryOnly,
  question: "Which input belongs to the prize model?",
  feedbackTitle: "What a prize model needs",
  feedbackReason:
      "A prize model needs the payouts and stacks. A bigger jump in prizes can change what a fold is worth.",
  teachingSteps: const [],
  options: const [
    Act0RunnerOptionV1(
      id: "your_two_card_suits",
      label: "Your two card suits",
      isCorrect: false,
      preferredLabel: "The prize for each place",
      betterAnswerLabel: "The prize for each place",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "Your suits can change your share of the pot. They give no value to the next paid place.",
    ),
    Act0RunnerOptionV1(
      id: "the_name_of_the_street",
      label: "The name of the street",
      isCorrect: false,
      preferredLabel: "The prize for each place",
      betterAnswerLabel: "The prize for each place",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "The street tells you when the bet came. It does not tell you what you stand to win by moving up.",
    ),
    Act0RunnerOptionV1(
      id: "the_prize_for_each_place",
      label: "The prize for each place",
      isCorrect: true,
      preferredLabel: "The prize for each place",

      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: "Correct.",
      feedbackReason:
          "A prize model needs the payouts and stacks. A bigger jump in prizes can change what a fold is worth.",
    ),
  ],
  table: _w9TextStudyTableV1,
);

final _w9CheckpointSurvivalLineRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w9_checkpoint_survival_line',
  lessonTitle: "First in from CO",
  lessonSubtitle: 'Tournament Pressure',
  caption:
      "You start with 7.5 BB. The money is far off. It folds to you in CO.",
  hint: '',
  hintPolicy: Act0HintPolicyV1.theoryOnly,
  question: "Go all-in or fold?",
  feedbackTitle: "First in from CO",
  feedbackReason:
      "Go all-in first from CO with AQs because BTN and the blinds may fold, and weaker aces can pay. Folding gives up a chance to add the 1.5 BB blinds to your 7.5 BB stack.",
  teachingSteps: const [],
  options: const [
    Act0RunnerOptionV1(
      id: "all_in_to_7_5_bb",
      label: "All-in to 7.5 BB",
      isCorrect: true,
      preferredLabel: "All-in to 7.5 BB",

      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: "Correct.",
      feedbackReason:
          "Go all-in first from CO with AQs because BTN and the blinds may fold, and weaker aces can pay. Folding gives up a chance to add the 1.5 BB blinds to your 7.5 BB stack.",
    ),
    Act0RunnerOptionV1(
      id: "fold",
      label: "Fold",
      isCorrect: false,
      preferredLabel: "All-in to 7.5 BB",
      betterAnswerLabel: "All-in to 7.5 BB",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "AQs with 7.5 BB first-in from CO is a suitable short-stack opportunity; folding gives up both fold equity and value when worse hands continue.",
    ),
  ],
  table: _day7TableV1(
    hero: 'co',
    hand: "Ac Qc",
    street: PokerStreet.preflop,
    actor: 'co',

    folded: const {"utg", "hj"},
    stacks: const {
      "utg": 24,
      "hj": 28,
      "co": 7.5,
      "btn": 20,
      "sb": 18,
      "bb": 25,
    },
    entries: const [..._act0LessonBlinds],
    history: const [
      Act0ActionTrailItemV1(label: "SB blind 0.5 BB"),
      Act0ActionTrailItemV1(label: "BB blind 1 BB"),
      Act0ActionTrailItemV1(label: "UTG folds"),
      Act0ActionTrailItemV1(label: "HJ folds"),
    ],
    bets: const {
      'sb': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.post,
        label: 'Post',
        amountLabel: '0.5 BB',
      ),
      'bb': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.post,
        label: 'Post',
        amountLabel: '1 BB',
      ),
    },
  ),
);

final _w9CheckpointZoneLineRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w9_checkpoint_zone_line',
  lessonTitle: "First to act",
  lessonSubtitle: 'Tournament Pressure',
  caption: "Starting stack: 33 BB in first seat. No antes.",
  hint: '',
  hintPolicy: Act0HintPolicyV1.theoryOnly,
  question: "Which zone and opening fit?",
  feedbackTitle: "First to act",
  feedbackReason:
      "33/1.5=22 is green. TT is Strong and opens UTG while 31 BB remain for later decisions.",
  teachingSteps: const [],
  options: const [
    Act0RunnerOptionV1(
      id: "green_raise_to_2_bb",
      label: "Green; raise to 2 BB",
      isCorrect: true,
      preferredLabel: "Green; raise to 2 BB",

      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: "Correct.",
      feedbackReason:
          "33/1.5=22 is green. TT is Strong and opens UTG while 31 BB remain for later decisions.",
    ),
    Act0RunnerOptionV1(
      id: "yellow_raise_to_2_bb",
      label: "Yellow; raise to 2 BB",
      isCorrect: false,
      preferredLabel: "Green; raise to 2 BB",
      betterAnswerLabel: "Green; raise to 2 BB",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "The TT open is suitable, but 33/1.5=22 is green, not yellow; the mistaken zone overstates urgency with 33 BB.",
    ),
    Act0RunnerOptionV1(
      id: "same_zone",
      label: "Red; all-in to 33 BB",
      isCorrect: false,
      preferredLabel: "Green; raise to 2 BB",
      betterAnswerLabel: "Green; raise to 2 BB",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "33/1.5=22 is green, not red; TT has no urgency to risk 33 BB for a 1.5 BB pot; a small open retains useful options against the five players behind.",
    ),
  ],
  table: _day7TableV1(
    hero: 'utg',
    hand: "Ts Th",
    street: PokerStreet.preflop,
    actor: 'utg',

    folded: const {},
    stacks: const {
      "utg": 33,
      "hj": 35,
      "co": 22,
      "btn": 40,
      "sb": 28,
      "bb": 31,
    },
    entries: const [..._act0LessonBlinds],
    history: const [
      Act0ActionTrailItemV1(label: "SB blind 0.5 BB"),
      Act0ActionTrailItemV1(label: "BB blind 1 BB"),
    ],
    bets: const {
      'sb': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.post,
        label: 'Post',
        amountLabel: '0.5 BB',
      ),
      'bb': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.post,
        label: 'Post',
        amountLabel: '1 BB',
      ),
    },
  ),
);

final _w9CheckpointBubbleLineRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w9_checkpoint_bubble_line',
  lessonTitle: "River bet from BB",
  lessonSubtitle: 'Tournament Pressure',
  caption:
      "Six left, five paid. Prizes in order: 500, 250, 120, 80, 50. BB bets 12 BB into 8.5 BB. The range is 60% AK, K8 or 88 and 40% missed 97s. You win 40% with no ties. The prize threshold is 58.4%.",
  hint: '',
  hintPolicy: Act0HintPolicyV1.theoryOnly,
  question: "Call or fold?",
  feedbackTitle: "River bet from BB",
  feedbackReason:
      "BB bets stronger hands and missed nine-seven. Fold because your 40% wins beat the 36.9% chip price but do not clear the 58.4% prize threshold for calling your last 12 BB.",
  teachingSteps: const [],
  options: const [
    Act0RunnerOptionV1(
      id: "call_12_bb",
      label: "Call 12 BB",
      isCorrect: false,
      preferredLabel: "Fold",
      betterAnswerLabel: "Fold",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "KQ is top pair, but loses to AK, K8 and 88. The 1 BB chip profit does not cover the prize value lost by risking elimination against the covering BB.",
    ),
    Act0RunnerOptionV1(
      id: "fold",
      label: "Fold",
      isCorrect: true,
      preferredLabel: "Fold",

      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: "Correct.",
      feedbackReason:
          "BB bets stronger hands and missed nine-seven. Fold because your 40% wins beat the 36.9% chip price but do not clear the 58.4% prize threshold for calling your last 12 BB.",
    ),
  ],
  table: _day7TableV1(
    hero: 'co',
    hand: "Kc Qd",
    street: PokerStreet.river,
    actor: 'co',
    board: _act0LessonCardsV1("Ks 8h 4d 6s 2c"),
    folded: const {"utg", "hj", "btn", "sb"},
    stacks: const {"utg": 3, "hj": 11, "co": 16, "btn": 15, "sb": 7, "bb": 48},
    entries: const [
      ..._act0LessonBlinds,
      Act0ContributionV1(
        PokerStreet.preflop,
        'co',
        Act0ContributionKindV1.wager,
        2,
      ),
      Act0ContributionV1(
        PokerStreet.preflop,
        'bb',
        Act0ContributionKindV1.wager,
        1,
      ),
      Act0ContributionV1(
        PokerStreet.flop,
        'co',
        Act0ContributionKindV1.wager,
        2,
      ),
      Act0ContributionV1(
        PokerStreet.flop,
        'bb',
        Act0ContributionKindV1.wager,
        2,
      ),
      Act0ContributionV1(
        PokerStreet.river,
        'bb',
        Act0ContributionKindV1.wager,
        12,
      ),
    ],
    history: const [
      Act0ActionTrailItemV1(label: "SB blind 0.5 BB"),
      Act0ActionTrailItemV1(label: "BB blind 1 BB"),
      Act0ActionTrailItemV1(label: "UTG folds"),
      Act0ActionTrailItemV1(label: "HJ folds"),
      Act0ActionTrailItemV1(label: "CO raises to 2 BB"),
      Act0ActionTrailItemV1(label: "BTN folds"),
      Act0ActionTrailItemV1(label: "SB folds"),
      Act0ActionTrailItemV1(label: "BB calls 2 BB"),
      Act0ActionTrailItemV1(label: "Flop: BB checks"),
      Act0ActionTrailItemV1(label: "CO bets 2 BB"),
      Act0ActionTrailItemV1(label: "BB calls 2 BB"),
      Act0ActionTrailItemV1(label: "Turn: BB checks"),
      Act0ActionTrailItemV1(label: "CO checks"),
      Act0ActionTrailItemV1(label: "River: BB bets 12 BB"),
    ],
    bets: const {
      'bb': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.bet,
        label: 'Bet',
        amountLabel: '12 BB',
      ),
    },
  ),
);

final _w9TablePressureNoticeRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w9_checkpoint_table_notice',
  lessonTitle: "Four seats behind",
  lessonSubtitle: 'Tournament Pressure',
  caption:
      "Six left, five paid. You cover the four seats behind. They all fold 80% of the time to either size. When one re-raises, you fold.",
  hint: '',
  hintPolicy: Act0HintPolicyV1.theoryOnly,
  question: "How should you open?",
  feedbackTitle: "Four seats behind",
  feedbackReason:
      "Raise to 2 BB from HJ because all four players behind fold 80% of the time at either size. Raising to 3 BB risks another blind on the hands where they resist.",
  teachingSteps: const [],
  options: const [
    Act0RunnerOptionV1(
      id: "raise_to_3_bb",
      label: "Raise to 3 BB",
      isCorrect: false,
      preferredLabel: "Raise to 2 BB",
      betterAnswerLabel: "Raise to 2 BB",
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: "Look again.",
      feedbackReason:
          "You choose an allowed HJ hand, but the same 80% fold rate means the larger size loses an extra 1 BB on resistance without adding successful steals.",
    ),
    Act0RunnerOptionV1(
      id: "raise_to_2_bb",
      label: "Raise to 2 BB",
      isCorrect: true,
      preferredLabel: "Raise to 2 BB",

      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: "Correct.",
      feedbackReason:
          "Raise to 2 BB from HJ because all four players behind fold 80% of the time at either size. Raising to 3 BB risks another blind on the hands where they resist.",
    ),
    Act0RunnerOptionV1(
      id: "fold",
      label: "Fold",
      isCorrect: false,
      preferredLabel: "Raise to 2 BB",
      betterAnswerLabel: "Raise to 2 BB",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "KQs from HJ can gain from the stated 80% joint fold rate; folding passes a profitable small-open opportunity despite covering the opponents behind.",
    ),
  ],
  table: _day7TableV1(
    hero: 'hj',
    hand: "Kd Qd",
    street: PokerStreet.preflop,
    actor: 'hj',

    folded: const {"utg"},
    stacks: const {"utg": 3, "hj": 55, "co": 26, "btn": 22, "sb": 24, "bb": 20},
    entries: const [..._act0LessonBlinds],
    history: const [
      Act0ActionTrailItemV1(label: "SB blind 0.5 BB"),
      Act0ActionTrailItemV1(label: "BB blind 1 BB"),
      Act0ActionTrailItemV1(label: "UTG folds"),
    ],
    bets: const {
      'sb': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.post,
        label: 'Post',
        amountLabel: '0.5 BB',
      ),
      'bb': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.post,
        label: 'Post',
        amountLabel: '1 BB',
      ),
    },
  ),
);

final _world9TournamentCheckpointRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w9_checkpoint_review',
  lessonTitle: "The last call",
  lessonSubtitle: 'Tournament Pressure',
  caption:
      "Six left, five paid. BTN covers you and raises to 20 BB with QQ+ or AK. A call uses your last 19 BB.",
  hint: '',
  hintPolicy: Act0HintPolicyV1.theoryOnly,
  question: "Call or fold?",
  feedbackTitle: "The last call",
  feedbackReason:
      "Call 19 BB because BTN raises with QQ or better or AK, and AA is ahead of most of that range. Folding protects your stack but gives up a strong prize opportunity even with a 2 BB rival.",
  teachingSteps: const [],
  options: const [
    Act0RunnerOptionV1(
      id: "call_19_bb",
      label: "Call 19 BB",
      isCorrect: true,
      preferredLabel: "Call 19 BB",

      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: "Correct.",
      feedbackReason:
          "Call 19 BB because BTN raises with QQ or better or AK, and AA is ahead of most of that range. Folding protects your stack but gives up a strong prize opportunity even with a 2 BB rival.",
    ),
    Act0RunnerOptionV1(
      id: "fold",
      label: "Fold",
      isCorrect: false,
      preferredLabel: "Call 19 BB",
      betterAnswerLabel: "Call 19 BB",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "A 2 BB rival creates pressure, but AA against QQ+/AK is a sufficiently strong opportunity; folding gives up substantial prize value, not merely a thin chip edge.",
    ),
  ],
  table: _day7TableV1(
    hero: 'bb',
    hand: "As Ah",
    street: PokerStreet.preflop,
    actor: 'bb',

    folded: const {"utg", "hj", "co", "sb"},
    stacks: const {"utg": 2, "hj": 10, "co": 8, "btn": 50, "sb": 10, "bb": 20},
    entries: const [
      ..._act0LessonBlinds,
      Act0ContributionV1(
        PokerStreet.preflop,
        'btn',
        Act0ContributionKindV1.wager,
        20,
      ),
    ],
    history: const [
      Act0ActionTrailItemV1(label: "SB blind 0.5 BB"),
      Act0ActionTrailItemV1(label: "BB blind 1 BB"),
      Act0ActionTrailItemV1(label: "UTG folds"),
      Act0ActionTrailItemV1(label: "HJ folds"),
      Act0ActionTrailItemV1(label: "CO folds"),
      Act0ActionTrailItemV1(label: "BTN raises to 20 BB"),
      Act0ActionTrailItemV1(label: "SB folds"),
    ],
    bets: const {
      'sb': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.post,
        label: 'Post',
        amountLabel: '0.5 BB',
      ),
      'bb': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.post,
        label: 'Post',
        amountLabel: '1 BB',
      ),
      'btn': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.raise,
        label: 'Raise',
        amountLabel: '20 BB',
      ),
    },
  ),
);

// Concept questions use the stated setup without an unrelated deal.
const _w10TextStudyTableV1 = Act0TableStateV1(
  scope: Act0TableScopeV1.explanation,
  showDecisionPremise: true,
  tableFormat: Act0TableFormatV1.sixMax,
  playerCount: 6,
  seats: [],
  heroCards: [],
  boardCards: [],
  streetLabel: '',
  potLabel: '',
  toCallLabel: '',
  centerLabel: '',
  highlightedSeatIds: [],
  highlightedCardIds: [],
);

final _w10PlayerTypeIntroRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w10_player_type_intro',
  lessonTitle: "How players act",
  lessonSubtitle: 'Player Adjustment',
  caption: "Read how the table plays.",
  hint: '',
  hintPolicy: Act0HintPolicyV1.theoryOnly,
  question: "Which clue is most useful over time?",
  feedbackTitle: "How players act",
  feedbackReason:
      "Several hands can show how often a player folds, calls or bets. You can use that read in the next hand.",
  teachingSteps: const [
    Act0TeachingStepV1(
      title: "How players act",
      body:
          "A nit plays few hands and folds a lot. A loose-passive player calls a lot and rarely raises. A calling station calls bets too much. An aggressive player bets and raises a lot. One who does so with too many weak hands is over-aggressive. An underbluffer bets strong hands and seldom bluffs. A 3-bet is a raise over an open raise. A c-bet is a flop bet by the player who raised preflop. These hands have no rake or antes.",
    ),
  ],
  options: const [],

  table: _w10TextStudyTableV1,
);

final _w10NitTagRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w10_nit_tag',
  lessonTitle: "Read both blinds",
  lessonSubtitle: 'Player Adjustment',
  caption:
      "Both blinds are nits. They fold 90% of the time to either size. When one 3-bets, you fold.",
  hint: '',
  hintPolicy: Act0HintPolicyV1.theoryOnly,
  question: "Open or fold?",
  feedbackTitle: "Read both blinds",
  feedbackReason:
      "The blinds fold 90% of the time. The steal earns 1.15 BB on average: 0.90 x 1.5 - 0.10 x 2.",
  teachingSteps: const [
    Act0TeachingStepV1(
      title: "Read both blinds",
      body:
          "In the first-in chart, open Premium (AA–QQ and AKs) or Strong (JJ–TT, AKo, AQs and AJs) from UTG through BTN. Open Medium AQo, AJo, KQ and AT from HJ through BTN. Open Medium 99–22, KJ, QJ, KT and QT from CO or BTN. Fold Weak hands. This drill gives a rare exception based on who is left to act.",
    ),
  ],
  options: const [
    Act0RunnerOptionV1(
      id: "raise_to_2_bb",
      label: "Raise to 2 BB",
      isCorrect: true,
      preferredLabel: "Raise to 2 BB",

      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: "Correct.",
      feedbackReason:
          "The blinds fold 90% of the time. The steal earns 1.15 BB on average: 0.90 x 1.5 - 0.10 x 2.",
    ),
    Act0RunnerOptionV1(
      id: "fold",
      label: "Fold",
      isCorrect: false,
      preferredLabel: "Raise to 2 BB",
      betterAnswerLabel: "Raise to 2 BB",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "97s is Weak in the base chart, but this strong read gives a 90% chance to win 1.5 BB without a flop. Folding misses that small steal.",
    ),
    Act0RunnerOptionV1(
      id: "raise_to_4_bb",
      label: "Raise to 4 BB",
      isCorrect: false,
      preferredLabel: "Raise to 2 BB",
      betterAnswerLabel: "Raise to 2 BB",
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: "Look again.",
      feedbackReason:
          "The same blinds fold 90% to either size in this read. A 4 BB open costs 2 BB more when one 3-bets.",
    ),
  ],

  table: _day7TableV1(
    hero: 'btn',
    hand: "9s 7s",
    street: PokerStreet.preflop,
    actor: 'btn',

    folded: const {"utg", "hj", "co"},
    stacks: const {
      "utg": 65,
      "hj": 70,
      "co": 62,
      "btn": 45,
      "sb": 48,
      "bb": 50,
    },
    entries: const [..._act0LessonBlinds],
    history: const [
      Act0ActionTrailItemV1(label: "SB blind 0.5 BB"),
      Act0ActionTrailItemV1(label: "BB blind 1 BB"),
      Act0ActionTrailItemV1(label: "UTG folds"),
      Act0ActionTrailItemV1(label: "HJ folds"),
      Act0ActionTrailItemV1(label: "CO folds"),
    ],
    bets: const {
      'sb': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.post,
        label: 'Post',
        amountLabel: '0.5 BB',
      ),
      'bb': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.post,
        label: 'Post',
        amountLabel: '1 BB',
      ),
    },
  ),
);

final _w10LoosePassiveTagRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w10_loose_passive_tag',
  lessonTitle: "Facing a limp",
  lessonSubtitle: 'Player Adjustment',
  caption:
      "HJ limps for 1 BB. In 12 shown hands, HJ called with weak aces and small pairs. HJ rarely 3-bets.",
  hint: '',
  hintPolicy: Act0HintPolicyV1.theoryOnly,
  question: "How should you enter?",
  feedbackTitle: "Facing a limp",
  feedbackReason:
      "AJo is a Medium CO hand. The 4 BB raise puts more chips in against weak aces and pairs that HJ has called before.",
  teachingSteps: const [
    Act0TeachingStepV1(
      title: "Facing a limp",
      body:
          "A limp is a call before the first raise. An isolation raise aims to play a pot with just the limper. Check the limper and seats behind you.",
    ),
  ],
  options: const [
    Act0RunnerOptionV1(
      id: "call_1_bb",
      label: "Call 1 BB",
      isCorrect: false,
      preferredLabel: "Raise to 4 BB",
      betterAnswerLabel: "Raise to 4 BB",
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: "Look again.",
      feedbackReason:
          "AJo can play, but matching the 1 BB limp lets BTN and the blinds join for cheap. You miss value from HJ weak calls.",
    ),
    Act0RunnerOptionV1(
      id: "raise_to_4_bb",
      label: "Raise to 4 BB",
      isCorrect: true,
      preferredLabel: "Raise to 4 BB",

      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: "Correct.",
      feedbackReason:
          "AJo is a Medium CO hand. The 4 BB raise puts more chips in against weak aces and pairs that HJ has called before.",
    ),
    Act0RunnerOptionV1(
      id: "fold",
      label: "Fold",
      isCorrect: false,
      preferredLabel: "Raise to 4 BB",
      betterAnswerLabel: "Raise to 4 BB",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "AJo is a Medium CO hand against a loose caller. Folding gives up a good chance to play for value after the 1 BB limp.",
    ),
  ],

  table: _day7TableV1(
    hero: 'co',
    hand: "Ah Jd",
    street: PokerStreet.preflop,
    actor: 'co',

    folded: const {"utg"},
    stacks: const {
      "utg": 70,
      "hj": 55,
      "co": 45,
      "btn": 50,
      "sb": 45,
      "bb": 60,
    },
    entries: const [
      ..._act0LessonBlinds,
      Act0ContributionV1(
        PokerStreet.preflop,
        'hj',
        Act0ContributionKindV1.wager,
        1,
      ),
    ],
    history: const [
      Act0ActionTrailItemV1(label: "SB blind 0.5 BB"),
      Act0ActionTrailItemV1(label: "BB blind 1 BB"),
      Act0ActionTrailItemV1(label: "UTG folds"),
      Act0ActionTrailItemV1(label: "HJ calls 1 BB"),
    ],
    bets: const {
      'sb': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.post,
        label: 'Post',
        amountLabel: '0.5 BB',
      ),
      'bb': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.post,
        label: 'Post',
        amountLabel: '1 BB',
      ),
      'hj': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.call,
        label: 'Call',
        amountLabel: '1 BB',
      ),
    },
  ),
);

final _w10FindLimperRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w10_find_limper',
  lessonTitle: "Track the first call",
  lessonSubtitle: 'Player Adjustment',
  caption: "",
  hint: '',
  hintPolicy: Act0HintPolicyV1.theoryOnly,
  question: "Tap the seat that limped.",
  feedbackTitle: "Track the first call",
  feedbackReason: "HJ put in 1 BB before a raise. That call is a limp.",
  teachingSteps: const [],
  options: const [
    Act0RunnerOptionV1(
      id: "sb",
      label: "SB",
      isCorrect: false,
      preferredLabel: "HJ",
      betterAnswerLabel: "HJ",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason: "SB posted 0.5 BB as a blind. That post was forced.",
      seatId: "sb",
    ),
    Act0RunnerOptionV1(
      id: "bb",
      label: "BB",
      isCorrect: false,
      preferredLabel: "HJ",
      betterAnswerLabel: "HJ",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "BB posted 1 BB as a blind. That is part of the cost of a hand.",
      seatId: "bb",
    ),
    Act0RunnerOptionV1(
      id: "hj",
      label: "HJ",
      isCorrect: true,
      preferredLabel: "HJ",

      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: "Correct.",
      feedbackReason: "HJ put in 1 BB before a raise. That call is a limp.",
      seatId: "hj",
    ),
  ],

  table: _day7TableV1(
    hero: 'co',
    hand: "As Tc",
    street: PokerStreet.preflop,
    actor: 'co',

    folded: const {"utg"},
    stacks: const {
      "utg": 70,
      "hj": 55,
      "co": 45,
      "btn": 50,
      "sb": 45,
      "bb": 60,
    },
    entries: const [
      ..._act0LessonBlinds,
      Act0ContributionV1(
        PokerStreet.preflop,
        'hj',
        Act0ContributionKindV1.wager,
        1,
      ),
    ],
    history: const [
      Act0ActionTrailItemV1(label: "SB blind 0.5 BB"),
      Act0ActionTrailItemV1(label: "BB blind 1 BB"),
      Act0ActionTrailItemV1(label: "UTG folds"),
      Act0ActionTrailItemV1(label: "HJ calls 1 BB"),
    ],
    bets: const {
      'sb': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.post,
        label: 'Post',
        amountLabel: '0.5 BB',
      ),
      'bb': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.post,
        label: 'Post',
        amountLabel: '1 BB',
      ),
      'hj': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.call,
        label: 'Call',
        amountLabel: '1 BB',
      ),
    },
  ).copyWith(selectableSeatIds: const ["hj", "sb", "bb"]),
);

final _w10UnderbluffSecondRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w10_underbluff_second',
  lessonTitle: "A large river bet",
  lessonSubtitle: 'Player Adjustment',
  caption:
      "BB showed a strong hand on 11 of 12 large river leads. This bet is 92% AQ, AK, two pair or sets. The last 8% is missed KQ.",
  hint: '',
  hintPolicy: Act0HintPolicyV1.theoryOnly,
  question: "Call or fold?",
  feedbackTitle: "A large river bet",
  feedbackReason:
      "The pot is 23.5 and a call costs 12. You need 33.8% wins, but AT beats 8% of this bet mix.",
  teachingSteps: const [],
  options: const [
    Act0RunnerOptionV1(
      id: "fold",
      label: "Fold",
      isCorrect: true,
      preferredLabel: "Fold",

      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: "Correct.",
      feedbackReason:
          "The pot is 23.5 and a call costs 12. You need 33.8% wins, but AT beats 8% of this bet mix.",
    ),
    Act0RunnerOptionV1(
      id: "call_12_bb",
      label: "Call 12 BB",
      isCorrect: false,
      preferredLabel: "Fold",
      betterAnswerLabel: "Fold",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "AT loses to AQ, AK, two pair and sets. With 8% wins, the 12 BB call loses about 9.16 BB.",
    ),
    Act0RunnerOptionV1(
      id: "raise_to_30_bb",
      label: "Raise to 30 BB",
      isCorrect: false,
      preferredLabel: "Fold",
      betterAnswerLabel: "Fold",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "The 92% value range can call a large raise. Betting more with AT builds a pot against hands that beat it.",
    ),
  ],

  table: _day7TableV1(
    hero: 'hj',
    hand: "Ac Tc",
    street: PokerStreet.river,
    actor: 'hj',
    board: _act0LessonCardsV1("As 8d 3c 6h 2s"),

    folded: const {"utg", "co", "btn", "sb"},
    stacks: const {
      "utg": 55,
      "hj": 62,
      "co": 60,
      "btn": 58,
      "sb": 54,
      "bb": 61,
    },
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
      Act0ContributionV1(
        PokerStreet.flop,
        'hj',
        Act0ContributionKindV1.wager,
        3,
      ),
      Act0ContributionV1(
        PokerStreet.flop,
        'bb',
        Act0ContributionKindV1.wager,
        3,
      ),
      Act0ContributionV1(
        PokerStreet.river,
        'bb',
        Act0ContributionKindV1.wager,
        12,
      ),
    ],
    history: const [
      Act0ActionTrailItemV1(label: "SB blind 0.5 BB"),
      Act0ActionTrailItemV1(label: "BB blind 1 BB"),
      Act0ActionTrailItemV1(label: "UTG folds"),
      Act0ActionTrailItemV1(label: "HJ raises to 2.5 BB"),
      Act0ActionTrailItemV1(label: "CO folds"),
      Act0ActionTrailItemV1(label: "BTN folds"),
      Act0ActionTrailItemV1(label: "SB folds"),
      Act0ActionTrailItemV1(label: "BB calls 2.5 BB"),
      Act0ActionTrailItemV1(label: "Flop: BB checks"),
      Act0ActionTrailItemV1(label: "HJ bets 3 BB"),
      Act0ActionTrailItemV1(label: "BB calls 3 BB"),
      Act0ActionTrailItemV1(label: "Turn: BB checks"),
      Act0ActionTrailItemV1(label: "HJ checks"),
      Act0ActionTrailItemV1(label: "River: BB bets 12 BB"),
    ],
    bets: const {
      'bb': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.bet,
        label: 'Bet',
        amountLabel: '12 BB',
      ),
    },
  ),
);

final _w10OveraggressiveTagRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w10_overaggressive_tag',
  lessonTitle: "Read the flop bet",
  lessonSubtitle: 'Player Adjustment',
  caption:
      "BTN has shown five weak hands after big flop bets. If you raise, BTN folds those weak hands and keeps the strongest ones.",
  hint: '',
  hintPolicy: Act0HintPolicyV1.theoryOnly,
  question: "What keeps the weak bets in?",
  feedbackTitle: "Read the flop bet",
  feedbackReason:
      "KJ has top pair and the price is 4/13.5 = 29.6%. The earlier weak bets give you a sound reason to keep bluffs in.",
  teachingSteps: const [
    Act0TeachingStepV1(
      title: "Read the flop bet",
      body:
          "Top pair means your card pairs the top rank on the board. A bet on the flop by the preflop raiser is a c-bet. Check what each action does to that range.",
    ),
  ],
  options: const [
    Act0RunnerOptionV1(
      id: "fold",
      label: "Fold",
      isCorrect: false,
      preferredLabel: "Call 4 BB",
      betterAnswerLabel: "Call 4 BB",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "With KJ on K-8-2, you beat weak BTN bets. Folding for 4 BB gives up this 29.6% price against a player seen betting air.",
    ),
    Act0RunnerOptionV1(
      id: "call_4_bb",
      label: "Call 4 BB",
      isCorrect: true,
      preferredLabel: "Call 4 BB",

      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: "Correct.",
      feedbackReason:
          "KJ has top pair and the price is 4/13.5 = 29.6%. The earlier weak bets give you a sound reason to keep bluffs in.",
    ),
    Act0RunnerOptionV1(
      id: "raise_to_12_bb",
      label: "Raise to 12 BB",
      isCorrect: false,
      preferredLabel: "Call 4 BB",
      betterAnswerLabel: "Call 4 BB",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "KJ can beat bluffs, but a raise to 12 may push those weak hands out. It builds a bigger pot when BTN has a better king or a set.",
    ),
  ],

  table: _day7TableV1(
    hero: 'bb',
    hand: "Kc Jd",
    street: PokerStreet.flop,
    actor: 'bb',
    board: _act0LessonCardsV1("Ks 8c 2d"),

    folded: const {"utg", "hj", "co", "sb"},
    stacks: const {
      "utg": 65,
      "hj": 56,
      "co": 61,
      "btn": 52,
      "sb": 45,
      "bb": 40,
    },
    entries: const [
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
        1.5,
      ),
      Act0ContributionV1(
        PokerStreet.flop,
        'btn',
        Act0ContributionKindV1.wager,
        4,
      ),
    ],
    history: const [
      Act0ActionTrailItemV1(label: "SB blind 0.5 BB"),
      Act0ActionTrailItemV1(label: "BB blind 1 BB"),
      Act0ActionTrailItemV1(label: "UTG folds"),
      Act0ActionTrailItemV1(label: "HJ folds"),
      Act0ActionTrailItemV1(label: "CO folds"),
      Act0ActionTrailItemV1(label: "BTN raises to 2.5 BB"),
      Act0ActionTrailItemV1(label: "SB folds"),
      Act0ActionTrailItemV1(label: "BB calls 2.5 BB"),
      Act0ActionTrailItemV1(label: "Flop: BB checks"),
      Act0ActionTrailItemV1(label: "BTN bets 4 BB"),
    ],
    bets: const {
      'btn': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.bet,
        label: 'Bet',
        amountLabel: '4 BB',
      ),
    },
  ),
);

final _w10PlayerTypeRecapRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w10_player_type_recap',
  lessonTitle: "Keep a useful read",
  lessonSubtitle: 'Player Adjustment',
  caption: "You see a new hand from a player you have watched.",
  hint: '',
  hintPolicy: Act0HintPolicyV1.theoryOnly,
  question: "What keeps a player tag useful?",
  feedbackTitle: "Keep a useful read",
  feedbackReason:
      "Fresh hands can confirm or change the tag. This keeps a costly old read from shaping new pots.",
  teachingSteps: const [],
  options: const [
    Act0RunnerOptionV1(
      id: "treat_the_tag_as_a_fixed_rule",
      label: "Treat the tag as a fixed rule",
      isCorrect: false,
      preferredLabel: "Check it against new hands",
      betterAnswerLabel: "Check it against new hands",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "A nit can get a strong hand. A fixed tag can make you raise into a strong range.",
    ),
    Act0RunnerOptionV1(
      id: "change_several_bet_habits_at_once",
      label: "Change several bet habits at once",
      isCorrect: false,
      preferredLabel: "Check it against new hands",
      betterAnswerLabel: "Check it against new hands",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "Large changes make it hard to see if one read helped, and they can cost chips in the wrong pots.",
    ),
    Act0RunnerOptionV1(
      id: "check_it_against_new_hands",
      label: "Check it against new hands",
      isCorrect: true,
      preferredLabel: "Check it against new hands",

      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: "Correct.",
      feedbackReason:
          "Fresh hands can confirm or change the tag. This keeps a costly old read from shaping new pots.",
    ),
  ],

  table: _w10TextStudyTableV1,
);

final _w10OneLeverIntroRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w10_one_lever_intro',
  lessonTitle: "Pick one change",
  lessonSubtitle: 'Player Adjustment',
  caption: "One change at a time",
  hint: '',
  hintPolicy: Act0HintPolicyV1.theoryOnly,
  question: "A foe calls nine of ten bets. What is the risk?",
  feedbackTitle: "Pick one change",
  feedbackReason:
      "A pure bluff needs folds. Nine calls in ten bets leave few wins without showdown.",
  teachingSteps: const [
    Act0TeachingStepV1(
      title: "Pick one change",
      body:
          "A value bet aims to get a call from a worse hand. A bluff aims to make a better hand fold. Tie the size to your goal and what the player does. An overpair is a pair in your own cards that ranks above the top card on the board.",
    ),
  ],
  options: const [],

  table: _w10TextStudyTableV1,
);

final _w10VsNitOpenWiderRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w10_vs_nit_open_wider',
  lessonTitle: "Three seats behind",
  lessonSubtitle: 'Player Adjustment',
  caption:
      "BTN, SB and BB often fold to late opens. They fold as a group 88% of the time to 2 BB or 5 BB. When one 3-bets, you fold.",
  hint: '',
  hintPolicy: Act0HintPolicyV1.theoryOnly,
  question: "Open or fold?",
  feedbackTitle: "Three seats behind",
  feedbackReason:
      "The three players fold together 88%. Your small steal earns 1.08 BB on average under this read.",
  teachingSteps: const [],
  options: const [
    Act0RunnerOptionV1(
      id: "raise_to_2_bb",
      label: "Raise to 2 BB",
      isCorrect: true,
      preferredLabel: "Raise to 2 BB",

      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: "Correct.",
      feedbackReason:
          "The three players fold together 88%. Your small steal earns 1.08 BB on average under this read.",
    ),
    Act0RunnerOptionV1(
      id: "fold",
      label: "Fold",
      isCorrect: false,
      preferredLabel: "Raise to 2 BB",
      betterAnswerLabel: "Raise to 2 BB",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "J9s is Weak in the base CO chart. Still, folding here passes the 88% chance to take the 1.5 BB pot.",
    ),
    Act0RunnerOptionV1(
      id: "raise_to_5_bb",
      label: "Raise to 5 BB",
      isCorrect: false,
      preferredLabel: "Raise to 2 BB",
      betterAnswerLabel: "Raise to 2 BB",
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: "Look again.",
      feedbackReason:
          "This read gives the same folds to either size. Risking 5 BB instead of 2 BB gives up 3 BB more when someone 3-bets.",
    ),
  ],

  table: _day7TableV1(
    hero: 'co',
    hand: "Js 9s",
    street: PokerStreet.preflop,
    actor: 'co',

    folded: const {"utg", "hj"},
    stacks: const {
      "utg": 55,
      "hj": 65,
      "co": 45,
      "btn": 40,
      "sb": 43,
      "bb": 47,
    },
    entries: const [..._act0LessonBlinds],
    history: const [
      Act0ActionTrailItemV1(label: "SB blind 0.5 BB"),
      Act0ActionTrailItemV1(label: "BB blind 1 BB"),
      Act0ActionTrailItemV1(label: "UTG folds"),
      Act0ActionTrailItemV1(label: "HJ folds"),
    ],
    bets: const {
      'sb': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.post,
        label: 'Post',
        amountLabel: '0.5 BB',
      ),
      'bb': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.post,
        label: 'Post',
        amountLabel: '1 BB',
      ),
    },
  ),
);

final _w10VsCallerValueHeavierRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w10_vs_caller_value_heavier',
  lessonTitle: "Pick a flop size",
  lessonSubtitle: 'Player Adjustment',
  caption:
      "BB calls 2 BB and 3 BB with weak kings and sevens. Past hands show that BB calls 15 BB with strong hands.",
  hint: '',
  hintPolicy: Act0HintPolicyV1.theoryOnly,
  question: "Which size earns most from that read?",
  feedbackTitle: "Pick a flop size",
  feedbackReason:
      "A 3 BB bet can get calls from 7x and weaker kings. That earns more than checking when those hands pay often.",
  teachingSteps: const [],
  options: const [
    Act0RunnerOptionV1(
      id: "bet_2_bb",
      label: "Bet 2 BB",
      isCorrect: false,
      preferredLabel: "Bet 3 BB",
      betterAnswerLabel: "Bet 3 BB",
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: "Look again.",
      feedbackReason:
          "BB calls 2 BB with weak kings and sevens. Your KQ can earn 1 BB more from the same hands.",
    ),
    Act0RunnerOptionV1(
      id: "bet_3_bb",
      label: "Bet 3 BB",
      isCorrect: true,
      preferredLabel: "Bet 3 BB",

      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: "Correct.",
      feedbackReason:
          "A 3 BB bet can get calls from 7x and weaker kings. That earns more than checking when those hands pay often.",
    ),
    Act0RunnerOptionV1(
      id: "bet_15_bb",
      label: "Bet 15 BB",
      isCorrect: false,
      preferredLabel: "Bet 3 BB",
      betterAnswerLabel: "Bet 3 BB",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "If you bet 15 BB, sevens may fold. The stronger hands stay in a large pot.",
    ),
  ],
  sizingConfig: const Act0SizingConfigV1(
    mode: Act0SizingUiModeV1.presetsOnly,
    showGuidance: false,
    presets: [
      Act0SizingPresetV1(
        id: "bet_3_bb",
        label: "Bet 3 BB",
        displayLabel: "3 BB",
        potFraction: 3 / 5.5,
      ),
      Act0SizingPresetV1(
        id: "bet_2_bb",
        label: "Bet 2 BB",
        displayLabel: "2 BB",
        potFraction: 2 / 5.5,
      ),
      Act0SizingPresetV1(
        id: "bet_15_bb",
        label: "Bet 15 BB",
        displayLabel: "15 BB",
        potFraction: 15 / 5.5,
      ),
    ],
  ),
  table: _day7TableV1(
    hero: 'hj',
    hand: "Kc Qd",
    street: PokerStreet.flop,
    actor: 'hj',
    board: _act0LessonCardsV1("Ks 7c 2d"),

    folded: const {"utg", "co", "btn", "sb"},
    stacks: const {
      "utg": 68,
      "hj": 55,
      "co": 61,
      "btn": 48,
      "sb": 52,
      "bb": 60,
    },
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
      Act0ActionTrailItemV1(label: "SB blind 0.5 BB"),
      Act0ActionTrailItemV1(label: "BB blind 1 BB"),
      Act0ActionTrailItemV1(label: "UTG folds"),
      Act0ActionTrailItemV1(label: "HJ raises to 2.5 BB"),
      Act0ActionTrailItemV1(label: "CO folds"),
      Act0ActionTrailItemV1(label: "BTN folds"),
      Act0ActionTrailItemV1(label: "SB folds"),
      Act0ActionTrailItemV1(label: "BB calls 2.5 BB"),
      Act0ActionTrailItemV1(label: "Flop: BB checks"),
    ],
    bets: const {},
  ),
);

final _w10VsStickyDefenderTightenStealsRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w10_vs_sticky_defender_tighten_steals',
  lessonTitle: "Read who calls",
  lessonSubtitle: 'Player Adjustment',
  caption:
      "BTN calls most opens. SB and BB defend a lot too. They call flop bets with weak pairs.",
  hint: '',
  hintPolicy: Act0HintPolicyV1.theoryOnly,
  question: "Open or fold?",
  feedbackTitle: "Read who calls",
  feedbackReason:
      "72o is Weak in the CO chart. Three sticky players behind you make a weak 2 BB steal lose much of its fold value.",
  teachingSteps: const [],
  options: const [
    Act0RunnerOptionV1(
      id: "raise_to_2_bb",
      label: "Raise to 2 BB",
      isCorrect: false,
      preferredLabel: "Fold",
      betterAnswerLabel: "Fold",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "72o has poor ways to win when called. BTN and both blinds defend a lot, so the raise buys fewer blind pots.",
    ),
    Act0RunnerOptionV1(
      id: "raise_to_4_bb",
      label: "Raise to 4 BB",
      isCorrect: false,
      preferredLabel: "Fold",
      betterAnswerLabel: "Fold",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "A 4 BB open risks twice as much as 2 BB with 72o. The sticky players may still call and leave you with a weak hand.",
    ),
    Act0RunnerOptionV1(
      id: "fold",
      label: "Fold",
      isCorrect: true,
      preferredLabel: "Fold",

      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: "Correct.",
      feedbackReason:
          "72o is Weak in the CO chart. Three sticky players behind you make a weak 2 BB steal lose much of its fold value.",
    ),
  ],

  table: _day7TableV1(
    hero: 'co',
    hand: "7c 2d",
    street: PokerStreet.preflop,
    actor: 'co',

    folded: const {"utg", "hj"},
    stacks: const {
      "utg": 65,
      "hj": 65,
      "co": 55,
      "btn": 62,
      "sb": 45,
      "bb": 50,
    },
    entries: const [..._act0LessonBlinds],
    history: const [
      Act0ActionTrailItemV1(label: "SB blind 0.5 BB"),
      Act0ActionTrailItemV1(label: "BB blind 1 BB"),
      Act0ActionTrailItemV1(label: "UTG folds"),
      Act0ActionTrailItemV1(label: "HJ folds"),
    ],
    bets: const {
      'sb': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.post,
        label: 'Post',
        amountLabel: '0.5 BB',
      ),
      'bb': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.post,
        label: 'Post',
        amountLabel: '1 BB',
      ),
    },
  ),
);

final _w10TableValueVsCallerTransferRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w10_table_value_vs_caller_transfer',
  lessonTitle: "Value on the flop",
  lessonSubtitle: 'Player Adjustment',
  caption:
      "BB calls 2 BB and 3 BB with sevens, 88–TT and weak jacks. At 18 BB, BB folds those hands and keeps strong ones.",
  hint: '',
  hintPolicy: Act0HintPolicyV1.theoryOnly,
  question: "Which size earns most from that read?",
  feedbackTitle: "Value on the flop",
  feedbackReason:
      "Bet 3 BB. With AJ, you get more from sevens and weak jacks than at 2 BB. If the calls, folds or raises with each hand change, the best size can change too.",
  teachingSteps: const [],
  options: const [
    Act0RunnerOptionV1(
      id: "bet_3_bb",
      label: "Bet 3 BB",
      isCorrect: true,
      preferredLabel: "Bet 3 BB",

      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: "Correct.",
      feedbackReason:
          "Bet 3 BB. With AJ, you get more from sevens and weak jacks than at 2 BB. If the calls, folds or raises with each hand change, the best size can change too.",
    ),
    Act0RunnerOptionV1(
      id: "bet_2_bb",
      label: "Bet 2 BB",
      isCorrect: false,
      preferredLabel: "Bet 3 BB",
      betterAnswerLabel: "Bet 3 BB",
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: "Look again.",
      feedbackReason:
          "BB still calls with weak jacks and 88–TT. With AJ, 3 BB earns one more chip per call than 2 BB.",
    ),
    Act0RunnerOptionV1(
      id: "bet_18_bb",
      label: "Bet 18 BB",
      isCorrect: false,
      preferredLabel: "Bet 3 BB",
      betterAnswerLabel: "Bet 3 BB",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "If you bet 18 BB, sevens and small pairs fold in this read. That builds a large pot with the hands that can beat AJ.",
    ),
  ],
  sizingConfig: const Act0SizingConfigV1(
    mode: Act0SizingUiModeV1.presetsOnly,
    showGuidance: false,
    presets: [
      Act0SizingPresetV1(
        id: "bet_3_bb",
        label: "Bet 3 BB",
        displayLabel: "3 BB",
        potFraction: 3 / 5.5,
      ),
      Act0SizingPresetV1(
        id: "bet_2_bb",
        label: "Bet 2 BB",
        displayLabel: "2 BB",
        potFraction: 2 / 5.5,
      ),
      Act0SizingPresetV1(
        id: "bet_18_bb",
        label: "Bet 18 BB",
        displayLabel: "18 BB",
        potFraction: 18 / 5.5,
      ),
    ],
  ),
  table: _day7TableV1(
    hero: 'co',
    hand: "Ad Jc",
    street: PokerStreet.flop,
    actor: 'co',
    board: _act0LessonCardsV1("Js 7h 2d"),

    folded: const {"utg", "hj", "btn", "sb"},
    stacks: const {
      "utg": 72,
      "hj": 58,
      "co": 60,
      "btn": 63,
      "sb": 55,
      "bb": 61,
    },
    entries: const [
      ..._act0LessonBlinds,
      Act0ContributionV1(
        PokerStreet.preflop,
        'co',
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
      Act0ActionTrailItemV1(label: "SB blind 0.5 BB"),
      Act0ActionTrailItemV1(label: "BB blind 1 BB"),
      Act0ActionTrailItemV1(label: "UTG folds"),
      Act0ActionTrailItemV1(label: "HJ folds"),
      Act0ActionTrailItemV1(label: "CO raises to 2.5 BB"),
      Act0ActionTrailItemV1(label: "BTN folds"),
      Act0ActionTrailItemV1(label: "SB folds"),
      Act0ActionTrailItemV1(label: "BB calls 2.5 BB"),
      Act0ActionTrailItemV1(label: "Flop: BB checks"),
    ],
    bets: const {},
  ),
);

final _w10IsolateLimperBbRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w10_isolate_limper_bb',
  lessonTitle: "Raise from BB",
  lessonSubtitle: 'Player Adjustment',
  caption:
      "SB limps. In ten past hands, SB called raises with weak aces and kings. Those hands call 4 BB and fold to 15 BB.",
  hint: '',
  hintPolicy: Act0HintPolicyV1.theoryOnly,
  question: "Check or raise?",
  feedbackTitle: "Raise from BB",
  feedbackReason:
      "ATs is ahead of many weak aces and kings that SB calls with. Raising can win more when SB calls.",
  teachingSteps: const [
    Act0TeachingStepV1(
      title: "Raise from BB",
      body:
          "In BB, you can check after a limp. A raise changes the pot and which hands stay in.",
    ),
  ],
  options: const [
    Act0RunnerOptionV1(
      id: "check",
      label: "Check",
      isCorrect: false,
      preferredLabel: "Raise to 4 BB",
      betterAnswerLabel: "Raise to 4 BB",
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: "Look again.",
      feedbackReason:
          "Checking costs nothing and sees a flop. It misses value against the weak hands SB has limp-called with.",
    ),
    Act0RunnerOptionV1(
      id: "raise_to_4_bb",
      label: "Raise to 4 BB",
      isCorrect: true,
      preferredLabel: "Raise to 4 BB",

      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: "Correct.",
      feedbackReason:
          "ATs is ahead of many weak aces and kings that SB calls with. Raising can win more when SB calls.",
    ),
    Act0RunnerOptionV1(
      id: "raise_to_15_bb",
      label: "Raise to 15 BB",
      isCorrect: false,
      preferredLabel: "Raise to 4 BB",
      betterAnswerLabel: "Raise to 4 BB",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "The pot is just 2 BB. A 15 BB raise risks too much when SB can still have a strong hand.",
    ),
  ],

  table: _day7TableV1(
    hero: 'bb',
    hand: "Ac Tc",
    street: PokerStreet.preflop,
    actor: 'bb',

    folded: const {"utg", "hj", "co", "btn"},
    stacks: const {
      "utg": 62,
      "hj": 59,
      "co": 66,
      "btn": 58,
      "sb": 50,
      "bb": 54,
    },
    entries: const [
      ..._act0LessonBlinds,
      Act0ContributionV1(
        PokerStreet.preflop,
        'sb',
        Act0ContributionKindV1.wager,
        0.5,
      ),
    ],
    history: const [
      Act0ActionTrailItemV1(label: "SB blind 0.5 BB"),
      Act0ActionTrailItemV1(label: "BB blind 1 BB"),
      Act0ActionTrailItemV1(label: "UTG folds"),
      Act0ActionTrailItemV1(label: "HJ folds"),
      Act0ActionTrailItemV1(label: "CO folds"),
      Act0ActionTrailItemV1(label: "BTN folds"),
      Act0ActionTrailItemV1(label: "SB calls 1 BB"),
    ],
    bets: const {
      'sb': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.call,
        label: 'Call',
        amountLabel: '1 BB',
      ),
      'bb': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.post,
        label: 'Post',
        amountLabel: '1 BB',
      ),
    },
  ),
);

final _w10StationNoBluffRiverARunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w10_station_no_bluff_river_a',
  lessonTitle: "Ace-high on the river",
  lessonSubtitle: 'Player Adjustment',
  caption:
      "BB is a calling station. BB holds a pair 90% of the time and calls with it. The other 10% is a missed hand that you beat and that folds.",
  hint: '',
  hintPolicy: Act0HintPolicyV1.theoryOnly,
  question: "Bluff or check?",
  feedbackTitle: "Ace-high on the river",
  feedbackReason:
      "BB folds just 10%. A 3 BB bluff needs 22.2% folds with no win at showdown. Your ace-high can beat the weak missed cards by checking.",
  teachingSteps: const [],
  options: const [
    Act0RunnerOptionV1(
      id: "bet_3_bb",
      label: "Bet 3 BB",
      isCorrect: false,
      preferredLabel: "Check",
      betterAnswerLabel: "Check",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "BB calls with a pair 90%. The 3 BB bluff loses 1.65 BB on its fold-only line, while a check can beat the weak missed cards.",
    ),
    Act0RunnerOptionV1(
      id: "bet_5_bb",
      label: "Bet 5 BB",
      isCorrect: false,
      preferredLabel: "Check",
      betterAnswerLabel: "Check",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "The pot is 10.5 and BB still calls 90%. A 5 BB bluff risks more and loses 3.45 BB on its fold-only line.",
    ),
    Act0RunnerOptionV1(
      id: "check",
      label: "Check",
      isCorrect: true,
      preferredLabel: "Check",

      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: "Correct.",
      feedbackReason:
          "BB folds just 10%. A 3 BB bluff needs 22.2% folds with no win at showdown. Your ace-high can beat the weak missed cards by checking.",
    ),
  ],

  table: _day7TableV1(
    hero: 'co',
    hand: "Ah Qh",
    street: PokerStreet.river,
    actor: 'co',
    board: _act0LessonCardsV1("Kd 8c 3s 6d 2c"),

    folded: const {"utg", "hj", "btn", "sb"},
    stacks: const {
      "utg": 58,
      "hj": 65,
      "co": 57,
      "btn": 62,
      "sb": 54,
      "bb": 59,
    },
    entries: const [
      ..._act0LessonBlinds,
      Act0ContributionV1(
        PokerStreet.preflop,
        'co',
        Act0ContributionKindV1.wager,
        2.5,
      ),
      Act0ContributionV1(
        PokerStreet.preflop,
        'bb',
        Act0ContributionKindV1.wager,
        1.5,
      ),
      Act0ContributionV1(
        PokerStreet.flop,
        'co',
        Act0ContributionKindV1.wager,
        2.5,
      ),
      Act0ContributionV1(
        PokerStreet.flop,
        'bb',
        Act0ContributionKindV1.wager,
        2.5,
      ),
    ],
    history: const [
      Act0ActionTrailItemV1(label: "SB blind 0.5 BB"),
      Act0ActionTrailItemV1(label: "BB blind 1 BB"),
      Act0ActionTrailItemV1(label: "UTG folds"),
      Act0ActionTrailItemV1(label: "HJ folds"),
      Act0ActionTrailItemV1(label: "CO raises to 2.5 BB"),
      Act0ActionTrailItemV1(label: "BTN folds"),
      Act0ActionTrailItemV1(label: "SB folds"),
      Act0ActionTrailItemV1(label: "BB calls 2.5 BB"),
      Act0ActionTrailItemV1(label: "Flop: BB checks"),
      Act0ActionTrailItemV1(label: "CO bets 2.5 BB"),
      Act0ActionTrailItemV1(label: "BB calls 2.5 BB"),
      Act0ActionTrailItemV1(label: "Turn: BB checks"),
      Act0ActionTrailItemV1(label: "CO checks"),
      Act0ActionTrailItemV1(label: "River: BB checks"),
    ],
    bets: const {},
  ),
);

final _w10OneLeverRecapRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w10_one_lever_recap',
  lessonTitle: "Pick a bet plan",
  lessonSubtitle: 'Player Adjustment',
  caption: "Think back to the pots in this lesson.",
  hint: '',
  hintPolicy: Act0HintPolicyV1.theoryOnly,
  question: "What should set the bet plan?",
  feedbackTitle: "Pick a bet plan",
  feedbackReason:
      "Those facts show what the bet may gain and what it may cost.",
  teachingSteps: const [],
  options: const [
    Act0RunnerOptionV1(
      id: "the_hand_pot_and_player_read",
      label: "The hand, pot and player read",
      isCorrect: true,
      preferredLabel: "The hand, pot and player read",

      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: "Correct.",
      feedbackReason:
          "Those facts show what the bet may gain and what it may cost.",
    ),
    Act0RunnerOptionV1(
      id: "the_same_size_for_each_player",
      label: "The same size for each player",
      isCorrect: false,
      preferredLabel: "The hand, pot and player read",
      betterAnswerLabel: "The hand, pot and player read",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "A weak 72o steal against sticky blinds has less fold value than a J9s steal against tight blinds.",
    ),
    Act0RunnerOptionV1(
      id: "a_big_bet_to_look_strong",
      label: "A big bet to look strong",
      isCorrect: false,
      preferredLabel: "The hand, pot and player read",
      betterAnswerLabel: "The hand, pot and player read",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "A large bet can pay too much when called. The 15 BB bet on K-7-2 may lose calls from weak pairs.",
    ),
  ],

  table: _w10TextStudyTableV1,
);

final _w10ExploitGuardrailsIntroRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w10_guardrails_intro',
  lessonTitle: "Check the read",
  lessonSubtitle: 'Player Adjustment',
  caption: "A call has a price.",
  hint: '',
  hintPolicy: Act0HintPolicyV1.theoryOnly,
  question: "A river call is 5 into 10. What is its price?",
  feedbackTitle: "Check the read",
  feedbackReason: "Call 5 into a 10 BB pot now. Final pot 15 BB: 5/15 = 33.3%.",
  teachingSteps: const [
    Act0TeachingStepV1(
      title: "Check the read",
      body:
          "A bluff-catcher beats bluffs. A blocker is a card you hold that rules out some hands. Divide the call by the pot after your call. Use the range and check the sample size.",
    ),
  ],
  options: const [],

  table: _w10TextStudyTableV1,
);

final _w10OverbluffPunishRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w10_overbluff_punish',
  lessonTitle: "Facing a river bet",
  lessonSubtitle: 'Player Adjustment',
  caption:
      "The SB open with QJo was already played. On this river, BB bets missed JT or T9 55% and AQ or KQ 45%. No ties.",
  hint: '',
  hintPolicy: Act0HintPolicyV1.theoryOnly,
  question: "Call or fold?",
  feedbackTitle: "Facing a river bet",
  feedbackReason:
      "QJ beats the missed draws 55% of the time. A call costs 10 into a final pot of 34.5, so it needs 29.0% wins.",
  teachingSteps: const [],
  options: const [
    Act0RunnerOptionV1(
      id: "fold",
      label: "Fold",
      isCorrect: false,
      preferredLabel: "Call 10 BB",
      betterAnswerLabel: "Call 10 BB",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "Your QJ beats 55% missed draws in the set range. Folding gives up a call worth 8.98 BB on average at this price.",
    ),
    Act0RunnerOptionV1(
      id: "call_10_bb",
      label: "Call 10 BB",
      isCorrect: true,
      preferredLabel: "Call 10 BB",

      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: "Correct.",
      feedbackReason:
          "QJ beats the missed draws 55% of the time. A call costs 10 into a final pot of 34.5, so it needs 29.0% wins.",
    ),
    Act0RunnerOptionV1(
      id: "raise_to_25_bb",
      label: "Raise to 25 BB",
      isCorrect: false,
      preferredLabel: "Call 10 BB",
      betterAnswerLabel: "Call 10 BB",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "QJ beats the missed bluffs but loses to AQ and KQ. Raising may fold the bluffs and get calls from better queens.",
    ),
  ],

  table: _day7TableV1(
    hero: 'sb',
    hand: "Qh Jd",
    street: PokerStreet.river,
    actor: 'sb',
    board: _act0LessonCardsV1("Qd 8c 5s 2h 3c"),

    folded: const {"utg", "hj", "co", "btn"},
    stacks: const {
      "utg": 65,
      "hj": 67,
      "co": 55,
      "btn": 50,
      "sb": 45,
      "bb": 52,
    },
    entries: const [
      ..._act0LessonBlinds,
      Act0ContributionV1(
        PokerStreet.preflop,
        'sb',
        Act0ContributionKindV1.wager,
        2,
      ),
      Act0ContributionV1(
        PokerStreet.preflop,
        'bb',
        Act0ContributionKindV1.wager,
        1.5,
      ),
      Act0ContributionV1(
        PokerStreet.flop,
        'bb',
        Act0ContributionKindV1.wager,
        3,
      ),
      Act0ContributionV1(
        PokerStreet.flop,
        'sb',
        Act0ContributionKindV1.wager,
        3,
      ),
      Act0ContributionV1(
        PokerStreet.turn,
        'bb',
        Act0ContributionKindV1.wager,
        1.75,
      ),
      Act0ContributionV1(
        PokerStreet.turn,
        'sb',
        Act0ContributionKindV1.wager,
        1.75,
      ),
      Act0ContributionV1(
        PokerStreet.river,
        'bb',
        Act0ContributionKindV1.wager,
        10,
      ),
    ],
    history: const [
      Act0ActionTrailItemV1(label: "SB blind 0.5 BB"),
      Act0ActionTrailItemV1(label: "BB blind 1 BB"),
      Act0ActionTrailItemV1(label: "UTG folds"),
      Act0ActionTrailItemV1(label: "HJ folds"),
      Act0ActionTrailItemV1(label: "CO folds"),
      Act0ActionTrailItemV1(label: "BTN folds"),
      Act0ActionTrailItemV1(label: "SB raises to 2.5 BB"),
      Act0ActionTrailItemV1(label: "BB calls 2.5 BB"),
      Act0ActionTrailItemV1(label: "Flop: SB checks"),
      Act0ActionTrailItemV1(label: "BB bets 3 BB"),
      Act0ActionTrailItemV1(label: "SB calls 3 BB"),
      Act0ActionTrailItemV1(label: "Turn: SB checks"),
      Act0ActionTrailItemV1(label: "BB bets 1.75 BB"),
      Act0ActionTrailItemV1(label: "SB calls 1.75 BB"),
      Act0ActionTrailItemV1(label: "River: SB checks"),
      Act0ActionTrailItemV1(label: "BB bets 10 BB"),
    ],
    bets: const {
      'bb': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.bet,
        label: 'Bet',
        amountLabel: '10 BB',
      ),
    },
  ),
);

final _w10UnderbluffFoldMoreRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w10_underbluff_fold_more',
  lessonTitle: "River range",
  lessonSubtitle: 'Player Adjustment',
  caption:
      "BTN bets 10 BB into 11.5 BB. Use 90% AK, K9 or sets and 10% missed QJ. No ties.",
  hint: '',
  hintPolicy: Act0HintPolicyV1.theoryOnly,
  question: "Call or fold?",
  feedbackTitle: "River range",
  feedbackReason:
      "KQ beats the missed QJ but loses to the 90% value group. The call needs 31.7% wins, far above 10%.",
  teachingSteps: const [],
  options: const [
    Act0RunnerOptionV1(
      id: "call_10_bb",
      label: "Call 10 BB",
      isCorrect: false,
      preferredLabel: "Fold",
      betterAnswerLabel: "Fold",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "KQ is top pair but has just 10% wins against this bet mix. A 10 BB call loses 6.85 BB on average.",
    ),
    Act0RunnerOptionV1(
      id: "raise_to_26_bb",
      label: "Raise to 26 BB",
      isCorrect: false,
      preferredLabel: "Fold",
      betterAnswerLabel: "Fold",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "A raise risks more chips against AK, K9 and sets. Those strong hands form 90% of BTN bets here.",
    ),
    Act0RunnerOptionV1(
      id: "fold",
      label: "Fold",
      isCorrect: true,
      preferredLabel: "Fold",

      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: "Correct.",
      feedbackReason:
          "KQ beats the missed QJ but loses to the 90% value group. The call needs 31.7% wins, far above 10%.",
    ),
  ],

  table: _day7TableV1(
    hero: 'bb',
    hand: "Kd Qc",
    street: PokerStreet.river,
    actor: 'bb',
    board: _act0LessonCardsV1("Kc 7d 4h 2s 9d"),

    folded: const {"utg", "hj", "co", "sb"},
    stacks: const {
      "utg": 62,
      "hj": 70,
      "co": 67,
      "btn": 60,
      "sb": 50,
      "bb": 55,
    },
    entries: const [
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
        1.5,
      ),
      Act0ContributionV1(
        PokerStreet.flop,
        'btn',
        Act0ContributionKindV1.wager,
        3,
      ),
      Act0ContributionV1(
        PokerStreet.flop,
        'bb',
        Act0ContributionKindV1.wager,
        3,
      ),
      Act0ContributionV1(
        PokerStreet.river,
        'btn',
        Act0ContributionKindV1.wager,
        10,
      ),
    ],
    history: const [
      Act0ActionTrailItemV1(label: "SB blind 0.5 BB"),
      Act0ActionTrailItemV1(label: "BB blind 1 BB"),
      Act0ActionTrailItemV1(label: "UTG folds"),
      Act0ActionTrailItemV1(label: "HJ folds"),
      Act0ActionTrailItemV1(label: "CO folds"),
      Act0ActionTrailItemV1(label: "BTN raises to 2.5 BB"),
      Act0ActionTrailItemV1(label: "SB folds"),
      Act0ActionTrailItemV1(label: "BB calls 2.5 BB"),
      Act0ActionTrailItemV1(label: "Flop: BB checks"),
      Act0ActionTrailItemV1(label: "BTN bets 3 BB"),
      Act0ActionTrailItemV1(label: "BB calls 3 BB"),
      Act0ActionTrailItemV1(label: "Turn: BB checks"),
      Act0ActionTrailItemV1(label: "BTN checks"),
      Act0ActionTrailItemV1(label: "River: BB checks"),
      Act0ActionTrailItemV1(label: "BTN bets 10 BB"),
    ],
    bets: const {
      'btn': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.bet,
        label: 'Bet',
        amountLabel: '10 BB',
      ),
    },
  ),
);

final _w10GuardrailSampleSizeRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w10_guardrail_sample_size',
  lessonTitle: "One shown bluff",
  lessonSubtitle: 'Player Adjustment',
  caption: "BB showed one bluff last lap. Use the course’s first-in plan.",
  hint: '',
  hintPolicy: Act0HintPolicyV1.theoryOnly,
  question: "What size fits the read?",
  feedbackTitle: "One shown bluff",
  feedbackReason:
      "AQs is Strong from HJ. The one BB bluff does not call for a new size or a loose stack-off plan.",
  teachingSteps: const [],
  options: const [
    Act0RunnerOptionV1(
      id: "raise_to_2_bb",
      label: "Raise to 2 BB",
      isCorrect: true,
      preferredLabel: "Raise to 2 BB",

      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: "Correct.",
      feedbackReason:
          "AQs is Strong from HJ. The one BB bluff does not call for a new size or a loose stack-off plan.",
    ),
    Act0RunnerOptionV1(
      id: "raise_to_3_bb",
      label: "Raise to 3 BB",
      isCorrect: false,
      preferredLabel: "Raise to 2 BB",
      betterAnswerLabel: "Raise to 2 BB",
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: "Look again.",
      feedbackReason:
          "AQs can open, but the one wild bluff gives no sound reason to spend 1 BB more before the flop.",
    ),
    Act0RunnerOptionV1(
      id: "all_in_to_52_bb",
      label: "All-in to 52 BB",
      isCorrect: false,
      preferredLabel: "Raise to 2 BB",
      betterAnswerLabel: "Raise to 2 BB",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "AQs is strong, but going all-in with 52 BB to win a 1.5 BB pot gives strong hands a big chance to win your stack.",
    ),
  ],
  sizingConfig: const Act0SizingConfigV1(
    mode: Act0SizingUiModeV1.presetsOnly,
    showGuidance: false,
    presets: [
      Act0SizingPresetV1(
        id: "raise_to_2_bb",
        label: "Raise to 2 BB",
        displayLabel: "2 BB",
        potFraction: 2 / 1.5,
      ),
      Act0SizingPresetV1(
        id: "raise_to_3_bb",
        label: "Raise to 3 BB",
        displayLabel: "3 BB",
        potFraction: 3 / 1.5,
      ),
      Act0SizingPresetV1(
        id: "all_in_to_52_bb",
        label: "All-in to 52 BB",
        displayLabel: "52 BB",
        potFraction: 52 / 1.5,
      ),
    ],
  ),
  table: _day7TableV1(
    hero: 'hj',
    hand: "As Qs",
    street: PokerStreet.preflop,
    actor: 'hj',

    folded: const {"utg"},
    stacks: const {
      "utg": 54,
      "hj": 52,
      "co": 61,
      "btn": 66,
      "sb": 48,
      "bb": 57,
    },
    entries: const [..._act0LessonBlinds],
    history: const [
      Act0ActionTrailItemV1(label: "SB blind 0.5 BB"),
      Act0ActionTrailItemV1(label: "BB blind 1 BB"),
      Act0ActionTrailItemV1(label: "UTG folds"),
    ],
    bets: const {
      'sb': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.post,
        label: 'Post',
        amountLabel: '0.5 BB',
      ),
      'bb': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.post,
        label: 'Post',
        amountLabel: '1 BB',
      ),
    },
  ),
);

final _w10TopPairTurnRaiseRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w10_top_pair_turn_raise',
  lessonTitle: "The turn raise",
  lessonSubtitle: 'Player Adjustment',
  caption:
      "Loose-passive BB showed two pair or a set on six turn raises. Use that range here.",
  hint: '',
  hintPolicy: Act0HintPolicyV1.theoryOnly,
  question: "Call or fold?",
  feedbackTitle: "The turn raise",
  feedbackReason:
      "You need 15/50.5 = 29.7% equity to call. AJ is behind the sets and two pair seen in BB turn raises.",
  teachingSteps: const [
    Act0TeachingStepV1(
      title: "The turn raise",
      body:
          "A turn raise can be much stronger than a call. Check what this player has shown.",
    ),
  ],
  options: const [
    Act0RunnerOptionV1(
      id: "call_15_bb",
      label: "Call 15 BB",
      isCorrect: false,
      preferredLabel: "Fold",
      betterAnswerLabel: "Fold",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "AJ is top pair, not a set. Calling 15 BB against this strong turn raise risks more chips with few winning river cards.",
    ),
    Act0RunnerOptionV1(
      id: "fold",
      label: "Fold",
      isCorrect: true,
      preferredLabel: "Fold",

      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: "Correct.",
      feedbackReason:
          "You need 15/50.5 = 29.7% equity to call. AJ is behind the sets and two pair seen in BB turn raises.",
    ),
    Act0RunnerOptionV1(
      id: "all_in_to_55_bb",
      label: "All-in to 55 BB",
      isCorrect: false,
      preferredLabel: "Fold",
      betterAnswerLabel: "Fold",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "BB rarely raises worse hands. Going all-in with AJ commits the rest of your stack against better hands.",
    ),
  ],

  table: _day7TableV1(
    hero: 'co',
    hand: "Ac Jc",
    street: PokerStreet.turn,
    actor: 'co',
    board: _act0LessonCardsV1("Js 8d 4h 2c"),

    folded: const {"utg", "hj", "btn", "sb"},
    stacks: const {
      "utg": 65,
      "hj": 68,
      "co": 60,
      "btn": 59,
      "sb": 55,
      "bb": 54,
    },
    entries: const [
      ..._act0LessonBlinds,
      Act0ContributionV1(
        PokerStreet.preflop,
        'co',
        Act0ContributionKindV1.wager,
        2.5,
      ),
      Act0ContributionV1(
        PokerStreet.preflop,
        'bb',
        Act0ContributionKindV1.wager,
        1.5,
      ),
      Act0ContributionV1(
        PokerStreet.flop,
        'co',
        Act0ContributionKindV1.wager,
        2.5,
      ),
      Act0ContributionV1(
        PokerStreet.flop,
        'bb',
        Act0ContributionKindV1.wager,
        2.5,
      ),
      Act0ContributionV1(
        PokerStreet.turn,
        'co',
        Act0ContributionKindV1.wager,
        5,
      ),
      Act0ContributionV1(
        PokerStreet.turn,
        'bb',
        Act0ContributionKindV1.wager,
        20,
      ),
    ],
    history: const [
      Act0ActionTrailItemV1(label: "SB blind 0.5 BB"),
      Act0ActionTrailItemV1(label: "BB blind 1 BB"),
      Act0ActionTrailItemV1(label: "UTG folds"),
      Act0ActionTrailItemV1(label: "HJ folds"),
      Act0ActionTrailItemV1(label: "CO raises to 2.5 BB"),
      Act0ActionTrailItemV1(label: "BTN folds"),
      Act0ActionTrailItemV1(label: "SB folds"),
      Act0ActionTrailItemV1(label: "BB calls 2.5 BB"),
      Act0ActionTrailItemV1(label: "Flop: BB checks"),
      Act0ActionTrailItemV1(label: "CO bets 2.5 BB"),
      Act0ActionTrailItemV1(label: "BB calls 2.5 BB"),
      Act0ActionTrailItemV1(label: "Turn: BB checks"),
      Act0ActionTrailItemV1(label: "CO bets 5 BB"),
      Act0ActionTrailItemV1(label: "Turn: BB raises to 20 BB"),
    ],
    bets: const {
      'co': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.bet,
        label: 'Bet',
        amountLabel: '5 BB',
      ),
      'bb': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.raise,
        label: 'Raise',
        amountLabel: '20 BB',
      ),
    },
  ),
);

final _w10FindTurnRaiserRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w10_find_turn_raiser',
  lessonTitle: "Find the turn raise",
  lessonSubtitle: 'Player Adjustment',
  caption: "",
  hint: '',
  hintPolicy: Act0HintPolicyV1.theoryOnly,
  question: "Tap the seat that raised the turn.",
  feedbackTitle: "Find the turn raise",
  feedbackReason: "BB raised to 20 BB after the 5 BB turn bet.",
  teachingSteps: const [],
  options: const [
    Act0RunnerOptionV1(
      id: "co",
      label: "CO",
      isCorrect: false,
      preferredLabel: "BB",
      betterAnswerLabel: "BB",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason: "CO made the first turn bet of 5 BB. BB made the raise.",
      seatId: "co",
    ),
    Act0RunnerOptionV1(
      id: "btn",
      label: "BTN",
      isCorrect: false,
      preferredLabel: "BB",
      betterAnswerLabel: "BB",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "BTN folded before the flop and put no chips in on the turn.",
      seatId: "btn",
    ),
    Act0RunnerOptionV1(
      id: "bb",
      label: "BB",
      isCorrect: true,
      preferredLabel: "BB",

      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: "Correct.",
      feedbackReason: "BB raised to 20 BB after the 5 BB turn bet.",
      seatId: "bb",
    ),
  ],

  table: _day7TableV1(
    hero: 'co',
    hand: "Ad Jd",
    street: PokerStreet.turn,
    actor: 'co',
    board: _act0LessonCardsV1("Jh 8c 4s 2d"),

    folded: const {"utg", "hj", "btn", "sb"},
    stacks: const {
      "utg": 65,
      "hj": 68,
      "co": 60,
      "btn": 59,
      "sb": 55,
      "bb": 54,
    },
    entries: const [
      ..._act0LessonBlinds,
      Act0ContributionV1(
        PokerStreet.preflop,
        'co',
        Act0ContributionKindV1.wager,
        2.5,
      ),
      Act0ContributionV1(
        PokerStreet.preflop,
        'bb',
        Act0ContributionKindV1.wager,
        1.5,
      ),
      Act0ContributionV1(
        PokerStreet.flop,
        'co',
        Act0ContributionKindV1.wager,
        2.5,
      ),
      Act0ContributionV1(
        PokerStreet.flop,
        'bb',
        Act0ContributionKindV1.wager,
        2.5,
      ),
      Act0ContributionV1(
        PokerStreet.turn,
        'co',
        Act0ContributionKindV1.wager,
        5,
      ),
      Act0ContributionV1(
        PokerStreet.turn,
        'bb',
        Act0ContributionKindV1.wager,
        20,
      ),
    ],
    history: const [
      Act0ActionTrailItemV1(label: "SB blind 0.5 BB"),
      Act0ActionTrailItemV1(label: "BB blind 1 BB"),
      Act0ActionTrailItemV1(label: "UTG folds"),
      Act0ActionTrailItemV1(label: "HJ folds"),
      Act0ActionTrailItemV1(label: "CO raises to 2.5 BB"),
      Act0ActionTrailItemV1(label: "BTN folds"),
      Act0ActionTrailItemV1(label: "SB folds"),
      Act0ActionTrailItemV1(label: "BB calls 2.5 BB"),
      Act0ActionTrailItemV1(label: "Flop: BB checks"),
      Act0ActionTrailItemV1(label: "CO bets 2.5 BB"),
      Act0ActionTrailItemV1(label: "BB calls 2.5 BB"),
      Act0ActionTrailItemV1(label: "Turn: BB checks"),
      Act0ActionTrailItemV1(label: "CO bets 5 BB"),
      Act0ActionTrailItemV1(label: "Turn: BB raises to 20 BB"),
    ],
    bets: const {
      'co': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.bet,
        label: 'Bet',
        amountLabel: '5 BB',
      ),
      'bb': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.raise,
        label: 'Raise',
        amountLabel: '20 BB',
      ),
    },
  ).copyWith(selectableSeatIds: const ["bb", "co", "btn"]),
);

final _w10StationNoBluffRiverRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w10_station_no_bluff_river',
  lessonTitle: "River choice",
  lessonSubtitle: 'Player Adjustment',
  caption:
      "CO is a calling station. The 80% with a pair call either size. The rest lose to your hand and fold.",
  hint: '',
  hintPolicy: Act0HintPolicyV1.theoryOnly,
  question: "Bluff or check?",
  feedbackTitle: "River choice",
  feedbackReason:
      "An 8 BB bluff into 10.5 needs 43.2% folds. CO folds 20%, so it costs chips.",
  teachingSteps: const [],
  options: const [
    Act0RunnerOptionV1(
      id: "check",
      label: "Check",
      isCorrect: true,
      preferredLabel: "Check",

      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: "Correct.",
      feedbackReason:
          "An 8 BB bluff into 10.5 needs 43.2% folds. CO folds 20%, so it costs chips.",
    ),
    Act0RunnerOptionV1(
      id: "bet_8_bb",
      label: "Bet 8 BB",
      isCorrect: false,
      preferredLabel: "Check",
      betterAnswerLabel: "Check",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "CO has a pair and calls 80% here. The pure 8 BB bluff loses 4.30 BB on average.",
    ),
    Act0RunnerOptionV1(
      id: "bet_4_bb",
      label: "Bet 4 BB",
      isCorrect: false,
      preferredLabel: "Check",
      betterAnswerLabel: "Check",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "The smaller bet risks less, but it still has just 20% folds. Its pure bluff EV is -1.10 BB.",
    ),
  ],

  table: _day7TableV1(
    hero: 'hj',
    hand: "Kc Qc",
    street: PokerStreet.river,
    actor: 'hj',
    board: _act0LessonCardsV1("As 9c 4d 2h 6s"),

    folded: const {"utg", "btn", "sb", "bb"},
    stacks: const {
      "utg": 55,
      "hj": 56,
      "co": 64,
      "btn": 62,
      "sb": 59,
      "bb": 60,
    },
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
        'co',
        Act0ContributionKindV1.wager,
        2.5,
      ),
      Act0ContributionV1(
        PokerStreet.flop,
        'hj',
        Act0ContributionKindV1.wager,
        2,
      ),
      Act0ContributionV1(
        PokerStreet.flop,
        'co',
        Act0ContributionKindV1.wager,
        2,
      ),
    ],
    history: const [
      Act0ActionTrailItemV1(label: "SB blind 0.5 BB"),
      Act0ActionTrailItemV1(label: "BB blind 1 BB"),
      Act0ActionTrailItemV1(label: "UTG folds"),
      Act0ActionTrailItemV1(label: "HJ raises to 2.5 BB"),
      Act0ActionTrailItemV1(label: "CO calls 2.5 BB"),
      Act0ActionTrailItemV1(label: "BTN folds"),
      Act0ActionTrailItemV1(label: "SB folds"),
      Act0ActionTrailItemV1(label: "BB folds"),
      Act0ActionTrailItemV1(label: "Flop: HJ bets 2 BB"),
      Act0ActionTrailItemV1(label: "CO calls 2 BB"),
      Act0ActionTrailItemV1(label: "Turn: HJ checks"),
      Act0ActionTrailItemV1(label: "CO checks"),
    ],
    bets: const {},
  ),
);

final _w10OutsAndTurnPriceRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w10_outs_and_turn_price',
  lessonTitle: "A draw and a price",
  lessonSubtitle: 'Player Adjustment',
  caption: "BTN shows 9c and 9d. No bets follow a call. BTN calls a raise.",
  hint: '',
  hintPolicy: Act0HintPolicyV1.theoryOnly,
  question: "Which call read fits?",
  feedbackTitle: "A draw and a price",
  feedbackReason:
      "A heart that pairs the king or deuce gives BTN a full house. Seven hearts win, about 15.9%. You pay 2 BB for a final pot of 14.5 BB, a 13.8% price.",
  teachingSteps: const [
    Act0TeachingStepV1(
      title: "A draw and a price",
      body:
          "A clean out makes you win. A card that gives the set a full house cannot help. Both hands are known, so 44 cards are unseen.",
    ),
  ],
  options: const [
    Act0RunnerOptionV1(
      id: "fold_price_too_high",
      label: "Fold: price too high",
      isCorrect: false,
      preferredLabel: "Call: seven outs",
      betterAnswerLabel: "Call: seven outs",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "A 2 BB call costs 13.8% of the final pot. Seven outs give about 15.9%, so a fold gives up a small edge.",
    ),
    Act0RunnerOptionV1(
      id: "call_seven_outs",
      label: "Call: seven outs",
      isCorrect: true,
      preferredLabel: "Call: seven outs",

      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: "Correct.",
      feedbackReason:
          "A heart that pairs the king or deuce gives BTN a full house. Seven hearts win, about 15.9%. You pay 2 BB for a final pot of 14.5 BB, a 13.8% price.",
    ),
    Act0RunnerOptionV1(
      id: "call_nine_outs",
      label: "Call: nine outs",
      isCorrect: false,
      preferredLabel: "Call: seven outs",
      betterAnswerLabel: "Call: seven outs",
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: "Look again.",
      feedbackReason:
          "The call works, but two hearts make a full house for BTN. Count seven wins, not nine.",
    ),
  ],

  table: _day7TableV1(
    hero: 'bb',
    hand: "8h 7h",
    street: PokerStreet.turn,
    actor: 'bb',
    board: _act0LessonCardsV1("Ks 9h 3h 2c"),
    shown: {'btn': _act0LessonCardsV1("9c 9d")},
    folded: const {"utg", "hj", "co", "sb"},
    stacks: const {
      "utg": 58,
      "hj": 60,
      "co": 64,
      "btn": 55,
      "sb": 50,
      "bb": 45,
    },
    entries: const [
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
        1.5,
      ),
      Act0ContributionV1(
        PokerStreet.flop,
        'btn',
        Act0ContributionKindV1.wager,
        2.5,
      ),
      Act0ContributionV1(
        PokerStreet.flop,
        'bb',
        Act0ContributionKindV1.wager,
        2.5,
      ),
      Act0ContributionV1(
        PokerStreet.turn,
        'btn',
        Act0ContributionKindV1.wager,
        2,
      ),
    ],
    history: const [
      Act0ActionTrailItemV1(label: "SB blind 0.5 BB"),
      Act0ActionTrailItemV1(label: "BB blind 1 BB"),
      Act0ActionTrailItemV1(label: "UTG folds"),
      Act0ActionTrailItemV1(label: "HJ folds"),
      Act0ActionTrailItemV1(label: "CO folds"),
      Act0ActionTrailItemV1(label: "BTN raises to 2.5 BB"),
      Act0ActionTrailItemV1(label: "SB folds"),
      Act0ActionTrailItemV1(label: "BB calls 2.5 BB"),
      Act0ActionTrailItemV1(label: "Flop: BB checks"),
      Act0ActionTrailItemV1(label: "BTN bets 2.5 BB"),
      Act0ActionTrailItemV1(label: "BB calls 2.5 BB"),
      Act0ActionTrailItemV1(label: "Turn: BB checks"),
      Act0ActionTrailItemV1(label: "BTN bets 2 BB"),
    ],
    bets: const {
      'btn': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.bet,
        label: 'Bet',
        amountLabel: '2 BB',
      ),
    },
  ),
);

final _w10ExploitGuardrailsRecapRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w10_guardrails_recap',
  lessonTitle: "Read the price",
  lessonSubtitle: 'Player Adjustment',
  caption: "You have a read and a bet to face.",
  hint: '',
  hintPolicy: Act0HintPolicyV1.theoryOnly,
  question: "What should stop a rushed call?",
  feedbackTitle: "Read the price",
  feedbackReason:
      "If your hand wins less often than the call price needs, the call loses chips.",
  teachingSteps: const [],
  options: const [
    Act0RunnerOptionV1(
      id: "a_loud_bet_from_the_foe",
      label: "A loud bet from the foe",
      isCorrect: false,
      preferredLabel: "A poor price against the bet range",
      betterAnswerLabel: "A poor price against the bet range",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "Loud play is not a range. A player can bluff big or bet a strong hand.",
    ),
    Act0RunnerOptionV1(
      id: "a_loss_in_the_prior_hand",
      label: "A loss in the prior hand",
      isCorrect: false,
      preferredLabel: "A poor price against the bet range",
      betterAnswerLabel: "A poor price against the bet range",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "A past loss does not change this pot or the cards. It can lead to a poor call if it drives your choice.",
    ),
    Act0RunnerOptionV1(
      id: "a_poor_price_against_the_bet_range",
      label: "A poor price against the bet range",
      isCorrect: true,
      preferredLabel: "A poor price against the bet range",

      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: "Correct.",
      feedbackReason:
          "If your hand wins less often than the call price needs, the call loses chips.",
    ),
  ],

  table: _w10TextStudyTableV1,
);

final _w10CheckpointIntroRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w10_checkpoint_intro',
  lessonTitle: "Read the whole hand",
  lessonSubtitle: 'Player Adjustment',
  caption: "Check the cards and the read.",
  hint: '',
  hintPolicy: Act0HintPolicyV1.theoryOnly,
  question: "What is the key check on a call?",
  feedbackTitle: "Read the whole hand",
  feedbackReason:
      "The pot sets the price. The bet range tells you how much of it your hand can beat.",
  teachingSteps: const [
    Act0TeachingStepV1(
      title: "Read the whole hand",
      body:
          "Use the hand and the seat. Check who has bet and how much. Then judge what that player may bet or call with. The next hands put all of these steps together.",
    ),
  ],
  options: const [],

  table: _w10TextStudyTableV1,
);

final _w10RiverPriceCheckRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w10_river_price_check',
  lessonTitle: "River call price",
  lessonSubtitle: 'Player Adjustment',
  caption: "The pot holds 18 BB after the bet. The call costs 6 BB.",
  hint: '',
  hintPolicy: Act0HintPolicyV1.theoryOnly,
  question: "What share of the final pot is the call?",
  feedbackTitle: "River call price",
  feedbackReason: "6 BB goes in a final pot of 24 BB. That is one in four.",
  teachingSteps: const [],
  options: const [
    Act0RunnerOptionV1(
      id: "25",
      label: "1 in 4 (25%)",
      isCorrect: true,
      preferredLabel: "1 in 4 (25%)",

      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: "Correct.",
      feedbackReason: "6 BB goes in a final pot of 24 BB. That is one in four.",
    ),
    Act0RunnerOptionV1(
      id: "33_3",
      label: "1 in 3 (33.3%)",
      isCorrect: false,
      preferredLabel: "1 in 4 (25%)",
      betterAnswerLabel: "1 in 4 (25%)",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "6 BB divided by the 18 BB pot leaves out the chips from your call.",
    ),
    Act0RunnerOptionV1(
      id: "50",
      label: "1 in 2 (50%)",
      isCorrect: false,
      preferredLabel: "1 in 4 (25%)",
      betterAnswerLabel: "1 in 4 (25%)",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "The 6 BB call brings the pot to 24 BB. A half pot would be 12 BB.",
    ),
  ],

  table: _w10TextStudyTableV1,
);

final _w10CheckpointTagLineRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w10_checkpoint_tag_line',
  lessonTitle: "The limper in HJ",
  lessonSubtitle: 'Player Adjustment',
  caption:
      "HJ limps and calls raises with 22–88, weak aces and low suited hands. Both blinds tend to fold to a raise.",
  hint: '',
  hintPolicy: Act0HintPolicyV1.theoryOnly,
  question: "How should you enter?",
  feedbackTitle: "The limper in HJ",
  feedbackReason:
      "99 is a Medium BTN hand. The raise can isolate HJ, who calls with smaller pairs and weak cards.",
  teachingSteps: const [],
  options: const [
    Act0RunnerOptionV1(
      id: "call_1_bb",
      label: "Call 1 BB",
      isCorrect: false,
      preferredLabel: "Raise to 4 BB",
      betterAnswerLabel: "Raise to 4 BB",
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: "Look again.",
      feedbackReason:
          "Calling 1 BB keeps the pot cheap but lets the blinds join. You give up value from the weaker hands HJ calls with.",
    ),
    Act0RunnerOptionV1(
      id: "raise_to_4_bb",
      label: "Raise to 4 BB",
      isCorrect: true,
      preferredLabel: "Raise to 4 BB",

      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: "Correct.",
      feedbackReason:
          "99 is a Medium BTN hand. The raise can isolate HJ, who calls with smaller pairs and weak cards.",
    ),
    Act0RunnerOptionV1(
      id: "fold",
      label: "Fold",
      isCorrect: false,
      preferredLabel: "Raise to 4 BB",
      betterAnswerLabel: "Raise to 4 BB",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "99 is a Medium BTN open. HJ calls with many pairs below 99, so folding misses a good value spot.",
    ),
  ],

  table: _day7TableV1(
    hero: 'btn',
    hand: "9h 9c",
    street: PokerStreet.preflop,
    actor: 'btn',

    folded: const {"utg", "co"},
    stacks: const {
      "utg": 70,
      "hj": 62,
      "co": 65,
      "btn": 50,
      "sb": 42,
      "bb": 48,
    },
    entries: const [
      ..._act0LessonBlinds,
      Act0ContributionV1(
        PokerStreet.preflop,
        'hj',
        Act0ContributionKindV1.wager,
        1,
      ),
    ],
    history: const [
      Act0ActionTrailItemV1(label: "SB blind 0.5 BB"),
      Act0ActionTrailItemV1(label: "BB blind 1 BB"),
      Act0ActionTrailItemV1(label: "UTG folds"),
      Act0ActionTrailItemV1(label: "HJ calls 1 BB"),
      Act0ActionTrailItemV1(label: "CO folds"),
    ],
    bets: const {
      'sb': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.post,
        label: 'Post',
        amountLabel: '0.5 BB',
      ),
      'bb': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.post,
        label: 'Post',
        amountLabel: '1 BB',
      ),
      'hj': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.call,
        label: 'Call',
        amountLabel: '1 BB',
      ),
    },
  ),
);

final _w10CheckpointLeverLineRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w10_checkpoint_lever_line',
  lessonTitle: "Read the big blind",
  lessonSubtitle: 'Player Adjustment',
  caption:
      "BB is a nit. BB folds 90% of the time to both sizes. On the rest, BB 3-bets and you fold.",
  hint: '',
  hintPolicy: Act0HintPolicyV1.theoryOnly,
  question: "Raise or fold?",
  feedbackTitle: "Read the big blind",
  feedbackReason:
      "The BB fold rate makes this steal worth 0.90 x 1.5 - 0.10 x 1.5 = 1.20 BB from this point.",
  teachingSteps: const [],
  options: const [
    Act0RunnerOptionV1(
      id: "fold",
      label: "Fold",
      isCorrect: false,
      preferredLabel: "Raise to 2 BB",
      betterAnswerLabel: "Raise to 2 BB",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "65s is Weak in the chart. Under this read, folding gives up a 90% chance to take the blinds with a raise.",
    ),
    Act0RunnerOptionV1(
      id: "raise_to_6_bb",
      label: "Raise to 6 BB",
      isCorrect: false,
      preferredLabel: "Raise to 2 BB",
      betterAnswerLabel: "Raise to 2 BB",
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: "Look again.",
      feedbackReason:
          "The BB folds 90% to either size. A 6 BB open risks 5.5 BB more than folding if BB 3-bets, not the 1.5 BB used by a 2 BB open.",
    ),
    Act0RunnerOptionV1(
      id: "raise_to_2_bb",
      label: "Raise to 2 BB",
      isCorrect: true,
      preferredLabel: "Raise to 2 BB",

      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: "Correct.",
      feedbackReason:
          "The BB fold rate makes this steal worth 0.90 x 1.5 - 0.10 x 1.5 = 1.20 BB from this point.",
    ),
  ],

  table: _day7TableV1(
    hero: 'sb',
    hand: "6s 5s",
    street: PokerStreet.preflop,
    actor: 'sb',

    folded: const {"utg", "hj", "co", "btn"},
    stacks: const {
      "utg": 64,
      "hj": 61,
      "co": 68,
      "btn": 60,
      "sb": 32,
      "bb": 45,
    },
    entries: const [..._act0LessonBlinds],
    history: const [
      Act0ActionTrailItemV1(label: "SB blind 0.5 BB"),
      Act0ActionTrailItemV1(label: "BB blind 1 BB"),
      Act0ActionTrailItemV1(label: "UTG folds"),
      Act0ActionTrailItemV1(label: "HJ folds"),
      Act0ActionTrailItemV1(label: "CO folds"),
      Act0ActionTrailItemV1(label: "BTN folds"),
    ],
    bets: const {
      'sb': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.post,
        label: 'Post',
        amountLabel: '0.5 BB',
      ),
      'bb': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.post,
        label: 'Post',
        amountLabel: '1 BB',
      ),
    },
  ),
);

final _w10CheckpointGuardrailLineRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w10_checkpoint_guardrail_line',
  lessonTitle: "Facing a turn raise",
  lessonSubtitle: 'Player Adjustment',
  caption:
      "HJ has raised the turn with sets and two pair in eight shown hands. Use that range for this raise.",
  hint: '',
  hintPolicy: Act0HintPolicyV1.theoryOnly,
  question: "Call or fold?",
  feedbackTitle: "Facing a turn raise",
  feedbackReason:
      "The call costs 12 into a final pot of 41.5, or 28.9%. KQ is far behind the shown sets and two pair.",
  teachingSteps: const [],
  options: const [
    Act0RunnerOptionV1(
      id: "fold",
      label: "Fold",
      isCorrect: true,
      preferredLabel: "Fold",

      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: "Correct.",
      feedbackReason:
          "The call costs 12 into a final pot of 41.5, or 28.9%. KQ is far behind the shown sets and two pair.",
    ),
    Act0RunnerOptionV1(
      id: "call_12_bb",
      label: "Call 12 BB",
      isCorrect: false,
      preferredLabel: "Fold",
      betterAnswerLabel: "Fold",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "KQ is top pair, not a set. HJ has shown strong hands on turn raises. Calling 12 BB buys little chance to win.",
    ),
    Act0RunnerOptionV1(
      id: "all_in_to_40_5_bb",
      label: "All-in to 40.5 BB",
      isCorrect: false,
      preferredLabel: "Fold",
      betterAnswerLabel: "Fold",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "A 40.5 BB turn all-in means adding 36.5 after your 4 BB bet. It risks more against HJ turn raises that have shown strong hands.",
    ),
  ],

  table: _day7TableV1(
    hero: 'bb',
    hand: "Kd Qd",
    street: PokerStreet.turn,
    actor: 'bb',
    board: _act0LessonCardsV1("Kc 8s 3h 2c"),

    folded: const {"utg", "co", "btn", "sb"},
    stacks: const {
      "utg": 66,
      "hj": 62,
      "co": 70,
      "btn": 68,
      "sb": 50,
      "bb": 45,
    },
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
      Act0ContributionV1(
        PokerStreet.flop,
        'hj',
        Act0ContributionKindV1.wager,
        2,
      ),
      Act0ContributionV1(
        PokerStreet.flop,
        'bb',
        Act0ContributionKindV1.wager,
        2,
      ),
      Act0ContributionV1(
        PokerStreet.turn,
        'bb',
        Act0ContributionKindV1.wager,
        4,
      ),
      Act0ContributionV1(
        PokerStreet.turn,
        'hj',
        Act0ContributionKindV1.wager,
        16,
      ),
    ],
    history: const [
      Act0ActionTrailItemV1(label: "SB blind 0.5 BB"),
      Act0ActionTrailItemV1(label: "BB blind 1 BB"),
      Act0ActionTrailItemV1(label: "UTG folds"),
      Act0ActionTrailItemV1(label: "HJ raises to 2.5 BB"),
      Act0ActionTrailItemV1(label: "CO folds"),
      Act0ActionTrailItemV1(label: "BTN folds"),
      Act0ActionTrailItemV1(label: "SB folds"),
      Act0ActionTrailItemV1(label: "BB calls 2.5 BB"),
      Act0ActionTrailItemV1(label: "Flop: BB checks"),
      Act0ActionTrailItemV1(label: "HJ bets 2 BB"),
      Act0ActionTrailItemV1(label: "BB calls 2 BB"),
      Act0ActionTrailItemV1(label: "Turn: BB bets 4 BB"),
      Act0ActionTrailItemV1(label: "Turn: HJ raises to 16 BB"),
    ],
    bets: const {
      'bb': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.bet,
        label: 'Bet',
        amountLabel: '4 BB',
      ),
      'hj': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.raise,
        label: 'Raise',
        amountLabel: '16 BB',
      ),
    },
  ),
);

final _w10TableAdjustmentNoticeRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w10_checkpoint_table_notice',
  lessonTitle: "River check and bet",
  lessonSubtitle: 'Player Adjustment',
  caption:
      "CO has shown bluffs after this line. The bet is 50% missed JT or T9 and 50% AQ, KQ or QJ. No ties.",
  hint: '',
  hintPolicy: Act0HintPolicyV1.theoryOnly,
  question: "Call or fold?",
  feedbackTitle: "River check and bet",
  feedbackReason:
      "QT wins against 50% missed draws. The 9 BB call needs 30.0% wins in the 30 BB final pot.",
  teachingSteps: const [],
  options: const [
    Act0RunnerOptionV1(
      id: "fold",
      label: "Fold",
      isCorrect: false,
      preferredLabel: "Call 9 BB",
      betterAnswerLabel: "Call 9 BB",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "QT beats half of CO bets by the stated read. Folding gives up a call worth 6 BB on average.",
    ),
    Act0RunnerOptionV1(
      id: "call_9_bb",
      label: "Call 9 BB",
      isCorrect: true,
      preferredLabel: "Call 9 BB",

      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: "Correct.",
      feedbackReason:
          "QT wins against 50% missed draws. The 9 BB call needs 30.0% wins in the 30 BB final pot.",
    ),
    Act0RunnerOptionV1(
      id: "raise_to_24_bb",
      label: "Raise to 24 BB",
      isCorrect: false,
      preferredLabel: "Call 9 BB",
      betterAnswerLabel: "Call 9 BB",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "QT wins by catching bluffs. A raise may fold missed draws and get calls from better queens.",
    ),
  ],

  table: _day7TableV1(
    hero: 'sb',
    hand: "Qs Ts",
    street: PokerStreet.river,
    actor: 'sb',
    board: _act0LessonCardsV1("Qh 7d 3c 8s 2d"),

    folded: const {"utg", "hj", "btn", "bb"},
    stacks: const {
      "utg": 67,
      "hj": 62,
      "co": 58,
      "btn": 55,
      "sb": 43,
      "bb": 49,
    },
    entries: const [
      ..._act0LessonBlinds,
      Act0ContributionV1(
        PokerStreet.preflop,
        'co',
        Act0ContributionKindV1.wager,
        2.5,
      ),
      Act0ContributionV1(
        PokerStreet.preflop,
        'sb',
        Act0ContributionKindV1.wager,
        2,
      ),
      Act0ContributionV1(
        PokerStreet.flop,
        'co',
        Act0ContributionKindV1.wager,
        3,
      ),
      Act0ContributionV1(
        PokerStreet.flop,
        'sb',
        Act0ContributionKindV1.wager,
        3,
      ),
      Act0ContributionV1(
        PokerStreet.river,
        'co',
        Act0ContributionKindV1.wager,
        9,
      ),
    ],
    history: const [
      Act0ActionTrailItemV1(label: "SB blind 0.5 BB"),
      Act0ActionTrailItemV1(label: "BB blind 1 BB"),
      Act0ActionTrailItemV1(label: "UTG folds"),
      Act0ActionTrailItemV1(label: "HJ folds"),
      Act0ActionTrailItemV1(label: "CO raises to 2.5 BB"),
      Act0ActionTrailItemV1(label: "BTN folds"),
      Act0ActionTrailItemV1(label: "SB calls 2.5 BB"),
      Act0ActionTrailItemV1(label: "BB folds"),
      Act0ActionTrailItemV1(label: "Flop: SB checks"),
      Act0ActionTrailItemV1(label: "CO bets 3 BB"),
      Act0ActionTrailItemV1(label: "SB calls 3 BB"),
      Act0ActionTrailItemV1(label: "Turn: SB checks"),
      Act0ActionTrailItemV1(label: "CO checks"),
      Act0ActionTrailItemV1(label: "River: SB checks"),
      Act0ActionTrailItemV1(label: "CO bets 9 BB"),
    ],
    bets: const {
      'co': Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.bet,
        label: 'Bet',
        amountLabel: '9 BB',
      ),
    },
  ),
);

final _world10PlayerAdjustmentCheckpointRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w10_checkpoint_review',
  lessonTitle: "Last street choice",
  lessonSubtitle: 'Player Adjustment',
  caption:
      "BTN is a calling station. The pair hands call either size 85% of the time. The other 15% fold. No pair will fold to a bet.",
  hint: '',
  hintPolicy: Act0HintPolicyV1.theoryOnly,
  question: "Bet or check?",
  feedbackTitle: "Last street choice",
  feedbackReason:
      "A 8 BB pure bluff needs 8/19.5 = 41.0% folds. BTN folds just 15%. Checking saves the chips.",
  teachingSteps: const [],
  options: const [
    Act0RunnerOptionV1(
      id: "bet_8_bb",
      label: "Bet 8 BB",
      isCorrect: false,
      preferredLabel: "Check",
      betterAnswerLabel: "Check",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "BTN calls 85% with a pair. A pure 8 BB bluff would lose 5.08 BB on average at this 11.5 BB pot.",
    ),
    Act0RunnerOptionV1(
      id: "bet_4_bb",
      label: "Bet 4 BB",
      isCorrect: false,
      preferredLabel: "Check",
      betterAnswerLabel: "Check",
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: "Look again.",
      feedbackReason:
          "A smaller bluff risks less, but BTN folds just 15%. It still loses 1.68 BB on average in this read.",
    ),
    Act0RunnerOptionV1(
      id: "check",
      label: "Check",
      isCorrect: true,
      preferredLabel: "Check",

      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: "Correct.",
      feedbackReason:
          "A 8 BB pure bluff needs 8/19.5 = 41.0% folds. BTN folds just 15%. Checking saves the chips.",
    ),
  ],

  table: _day7TableV1(
    hero: 'bb',
    hand: "9h 8h",
    street: PokerStreet.river,
    actor: 'bb',
    board: _act0LessonCardsV1("Kh 7h 2c 4s 3d"),

    folded: const {"utg", "hj", "co", "sb"},
    stacks: const {
      "utg": 64,
      "hj": 61,
      "co": 59,
      "btn": 57,
      "sb": 50,
      "bb": 52,
    },
    entries: const [
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
        1.5,
      ),
      Act0ContributionV1(
        PokerStreet.flop,
        'btn',
        Act0ContributionKindV1.wager,
        3,
      ),
      Act0ContributionV1(
        PokerStreet.flop,
        'bb',
        Act0ContributionKindV1.wager,
        3,
      ),
    ],
    history: const [
      Act0ActionTrailItemV1(label: "SB blind 0.5 BB"),
      Act0ActionTrailItemV1(label: "BB blind 1 BB"),
      Act0ActionTrailItemV1(label: "UTG folds"),
      Act0ActionTrailItemV1(label: "HJ folds"),
      Act0ActionTrailItemV1(label: "CO folds"),
      Act0ActionTrailItemV1(label: "BTN raises to 2.5 BB"),
      Act0ActionTrailItemV1(label: "SB folds"),
      Act0ActionTrailItemV1(label: "BB calls 2.5 BB"),
      Act0ActionTrailItemV1(label: "Flop: BB checks"),
      Act0ActionTrailItemV1(label: "BTN bets 3 BB"),
      Act0ActionTrailItemV1(label: "BB calls 3 BB"),
      Act0ActionTrailItemV1(label: "Turn: BB checks"),
      Act0ActionTrailItemV1(label: "BTN checks"),
    ],
    bets: const {},
  ),
);

final _w11SessionPlanIntroRunner = _w10ExploitGuardrailsIntroRunner.copyWith(
  table: _act0ReassignHeroSeatV1(
    _act0HypotheticalConceptTableV1(_w9ExampleTableBase),
    heroSeatId: 'co',
    activeSeatId: '',
  ),
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

Act0LessonTaskV1 _w11Task(
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
    runner: _w11SessionPlanIntroRunner.copyWith(
      lessonId: id,
      phase: Act0LessonPhaseV1.drill,
      caption: caption,
      question: question,
      hint: '',
      hintPolicy: Act0HintPolicyV1.hidden,
      feedbackTitle: 'Review your choice.',
      feedbackReason: choices[correct].$3,
      teachingSteps: [if (teaching != null) teaching],
      table: table ?? _w11SessionPlanIntroRunner.table,
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

final _w11_multiway_first_seat = _w11Task(
  'w11_multiway_first_seat',
  'Find the first seat on the flop',
  'CO opened. BTN and BB called.',
  'Tap the first seat to act.',
  correct: 1,
  choices: const [
    (
      'co',
      'CO',
      'CO opened before the flop. Acting from CO now would skip BB, the first live seat after BTN.',
      'co',
    ),
    (
      'bb',
      'BB',
      'BB is the first live seat after BTN once the flop is out.',
      'bb',
    ),
    (
      'btn',
      'BTN',
      'BTN acts last among these three players on the flop. Starting there would skip both other live seats.',
      'btn',
    ),
  ],
  table:
      _day7TableV1(
        hero: 'co',
        hand: 'Ac Qh',
        street: PokerStreet.flop,

        board: _act0LessonCardsV1('Qc 8s 3h'),
        folded: const {'utg', 'hj', 'sb'},
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
          Act0ActionTrailItemV1(label: 'HJ folds'),
          Act0ActionTrailItemV1(label: 'CO raises to 2.5 BB'),
          Act0ActionTrailItemV1(label: 'BTN calls 2.5 BB'),
          Act0ActionTrailItemV1(label: 'SB folds'),
          Act0ActionTrailItemV1(
            label: 'BB calls 2.5 BB',
            displayLabel: 'BB calls 1.5 BB more',
          ),
        ],
        bets: const {},
      ).copyWith(
        showDecisionPremise: true,
        selectableSeatIds: const ['co', 'bb', 'btn'],
      ),
);

final _w11_first_in_seat = _w11Task(
  'w11_first_in_seat',
  'Find the opener',
  'Read the voluntary action after the two blinds were posted.',
  'Tap the seat that opened the pot.',
  correct: 1,
  choices: const [
    (
      'utg',
      'UTG',
      'UTG folded. Counting that seat as the opener ignores HJ’s 2.5 BB raise.',
      'utg',
    ),
    (
      'hj',
      'HJ',
      'HJ put in the first raise. The blinds posted before that action.',
      'hj',
    ),
    (
      'bb',
      'BB',
      'BB posted a 1 BB blind. Counting that post as a raise gives the lead to the wrong seat.',
      'bb',
    ),
  ],
  table: _day7PreflopV1('co', '6s 5s', opener: 'hj', showTurn: true).copyWith(
    showDecisionPremise: true,
    selectableSeatIds: const ['utg', 'hj', 'bb'],
  ),
);

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

final _w11SessionPlanBasicsTasksV1 = <Act0LessonTaskV1>[
  _wave6AuthoredTaskV1(
    id: 'w11_session_plan_intro',
    lesson: 'session_plan_basics',
    lessonTitle: 'Session plan in 30 seconds',
    title: 'One-focus plan',
    phase: Act0LessonPhaseV1.theory,
    step: Act0LessonStepKindV1.learn,
    xp: 7,
    caption: 'A short plan helps you spot one leak while you play.',
    question: 'Which plan can you track?',
    teach:
        'Choose a cue you can see during play. Use it to test a past leak. Bankroll means funds set aside for poker, not rent or other needs. These cash-game drills have no rake or antes.',
    choices: const [
      (
        'one_clear_skill_to_watch',
        'One clear skill to watch',
        Act0FeedbackQualityV1.correct,
        'One cue, such as BB defense, is easy to spot in a short session and check later.',
      ),
      (
        'six_skills_to_track_at_once',
        'Six skills to track at once',
        Act0FeedbackQualityV1.wrong,
        'Six live cues split your focus. You may miss the one BB choice that you meant to study.',
      ),
      (
        'a_win_goal_for_the_day',
        'A win goal for the day',
        Act0FeedbackQualityV1.wrong,
        'A cash win can depend on luck. It does not show whether you read the next bet well.',
      ),
    ],
    table: _wave6StudyTableV1,
  ),
  _wave6AuthoredTaskV1(
    id: 'w11_bankroll_rule',
    lesson: 'session_plan_basics',
    lessonTitle: 'Session plan in 30 seconds',
    title: 'Bankroll rule',
    phase: Act0LessonPhaseV1.drill,
    step: Act0LessonStepKindV1.practice,
    xp: 10,
    caption:
        'Sharky cash-game plan: keep 40 full buy-ins for your stake. NL25 is \$0.10/\$0.25.',
    question: 'What bankroll does NL25 need?',
    teach:
        'A full buy-in is 100 BB. Our course uses a buffer of 40 full buy-ins for cash games. At NL10, a full buy-in is \$10. At NL5, it is \$5. This is a risk guide, not a promise of profit.',
    choices: const [
      (
        '250',
        '\$250',
        Act0FeedbackQualityV1.wrong,
        '\$250 covers ten \$25 buy-ins. That is 30 buy-ins short of the course plan.',
      ),
      (
        '100',
        '\$100',
        Act0FeedbackQualityV1.wrong,
        '\$100 covers four \$25 buy-ins. A few losses could use the funds set aside for play.',
      ),
      (
        '1_000',
        '\$1,000',
        Act0FeedbackQualityV1.correct,
        'At NL25 the big blind is \$0.25. A full buy-in is \$25. Forty buy-ins need \$1,000.',
      ),
    ],
    table: _wave6StudyTableV1,
  ),
  _wave6AuthoredTaskV1(
    id: 'w11_plan_focus_choice',
    lesson: 'session_plan_basics',
    lessonTitle: 'Session plan in 30 seconds',
    title: 'Choose one focus',
    phase: Act0LessonPhaseV1.drill,
    step: Act0LessonStepKindV1.practice,
    xp: 10,
    caption: 'You have 45 minutes and missed three blind calls last week.',
    question: 'What should you track this session?',
    teach:
        'A focus should fit the next session. Name one cue that links to a past error. Make the cue easy to spot and save a hand for a later check.',
    choices: const [
      (
        'profit_from_the_next_45_minutes',
        'Profit from the next 45 minutes',
        Act0FeedbackQualityV1.wrong,
        'Profit can rise from a lucky pot even if you keep making poor blind calls.',
      ),
      (
        'bb_call_price_before_each_defense',
        'BB call price before each defense',
        Act0FeedbackQualityV1.correct,
        'You can note the pot, call amount and hand each time you face a raise in BB.',
      ),
      (
        'blinds_bluffs_calls_and_bet_sizes',
        'Blinds, bluffs, calls and bet sizes',
        Act0FeedbackQualityV1.suboptimal,
        'These are real skills, but tracking four at once makes the three missed BB calls hard to repair.',
      ),
    ],
    table: _wave6StudyTableV1,
  ),
  _wave6AuthoredTaskV1(
    id: 'w11_bankroll_stake_choice',
    lesson: 'session_plan_basics',
    lessonTitle: 'Session plan in 30 seconds',
    title: 'Bankroll stake choice',
    phase: Act0LessonPhaseV1.drill,
    step: Act0LessonStepKindV1.practice,
    xp: 10,
    caption:
        'Your bankroll is \$340. NL5 is \$0.02/\$0.05 with a \$5 full buy-in. NL10 is \$0.05/\$0.10 with a \$10 full buy-in.',
    question: 'Which stake fits the plan?',
    teach:
        'Use the 40-buy-in rule. A full buy-in is 100 BB. Keep rent and other needs out of your poker funds.',
    choices: const [
      (
        'nl5',
        'NL5',
        Act0FeedbackQualityV1.correct,
        '\$340 covers 68 NL5 buy-ins. That clears the 40-buy-in course rule.',
      ),
      (
        'nl10',
        'NL10',
        Act0FeedbackQualityV1.wrong,
        '\$340 covers 34 NL10 buy-ins. This is six below the course buffer.',
      ),
      (
        'nl10_with_a_short_buy_in',
        'NL10 with a short buy-in',
        Act0FeedbackQualityV1.wrong,
        'Buying in short does not change the 40 full-buy-in rule. It hides the gap rather than fixing it.',
      ),
    ],
    table: _wave6StudyTableV1,
  ),
];

final _w11TableTriggerReadsTasksV1 = <Act0LessonTaskV1>[
  _wave6AuthoredTaskV1(
    id: 'w11_trigger_intro',
    lesson: 'table_trigger_reads',
    lessonTitle: 'In-session trigger reads',
    title: 'Trigger-first routine',
    phase: Act0LessonPhaseV1.theory,
    step: Act0LessonStepKindV1.learn,
    xp: 7,
    caption: 'Read the table, then pick one response.',
    question: 'Flop pot 6, stack left 12: what SPR?',
    teach:
        'A multiway pot has three or more players on the flop. A c-bet is a flop bet by the preflop raiser. A 3-bet is a raise over an open raise. SPR is the smaller stack left after preflop, divided by the flop pot. An overpair is a pocket pair above the top board card. Check cards, seat, price and the player read.',
    choices: const [
      (
        '2',
        '2',
        Act0FeedbackQualityV1.correct,
        'SPR is 12/6=2. You have twice the pot left to play.',
      ),
      (
        '6',
        '6',
        Act0FeedbackQualityV1.wrong,
        '6 BB is the pot size, not the ratio. The 12 BB stack is twice that pot.',
      ),
      (
        '12',
        '12',
        Act0FeedbackQualityV1.wrong,
        '12 BB is the stack left, not the ratio. Divide it by the 6 BB pot.',
      ),
    ],
    table: _wave6StudyTableV1,
  ),
  _wave6AuthoredTaskV1(
    id: 'w11_trigger_overfold_blinds',
    lesson: 'table_trigger_reads',
    lessonTitle: 'In-session trigger reads',
    title: 'Blind overfold trigger',
    phase: Act0LessonPhaseV1.drill,
    step: Act0LessonStepKindV1.practice,
    xp: 10,
    caption:
        'You have A7o in SB. BB has folded to 22 of 25 SB opens. This drill gives an 88% fold rate to a 2 or 4 BB open. On a 3-bet, you fold.',
    question: 'How should you enter?',
    teach: '',
    choices: const [
      (
        'raise_to_4_bb',
        'Raise to 4 BB',
        Act0FeedbackQualityV1.suboptimal,
        'BB folds at the same rate. The larger open risks 3.5 BB more than folding and gives up 0.24 BB of steal value.',
      ),
      (
        'fold',
        'Fold',
        Act0FeedbackQualityV1.wrong,
        'A7o is weak in the base chart, but the observed 88% BB folds make a small SB steal worth more than giving up the blind.',
      ),
      (
        'raise_to_2_bb',
        'Raise to 2 BB',
        Act0FeedbackQualityV1.correct,
        'BB folds 88%. From this decision, the 2 BB open gains 1.14 BB on average: 0.88 x 1.5 - 0.12 x 1.5. SB has already put in 0.5 BB. The base chart is a guide for first-in hands. A tested player read can change a close choice. Check risk and the fold rate.',
      ),
    ],
    table: _day7TableV1(
      hero: 'sb',
      hand: 'Ah 7d',
      street: PokerStreet.preflop,
      actor: 'sb',

      folded: const {'utg', 'hj', 'co', 'btn'},
      stacks: const {
        'utg': 62,
        'hj': 58,
        'co': 55,
        'btn': 52,
        'sb': 32,
        'bb': 40,
      },
      entries: const [..._act0LessonBlinds],
      history: const [
        Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
        Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
        Act0ActionTrailItemV1(label: 'UTG folds'),
        Act0ActionTrailItemV1(label: 'HJ folds'),
        Act0ActionTrailItemV1(label: 'CO folds'),
        Act0ActionTrailItemV1(label: 'BTN folds'),
      ],
      bets: const {
        'sb': Act0SeatBetStateV1(
          kind: Act0SeatBetKindV1.post,
          label: 'post',
          amountLabel: '0.5 BB',
        ),
        'bb': Act0SeatBetStateV1(
          kind: Act0SeatBetKindV1.post,
          label: 'post',
          amountLabel: '1 BB',
        ),
      },
    ).copyWith(showDecisionPremise: true),
  ),
  _wave6AuthoredTaskV1(
    id: 'w11_trigger_overcall_flop',
    lesson: 'table_trigger_reads',
    lessonTitle: 'In-session trigger reads',
    title: 'Overcall trigger',
    phase: Act0LessonPhaseV1.drill,
    step: Act0LessonStepKindV1.practice,
    xp: 10,
    caption:
        'Three players see A-7-3. You hold AK. BTN and BB have called bets with weaker aces and 7x in prior hands. They each call a 4 BB bet often.',
    question: 'Bet or check?',
    teach: '',
    choices: const [
      (
        'bet_4_bb',
        'Bet 4 BB',
        Act0FeedbackQualityV1.correct,
        'Your AK has top pair with the best kicker. The two loose callers can pay 4 BB with weaker aces or 7x. In a multiway pot, two players can pay the same bet. A bet seeks calls from worse hands. A check may save chips or give a free card. Check each range.',
      ),
      (
        'check',
        'Check',
        Act0FeedbackQualityV1.suboptimal,
        'A check keeps the 8 BB pot small. It also gives two loose callers a free card and misses value from weaker aces.',
      ),
      (
        'bet_20_bb',
        'Bet 20 BB',
        Act0FeedbackQualityV1.wrong,
        'An overbet of 20 into 8 may lose the 7x calls you want. You risk a large bet when either foe has two pair or a set.',
      ),
    ],
    table: _day7TableV1(
      hero: 'utg',
      hand: 'Ac Kc',
      street: PokerStreet.flop,
      actor: 'utg',
      board: _act0LessonCardsV1('As 7d 3h'),

      folded: const {'hj', 'co', 'sb'},
      stacks: const {
        'utg': 55,
        'hj': 62,
        'co': 60,
        'btn': 44,
        'sb': 51,
        'bb': 45,
      },
      entries: const [
        ..._act0LessonBlinds,
        Act0ContributionV1(
          PokerStreet.preflop,
          'utg',
          Act0ContributionKindV1.wager,
          2.5,
        ),
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
          1.5,
        ),
      ],
      history: const [
        Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
        Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
        Act0ActionTrailItemV1(label: 'UTG raises to 2.5 BB'),
        Act0ActionTrailItemV1(label: 'HJ folds'),
        Act0ActionTrailItemV1(label: 'CO folds'),
        Act0ActionTrailItemV1(label: 'BTN calls 2.5 BB'),
        Act0ActionTrailItemV1(label: 'SB folds'),
        Act0ActionTrailItemV1(label: 'BB calls 1.5 BB more'),
        Act0ActionTrailItemV1(label: 'Flop: BB checks'),
      ],
      bets: const {},
    ).copyWith(showDecisionPremise: true),
  ),
  _wave6AuthoredTaskV1(
    id: 'w11_trigger_small_price_continue',
    lesson: 'table_trigger_reads',
    lessonTitle: 'In-session trigger reads',
    title: 'A small bet on the flop',
    phase: Act0LessonPhaseV1.drill,
    step: Act0LessonStepKindV1.practice,
    xp: 10,
    family: Act0TaskFamilyV1.transfer,
    caption:
        'Three players see J-7-4. CO has c-bet weak overcards as well as Jx in past hands. BTN calls small bets with 7x and draws. You hold top pair QJ.',
    question: 'How should you respond?',
    teach: '',
    choices: const [
      (
        'raise_to_10_bb',
        'Raise to 10 BB',
        Act0FeedbackQualityV1.suboptimal,
        'Raising 10 can drive out the overcards and 7x you beat. It makes a larger pot with CO strong Jx still in.',
      ),
      (
        'fold',
        'Fold',
        Act0FeedbackQualityV1.wrong,
        'QJ has top pair and costs 2 BB to stay in a 12 BB pot. Folding loses a cheap chance against the weak bets in the read.',
      ),
      (
        'call_2_bb',
        'Call 2 BB',
        Act0FeedbackQualityV1.correct,
        'The pot is 12 BB now. Your 2 BB call needs 14.3% of a 14 BB final pot. QJ can beat CO overcards and BTN weak pairs. In a multiway pot, think about both players. A call closes the action here. If you raise, CO and BTN can act again.',
      ),
    ],
    table: _day7TableV1(
      hero: 'bb',
      hand: 'Qs Js',
      street: PokerStreet.flop,
      actor: 'bb',
      board: _act0LessonCardsV1('Jh 7c 4d'),

      folded: const {'utg', 'hj', 'sb'},
      stacks: const {
        'utg': 57,
        'hj': 58,
        'co': 60,
        'btn': 50,
        'sb': 54,
        'bb': 44,
      },
      entries: const [
        ..._act0LessonBlinds,
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
        Act0ContributionV1(
          PokerStreet.preflop,
          'bb',
          Act0ContributionKindV1.wager,
          1.5,
        ),
        Act0ContributionV1(
          PokerStreet.flop,
          'co',
          Act0ContributionKindV1.wager,
          2,
        ),
        Act0ContributionV1(
          PokerStreet.flop,
          'btn',
          Act0ContributionKindV1.wager,
          2,
        ),
      ],
      history: const [
        Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
        Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
        Act0ActionTrailItemV1(label: 'UTG folds'),
        Act0ActionTrailItemV1(label: 'HJ folds'),
        Act0ActionTrailItemV1(label: 'CO raises to 2.5 BB'),
        Act0ActionTrailItemV1(label: 'BTN calls 2.5 BB'),
        Act0ActionTrailItemV1(label: 'SB folds'),
        Act0ActionTrailItemV1(label: 'BB calls 1.5 BB more'),
        Act0ActionTrailItemV1(label: 'Flop: BB checks'),
        Act0ActionTrailItemV1(label: 'CO bets 2 BB'),
        Act0ActionTrailItemV1(label: 'BTN calls 2 BB'),
      ],
      bets: const {
        'co': Act0SeatBetStateV1(
          kind: Act0SeatBetKindV1.bet,
          label: 'bet',
          amountLabel: '2 BB',
        ),
        'btn': Act0SeatBetStateV1(
          kind: Act0SeatBetKindV1.call,
          label: 'call',
          amountLabel: '2 BB',
        ),
      },
    ).copyWith(showDecisionPremise: true),
  ),
  _wave6AuthoredTaskV1(
    id: 'w11_trigger_bad_price_fold',
    lesson: 'table_trigger_reads',
    lessonTitle: 'In-session trigger reads',
    title: 'A tight turn raise',
    phase: Act0LessonPhaseV1.drill,
    step: Act0LessonStepKindV1.practice,
    xp: 10,
    family: Act0TaskFamilyV1.transfer,
    caption:
        'CO bets 8 into 10 on K-8-4-2. In eight past big turn bets, CO showed sets, K8 or AK in seven. Assume KQ wins 15% against this betting range by the river, about 1 in 7.',
    question: 'Call or fold?',
    teach: '',
    choices: const [
      (
        'fold',
        'Fold',
        Act0FeedbackQualityV1.correct,
        'The 8 BB call needs 30.8% wins. Your top pair KQ has 15% by this read. Folding saves 8 BB. A new street can change the cost of a call. A big turn bet is not the same as a small flop bet. Read the price and past hands, not the hand name.',
      ),
      (
        'call_8_bb',
        'Call 8 BB',
        Act0FeedbackQualityV1.wrong,
        'KQ loses to the sets, K8 and AK in this turn range. With 15% wins, calling loses 4.1 BB on average.',
      ),
      (
        'all_in_to_32_5_bb',
        'All-in to 32.5 BB',
        Act0FeedbackQualityV1.wrong,
        'You have 32.5 BB left before this choice. Going all-in into a strong turn range risks the rest of the stack with top pair.',
      ),
    ],
    table: _day7TableV1(
      hero: 'sb',
      hand: 'Kc Qd',
      street: PokerStreet.turn,
      actor: 'sb',
      board: _act0LessonCardsV1('Ks 8d 4c 2h'),

      folded: const {'utg', 'hj', 'btn', 'bb'},
      stacks: const {
        'utg': 65,
        'hj': 62,
        'co': 59,
        'btn': 57,
        'sb': 37,
        'bb': 50,
      },
      entries: const [
        ..._act0LessonBlinds,
        Act0ContributionV1(
          PokerStreet.preflop,
          'co',
          Act0ContributionKindV1.wager,
          2.5,
        ),
        Act0ContributionV1(
          PokerStreet.preflop,
          'sb',
          Act0ContributionKindV1.wager,
          2,
        ),
        Act0ContributionV1(
          PokerStreet.flop,
          'co',
          Act0ContributionKindV1.wager,
          2,
        ),
        Act0ContributionV1(
          PokerStreet.flop,
          'sb',
          Act0ContributionKindV1.wager,
          2,
        ),
        Act0ContributionV1(
          PokerStreet.turn,
          'co',
          Act0ContributionKindV1.wager,
          8,
        ),
      ],
      history: const [
        Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
        Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
        Act0ActionTrailItemV1(label: 'UTG folds'),
        Act0ActionTrailItemV1(label: 'HJ folds'),
        Act0ActionTrailItemV1(label: 'CO raises to 2.5 BB'),
        Act0ActionTrailItemV1(label: 'BTN folds'),
        Act0ActionTrailItemV1(label: 'SB calls 2 BB more'),
        Act0ActionTrailItemV1(label: 'BB folds'),
        Act0ActionTrailItemV1(label: 'Flop: SB checks'),
        Act0ActionTrailItemV1(label: 'CO bets 2 BB'),
        Act0ActionTrailItemV1(label: 'SB calls 2 BB'),
        Act0ActionTrailItemV1(label: 'Turn: SB checks'),
        Act0ActionTrailItemV1(label: 'CO bets 8 BB'),
      ],
      bets: const {
        'co': Act0SeatBetStateV1(
          kind: Act0SeatBetKindV1.bet,
          label: 'bet',
          amountLabel: '8 BB',
        ),
      },
    ).copyWith(showDecisionPremise: true),
  ),
  _w11_multiway_first_seat,
  _wave6AuthoredTaskV1(
    id: 'w11_bb_defend_price',
    lesson: 'table_trigger_reads',
    lessonTitle: 'In-session trigger reads',
    title: 'Bb defend price',
    phase: Act0LessonPhaseV1.drill,
    step: Act0LessonStepKindV1.practice,
    xp: 10,
    caption:
        'BTN opens to 2 BB. BTN opens wide and has called 3-bets with better aces and pairs. You have KJs in BB. No antes.',
    question: 'How should you defend?',
    teach: '',
    choices: const [
      (
        'raise_to_8_bb',
        'Raise to 8 BB',
        Act0FeedbackQualityV1.suboptimal,
        'KJs has good strength, but an 8 BB 3-bet builds a larger pot against BTN strong continue range. A cheap call keeps those weaker opens in.',
      ),
      (
        'call_1_bb',
        'Call 1 BB',
        Act0FeedbackQualityV1.correct,
        'Your call is 1 into a final 4.5 BB pot, a 22.2% price. KJs has play value against a wide BTN open. A BB has put in 1 BB before the hand starts. A small raise may cost little to call. The first-in chart is not a BB defense chart.',
      ),
      (
        'fold',
        'Fold',
        Act0FeedbackQualityV1.wrong,
        'KJs can defend the BB against a wide 2 BB BTN open. Folding misses a cheap 22.2% price with a suited broadway hand.',
      ),
    ],
    table: _day7TableV1(
      hero: 'bb',
      hand: 'Ks Js',
      street: PokerStreet.preflop,
      actor: 'bb',

      folded: const {'utg', 'hj', 'co', 'sb'},
      stacks: const {
        'utg': 60,
        'hj': 58,
        'co': 56,
        'btn': 50,
        'sb': 55,
        'bb': 44,
      },
      entries: const [
        ..._act0LessonBlinds,
        Act0ContributionV1(
          PokerStreet.preflop,
          'btn',
          Act0ContributionKindV1.wager,
          2,
        ),
      ],
      history: const [
        Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
        Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
        Act0ActionTrailItemV1(label: 'UTG folds'),
        Act0ActionTrailItemV1(label: 'HJ folds'),
        Act0ActionTrailItemV1(label: 'CO folds'),
        Act0ActionTrailItemV1(label: 'BTN raises to 2 BB'),
        Act0ActionTrailItemV1(label: 'SB folds'),
      ],
      bets: const {
        'sb': Act0SeatBetStateV1(
          kind: Act0SeatBetKindV1.post,
          label: 'post',
          amountLabel: '0.5 BB',
        ),
        'bb': Act0SeatBetStateV1(
          kind: Act0SeatBetKindV1.post,
          label: 'post',
          amountLabel: '1 BB',
        ),
        'btn': Act0SeatBetStateV1(
          kind: Act0SeatBetKindV1.raise,
          label: 'raise',
          amountLabel: '2 BB',
        ),
      },
    ).copyWith(showDecisionPremise: true),
  ),
  _wave6AuthoredTaskV1(
    id: 'w11_sb_3bet_value',
    lesson: 'table_trigger_reads',
    lessonTitle: 'In-session trigger reads',
    title: 'Sb 3bet value',
    phase: Act0LessonPhaseV1.drill,
    step: Act0LessonStepKindV1.practice,
    xp: 10,
    caption:
        'BTN opens to 2.5 BB. BTN has called 3-bets with 99-JJ, ATs and KQs. BB folds to a 3-bet in this drill. You hold AA in SB.',
    question: 'How should you respond?',
    teach: '',
    choices: const [
      (
        'call_2_bb',
        'Call 2 BB',
        Act0FeedbackQualityV1.suboptimal,
        'AA can win by calling, but this gives BTN a cheap path and lets BB join while you’re out of position. You miss more value from 99-JJ and ATs.',
      ),
      (
        'fold',
        'Fold',
        Act0FeedbackQualityV1.wrong,
        'AA is Premium and far ahead of the BTN calls shown. Folding gives up a strong chance to win a larger pot.',
      ),
      (
        '3_bet_to_8_bb',
        '3-bet to 8 BB',
        Act0FeedbackQualityV1.correct,
        'AA is ahead of BTN weak calls. An 8 BB 3-bet builds a pot for value while BB is likely to fold. A 3-bet is a raise after an open raise. In SB, a call leaves BB free to act. A raise may make the pot larger against a wide opening range.',
      ),
    ],
    table: _day7TableV1(
      hero: 'sb',
      hand: 'As Ad',
      street: PokerStreet.preflop,
      actor: 'sb',

      folded: const {'utg', 'hj', 'co'},
      stacks: const {
        'utg': 60,
        'hj': 58,
        'co': 55,
        'btn': 43,
        'sb': 45,
        'bb': 48,
      },
      entries: const [
        ..._act0LessonBlinds,
        Act0ContributionV1(
          PokerStreet.preflop,
          'btn',
          Act0ContributionKindV1.wager,
          2.5,
        ),
      ],
      history: const [
        Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
        Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
        Act0ActionTrailItemV1(label: 'UTG folds'),
        Act0ActionTrailItemV1(label: 'HJ folds'),
        Act0ActionTrailItemV1(label: 'CO folds'),
        Act0ActionTrailItemV1(label: 'BTN raises to 2.5 BB'),
      ],
      bets: const {
        'sb': Act0SeatBetStateV1(
          kind: Act0SeatBetKindV1.post,
          label: 'post',
          amountLabel: '0.5 BB',
        ),
        'bb': Act0SeatBetStateV1(
          kind: Act0SeatBetKindV1.post,
          label: 'post',
          amountLabel: '1 BB',
        ),
        'btn': Act0SeatBetStateV1(
          kind: Act0SeatBetKindV1.raise,
          label: 'raise',
          amountLabel: '2.5 BB',
        ),
      },
    ).copyWith(showDecisionPremise: true),
  ),
];

final _w11PostSessionReviewLoopTasksV1 = <Act0LessonTaskV1>[
  _wave6AuthoredTaskV1(
    id: 'w11_review_pick_leak',
    lesson: 'post_session_review_loop',
    lessonTitle: 'Post-session review habit',
    title: 'Pick priority leak',
    phase: Act0LessonPhaseV1.drill,
    step: Act0LessonStepKindV1.practice,
    xp: 10,
    caption:
        'Your log shows four bad BB calls and one missed value bet. Your goal is to find one repeated decision you can work on next session.',
    question: 'Which leak should you review first?',
    teach:
        'The next focus should come from what the record shows. Count repeated errors, then name the same clue you missed. Do not call a lucky win a fixed leak.',
    choices: const [
      (
        'the_single_missed_value_bet',
        'The single missed value bet',
        Act0FeedbackQualityV1.suboptimal,
        'That hand may need work, but the log shows four BB price errors. The repeated leak needs the first check.',
      ),
      (
        'the_largest_pot_you_won',
        'The largest pot you won',
        Act0FeedbackQualityV1.wrong,
        'A large win is not listed as an error. It gives no reason to skip the four bad BB calls.',
      ),
      (
        'bb_call_price_against_strong_bets',
        'BB call price against strong bets',
        Act0FeedbackQualityV1.correct,
        'Four BB price errors give more repeated evidence than the one missed value bet.',
      ),
    ],
    table: _wave6StudyTableV1,
  ),
  _wave6AuthoredTaskV1(
    id: 'w11_review_define_fix',
    lesson: 'post_session_review_loop',
    lessonTitle: 'Post-session review habit',
    title: 'Define tomorrow fix',
    phase: Act0LessonPhaseV1.drill,
    step: Act0LessonStepKindV1.practice,
    xp: 10,
    caption: 'Your notes show calls with top pair against rare turn raises.',
    question: 'Which note is a clear repair cue?',
    teach:
        'A useful fix says when to use the clue. It does not ask you to guess a win rate. Save the old miss and test a new turn raise with no hint.',
    choices: const [
      (
        'on_a_turn_raise_check_range_and_call_price',
        'On a turn raise, check range and call price',
        Act0FeedbackQualityV1.correct,
        'The cue names the turn raise and two facts to test before putting more chips in.',
      ),
      (
        'play_tighter_after_a_loss',
        'Play tighter after a loss',
        Act0FeedbackQualityV1.wrong,
        'A loss is not the turn-raise cue. Tight play after a loss can fold good hands in new spots.',
      ),
      (
        'win_back_the_cost_of_the_error',
        'Win back the cost of the error',
        Act0FeedbackQualityV1.wrong,
        'The money lost is gone. A chase goal can cause another poor call in a new pot.',
      ),
    ],
    table: _wave6StudyTableV1,
  ),
  _wave6AuthoredTaskV1(
    id: 'w11_review_loop_recap',
    lesson: 'post_session_review_loop',
    lessonTitle: 'Post-session review habit',
    title: 'Review-habit recap',
    phase: Act0LessonPhaseV1.review,
    step: Act0LessonStepKindV1.review,
    xp: 16,
    caption: 'A clean review gives one next test.',
    question: 'What shows a new skill read?',
    teach:
        'A saved miss can teach you what to check next. Help may teach a clue. A new unassisted hand tests if you can use it. A result days later needs real time to pass.',
    choices: const [
      (
        'an_unassisted_choice_in_a_new_hand',
        'An unassisted choice in a new hand',
        Act0FeedbackQualityV1.correct,
        'A new spot with no hint tests if you can use the cue beyond the first missed hand.',
      ),
      (
        'a_replay_solved_with_a_hint',
        'A replay solved with a hint',
        Act0FeedbackQualityV1.wrong,
        'A hint can teach you. It does not show you found the cue on your own.',
      ),
      (
        'a_win_after_the_old_mistake',
        'A win after the old mistake',
        Act0FeedbackQualityV1.wrong,
        'A pot win can come from luck. It does not test the price or the range clue.',
      ),
    ],
    table: _wave6StudyTableV1,
  ),
];

final _w11RealPlayTransferCheckpointTasksV1 = <Act0LessonTaskV1>[
  _wave6AuthoredTaskV1(
    id: 'w11_checkpoint_intro',
    lesson: 'real_play_transfer_checkpoint',
    lessonTitle: 'Real-play session checkpoint',
    title: 'Session cycle map',
    phase: Act0LessonPhaseV1.drill,
    step: Act0LessonStepKindV1.learn,
    xp: 7,
    caption: 'Five new hands test the full live table read.',
    question:
        'An example pot starts with 8 BB. Your call would match a 4 BB wager. What is the call price?',
    teach:
        'Read the seat, cards and board. A pot price is the call divided by the final pot. Check each player who may still act. After you choose, review the reason.',
    choices: const [
      (
        '25',
        '25%',
        Act0FeedbackQualityV1.correct,
        'The pot has 12 after the bet. Calling 4 makes 16. The price is 4/16=25%.',
      ),
      (
        '33_3',
        '33.3%',
        Act0FeedbackQualityV1.wrong,
        '4/12 leaves out your own call. The final pot is 16, so the call price is lower.',
      ),
      (
        '50',
        '50%',
        Act0FeedbackQualityV1.wrong,
        'The 4 BB bet is half of the old 8 BB pot. The call cost uses the 16 BB final pot.',
      ),
    ],
    table: _wave6StudyTableV1,
  ),
  _wave6AuthoredTaskV1(
    id: 'w11_checkpoint_plan_line',
    lesson: 'real_play_transfer_checkpoint',
    lessonTitle: 'Real-play session checkpoint',
    title: 'Plan line',
    phase: Act0LessonPhaseV1.drill,
    step: Act0LessonStepKindV1.practice,
    xp: 10,
    caption:
        'BTN opens to 2.5 BB and calls 3-bets with AT, A9s, KQ and 88-JJ. BB folds to most 3-bets. You have AJs in SB.',
    question: 'How should you respond?',
    teach: '',
    choices: const [
      (
        '3_bet_to_9_bb',
        '3-bet to 9 BB',
        Act0FeedbackQualityV1.correct,
        'AJs can get calls from weaker aces and KQ. A 9 BB 3-bet earns value and may keep BB out.',
      ),
      (
        'call_2_bb',
        'Call 2 BB',
        Act0FeedbackQualityV1.suboptimal,
        'A call can play, but BB can join, you’re out of position and BTN’s weaker aces see a cheap flop. The strong hand misses part of its value.',
      ),
      (
        'fold',
        'Fold',
        Act0FeedbackQualityV1.wrong,
        'AJs is Strong against the hands BTN calls with. Folding to 2.5 BB gives up a good SB value chance.',
      ),
    ],
    table: _day7TableV1(
      hero: 'sb',
      hand: 'Ah Jh',
      street: PokerStreet.preflop,
      actor: 'sb',

      folded: const {'utg', 'hj', 'co'},
      stacks: const {
        'utg': 70,
        'hj': 66,
        'co': 60,
        'btn': 50,
        'sb': 45,
        'bb': 55,
      },
      entries: const [
        ..._act0LessonBlinds,
        Act0ContributionV1(
          PokerStreet.preflop,
          'btn',
          Act0ContributionKindV1.wager,
          2.5,
        ),
      ],
      history: const [
        Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
        Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
        Act0ActionTrailItemV1(label: 'UTG folds'),
        Act0ActionTrailItemV1(label: 'HJ folds'),
        Act0ActionTrailItemV1(label: 'CO folds'),
        Act0ActionTrailItemV1(label: 'BTN raises to 2.5 BB'),
      ],
      bets: const {
        'sb': Act0SeatBetStateV1(
          kind: Act0SeatBetKindV1.post,
          label: 'post',
          amountLabel: '0.5 BB',
        ),
        'bb': Act0SeatBetStateV1(
          kind: Act0SeatBetKindV1.post,
          label: 'post',
          amountLabel: '1 BB',
        ),
        'btn': Act0SeatBetStateV1(
          kind: Act0SeatBetKindV1.raise,
          label: 'raise',
          amountLabel: '2.5 BB',
        ),
      },
    ).copyWith(showDecisionPremise: true),
  ),
  _wave6AuthoredTaskV1(
    id: 'w11_checkpoint_trigger_line',
    lesson: 'real_play_transfer_checkpoint',
    lessonTitle: 'Real-play session checkpoint',
    title: 'Trigger line',
    phase: Act0LessonPhaseV1.drill,
    step: Act0LessonStepKindV1.practice,
    xp: 10,
    caption:
        'BTN has shown weak bluffs in six of ten past flop bets. BTN bets 4 into 5.5 on K-7-3. You hold KT, top pair.',
    question: 'How should you respond?',
    teach: '',
    choices: const [
      (
        'raise_to_12_bb',
        'Raise to 12 BB',
        Act0FeedbackQualityV1.suboptimal,
        'A raise may push out BTN weak bluffs. A call keeps those hands in while top pair remains ahead of much of the betting range.',
      ),
      (
        'fold',
        'Fold',
        Act0FeedbackQualityV1.wrong,
        'KT has top pair against a foe with six weak flop bluffs in ten. Folding gives up a call with good value at a 29.6% price.',
      ),
      (
        'call_4_bb',
        'Call 4 BB',
        Act0FeedbackQualityV1.correct,
        'KT beats the shown bluffs and some weaker kings. A 4 BB call needs 29.6% wins in a 13.5 BB final pot.',
      ),
    ],
    table: _day7TableV1(
      hero: 'bb',
      hand: 'Kc Td',
      street: PokerStreet.flop,
      actor: 'bb',
      board: _act0LessonCardsV1('Ks 7h 3d'),

      folded: const {'utg', 'hj', 'co', 'sb'},
      stacks: const {
        'utg': 65,
        'hj': 60,
        'co': 62,
        'btn': 45,
        'sb': 53,
        'bb': 40,
      },
      entries: const [
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
          1.5,
        ),
        Act0ContributionV1(
          PokerStreet.flop,
          'btn',
          Act0ContributionKindV1.wager,
          4,
        ),
      ],
      history: const [
        Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
        Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
        Act0ActionTrailItemV1(label: 'UTG folds'),
        Act0ActionTrailItemV1(label: 'HJ folds'),
        Act0ActionTrailItemV1(label: 'CO folds'),
        Act0ActionTrailItemV1(label: 'BTN raises to 2.5 BB'),
        Act0ActionTrailItemV1(label: 'SB folds'),
        Act0ActionTrailItemV1(label: 'BB calls 1.5 BB more'),
        Act0ActionTrailItemV1(label: 'Flop: BB checks'),
        Act0ActionTrailItemV1(label: 'BTN bets 4 BB'),
      ],
      bets: const {
        'btn': Act0SeatBetStateV1(
          kind: Act0SeatBetKindV1.bet,
          label: 'bet',
          amountLabel: '4 BB',
        ),
      },
    ).copyWith(showDecisionPremise: true),
  ),
  _wave6AuthoredTaskV1(
    id: 'w11_checkpoint_review_line',
    lesson: 'real_play_transfer_checkpoint',
    lessonTitle: 'Real-play session checkpoint',
    title: 'Review line',
    phase: Act0LessonPhaseV1.drill,
    step: Act0LessonStepKindV1.practice,
    xp: 10,
    family: Act0TaskFamilyV1.transfer,
    caption:
        'Four players see 9-6-2. You have a set of nines. UTG bets AA, KK and AK. HJ has 6x or 77-88. Both tend to fold these hands to a raise to 14, but pay a small turn bet after a flop call.',
    question: 'Call or raise?',
    teach: '',
    choices: const [
      (
        'raise_to_14_bb',
        'Raise to 14 BB',
        Act0FeedbackQualityV1.suboptimal,
        'A raise can win value from AA, but the read says weak hands fold. It may lose later calls from AK and HJ small pairs.',
      ),
      (
        'call_4_bb',
        'Call 4 BB',
        Act0FeedbackQualityV1.correct,
        'Your set wins from many worse hands. A call keeps the weak UTG bets and HJ small pairs in the 22.5 BB pot.',
      ),
      (
        'fold',
        'Fold',
        Act0FeedbackQualityV1.wrong,
        'A set of nines is far ahead of AK and 77-88 on 9-6-2. Folding gives up a large value chance in a four-way pot.',
      ),
    ],
    table: _day7TableV1(
      hero: 'co',
      hand: '9h 9d',
      street: PokerStreet.flop,
      actor: 'co',
      board: _act0LessonCardsV1('9s 6h 2c'),

      folded: const {'btn', 'sb'},
      stacks: const {
        'utg': 70,
        'hj': 68,
        'co': 65,
        'btn': 60,
        'sb': 55,
        'bb': 62,
      },
      entries: const [
        ..._act0LessonBlinds,
        Act0ContributionV1(
          PokerStreet.preflop,
          'utg',
          Act0ContributionKindV1.wager,
          2.5,
        ),
        Act0ContributionV1(
          PokerStreet.preflop,
          'hj',
          Act0ContributionKindV1.wager,
          2.5,
        ),
        Act0ContributionV1(
          PokerStreet.preflop,
          'co',
          Act0ContributionKindV1.wager,
          2.5,
        ),
        Act0ContributionV1(
          PokerStreet.preflop,
          'bb',
          Act0ContributionKindV1.wager,
          1.5,
        ),
        Act0ContributionV1(
          PokerStreet.flop,
          'utg',
          Act0ContributionKindV1.wager,
          4,
        ),
        Act0ContributionV1(
          PokerStreet.flop,
          'hj',
          Act0ContributionKindV1.wager,
          4,
        ),
      ],
      history: const [
        Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
        Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
        Act0ActionTrailItemV1(label: 'UTG raises to 2.5 BB'),
        Act0ActionTrailItemV1(label: 'HJ calls 2.5 BB'),
        Act0ActionTrailItemV1(label: 'CO calls 2.5 BB'),
        Act0ActionTrailItemV1(label: 'BTN folds'),
        Act0ActionTrailItemV1(label: 'SB folds'),
        Act0ActionTrailItemV1(label: 'BB calls 1.5 BB more'),
        Act0ActionTrailItemV1(label: 'Flop: BB checks'),
        Act0ActionTrailItemV1(label: 'UTG bets 4 BB'),
        Act0ActionTrailItemV1(label: 'HJ calls 4 BB'),
      ],
      bets: const {
        'utg': Act0SeatBetStateV1(
          kind: Act0SeatBetKindV1.bet,
          label: 'bet',
          amountLabel: '4 BB',
        ),
        'hj': Act0SeatBetStateV1(
          kind: Act0SeatBetKindV1.call,
          label: 'call',
          amountLabel: '4 BB',
        ),
      },
    ).copyWith(showDecisionPremise: true),
  ),
  _wave6AuthoredTaskV1(
    id: 'w11_checkpoint_mixed_table_line',
    lesson: 'real_play_transfer_checkpoint',
    lessonTitle: 'Real-play session checkpoint',
    title: 'Mixed table line',
    phase: Act0LessonPhaseV1.drill,
    step: Act0LessonStepKindV1.practice,
    xp: 10,
    family: Act0TaskFamilyV1.transfer,
    caption:
        'SB and BTN start with 35 BB. Flop pot 19 and 26 behind: SPR 1.4. BTN calls 7 BB with AJ, AT and 88-JJ. BTN calls a 26 BB all-in with sets and AK.',
    question: 'Bet or check?',
    teach: '',
    choices: const [
      (
        'check',
        'Check',
        Act0FeedbackQualityV1.suboptimal,
        'Checking can control the pot, but AQ is ahead of BTN weak calls. You miss a clear 7 BB value bet.',
      ),
      (
        'all_in_to_26_bb',
        'All-in to 26 BB',
        Act0FeedbackQualityV1.wrong,
        'Going all-in can fold the worse aces and pairs that call 7 BB. It risks 26 BB when BTN has a strong hand.',
      ),
      (
        'bet_7_bb',
        'Bet 7 BB',
        Act0FeedbackQualityV1.correct,
        'AQ beats AJ, AT and 88-JJ. Those hands often call 7 BB, so this size gets paid at the low SPR.',
      ),
    ],
    table: _day7TableV1(
      hero: 'sb',
      hand: 'Ac Qc',
      street: PokerStreet.flop,
      actor: 'sb',
      board: _act0LessonCardsV1('As 7d 2h'),

      folded: const {'utg', 'hj', 'co', 'bb'},
      stacks: const {
        'utg': 65,
        'hj': 61,
        'co': 60,
        'btn': 35,
        'sb': 35,
        'bb': 50,
      },
      entries: const [
        ..._act0LessonBlinds,
        Act0ContributionV1(
          PokerStreet.preflop,
          'btn',
          Act0ContributionKindV1.wager,
          2.5,
        ),
        Act0ContributionV1(
          PokerStreet.preflop,
          'sb',
          Act0ContributionKindV1.wager,
          8.5,
        ),
        Act0ContributionV1(
          PokerStreet.preflop,
          'btn',
          Act0ContributionKindV1.wager,
          6.5,
        ),
      ],
      history: const [
        Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
        Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
        Act0ActionTrailItemV1(label: 'UTG folds'),
        Act0ActionTrailItemV1(label: 'HJ folds'),
        Act0ActionTrailItemV1(label: 'CO folds'),
        Act0ActionTrailItemV1(label: 'BTN raises to 2.5 BB'),
        Act0ActionTrailItemV1(label: 'SB raises to 9 BB'),
        Act0ActionTrailItemV1(label: 'BB folds'),
        Act0ActionTrailItemV1(label: 'BTN calls 6.5 BB more'),
        Act0ActionTrailItemV1(label: 'Flop is dealt'),
      ],
      bets: const {},
    ).copyWith(showDecisionPremise: true),
  ),
  _wave6AuthoredTaskV1(
    id: 'w11_checkpoint_review',
    lesson: 'real_play_transfer_checkpoint',
    lessonTitle: 'Real-play session checkpoint',
    title: 'Real-play recap',
    phase: Act0LessonPhaseV1.review,
    step: Act0LessonStepKindV1.proveIt,
    xp: 17,
    caption:
        'CO and BB start with 13 BB. Flop pot 6.5, with 10 left: SPR 1.5. CO goes all-in with 8x or 99 twice as often as sets. Assume TT wins 60% versus this mix.',
    question: 'Call or fold?',
    teach: '',
    choices: const [
      (
        'call_10_bb',
        'Call 10 BB',
        Act0FeedbackQualityV1.correct,
        'Your overpair wins 60% of the time in this model. The 10 BB call needs 37.7%, so calling has a strong edge.',
      ),
      (
        'fold',
        'Fold',
        Act0FeedbackQualityV1.wrong,
        'TT is an overpair on 8-5-2. The given 60% win chance is far above the 37.7% call price, so folding gives up value.',
      ),
    ],
    table: _day7TableV1(
      hero: 'bb',
      hand: 'Td Th',
      street: PokerStreet.flop,
      actor: 'bb',
      board: _act0LessonCardsV1('8c 5d 2s'),

      folded: const {'utg', 'hj', 'btn', 'sb'},
      stacks: const {
        'utg': 64,
        'hj': 60,
        'co': 13,
        'btn': 55,
        'sb': 54,
        'bb': 13,
      },
      entries: const [
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
          'co',
          Act0ContributionKindV1.wager,
          10,
        ),
      ],
      history: const [
        Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
        Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
        Act0ActionTrailItemV1(label: 'UTG folds'),
        Act0ActionTrailItemV1(label: 'HJ folds'),
        Act0ActionTrailItemV1(label: 'CO raises to 3 BB'),
        Act0ActionTrailItemV1(label: 'BTN folds'),
        Act0ActionTrailItemV1(label: 'SB folds'),
        Act0ActionTrailItemV1(label: 'BB calls 2 BB more'),
        Act0ActionTrailItemV1(label: 'Flop: BB checks'),
        Act0ActionTrailItemV1(label: 'CO all-in 10 BB'),
      ],
      bets: const {
        'co': Act0SeatBetStateV1(
          kind: Act0SeatBetKindV1.allIn,
          label: 'allIn',
          amountLabel: '10 BB',
        ),
      },
    ).copyWith(showDecisionPremise: true),
  ),
];

final _w11SessionPlanBankrollFollowupTasksV1 = <Act0LessonTaskV1>[
  _wave6AuthoredTaskV1(
    id: 'w11_bankroll_move_down',
    lesson: 'session_plan_bankroll_followup',
    lessonTitle: 'Keep the session plan',
    title: 'Check the limit after a loss',
    phase: Act0LessonPhaseV1.drill,
    step: Act0LessonStepKindV1.practice,
    xp: 10,
    caption: 'Your NL10 bankroll fell from \$420 to \$350.',
    question: 'What stake now meets the bankroll rule?',
    teach:
        'At NL10, \$10 is one full buy-in. At NL5, \$5 is one full buy-in. Use the same 40-buy-in rule after a losing week. Use the new balance, not the old one.',
    choices: const [
      (
        'stay_at_nl10_to_win_it_back',
        'Stay at NL10 to win it back',
        Act0FeedbackQualityV1.wrong,
        '35 NL10 buy-ins are short of the 40-buy-in floor. Chasing the loss adds risk.',
      ),
      (
        'move_to_nl25_for_a_faster_win',
        'Move to NL25 for a faster win',
        Act0FeedbackQualityV1.wrong,
        'A \$25 full buy-in means just 14 buy-ins at this bankroll. The risk is far above the plan.',
      ),
      (
        'move_to_nl5',
        'Move to NL5',
        Act0FeedbackQualityV1.correct,
        '\$350 is 70 NL5 buy-ins. It is 35 NL10 buy-ins, below the plan.',
      ),
    ],
    table: _wave6StudyTableV1,
  ),
  _wave6AuthoredTaskV1(
    id: 'w11_plan_table_focus_transfer',
    lesson: 'session_plan_bankroll_followup',
    lessonTitle: 'Keep the session plan',
    title: 'Real-table focus plan',
    phase: Act0LessonPhaseV1.drill,
    step: Act0LessonStepKindV1.proveIt,
    xp: 12,
    family: Act0TaskFamilyV1.transfer,
    caption:
        'Your session starts soon. You feel tired. Your notes show missed BB calls.',
    question: 'Which plan is easiest to use?',
    teach:
        'One focus is still useful when you are low on energy. State the cue in plain words. Note a hand for review. If you are too tired to read the table, you may skip the session.',
    choices: const [
      (
        'watch_six_leaks_and_play_a_full_session',
        'Watch six leaks and play a full session',
        Act0FeedbackQualityV1.wrong,
        'You are tired. Six live tasks add load and make it easy to miss the BB price.',
      ),
      (
        'play_with_no_cue_and_sort_it_out_later',
        'Play with no cue and sort it out later',
        Act0FeedbackQualityV1.suboptimal,
        'This feels simple, but it gives the review no test of the blind leak you chose.',
      ),
      (
        'check_bb_call_price_then_review_one_hand',
        'Check BB call price, then review one hand',
        Act0FeedbackQualityV1.correct,
        'The BB cue is clear. One saved choice makes the next review short and useful.',
      ),
    ],
    table: _wave6StudyTableV1,
  ),
  _wave6AuthoredTaskV1(
    id: 'w11_session_plan_recap',
    lesson: 'session_plan_bankroll_followup',
    lessonTitle: 'Keep the session plan',
    title: 'Session-plan recap',
    phase: Act0LessonPhaseV1.review,
    step: Act0LessonStepKindV1.review,
    xp: 16,
    caption: 'A session goal is a skill check, not a money target.',
    question: 'What should a good session leave behind?',
    teach:
        'Profit or loss from one session is not a skill grade. The hand you played and the reason for your choice matter more than the result.',
    choices: const [
      (
        'a_noted_choice_to_check_and_one_next_step',
        'A noted choice to check and one next step',
        Act0FeedbackQualityV1.correct,
        'A saved cue can turn a live error into a skill you test in a new hand.',
      ),
      (
        'a_profit_target_met',
        'A profit target met',
        Act0FeedbackQualityV1.wrong,
        'A winning session can still include poor calls. A cash result does not show a fixed leak.',
      ),
      (
        'a_long_list_of_new_plans',
        'A long list of new plans',
        Act0FeedbackQualityV1.suboptimal,
        'The notes may help later, but a long list makes the next session harder to focus.',
      ),
    ],
    table: _wave6StudyTableV1,
  ),
];

final _w11TableTriggerMultiwayAndSprTasksV1 = <Act0LessonTaskV1>[
  _wave6AuthoredTaskV1(
    id: 'w11_sb_isolate_limp',
    lesson: 'table_trigger_multiway_and_spr',
    lessonTitle: 'Multiway pots and stack depth',
    title: 'Sb isolate limp',
    phase: Act0LessonPhaseV1.drill,
    step: Act0LessonStepKindV1.practice,
    xp: 10,
    caption:
        'BTN limps, then calls raises with A8, A5 or QJ. BB usually folds to a raise.',
    question: 'How should you enter?',
    teach: '',
    choices: const [
      (
        'raise_to_4_bb',
        'Raise to 4 BB',
        Act0FeedbackQualityV1.correct,
        'AJs can get calls from A8, A5 and QJ. Raising to 4 BB can play a value pot with the loose BTN. A limp is a preflop call of the big blind. An isolation raise tries to play with that limper. Think about both the limper and the BB behind.',
      ),
      (
        'call_0_5_bb',
        'Call 0.5 BB',
        Act0FeedbackQualityV1.suboptimal,
        'A complete to 1 BB is cheap, but it lets BB check and see a three-way flop. You miss the weak BTN calls to a raise.',
      ),
      (
        'fold',
        'Fold',
        Act0FeedbackQualityV1.wrong,
        'AJs is Strong and leads the weak hands BTN has limp-called before. Folding gives up that value.',
      ),
    ],
    table: _day7TableV1(
      hero: 'sb',
      hand: 'Ad Jd',
      street: PokerStreet.preflop,
      actor: 'sb',

      folded: const {'utg', 'hj', 'co'},
      stacks: const {
        'utg': 65,
        'hj': 62,
        'co': 60,
        'btn': 55,
        'sb': 42,
        'bb': 48,
      },
      entries: const [
        ..._act0LessonBlinds,
        Act0ContributionV1(
          PokerStreet.preflop,
          'btn',
          Act0ContributionKindV1.wager,
          1,
        ),
      ],
      history: const [
        Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
        Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
        Act0ActionTrailItemV1(label: 'UTG folds'),
        Act0ActionTrailItemV1(label: 'HJ folds'),
        Act0ActionTrailItemV1(label: 'CO folds'),
        Act0ActionTrailItemV1(label: 'BTN calls 1 BB'),
      ],
      bets: const {
        'sb': Act0SeatBetStateV1(
          kind: Act0SeatBetKindV1.post,
          label: 'post',
          amountLabel: '0.5 BB',
        ),
        'bb': Act0SeatBetStateV1(
          kind: Act0SeatBetKindV1.post,
          label: 'post',
          amountLabel: '1 BB',
        ),
        'btn': Act0SeatBetStateV1(
          kind: Act0SeatBetKindV1.call,
          label: 'call',
          amountLabel: '1 BB',
        ),
      },
    ).copyWith(showDecisionPremise: true),
  ),
  _wave6AuthoredTaskV1(
    id: 'w11_bb_isolate_limp',
    lesson: 'table_trigger_multiway_and_spr',
    lessonTitle: 'Multiway pots and stack depth',
    title: 'Bb isolate limp',
    phase: Act0LessonPhaseV1.drill,
    step: Act0LessonStepKindV1.practice,
    xp: 10,
    caption: 'SB limps and calls small raises with K9, K8 or Q8.',
    question: 'Check or raise?',
    teach: '',
    choices: const [
      (
        'raise_to_4_bb',
        'Raise to 4 BB',
        Act0FeedbackQualityV1.correct,
        'KQs is ahead of the weak kings and queens SB calls with. A 4 BB raise can earn value from those hands. The BB can check for free after an SB limp. A raise costs more but can get calls from weaker hands. Judge the size by the limper read.',
      ),
      (
        'check',
        'Check',
        Act0FeedbackQualityV1.suboptimal,
        'Checking costs no more chips, but it gives K9 and Q8 a free flop. A value raise can get paid by them.',
      ),
      (
        'all_in_to_48_bb',
        'All-in to 48 BB',
        Act0FeedbackQualityV1.wrong,
        'The pot is 2 BB. A 48 BB all-in can scare off the worse hands and risks too much against SB strong hands.',
      ),
    ],
    table: _day7TableV1(
      hero: 'bb',
      hand: 'Ks Qs',
      street: PokerStreet.preflop,
      actor: 'bb',

      folded: const {'utg', 'hj', 'co', 'btn'},
      stacks: const {
        'utg': 62,
        'hj': 60,
        'co': 57,
        'btn': 54,
        'sb': 45,
        'bb': 48,
      },
      entries: const [
        ..._act0LessonBlinds,
        Act0ContributionV1(
          PokerStreet.preflop,
          'sb',
          Act0ContributionKindV1.wager,
          0.5,
        ),
      ],
      history: const [
        Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
        Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
        Act0ActionTrailItemV1(label: 'UTG folds'),
        Act0ActionTrailItemV1(label: 'HJ folds'),
        Act0ActionTrailItemV1(label: 'CO folds'),
        Act0ActionTrailItemV1(label: 'BTN folds'),
        Act0ActionTrailItemV1(label: 'SB calls 0.5 BB more'),
      ],
      bets: const {
        'sb': Act0SeatBetStateV1(
          kind: Act0SeatBetKindV1.call,
          label: 'call',
          amountLabel: '1 BB',
        ),
        'bb': Act0SeatBetStateV1(
          kind: Act0SeatBetKindV1.post,
          label: 'post',
          amountLabel: '1 BB',
        ),
      },
    ).copyWith(showDecisionPremise: true),
  ),
  _w11_first_in_seat,
  _wave6AuthoredTaskV1(
    id: 'w11_multiway_top_pair_fold',
    lesson: 'table_trigger_multiway_and_spr',
    lessonTitle: 'Multiway pots and stack depth',
    title: 'Multiway top pair fold',
    phase: Act0LessonPhaseV1.drill,
    step: Act0LessonStepKindV1.practice,
    xp: 10,
    caption:
        'UTG bets 6. CO raises to 18. Its last seven flop raises showed sets or two pair.',
    question: 'What should you do?',
    teach: '',
    choices: const [
      (
        'fold',
        'Fold',
        Act0FeedbackQualityV1.correct,
        'KQ is top pair, but CO raises with sets and two pair. Calling 18 needs at least 36% wins and UTG can act again. Three players can see the flop, but more than one foe can hold a strong hand. A raise after a bet may leave the first bettor able to act again. A small call price is not the full story.',
      ),
      (
        'call_18_bb',
        'Call 18 BB',
        Act0FeedbackQualityV1.wrong,
        'KQ loses to the shown raises. The price is 18/50=36% before more action from UTG. A call puts a lot at risk.',
      ),
      (
        'all_in_to_52_5_bb',
        'All-in to 52.5 BB',
        Act0FeedbackQualityV1.wrong,
        'Your top pair is behind CO value raises. Going all-in can get calls from better hands.',
      ),
    ],
    table: _day7TableV1(
      hero: 'bb',
      hand: 'Kd Qc',
      street: PokerStreet.flop,
      actor: 'bb',
      board: _act0LessonCardsV1('Kh 9h 8d'),

      folded: const {'hj', 'btn', 'sb'},
      stacks: const {
        'utg': 72,
        'hj': 68,
        'co': 62,
        'btn': 60,
        'sb': 57,
        'bb': 55,
      },
      entries: const [
        ..._act0LessonBlinds,
        Act0ContributionV1(
          PokerStreet.preflop,
          'utg',
          Act0ContributionKindV1.wager,
          2.5,
        ),
        Act0ContributionV1(
          PokerStreet.preflop,
          'co',
          Act0ContributionKindV1.wager,
          2.5,
        ),
        Act0ContributionV1(
          PokerStreet.preflop,
          'bb',
          Act0ContributionKindV1.wager,
          1.5,
        ),
        Act0ContributionV1(
          PokerStreet.flop,
          'utg',
          Act0ContributionKindV1.wager,
          6,
        ),
        Act0ContributionV1(
          PokerStreet.flop,
          'co',
          Act0ContributionKindV1.wager,
          18,
        ),
      ],
      history: const [
        Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
        Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
        Act0ActionTrailItemV1(label: 'UTG raises to 2.5 BB'),
        Act0ActionTrailItemV1(label: 'HJ folds'),
        Act0ActionTrailItemV1(label: 'CO calls 2.5 BB'),
        Act0ActionTrailItemV1(label: 'BTN folds'),
        Act0ActionTrailItemV1(label: 'SB folds'),
        Act0ActionTrailItemV1(label: 'BB calls 1.5 BB more'),
        Act0ActionTrailItemV1(label: 'Flop: BB checks'),
        Act0ActionTrailItemV1(label: 'UTG bets 6 BB'),
        Act0ActionTrailItemV1(label: 'CO raises to 18 BB'),
      ],
      bets: const {
        'utg': Act0SeatBetStateV1(
          kind: Act0SeatBetKindV1.bet,
          label: 'bet',
          amountLabel: '6 BB',
        ),
        'co': Act0SeatBetStateV1(
          kind: Act0SeatBetKindV1.raise,
          label: 'raise',
          amountLabel: '18 BB',
        ),
      },
    ).copyWith(showDecisionPremise: true),
  ),
  _wave6AuthoredTaskV1(
    id: 'w11_multiway_dirty_outs',
    lesson: 'table_trigger_multiway_and_spr',
    lessonTitle: 'Multiway pots and stack depth',
    title: 'Multiway dirty outs',
    phase: Act0LessonPhaseV1.drill,
    step: Act0LessonStepKindV1.practice,
    xp: 10,
    caption:
        'CO bets 2.5 and shows 6s 6d. If you call, the river checks through.',
    question: 'How do the clean outs affect your call or fold?',
    teach: '',
    choices: const [
      (
        'fold',
        'Fold',
        Act0FeedbackQualityV1.suboptimal,
        'The set cuts your heart outs from nine to seven. Even so, 15.9% wins beats the 14.3% call price. A fold gives up about 0.28 BB.',
      ),
      (
        'raise_to_10_bb',
        'Raise to 10 BB',
        Act0FeedbackQualityV1.wrong,
        'CO has a set and will call a raise in this drill. Raising risks more chips while if 2h or 4h comes on the river, the flush loses to a full house.',
      ),
      (
        'call_2_5_bb',
        'Call 2.5 BB',
        Act0FeedbackQualityV1.correct,
        'You have 7 clean hearts. If the river is 2h or 4h, CO makes a full house. You win on 7/44 = 15.9% of rivers; the call needs 14.3%. An out is a river card that can make you win. A flush draw has up to nine hearts. Some hearts may pair the board and give a set a full house. Count clean outs before you check the price. Three players saw the flop. CO has a set, and you have a heart draw.',
      ),
    ],
    table: _day7TableV1(
      hero: 'bb',
      hand: '9h 8h',
      street: PokerStreet.turn,
      actor: 'bb',
      board: _act0LessonCardsV1('Ah 6h 2c 4c'),
      shown: {'co': _act0LessonCardsV1('6s 6d')},
      folded: const {'utg', 'hj', 'sb', 'btn'},
      stacks: const {
        'utg': 63,
        'hj': 58,
        'co': 60,
        'btn': 55,
        'sb': 54,
        'bb': 50,
      },
      entries: const [
        ..._act0LessonBlinds,
        Act0ContributionV1(
          PokerStreet.preflop,
          'co',
          Act0ContributionKindV1.wager,
          2,
        ),
        Act0ContributionV1(
          PokerStreet.preflop,
          'btn',
          Act0ContributionKindV1.wager,
          2,
        ),
        Act0ContributionV1(
          PokerStreet.preflop,
          'bb',
          Act0ContributionKindV1.wager,
          1,
        ),
        Act0ContributionV1(
          PokerStreet.flop,
          'co',
          Act0ContributionKindV1.wager,
          2,
        ),
        Act0ContributionV1(
          PokerStreet.flop,
          'btn',
          Act0ContributionKindV1.wager,
          2,
        ),
        Act0ContributionV1(
          PokerStreet.flop,
          'bb',
          Act0ContributionKindV1.wager,
          2,
        ),
        Act0ContributionV1(
          PokerStreet.turn,
          'co',
          Act0ContributionKindV1.wager,
          2.5,
        ),
      ],
      history: const [
        Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
        Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
        Act0ActionTrailItemV1(label: 'UTG folds'),
        Act0ActionTrailItemV1(label: 'HJ folds'),
        Act0ActionTrailItemV1(label: 'CO raises to 2 BB'),
        Act0ActionTrailItemV1(label: 'BTN calls 2 BB'),
        Act0ActionTrailItemV1(label: 'SB folds'),
        Act0ActionTrailItemV1(label: 'BB calls 1 BB more'),
        Act0ActionTrailItemV1(label: 'Flop: BB checks'),
        Act0ActionTrailItemV1(label: 'CO bets 2 BB'),
        Act0ActionTrailItemV1(label: 'BTN calls 2 BB'),
        Act0ActionTrailItemV1(label: 'BB calls 2 BB'),
        Act0ActionTrailItemV1(label: 'Turn: BB checks'),
        Act0ActionTrailItemV1(label: 'CO bets 2.5 BB'),
        Act0ActionTrailItemV1(label: 'BTN folds'),
      ],
      bets: const {
        'co': Act0SeatBetStateV1(
          kind: Act0SeatBetKindV1.bet,
          label: 'bet',
          amountLabel: '2.5 BB',
        ),
      },
    ).copyWith(showDecisionPremise: true),
  ),
  _wave6AuthoredTaskV1(
    id: 'w11_spr_low_overpair',
    lesson: 'table_trigger_multiway_and_spr',
    lessonTitle: 'Multiway pots and stack depth',
    title: 'Spr low overpair',
    phase: Act0LessonPhaseV1.drill,
    step: Act0LessonStepKindV1.practice,
    xp: 10,
    caption:
        'Flop SPR is 2.1. BB goes all-in with 8x or 99 four times as often as sets. Assume JJ wins 65%.',
    question: 'Call or fold at this SPR?',
    teach: '',
    choices: const [
      (
        'call_11_5_bb',
        'Call 11.5 BB',
        Act0FeedbackQualityV1.correct,
        'An overpair is above the top board card. Your 65% wins beat the 40.4% call price, so calling earns 7.03 BB on average. At a low SPR, a bet can put most of the stack at risk. Compare what the hand may beat with the final pot and call cost. SPR by itself is not a call signal. Both started with 14 BB. With 11.5 behind and 5.5 in the middle, SPR was about 2.1.',
      ),
      (
        'fold',
        'Fold',
        Act0FeedbackQualityV1.wrong,
        'JJ beats many 8x and 99 hands in this all-in range. A 65% chance clears the 40.4% call cost by a large gap.',
      ),
    ],
    table: _day7TableV1(
      hero: 'hj',
      hand: 'Jc Jh',
      street: PokerStreet.flop,
      actor: 'hj',
      board: _act0LessonCardsV1('8d 5s 2c'),

      folded: const {'utg', 'co', 'btn', 'sb'},
      stacks: const {
        'utg': 63,
        'hj': 14,
        'co': 55,
        'btn': 50,
        'sb': 45,
        'bb': 14,
      },
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
        Act0ContributionV1(
          PokerStreet.flop,
          'bb',
          Act0ContributionKindV1.wager,
          11.5,
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
        Act0ActionTrailItemV1(label: 'BB calls 1.5 BB more'),
        Act0ActionTrailItemV1(label: 'Flop: BB all-in 11.5 BB'),
      ],
      bets: const {
        'bb': Act0SeatBetStateV1(
          kind: Act0SeatBetKindV1.allIn,
          label: 'allIn',
          amountLabel: '11.5 BB',
        ),
      },
    ).copyWith(showDecisionPremise: true),
  ),
  _wave6AuthoredTaskV1(
    id: 'w11_spr_high_top_pair',
    lesson: 'table_trigger_multiway_and_spr',
    lessonTitle: 'Multiway pots and stack depth',
    title: 'Spr high top pair',
    phase: Act0LessonPhaseV1.drill,
    step: Act0LessonStepKindV1.practice,
    xp: 10,
    caption:
        'Flop SPR is 17.7. BB raises 3 BB to 12. Its last seven flop raises showed sets or two pair.',
    question: 'Call or fold?',
    teach: '',
    choices: const [
      (
        'fold',
        'Fold',
        Act0FeedbackQualityV1.correct,
        'AQ is top pair, but the seven raised hands were sets or two pair. Saving 9 BB avoids a deep pot against better hands. A high SPR means more chips remain next to the pot. One pair may face large bets on later streets. Read what hands a flop raise may mean before you grow the pot. Both started with 100 BB. With 97.5 behind and 5.5 in the middle, the flop SPR was about 17.7.',
      ),
      (
        'call_9_bb',
        'Call 9 BB',
        Act0FeedbackQualityV1.wrong,
        'A call needs 30.5% wins before later bets. AQ has too few clean ways to beat this strong raise range on A-9-6.',
      ),
      (
        'raise_to_35_bb',
        'Raise to 35 BB',
        Act0FeedbackQualityV1.wrong,
        'A large re-raise drives the pot up at SPR 17.7. BB strong flop-raise range is likely to call with better hands.',
      ),
    ],
    table: _day7TableV1(
      hero: 'btn',
      hand: 'Ad Qc',
      street: PokerStreet.flop,
      actor: 'btn',
      board: _act0LessonCardsV1('As 9h 6d'),

      folded: const {'utg', 'hj', 'co', 'sb'},
      stacks: const {
        'utg': 65,
        'hj': 62,
        'co': 60,
        'btn': 100,
        'sb': 54,
        'bb': 100,
      },
      entries: const [
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
          1.5,
        ),
        Act0ContributionV1(
          PokerStreet.flop,
          'btn',
          Act0ContributionKindV1.wager,
          3,
        ),
        Act0ContributionV1(
          PokerStreet.flop,
          'bb',
          Act0ContributionKindV1.wager,
          12,
        ),
      ],
      history: const [
        Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
        Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
        Act0ActionTrailItemV1(label: 'UTG folds'),
        Act0ActionTrailItemV1(label: 'HJ folds'),
        Act0ActionTrailItemV1(label: 'CO folds'),
        Act0ActionTrailItemV1(label: 'BTN raises to 2.5 BB'),
        Act0ActionTrailItemV1(label: 'SB folds'),
        Act0ActionTrailItemV1(label: 'BB calls 1.5 BB more'),
        Act0ActionTrailItemV1(label: 'Flop: BB checks'),
        Act0ActionTrailItemV1(label: 'BTN bets 3 BB'),
        Act0ActionTrailItemV1(label: 'BB raises to 12 BB'),
      ],
      bets: const {
        'btn': Act0SeatBetStateV1(
          kind: Act0SeatBetKindV1.bet,
          label: 'bet',
          amountLabel: '3 BB',
        ),
        'bb': Act0SeatBetStateV1(
          kind: Act0SeatBetKindV1.raise,
          label: 'raise',
          amountLabel: '12 BB',
        ),
      },
    ).copyWith(showDecisionPremise: true),
  ),
  _wave6AuthoredTaskV1(
    id: 'w11_trigger_recap',
    lesson: 'table_trigger_multiway_and_spr',
    lessonTitle: 'Multiway pots and stack depth',
    title: 'Trigger recap',
    phase: Act0LessonPhaseV1.review,
    step: Act0LessonStepKindV1.review,
    xp: 16,
    caption: 'One table cue leads to one small change.',
    question: 'A new large turn bet calls for what check?',
    teach: '',
    choices: const [
      (
        'the_name_of_your_hand',
        'The name of your hand',
        Act0FeedbackQualityV1.wrong,
        'Top pair can win against bluffs and lose to a strong bet. The name alone does not set a call price.',
      ),
      (
        'price_and_the_player_read',
        'Price and the player read',
        Act0FeedbackQualityV1.correct,
        'A call for 2 BB and a call for 8 BB need different win chances. The player read helps you rate those chances. Price tells you what a call costs. SPR shows how large the stack is next to the pot. In multiway pots, more than one foe can have a strong hand.',
      ),
      (
        'the_last_pot_you_won',
        'The last pot you won',
        Act0FeedbackQualityV1.wrong,
        'A past result says little about the next bettor or the cost of a new call.',
      ),
    ],
    table: _wave6StudyTableV1,
  ),
  _wave6AuthoredTaskV1(
    id: 'w11_review_loop_intro',
    lesson: 'table_trigger_multiway_and_spr',
    lessonTitle: 'Multiway pots and stack depth',
    title: 'One leak one fix',
    phase: Act0LessonPhaseV1.theory,
    step: Act0LessonStepKindV1.learn,
    xp: 7,
    caption: 'Review one useful hand.',
    question: 'Which note is most useful?',
    teach: '',
    choices: const [
      (
        'bb_called_8_into_18_versus_a_tight_turn_range',
        'BB called 8 into 18 versus a tight turn range',
        Act0FeedbackQualityV1.correct,
        'The note has a seat, cost and player clue. You can test the same skill in a new hand. Write the hand, seat, bet and price that led to the choice. Mark a repeat leak, not a loss from luck. Use the note to plan a new, fair test in a later hand.',
      ),
      (
        'lost_a_big_pot_and_felt_bad',
        'Lost a big pot and felt bad',
        Act0FeedbackQualityV1.wrong,
        'The loss says no bet size or price. It cannot show which call or fold needs work.',
      ),
      (
        'need_more_wins_next_time',
        'Need more wins next time',
        Act0FeedbackQualityV1.wrong,
        'A win target has no hand cue. It does not explain how to avoid the next price error.',
      ),
    ],
    table: _wave6StudyTableV1,
  ),
];

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
      Act0ActionTrailItemV1(
        label: 'BB calls 2.5 BB',
        displayLabel: 'BB calls 1.5 BB more',
      ),
    ],
    bets: const {},
  ).copyWith(showDecisionPremise: true),
);

final _w12_river_ev_costly_call = _w12Task(
  'w12_river_ev_costly_call',
  'A costly river call',
  'BB bets 5 BB. 1 in 5 bets is a bluff you beat. The rest beat your kings. BB folds the bluffs to a raise and calls with the better hands.',
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

Act0LessonTaskV1 _wave6Asm05CopyV1(
  Act0LessonTaskV1 source, {
  required String caption,
  required String question,
  required List<(String, String, Act0FeedbackQualityV1, String)> choices,
  required String teach,
}) {
  final authored = _wave6AuthoredChoicesV1(choices);
  return Act0LessonTaskV1(
    taskId: source.taskId,
    title: source.title,
    phase: source.phase,
    rewardXp: source.rewardXp,
    stepKind: source.stepKind,
    taskFamily: source.taskFamily,
    tablePresentation: source.tablePresentation,
    summary: source.summary,
    runner: source.runner.copyWith(
      caption: caption,
      question: question,
      options: [
        for (final outcome in source.runner.options)
          for (final option in authored.where(
            (choice) => choice.id == outcome.id,
          ))
            Act0RunnerOptionV1(
              id: option.id,
              label: option.label,
              isCorrect: outcome.isCorrect,
              preferredLabel: option.preferredLabel,
              quality: outcome.quality,
              feedbackTitle: outcome.feedbackTitle,
              feedbackReason: [
                outcome.feedbackReason,
                option.feedbackReason,
                if (outcome.isCorrect && teach.isNotEmpty) teach,
              ].join(' '),
            ),
      ],
    ),
  );
}

final _w12_turn_count_heart_outs = _w12Task(
  'w12_turn_count_heart_outs',
  'Count before the last card',
  'At the turn, you hold two hearts and see two more on the board. Recall how to count outs.',
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

final _w12DecisionOverOutcomeTasksV1 = <Act0LessonTaskV1>[
  _wave6AuthoredTaskV1(
    id: 'w12_decision_quality_intro',
    lesson: 'decision_over_outcome',
    lessonTitle: 'Decision quality over outcome',
    title: 'Process first',
    phase: Act0LessonPhaseV1.theory,
    step: Act0LessonStepKindV1.learn,
    xp: 7,
    caption: 'A good choice can lose. A poor choice can win.',
    question: 'What should you test after a lucky win?',
    teach:
        'EV means expected value: the average gain or loss over many repeats. An out is a card that makes a losing hand win. On the turn, count clean outs, not cards that help the other player more. A river call needs a win rate high enough for its price. A c-bet is a flop bet from the preflop raiser.',
    choices: const [
      (
        'the_price_and_range_you_faced',
        'The price and range you faced',
        Act0FeedbackQualityV1.correct,
        'A lucky river can hide a bad call. The old price and the likely hands decide if it had value.',
      ),
      (
        'the_size_of_the_pot_you_won',
        'The size of the pot you won',
        Act0FeedbackQualityV1.wrong,
        'A large pot can come from a weak call. Pot size alone does not show if the price was good.',
      ),
      (
        'how_happy_the_win_made_you',
        'How happy the win made you',
        Act0FeedbackQualityV1.wrong,
        'A good feeling is real, but it does not show if your hand had enough wins for the bet.',
      ),
    ],
    table: _wave6StudyTableV1,
  ),
  _wave6AuthoredTaskV1(
    id: 'w12_good_fold_bad_result',
    lesson: 'decision_over_outcome',
    lessonTitle: 'Decision quality over outcome',
    title: 'A new river decision',
    phase: Act0LessonPhaseV1.drill,
    step: Act0LessonStepKindV1.practice,
    xp: 10,
    caption:
        'Last orbit, BB showed a bluff after you folded. On this river BB bets 12 into 16. In 20 similar spots, BB had 3 missed KQ/QT and 17 Ax or sets. JJ beats the misses; it loses to the value hands.',
    question: 'Call or fold?',
    teach:
        'One shown card can help you learn. It does not replace a larger group of showdowns. On the river, there is no next card to save a weak call.',
    choices: const [
      (
        'call_12_bb',
        'Call 12 BB',
        Act0FeedbackQualityV1.wrong,
        'JJ loses to Ax and sets in 17 of 20 bets. The call loses 6 BB on average, even after last orbit\'s bluff.',
      ),
      (
        'raise_to_32_bb',
        'Raise to 32 BB',
        Act0FeedbackQualityV1.wrong,
        'JJ is a pair below the ace on board. A raise of 32 BB risks more chips against a range full of Ax and sets.',
      ),
      (
        'fold',
        'Fold',
        Act0FeedbackQualityV1.correct,
        'JJ needs 30% wins for a 12 BB call. It wins 15% of this bet range. One old bluff does not pay the price.',
      ),
    ],
    table: _day7TableV1(
      hero: 'hj',
      hand: 'Jc Jd',
      street: PokerStreet.river,
      actor: 'hj',
      board: _act0LessonCardsV1('As 8h 4d 2c 9s'),

      folded: const {'utg', 'co', 'btn', 'sb'},
      stacks: const {
        'utg': 75,
        'hj': 75,
        'co': 72,
        'btn': 78,
        'sb': 64,
        'bb': 80,
      },
      entries: const [
        ..._act0LessonBlinds,
        Act0ContributionV1(
          PokerStreet.preflop,
          'hj',
          Act0ContributionKindV1.wager,
          2,
        ),
        Act0ContributionV1(
          PokerStreet.preflop,
          'bb',
          Act0ContributionKindV1.wager,
          1,
        ),
        Act0ContributionV1(
          PokerStreet.flop,
          'hj',
          Act0ContributionKindV1.wager,
          3,
        ),
        Act0ContributionV1(
          PokerStreet.flop,
          'bb',
          Act0ContributionKindV1.wager,
          3,
        ),
        Act0ContributionV1(
          PokerStreet.turn,
          'hj',
          Act0ContributionKindV1.wager,
          2.75,
        ),
        Act0ContributionV1(
          PokerStreet.turn,
          'bb',
          Act0ContributionKindV1.wager,
          2.75,
        ),
        Act0ContributionV1(
          PokerStreet.river,
          'bb',
          Act0ContributionKindV1.wager,
          12,
        ),
      ],
      history: const [
        Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
        Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
        Act0ActionTrailItemV1(label: 'UTG folds'),
        Act0ActionTrailItemV1(label: 'HJ raises to 2 BB'),
        Act0ActionTrailItemV1(label: 'CO folds'),
        Act0ActionTrailItemV1(label: 'BTN folds'),
        Act0ActionTrailItemV1(label: 'SB folds'),
        Act0ActionTrailItemV1(label: 'BB calls 1 BB more'),
        Act0ActionTrailItemV1(label: 'Flop: BB checks'),
        Act0ActionTrailItemV1(label: 'HJ bets 3 BB'),
        Act0ActionTrailItemV1(label: 'BB calls 3 BB'),
        Act0ActionTrailItemV1(label: 'Turn: BB checks'),
        Act0ActionTrailItemV1(label: 'HJ bets 2.75 BB'),
        Act0ActionTrailItemV1(label: 'BB calls 2.75 BB'),
        Act0ActionTrailItemV1(label: 'River: BB bets 12 BB'),
      ],
      bets: const {
        'bb': Act0SeatBetStateV1(
          kind: Act0SeatBetKindV1.bet,
          label: 'bet',
          amountLabel: '12 BB',
        ),
      },
    ).copyWith(showDecisionPremise: true),
  ),
  _wave6AuthoredTaskV1(
    id: 'w12_bad_call_good_result',
    lesson: 'decision_over_outcome',
    lessonTitle: 'Decision quality over outcome',
    title: 'The next draw',
    phase: Act0LessonPhaseV1.drill,
    step: Act0LessonStepKindV1.practice,
    xp: 10,
    family: Act0TaskFamilyV1.transfer,
    signal: 'process_over_outcome',
    caption:
        'Last hand you called a costly draw bet and hit. This time BB shows Kc Kd: a set of kings. You have a heart draw on K-7-2-4. BB bets 12 into 10. If you call, both players check the river. No rake.',
    question: 'Call or fold?',
    teach:
        'A set is three cards of the same rank. If the board pairs, a set may make a full house. A past win does not make a future draw more likely.',
    choices: const [
      (
        'call_12_bb',
        'Call 12 BB',
        Act0FeedbackQualityV1.wrong,
        'Ah Th has 7 clean hearts. If the river is 2h or 4h, the set makes a full house. The 12 BB call loses about 6.59 BB.',
      ),
      (
        'fold',
        'Fold',
        Act0FeedbackQualityV1.correct,
        'Seven hearts win, out of 44 unseen cards. That is 15.9%, below the 35.3% call price. The last lucky win changes nothing.',
      ),
      (
        'all_in_to_75_25_bb',
        'All-in to 75.25 BB',
        Act0FeedbackQualityV1.wrong,
        'BB has a set of kings and will not fold in this model. Pushing your 75.25 BB adds far more risk to a draw with 7 clean outs.',
      ),
    ],
    table: _day7TableV1(
      hero: 'co',
      hand: 'Ah Th',
      street: PokerStreet.turn,
      actor: 'co',
      board: _act0LessonCardsV1('Kh 7h 2c 4d'),
      shown: {'bb': _act0LessonCardsV1('Kc Kd')},
      folded: const {'utg', 'hj', 'btn', 'sb'},
      stacks: const {
        'utg': 73,
        'hj': 64,
        'co': 80,
        'btn': 77,
        'sb': 70,
        'bb': 80,
      },
      entries: const [
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
          1.75,
        ),
        Act0ContributionV1(
          PokerStreet.flop,
          'co',
          Act0ContributionKindV1.wager,
          1.75,
        ),
        Act0ContributionV1(
          PokerStreet.turn,
          'bb',
          Act0ContributionKindV1.wager,
          12,
        ),
      ],
      history: const [
        Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
        Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
        Act0ActionTrailItemV1(label: 'UTG folds'),
        Act0ActionTrailItemV1(label: 'HJ folds'),
        Act0ActionTrailItemV1(label: 'CO raises to 3 BB'),
        Act0ActionTrailItemV1(label: 'BTN folds'),
        Act0ActionTrailItemV1(label: 'SB folds'),
        Act0ActionTrailItemV1(label: 'BB calls 2 BB more'),
        Act0ActionTrailItemV1(label: 'Flop: BB bets 1.75 BB'),
        Act0ActionTrailItemV1(label: 'CO calls 1.75 BB'),
        Act0ActionTrailItemV1(label: 'Turn: BB bets 12 BB'),
      ],
      bets: const {
        'bb': Act0SeatBetStateV1(
          kind: Act0SeatBetKindV1.bet,
          label: 'bet',
          amountLabel: '12 BB',
        ),
      },
    ).copyWith(showDecisionPremise: true),
  ),
  _wave6Asm05CopyV1(
    act0Asm05AuthoredDecisionTaskV1(
      exercise: Act0Asm05AuthoredExerciseV1.goodCallLoses(),
      lessonId: 'decision_over_outcome',
      lessonTitle: 'Decision quality over outcome',
      beatIndex: 4,
      beatCount: 6,
      rewardXp: 0,
      returnTarget: 'learn',
      nextLessonId: 'tilt_reset_protocol',
    ),
    caption:
        'SB shows As Ad (pocket aces). Other players folded without card clues; cards are random. SB bets 10 into 40. If you call, both check the river. Raises are excluded. No ante or rake.',
    question: 'Call or fold?',
    choices: const [
      (
        'call',
        'Call 10 BB',
        Act0FeedbackQualityV1.correct,
        'Nine hearts win out of 44 unknown cards. That is 20.5%, above the 16.7% price. The call gains 2.27 BB on average.',
      ),
      (
        'fold',
        'Fold',
        Act0FeedbackQualityV1.wrong,
        'The 10 BB price needs 16.7%. With 9 clean hearts, your 20.5% chance earns about 2.27 BB more than a fold.',
      ),
    ],
    teach:
        'On the turn, count the cards that win at showdown. Here the other four folded players gave no clues. The prior bet is gone in either choice.',
  ),
  _wave6Asm05CopyV1(
    act0Asm05AuthoredDecisionTaskV1(
      exercise: Act0Asm05AuthoredExerciseV1.badCallWins(),
      lessonId: 'decision_over_outcome',
      lessonTitle: 'Decision quality over outcome',
      beatIndex: 5,
      beatCount: 6,
      rewardXp: 0,
      returnTarget: 'learn',
      nextLessonId: 'tilt_reset_protocol',
    ),
    caption:
        'SB shows As Ad (pocket aces). Other players folded without card clues; cards are random. SB bets 40 into 40. If you call, both check the river. Raises are excluded. No ante or rake.',
    question: 'Call or fold?',
    choices: const [
      (
        'fold',
        'Fold',
        Act0FeedbackQualityV1.correct,
        'Nine hearts win out of 44 unknown cards. That is 20.5%, below the 33.3% price. The fold saves 15.45 BB of expected loss. On the turn, count the cards that win at showdown. Here the other four folded players gave no clues. The prior bet is gone in either choice.',
      ),
      (
        'call',
        'Call 40 BB',
        Act0FeedbackQualityV1.wrong,
        'The river heart came in once, but 35 of 44 cards still lose. This 40 BB call loses 15.45 BB on average.',
      ),
    ],
    teach: '',
  ),
  _w12_turn_count_heart_outs,
];

final _w12TiltResetProtocolTasksV1 = <Act0LessonTaskV1>[
  _wave6AuthoredTaskV1(
    id: 'w12_tilt_reset_intro',
    lesson: 'tilt_reset_protocol',
    lessonTitle: 'Tilt reset protocol',
    title: 'Reset in under 20s',
    phase: Act0LessonPhaseV1.theory,
    step: Act0LessonStepKindV1.learn,
    xp: 7,
    caption: 'What happened in the last hand can affect your next choice.',
    question: 'What can a reset protect?',
    teach:
        'Tilt is when anger, fear or stress starts to steer your play. A quick reset can protect the next hand. You can note the feeling, slow your next choice and check the table facts. If focus does not return, you can leave the session. A pause does not change pot odds.',
    choices: const [
      (
        'the_next_choice_from_the_last_hand_s_mood',
        'The next choice from the last hand\'s mood',
        Act0FeedbackQualityV1.correct,
        'The prior loss is over. A reset helps you read new cards and stakes without trying to get even.',
      ),
      (
        'the_stack_from_a_normal_bad_beat',
        'The stack from a normal bad beat',
        Act0FeedbackQualityV1.wrong,
        'A short pause cannot bring back lost chips. It helps stop a rushed next bet from losing more.',
      ),
      (
        'the_odds_on_the_next_board',
        'The odds on the next board',
        Act0FeedbackQualityV1.wrong,
        'The next cards do not change due to your mood. Only the care you take with the choice can change.',
      ),
    ],
    table: _wave6StudyTableV1,
  ),
  _wave6AuthoredTaskV1(
    id: 'w12_after_bad_beat_reset',
    lesson: 'tilt_reset_protocol',
    lessonTitle: 'Tilt reset protocol',
    title: 'After bad beat',
    phase: Act0LessonPhaseV1.drill,
    step: Act0LessonStepKindV1.practice,
    xp: 10,
    caption:
        'Last hand, your AA lost to KK after a preflop all-in. You feel angry. New hand: AQs on A-7-2. BB calls flop bets with weaker aces and 7x. Pot 5.5.',
    question: 'What is your flop action?',
    teach:
        'A lost all-in can make the next bet feel urgent. The new pot has its own hand, board and player read. A short pause is an option before a large choice.',
    choices: const [
      (
        'check_from_fear_of_another_loss',
        'Check from fear of another loss',
        Act0FeedbackQualityV1.suboptimal,
        'Checking keeps your 53.5 BB behind, but BB has weak aces and 7x that may pay a value bet now.',
      ),
      (
        'all_in_to_53_5_bb_to_win_back_chips',
        'All-in to 53.5 BB to win back chips',
        Act0FeedbackQualityV1.wrong,
        'You have top pair, not the nuts. A 53.5 BB all-in into 5.5 BB may fold weak calls and risk a lot against sets or two pair.',
      ),
      (
        'bet_3_bb_after_a_brief_reset',
        'Bet 3 BB after a brief reset',
        Act0FeedbackQualityV1.correct,
        'Your AQ has top pair with a queen kicker. BB may call 3 BB with worse aces and 7x; the last loss is not part of this pot.',
      ),
    ],
    table: _day7TableV1(
      hero: 'co',
      hand: 'Ah Qh',
      street: PokerStreet.flop,
      actor: 'co',
      board: _act0LessonCardsV1('As 7d 2c'),

      folded: const {'utg', 'hj', 'btn', 'sb'},
      stacks: const {
        'utg': 65,
        'hj': 60,
        'co': 56,
        'btn': 62,
        'sb': 53,
        'bb': 70,
      },
      entries: const [
        ..._act0LessonBlinds,
        Act0ContributionV1(
          PokerStreet.preflop,
          'co',
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
        Act0ActionTrailItemV1(label: 'HJ folds'),
        Act0ActionTrailItemV1(label: 'CO raises to 2.5 BB'),
        Act0ActionTrailItemV1(label: 'BTN folds'),
        Act0ActionTrailItemV1(label: 'SB folds'),
        Act0ActionTrailItemV1(label: 'BB calls 1.5 BB more'),
        Act0ActionTrailItemV1(label: 'Flop: BB checks'),
      ],
      bets: const {},
    ).copyWith(showDecisionPremise: true),
  ),
  _wave6AuthoredTaskV1(
    id: 'w12_after_mistake_reset',
    lesson: 'tilt_reset_protocol',
    lessonTitle: 'Tilt reset protocol',
    title: 'After your own mistake',
    phase: Act0LessonPhaseV1.drill,
    step: Act0LessonStepKindV1.practice,
    xp: 10,
    family: Act0TaskFamilyV1.transfer,
    caption:
        'Last hand you made a bad 12 BB river call. You wrote it down. New hand: TT in HJ with 35 BB. It is folded to you. No special player read.',
    question: 'What should you do preflop?',
    teach:
        'Log one past leak, then read the new deal. Use your normal hand chart and bet size unless this new spot gives a reason to change.',
    choices: const [
      (
        'raise_to_2_bb',
        'Raise to 2 BB',
        Act0FeedbackQualityV1.correct,
        'TT is Strong from HJ. A small open leaves 33 BB for the new pot; the last call has no say here.',
      ),
      (
        'raise_to_3_bb',
        'Raise to 3 BB',
        Act0FeedbackQualityV1.suboptimal,
        'TT is a sound HJ open, but 3 BB spends one more than the course size with no read to gain more folds or calls.',
      ),
      (
        'fold_to_avoid_another_error',
        'Fold to avoid another error',
        Act0FeedbackQualityV1.wrong,
        'TT is in the Strong HJ range. Folding because of a prior river loss gives up a sound open and lets fear set your next line.',
      ),
    ],
    table: _day7TableV1(
      hero: 'hj',
      hand: 'Ts Th',
      street: PokerStreet.preflop,
      actor: 'hj',

      folded: const {'utg'},
      stacks: const {
        'utg': 32,
        'hj': 35,
        'co': 38,
        'btn': 40,
        'sb': 35,
        'bb': 37,
      },
      entries: const [..._act0LessonBlinds],
      history: const [
        Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
        Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
        Act0ActionTrailItemV1(label: 'UTG folds'),
      ],
      bets: const {
        'sb': Act0SeatBetStateV1(
          kind: Act0SeatBetKindV1.post,
          label: 'post',
          amountLabel: '0.5 BB',
        ),
        'bb': Act0SeatBetStateV1(
          kind: Act0SeatBetKindV1.post,
          label: 'post',
          amountLabel: '1 BB',
        ),
      },
    ).copyWith(showDecisionPremise: true),
  ),
  _wave6AuthoredTaskV1(
    id: 'w12_tilt_reset_recap',
    lesson: 'tilt_reset_protocol',
    lessonTitle: 'Tilt reset protocol',
    title: 'Reset recap',
    phase: Act0LessonPhaseV1.review,
    step: Act0LessonStepKindV1.review,
    xp: 16,
    caption: 'A reset is a tool, not a rule to keep playing.',
    question: 'What if the next pot still feels rushed?',
    teach: '',
    choices: const [
      (
        'keep_playing_to_recover_a_lost_stack',
        'Keep playing to recover a lost stack',
        Act0FeedbackQualityV1.wrong,
        'A loss is not a debt due from the table. A rushed 12 BB call can add a second error.',
      ),
      (
        'sit_out_and_review_when_ready',
        'Sit out and review when ready',
        Act0FeedbackQualityV1.correct,
        'Stopping is better than making a forced large call while you cannot check the cards or price.',
      ),
      (
        'raise_the_next_hand_to_gain_control',
        'Raise the next hand to gain control',
        Act0FeedbackQualityV1.wrong,
        'An extra raise does not fix the past hand. It risks chips before you read the new seat and hand.',
      ),
    ],
    table: _wave6StudyTableV1,
  ),
];

final _w12ConfidenceAndDisciplineTasksV1 = <Act0LessonTaskV1>[
  _wave6AuthoredTaskV1(
    id: 'w12_confidence_intro',
    lesson: 'confidence_and_discipline',
    lessonTitle: 'Confidence with discipline',
    title: 'Calm assertive posture',
    phase: Act0LessonPhaseV1.theory,
    step: Act0LessonStepKindV1.learn,
    xp: 7,
    caption:
        'A river example starts with 16 BB in the middle. A rival adds 8 BB, making the pot 24 BB.',
    question: 'What is the call price?',
    teach:
        'Confidence does not mean a larger bet. Start by reading the chips already in the pot. Your own chips enter only if you call. An overpair is a pocket pair above the top board card. A bluff-catcher beats bluffs but loses to value hands. Call price equals the call divided by the pot after your call.',
    choices: const [
      (
        '25',
        '25%',
        Act0FeedbackQualityV1.correct,
        'The pot now has 24 BB. Calling 8 makes 32 BB. Your price is 8/32 = 25%.',
      ),
      (
        '33_3',
        '33.3%',
        Act0FeedbackQualityV1.wrong,
        'A call would make the 24 BB pot grow to 32 BB. Dividing by 24 leaves out your own call.',
      ),
      (
        '50',
        '50%',
        Act0FeedbackQualityV1.wrong,
        'Calling 8 BB can win more than 8. The final pot is 32 BB, so 50% is far too high.',
      ),
    ],
    table: _wave6StudyTableV1,
  ),
  _wave6AuthoredTaskV1(
    id: 'w12_assertive_not_ego',
    lesson: 'confidence_and_discipline',
    lessonTitle: 'Confidence with discipline',
    title: 'Assertive, not ego',
    phase: Act0LessonPhaseV1.drill,
    step: Act0LessonStepKindV1.practice,
    xp: 10,
    caption:
        'BB made fun of your last fold. New hand: 99 from CO with 35 BB. No strong read changes the course opening plan.',
    question: 'What is your preflop action?',
    teach:
        'Read your position and the hand chart before you act. A comment from a rival gives no new card or pot fact.',
    choices: const [
      (
        'raise_to_2_bb',
        'Raise to 2 BB',
        Act0FeedbackQualityV1.correct,
        '99 is a Medium CO opener. The 2 BB size takes a normal spot without reacting to BB\'s talk.',
      ),
      (
        'raise_to_3_bb',
        'Raise to 3 BB',
        Act0FeedbackQualityV1.suboptimal,
        '99 is worth opening from CO, but a 3 BB size adds 1 BB of risk with no read that calls for it.',
      ),
      (
        'all_in_to_35_bb',
        'All-in to 35 BB',
        Act0FeedbackQualityV1.wrong,
        '99 can open small in CO. Going all-in for 35 BB to prove a point risks the stack for a 1.5 BB pot.',
      ),
    ],
    table: _day7TableV1(
      hero: 'co',
      hand: '9s 9d',
      street: PokerStreet.preflop,
      actor: 'co',

      folded: const {'utg', 'hj'},
      stacks: const {
        'utg': 52,
        'hj': 46,
        'co': 35,
        'btn': 49,
        'sb': 43,
        'bb': 44,
      },
      entries: const [..._act0LessonBlinds],
      history: const [
        Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
        Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
        Act0ActionTrailItemV1(label: 'UTG folds'),
        Act0ActionTrailItemV1(label: 'HJ folds'),
      ],
      bets: const {
        'sb': Act0SeatBetStateV1(
          kind: Act0SeatBetKindV1.post,
          label: 'post',
          amountLabel: '0.5 BB',
        ),
        'bb': Act0SeatBetStateV1(
          kind: Act0SeatBetKindV1.post,
          label: 'post',
          amountLabel: '1 BB',
        ),
      },
    ).copyWith(showDecisionPremise: true),
  ),
  _wave6AuthoredTaskV1(
    id: 'w12_discipline_under_pressure',
    lesson: 'confidence_and_discipline',
    lessonTitle: 'Confidence with discipline',
    title: 'Discipline under pressure',
    phase: Act0LessonPhaseV1.drill,
    step: Act0LessonStepKindV1.practice,
    xp: 10,
    family: Act0TaskFamilyV1.transfer,
    caption:
        'Late in your session, BTN bets 9 into 12 on A-8-4-2-9. Its range is 45% missed KQ/QJ and 55% AK/AQ/sets. Your AJ beats the misses and loses to value. No ties.',
    question: 'Call or fold?',
    teach:
        'Fatigue can speed up a large choice. A brief pause can help you read the bet size and the set of hands that bet. Stop if you cannot do that.',
    choices: const [
      (
        'fold_to_end_the_session',
        'Fold to end the session',
        Act0FeedbackQualityV1.wrong,
        'Your AJ beats 45% of the bets, well above the 30% price. A tired fold gives up 4.5 BB of call value.',
      ),
      (
        'raise_to_25_bb',
        'Raise to 25 BB',
        Act0FeedbackQualityV1.wrong,
        'AJ can catch missed hands for 9 BB. A raise may fold the misses and meet calls from AK, AQ or sets.',
      ),
      (
        'call_9_bb',
        'Call 9 BB',
        Act0FeedbackQualityV1.correct,
        'The price is 9/30=30%. AJ wins 45% of these river bets, so calling earns 4.5 BB on average.',
      ),
    ],
    table: _day7TableV1(
      hero: 'bb',
      hand: 'Ac Jd',
      street: PokerStreet.river,
      actor: 'bb',
      board: _act0LessonCardsV1('Ah 8c 4s 2d 9h'),

      folded: const {'utg', 'hj', 'co', 'sb'},
      stacks: const {
        'utg': 70,
        'hj': 66,
        'co': 62,
        'btn': 75,
        'sb': 65,
        'bb': 65,
      },
      entries: const [
        ..._act0LessonBlinds,
        Act0ContributionV1(
          PokerStreet.preflop,
          'btn',
          Act0ContributionKindV1.wager,
          2,
        ),
        Act0ContributionV1(
          PokerStreet.preflop,
          'bb',
          Act0ContributionKindV1.wager,
          1,
        ),
        Act0ContributionV1(
          PokerStreet.flop,
          'btn',
          Act0ContributionKindV1.wager,
          2,
        ),
        Act0ContributionV1(
          PokerStreet.flop,
          'bb',
          Act0ContributionKindV1.wager,
          2,
        ),
        Act0ContributionV1(
          PokerStreet.turn,
          'btn',
          Act0ContributionKindV1.wager,
          1.75,
        ),
        Act0ContributionV1(
          PokerStreet.turn,
          'bb',
          Act0ContributionKindV1.wager,
          1.75,
        ),
        Act0ContributionV1(
          PokerStreet.river,
          'btn',
          Act0ContributionKindV1.wager,
          9,
        ),
      ],
      history: const [
        Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
        Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
        Act0ActionTrailItemV1(label: 'UTG folds'),
        Act0ActionTrailItemV1(label: 'HJ folds'),
        Act0ActionTrailItemV1(label: 'CO folds'),
        Act0ActionTrailItemV1(label: 'BTN raises to 2 BB'),
        Act0ActionTrailItemV1(label: 'SB folds'),
        Act0ActionTrailItemV1(label: 'BB calls 1 BB more'),
        Act0ActionTrailItemV1(label: 'Flop: BB checks'),
        Act0ActionTrailItemV1(label: 'BTN bets 2 BB'),
        Act0ActionTrailItemV1(label: 'BB calls 2 BB'),
        Act0ActionTrailItemV1(label: 'Turn: BB checks'),
        Act0ActionTrailItemV1(label: 'BTN bets 1.75 BB'),
        Act0ActionTrailItemV1(label: 'BB calls 1.75 BB'),
        Act0ActionTrailItemV1(label: 'River: BB checks'),
        Act0ActionTrailItemV1(label: 'BTN bets 9 BB'),
      ],
      bets: const {
        'btn': Act0SeatBetStateV1(
          kind: Act0SeatBetKindV1.bet,
          label: 'bet',
          amountLabel: '9 BB',
        ),
      },
    ).copyWith(showDecisionPremise: true),
  ),
];

final _w12MindsetBridgeCheckpointTasksV1 = <Act0LessonTaskV1>[
  _wave6AuthoredTaskV1(
    id: 'w12_checkpoint_intro',
    lesson: 'mindset_bridge_checkpoint',
    lessonTitle: 'Mindset bridge checkpoint',
    title: 'Mindset routine map',
    phase: Act0LessonPhaseV1.drill,
    step: Act0LessonStepKindV1.learn,
    xp: 7,
    caption: 'Five new hands check process, mood and price.',
    question: 'Which fact belongs to the new hand?',
    teach: '',
    choices: const [
      (
        'the_current_pot_and_amount_to_call',
        'The current pot and amount to call',
        Act0FeedbackQualityV1.correct,
        'Those numbers set the price. Last hand\'s chips are not part of this new bet.',
      ),
      (
        'the_win_or_loss_in_the_prior_orbit',
        'The win or loss in the prior orbit',
        Act0FeedbackQualityV1.wrong,
        'A prior result may affect your mood, but it does not change the current pot price.',
      ),
      (
        'how_much_you_want_to_win_this_hour',
        'How much you want to win this hour',
        Act0FeedbackQualityV1.wrong,
        'A cash goal does not change the hand range or how often a river call wins.',
      ),
    ],
    table: _wave6StudyTableV1,
  ),
  _wave6AuthoredTaskV1(
    id: 'w12_checkpoint_process_line',
    lesson: 'mindset_bridge_checkpoint',
    lessonTitle: 'Mindset bridge checkpoint',
    title: 'Process line',
    phase: Act0LessonPhaseV1.drill,
    step: Act0LessonStepKindV1.practice,
    xp: 10,
    signal: 'process_over_outcome',
    caption:
        'Last orbit, a similar call lost. New hand: BB bets 7 into 14 on Q-9-4-2-3. BB has value Qx/sets 60% and missed AJ/KT 40%. Your 77 beats the missed hands and loses to value. No ties.',
    question: 'Call or fold?',
    teach: '',
    choices: const [
      (
        'fold_after_last_orbit_s_loss',
        'Fold after last orbit\'s loss',
        Act0FeedbackQualityV1.wrong,
        'The old loss is done. Here 40% wins beat a 25% price, so folding misses 4.2 BB of expected call value.',
      ),
      (
        'raise_to_25_bb',
        'Raise to 25 BB',
        Act0FeedbackQualityV1.wrong,
        'A 7 BB call beats the missed AJ and KT. Raising may drive off those hands and face calls from Qx or sets.',
      ),
      (
        'call_7_bb',
        'Call 7 BB',
        Act0FeedbackQualityV1.correct,
        'Your 77 wins 40% of the river bets. The price is 7/28=25%, so calling gains 4.2 BB on average.',
      ),
    ],
    table: _day7TableV1(
      hero: 'co',
      hand: '7c 7d',
      street: PokerStreet.river,
      actor: 'co',
      board: _act0LessonCardsV1('Qh 9c 4d 2s 3h'),

      folded: const {'utg', 'hj', 'btn', 'sb'},
      stacks: const {
        'utg': 75,
        'hj': 75,
        'co': 70,
        'btn': 68,
        'sb': 65,
        'bb': 75,
      },
      entries: const [
        ..._act0LessonBlinds,
        Act0ContributionV1(
          PokerStreet.preflop,
          'co',
          Act0ContributionKindV1.wager,
          2,
        ),
        Act0ContributionV1(
          PokerStreet.preflop,
          'bb',
          Act0ContributionKindV1.wager,
          1,
        ),
        Act0ContributionV1(
          PokerStreet.flop,
          'co',
          Act0ContributionKindV1.wager,
          2.75,
        ),
        Act0ContributionV1(
          PokerStreet.flop,
          'bb',
          Act0ContributionKindV1.wager,
          2.75,
        ),
        Act0ContributionV1(
          PokerStreet.turn,
          'co',
          Act0ContributionKindV1.wager,
          2,
        ),
        Act0ContributionV1(
          PokerStreet.turn,
          'bb',
          Act0ContributionKindV1.wager,
          2,
        ),
        Act0ContributionV1(
          PokerStreet.river,
          'bb',
          Act0ContributionKindV1.wager,
          7,
        ),
      ],
      history: const [
        Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
        Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
        Act0ActionTrailItemV1(label: 'UTG folds'),
        Act0ActionTrailItemV1(label: 'HJ folds'),
        Act0ActionTrailItemV1(label: 'CO raises to 2 BB'),
        Act0ActionTrailItemV1(label: 'BTN folds'),
        Act0ActionTrailItemV1(label: 'SB folds'),
        Act0ActionTrailItemV1(label: 'BB calls 1 BB more'),
        Act0ActionTrailItemV1(label: 'Flop: BB checks'),
        Act0ActionTrailItemV1(label: 'CO bets 2.75 BB'),
        Act0ActionTrailItemV1(label: 'BB calls 2.75 BB'),
        Act0ActionTrailItemV1(label: 'Turn: BB checks'),
        Act0ActionTrailItemV1(label: 'CO bets 2 BB'),
        Act0ActionTrailItemV1(label: 'BB calls 2 BB'),
        Act0ActionTrailItemV1(label: 'River: BB bets 7 BB'),
      ],
      bets: const {
        'bb': Act0SeatBetStateV1(
          kind: Act0SeatBetKindV1.bet,
          label: 'bet',
          amountLabel: '7 BB',
        ),
      },
    ).copyWith(showDecisionPremise: true),
  ),
  _wave6AuthoredTaskV1(
    id: 'w12_checkpoint_reset_line',
    lesson: 'mindset_bridge_checkpoint',
    lessonTitle: 'Mindset bridge checkpoint',
    title: 'Reset line',
    phase: Act0LessonPhaseV1.drill,
    step: Act0LessonStepKindV1.practice,
    xp: 10,
    caption:
        'You lost two large pots and want to get even. New hand: UTG raises to 3 with QQ+/AK. You have QJo in CO and 28 BB; BTN and both blinds act after you, and UTG can still respond to a raise.',
    question: 'What should you do?',
    teach: '',
    choices: const [
      (
        'fold',
        'Fold',
        Act0FeedbackQualityV1.correct,
        'QJo is far behind UTG\'s QQ+/AK. A reset keeps your 28 BB for a better spot.',
      ),
      (
        'call_3_bb_to_win_chips_back',
        'Call 3 BB to win chips back',
        Act0FeedbackQualityV1.wrong,
        'QJo faces QQ+/AK with players behind. Paying 3 BB to chase the past loss risks a dominated flop hand.',
      ),
      (
        'all_in_to_28_bb',
        'All-in to 28 BB',
        Act0FeedbackQualityV1.wrong,
        'The UTG range is strong and can call. Going all-in with QJo risks 28 BB into a 4.5 BB pot with little fold pressure.',
      ),
    ],
    table: _day7TableV1(
      hero: 'co',
      hand: 'Qs Jd',
      street: PokerStreet.preflop,
      actor: 'co',

      folded: const {'hj'},
      stacks: const {
        'utg': 40,
        'hj': 45,
        'co': 28,
        'btn': 36,
        'sb': 32,
        'bb': 38,
      },
      entries: const [
        ..._act0LessonBlinds,
        Act0ContributionV1(
          PokerStreet.preflop,
          'utg',
          Act0ContributionKindV1.wager,
          3,
        ),
      ],
      history: const [
        Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
        Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
        Act0ActionTrailItemV1(label: 'UTG raises to 3 BB'),
        Act0ActionTrailItemV1(label: 'HJ folds'),
      ],
      bets: const {
        'sb': Act0SeatBetStateV1(
          kind: Act0SeatBetKindV1.post,
          label: 'post',
          amountLabel: '0.5 BB',
        ),
        'bb': Act0SeatBetStateV1(
          kind: Act0SeatBetKindV1.post,
          label: 'post',
          amountLabel: '1 BB',
        ),
        'utg': Act0SeatBetStateV1(
          kind: Act0SeatBetKindV1.raise,
          label: 'raise',
          amountLabel: '3 BB',
        ),
      },
    ).copyWith(showDecisionPremise: true),
  ),
  _wave6AuthoredTaskV1(
    id: 'w12_checkpoint_discipline_line',
    lesson: 'mindset_bridge_checkpoint',
    lessonTitle: 'Mindset bridge checkpoint',
    title: 'Discipline line',
    phase: Act0LessonPhaseV1.drill,
    step: Act0LessonStepKindV1.practice,
    xp: 10,
    caption:
        'You feel tired. BTN bets 16 into 12 on K-7-2-9-4. In this line, BTN has 12% missed JT and 88% AK, K9 or sets. Your KQ beats the misses and loses to value.',
    question: 'Call or fold?',
    teach: '',
    choices: const [
      (
        'call_16_bb',
        'Call 16 BB',
        Act0FeedbackQualityV1.wrong,
        'The pot is 28 BB after the bet. KQ beats the 12% bluffs but not AK, K9 or sets. A 16 BB call loses 10.72 BB.',
      ),
      (
        'fold',
        'Fold',
        Act0FeedbackQualityV1.correct,
        'KQ wins 12% of the range. The price for 16 BB is 36.4%, so a tired call would lose about 10.72 BB.',
      ),
      (
        'raise_to_40_bb',
        'Raise to 40 BB',
        Act0FeedbackQualityV1.wrong,
        'KQ has top pair, but this BTN range is 88% value. Raising to 40 BB risks extra chips into hands that beat you.',
      ),
    ],
    table: _day7TableV1(
      hero: 'bb',
      hand: 'Kd Qs',
      street: PokerStreet.river,
      actor: 'bb',
      board: _act0LessonCardsV1('Kh 7c 2d 9s 4c'),

      folded: const {'utg', 'hj', 'co', 'sb'},
      stacks: const {
        'utg': 78,
        'hj': 72,
        'co': 73,
        'btn': 77,
        'sb': 69,
        'bb': 70,
      },
      entries: const [
        ..._act0LessonBlinds,
        Act0ContributionV1(
          PokerStreet.preflop,
          'btn',
          Act0ContributionKindV1.wager,
          2,
        ),
        Act0ContributionV1(
          PokerStreet.preflop,
          'bb',
          Act0ContributionKindV1.wager,
          1,
        ),
        Act0ContributionV1(
          PokerStreet.flop,
          'btn',
          Act0ContributionKindV1.wager,
          2.25,
        ),
        Act0ContributionV1(
          PokerStreet.flop,
          'bb',
          Act0ContributionKindV1.wager,
          2.25,
        ),
        Act0ContributionV1(
          PokerStreet.turn,
          'btn',
          Act0ContributionKindV1.wager,
          1.5,
        ),
        Act0ContributionV1(
          PokerStreet.turn,
          'bb',
          Act0ContributionKindV1.wager,
          1.5,
        ),
        Act0ContributionV1(
          PokerStreet.river,
          'btn',
          Act0ContributionKindV1.wager,
          16,
        ),
      ],
      history: const [
        Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
        Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
        Act0ActionTrailItemV1(label: 'UTG folds'),
        Act0ActionTrailItemV1(label: 'HJ folds'),
        Act0ActionTrailItemV1(label: 'CO folds'),
        Act0ActionTrailItemV1(label: 'BTN raises to 2 BB'),
        Act0ActionTrailItemV1(label: 'SB folds'),
        Act0ActionTrailItemV1(label: 'BB calls 1 BB more'),
        Act0ActionTrailItemV1(label: 'Flop: BB checks'),
        Act0ActionTrailItemV1(label: 'BTN bets 2.25 BB'),
        Act0ActionTrailItemV1(label: 'BB calls 2.25 BB'),
        Act0ActionTrailItemV1(label: 'Turn: BB checks'),
        Act0ActionTrailItemV1(label: 'BTN bets 1.5 BB'),
        Act0ActionTrailItemV1(label: 'BB calls 1.5 BB'),
        Act0ActionTrailItemV1(label: 'River: BB checks'),
        Act0ActionTrailItemV1(label: 'BTN bets 16 BB'),
      ],
      bets: const {
        'btn': Act0SeatBetStateV1(
          kind: Act0SeatBetKindV1.bet,
          label: 'bet',
          amountLabel: '16 BB',
        ),
      },
    ).copyWith(showDecisionPremise: true),
  ),
  _wave6AuthoredTaskV1(
    id: 'w12_checkpoint_full_loop_line',
    lesson: 'mindset_bridge_checkpoint',
    lessonTitle: 'Mindset bridge checkpoint',
    title: 'Full routine line',
    phase: Act0LessonPhaseV1.drill,
    step: Act0LessonStepKindV1.practice,
    xp: 10,
    family: Act0TaskFamilyV1.transfer,
    caption:
        'Last orbit you made a loose bluff. Now you have AJs on A-8-4. CO bets 2 into 8. CO bets this size with weaker aces, draws and strong hands.',
    question: 'What is your flop action?',
    teach: '',
    choices: const [
      (
        'raise_to_8_bb_to_feel_in_control',
        'Raise to 8 BB to feel in control',
        Act0FeedbackQualityV1.suboptimal,
        'A raise with AJ may fold weak draws in this 10 BB pot. Calling for 2 BB keeps more of the mixed range in.',
      ),
      (
        'fold_to_avoid_a_new_error',
        'Fold to avoid a new error',
        Act0FeedbackQualityV1.wrong,
        'Your AJ has top pair and a low 2 BB price. Folding from regret gives up value against weak aces and draws.',
      ),
      (
        'call_2_bb',
        'Call 2 BB',
        Act0FeedbackQualityV1.correct,
        'AJs has top pair with a jack kicker. The 16.7% price is low; calling keeps weak aces and draws in.',
      ),
    ],
    table: _day7TableV1(
      hero: 'btn',
      hand: 'As Js',
      street: PokerStreet.flop,
      actor: 'btn',
      board: _act0LessonCardsV1('Ah 8h 4c'),

      folded: const {'utg', 'hj', 'sb', 'bb'},
      stacks: const {
        'utg': 80,
        'hj': 78,
        'co': 60,
        'btn': 35,
        'sb': 72,
        'bb': 70,
      },
      entries: const [
        ..._act0LessonBlinds,
        Act0ContributionV1(
          PokerStreet.preflop,
          'co',
          Act0ContributionKindV1.wager,
          3.25,
        ),
        Act0ContributionV1(
          PokerStreet.preflop,
          'btn',
          Act0ContributionKindV1.wager,
          3.25,
        ),
        Act0ContributionV1(
          PokerStreet.flop,
          'co',
          Act0ContributionKindV1.wager,
          2,
        ),
      ],
      history: const [
        Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
        Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
        Act0ActionTrailItemV1(label: 'UTG folds'),
        Act0ActionTrailItemV1(label: 'HJ folds'),
        Act0ActionTrailItemV1(label: 'CO raises to 3.25 BB'),
        Act0ActionTrailItemV1(label: 'BTN calls 3.25 BB'),
        Act0ActionTrailItemV1(label: 'SB folds'),
        Act0ActionTrailItemV1(label: 'BB folds'),
        Act0ActionTrailItemV1(label: 'Flop: CO bets 2 BB'),
      ],
      bets: const {
        'co': Act0SeatBetStateV1(
          kind: Act0SeatBetKindV1.bet,
          label: 'bet',
          amountLabel: '2 BB',
        ),
      },
    ).copyWith(showDecisionPremise: true),
  ),
  _wave6AuthoredTaskV1(
    id: 'w12_checkpoint_review',
    lesson: 'mindset_bridge_checkpoint',
    lessonTitle: 'Mindset bridge checkpoint',
    title: 'Mindset recap',
    phase: Act0LessonPhaseV1.review,
    step: Act0LessonStepKindV1.proveIt,
    xp: 17,
    family: Act0TaskFamilyV1.transfer,
    caption:
        'You have AT on A-9-6-3-2. The pot is 14. BB calls a 6 BB bet with A4, A5, A7, A8 and 9x. BB raises two pair or sets. You have not seen BB call a river all-in with weak hands.',
    question: 'What river action fits?',
    teach: '',
    choices: const [
      (
        'bet_6_bb',
        'Bet 6 BB',
        Act0FeedbackQualityV1.correct,
        'AT beats A4, A5, A7, A8 and 9x. The station can pay a 6 BB value bet with worse hands.',
      ),
      (
        'check',
        'Check',
        Act0FeedbackQualityV1.suboptimal,
        'Checking keeps the 14 BB pot, but this BB is set to call 6 BB with weaker aces and 9x.',
      ),
      (
        'all_in_to_53_25_bb',
        'All-in to 53.25 BB',
        Act0FeedbackQualityV1.wrong,
        'Going all-in can drive off the weak aces and 9x that pay 6 BB. It risks 53.25 BB against a range with sets and two pair.',
      ),
    ],
    table: _day7TableV1(
      hero: 'co',
      hand: 'Ac Tc',
      street: PokerStreet.river,
      actor: 'co',
      board: _act0LessonCardsV1('As 9d 6c 3h 2s'),

      folded: const {'utg', 'hj', 'btn', 'sb'},
      stacks: const {
        'utg': 80,
        'hj': 74,
        'co': 60,
        'btn': 70,
        'sb': 65,
        'bb': 66,
      },
      entries: const [
        ..._act0LessonBlinds,
        Act0ContributionV1(
          PokerStreet.preflop,
          'co',
          Act0ContributionKindV1.wager,
          2.5,
        ),
        Act0ContributionV1(
          PokerStreet.preflop,
          'bb',
          Act0ContributionKindV1.wager,
          1.5,
        ),
        Act0ContributionV1(
          PokerStreet.flop,
          'co',
          Act0ContributionKindV1.wager,
          2.25,
        ),
        Act0ContributionV1(
          PokerStreet.flop,
          'bb',
          Act0ContributionKindV1.wager,
          2.25,
        ),
        Act0ContributionV1(
          PokerStreet.turn,
          'co',
          Act0ContributionKindV1.wager,
          2,
        ),
        Act0ContributionV1(
          PokerStreet.turn,
          'bb',
          Act0ContributionKindV1.wager,
          2,
        ),
      ],
      history: const [
        Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
        Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
        Act0ActionTrailItemV1(label: 'UTG folds'),
        Act0ActionTrailItemV1(label: 'HJ folds'),
        Act0ActionTrailItemV1(label: 'CO raises to 2.5 BB'),
        Act0ActionTrailItemV1(label: 'BTN folds'),
        Act0ActionTrailItemV1(label: 'SB folds'),
        Act0ActionTrailItemV1(label: 'BB calls 1.5 BB more'),
        Act0ActionTrailItemV1(label: 'Flop: BB checks'),
        Act0ActionTrailItemV1(label: 'CO bets 2.25 BB'),
        Act0ActionTrailItemV1(label: 'BB calls 2.25 BB'),
        Act0ActionTrailItemV1(label: 'Turn: BB checks'),
        Act0ActionTrailItemV1(label: 'CO bets 2 BB'),
        Act0ActionTrailItemV1(label: 'BB calls 2 BB'),
        Act0ActionTrailItemV1(label: 'River: BB checks'),
      ],
      bets: const {},
    ).copyWith(showDecisionPremise: true),
  ),
];

final _w12DecisionPriceAndCleanOutsTasksV1 = <Act0LessonTaskV1>[
  _wave6AuthoredTaskV1(
    id: 'w12_clean_outs_vs_set',
    lesson: 'decision_price_and_clean_outs',
    lessonTitle: 'Price and clean outs',
    title: 'Read a turn draw',
    phase: Act0LessonPhaseV1.drill,
    step: Act0LessonStepKindV1.practice,
    xp: 10,
    caption:
        'SB shows 9d 9c: a set of nines. You have Ah Jh on 2h 7h 9s 3c. SB bets 2 into 12. If you call, both check the river. No rake.',
    question: 'Call or fold?',
    teach:
        'A flush is five cards of one suit. Nine hearts may finish a flush, yet some can make a set into a full house or quads. Count cards that win, then compare the bet.',
    choices: const [
      (
        'fold',
        'Fold',
        Act0FeedbackQualityV1.wrong,
        'With 7 clean hearts from 44, the draw wins 15.9%. Folding gives up about 0.55 BB of call value at this 2 BB price.',
      ),
      (
        'raise_to_10_bb',
        'Raise to 10 BB',
        Act0FeedbackQualityV1.wrong,
        'Your seven clean hearts give a fair 2 BB call. SB has a set and will not fold; raising to 10 spends 8 BB more with no added folds.',
      ),
      (
        'call_2_bb',
        'Call 2 BB',
        Act0FeedbackQualityV1.correct,
        'Nine hearts are unseen, but if 9h or 3h comes on the river, SB makes quads or a full house, respectively. Seven clean hearts beat the 12.5% call price.',
      ),
    ],
    table: _day7TableV1(
      hero: 'bb',
      hand: 'Ah Jh',
      street: PokerStreet.turn,
      actor: 'bb',
      board: _act0LessonCardsV1('2h 7h 9s 3c'),
      shown: {'sb': _act0LessonCardsV1('9d 9c')},
      folded: const {'utg', 'hj', 'co', 'btn'},
      stacks: const {
        'utg': 72,
        'hj': 70,
        'co': 67,
        'btn': 65,
        'sb': 68,
        'bb': 70,
      },
      entries: const [
        ..._act0LessonBlinds,
        Act0ContributionV1(
          PokerStreet.preflop,
          'sb',
          Act0ContributionKindV1.wager,
          2.5,
        ),
        Act0ContributionV1(
          PokerStreet.preflop,
          'bb',
          Act0ContributionKindV1.wager,
          2,
        ),
        Act0ContributionV1(
          PokerStreet.flop,
          'sb',
          Act0ContributionKindV1.wager,
          3,
        ),
        Act0ContributionV1(
          PokerStreet.flop,
          'bb',
          Act0ContributionKindV1.wager,
          3,
        ),
        Act0ContributionV1(
          PokerStreet.turn,
          'sb',
          Act0ContributionKindV1.wager,
          2,
        ),
      ],
      history: const [
        Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
        Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
        Act0ActionTrailItemV1(label: 'UTG folds'),
        Act0ActionTrailItemV1(label: 'HJ folds'),
        Act0ActionTrailItemV1(label: 'CO folds'),
        Act0ActionTrailItemV1(label: 'BTN folds'),
        Act0ActionTrailItemV1(label: 'SB raises to 3 BB'),
        Act0ActionTrailItemV1(label: 'BB calls 2 BB more'),
        Act0ActionTrailItemV1(label: 'Flop: SB bets 3 BB'),
        Act0ActionTrailItemV1(label: 'BB calls 3 BB'),
        Act0ActionTrailItemV1(label: 'Turn: SB bets 2 BB'),
      ],
      bets: const {
        'sb': Act0SeatBetStateV1(
          kind: Act0SeatBetKindV1.bet,
          label: 'bet',
          amountLabel: '2 BB',
        ),
      },
    ).copyWith(showDecisionPremise: true),
  ),
  _wave6AuthoredTaskV1(
    id: 'w12_river_price_call',
    lesson: 'decision_price_and_clean_outs',
    lessonTitle: 'Price and clean outs',
    title: 'River price',
    phase: Act0LessonPhaseV1.drill,
    step: Act0LessonStepKindV1.practice,
    xp: 10,
    caption:
        'CO bets 10 into 20 on K-8-4-2-9. This river range is 35% missed QJ/JT and 65% AK, K9 or 88. Your KQ beats the misses and loses to the value hands. No ties.',
    question: 'Call or fold?',
    teach:
        'Clean outs matter while another card can come. On the river the board is complete. A bluff-catcher beats bluffs but loses to value hands. Use the call price: divide the call by the pot after the bet and your call. Compare that price with the share of bluffs.',
    choices: const [
      (
        'fold',
        'Fold',
        Act0FeedbackQualityV1.wrong,
        'The bet makes the pot 30 BB. KQ beats the 35% missed hands, so folding gives up 4 BB of expected call value.',
      ),
      (
        'call_10_bb',
        'Call 10 BB',
        Act0FeedbackQualityV1.correct,
        'KQ wins 35% of this river range. A 10 BB call needs 25%. Its average gain is 4 BB.',
      ),
      (
        'raise_to_35_bb',
        'Raise to 35 BB',
        Act0FeedbackQualityV1.wrong,
        'KQ can catch missed QJ/JT for 10 BB. A raise to 35 may fold those bluffs and face calls from AK, K9 and 88.',
      ),
    ],
    table: _day7TableV1(
      hero: 'bb',
      hand: 'Kc Qd',
      street: PokerStreet.river,
      actor: 'bb',
      board: _act0LessonCardsV1('Ks 8c 4d 2h 9s'),

      folded: const {'utg', 'hj', 'btn', 'sb'},
      stacks: const {
        'utg': 70,
        'hj': 69,
        'co': 70,
        'btn': 65,
        'sb': 62,
        'bb': 70,
      },
      entries: const [
        ..._act0LessonBlinds,
        Act0ContributionV1(
          PokerStreet.preflop,
          'co',
          Act0ContributionKindV1.wager,
          2,
        ),
        Act0ContributionV1(
          PokerStreet.preflop,
          'bb',
          Act0ContributionKindV1.wager,
          1,
        ),
        Act0ContributionV1(
          PokerStreet.flop,
          'co',
          Act0ContributionKindV1.wager,
          3.75,
        ),
        Act0ContributionV1(
          PokerStreet.flop,
          'bb',
          Act0ContributionKindV1.wager,
          3.75,
        ),
        Act0ContributionV1(
          PokerStreet.turn,
          'co',
          Act0ContributionKindV1.wager,
          4,
        ),
        Act0ContributionV1(
          PokerStreet.turn,
          'bb',
          Act0ContributionKindV1.wager,
          4,
        ),
        Act0ContributionV1(
          PokerStreet.river,
          'co',
          Act0ContributionKindV1.wager,
          10,
        ),
      ],
      history: const [
        Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
        Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
        Act0ActionTrailItemV1(label: 'UTG folds'),
        Act0ActionTrailItemV1(label: 'HJ folds'),
        Act0ActionTrailItemV1(label: 'CO raises to 2 BB'),
        Act0ActionTrailItemV1(label: 'BTN folds'),
        Act0ActionTrailItemV1(label: 'SB folds'),
        Act0ActionTrailItemV1(label: 'BB calls 1 BB more'),
        Act0ActionTrailItemV1(label: 'Flop: BB checks'),
        Act0ActionTrailItemV1(label: 'CO bets 3.75 BB'),
        Act0ActionTrailItemV1(label: 'BB calls 3.75 BB'),
        Act0ActionTrailItemV1(label: 'Turn: BB checks'),
        Act0ActionTrailItemV1(label: 'CO bets 4 BB'),
        Act0ActionTrailItemV1(label: 'BB calls 4 BB'),
        Act0ActionTrailItemV1(label: 'River: BB checks'),
        Act0ActionTrailItemV1(label: 'CO bets 10 BB'),
      ],
      bets: const {
        'co': Act0SeatBetStateV1(
          kind: Act0SeatBetKindV1.bet,
          label: 'bet',
          amountLabel: '10 BB',
        ),
      },
    ).copyWith(showDecisionPremise: true),
  ),
  _w12_river_ev_costly_call,
  _wave6AuthoredTaskV1(
    id: 'w12_river_value_vs_caller',
    lesson: 'decision_price_and_clean_outs',
    lessonTitle: 'Price and clean outs',
    title: 'River value vs caller',
    phase: Act0LessonPhaseV1.drill,
    step: Act0LessonStepKindV1.practice,
    xp: 10,
    caption:
        'BB is a loose caller. BB calls a 6 BB river bet with A3, A5, A6, A8, 7x and 9x, but raises two pair or sets. You have AJ on A-7-2-4-9, with 14 BB in the pot.',
    question: 'What river action fits?',
    teach:
        'A value bet aims to get paid by a worse hand. A loose caller may pay with weak pairs. A large size can change which hands call. Plan the size before you bet.',
    choices: const [
      (
        'check',
        'Check',
        Act0FeedbackQualityV1.suboptimal,
        'A check keeps the 14 BB pot. It also misses a 6 BB call from weaker aces and pairs in BB\'s known range.',
      ),
      (
        'all_in_to_68_25_bb',
        'All-in to 68.25 BB',
        Act0FeedbackQualityV1.wrong,
        'BB calls small with weak pairs and raises with strong hands. Going all-in for 68.25 BB may drive off weaker hands and risk too much against sets or two pair.',
      ),
      (
        'bet_6_bb',
        'Bet 6 BB',
        Act0FeedbackQualityV1.correct,
        'AJ beats A3, A5, A6 and A8, 7x and 9x. A 6 BB value bet can get calls from worse while the bet stays small.',
      ),
    ],
    table: _day7TableV1(
      hero: 'hj',
      hand: 'Ac Jc',
      street: PokerStreet.river,
      actor: 'hj',
      board: _act0LessonCardsV1('As 7d 2c 4s 9h'),

      folded: const {'utg', 'co', 'btn', 'sb'},
      stacks: const {
        'utg': 75,
        'hj': 75,
        'co': 68,
        'btn': 62,
        'sb': 65,
        'bb': 80,
      },
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
        Act0ContributionV1(
          PokerStreet.flop,
          'hj',
          Act0ContributionKindV1.wager,
          2.25,
        ),
        Act0ContributionV1(
          PokerStreet.flop,
          'bb',
          Act0ContributionKindV1.wager,
          2.25,
        ),
        Act0ContributionV1(
          PokerStreet.turn,
          'hj',
          Act0ContributionKindV1.wager,
          2,
        ),
        Act0ContributionV1(
          PokerStreet.turn,
          'bb',
          Act0ContributionKindV1.wager,
          2,
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
        Act0ActionTrailItemV1(label: 'BB calls 1.5 BB more'),
        Act0ActionTrailItemV1(label: 'Flop: BB checks'),
        Act0ActionTrailItemV1(label: 'HJ bets 2.25 BB'),
        Act0ActionTrailItemV1(label: 'BB calls 2.25 BB'),
        Act0ActionTrailItemV1(label: 'Turn: BB checks'),
        Act0ActionTrailItemV1(label: 'HJ bets 2 BB'),
        Act0ActionTrailItemV1(label: 'BB calls 2 BB'),
        Act0ActionTrailItemV1(label: 'River: BB checks'),
      ],
      bets: const {},
    ).copyWith(showDecisionPremise: true),
  ),
  _wave6AuthoredTaskV1(
    id: 'w12_river_draw_missed',
    lesson: 'decision_price_and_clean_outs',
    lessonTitle: 'Price and clean outs',
    title: 'River draw missed',
    phase: Act0LessonPhaseV1.drill,
    step: Act0LessonStepKindV1.practice,
    xp: 10,
    caption:
        'Your Qh Jh missed a flush on A-8-4-2-9. The pot is 14. BTN calls river bets 80% with a pair and folds 20% missed low draws. Your queen-high beats the low draws if you check.',
    question: 'What is your river action?',
    teach:
        'A draw can miss. On the river there are no outs left. A bluff wins when the other player folds. Check the fold rate and the amount at risk.',
    choices: const [
      (
        'check',
        'Check',
        Act0FeedbackQualityV1.correct,
        'There is no card left to make your flush. Checking can win versus weak missed draws and avoids a poor bluff into the 80% call rate.',
      ),
      (
        'bet_6_bb',
        'Bet 6 BB',
        Act0FeedbackQualityV1.wrong,
        'With 14 BB in the pot, a 6 BB pure bluff needs 30% folds. BTN folds 20%, so it loses about 2 BB as a bluff.',
      ),
      (
        'bet_12_bb',
        'Bet 12 BB',
        Act0FeedbackQualityV1.wrong,
        'The same 20% folds cannot pay for a 12 BB bluff into 14. The bet needs 46.2% folds before other effects.',
      ),
    ],
    table: _day7TableV1(
      hero: 'sb',
      hand: 'Qh Jh',
      street: PokerStreet.river,
      actor: 'sb',
      board: _act0LessonCardsV1('Ah 8h 4c 2s 9d'),

      folded: const {'utg', 'hj', 'co', 'bb'},
      stacks: const {
        'utg': 65,
        'hj': 63,
        'co': 60,
        'btn': 70,
        'sb': 70,
        'bb': 66,
      },
      entries: const [
        ..._act0LessonBlinds,
        Act0ContributionV1(
          PokerStreet.preflop,
          'btn',
          Act0ContributionKindV1.wager,
          2,
        ),
        Act0ContributionV1(
          PokerStreet.preflop,
          'sb',
          Act0ContributionKindV1.wager,
          1.5,
        ),
        Act0ContributionV1(
          PokerStreet.flop,
          'btn',
          Act0ContributionKindV1.wager,
          2.5,
        ),
        Act0ContributionV1(
          PokerStreet.flop,
          'sb',
          Act0ContributionKindV1.wager,
          2.5,
        ),
        Act0ContributionV1(
          PokerStreet.turn,
          'btn',
          Act0ContributionKindV1.wager,
          2,
        ),
        Act0ContributionV1(
          PokerStreet.turn,
          'sb',
          Act0ContributionKindV1.wager,
          2,
        ),
      ],
      history: const [
        Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
        Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
        Act0ActionTrailItemV1(label: 'UTG folds'),
        Act0ActionTrailItemV1(label: 'HJ folds'),
        Act0ActionTrailItemV1(label: 'CO folds'),
        Act0ActionTrailItemV1(label: 'BTN raises to 2 BB'),
        Act0ActionTrailItemV1(label: 'SB calls 1.5 BB more'),
        Act0ActionTrailItemV1(label: 'BB folds'),
        Act0ActionTrailItemV1(label: 'Flop: SB checks'),
        Act0ActionTrailItemV1(label: 'BTN bets 2.5 BB'),
        Act0ActionTrailItemV1(label: 'SB calls 2.5 BB'),
        Act0ActionTrailItemV1(label: 'Turn: SB checks'),
        Act0ActionTrailItemV1(label: 'BTN bets 2 BB'),
        Act0ActionTrailItemV1(label: 'SB calls 2 BB'),
        Act0ActionTrailItemV1(label: 'River is dealt'),
      ],
      bets: const {},
    ).copyWith(showDecisionPremise: true),
  ),
  _wave6AuthoredTaskV1(
    id: 'w12_decision_quality_recap',
    lesson: 'decision_price_and_clean_outs',
    lessonTitle: 'Price and clean outs',
    title: 'Process recap',
    phase: Act0LessonPhaseV1.review,
    step: Act0LessonStepKindV1.review,
    xp: 16,
    caption: 'One lucky river does not rewrite the call price.',
    question: 'Which review uses the right evidence?',
    teach: '',
    choices: const [
      (
        'mark_the_40_bb_draw_call_right_after_a_heart',
        'Mark the 40 BB draw call right after a heart',
        Act0FeedbackQualityV1.wrong,
        'The nine winning hearts did not change. The 40 BB bet still cost too much for those odds.',
      ),
      (
        'compare_the_call_price_with_wins_in_the_range',
        'Compare the call price with wins in the range',
        Act0FeedbackQualityV1.correct,
        'The 10 BB draw call gained value and the 40 BB draw call lost value with the same nine outs.',
      ),
      (
        'judge_a_fold_by_the_next_shown_card',
        'Judge a fold by the next shown card',
        Act0FeedbackQualityV1.wrong,
        'A shown bluff from BB cannot erase the other 17 value bets in the record. The decision still needs a range read.',
      ),
    ],
    table: _wave6StudyTableV1,
  ),
];

final _w12ConfidenceRiverDisciplineTasksV1 = <Act0LessonTaskV1>[
  _wave6AuthoredTaskV1(
    id: 'w12_pretty_hand_bad_price_fold',
    lesson: 'confidence_river_discipline',
    lessonTitle: 'River discipline',
    title: 'Top pair under pressure',
    phase: Act0LessonPhaseV1.drill,
    step: Act0LessonStepKindV1.practice,
    xp: 10,
    family: Act0TaskFamilyV1.transfer,
    caption:
        'Tight CO bets 18 into 20 on K-7-2-9-4. Of 20 such river bets, one was missed JT and 19 were AK, K9 or sets. Your KQ beats JT and loses to the value hands.',
    question: 'Call or fold?',
    teach:
        'Top pair is one pair made with the highest board rank. It is not a set or an overpair. A pretty hand still needs enough wins to pay for a river bet.',
    choices: const [
      (
        'call_18_bb',
        'Call 18 BB',
        Act0FeedbackQualityV1.wrong,
        'KQ is top pair but loses to 19 of 20 betting hands. At 18 BB to call, the average loss is 15.2 BB.',
      ),
      (
        'fold',
        'Fold',
        Act0FeedbackQualityV1.correct,
        'KQ wins 5% of this river bet range. A call needs 32.1%. You save 15.2 BB of expected loss.',
      ),
      (
        'raise_to_45_bb',
        'Raise to 45 BB',
        Act0FeedbackQualityV1.wrong,
        'CO bets 18 with strong hands 95% of the time. Raising KQ risks more than calling and may fold the rare missed JT.',
      ),
    ],
    table: _day7TableV1(
      hero: 'btn',
      hand: 'Kd Qc',
      street: PokerStreet.river,
      actor: 'btn',
      board: _act0LessonCardsV1('Kh 7c 2d 9s 4c'),

      folded: const {'utg', 'hj', 'sb', 'bb'},
      stacks: const {
        'utg': 85,
        'hj': 86,
        'co': 90,
        'btn': 100,
        'sb': 95,
        'bb': 80,
      },
      entries: const [
        ..._act0LessonBlinds,
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
        Act0ContributionV1(
          PokerStreet.flop,
          'co',
          Act0ContributionKindV1.wager,
          3.5,
        ),
        Act0ContributionV1(
          PokerStreet.flop,
          'btn',
          Act0ContributionKindV1.wager,
          3.5,
        ),
        Act0ContributionV1(
          PokerStreet.turn,
          'co',
          Act0ContributionKindV1.wager,
          3.25,
        ),
        Act0ContributionV1(
          PokerStreet.turn,
          'btn',
          Act0ContributionKindV1.wager,
          3.25,
        ),
        Act0ContributionV1(
          PokerStreet.river,
          'co',
          Act0ContributionKindV1.wager,
          18,
        ),
      ],
      history: const [
        Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
        Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
        Act0ActionTrailItemV1(label: 'UTG folds'),
        Act0ActionTrailItemV1(label: 'HJ folds'),
        Act0ActionTrailItemV1(label: 'CO raises to 2.5 BB'),
        Act0ActionTrailItemV1(label: 'BTN calls 2.5 BB'),
        Act0ActionTrailItemV1(label: 'SB folds'),
        Act0ActionTrailItemV1(label: 'BB folds'),
        Act0ActionTrailItemV1(label: 'Flop: CO bets 3.5 BB'),
        Act0ActionTrailItemV1(label: 'BTN calls 3.5 BB'),
        Act0ActionTrailItemV1(label: 'Turn: CO bets 3.25 BB'),
        Act0ActionTrailItemV1(label: 'BTN calls 3.25 BB'),
        Act0ActionTrailItemV1(label: 'River: CO bets 18 BB'),
      ],
      bets: const {
        'co': Act0SeatBetStateV1(
          kind: Act0SeatBetKindV1.bet,
          label: 'bet',
          amountLabel: '18 BB',
        ),
      },
    ).copyWith(showDecisionPremise: true),
  ),
  _wave6AuthoredTaskV1(
    id: 'w12_revenge_raise_trap',
    lesson: 'confidence_river_discipline',
    lessonTitle: 'River discipline',
    title: 'Do not raise to take control',
    phase: Act0LessonPhaseV1.drill,
    step: Act0LessonStepKindV1.practice,
    xp: 10,
    family: Act0TaskFamilyV1.transfer,
    caption:
        'CO bluffed you last orbit and made a joke about it. New hand: your QJs has top pair on J-7-4. CO bets 2 into 8 with some missed overcards and better pairs.',
    question: 'What is your flop action?',
    teach:
        'A 3-bet means a preflop raise over an open raise. Here CO made a normal open, not a 3-bet. A past bluff does not prove that a new flop bet is weak.',
    choices: const [
      (
        'raise_to_7_bb',
        'Raise to 7 BB',
        Act0FeedbackQualityV1.suboptimal,
        'The small CO bet contains missed hands. Raising to 7 BB may fold those hands and grow the pot against AJ, QQ and sets.',
      ),
      (
        'all_in_to_36_75_bb',
        'All-in to 36.75 BB',
        Act0FeedbackQualityV1.wrong,
        'Going all-in for 36.75 BB with top pair QJ can fold bluffs but get action from better pairs or sets.',
      ),
      (
        'call_2_bb',
        'Call 2 BB',
        Act0FeedbackQualityV1.correct,
        'QJ is top pair with a queen kicker. Calling costs 16.7% of the final 12 BB pot and keeps CO\'s weak bets in.',
      ),
    ],
    table: _day7TableV1(
      hero: 'btn',
      hand: 'Qs Js',
      street: PokerStreet.flop,
      actor: 'btn',
      board: _act0LessonCardsV1('Jh 7c 4d'),

      folded: const {'utg', 'hj', 'sb', 'bb'},
      stacks: const {
        'utg': 65,
        'hj': 61,
        'co': 55,
        'btn': 40,
        'sb': 63,
        'bb': 60,
      },
      entries: const [
        ..._act0LessonBlinds,
        Act0ContributionV1(
          PokerStreet.preflop,
          'co',
          Act0ContributionKindV1.wager,
          3.25,
        ),
        Act0ContributionV1(
          PokerStreet.preflop,
          'btn',
          Act0ContributionKindV1.wager,
          3.25,
        ),
        Act0ContributionV1(
          PokerStreet.flop,
          'co',
          Act0ContributionKindV1.wager,
          2,
        ),
      ],
      history: const [
        Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
        Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
        Act0ActionTrailItemV1(label: 'UTG folds'),
        Act0ActionTrailItemV1(label: 'HJ folds'),
        Act0ActionTrailItemV1(label: 'CO raises to 3.25 BB'),
        Act0ActionTrailItemV1(label: 'BTN calls 3.25 BB'),
        Act0ActionTrailItemV1(label: 'SB folds'),
        Act0ActionTrailItemV1(label: 'BB folds'),
        Act0ActionTrailItemV1(label: 'Flop: CO bets 2 BB'),
      ],
      bets: const {
        'co': Act0SeatBetStateV1(
          kind: Act0SeatBetKindV1.bet,
          label: 'bet',
          amountLabel: '2 BB',
        ),
      },
    ).copyWith(showDecisionPremise: true),
  ),
  _w12_confidence_spr,
  _wave6AuthoredTaskV1(
    id: 'w12_confidence_recap',
    lesson: 'confidence_river_discipline',
    lessonTitle: 'River discipline',
    title: 'Confidence recap',
    phase: Act0LessonPhaseV1.review,
    step: Act0LessonStepKindV1.review,
    xp: 16,
    caption: 'Calm play still takes good chances.',
    question: 'What should stay the same after a taunt?',
    teach: '',
    choices: const [
      (
        'your_table_based_choice_process',
        'Your table-based choice process',
        Act0FeedbackQualityV1.correct,
        '99 from CO still has a normal open; QJ on J-7-4 still needs a read before a large raise.',
      ),
      (
        'the_bet_size_used_by_your_rival',
        'The bet size used by your rival',
        Act0FeedbackQualityV1.wrong,
        'A rival\'s taunt does not make a big bet a good response. Going all-in for 35 BB with 99 adds needless risk.',
      ),
      (
        'the_choice_to_avoid_that_player',
        'The choice to avoid that player',
        Act0FeedbackQualityV1.suboptimal,
        'A calmer seat plan can help, but folding good CO opens gives up value from a fear of table talk.',
      ),
    ],
    table: _wave6StudyTableV1,
  ),
];

part of 'act0_shell_state_v1.dart';

final _firstTableGuideReadTableRecheckRunner = _w1TableReadTransferRunner.copyWith(
  lessonId: 'what_poker_is_table_read_recheck',
  lessonTitle: 'What poker is',
  lessonSubtitle: 'Poker from Zero',
  caption: 'Read the cards and pot shown in this hand.',
  hint: 'Read your cards, the shared board, and the pot before any action.',
  question: 'What is the clean table read here?',
  feedbackTitle: 'Same scan, new spot.',
  feedbackReason:
      'You repeated the table scan: your cards, shared board, then pot.',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'two_three_four',
      label: '2 private cards, 3 board cards, 4 BB in the pot',
      isCorrect: true,
      preferredLabel: '2 private cards, 3 board cards, 4 BB in the pot',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Clean table read.',
      feedbackReason:
          'Same scan, new numbers: you have two private cards, the board has three shared cards, and the pot is 4 BB.',
      repairFocusCardIds: <String>[
        'hero_0',
        'hero_1',
        'board_0',
        'board_1',
        'board_2',
      ],
      repairFocusLabels: <String>['Your cards', 'Board cards', 'Pot 4 BB'],
    ),
    Act0RunnerOptionV1(
      id: 'five_board_cards',
      label: '5 board cards are out',
      isCorrect: false,
      preferredLabel: '2 private cards, 3 board cards, 4 BB in the pot',
      betterAnswerLabel: '2 private cards, 3 board cards, 4 BB in the pot',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason: 'Only three shared cards are visible in the middle here.',
      repairFocusCardIds: <String>[
        'hero_0',
        'hero_1',
        'board_0',
        'board_1',
        'board_2',
      ],
      repairFocusLabels: <String>['Your cards', 'Board cards', 'Pot 4 BB'],
    ),
    Act0RunnerOptionV1(
      id: 'hero_cards_only',
      label: 'Check your two cards and skip the board',
      isCorrect: false,
      preferredLabel: '2 private cards, 3 board cards, 4 BB in the pot',
      betterAnswerLabel: '2 private cards, 3 board cards, 4 BB in the pot',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Read the board and pot too.',
      feedbackReason:
          'Your cards matter, but the clean table read also includes the shared board and the pot.',
      repairFocusCardIds: <String>[
        'hero_0',
        'hero_1',
        'board_0',
        'board_1',
        'board_2',
      ],
      repairFocusLabels: <String>['Your cards', 'Board cards', 'Pot 4 BB'],
    ),
  ],
  table: _readBoardRunner.table.copyWith(
    handContributions: _act0FourPlayerLimpedPot,
    heroCards: _heroQqCards,
    boardCards: _flopA72Cards,
    centerLabel: 'Read hand, board, pot',
    potLabel: 'Pot 4 BB',
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
      title: 'Repeat the same scan.',
      body: 'Read your cards, the board, and the pot.',
      focusCardIds: <String>[
        'hero_0',
        'hero_1',
        'board_0',
        'board_1',
        'board_2',
      ],
      focusLabels: <String>['2 private', '3 board', 'Pot 4 BB'],
    ),
  ],
);

final _w1LiveWinTransferRunner = _winWaysRunner.copyWith(
  lessonId: 'w1_live_win_transfer',
  lessonTitle: 'What poker is',
  lessonSubtitle: 'Poker from Zero',
  caption: 'You are on the Button. The blinds have posted.',
  hint: 'After the first read, remember how this pot can still finish.',
  question: 'In this live hand, what can still decide the pot?',
  feedbackTitle: 'That is the live loop.',
  feedbackReason:
      'A real hand still ends the same two clean ways: everyone else folds, or players reach showdown and the best hand wins.',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'fold_or_showdown',
      label: 'A fold or a showdown',
      isCorrect: true,
      preferredLabel: 'A fold or a showdown',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Exactly.',
      feedbackReason:
          'You win early if all other players fold. If the hand reaches showdown, the strongest eligible hand wins. Tied winners share the pot.',
    ),
    Act0RunnerOptionV1(
      id: 'button_wins_now',
      label: 'The button wins right away',
      isCorrect: false,
      preferredLabel: 'A fold or a showdown',
      betterAnswerLabel: 'A fold or a showdown',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'One more read.',
      feedbackReason:
          'The Button usually acts late. The hand still decides who wins.',
    ),
    Act0RunnerOptionV1(
      id: 'hero_cards_decide_now',
      label: 'Your cards decide it immediately',
      isCorrect: false,
      preferredLabel: 'A fold or a showdown',
      betterAnswerLabel: 'A fold or a showdown',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'The hand is still live.',
      feedbackReason:
          'Your cards matter if the hand reaches showdown, but the pot can still end earlier when everyone else folds.',
    ),
  ],
  table: _tableObjectsRunner.table.copyWith(
    centerLabel: 'BTN, blinds, pot',
    potLabel: 'Pot 1.5 BB',
    selectableSeatIds: const <String>[],
    highlightedSeatIds: const <String>['btn', 'sb', 'bb'],
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Real hand, same endings.',
      body:
          'Even in a real hand, the pot still ends one of two ways: everyone else folds, or players reach showdown.',
      focusLabels: <String>['Fold', 'Showdown', 'Pot 1.5 BB'],
    ),
  ],
);

final _firstTableGuideMeetTableRunner = _meetTableRunner.copyWith(
  lessonId: 'first_table_guide_meet_table',
  lessonTitle: 'Your cards and the board',
  lessonSubtitle: 'Read one spot, answer once, and see why.',
  beatIndex: 1,
  beatCount: 5,
  caption: 'A new hand.',
  hint: 'Find the seat with two visible cards.',
  question: 'Which two cards are yours?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'top',
      label: 'Upper seat',
      seatId: 'utg',
      isCorrect: false,
      preferredLabel: 'Bottom seat',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Where are the visible cards?',
      feedbackReason: 'The two face-up cards are at the bottom.',
    ),
    Act0RunnerOptionV1(
      id: 'bottom',
      label: 'Bottom seat',
      seatId: 'btn',
      isCorrect: true,
      preferredLabel: 'Bottom seat',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Your cards found.',
      feedbackReason: 'The two cards at the bottom belong to you.',
    ),
    Act0RunnerOptionV1(
      id: 'random',
      label: 'Side seat',
      seatId: 'bb',
      isCorrect: false,
      preferredLabel: 'Bottom seat',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Look for the face-up cards.',
      feedbackReason: 'The side seat belongs to another player.',
    ),
  ],
  feedbackTitle: 'Sharp read.',
  feedbackReason:
      'Your cards stay next to you. The shared cards go in the middle.',
  table: _meetTableRunner.table.copyWith(
    heroCards: _heroKtCards,
    handContributions: _meetTableRunner.table.handContributions,
    actionTrail: [
      for (final item in _meetTableRunner.table.actionTrail)
        if (item.isNote)
          item
        else
          Act0ActionTrailItemV1(
            label: item.label,
            displayLabel: item.learnerLabel.replaceFirstMapped(
              RegExp(r'^(?:SB|BB) blind (0\.5|1) BB$'),
              (match) => match[1] == '1'
                  ? 'A player adds one unit'
                  : 'A player adds half a unit',
            ),
          ),
    ],
    selectableSeatIds: const <String>['utg', 'btn', 'bb'],
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Find your cards.',
      body:
          'Your private cards are the two beside your seat. The board is the group of cards everyone still playing can use. Look at where each group sits before reading the ranks.',
      focusSeatIds: <String>['btn', 'sb', 'bb'],
      focusLabels: <String>['Your cards', 'Board'],
      identityTeachingSemantics:
          Act0TableIdentityTeachingSemanticsV1.learnerOnly,
    ),
  ],
);

final _firstTableGuideFindHeroRunner = _meetTableRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'first_table_guide_find_hero',
  lessonTitle: 'Your cards and the board',
  lessonSubtitle: 'Read one spot, answer once, and see why.',
  beatIndex: 2,
  beatCount: 5,
  caption: 'Look at the cards in both parts of the table.',
  hint: 'Compare the cards at your seat with the cards in the middle.',
  question: 'Which cards belong to you alone?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'top',
      label: 'The shared cards in the middle',
      repairFocusSeatIds: const <String>['btn'],
      isCorrect: false,
      preferredLabel: 'The two cards at your seat',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Shared cards can be used by everyone.',
      feedbackReason: 'Everyone still playing can use the cards in the middle.',
    ),
    Act0RunnerOptionV1(
      id: 'bottom',
      label: 'The two cards at your seat',
      repairFocusSeatIds: const <String>['btn'],
      isCorrect: true,
      preferredLabel: 'The two cards at your seat',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'You found your own cards.',
      feedbackReason: 'The two cards at your seat are yours alone to use.',
    ),
    Act0RunnerOptionV1(
      id: 'random',
      label: 'The cards at the other seats',
      repairFocusSeatIds: const <String>['btn'],
      isCorrect: false,
      preferredLabel: 'The two cards at your seat',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Only your seat shows your cards.',
      feedbackReason: 'The cards at the other seats belong to those players.',
    ),
  ],
  feedbackTitle: 'Private cards and shared cards.',
  feedbackReason: 'Look near the bottom for your two private cards.',
  table: _meetTableRunner.table.copyWith(
    heroCards: _heroKtCards,
    handContributions: _meetTableRunner.table.handContributions,
    actionTrail: [
      for (final item in _meetTableRunner.table.actionTrail)
        if (item.isNote)
          item
        else
          Act0ActionTrailItemV1(
            label: item.label,
            displayLabel: item.learnerLabel.replaceFirstMapped(
              RegExp(r'^(?:SB|BB) blind (0\.5|1) BB$'),
              (match) => match[1] == '1'
                  ? 'A player adds one unit'
                  : 'A player adds half a unit',
            ),
          ),
    ],
    selectableSeatIds: const <String>[],
  ),
  teachingSteps: const <Act0TeachingStepV1>[],
);

final _firstTableGuideReadTableRunner = _w1TableReadTransferRunner.copyWith(
  lessonId: 'first_table_guide_read_table',
  lessonTitle: 'First Table Guide',
  lessonSubtitle: 'Read one spot, answer once, and see why.',
  beatIndex: 3,
  beatCount: 5,
  caption: 'Shared cards and the pot are visible in the middle.',
  hint: 'Read your cards, the shared board, and the pot before any action.',
  feedbackReason:
      'Start with the same three checks every time: your cards, the shared board, and chips in the pot.',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'two_three_six',
      label: '2 private cards, 3 board cards, 6 BB in the pot',
      isCorrect: true,
      preferredLabel: '2 private cards, 3 board cards, 6 BB in the pot',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Excellent spot.',
      feedbackReason:
          'That is the clean first live read. Separate your cards, the shared board, and chips in the middle before choosing anything.',
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
      label: 'Read your two cards and act right away',
      isCorrect: false,
      preferredLabel: '2 private cards, 3 board cards, 6 BB in the pot',
      betterAnswerLabel: '2 private cards, 3 board cards, 6 BB in the pot',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Read the whole table.',
      feedbackReason:
          'Your cards matter, but a live table read also needs the shared board and pot before the decision starts.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Carry the first table scan.',
      body: 'Find your cards, the shared board, and the chips in the pot.',
      focusLabels: <String>['2 private', '3 board', 'Pot'],
    ),
  ],
);

final _firstTableGuideActionRunner = _whatYouCanDoRunner.copyWith(
  lessonId: 'first_table_guide_one_clear_choice',
  lessonTitle: 'Your cards and the board',
  lessonSubtitle: 'Read one spot, answer once, and see why.',
  beatIndex: 4,
  beatCount: 5,
  caption: 'Find the cards at your seat and check the middle.',
  hint: 'The shared cards would appear in the middle.',
  question: 'Which description matches the cards on this table?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'hero_btn_preflop_setup',
      label: 'Two private cards and no shared cards',
      isCorrect: true,
      preferredLabel: 'Two private cards and no shared cards',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'That is the setup.',
      feedbackReason:
          'Your two cards are visible next to you. The space for the shared cards is empty.',
      repairFocusSeatIds: <String>['btn', 'sb', 'bb'],
      repairFocusCardIds: <String>['hero_0', 'hero_1'],
      repairFocusLabels: <String>['Your cards', 'Shared cards', 'Board space'],
    ),
    Act0RunnerOptionV1(
      id: 'co_still_acting',
      label: 'Two private cards and three shared cards',
      isCorrect: false,
      preferredLabel: 'Two private cards and no shared cards',
      betterAnswerLabel: 'Two private cards and no shared cards',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Count the shared cards separately.',
      feedbackReason:
          'You correctly found the two private cards. The shared cards have yet to appear.',
      repairFocusSeatIds: <String>['btn', 'sb', 'bb'],
      repairFocusCardIds: <String>['hero_0', 'hero_1'],
      repairFocusLabels: <String>['Your cards', 'Shared cards', 'Board space'],
    ),
    Act0RunnerOptionV1(
      id: 'hero_has_no_cards',
      label: 'No private cards and no shared cards',
      isCorrect: false,
      preferredLabel: 'Two private cards and no shared cards',
      betterAnswerLabel: 'Two private cards and no shared cards',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Use the visible cards too.',
      feedbackReason:
          'There are no cards in the middle, but two cards are visible beside you.',
      repairFocusSeatIds: <String>['btn', 'sb', 'bb'],
      repairFocusCardIds: <String>['hero_0', 'hero_1'],
      repairFocusLabels: <String>['Your cards', 'Shared cards', 'Board space'],
    ),
  ],
  feedbackTitle: 'Setup locked in.',
  feedbackReason:
      'You read one spot, named the setup, and got one clear why back. That foundation makes later lessons move faster because later lessons keep reusing the same table-first scan.',
  table: _whatYouCanDoRunner.table.copyWith(
    centerLabel: 'Cards on the table',
    handContributions: _whatYouCanDoRunner.table.handContributions,
    actionTrail: const [],
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Your cards and the board.',
      body:
          'Count your cards and the shared cards separately. The middle can be empty while you already have two cards. Look beside your seat first, then look at the middle. Count each group on its own even when one group has no cards.',
      focusSeatIds: <String>['btn', 'sb', 'bb'],
      focusLabels: <String>['Your cards', 'Shared cards'],
    ),
  ],
);

final _firstTableGuideRouteRunner = _whatYouCanDoRunner.copyWith(
  lessonId: 'first_table_guide_route_roles',
  lessonTitle: 'First Table Guide',
  lessonSubtitle: 'Read one spot, answer once, and see why.',
  beatIndex: 5,
  beatCount: 5,
  phase: Act0LessonPhaseV1.review,
  caption: 'Each tab has a job.',
  hint: 'Home shows what to do now. Learn shows what to study next.',
  question: 'Where do you go to fix mistakes after a miss?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'review',
      label: 'Review',
      isCorrect: true,
      preferredLabel: 'Review',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Exactly.',
      feedbackReason:
          'Review fixes mistakes. Home shows what to do now, Learn shows what to study next, Practice gives extra reps, and You shows progress.',
    ),
    Act0RunnerOptionV1(
      id: 'practice',
      label: 'Practice',
      isCorrect: false,
      preferredLabel: 'Review',
      betterAnswerLabel: 'Review',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Close, but one tab is sharper.',
      feedbackReason:
          'Practice gives extra reps after Learn teaches the concept. Review is where a miss gets fixed first.',
    ),
    Act0RunnerOptionV1(
      id: 'learn',
      label: 'Learn',
      isCorrect: false,
      preferredLabel: 'Review',
      betterAnswerLabel: 'Review',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'One more distinction.',
      feedbackReason:
          'Learn shows what to study next. Review is the tab that turns a mistake into the next repair step.',
    ),
  ],
  feedbackTitle: 'Tab jobs locked in.',
  feedbackReason:
      'Home shows what to do now, Learn shows what to study next, Practice gives extra reps, Review fixes mistakes, and You shows progress.',
  table: _whatYouCanDoRunner.table.copyWith(
    handContributions: _whatYouCanDoRunner.table.handContributions,
    actionTrail: const [],
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Know the five jobs.',
      body:
          'Home picks the next step. Learn opens lessons. Practice adds reps. Review fixes mistakes. You shows progress and settings.',
      focusLabels: <String>['Home', 'Learn', 'Practice', 'Review', 'You'],
    ),
  ],
);

final _boardCountRunner = _readBoardRunner.copyWith(
  lessonId: 'board_count',
  lessonTitle: 'Cards, ranks & suits',
  caption: 'Count the cards in the middle.',
  hint: 'Count the occupied card slots in the middle.',
  question: 'How many shared cards can the table show?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'five',
      label: 'Five',
      isCorrect: true,
      preferredLabel: 'Five',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Spot on.',
      feedbackReason: 'The table can show up to five shared cards.',
    ),
    Act0RunnerOptionV1(
      id: 'two',
      label: 'Two',
      isCorrect: false,
      preferredLabel: 'Five',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason: 'Two is your private card count, not the full board.',
    ),
    Act0RunnerOptionV1(
      id: 'three',
      label: 'Three',
      isCorrect: false,
      preferredLabel: 'Five',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Check the clue again.',
      feedbackReason:
          'The first group of shared cards has three. Two more can be dealt later.',
    ),
  ],
  table: _riverBoardRunner.table.copyWith(
    handContributions: _act0BoardReadingContributionsV1(PokerStreet.river),
    centerLabel: 'Read the cards',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'The board grows during the hand.',
      body: 'A table can have up to five shared cards.',
      focusCardIds: <String>[
        'board_0',
        'board_1',
        'board_2',
        'board_3',
        'board_4',
      ],
      focusLabels: <String>['Shared cards'],
    ),
  ],
);

final _bestFiveCardsRunner = _riverBoardRunner.copyWith(
  lessonId: 'best_five_cards',
  lessonTitle: 'Cards, ranks & suits',
  caption: 'A poker hand uses the best five cards available.',
  hint: 'Use your private cards and the shared board together.',
  question: 'How many cards make your final hand?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'five',
      label: 'Five',
      isCorrect: true,
      preferredLabel: 'Five',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Five cards form your hand.',
      feedbackReason: 'Your final poker hand is the best five cards.',
    ),
    Act0RunnerOptionV1(
      id: 'seven',
      label: 'Seven',
      isCorrect: false,
      preferredLabel: 'Five',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason: 'You may see seven cards, but only five form the hand.',
    ),
  ],
  table: _riverBoardRunner.table.copyWith(
    handContributions: _act0BoardReadingContributionsV1(PokerStreet.river),
    highlightedCardIds: const <String>[
      'hero_0',
      'hero_1',
      'board_0',
      'board_1',
      'board_3',
    ],
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Seven seen, five count.',
      body: 'Two private cards plus five board cards are available.',
      focusLabels: <String>['Choose best five'],
    ),
  ],
);

final _cardsRecapRunner = _bestFiveCardsRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'cards_recap',
  caption: 'Lesson learned: cards have a job.',
  hint:
      'A rank tells how high a card is. A suit is its symbol. Everyone can use the board.',
  question: 'How many cards make your final hand?',
  feedbackTitle: 'Card takeaway.',
  feedbackReason:
      'You hold two private cards, share the board, and make the best five-card hand.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Card takeaway.',
      body:
          'Rank compares height. Suit groups cards, and board cards are shared.',
      focusLabels: <String>['Rank', 'Suit', 'Board'],
    ),
  ],
);

final _actionTrailRunner = _riverBoardRunner.copyWith(
  lessonId: 'action_trail',
  lessonTitle: 'Your first hand, dealt',
  caption: 'The action history records what happened street by street.',
  hint: 'Read it left to right.',
  question: 'Which previous action happened last?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'bb_check',
      label: 'Flop: BB checks',
      isCorrect: true,
      preferredLabel: 'Flop: BB checks',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Right timeline.',
      feedbackReason:
          'The last action in the history is the newest one, so Flop: BB checks comes after the blind posts and preflop action.',
    ),
    Act0RunnerOptionV1(
      id: 'sb_post',
      label: 'SB blind posted',
      isCorrect: false,
      preferredLabel: 'Flop: BB checks',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason: 'Posting blinds happened before the hand developed.',
    ),
  ],
  table: _riverBoardRunner.table.copyWith(
    actionTrail: const <Act0ActionTrailItemV1>[
      Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
      Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
      Act0ActionTrailItemV1(label: 'BTN raises 3 BB'),
      Act0ActionTrailItemV1(label: 'BB calls 3 BB'),
      Act0ActionTrailItemV1(label: 'Flop: BB checks'),
    ],
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Action history shows the hand.',
      body: 'Read left to right to see what already happened.',
      focusLabels: <String>['Oldest -> newest'],
    ),
  ],
);

final _streetOrderRecapRunner = _riverBoardRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'street_order_recap',
  lessonTitle: 'Your first hand, dealt',
  caption: 'Lesson learned: streets tell time.',
  hint: 'Preflop has no board, then flop 3, turn 4, river 5.',
  question: 'Which street comes after the turn?',
  feedbackTitle: 'Street takeaway.',
  feedbackReason:
      'A hand moves forward street by street. The action history records what already happened.',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'river',
      label: 'River',
      isCorrect: true,
      preferredLabel: 'River',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Correct order.',
      feedbackReason:
          'A hand moves preflop, flop, turn, then river. The river comes right after the turn.',
    ),
    Act0RunnerOptionV1(
      id: 'flop',
      label: 'Flop',
      isCorrect: false,
      preferredLabel: 'River',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason: 'The flop comes before the turn.',
    ),
    Act0RunnerOptionV1(
      id: 'preflop',
      label: 'Preflop',
      isCorrect: false,
      preferredLabel: 'River',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Check the clue again.',
      feedbackReason: 'Preflop happens before any board cards are dealt.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'The order of the streets.',
      body:
          'When a hand runs all the way to the river, the order is preflop, flop, turn and river.',
      focusLabels: <String>['Preflop', 'Flop', 'Turn', 'River'],
    ),
  ],
);

final _actionWordsRunner = _whatYouCanDoRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'action_words',
  caption: 'Four action words matter first: fold, check, call, raise.',
  hint: 'The table state tells which actions are legal.',
  question:
      'Which action would make the next player match more than the big blind?',
  options: _raisesThePriceChoices,
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Actions are table verbs.',
      body:
          'Fold leaves the hand. Check passes for free. Call matches the bet. Raise makes others pay more to continue.',
      focusLabels: <String>['Fold', 'Check', 'Call', 'Raise'],
    ),
  ],
);

final _legalActionRunner = _checkActionRunner.copyWith(
  lessonId: 'legal_actions',
  caption: 'Legal actions depend on whether a bet is facing you.',
  hint:
      'When no chips are owed, you can check. Facing a bet, a call matches the price and a fold exits. A raise may also be available.',
  question:
      'No bet faces you. Which action keeps you in the hand without adding chips?',
  options: _noPriceActionChoices,
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Legality depends on price.',
      body: 'With no bet, you can check for free.',
      focusLabels: <String>['No bet', 'Check'],
    ),
  ],
);

final _actionRecapRunner = _whatYouCanDoRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'action_recap',
  caption: 'Lesson learned: action words depend on price.',
  hint: 'Compare what each action asks the next player to match.',
  feedbackTitle: 'Action takeaway.',
  feedbackReason:
      'Check is free, fold exits, call matches the price, and raise adds more.',
  question: 'Which action sets a higher price for the next player?',
  options: _raisesThePriceChoices,
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Action takeaway.',
      body: 'Read the price before acting.',
      focusLabels: <String>['Price first'],
    ),
  ],
);

final _bigBlindPostRunner = _tableObjectsRunner.copyWith(
  lessonId: 'big_blind_post',
  lessonTitle: 'Blinds & action order',
  caption: 'BB sets the 1 BB unit for the hand.',
  hint: 'Later prices like 3 BB count from this post.',
  question: 'Tap the blind that sets the 1 BB unit.',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'bb',
      label: 'BB',
      seatId: 'bb',
      isCorrect: true,
      preferredLabel: 'BB',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Right unit.',
      feedbackReason:
          'BB posts the full 1 BB blind, so later prices count from that 1 BB post.',
    ),
    Act0RunnerOptionV1(
      id: 'sb',
      label: 'SB',
      seatId: 'sb',
      isCorrect: false,
      preferredLabel: 'BB',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not the 1 BB unit.',
      feedbackReason:
          'SB posts only 0.5 BB. BB is the full 1 BB post players count from.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'BB is the 1 BB unit.',
      body:
          'Find the seat marked BB, because later prices like 3 BB count from that 1 BB post.',
      focusSeatIds: <String>['bb'],
      focusLabels: <String>['1 BB unit', 'Count from BB'],
    ),
  ],
);

final _buttonMovesRunner = _buttonSeatRunner.copyWith(
  lessonId: 'button_moves',
  lessonTitle: 'Blinds & action order',
  caption: 'The Button moves one seat after each hand.',
  hint: 'That keeps blinds and late position rotating.',
  question: 'Which seat has the dealer marker in this hand?',
  options: _dealerMarkerChoices,
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Button rotates.',
      body: 'After each hand, the button moves so blinds rotate too.',
      focusSeatIds: <String>['btn'],
      focusLabels: <String>['D marker'],
    ),
  ],
);

final _blindsOrderRecapRunner = _lastPreflopActorRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'blinds_order_recap',
  caption: 'Lesson learned: blinds start the order.',
  hint: 'SB posts 0.5, BB posts 1, then action begins around the table.',
  question: 'Who acts first preflop?',
  feedbackTitle: 'Order takeaway.',
  feedbackReason:
      'Preflop starts left of the big blind. After the flop, action starts left of the Button.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Order takeaway.',
      body: 'Blinds post first. Then each street follows the table order.',
      focusSeatIds: <String>['sb', 'bb', 'utg'],
      focusLabels: <String>['Post', 'Act'],
    ),
  ],
);

final _cutoffSeatRunner = _meetTableRunner.copyWith(
  lessonId: 'cutoff_seat',
  lessonTitle: 'The 6 positions',
  caption: 'CO means cutoff. It is one seat before the Button.',
  hint: 'Find the dealer marker, then look one seat earlier.',
  question: 'Tap the cutoff.',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'co',
      label: 'CO',
      seatId: 'co',
      isCorrect: true,
      preferredLabel: 'CO',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'CO is the seat before BTN.',
      feedbackReason: 'CO is the cutoff seat before the Button.',
    ),
    Act0RunnerOptionV1(
      id: 'hj',
      label: 'HJ',
      seatId: 'hj',
      isCorrect: false,
      preferredLabel: 'CO',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason: 'HJ is before CO in the six-seat order.',
    ),
  ],
  table: _meetTableRunner.table.copyWith(
    selectableSeatIds: const <String>['co', 'hj'],
    highlightedSeatIds: const <String>['co'],
    activeSeatId: 'co',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'CO is before BTN.',
      body: 'Cutoff is the seat immediately before the Button.',
      focusSeatIds: <String>['co', 'btn'],
      focusLabels: <String>['CO -> BTN'],
    ),
  ],
);

final _earlyLatePositionRunner = _latePositionRunner.copyWith(
  lessonId: 'early_late_position',
  caption: 'Early seats act with less information than late seats.',
  hint: 'Start at the big blind and follow the first pass before the flop.',
  question: 'Which seat is early preflop?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'utg',
      label: 'UTG',
      seatId: 'utg',
      isCorrect: true,
      preferredLabel: 'UTG',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Solid understanding.',
      feedbackReason: 'UTG is the early preflop seat.',
    ),
    Act0RunnerOptionV1(
      id: 'btn',
      label: 'BTN',
      seatId: 'btn',
      isCorrect: false,
      preferredLabel: 'UTG',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason: 'BTN is late and usually has more information.',
    ),
  ],
  table: _latePositionRunner.table.copyWith(
    selectableSeatIds: const <String>['btn', 'utg'],
    highlightedSeatIds: const <String>['utg'],
    activeSeatId: 'utg',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Early seats decide sooner.',
      body: 'UTG acts before seeing what most players will do.',
      focusSeatIds: <String>['utg', 'btn'],
      focusLabels: <String>['Early', 'Late'],
    ),
  ],
);

final _positionsRecapRunner = _positionsRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'positions_recap',
  caption: 'Lesson learned: position changes information.',
  hint: 'Early seats decide sooner. Late seats see more before acting.',
  question: 'Which seat is latest after the flop here?',
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
          'UTG acts before BTN after the flop on this six-seat table.',
    ),
    Act0RunnerOptionV1(
      id: 'bottom',
      label: 'BTN',
      seatId: 'btn',
      isCorrect: true,
      preferredLabel: 'BTN',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'You found the seat.',
      feedbackReason: 'BTN acts last after the flop on this six-seat table.',
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
          'BB acts before BTN after the flop on this six-seat table.',
    ),
  ],
  feedbackTitle: 'Position takeaway.',
  feedbackReason:
      'The six names are UTG, HJ, CO, BTN, SB, and BB. BTN is the clearest late seat.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Position takeaway.',
      body: 'Seat name tells when you act and how much you can observe.',
      focusSeatIds: <String>['utg', 'btn'],
      focusLabels: <String>['Sooner', 'Later'],
    ),
  ],
);

final _tripsRankRunner = _riverBoardRunner.copyWith(
  lessonId: 'trips_rank',
  lessonTitle: 'Hand rankings, on the table',
  caption:
      'A set is three of a kind made from a pair in your private cards and one matching card on the board.',
  hint: 'Three of a kind beats two pair.',
  question: 'Which hand ranks higher?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'trips',
      label: 'Three of a kind',
      isCorrect: true,
      preferredLabel: 'Three of a kind',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Well done.',
      feedbackReason: 'Three of a kind ranks above two pair.',
    ),
    Act0RunnerOptionV1(
      id: 'two_pair',
      label: 'Two pair',
      isCorrect: false,
      preferredLabel: 'Three of a kind',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason: 'Two pair is below three of a kind.',
    ),
  ],
  table: _riverBoardRunner.table.copyWith(
    handContributions: _act0FivePlayerComparisonPot,
    heroCards: const [
      Act0CardStateV1(rank: 'T', suit: 'h'),
      Act0CardStateV1(rank: 'T', suit: 's'),
    ],
    boardCards: _boardThreeTens,
    highlightedCardIds: const <String>['hero_0', 'hero_1', 'board_0'],
    seats: _riverBoardRunner.table.seats
        .map(
          (seat) => seat.seatId == 'btn'
              ? _act0CopySeatStateV1(
                  seat,
                  holeCards: const [
                    Act0CardStateV1(rank: 'T', suit: 'h'),
                    Act0CardStateV1(rank: 'T', suit: 's'),
                  ],
                  cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
                )
              : seat.seatId == 'co'
              ? _act0CopySeatStateV1(
                  seat,
                  holeCards: _opponentJd7hCards,
                  cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
                  isActive: false,
                )
              : seat,
        )
        .toList(growable: false),
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Three of a kind is above two pair.',
      body: 'Three cards of one rank beat two separate pairs.',
      focusLabels: <String>['Three of a kind'],
    ),
  ],
);

final _straightRankRunner = _riverBoardRunner.copyWith(
  lessonId: 'straight_rank',
  lessonTitle: 'Hand rankings, on the table',
  caption:
      'A straight is five ranks in a row. An ace can be low in A-2-3-4-5, but Q-K-A-2-3 is not a straight.',
  hint: 'Check whether the five ranks follow one another.',
  question: 'What makes a straight?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'five_in_row',
      label: 'Five in a row',
      isCorrect: true,
      preferredLabel: 'Five in a row',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Excellent spot.',
      feedbackReason: 'A straight uses five ranks in sequence.',
    ),
    Act0RunnerOptionV1(
      id: 'same_suit',
      label: 'Same suit',
      isCorrect: false,
      preferredLabel: 'Five in a row',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'Cards of one suit can have gaps. Look for five ranks in a row.',
    ),
  ],
  table: _riverBoardRunner.table.copyWith(
    handContributions: _act0BoardReadingContributionsV1(PokerStreet.river),
    heroCards: _hero89Cards,
    boardCards: _boardStraight,
    highlightedCardIds: const <String>[
      'board_0',
      'board_1',
      'board_2',
      'hero_0',
      'hero_1',
    ],
    seats: _riverBoardRunner.table.seats
        .map(
          (seat) => seat.seatId == 'btn'
              ? _act0CopySeatStateV1(
                  seat,
                  holeCards: _hero89Cards,
                  cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
                )
              : seat,
        )
        .toList(growable: false),
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Straight means sequence.',
      body: 'A straight is five ranks in a row, not five of one suit.',
      focusLabels: <String>['5 ranks in order'],
    ),
  ],
);

final _bestFiveShowdownRunner = _bestFiveCardsRunner.copyWith(
  lessonId: 'best_five_showdown',
  lessonTitle: 'Hand rankings, on the table',
  caption: "Compare each player's best five cards.",
  question: 'Which of these cards is left out of your best five?',
  options: const [
    Act0RunnerOptionV1(
      id: 'five',
      label: 'Four',
      isCorrect: true,
      preferredLabel: 'Four',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Use the highest side card.',
      feedbackReason:
          'The jack completes your two pair, aces and sevens. The four stays out.',
    ),
    Act0RunnerOptionV1(
      id: 'seven',
      label: 'Jack',
      isCorrect: false,
      preferredLabel: 'Four',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Compare the cards outside your two pair.',
      feedbackReason:
          'The jack is higher than the four, so use it with the two pairs.',
    ),
  ],
  hint: 'Unused extra cards do not count.',
  table: _bestFiveCardsRunner.table.copyWith(
    heroCards: _heroA7oCards,
    highlightedCardIds: const <String>[
      'hero_0',
      'hero_1',
      'board_0',
      'board_1',
      'board_3',
    ],
    centerLabel: 'Read the cards',
    seats: _bestFiveCardsRunner.table.seats
        .map(
          (seat) => seat.seatId == 'btn'
              ? _act0CopySeatStateV1(
                  seat,
                  holeCards: _heroA7oCards,
                  cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
                )
              : seat,
        )
        .toList(growable: false),
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Extra cards are ignored.',
      body:
          'Here the best five are A, A, 7, 7, and J. The 4 is still visible on the board, but it does not play because only the strongest five cards count.',
      focusCardIds: <String>[
        'hero_0',
        'hero_1',
        'board_0',
        'board_1',
        'board_3',
      ],
      focusLabels: <String>['Best five', 'Unused card'],
    ),
  ],
);

final _rankingRecapRunner = _flushRankRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'ranking_recap',
  caption: 'Lesson learned: compare the best five.',
  hint: 'Compare the two hand types on the ranking ladder.',
  question: 'Which ranks higher: flush or straight?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'flush',
      label: 'Flush',
      isCorrect: true,
      preferredLabel: 'Flush',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Read the hand rankings.',
      feedbackReason: 'A flush ranks above a straight.',
    ),
    Act0RunnerOptionV1(
      id: 'straight',
      label: 'Straight',
      isCorrect: false,
      preferredLabel: 'Flush',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Compare consecutive ranks with matching suits.',
      feedbackReason:
          'A straight beats three of a kind. Five cards of one suit make a flush, which ranks higher.',
    ),
  ],
  feedbackTitle: 'Ranking takeaway.',
  feedbackReason:
      'Only the best five cards count. A flush ranks above a straight.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Ranking takeaway.',
      body: 'First identify the hand type, then compare the ladder.',
      focusLabels: <String>['Pair', 'Straight', 'Flush'],
    ),
  ],
);

final _boardPlaysRunner = _riverBoardRunner.copyWith(
  lessonId: 'board_plays',
  lessonTitle: 'Showdown & winning',
  caption: 'Sometimes the best five cards are all on the board.',
  hint: 'Then both players may play the board.',
  question: 'If both players use the same board, what can happen?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'tie',
      label: 'Tie',
      isCorrect: true,
      preferredLabel: 'Tie',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Spot on.',
      feedbackReason: 'If the same five cards play, the pot can be split.',
    ),
    Act0RunnerOptionV1(
      id: 'seat_wins',
      label: 'BTN wins',
      isCorrect: false,
      preferredLabel: 'Tie',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason: 'Seat position does not win when the same hand plays.',
    ),
  ],
  table: _riverBoardRunner.table.copyWith(
    handContributions: _act0FivePlayerComparisonPot,
    heroCards: _heroQqCards,
    boardCards: _boardBroadwayCards,
    highlightedCardIds: const <String>[
      'board_0',
      'board_1',
      'board_2',
      'board_3',
      'board_4',
    ],
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
                  holeCards: _villainK4Cards,
                  cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
                  isActive: false,
                )
              : seat,
        )
        .toList(growable: false),
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Sometimes the board plays.',
      body:
          'You and CO both use the same A-K-Q-J-T straight from the board here, so private cards do not improve either player.',
      focusCardIds: <String>[
        'board_0',
        'board_1',
        'board_2',
        'board_3',
        'board_4',
      ],
      focusLabels: <String>['Same best five'],
    ),
  ],
);

final _tiePotRunner = _boardPlaysRunner.copyWith(
  lessonId: 'tie_pot',
  caption: 'A tie means the pot is split.',
  hint: 'This can happen when the same best five cards play.',
  question: 'What happens to the pot on a tie?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'split',
      label: 'Split',
      isCorrect: true,
      preferredLabel: 'Split',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Clean execution.',
      feedbackReason: 'A tied pot is split between tied players.',
    ),
    Act0RunnerOptionV1(
      id: 'first_seat',
      label: 'First seat wins',
      isCorrect: false,
      preferredLabel: 'Split',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason: 'Acting order does not break a tied hand.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Split means share.',
      body:
          'You and CO share the same A-K-Q-J-T straight from the board, so the two shown hands tie. Only these two hands are shown here.',
      focusLabels: <String>['Shown hands tie'],
    ),
  ],
);

Act0TableStateV1 _act0CheckpointShowdownTableV1({
  required List<Act0CardStateV1> heroCards,
  required List<Act0CardStateV1> otherCards,
  required List<Act0CardStateV1> boardCards,
  num flopBetBb = 0,
  num turnBetBb = 0,
  List<String> highlightedCardIds = const [],
}) {
  const opponent = 'hj';
  const hero = 'co';
  final contributedBb = 2.25 + flopBetBb + turnBetBb;
  return _showdownKickerRunner.table.copyWith(
    centerLabel: 'Showdown',
    streetLabel: 'River',
    potLabel: 'Pot ${_act0BbLabelV1(2 * contributedBb + 1.5)}',
    toCallLabel: '',
    heroSeatId: hero,
    activeSeatId: '',
    clearDecisionSeatId: true,
    selectableSeatIds: const [],
    highlightedCardIds: highlightedCardIds,
    heroCards: heroCards,
    boardCards: boardCards,
    handContributions: Act0HandContributionsV1(
      throughStreet: PokerStreet.river,
      entries: [
        ..._act0LessonBlinds,
        const Act0ContributionV1(
          PokerStreet.preflop,
          opponent,
          Act0ContributionKindV1.wager,
          2.25,
        ),
        const Act0ContributionV1(
          PokerStreet.preflop,
          hero,
          Act0ContributionKindV1.wager,
          2.25,
        ),
        for (final (street, bet) in [
          (PokerStreet.flop, flopBetBb),
          (PokerStreet.turn, turnBetBb),
        ])
          if (bet > 0)
            for (final seat in [opponent, hero])
              Act0ContributionV1(
                street,
                seat,
                Act0ContributionKindV1.wager,
                bet.toDouble(),
              ),
      ],
    ),
    actionTrail: [
      const Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
      const Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
      const Act0ActionTrailItemV1(label: 'UTG folds'),
      const Act0ActionTrailItemV1(label: 'HJ raises 2.25 BB'),
      const Act0ActionTrailItemV1(label: 'CO calls 2.25 BB'),
      const Act0ActionTrailItemV1(label: 'BTN folds'),
      const Act0ActionTrailItemV1(label: 'SB folds'),
      const Act0ActionTrailItemV1(label: 'BB folds'),
      for (final (street, bet) in [('Flop', flopBetBb), ('Turn', turnBetBb)])
        if (bet > 0) ...[
          Act0ActionTrailItemV1(
            label: '$street: HJ bets ${_act0BbLabelV1(bet)}',
          ),
          Act0ActionTrailItemV1(label: 'CO calls ${_act0BbLabelV1(bet)}'),
        ] else ...[
          Act0ActionTrailItemV1(label: '$street: HJ checks'),
          const Act0ActionTrailItemV1(label: 'CO checks'),
        ],
      const Act0ActionTrailItemV1(label: 'River: HJ checks'),
      const Act0ActionTrailItemV1(label: 'CO checks'),
    ],
    autoPlayHistory: false,
    seats: [
      for (final seat in _showdownKickerRunner.table.seats)
        _act0CopySeatStateV1(
          seat,
          isOccupied: true,
          isHero: seat.seatId == hero,
          displayName: seat.seatId == hero
              ? 'Hero'
              : _act0DefaultSeatDisplayNameV1(seat),
          isInHand: seat.seatId == hero || seat.seatId == opponent,
          isFolded: seat.seatId != hero && seat.seatId != opponent,
          isActive: false,
          hasActed: true,
          isLastAggressor: false,
          clearCommitment: true,
          stackLabel: switch (seat.seatId) {
            hero || opponent => _act0BbLabelV1(100 - contributedBb),
            'sb' => '99.5 BB',
            'bb' => '99 BB',
            _ => '100 BB',
          },
          holeCards: switch (seat.seatId) {
            opponent => otherCards,
            hero => heroCards,
            _ => seat.holeCards,
          },
          cardsVisibleMode: seat.seatId == hero || seat.seatId == opponent
              ? Act0CardsVisibleModeV1.faceUp
              : Act0CardsVisibleModeV1.none,
        ),
    ],
  );
}

final _worldOneCheckpointRunner = _showdownKickerRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'world_one_checkpoint',
  lessonTitle: 'Showdown & winning',
  caption: 'Compare the two shown hands on this board.',
  hint:
      'Build each best five. Check whether either player can improve the board.',
  question: 'What happens to the pot in this hand?',
  table: _act0CheckpointShowdownTableV1(
    heroCards: const [
      Act0CardStateV1(rank: '8', suit: 's'),
      Act0CardStateV1(rank: '7', suit: 'd'),
    ],
    otherCards: const [
      Act0CardStateV1(rank: '6', suit: 'h'),
      Act0CardStateV1(rank: '4', suit: 'c'),
    ],
    boardCards: const [
      Act0CardStateV1(rank: 'K', suit: 'd'),
      Act0CardStateV1(rank: 'Q', suit: 'h'),
      Act0CardStateV1(rank: 'J', suit: 's'),
      Act0CardStateV1(rank: 'T', suit: 'c'),
      Act0CardStateV1(rank: '9', suit: 'c'),
    ],
  ),
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'best_hand',
      label: 'Split the pot',
      isCorrect: true,
      preferredLabel: 'Split the pot',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'The best five tie.',
      feedbackReason:
          'Both players use K-Q-J-T-9. Neither can make a higher straight, so they split the pot.',
    ),
    Act0RunnerOptionV1(
      id: 'first_actor',
      label: 'Other player wins',
      isCorrect: false,
      preferredLabel: 'Split the pot',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Compare the best five.',
      feedbackReason:
          'The other player cannot improve the king-high straight on the board.',
    ),
    Act0RunnerOptionV1(
      id: 'hero_cards_only',
      label: 'You win',
      isCorrect: false,
      preferredLabel: 'Split the pot',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Start with the shared straight.',
      feedbackReason:
          'Your eight can make a lower straight. Your best five are the five shared cards.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[],
);

final _world2ShowdownIntroRunner = _showdownBestHandRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w2_showdown_intro',
  lessonTitle: 'Which hand wins?',
  lessonSubtitle: 'Hand Value And Position',
  caption: 'World 2 starts by comparing real showdowns.',
  hint: 'Do not guess by seat. Compare the hand that reaches showdown.',
  question: 'What decides this showdown?',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Compare the hands.',
      body: 'At showdown, the strongest best-five hand wins the pot.',
      focusLabels: <String>['Showdown', 'Best hand'],
    ),
  ],
);

final _world2ShowdownRecapRunner = _showdownBestHandRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w2_showdown_recap',
  lessonTitle: 'Which hand wins?',
  lessonSubtitle: 'Hand Value And Position',
  caption: 'Lesson learned: compare hand strength first.',
  hint: 'Seat, stack, and action do not beat the best hand at showdown.',
  question: 'What is the first showdown question?',
  feedbackTitle: 'Showdown takeaway.',
  feedbackReason:
      'At showdown, compare each player\'s best five cards before thinking about seat or action.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Showdown checklist.',
      body: 'Name the hand type, compare kickers if needed, then award pot.',
      focusLabels: <String>['Hand type', 'Kicker', 'Pot'],
    ),
  ],
);

final _world2BestFiveIntroRunner = _bestFiveCardsRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w2_best_five_intro',
  lessonTitle: 'Best five cards',
  lessonSubtitle: 'Hand Value And Position',
  caption: 'You may see seven cards, but only five count.',
  hint: 'Your best five can use private cards, board cards, or both.',
  question: 'How many cards decide your final hand?',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Only five count.',
      body: 'Choose the strongest five-card hand from all available cards.',
      focusLabels: <String>['Best five'],
    ),
  ],
);

final _world2BestFiveRecapRunner = _bestFiveShowdownRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w2_best_five_recap',
  lessonTitle: 'Best five cards',
  lessonSubtitle: 'Hand Value And Position',
  caption: 'Lesson learned: extra cards are only helpers.',
  hint: 'Compare the final five, not every card you can see.',
  question: 'What counts at showdown?',
  feedbackTitle: 'Best-five takeaway.',
  feedbackReason:
      'A player can see up to seven cards, but showdown uses only the strongest five-card hand.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Best-five checklist.',
      body: 'Build the best five, ignore unused cards, then compare.',
      focusLabels: <String>['Build', 'Ignore extra', 'Compare'],
    ),
  ],
);

final _world2KickerIntroRunner = _showdownKickerRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w2_kicker_intro',
  lessonTitle: 'Kicker decides',
  lessonSubtitle: 'Hand Value And Position',
  caption: 'A kicker is the side card that can break a tie.',
  hint: 'It matters only when the main hand is otherwise close.',
  question: 'When can a kicker matter?',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Side cards can decide.',
      body: 'If the main hand matches, compare the highest side card.',
      focusLabels: <String>['Same hand', 'Kicker'],
    ),
  ],
);

final _world2KickerRecapRunner = _showdownKickerRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w2_kicker_recap',
  lessonTitle: 'Kicker decides',
  lessonSubtitle: 'Hand Value And Position',
  caption: 'Lesson learned: ties need a clean tiebreak.',
  hint: 'Use kickers only when they are part of the best five.',
  question: 'What breaks some matching-hand ties?',
  feedbackTitle: 'Kicker takeaway.',
  feedbackReason:
      'When two players share the same made hand, the best side card can decide the pot.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Kicker checklist.',
      body: 'Match the made hand first, then compare the best side card.',
      focusLabels: <String>['Made hand', 'Side card'],
    ),
  ],
);

final _world2BoardIntroRunner = _boardPlaysRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w2_board_intro',
  lessonTitle: 'Board plays',
  lessonSubtitle: 'Hand Value And Position',
  caption: 'Shared board cards can sometimes make the best hand.',
  hint:
      'If private cards do not improve, both players may share the same five.',
  question: 'What can happen when the same board plays?',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'The board is shared.',
      body: 'If the board makes the best five, private cards may not matter.',
      focusLabels: <String>['Shared board', 'Same five'],
    ),
  ],
);

final _world2BoardRecapRunner = _tiePotRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w2_board_recap',
  lessonTitle: 'Board plays',
  lessonSubtitle: 'Hand Value And Position',
  caption: 'Lesson learned: shared cards can split the pot.',
  hint: 'A tie is normal when both players use the same best five.',
  question: 'What happens when both players tie?',
  feedbackTitle: 'Board takeaway.',
  feedbackReason:
      'When both players have the same best five-card hand, the pot is split instead of awarded by seat.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Board-play checklist.',
      body: 'Check if private cards improve the board. If not, ties can split.',
      focusLabels: <String>['Private cards', 'Shared five', 'Split'],
    ),
  ],
);

final _world2PositionIntroRunner = _latePositionRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w2_position_intro',
  lessonTitle: 'Position changes value',
  lessonSubtitle: 'Hand Value And Position',
  caption: 'The same hand feels different from early and late seats.',
  hint: 'Late seats act after seeing more decisions.',
  question: 'Which seat usually has more information before acting?',
  options: _laterSeatChoices,
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Position is information.',
      body: 'Early seats decide sooner. Late seats see more before acting.',
      focusSeatIds: <String>['utg', 'btn'],
      focusLabels: <String>['Early', 'Late'],
    ),
  ],
);

final _world2PositionRecapRunner = _positionsRecapRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w2_position_recap',
  lessonTitle: 'Position changes value',
  lessonSubtitle: 'Hand Value And Position',
  caption: 'Lesson learned: hand value depends on seat context.',
  hint: 'Read the seat labels clockwise from CO.',
  question: 'Which seat sits between CO and the small blind?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'top',
      label: 'UTG',
      seatId: 'utg',
      isCorrect: false,
      preferredLabel: 'BTN',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Read the seating order.',
      feedbackReason: 'UTG sits between the big blind and HJ.',
    ),
    Act0RunnerOptionV1(
      id: 'bottom',
      label: 'BTN',
      seatId: 'btn',
      isCorrect: true,
      preferredLabel: 'BTN',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Clockwise order found.',
      feedbackReason:
          'Clockwise from CO, BTN is next, followed by the small blind.',
    ),
    Act0RunnerOptionV1(
      id: 'random',
      label: 'BB',
      seatId: 'bb',
      isCorrect: false,
      preferredLabel: 'BTN',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Read the seating order.',
      feedbackReason:
          'BB sits after the small blind, clockwise from the Button.',
    ),
  ],
  feedbackTitle: 'Position-value takeaway.',
  feedbackReason:
      'Hand strength is not the whole decision. Seat position changes how much information you have.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Position-value checklist.',
      body: 'Name the seat, note who acts first, then compare the hand.',
      focusSeatIds: <String>['utg', 'btn'],
      focusLabels: <String>['Seat', 'Order', 'Hand'],
    ),
  ],
);

final _world2InitiativeIntroRunner = _actionTrailRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w2_initiative_intro',
  lessonTitle: 'Who has initiative?',
  lessonSubtitle: 'Hand Value And Position',
  caption: 'Initiative starts with the last aggressive action.',
  hint: 'For now, track who raised or bet most recently.',
  question: 'Who usually has initiative here?',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Last aggressor matters.',
      body: 'The player who last raised or bet is the aggressor for this spot.',
      focusLabels: <String>['Raise', 'Bet', 'Aggressor'],
    ),
  ],
);

final _world2InitiativeDrillRunner = _actionTrailRunner.copyWith(
  lessonId: 'w2_initiative_find',
  lessonTitle: 'Who has initiative?',
  lessonSubtitle: 'Hand Value And Position',
  caption: 'BTN raised before the flop and BB called.',
  hint: 'The raiser, not the caller, has initiative.',
  question: 'Who has initiative?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'btn',
      label: 'BTN',
      seatId: 'btn',
      isCorrect: true,
      preferredLabel: 'BTN',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'UTG is the early seat.',
      feedbackReason: 'BTN made the aggressive raise. BB only called.',
    ),
    Act0RunnerOptionV1(
      id: 'bb',
      label: 'BB',
      seatId: 'bb',
      isCorrect: false,
      preferredLabel: 'BTN',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'Calling continues the hand, but the raise gives BTN initiative.',
    ),
  ],
  table: _actionTrailRunner.table.copyWith(
    activeSeatId: 'btn',
    highlightedSeatIds: const <String>['btn', 'bb'],
    selectableSeatIds: const <String>['btn', 'bb'],
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Raise beats call for initiative.',
      body: 'BTN raised. BB called. Track the last aggressive action.',
      focusSeatIds: <String>['btn', 'bb'],
      focusLabels: <String>['BTN raises', 'BB calls'],
    ),
  ],
);

final _world2InitiativeActiveRunner = _world2InitiativeDrillRunner.copyWith(
  lessonId: 'w2_initiative_active',
  caption: 'Now action is on BB after BTN showed aggression.',
  hint:
      'Active seat is who must decide now; initiative is who applied pressure.',
  question: 'Who must act now?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'bb',
      label: 'BB',
      seatId: 'bb',
      isCorrect: true,
      preferredLabel: 'BB',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Sharp read.',
      feedbackReason: 'BB is active now, even though BTN has initiative.',
    ),
    Act0RunnerOptionV1(
      id: 'btn',
      label: 'BTN',
      seatId: 'btn',
      isCorrect: false,
      preferredLabel: 'BB',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason: 'BTN has initiative, but BB is the active seat now.',
    ),
  ],
  table: _actionTrailRunner.table.copyWith(
    activeSeatId: 'bb',
    highlightedSeatIds: const <String>['btn', 'bb'],
    selectableSeatIds: const <String>['btn', 'bb'],
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Active seat is different.',
      body: 'Initiative says who pressured. Active seat says who acts now.',
      focusSeatIds: <String>['btn', 'bb'],
      focusLabels: <String>['Initiative', 'Active'],
    ),
  ],
);

final _world2InitiativeRecapRunner = _world2InitiativeDrillRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w2_initiative_recap',
  caption: 'Lesson learned: track pressure and current action separately.',
  hint: 'Aggressor applied pressure; active player chooses now.',
  question: 'What gives a player initiative?',
  feedbackTitle: 'Initiative takeaway.',
  feedbackReason:
      'A raise or bet is the simple beginner signal for initiative. The active seat is still read from the current table state.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Initiative checklist.',
      body:
          'Read the action history, find the last bet or raise, then find who acts now.',
      focusLabels: <String>['History', 'Aggressor', 'Active seat'],
    ),
  ],
);

final _world2CheckpointIntroRunner = _world2ShowdownIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w2_checkpoint_intro',
  lessonTitle: 'Hand value checkpoint',
  lessonSubtitle: 'Hand Value And Position',
  caption: 'Checkpoint: compare hand, position, and initiative together.',
  hint: 'Keep it simple: hand first, seat second, action history third.',
  question: 'What three checks matter here?',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Bridge checklist.',
      body: 'Compare the hand, name the seat, then read who applied pressure.',
      focusLabels: <String>['Hand', 'Position', 'Initiative'],
    ),
  ],
);

final _world2CheckpointRunner = _world2InitiativeDrillRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w2_checkpoint_review',
  lessonTitle: 'Hand value checkpoint',
  lessonSubtitle: 'Hand Value And Position',
  caption: 'Lesson learned: good decisions start with context.',
  hint:
      'Hand value, position, and initiative are the bridge to preflop basics.',
  question: 'What should you read before choosing?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'context',
      label: 'Hand, seat, action',
      isCorrect: true,
      preferredLabel: 'Hand, seat, action',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Strong choice.',
      feedbackReason:
          'Read hand value, position, and initiative before moving into strategy.',
    ),
    Act0RunnerOptionV1(
      id: 'seat_only',
      label: 'Seat only',
      isCorrect: false,
      preferredLabel: 'Hand, seat, action',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason: 'Seat matters, but it is only one part of the context.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'World 2 bridge.',
      body: 'You can now compare showdowns and read basic table context.',
      focusLabels: <String>['Showdown', 'Position', 'Initiative'],
    ),
  ],
);

final _world3BucketsIntroRunner = _whatYouCanDoRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w3_buckets_intro',
  lessonTitle: 'Hand buckets',
  lessonSubtitle: 'Preflop Basics',
  caption: 'Preflop starts by sorting the hand into a simple bucket.',
  hint:
      'Hand code writes the two ranks together. T means ten, s means suited, and o means offsuit.',
  question: 'What should you name before the action?',
  options: const <Act0RunnerOptionV1>[],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Groups and seats, before a raise.',
      body:
          'T means ten. Suited means same suit (s); offsuit means different suits (o).\n\n'
          'Sharky 6-max starting chart. Open means the first raise preflop.\n\n'
          'Premium: AA–QQ, AK suited (UTG–BTN).\n\n'
          'Strong: JJ–TT, AK offsuit, AQ suited, AJ suited (UTG–BTN).\n\n'
          'Medium: AQ offsuit, AJ offsuit, KQ, AT (HJ–BTN).\n\n'
          'Medium: 99–22, KJ, QJ, KT, QT (CO–BTN).\n\n'
          'Weak: other hands (Fold).',
    ),
    Act0TeachingStepV1(
      title: 'On BTN after a raise.',
      body:
          'BTN vs one HJ/CO open: call AQo, AJo, KQs, KQo, ATs, ATo, KJs, QJs. Fold other Medium and Weak hands.',
    ),
  ],
);

final _world3PremiumBucketRunner = _world3BucketsIntroRunner.copyWith(
  lessonId: 'w3_premium_bucket',
  caption: 'You hold A♠ A♥ before the flop.',
  hint: 'Start from the two-card strength before choosing the bucket.',
  question: 'Which bucket is AA?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'premium',
      label: 'Premium',
      isCorrect: true,
      preferredLabel: 'Premium',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Solid understanding.',
      feedbackReason:
          'AA belongs to premium pairs and usually raises to grow the pot with the best hand.',
    ),
    Act0RunnerOptionV1(
      id: 'medium',
      label: 'Medium',
      isCorrect: false,
      preferredLabel: 'Premium',
      betterAnswerLabel: 'Premium',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason: 'AA is stronger than a medium hand.',
    ),
    Act0RunnerOptionV1(
      id: 'strong',
      label: 'Strong',
      isCorrect: false,
      preferredLabel: 'Premium',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Check the clue again.',
      feedbackReason:
          'The chart puts aces with kings and queens in Premium. Strong starts below that group.',
    ),
  ],
  table: _whatYouCanDoRunner.table.copyWith(
    heroCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'A', suit: 's'),
      Act0CardStateV1(rank: 'A', suit: 'h'),
    ],
    centerLabel: 'Pocket aces',
    highlightedCardIds: const <String>['hero_0', 'hero_1'],
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Premium means top bucket.',
      body: 'AA starts in the premium bucket before context changes anything.',
      focusCardIds: <String>['hero_0', 'hero_1'],
      focusLabels: <String>['AA', 'Premium'],
    ),
  ],
);

final _world3TrashBucketRunner = _world3BucketsIntroRunner.copyWith(
  lessonId: 'w3_trash_bucket',
  caption: 'J8o is a weak offsuit starter from early position.',
  hint: 'Weak early hands should not be forced into action.',
  question: 'Which bucket fits J8o early?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'trash',
      label: 'Weak',
      isCorrect: true,
      preferredLabel: 'Weak',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Well done.',
      feedbackReason: 'J8o from early position belongs in the weak bucket.',
    ),
    Act0RunnerOptionV1(
      id: 'strong',
      label: 'Strong',
      isCorrect: false,
      preferredLabel: 'Weak',
      betterAnswerLabel: 'Weak',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason: 'Offsuit disconnected hands are not strong starters.',
    ),
    Act0RunnerOptionV1(
      id: 'medium',
      label: 'Medium',
      isCorrect: false,
      preferredLabel: 'Weak',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Check the clue again.',
      feedbackReason:
          'J8o is not in any chart row, so it belongs in Weak. The only jack hands in Medium are KJ, QJ, and AJo.',
    ),
  ],
  table: _act0ReassignHeroSeatV1(
    _whatYouCanDoRunner.table.copyWith(
      seats: _act0WithAuthoredPreActionSeatsV1(_whatYouCanDoRunner.table).seats,
      heroCards: const <Act0CardStateV1>[
        Act0CardStateV1(rank: 'J', suit: 's'),
        Act0CardStateV1(rank: '8', suit: 'd'),
      ],
      centerLabel: 'J8o early',
      handContributions: _act0UnopenedPriceContributionsV1('utg'),
      actionTrail: const <Act0ActionTrailItemV1>[
        Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
        Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
        Act0ActionTrailItemV1(label: 'UTG acts'),
      ],
      highlightedSeatIds: const <String>['utg'],
      highlightedCardIds: const <String>['hero_0', 'hero_1'],
    ),
    heroSeatId: 'utg',
    activeSeatId: 'utg',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Weak and early is trouble.',
      body: 'J8o has little help, especially before seeing others act.',
      focusSeatIds: <String>['utg'],
      focusCardIds: <String>['hero_0', 'hero_1'],
      focusLabels: <String>['J8o', 'Early'],
    ),
  ],
);

final _world3BucketsRecapRunner = _world3BucketsIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w3_buckets_recap',
  caption: 'Lesson learned: bucket the hand before the action.',
  hint: 'Premium, strong, medium, or weak is the first preflop read.',
  question: 'What is the first preflop habit?',
  feedbackTitle: 'Bucket takeaway.',
  feedbackReason:
      'Preflop choices get calmer when you name the hand bucket before choosing open, call, or fold.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Bucket checklist.',
      body: 'Name the hand bucket, then read position and action frame.',
      focusLabels: <String>['Bucket', 'Position', 'Frame'],
    ),
  ],
);

final _world3FirstInIntroRunner = _whatYouCanDoRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w3_first_in_intro',
  lessonTitle: 'First-in open',
  lessonSubtitle: 'Preflop Basics',
  caption: 'First in means nobody has entered the pot yet.',
  hint: 'You can limp by calling the blind, but open or fold is cleaner.',
  question: 'What is cleaner than limping first in?',
  options: const <Act0RunnerOptionV1>[],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Unopened pot.',
      body:
          'When nobody entered, raising is called opening. Calling is limping.',
      focusLabels: <String>['Nobody entered', 'Open cleaner'],
    ),
  ],
);

const _sharkyOpenChartChoices = <Act0RunnerOptionV1>[
  Act0RunnerOptionV1(
    id: 'fold',
    label: 'Fold',
    isCorrect: false,
    preferredLabel: 'Raise',
    quality: Act0FeedbackQualityV1.wrong,
    feedbackTitle: 'The chart gives this hand an open.',
    feedbackReason:
        'This hand and seat appear in the starting chart, so raise when nobody has raised.',
  ),
  Act0RunnerOptionV1(
    id: 'call',
    label: 'Call',
    amountLabel: '1 BB',
    isCorrect: false,
    preferredLabel: 'Raise',
    quality: Act0FeedbackQualityV1.suboptimal,
    feedbackTitle: 'Calling matches the big blind.',
    feedbackReason:
        'Calling is allowed, but the starting chart raises this hand from this seat.',
  ),
  Act0RunnerOptionV1(
    id: 'raise',
    label: 'Raise',
    amountLabel: '3 BB',
    isCorrect: true,
    preferredLabel: 'Raise',
    quality: Act0FeedbackQualityV1.correct,
    feedbackTitle: 'That hand and seat fit the chart.',
    feedbackReason:
        "With BTN first in, a raise lets you win the blinds when they fold. Calling leaves BB a free check and SB a cheaper entry.",
  ),
];

final _world3ButtonOpenRunner = _whatYouCanDoRunner.copyWith(
  lessonId: 'w3_button_open',
  lessonTitle: 'First-in open',
  lessonSubtitle: 'Preflop Basics',
  caption: 'Folded to BTN with KTs.',
  hint: 'First in and late position: opening is the clean action.',
  question: 'By the Sharky starting chart, what is the simple first-in action?',
  options: _sharkyOpenChartChoices,
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Late playable hand.',
      body: 'KTs on the Button is playable when nobody entered.',
      focusSeatIds: <String>['btn'],
      focusCardIds: <String>['hero_0', 'hero_1'],
      focusLabels: <String>['KTs', 'Open'],
    ),
  ],
);

final _world3ButtonOpenQtsRunner = _world3ButtonOpenRunner.copyWith(
  lessonId: 'w3_button_open_qts',
  caption: 'Folded to BTN with QTs.',
  hint:
      'Same late seat, different playable hand, same clean open-or-fold rule.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Late playable hand.',
      body: 'QTs can still open first in from the Button.',
      focusSeatIds: <String>['btn'],
      focusCardIds: <String>['hero_0', 'hero_1'],
      focusLabels: <String>['QTs', 'Open'],
    ),
  ],
  table: _world3ButtonOpenRunner.table.copyWith(
    heroCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'Q', suit: 's'),
      Act0CardStateV1(rank: 'T', suit: 's'),
    ],
    seats: _world3ButtonOpenRunner.table.seats
        .map(
          (seat) => seat.seatId == 'btn'
              ? _act0CopySeatStateV1(
                  seat,
                  holeCards: const <Act0CardStateV1>[
                    Act0CardStateV1(rank: 'Q', suit: 's'),
                    Act0CardStateV1(rank: 'T', suit: 's'),
                  ],
                )
              : seat,
        )
        .toList(growable: false),
  ),
);

final _world3CutoffOpenRunner = _world3ButtonOpenRunner.copyWith(
  lessonId: 'w3_cutoff_open',
  caption: 'Folded to CO with AJo.',
  hint: 'Cutoff is late, but Button and blinds still remain behind.',
  question:
      'By the Sharky starting chart, what is the cleaner first-in action from CO?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'raise',
      label: 'Raise',
      amountLabel: '2.5 BB',
      isCorrect: true,
      preferredLabel: 'Raise',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Clean execution.',
      feedbackReason:
          "Raise AJo from CO because only BTN and the blinds can respond, and weaker aces can call. Calling lets the blinds see the flop more cheaply.",
    ),
    Act0RunnerOptionV1(
      id: 'call',
      label: 'Call',
      amountLabel: '1 BB',
      isCorrect: false,
      preferredLabel: 'Raise',
      betterAnswerLabel: 'Raise',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Legal, but passive.',
      feedbackReason:
          'Calling first in is still a limp. Cutoff is late enough to open the playable hand cleanly.',
    ),
    Act0RunnerOptionV1(
      id: 'fold',
      label: 'Fold',
      isCorrect: false,
      preferredLabel: 'Raise',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Check the clue again.',
      feedbackReason:
          'Ace-jack offsuit is Medium. With everyone folded to the cutoff, this chart opens it.',
    ),
  ],
  table: _act0ReassignHeroSeatV1(
    _world3ButtonOpenRunner.table.copyWith(
      seats: _act0WithAuthoredPreActionSeatsV1(
        _world3ButtonOpenRunner.table,
        foldedSeatIds: const <String>{'utg', 'hj'},
      ).seats,
      heroCards: const <Act0CardStateV1>[
        Act0CardStateV1(rank: 'A', suit: 'd'),
        Act0CardStateV1(rank: 'J', suit: 'c'),
      ],
      activeSeatId: 'co',
      highlightedSeatIds: const <String>['co', 'btn', 'sb', 'bb'],
      centerLabel: 'Folded to CO',
      handContributions: _act0UnopenedPriceContributionsV1('co'),
      actionTrail: const <Act0ActionTrailItemV1>[
        Act0ActionTrailItemV1(label: 'UTG folds'),
        Act0ActionTrailItemV1(label: 'HJ folds'),
        Act0ActionTrailItemV1(label: 'CO acts'),
      ],
    ),
    heroSeatId: 'co',
    activeSeatId: 'co',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Late, but not last.',
      body:
          'AJo can open from CO, but you still respect the Button behind you.',
      focusSeatIds: <String>['co', 'btn'],
      focusCardIds: <String>['hero_0', 'hero_1'],
      focusLabels: <String>['CO', 'BTN behind', 'Open'],
    ),
  ],
);

final _world3ButtonOpenA9sRunner = _world3ButtonOpenRunner.copyWith(
  lessonId: 'w3_button_open_a9s',
  caption: 'Folded to BTN with A9s.',
  hint: 'Button still opens the playable suited ace when nobody entered.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Playable suited ace.',
      body: 'A9s can still open first in when the Button is the acting seat.',
      focusSeatIds: <String>['btn'],
      focusCardIds: <String>['hero_0', 'hero_1'],
      focusLabels: <String>['A9s', 'Open'],
    ),
  ],
  table: _world3ButtonOpenRunner.table.copyWith(
    heroCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'A', suit: 's'),
      Act0CardStateV1(rank: '9', suit: 's'),
    ],
    seats: _world3ButtonOpenRunner.table.seats
        .map(
          (seat) => seat.seatId == 'btn'
              ? _act0CopySeatStateV1(
                  seat,
                  holeCards: const <Act0CardStateV1>[
                    Act0CardStateV1(rank: 'A', suit: 's'),
                    Act0CardStateV1(rank: '9', suit: 's'),
                  ],
                )
              : seat,
        )
        .toList(growable: false),
  ),
);

final _world3CutoffOpenKJsRunner = _world3CutoffOpenRunner.copyWith(
  lessonId: 'w3_cutoff_open_kjs',
  caption: 'Folded to CO with KJs.',
  hint: 'Still a late playable hand, but one seat earlier than the Button.',
  table: _act0ReassignHeroSeatV1(
    _world3CutoffOpenRunner.table.copyWith(
      heroCards: const <Act0CardStateV1>[
        Act0CardStateV1(rank: 'K', suit: 's'),
        Act0CardStateV1(rank: 'J', suit: 's'),
      ],
    ),
    heroSeatId: 'co',
    activeSeatId: 'co',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Cutoff still opens.',
      body:
          'KJs stays playable first in from CO, but the Button still matters.',
      focusSeatIds: <String>['co', 'btn'],
      focusCardIds: <String>['hero_0', 'hero_1'],
      focusLabels: <String>['CO', 'KJs', 'Open'],
    ),
  ],
);

final _world3EarlyFoldRunner = _world3TrashBucketRunner.copyWith(
  lessonId: 'w3_early_fold',
  lessonTitle: 'First-in open',
  lessonSubtitle: 'Preflop Basics',
  caption: 'Unopened pot. You act early with J8o.',
  hint: 'Early position removes the comfort from weak offsuit hands.',
  question: 'By the Sharky starting chart, what is the clean action?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'fold',
      label: 'Fold',
      isCorrect: true,
      preferredLabel: 'Fold',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Excellent spot.',
      feedbackReason:
          "At UTG with a weak offsuit hand, five players can raise after you, so folding saves the chips a call would risk.",
    ),
    Act0RunnerOptionV1(
      id: 'raise',
      label: 'Raise',
      isCorrect: false,
      preferredLabel: 'Fold',
      betterAnswerLabel: 'Fold',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason: 'Position is early and the hand bucket is too weak.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Discipline is allowed.',
      body: 'Opening weak early hands creates hard spots later.',
      focusSeatIds: <String>['utg'],
      focusLabels: <String>['Early', 'Fold'],
    ),
  ],
);

final _world3FirstInRecapRunner = _world3ButtonOpenRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w3_first_in_recap',
  caption: 'Lesson learned: first in means open or fold.',
  hint: 'Calling the blind is a limp; it is legal, but not the clean default.',
  question: 'What is the passive first-in action?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'call',
      label: 'Call',
      isCorrect: true,
      preferredLabel: 'Call',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Spot on.',
      feedbackReason:
          'Calling first in is limping. It is legal, but usually weaker than a clean open-or-fold habit.',
    ),
    Act0RunnerOptionV1(
      id: 'fold',
      label: 'Fold',
      isCorrect: false,
      preferredLabel: 'Call',
      betterAnswerLabel: 'Call',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'Folding is legal first in. Calling is the passive limp this question asks for.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'First-in takeaway.',
      body: 'Unopened pots ask whether to open or let the hand go.',
      focusLabels: <String>['Open', 'Fold', 'Limp passive'],
    ),
  ],
);

final _world3FacingOpenIntroRunner = _world3FirstInIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w3_facing_open_intro',
  lessonTitle: 'Facing an open',
  caption: 'Facing an open means someone raised before you.',
  hint: 'Now calling can exist, and weak continues can fold.',
  question: 'What changed from first in?',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'The frame changed.',
      body: 'An opener created a price. Now call or fold can be natural.',
      focusLabels: <String>['Facing open', 'Price'],
    ),
  ],
);

// Later worlds still author scenes on the original table scaffold.
final _legacyFacingOpenTableV1 = _callActionRunner.table.copyWith(
  heroCards: const <Act0CardStateV1>[
    Act0CardStateV1(rank: 'K', suit: 'd'),
    Act0CardStateV1(rank: 'Q', suit: 'c'),
  ],
  boardCards: const <Act0CardStateV1>[],
  highlightedCardIds: const ['hero_0', 'hero_1'],
  streetLabel: 'Preflop',
  potLabel: 'Pot 4 BB',
  toCallLabel: 'To call 2.5 BB',
  centerLabel: 'CO opened',
  actionTrail: const <Act0ActionTrailItemV1>[
    Act0ActionTrailItemV1(label: 'CO opens 2.5 BB'),
    Act0ActionTrailItemV1(label: 'BTN acts'),
  ],
  activeSeatId: 'btn',
  highlightedSeatIds: const <String>['co', 'btn'],
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
      bet: _coOpen25Bb,
      holeCards: _unknownHoleCards,
    ),
    Act0SeatStateV1(
      seatId: 'btn',
      seatLabel: 'BTN',
      displayName: 'Hero',
      isHero: true,
      isDealerButton: true,
      holeCards: _heroKqCards,
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
);

String _act0BbLabelV1(num amount) =>
    '${amount.toString().replaceFirst(RegExp(r'\.0$'), '')} BB';

Act0TableStateV1 _act0FacingOpenTableV1(
  Act0TableStateV1 source, {
  required String opener,
  String hero = 'btn',
  num openingBb = 2.5,
}) {
  final size = _act0BbLabelV1(openingBb);
  final open = openingBb == 2.5
      ? (opener == 'hj' ? _hjOpen25Bb : _coOpen25Bb)
      : Act0SeatBetStateV1(
          kind: Act0SeatBetKindV1.raise,
          label: opener.toUpperCase(),
          amountLabel: size,
        );
  final folded = {
    'utg',
    if (opener == 'co') 'hj',
    if (opener == 'hj' && hero == 'btn') 'co',
  };
  return source.copyWith(
    boardCards: const [],
    streetLabel: 'Preflop',
    potLabel: 'Pot ${_act0BbLabelV1(openingBb + 1.5)}',
    toCallLabel: 'To call $size',
    activeSeatId: hero,
    heroSeatId: hero,
    handContributions: Act0HandContributionsV1(
      throughStreet: PokerStreet.preflop,
      startingStackBbBySeat: {hero: 100},
      entries: [
        ..._act0LessonBlinds,
        Act0ContributionV1(
          PokerStreet.preflop,
          opener,
          Act0ContributionKindV1.wager,
          openingBb.toDouble(),
        ),
      ],
    ),
    actionTrail: [
      const Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
      const Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
      const Act0ActionTrailItemV1(label: 'UTG folds'),
      if (opener == 'co') const Act0ActionTrailItemV1(label: 'HJ folds'),
      Act0ActionTrailItemV1(label: '${opener.toUpperCase()} opens $size'),
      if (opener == 'hj' && hero == 'btn')
        const Act0ActionTrailItemV1(label: 'CO folds'),
      Act0ActionTrailItemV1.note(label: '${hero.toUpperCase()} acts'),
    ],
    seats: [
      for (final seat in source.seats)
        Act0SeatStateV1(
          seatId: seat.seatId,
          seatLabel: seat.seatLabel,
          displayName: seat.seatId == hero
              ? 'Hero'
              : _act0DefaultSeatDisplayNameV1(seat),
          isHero: seat.seatId == hero,
          isDealerButton: seat.seatId == 'btn',
          isSmallBlind: seat.seatId == 'sb',
          isBigBlind: seat.seatId == 'bb',
          isActive: seat.seatId == hero,
          isInHand: !folded.contains(seat.seatId),
          isFolded: folded.contains(seat.seatId),
          hasActed: seat.seatId == opener || folded.contains(seat.seatId),
          isLastAggressor: seat.seatId == opener,
          blindAmountLabel: switch (seat.seatId) {
            'sb' => '0.5 BB',
            'bb' => '1 BB',
            _ => null,
          },
          stackLabel: switch (seat.seatId) {
            'sb' => '99.5 BB',
            'bb' => '99 BB',
            _ when seat.seatId == opener =>
              '${_act0BbLabelV1(100 - openingBb)}',
            _ => '100 BB',
          },
          bet: switch (seat.seatId) {
            'sb' => _smallBlindPost,
            'bb' => _bigBlindPost,
            _ when seat.seatId == opener => open,
            _ => null,
          },
          currentBetLabel: switch (seat.seatId) {
            'sb' => '0.5 BB',
            'bb' => '1 BB',
            _ when seat.seatId == opener => size,
            _ => null,
          },
          holeCards: seat.seatId == hero ? source.heroCards : _unknownHoleCards,
          cardsVisibleMode: folded.contains(seat.seatId)
              ? Act0CardsVisibleModeV1.none
              : seat.seatId == hero
              ? Act0CardsVisibleModeV1.faceUp
              : Act0CardsVisibleModeV1.faceDown,
        ),
    ],
  );
}

const _kqoButtonFacingRaiseChoices = <Act0RunnerOptionV1>[
  Act0RunnerOptionV1(
    id: 'call',
    label: 'Call',
    amountLabel: '2.5 BB',
    isCorrect: true,
    preferredLabel: 'Call',
    quality: Act0FeedbackQualityV1.correct,
    feedbackTitle: 'Clean execution.',
    feedbackReason:
        "Call 2.5 BB with KQo on BTN because CO can open weaker kings such as KJo and KTs, and you see CO’s decisions before yours. A reraise risks more against stronger hands that continue.",
  ),
  Act0RunnerOptionV1(
    id: 'fold',
    label: 'Fold',
    isCorrect: false,
    preferredLabel: 'Call',
    betterAnswerLabel: 'Call',
    quality: Act0FeedbackQualityV1.wrong,
    feedbackTitle: 'Not quite.',
    feedbackReason:
        'Folding is too tight here. BTN versus a CO open, KQo can continue in position.',
  ),
];

final _world3PlayableCallRunner = _callActionRunner.copyWith(
  lessonId: 'w3_playable_call',
  lessonTitle: 'Facing an open',
  lessonSubtitle: 'Preflop Basics',
  caption: 'CO opened. You are BTN with KQo.',
  hint: 'Playable hand in position: call keeps the hand in.',
  question: 'By the Sharky starting chart, what is the simple response?',
  options: _kqoButtonFacingRaiseChoices,
  table: _act0FacingOpenTableV1(
    _callActionRunner.table.copyWith(
      heroCards: _heroKqCards,
      highlightedCardIds: const ['hero_0', 'hero_1'],
      centerLabel: 'CO opened',
    ),
    opener: 'co',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Playable and in position.',
      body: 'KQo can call a simple open when you act after CO.',
      focusSeatIds: <String>['co', 'btn'],
      focusCardIds: <String>['hero_0', 'hero_1'],
      focusLabels: <String>['CO opens', 'BTN calls'],
    ),
  ],
);

final _world2StrongContinueRunner = _world3PlayableCallRunner.copyWith(
  lessonId: 'w2_strong_continue_kqo',
  caption: 'HJ opened. You are BTN with KQo.',
  hint:
      'Broadway cards are T, J, Q, K, and A. One seat earlier from the opener still leaves you in position with a playable broadway.',
  question:
      'By the Sharky starting chart, what is your decision in this model?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'call',
      label: 'Call',
      amountLabel: '2.5 BB',
      isCorrect: true,
      preferredLabel: 'Call',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Clean execution.',
      feedbackReason:
          "Call 2.5 BB with KQo on BTN because you see HJ’s decisions before yours on later rounds. HJ can continue against a reraise with strong aces or high pairs, so raising risks more.",
    ),
    Act0RunnerOptionV1(
      id: 'fold',
      label: 'Fold',
      isCorrect: false,
      preferredLabel: 'Call',
      betterAnswerLabel: 'Call',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'Folding is still too tight. KQo keeps enough strength and position against an HJ open.',
    ),
  ],
  table: _act0FacingOpenTableV1(
    _world3PlayableCallRunner.table.copyWith(centerLabel: 'HJ opened'),
    opener: 'hj',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Playable broadway, tighter opener.',
      body:
          'KQo is a broadway hand because both cards are broadway ranks. It still continues in position, but the opener seat is one step tighter now.',
      focusSeatIds: <String>['hj', 'btn'],
      focusCardIds: <String>['hero_0', 'hero_1'],
      focusLabels: <String>['Broadway = T J Q K A', 'HJ opens', 'BTN calls'],
    ),
  ],
);

final _world2KqoContrastRunner = _world3PlayableCallRunner.copyWith(
  lessonId: 'w2_kqo_contrast',
  caption: 'CO opened. You are BTN with KQo instead of A7o.',
  hint: 'Look for a shared rank, then compare the other card.',
  question: 'What is different about how these hands can be dominated?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'less_dominated',
      label: 'A7o shares an ace with AK and has the lower second card',
      isCorrect: true,
      preferredLabel: 'A7o shares an ace with AK and has the lower second card',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Strong contrast read.',
      feedbackReason:
          'A7o shares its ace with AK or AQ and has the lower second card. KQo avoids that specific comparison, but it can be dominated by AK or AQ itself.',
    ),
    Act0RunnerOptionV1(
      id: 'two_big_cards_auto',
      label: 'KQo shares its queen with AK and has the lower second card',
      isCorrect: false,
      preferredLabel: 'A7o shares an ace with AK and has the lower second card',
      betterAnswerLabel:
          'A7o shares an ace with AK and has the lower second card',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'AK has no queen. KQo shares its king with AK, and the queen loses to the ace.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Compare the hand class.',
      body:
          'Both hands can be dominated. Use the shared rank and compare the other card.',
      focusSeatIds: <String>['co', 'btn'],
      focusCardIds: <String>['hero_0', 'hero_1'],
      focusLabels: <String>['Shared rank', 'Second card'],
    ),
  ],
);

final _world2BorderlineContinueRunner = _world3PlayableCallRunner.copyWith(
  lessonId: 'w2_borderline_continue_qjs',
  caption: 'CO opened. You are BTN with QJs.',
  hint:
      'Playable suited broadways can continue, but the reason is still seat plus hand class.',
  question:
      'By the Sharky starting chart, what is your decision in this model?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'call',
      label: 'Call',
      amountLabel: '2.5 BB',
      isCorrect: true,
      preferredLabel: 'Call',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Clean execution.',
      feedbackReason:
          "Call 2.5 BB with QJs on BTN because you see CO’s decisions before yours. CO can call a reraise with stronger queens or higher pairs, so raising risks more.",
    ),
    Act0RunnerOptionV1(
      id: 'fold',
      label: 'Fold',
      isCorrect: false,
      preferredLabel: 'Call',
      betterAnswerLabel: 'Call',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'A bit too tight.',
      feedbackReason:
          'QJs keeps enough playability in position here, so folding gives up a workable continue.',
    ),
  ],
  table: _world3PlayableCallRunner.table.copyWith(
    heroCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'Q', suit: 's'),
      Act0CardStateV1(rank: 'J', suit: 's'),
    ],
    seats: _world3PlayableCallRunner.table.seats
        .map(
          (seat) => seat.seatId == 'btn'
              ? _act0CopySeatStateV1(
                  seat,
                  holeCards: const <Act0CardStateV1>[
                    Act0CardStateV1(rank: 'Q', suit: 's'),
                    Act0CardStateV1(rank: 'J', suit: 's'),
                  ],
                )
              : seat,
        )
        .toList(growable: false),
    centerLabel: 'Playable broadway',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Borderline but playable.',
      body:
          'QJs still continues from the Button because position and playability line up cleanly.',
      focusSeatIds: <String>['co', 'btn'],
      focusCardIds: <String>['hero_0', 'hero_1'],
      focusLabels: <String>['QJs', 'Button', 'Call'],
    ),
  ],
);

final _world3CutoffCallRunner = _world3PlayableCallRunner.copyWith(
  lessonId: 'w3_cutoff_call_kqo',
  caption: 'HJ opened. You are CO with KQo.',
  hint: 'Count which players have yet to respond to the opening raise.',
  question: 'Who still has to act after you on the first pass?',
  options: const [
    Act0RunnerOptionV1(
      id: 'players_behind',
      label: 'BTN, SB, and BB',
      isCorrect: true,
      preferredLabel: 'BTN, SB, and BB',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Three players are behind you.',
      feedbackReason:
          'HJ has raised and you act next from CO. BTN and both blinds still have their first response to make.',
    ),
    Act0RunnerOptionV1(
      id: 'blinds_only',
      label: 'SB and BB',
      isCorrect: false,
      preferredLabel: 'BTN, SB, and BB',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Include the button.',
      feedbackReason:
          'BTN sits between you and the blinds and has yet to respond to the raise.',
    ),
  ],
  table: _act0FacingOpenTableV1(
    _world2StrongContinueRunner.table,
    opener: 'hj',
    hero: 'co',
  ),
  teachingSteps: const [
    Act0TeachingStepV1(
      title: 'Who can act behind you?',
      body:
          'When you face a raise, check who still has a turn. Their actions can change the price and how many players see the flop.',
    ),
  ],
);

final _world3WeakFacingFoldPressureRunner = _world3WeakFacingFoldRunner
    .copyWith(
      lessonId: 'w3_weak_facing_fold_pressure',
      hint: 'Late position adds comfort, not permission.',
      question: 'By the Sharky starting chart, what does discipline say here?',
      options: _weakJackFacingRaiseChoices,
      teachingSteps: const <Act0TeachingStepV1>[
        Act0TeachingStepV1(
          title: 'Comfort is not a rescue.',
          body:
              'J8o stays too weak even when the Button acts after the opener.',
          focusSeatIds: <String>['btn'],
          focusCardIds: <String>['hero_0', 'hero_1'],
          focusLabels: <String>['J8o', 'Still fold'],
        ),
      ],
    );

final _world3PositionCheckpointCallRunner = _world3PlayableCallRunner.copyWith(
  lessonId: 'w3_position_btn_call_kjs',
  caption: 'HJ opened. You are BTN with KJs.',
  hint: 'Late position helps when the hand can still continue cleanly.',
  question: 'By the Sharky starting chart, what is the simple response?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'call',
      label: 'Call',
      amountLabel: '2.5 BB',
      isCorrect: true,
      preferredLabel: 'Call',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Sharp read.',
      feedbackReason:
          "Call 2.5 BB with KJs because BTN acts after HJ on every later round. A reraise risks more when HJ continues with better hands such as KQ or strong aces.",
    ),
    Act0RunnerOptionV1(
      id: 'fold',
      label: 'Fold',
      isCorrect: false,
      preferredLabel: 'Call',
      betterAnswerLabel: 'Call',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'KJs keeps enough strength and position here, so folding gives up a workable continue.',
    ),
  ],
  table: _world2StrongContinueRunner.table.copyWith(
    heroCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'K', suit: 's'),
      Act0CardStateV1(rank: 'J', suit: 's'),
    ],
    seats: _world2StrongContinueRunner.table.seats
        .map(
          (seat) => seat.seatId == 'btn'
              ? _act0CopySeatStateV1(
                  seat,
                  holeCards: const <Act0CardStateV1>[
                    Act0CardStateV1(rank: 'K', suit: 's'),
                    Act0CardStateV1(rank: 'J', suit: 's'),
                  ],
                )
              : seat,
        )
        .toList(growable: false),
    centerLabel: 'HJ opens, BTN decides',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Seat plus hand class.',
      body:
          'KJs is not just late-position noise. The hand still needs enough playability to continue cleanly.',
      focusSeatIds: <String>['hj', 'btn'],
      focusCardIds: <String>['hero_0', 'hero_1'],
      focusLabels: <String>['HJ opens', 'BTN', 'KJs'],
    ),
  ],
);

final _world4CallFrameRunner = _world3PlayableCallRunner.copyWith(
  lessonId: 'w4_call_frame_ajs',
  caption: 'CO opened. Hero is BTN with AJs.',
  hint:
      'Facing an open, late position can still continue with the stronger broadway hand.',
  question: 'What is the simple call-frame action?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'call',
      label: 'Call',
      amountLabel: '2.5 BB',
      isCorrect: true,
      preferredLabel: 'Call',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Frame read first.',
      feedbackReason: 'AJs on BTN can call here after a single CO raise.',
    ),
    Act0RunnerOptionV1(
      id: 'fold',
      label: 'Fold',
      isCorrect: false,
      preferredLabel: 'Call',
      betterAnswerLabel: 'Call',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too tight for the frame.',
      feedbackReason:
          'AJs keeps both strength and position here, so the cleaner frame is continue rather than fold.',
    ),
  ],
  table: _world3PlayableCallRunner.table.copyWith(
    heroCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'A', suit: 's'),
      Act0CardStateV1(rank: 'J', suit: 's'),
    ],
    seats: _world3PlayableCallRunner.table.seats
        .map(
          (seat) => seat.seatId == 'btn'
              ? _act0CopySeatStateV1(
                  seat,
                  holeCards: const <Act0CardStateV1>[
                    Act0CardStateV1(rank: 'A', suit: 's'),
                    Act0CardStateV1(rank: 'J', suit: 's'),
                  ],
                )
              : seat,
        )
        .toList(growable: false),
    centerLabel: 'Facing a CO open',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Call frame, not open frame.',
      body:
          'Once someone opened, AJs does not ask whether to open first in anymore.',
      focusSeatIds: <String>['co', 'btn'],
      focusCardIds: <String>['hero_0', 'hero_1'],
      focusLabels: <String>['Open already happened', 'Call frame'],
    ),
  ],
);

final _world4SameHandCallRunner = _world3PlayableCallRunner.copyWith(
  lessonId: 'w4_same_hand_call_qjs',
  caption: 'HJ opened. Hero is BTN with QJs.',
  hint: 'Same frame family, different opener seat and different playable hand.',
  question: 'What is the cleaner continue here?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'call',
      label: 'Call',
      amountLabel: '2.5 BB',
      isCorrect: true,
      preferredLabel: 'Call',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Clean frame read.',
      feedbackReason:
          'QJs still continues in position here, but you still start from seat plus frame before clicking call.',
    ),
    Act0RunnerOptionV1(
      id: 'fold',
      label: 'Fold',
      isCorrect: false,
      preferredLabel: 'Call',
      betterAnswerLabel: 'Call',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'A bit too cautious.',
      feedbackReason:
          'The frame changed because HJ opened first, but QJs on the Button still has enough playability to continue.',
    ),
  ],
  table: _world2StrongContinueRunner.table.copyWith(
    heroCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'Q', suit: 's'),
      Act0CardStateV1(rank: 'J', suit: 's'),
    ],
    seats: _world2StrongContinueRunner.table.seats
        .map(
          (seat) => seat.seatId == 'btn'
              ? _act0CopySeatStateV1(
                  seat,
                  holeCards: const <Act0CardStateV1>[
                    Act0CardStateV1(rank: 'Q', suit: 's'),
                    Act0CardStateV1(rank: 'J', suit: 's'),
                  ],
                )
              : seat,
        )
        .toList(growable: false),
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Frame first, then hand comfort.',
      body:
          'Same facing-open family, but the specific opener seat and hand class still matter.',
      focusSeatIds: <String>['hj', 'btn'],
      focusCardIds: <String>['hero_0', 'hero_1'],
      focusLabels: <String>['HJ opens', 'QJs', 'Call'],
    ),
  ],
);

const _weakJackFacingRaiseChoices = <Act0RunnerOptionV1>[
  Act0RunnerOptionV1(
    id: 'fold',
    label: 'Fold',
    isCorrect: true,
    preferredLabel: 'Fold',
    quality: Act0FeedbackQualityV1.correct,
    feedbackTitle: 'J8o still folds versus a CO open.',
    feedbackReason: 'BTN versus a CO open, J8o is still too weak to continue.',
  ),
  Act0RunnerOptionV1(
    id: 'call',
    label: 'Call',
    amountLabel: '2.5 BB',
    isCorrect: false,
    preferredLabel: 'Fold',
    betterAnswerLabel: 'Fold',
    quality: Act0FeedbackQualityV1.wrong,
    feedbackTitle: 'Not quite.',
    feedbackReason:
        'Late position helps, but J8o is still too weak versus a CO open.',
  ),
];

final _world3WeakFacingFoldRunner = _world3PlayableCallRunner.copyWith(
  lessonId: 'w3_weak_facing_fold',
  caption: 'CO opened. You are BTN with J8o.',
  hint: 'Position helps, but this hand is still too weak to continue.',
  question: 'By the Sharky starting chart, what is the clean response?',
  options: _weakJackFacingRaiseChoices,
  table: _world3PlayableCallRunner.table.copyWith(
    heroCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'J', suit: 's'),
      Act0CardStateV1(rank: '8', suit: 'd'),
    ],
    centerLabel: 'Weak continue?',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Position is not a free pass.',
      body: 'J8o still folds when the hand bucket is too weak.',
      focusSeatIds: <String>['btn'],
      focusCardIds: <String>['hero_0', 'hero_1'],
      focusLabels: <String>['Weak bucket', 'Fold'],
    ),
  ],
);

final _world3FacingOpenRecapRunner = _world3PlayableCallRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w3_facing_open_recap',
  caption: 'Lesson learned: facing an open creates a price.',
  hint: 'Playable hands can call; weak hands can still fold.',
  question:
      'By the Sharky starting chart, what is your decision facing the raise?',
  options: _kqoButtonFacingRaiseChoices,
  feedbackTitle: 'Facing-open takeaway.',
  feedbackReason:
      'Once someone opens, your first preflop read changes from open-or-fold to continue-or-fold.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Facing-open checklist.',
      body: 'Read the hand bucket, your position, and the price.',
      focusLabels: <String>['Bucket', 'Position', 'Price'],
    ),
  ],
);

final _world3PositionIntroRunner = _world2PositionIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w3_position_intro',
  lessonTitle: 'Position preflop',
  lessonSubtitle: 'Preflop Basics',
  caption: 'Position changes how comfortable a preflop hand is.',
  hint: 'Late position helps more than early position.',
  question: 'Which of these seats can see more decisions before its turn?',
  options: _laterSeatChoices,
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Position modifies the bucket.',
      body:
          'Late position can upgrade comfort. Early position demands discipline.',
      focusSeatIds: <String>['utg', 'btn'],
      focusLabels: <String>['Early', 'Late'],
    ),
  ],
);

const _additionalLateOpenChoices = <Act0RunnerOptionV1>[
  Act0RunnerOptionV1(
    id: 'call',
    label: 'Call',
    amountLabel: '1 BB',
    isCorrect: false,
    preferredLabel: 'Raise',
    quality: Act0FeedbackQualityV1.suboptimal,
    feedbackTitle: 'Calling matches the blind.',
    feedbackReason:
        'This hand and the BTN seat are in the opening part of the Sharky starting chart.',
  ),
  Act0RunnerOptionV1(
    id: 'raise',
    label: 'Raise',
    amountLabel: '3 BB',
    isCorrect: true,
    preferredLabel: 'Raise',
    quality: Act0FeedbackQualityV1.correct,
    feedbackTitle: 'Read the hand with the seat.',
    feedbackReason:
        "Raise from BTN because only SB and BB can respond, and they can fold weak hands. Calling lets BB see a cheap flop.",
  ),
];

final _world3LateOpenRunner = _world3ButtonOpenRunner.copyWith(
  lessonId: 'w3_late_position_open',
  lessonTitle: 'Position preflop',
  caption: 'Unopened pot. You act late with ATo.',
  hint: 'Late position supports a clean open with this playable hand.',
  question: 'By the Sharky starting chart, what is the simple action?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'raise',
      label: 'Raise',
      amountLabel: '2.5 BB',
      isCorrect: true,
      preferredLabel: 'Raise',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Sharp read.',
      feedbackReason:
          "With ATo on BTN, raise because only the blinds can call and may fold the pot to you. Calling lets BB see a cheap flop.",
    ),
    Act0RunnerOptionV1(
      id: 'call',
      label: 'Call',
      amountLabel: '1 BB',
      isCorrect: false,
      preferredLabel: 'Raise',
      betterAnswerLabel: 'Raise',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Limp is legal, raise is stronger.',
      feedbackReason:
          'Limping ATo is legal, but raising takes advantage of late position and puts pressure on the blinds.',
    ),
  ],
  table: _whatYouCanDoRunner.table.copyWith(
    heroCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'A', suit: 'd'),
      Act0CardStateV1(rank: 'T', suit: 'c'),
    ],
    centerLabel: 'Unopened pot',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Read the displayed hand and seat.',
      body:
          'ATo means ace-ten offsuit. The displayed cards are the ace of diamonds and ten of clubs. Read this hand with the Button seat and unopened-pot context.',
      focusSeatIds: <String>['btn'],
      focusCardIds: <String>['hero_0', 'hero_1'],
      focusLabels: <String>['ATo', 'BTN', 'Unopened pot'],
    ),
  ],
);

final _world3PositionDisciplineRunner = _world3EarlyFoldRunner.copyWith(
  lessonId: 'w3_position_not_free_pass',
  lessonTitle: 'Position preflop',
  caption: 'Unopened pot. You act early with ATo.',
  hint: 'The same hand is less comfortable from early position.',
  question: 'By the Sharky starting chart, what is the disciplined action?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'fold',
      label: 'Fold',
      isCorrect: true,
      preferredLabel: 'Fold',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Read the UTG row.',
      feedbackReason:
          "The Sharky starting chart folds ATo at UTG because five players can still raise or call with stronger aces. Limping risks 1 BB before they act.",
    ),
    Act0RunnerOptionV1(
      id: 'raise',
      label: 'Raise',
      isCorrect: false,
      preferredLabel: 'Fold',
      betterAnswerLabel: 'Fold',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Re-check ATo and UTG.',
      feedbackReason:
          'UTG is earlier than HJ, where the Sharky starting chart begins opening ATo.',
    ),
  ],
  table: _act0ReassignHeroSeatV1(
    _world3EarlyFoldRunner.table.copyWith(
      seats: _act0WithAuthoredPreActionSeatsV1(
        _world3EarlyFoldRunner.table,
      ).seats,
      heroCards: const <Act0CardStateV1>[
        Act0CardStateV1(rank: 'A', suit: 'd'),
        Act0CardStateV1(rank: 'T', suit: 'c'),
      ],
      centerLabel: 'Early position',
    ),
    heroSeatId: 'utg',
    activeSeatId: 'utg',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Same hand, worse seat.',
      body: 'Early position can turn a close hand into a fold.',
      focusSeatIds: <String>['utg'],
      focusCardIds: <String>['hero_0', 'hero_1'],
      focusLabels: <String>['ATo', 'Early'],
    ),
  ],
);

final _world3HijDisciplineRunner = _world3PositionDisciplineRunner.copyWith(
  lessonId: 'w3_hj_discipline_hold',
  caption: 'Unopened pot. You are HJ with KTo.',
  hint:
      'Middle position still needs discipline when the offsuit hand gets loose.',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'fold',
      label: 'Fold',
      isCorrect: true,
      preferredLabel: 'Fold',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Read the HJ row.',
      feedbackReason:
          "The Sharky starting chart folds KTo from HJ because CO, BTN and the blinds can raise or call with better kings. Limping pays 1 BB before they decide.",
    ),
    Act0RunnerOptionV1(
      id: 'raise',
      label: 'Raise',
      isCorrect: false,
      preferredLabel: 'Fold',
      betterAnswerLabel: 'Fold',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Re-check KTo and HJ.',
      feedbackReason:
          'HJ is before CO. The Sharky starting chart starts opening KTo from CO.',
    ),
  ],
  table: _act0ReassignHeroSeatV1(
    _world3PositionDisciplineRunner.table.copyWith(
      seats: _act0WithAuthoredPreActionSeatsV1(
        _world3PositionDisciplineRunner.table,
        foldedSeatIds: const <String>{'utg'},
      ).seats,
      heroCards: const <Act0CardStateV1>[
        Act0CardStateV1(rank: 'K', suit: 'd'),
        Act0CardStateV1(rank: 'T', suit: 'c'),
      ],
      centerLabel: 'Middle position',
      handContributions: _act0UnopenedPriceContributionsV1('hj'),
      actionTrail: const <Act0ActionTrailItemV1>[
        Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
        Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
        Act0ActionTrailItemV1(label: 'UTG folds'),
        Act0ActionTrailItemV1(label: 'HJ acts'),
      ],
    ),
    heroSeatId: 'hj',
    activeSeatId: 'hj',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Middle still needs discipline.',
      body:
          'On the Sharky chart, KTo opens from CO and BTN in an unopened pot.',
      focusSeatIds: <String>['hj'],
      focusCardIds: <String>['hero_0', 'hero_1'],
      focusLabels: <String>['KTo', 'HJ', 'Fold'],
    ),
  ],
);

final _world3CheckpointEarlyFoldRunner = _world3PositionDisciplineRunner.copyWith(
  lessonId: 'w3_checkpoint_early_fold_a9o',
  caption: 'Unopened pot. You are UTG with A9o.',
  hint: 'A tempting ace still needs an early-seat discipline check.',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'fold',
      label: 'Fold',
      isCorrect: true,
      preferredLabel: 'Fold',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Ace discipline applied.',
      feedbackReason:
          "The Sharky starting chart folds A9o at UTG because five players can still raise or call with stronger aces. Calling risks chips before they act.",
    ),
    Act0RunnerOptionV1(
      id: 'raise',
      label: 'Raise',
      isCorrect: false,
      preferredLabel: 'Fold',
      betterAnswerLabel: 'Fold',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Re-check A9o and UTG.',
      feedbackReason:
          'At UTG, the Sharky starting chart puts A9o in the Weak group. Ace-ten is in the next group.',
    ),
  ],
  table: _act0ReassignHeroSeatV1(
    _world3PositionDisciplineRunner.table.copyWith(
      heroCards: const <Act0CardStateV1>[
        Act0CardStateV1(rank: 'A', suit: 'c'),
        Act0CardStateV1(rank: '9', suit: 'd'),
      ],
      centerLabel: 'UTG discipline',
    ),
    heroSeatId: 'utg',
    activeSeatId: 'utg',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Tempting ace, same discipline.',
      body:
          'A9o still needs the early-seat fold because the seat is too exposed for a thin open.',
      focusSeatIds: <String>['utg'],
      focusCardIds: <String>['hero_0', 'hero_1'],
      focusLabels: <String>['A9o', 'UTG', 'Fold'],
    ),
  ],
);

final _w3LateSeatContrastRunner = _latePositionRunner.copyWith(
  lessonId: 'w3_late_seat_contrast',
  caption: 'Compare CO and BTN in this hand.',
  hint: 'Compare the two latest seats directly.',
  question:
      'Which of these seats acts later on the first pass before the flop?',
  table: _latePositionRunner.table.copyWith(
    selectableSeatIds: const ['btn', 'co'],
  ),
  options: const [
    Act0RunnerOptionV1(
      id: 'btn',
      label: 'BTN',
      seatId: 'btn',
      isCorrect: true,
      preferredLabel: 'BTN',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Button acts later.',
      feedbackReason: 'The first pass goes from CO to BTN, then to the blinds.',
    ),
    Act0RunnerOptionV1(
      id: 'co',
      label: 'CO',
      seatId: 'co',
      isCorrect: false,
      preferredLabel: 'BTN',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Follow the seats in order.',
      feedbackReason:
          'The cutoff acts before the button on the first preflop pass.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Late has levels.',
      body:
          'Cutoff is late, but Button still gets the final late-position edge.',
      focusSeatIds: <String>['co', 'btn'],
      focusLabels: <String>['CO', 'BTN'],
    ),
  ],
);

final _w3LateInfoEdgeRunner = _latePositionRunner.copyWith(
  lessonId: 'w3_late_info_edge',
  caption: 'CO already saw UTG and HJ fold before acting.',
  hint: 'Late comfort comes from fewer players left to act.',
  question: 'What gives CO more comfort than UTG here?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'fewer_behind',
      label: 'Fewer players still act after CO',
      isCorrect: true,
      preferredLabel: 'Fewer players still act after CO',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Excellent spot.',
      feedbackReason:
          'CO has already seen two folds. BTN, SB and BB still get a turn, so CO has more information without acting last.',
    ),
    Act0RunnerOptionV1(
      id: 'always_last',
      label: 'CO acts last before and after the flop',
      isCorrect: false,
      preferredLabel: 'Fewer players still act after CO',
      betterAnswerLabel: 'Fewer players still act after CO',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'CO is late, but BTN and the blinds still remain. The real edge is fewer players behind than UTG faces.',
    ),
  ],
  table: _act0ExplicitFoldsV1(
    _act0ReassignHeroSeatV1(
      _latePositionRunner.table.copyWith(
        scope: Act0TableScopeV1.playedHand,
        selectableSeatIds: const [],
        highlightedSeatIds: const ['co', 'btn', 'sb', 'bb'],
        actionTrail: const [
          Act0ActionTrailItemV1(label: 'UTG folds'),
          Act0ActionTrailItemV1(label: 'HJ folds'),
          Act0ActionTrailItemV1(label: 'CO acts'),
        ],
        centerLabel: 'CO after two folds',
        decisionSeatId: 'co',
        handContributions: _act0BlindsOnlyContributions,
      ),
      heroSeatId: 'co',
      activeSeatId: 'co',
      heroCardsVisibleMode: Act0CardsVisibleModeV1.faceDown,
    ),
    const {'utg', 'hj'},
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Late edge is practical.',
      body:
          'Seeing two folds before CO acts is already more information than UTG gets.',
      focusSeatIds: <String>['co', 'btn'],
      focusLabels: <String>['Two folds seen', 'Players behind'],
    ),
  ],
);

final _w3SeatOrderDecisionRunner = _earlyLatePositionRunner.copyWith(
  lessonId: 'w3_seat_order_decision',
  caption: 'UTG and BTN are visible. One acts before the other preflop.',
  hint: 'Earlier seats get less information first.',
  question: 'Which seat acts before BTN?',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Order matters before comfort.',
      body: 'UTG acts before BTN.',
      focusSeatIds: <String>['utg', 'btn'],
      focusLabels: <String>['UTG first', 'BTN later'],
    ),
    Act0TeachingStepV1(
      title: 'Information arrives later.',
      body: 'BTN can use more late-position information.',
      focusSeatIds: <String>['btn'],
      focusLabels: <String>['BTN sees more'],
    ),
  ],
);

final _w3EarlyLateOrderRepairRunner = _earlyLatePositionRunner.copyWith(
  lessonId: 'w3_repair_early_late_order',
  caption: 'Repair: compare early and late seats on this six-seat table.',
  hint: 'UTG acts sooner. BTN sees more first.',
  question: 'Which seat acts earlier on this six-seat table?',
  feedbackTitle: 'Early-late order repaired.',
  feedbackReason:
      'On this six-seat table, UTG acts sooner and BTN gets more information first.',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'utg',
      label: 'UTG',
      seatId: 'utg',
      isCorrect: true,
      preferredLabel: 'UTG',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Early-late order repaired.',
      feedbackReason:
          'UTG acts earlier on this six-seat table, before BTN gets to use late information.',
    ),
    Act0RunnerOptionV1(
      id: 'btn',
      label: 'BTN',
      seatId: 'btn',
      isCorrect: false,
      preferredLabel: 'UTG',
      betterAnswerLabel: 'UTG',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'BTN is later on this table. The missed signal is that UTG acts sooner.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Repair the order read.',
      body:
          'On this six-seat table, UTG is early and acts sooner; BTN is late and sees more first.',
      focusSeatIds: <String>['utg', 'btn'],
      focusLabels: <String>['UTG early', 'BTN late'],
    ),
  ],
);

final _w3EarlySeatPressureRunner = _earlyLatePositionRunner.copyWith(
  lessonId: 'w3_early_pressure',
  caption: 'UTG must act before HJ, CO, BTN, SB, and BB.',
  hint:
      'More players still to act behind you means you should open fewer hands.',
  question: 'Why does UTG need more discipline here?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'more_players_behind',
      label: 'Five players still act after UTG',
      isCorrect: true,
      preferredLabel: 'Five players still act after UTG',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Solid understanding.',
      feedbackReason:
          'That is the early-seat problem. More players still act, so weak opens get punished more often.',
    ),
    Act0RunnerOptionV1(
      id: 'same_as_btn',
      label: 'UTG gets the same information as BTN',
      isCorrect: false,
      preferredLabel: 'Five players still act after UTG',
      betterAnswerLabel: 'Five players still act after UTG',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'BTN is later and sees much more first. UTG is pressured because almost everyone still acts after it.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Early means pressure first.',
      body:
          'UTG faces the most unseen decisions behind, so discipline starts there.',
      focusSeatIds: <String>['utg'],
      focusLabels: <String>['UTG', 'Five behind'],
    ),
  ],
);

/// Evidence-only access to a live World 3 runner that is not materialized by
/// the compact sample-state graph. The application does not call this helper.
Act0LessonTaskV1? act0ProductionVisualAuditTaskSeedV1(String seedId) {
  if (seedId != 'world3_early_pressure') {
    return null;
  }
  return Act0LessonTaskV1(
    taskId: 'early_pressure_choice',
    title: 'Early pressure',
    phase: Act0LessonPhaseV1.drill,
    runner: _w3EarlySeatPressureRunner.copyWith(
      options: _act0AuthoredCorrectOptionAtV1(
        _w3EarlySeatPressureRunner.options,
        correctOptionId: 'more_players_behind',
        correctIndex: 1,
      ),
    ),
    rewardXp: 9,
    stepKind: Act0LessonStepKindV1.practice,
  );
}

final _w3UtgPlayersBehindRepairRunner = _w3EarlySeatPressureRunner.copyWith(
  lessonId: 'w3_repair_utg_players_behind',
  caption: 'UTG has the first decision in this frame.',
  hint: 'Count who still acts after UTG.',
  question: 'Why is UTG under pressure here?',
  feedbackTitle: 'UTG pressure repaired.',
  feedbackReason:
      'Five players still act after UTG, so early seats need extra discipline.',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'five_players_behind',
      label: 'Five players still act after UTG',
      isCorrect: true,
      preferredLabel: 'Five players still act after UTG',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'UTG pressure repaired.',
      feedbackReason:
          'Five players still act after UTG, so the seat has less information.',
    ),
    Act0RunnerOptionV1(
      id: 'utg_has_late_info',
      label: 'UTG already has late-position information',
      isCorrect: false,
      preferredLabel: 'Five players still act after UTG',
      betterAnswerLabel: 'Five players still act after UTG',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'UTG acts before the rest of the table, so the missed signal is players behind.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Repair the early-seat read.',
      body: 'UTG acts first, with HJ, CO, BTN, SB, and BB still behind it.',
      focusSeatIds: <String>['utg', 'hj', 'co', 'btn', 'sb', 'bb'],
      focusLabels: <String>['UTG', 'Five players behind'],
    ),
  ],
);

final _world3PositionRecapRunner = _world3LateOpenRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w3_position_recap',
  caption: 'Lesson learned: position changes preflop comfort.',
  hint: 'Late helps. Early demands stronger buckets and cleaner frames.',
  feedbackTitle: 'Position-preflop takeaway.',
  feedbackReason:
      'Preflop is not one-hand-one-answer. Position changes how confidently the hand can continue in first-in and facing-open frames.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Position checklist.',
      body: 'Bucket the hand, then ask if the seat helps or hurts.',
      focusLabels: <String>['Bucket', 'Seat'],
    ),
  ],
);

final _w3TablePositionNoticeRunner = _world3LateOpenRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w3_table_position_notice',
  feedbackSignalId: 'players_behind',
  caption: 'Real table. You are CO with QJs and three seats still act after.',
  hint: 'Before choosing an action, notice what the seat order gives you.',
  question: 'What is the clean seat read here?',
  feedbackTitle: 'Seat read first.',
  feedbackReason:
      'Count the players behind before treating the seat as comfortable.',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'players_behind',
      label: 'BTN, SB, and BB still act after you',
      isCorrect: true,
      preferredLabel: 'BTN, SB, and BB still act after you',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Strong choice.',
      feedbackReason:
          'CO still has BTN, SB and BB behind. Treating CO as last overlooks three players who can call or raise after you.',
    ),
    Act0RunnerOptionV1(
      id: 'acts_last',
      label: 'You already act last',
      isCorrect: false,
      preferredLabel: 'BTN, SB, and BB still act after you',
      betterAnswerLabel: 'BTN, SB, and BB still act after you',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'Cutoff is late, but Button and the blinds still act after you.',
    ),
    Act0RunnerOptionV1(
      id: 'late_free_pass',
      label: 'Late seat makes most hands easy',
      isCorrect: false,
      preferredLabel: 'BTN, SB, and BB still act after you',
      betterAnswerLabel: 'BTN, SB, and BB still act after you',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Count the players behind.',
      feedbackReason:
          'Late position helps, but it is not a free pass. First notice who still acts after you.',
    ),
  ],
  table: _act0ReassignHeroSeatV1(
    _world3LateOpenRunner.table.copyWith(
      heroCards: const <Act0CardStateV1>[
        Act0CardStateV1(rank: 'Q', suit: 's'),
        Act0CardStateV1(rank: 'J', suit: 's'),
      ],
      // This authored transfer stops before CO acts. Inherited BTN scenarios
      // have CO folded already, so identity reassignment alone is not enough.
      seats: _world3LateOpenRunner.table.seats
          .map((seat) {
            final folded = seat.seatId == 'utg' || seat.seatId == 'hj';
            return _act0CopySeatStateV1(
              seat,
              // The trail records 'UTG folds': UTG is a player in this hand,
              // not the empty seat inherited from the 5-handed base scene.
              isOccupied: seat.seatId == 'utg' ? true : null,
              isInHand: !folded,
              isFolded: folded,
              hasActed: folded,
            );
          })
          .toList(growable: false),
      highlightedSeatIds: const <String>['co', 'btn', 'sb', 'bb'],
      centerLabel: 'CO with three seats behind',
      handContributions: _act0UnopenedPriceContributionsV1('co'),
      actionTrail: const <Act0ActionTrailItemV1>[
        Act0ActionTrailItemV1(label: 'UTG folds'),
        Act0ActionTrailItemV1(label: 'HJ folds'),
        Act0ActionTrailItemV1(label: 'CO acts'),
      ],
    ),
    heroSeatId: 'co',
    activeSeatId: 'co',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Seat read before action.',
      body:
          'Late position helps, but Cutoff still leaves Button and the blinds behind you.',
      focusSeatIds: <String>['co', 'btn', 'sb', 'bb'],
      focusLabels: <String>['CO', 'Players behind', 'Not last to act'],
    ),
  ],
);

final _world3SameHandIntroRunner = _world3PositionIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w3_same_hand_intro',
  lessonTitle: 'Same hand, different frame',
  caption: 'The same hand can change action when the frame changes.',
  hint: 'First in, facing open, and early position are different frames.',
  question:
      'What should you re-check before deciding how to play the same hand?',
  table: _world3PositionIntroRunner.table.copyWith(selectableSeatIds: const []),
  options: const [
    Act0RunnerOptionV1(
      id: 'cards_and_seat',
      label: 'Your cards and seat',
      isCorrect: false,
      preferredLabel: 'Your cards, seat, and earlier action',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Check the action too.',
      feedbackReason:
          'The same cards at the same seat can face an earlier raise or an unopened pot.',
    ),
    Act0RunnerOptionV1(
      id: 'full_context',
      label: 'Your cards, seat, and earlier action',
      isCorrect: true,
      preferredLabel: 'Your cards, seat, and earlier action',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Read the whole situation.',
      feedbackReason:
          'Your cards tell you what you hold, your seat tells you who is left to act, and the earlier action tells you whether somebody has already raised.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'No permanent answer.',
      body: 'Re-check bucket, seat, and whether someone already opened.',
      focusLabels: <String>['Bucket', 'Seat', 'Frame'],
    ),
  ],
);

final _world3SameHandRecapRunner = _world3SameHandIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w3_same_hand_recap',
  caption: 'Lesson learned: context can change the action.',
  hint:
      'A hand can open first in, call facing an open, or fold in a worse frame.',
  question: 'What prevents one-hand-one-answer thinking?',
  // Current context-answer revision; old seat choices stay historical.
  feedbackSignalId: 'position_action_order',
  table: _world3SameHandIntroRunner.table.copyWith(
    selectableSeatIds: const <String>[],
  ),
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'one_answer',
      label: 'One answer per hand',
      isCorrect: false,
      preferredLabel: 'Bucket, seat, frame',
      betterAnswerLabel: 'Bucket, seat, frame',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Re-check the frame.',
      feedbackReason:
          'One hand can change action when position or action frame changes.',
    ),
    Act0RunnerOptionV1(
      id: 'framework',
      label: 'Bucket, seat, frame',
      isCorrect: true,
      preferredLabel: 'Bucket, seat, frame',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Frame takeaway.',
      feedbackReason:
          'The reusable preflop read is hand bucket, position, and action frame before choosing.',
    ),
  ],
  feedbackTitle: 'Frame takeaway.',
  feedbackReason:
      'The reusable preflop read is hand bucket, position, and action frame before choosing.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Frame checklist.',
      body: 'Ask if the pot is unopened or if a raise already happened.',
      focusLabels: <String>['Unopened', 'Facing open'],
    ),
  ],
);

final _w3SameHandDifferentSeatRepairRunner = _world3PositionDisciplineRunner.copyWith(
  lessonId: 'w3_repair_same_hand_different_seat',
  lessonTitle: 'Same hand, different seat',
  caption: 'Compare the two starting spots.',
  hint: 'Look at who still acts after you before judging comfort.',
  question: 'What changed most between the two frames?',
  feedbackTitle: 'Same-hand seat shift repaired.',
  feedbackReason:
      'The cards stayed ATo. The seat changed who still acts after you, so the hand feels different.',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'seat_context',
      label: 'Seat context changed the hand comfort',
      isCorrect: true,
      preferredLabel: 'Seat context changed the hand comfort',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Seat context repaired.',
      feedbackReason:
          'Same hand, different seat: early has more players behind; later has fewer players behind.',
      repairFocusSeatIds: <String>['utg', 'co', 'btn', 'sb', 'bb'],
      repairFocusCardIds: <String>['hero_0', 'hero_1'],
      repairFocusLabels: <String>['Same hand', 'Players behind'],
    ),
    Act0RunnerOptionV1(
      id: 'cards_changed',
      label: 'The cards changed strength by themselves',
      isCorrect: false,
      preferredLabel: 'Seat context changed the hand comfort',
      betterAnswerLabel: 'Seat context changed the hand comfort',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'The hand is still ATo. The missed signal is the seat and who still acts after you.',
      repairFocusSeatIds: <String>['utg', 'co', 'btn', 'sb', 'bb'],
      repairFocusCardIds: <String>['hero_0', 'hero_1'],
      repairFocusLabels: <String>['Same hand', 'Players behind'],
    ),
    Act0RunnerOptionV1(
      id: 'position_unimportant',
      label: 'Seat does not matter for this hand',
      isCorrect: false,
      preferredLabel: 'Seat context changed the hand comfort',
      betterAnswerLabel: 'Seat context changed the hand comfort',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Repair the table read.',
      feedbackReason:
          'Position matters because it changes how many players still act after you.',
      repairFocusSeatIds: <String>['utg', 'co', 'btn', 'sb', 'bb'],
      repairFocusCardIds: <String>['hero_0', 'hero_1'],
      repairFocusLabels: <String>['Same hand', 'Players behind'],
    ),
  ],
  table: _act0ReassignHeroSeatV1(
    _world3PositionDisciplineRunner.table.copyWith(
      scope: Act0TableScopeV1.explanation,
      centerLabel: 'Same hand, seat changes',
      // The exercise moves the same Hero from UTG to CO. Keep the
      // original Hero's starting stack when comparing the two positions.
      handContributions: Act0HandContributionsV1(
        throughStreet: PokerStreet.preflop,
        entries: _act0LessonBlinds,
        startingStackBbBySeat: {
          'co': _world3PositionDisciplineRunner
              .table
              .handContributions!
              .startingStackBbBySeat['utg']!,
        },
      ),
      heroCards: const <Act0CardStateV1>[
        Act0CardStateV1(rank: 'A', suit: 'd'),
        Act0CardStateV1(rank: 'T', suit: 'c'),
      ],
      highlightedSeatIds: const <String>['utg', 'co', 'btn', 'sb', 'bb'],
      actionTrail: const <Act0ActionTrailItemV1>[
        Act0ActionTrailItemV1.note(label: 'Frame 1: UTG has more behind'),
        Act0ActionTrailItemV1.note(label: 'Frame 2: CO has fewer behind'),
        Act0ActionTrailItemV1.note(
          label: 'Hero compares seats',
          displayLabel: 'Compare the two seats',
        ),
      ],
    ),
    heroSeatId: 'co',
    activeSeatId: 'co',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Frame one: early seat.',
      body:
          'ATo from UTG faces more players behind and less information on this six-seat table.',
      focusSeatIds: <String>['utg', 'hj', 'co', 'btn', 'sb', 'bb'],
      focusCardIds: <String>['hero_0', 'hero_1'],
      focusLabels: <String>['ATo', 'More behind'],
    ),
    Act0TeachingStepV1(
      title: 'Frame two: later seat.',
      body:
          'The same ATo later in the order has fewer players behind and more information first.',
      focusSeatIds: <String>['co', 'btn', 'sb', 'bb'],
      focusCardIds: <String>['hero_0', 'hero_1'],
      focusLabels: <String>['Same hand', 'Fewer behind'],
    ),
  ],
);

final _world3DominatedIntroRunner = _world3FacingOpenIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w3_dominated_intro',
  lessonTitle: 'Dominated hand warning',
  caption: 'Some familiar hands are trouble when stronger versions open.',
  hint: 'A weak ace can be behind a better ace.',
  question: 'What kind of hand needs caution?',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Compare similar hands',
      body:
          'Broadway ranks are T, J, Q, K, and A. One kind of domination is when two hands share a rank and one has the weaker side card.',
    ),
    Act0TeachingStepV1(
      title: 'Acting after your opponent',
      body:
          'You are in position when you act after the other player. Acting later gives you information. A weak ace can still lose to a stronger ace.',
    ),
  ],
);

const _weakAceFacingRaiseChoices = <Act0RunnerOptionV1>[
  Act0RunnerOptionV1(
    id: 'fold',
    label: 'Fold',
    isCorrect: true,
    preferredLabel: 'Fold',
    quality: Act0FeedbackQualityV1.correct,
    feedbackTitle: 'Disciplined fold.',
    feedbackReason:
        "Fold A7o because CO can raise stronger aces that win when you both pair your ace. Calling pays to enter against those hands.",
  ),
  Act0RunnerOptionV1(
    id: 'call',
    label: 'Call',
    amountLabel: '2.5 BB',
    isCorrect: false,
    preferredLabel: 'Fold',
    betterAnswerLabel: 'Fold',
    quality: Act0FeedbackQualityV1.wrong,
    feedbackTitle: 'Tempting, but fold.',
    feedbackReason:
        'A7o is in the Weak group. If both players pair an ace, a hand like A-J can win with its higher second card.',
  ),
];

final _world3DominatedFoldRunner = _world3WeakFacingFoldRunner.copyWith(
  lessonId: 'w3_dominated_fold',
  lessonTitle: 'Dominated hand warning',
  caption: 'CO opened. You are BTN with A7o.',
  hint: 'This can be behind stronger aces, so folding is clean.',
  question: 'By the Sharky starting chart, what is the disciplined response?',
  options: _weakAceFacingRaiseChoices,
  table: _world3WeakFacingFoldRunner.table.copyWith(
    heroCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'A', suit: 's'),
      Act0CardStateV1(rank: '7', suit: 'd'),
    ],
    centerLabel: 'Weak ace',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Weak ace caution.',
      body: 'A7o can be dominated when someone opened first.',
      focusCardIds: <String>['hero_0', 'hero_1'],
      focusLabels: <String>['A7o', 'Fold'],
    ),
  ],
);

Act0RunnerStateV1 _act0WeakAcePriceContrastV1(int openingBb) {
  final base = _world3DominatedFoldRunner;
  final wrong = _weakAceFacingRaiseChoices[1];
  final potBb = openingBb + 1.5;
  return base.copyWith(
    caption: 'CO raises to $openingBb BB. You are on the Button with A7o.',
    question:
        'What does the Sharky starting chart say to do with A7o facing this $openingBb BB raise?',
    hint: 'Check the Weak row for an earlier raise.',
    table: _act0FacingOpenTableV1(
      base.table.copyWith(centerLabel: 'Facing the first raise'),
      opener: 'co',
      openingBb: openingBb,
    ),
    options: [
      Act0RunnerOptionV1(
        id: wrong.id,
        label: wrong.label,
        amountLabel: '$openingBb BB',
        isCorrect: false,
        preferredLabel: wrong.preferredLabel,
        betterAnswerLabel: wrong.betterAnswerLabel,
        quality: wrong.quality,
        feedbackTitle: wrong.feedbackTitle,
        feedbackReason:
            'Calling $openingBb BB into a $potBb BB pot on BTN with A7o risks chips with a weak ace that loses big pots when CO holds a stronger ace.',
      ),
      _weakAceFacingRaiseChoices.first,
    ],
    teachingSteps: const [],
  );
}

Act0RunnerStateV1 _act0WeakHandAfterRaiseContrastV1(
  Act0RunnerStateV1 base, {
  required String handName,
  required List<Act0CardStateV1> cards,
  required int correctIndex,
  bool cutoffFacingHijack = false,
}) {
  final handCode = '${cards[0].rank}${cards[1].rank}o';
  final opener = cutoffFacingHijack ? 'HJ' : 'CO';
  final seatName = cutoffFacingHijack ? 'from CO' : 'on BTN';
  final strongerHands = switch (cards[0].rank) {
    'A' => 'stronger aces',
    'K' => 'stronger kings',
    _ => 'stronger jacks',
  };
  final foldReason =
      'Fold $handCode because $opener can raise $strongerHands. '
      'Calling costs 2.5 BB and can leave you behind even if you both pair that rank.';
  final wrongCallReason = cards[0].rank == 'A'
      ? 'Calling 2.5 BB into a 4 BB pot $seatName with $handCode pays to play a weak ace that loses big pots when $opener holds a stronger ace.'
      : 'Calling 2.5 BB into a 4 BB pot $seatName with $handCode risks chips with a weak offsuit hand that loses big pots to $opener\'s stronger high cards.';
  return base.copyWith(
    caption: cutoffFacingHijack
        ? 'HJ raised. You are in CO with $handName.'
        : 'CO raised. You are on the Button with $handName.',
    hint: 'Read your two cards and find their group in the chart.',
    feedbackReason: foldReason,
    table: cutoffFacingHijack
        ? _act0FacingOpenTableV1(
            base.table.copyWith(
              centerLabel: 'Facing the first raise',
              heroCards: cards,
              highlightedSeatIds: const [],
            ),
            opener: 'hj',
            hero: 'co',
          )
        : base.table.copyWith(
            centerLabel: 'Facing the first raise',
            heroCards: cards,
          ),
    options: _act0AuthoredCorrectOptionAtV1(
      [
        Act0RunnerOptionV1(
          id: 'fold',
          label: 'Fold',
          isCorrect: true,
          preferredLabel: 'Fold',
          quality: Act0FeedbackQualityV1.correct,
          feedbackTitle: 'Use the Weak row.',
          feedbackReason: foldReason,
        ),
        Act0RunnerOptionV1(
          id: 'call',
          label: 'Call',
          amountLabel: '2.5 BB',
          isCorrect: false,
          preferredLabel: 'Fold',
          quality: Act0FeedbackQualityV1.wrong,
          feedbackTitle: 'Read the cards before the seat.',
          feedbackReason: wrongCallReason,
        ),
        if (cutoffFacingHijack)
          Act0RunnerOptionV1(
            id: 'raise',
            label: 'Reraise to 7.5 BB',
            isCorrect: false,
            preferredLabel: 'Fold',
            betterAnswerLabel: 'Fold',
            quality: Act0FeedbackQualityV1.wrong,
            feedbackTitle: 'Keep the chips for a stronger hand.',
            feedbackReason:
                'Reraising $handCode from CO puts 7.5 BB at risk against '
                'an HJ opener who can continue with stronger hands. Folding saves that wager.',
          ),
      ],
      correctOptionId: 'fold',
      correctIndex: correctIndex,
    ),
    teachingSteps: const [],
  );
}

final _world3DominatedRecapRunner = _world3DominatedFoldRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w3_dominated_recap',
  caption: 'Lesson learned: familiar cards still need context.',
  hint: 'Do not continue just because one card looks high.',
  question:
      'By the Sharky starting chart, what is the disciplined action with this weak ace facing an open?',
  options: _weakAceFacingRaiseChoices,
  feedbackTitle: 'Discipline takeaway.',
  feedbackReason:
      'The Sharky starting chart folds A7o against a CO raise. A higher second card can win when both players pair an ace.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Trouble-hand checklist.',
      body: 'High card alone is not enough. Read the opener and bucket.',
      focusLabels: <String>['High card', 'Opener', 'Bucket'],
    ),
  ],
);

final _w1DisciplineCheckpointRunner = _world3DominatedRecapRunner.copyWith(
  lessonId: 'w1_discipline_checkpoint_bridge',
  lessonTitle: 'Hand discipline checkpoint',
  lessonSubtitle: 'Hand Discipline',
  caption: 'Lesson learned: discipline comes before action.',
  hint: 'Next world adds position: the same bucket can change action by seat.',
  question: 'What comes right after naming the bucket?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'seat_context',
      label: 'Seat context',
      isCorrect: true,
      preferredLabel: 'Seat context',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Solid understanding.',
      feedbackReason:
          'Bucket is step one. Seat context is the next check before choosing action.',
    ),
    Act0RunnerOptionV1(
      id: 'auto_action',
      label: 'Auto action',
      isCorrect: false,
      preferredLabel: 'Seat context',
      betterAnswerLabel: 'Seat context',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'One bucket does not force one action. Position changes comfort.',
    ),
  ],
  feedbackTitle: 'Discipline bridge takeaway.',
  feedbackReason:
      'You now protect your stack with buckets. Next, add position so the same hand can play differently by seat, without chart memorization.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Bridge to hand groups.',
      body: 'Bucket first. Position second. Then choose the action frame.',
      focusLabels: <String>['Bucket', 'Position', 'Action frame'],
    ),
  ],
);

final _w2DisciplineTableNoticeRunner = _w1DisciplineApplyEarlyFoldRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w2_discipline_table_notice',
  lessonTitle: 'Hand discipline checkpoint',
  lessonSubtitle: 'Hand Discipline',
  caption: 'Real table. You are HJ with J4o and the pot is unopened.',
  hint: 'Use the bucket first before hope or curiosity shows up.',
  question: 'What is the clean discipline read?',
  feedbackTitle: 'Discipline read first.',
  feedbackReason:
      'Real-table discipline starts by naming the bucket cleanly before inventing reasons to continue.',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'trash_fold',
      label: 'Weak · Fold',
      isCorrect: true,
      preferredLabel: 'Weak · Fold',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Well done.',
      feedbackReason:
          "Fold J4o from HJ because CO, BTN and both blinds still act. Limping pays 1 BB before any of them can raise.",
    ),
    Act0RunnerOptionV1(
      id: 'looks_fun_open',
      label: 'Medium · Raise',
      isCorrect: false,
      preferredLabel: 'Weak · Fold',
      betterAnswerLabel: 'Weak · Fold',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'This is exactly the leak hand-discipline is trying to prevent. J4o does not become playable because it looks fun.',
    ),
    Act0RunnerOptionV1(
      id: 'maybe_limp',
      label: 'Weak · Call',
      isCorrect: false,
      preferredLabel: 'Weak · Fold',
      betterAnswerLabel: 'Weak · Fold',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'The limp still costs a blind.',
      feedbackReason:
          'An unopened pot does not rescue a weak bucket. Discipline still says let it go instead of leaking a limp.',
    ),
  ],
  table: _act0ExplicitFoldsV1(
    _act0ReassignHeroSeatV1(
      _w1DisciplineApplyEarlyFoldRunner.table.copyWith(
        heroCards: const <Act0CardStateV1>[
          Act0CardStateV1(rank: 'J', suit: 'c'),
          Act0CardStateV1(rank: '4', suit: 'd', tone: Act0CardToneV1.red),
        ],
        highlightedSeatIds: const <String>['hj'],
        centerLabel: 'HJ, unopened pot',
        handContributions: _act0UnopenedPriceContributionsV1('hj'),
        actionTrail: const <Act0ActionTrailItemV1>[
          Act0ActionTrailItemV1(label: 'UTG folds'),
          Act0ActionTrailItemV1(label: 'HJ acts'),
        ],
      ),
      heroSeatId: 'hj',
      activeSeatId: 'hj',
    ),
    {'utg'},
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Bucket before curiosity.',
      body:
          'Some live-table leaks start because a weak hand looks tempting. Name the bucket first, then act with discipline.',
      focusSeatIds: <String>['hj'],
      focusCardIds: <String>['hero_0', 'hero_1'],
      focusLabels: <String>['J4o', 'Weak', 'Fold'],
    ),
  ],
);

// W1 bucket ID runners — all four buckets so the learner sees the full picture.
final _w1StrongBucketRunner = _world3BucketsIntroRunner.copyWith(
  lessonId: 'w1_strong_bucket',
  lessonTitle: 'Hand buckets',
  lessonSubtitle: 'Hand Discipline',
  caption: 'You hold J♥ J♠ before the flop.',
  hint: 'It is below the absolute top but does not need a perfect seat.',
  question: 'Which bucket is JJ?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'strong',
      label: 'Strong',
      isCorrect: true,
      preferredLabel: 'Strong',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Excellent spot.',
      feedbackReason:
          'JJ is a strong hand — second bucket. Very playable, but not premium.',
    ),
    Act0RunnerOptionV1(
      id: 'premium',
      label: 'Premium',
      isCorrect: false,
      preferredLabel: 'Strong',
      betterAnswerLabel: 'Strong',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'Premium is reserved for the absolute top hands like AA, KK, and AKs.',
    ),
    Act0RunnerOptionV1(
      id: 'medium',
      label: 'Medium',
      isCorrect: false,
      preferredLabel: 'Strong',
      betterAnswerLabel: 'Strong',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'JJ is above medium. Medium hands need more context to play well.',
    ),
  ],
  table: _whatYouCanDoRunner.table.copyWith(
    heroCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'J', suit: 'h'),
      Act0CardStateV1(rank: 'J', suit: 's'),
    ],
    centerLabel: 'Pocket jacks',
    highlightedCardIds: const <String>['hero_0', 'hero_1'],
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Strong, not premium.',
      body:
          'The Sharky chart groups JJ and TT in its Strong bucket. AA, KK and QQ are in the Premium pairs row.',
      focusCardIds: <String>['hero_0', 'hero_1'],
      focusLabels: <String>['JJ', 'Strong'],
    ),
  ],
);

final _w1MediumBucketRunner = _world3BucketsIntroRunner.copyWith(
  lessonId: 'w1_medium_bucket',
  lessonTitle: 'Hand buckets',
  lessonSubtitle: 'Hand Discipline',
  caption: 'You hold K♦ T♣ before the flop.',
  hint: 'Two high unpaired cards can play, but seat and frame matter.',
  question: 'Which bucket is KTo?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'medium',
      label: 'Medium',
      isCorrect: true,
      preferredLabel: 'Medium',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Spot on.',
      feedbackReason:
          'KTo is a medium hand — good enough to play but needs a comfortable spot.',
    ),
    Act0RunnerOptionV1(
      id: 'strong',
      label: 'Strong',
      isCorrect: false,
      preferredLabel: 'Medium',
      betterAnswerLabel: 'Medium',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'Strong hands need less context. KTo wants a good position and a clear frame.',
    ),
    Act0RunnerOptionV1(
      id: 'trash',
      label: 'Weak',
      isCorrect: false,
      preferredLabel: 'Medium',
      betterAnswerLabel: 'Medium',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'KTo is in the medium row. In this model, it opens from CO or BTN if nobody has raised.',
    ),
  ],
  table: _whatYouCanDoRunner.table.copyWith(
    heroCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'K', suit: 'd'),
      Act0CardStateV1(rank: 'T', suit: 'c'),
    ],
    centerLabel: 'KTo preflop',
    highlightedCardIds: const <String>['hero_0', 'hero_1'],
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Medium needs position.',
      body:
          'The hand bucket describes the starting cards. The seat and any earlier raise affect what you do with them.',
      focusCardIds: <String>['hero_0', 'hero_1'],
      focusLabels: <String>['KTo', 'Medium'],
    ),
  ],
);

final _w2BorderlineBucketRunner = _world3BucketsIntroRunner.copyWith(
  lessonId: 'w2_borderline_bucket_qjs',
  lessonTitle: 'Hand buckets',
  lessonSubtitle: 'Hand Discipline',
  caption: 'You hold Qs Js before the flop.',
  hint: 'Connected high cards can play, but they need position and frame.',
  question: 'Which bucket is QJs before context helps?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'medium',
      label: 'Medium',
      isCorrect: true,
      preferredLabel: 'Medium',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Conditional bucket found.',
      feedbackReason:
          'QJs sits in the medium border zone. It can continue in good context, but it is not a self-starting strong hand.',
    ),
    Act0RunnerOptionV1(
      id: 'strong',
      label: 'Strong',
      isCorrect: false,
      preferredLabel: 'Medium',
      betterAnswerLabel: 'Medium',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'QJs is in the Medium bucket.',
      feedbackReason:
          'Strong hands need less help from position and action frame. QJs still wants context before chips go in.',
    ),
    Act0RunnerOptionV1(
      id: 'trash',
      label: 'Weak',
      isCorrect: false,
      preferredLabel: 'Medium',
      betterAnswerLabel: 'Medium',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too low.',
      feedbackReason:
          'QJs has connected high-card value. It is conditional, not weak.',
    ),
  ],
  table: _whatYouCanDoRunner.table.copyWith(
    heroCards: _heroQJsCards,
    centerLabel: 'QJs preflop',
    highlightedCardIds: const <String>['hero_0', 'hero_1'],
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Borderline needs context.',
      body:
          'QJs is Medium. The Strong row lists JJ and TT, which are pocket pairs.',
      focusCardIds: <String>['hero_0', 'hero_1'],
      focusLabels: <String>['QJs', 'Context matters'],
    ),
  ],
);

// W1: Medium hand first-in on the Button — raise is clean, limp is suboptimal.
final _w1MediumOpenRunner = _world3ButtonOpenRunner.copyWith(
  lessonId: 'w1_medium_open',
  lessonTitle: 'Continue or let go',
  lessonSubtitle: 'Hand Discipline',
  caption: 'BTN. Pot unopened. You hold K♦ Q♣.',
  hint: 'Medium hand in the best seat. Raising is sharper than limping.',
  question: 'By the Sharky starting chart, what is the best first-in action?',
  table: _world3ButtonOpenRunner.table.copyWith(
    heroCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'K', suit: 'd'),
      Act0CardStateV1(rank: 'Q', suit: 'c'),
    ],
    centerLabel: 'Medium, good seat',
    activeSeatId: 'btn',
    highlightedSeatIds: const <String>['btn'],
    highlightedCardIds: const <String>['hero_0', 'hero_1'],
  ),
  feedbackTitle: 'Clean execution.',
  feedbackReason:
      'KQo on the Button can open cleanly when the pot is unopened.',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'fold',
      label: 'Fold',
      isCorrect: false,
      preferredLabel: 'Raise',
      betterAnswerLabel: 'Raise',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'KQo on the Button has enough to open. Folding here wastes a strong seat.',
      repairFocusSeatIds: <String>['btn'],
      repairFocusCardIds: <String>['hero_0', 'hero_1'],
      repairFocusLabels: <String>['BTN', 'KQo', 'Fold wastes it'],
    ),
    Act0RunnerOptionV1(
      id: 'call',
      label: 'Call',
      amountLabel: '1 BB',
      isCorrect: false,
      preferredLabel: 'Raise',
      betterAnswerLabel: 'Raise',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Passive line, weaker pressure.',
      feedbackReason:
          'Limping KQo is legal but starts the hand passively. Raising opens the pot and pressures the blinds.',
      repairFocusSeatIds: <String>['btn', 'sb', 'bb'],
      repairFocusCardIds: <String>['hero_0', 'hero_1'],
      repairFocusLabels: <String>['Call 1 BB', 'Chart says raise', 'BTN'],
    ),
    Act0RunnerOptionV1(
      id: 'raise',
      label: 'Raise',
      amountLabel: '2.5 BB',
      isCorrect: true,
      preferredLabel: 'Raise',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Raise is the sharp Button play.',
      feedbackReason:
          "With KQo on BTN, raise because the blinds can fold or pay with weaker kings and queens. Calling lets BB see a cheap flop.",
      repairFocusSeatIds: <String>['btn'],
      repairFocusCardIds: <String>['hero_0', 'hero_1'],
      repairFocusLabels: <String>['BTN open', 'KQo'],
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Medium hand, good seat.',
      body:
          'KQo is medium bucket. The Button is the best seat. Raise to open cleanly.',
      focusSeatIds: <String>['btn'],
      focusCardIds: <String>['hero_0', 'hero_1'],
      focusLabels: <String>['KQo', 'BTN', 'Open'],
    ),
  ],
);

// W1 apply runners — table-context scenarios that combine bucket + seat + frame.
final _w1DisciplineApplyIntroRunner = _world3BucketsRecapRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w1_discipline_apply_intro',
  lessonTitle: 'Discipline at the table',
  lessonSubtitle: 'Hand Discipline',
  caption: 'Three steps make the decision easier.',
  hint: 'Use the Sharky starting chart with your seat and earlier action.',
  question: 'What order helps most?',
  feedbackTitle: 'Three-step habit.',
  feedbackReason:
      'Bucket, seat, and frame together give the action a clear reason.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Bucket, seat, frame.',
      body: 'Name the hand bucket. Check the seat. Read who acted first.',
      focusLabels: <String>['Bucket', 'Seat', 'Frame'],
    ),
  ],
);

final _w1DisciplineApplyEarlyFoldRunner = _world3EarlyFoldRunner.copyWith(
  lessonId: 'w1_apply_early_fold',
  lessonTitle: 'Discipline at the table',
  lessonSubtitle: 'Hand Discipline',
  caption: 'UTG. Pot unopened. You hold 8♠ 4♦.',
  hint: 'Early position, weak bucket. Discipline says fold.',
  question: 'By the Sharky starting chart, what is the clean action?',
  feedbackTitle: 'Discipline holds.',
  feedbackReason:
      'Early position with a weak hand needs no extra thought. Fold and wait.',
  table: _act0ReassignHeroSeatV1(
    _world3EarlyFoldRunner.table.copyWith(
      seats: _act0WithAuthoredPreActionSeatsV1(
        _world3EarlyFoldRunner.table,
      ).seats,
      heroCards: const <Act0CardStateV1>[
        Act0CardStateV1(rank: '8', suit: 's'),
        Act0CardStateV1(rank: '4', suit: 'd'),
      ],
      centerLabel: 'Weak early',
      highlightedSeatIds: const <String>['utg'],
      highlightedCardIds: const <String>['hero_0', 'hero_1'],
    ),
    heroSeatId: 'utg',
    activeSeatId: 'utg',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Weak in early seat.',
      body:
          '8♠4♦ is Weak in the Sharky starting chart. This six-player first-in example is from UTG.',
      focusSeatIds: <String>['utg'],
      focusCardIds: <String>['hero_0', 'hero_1'],
      focusLabels: <String>['8 4o', 'UTG', 'Fold'],
    ),
  ],
);

final _w1DisciplineApplyLateOpenRunner = _world3ButtonOpenRunner.copyWith(
  lessonId: 'w1_apply_late_open',
  lessonTitle: 'Discipline at the table',
  lessonSubtitle: 'Hand Discipline',
  caption: 'BTN. Pot unopened. You hold A♠ J♦.',
  hint: 'Find this medium hand in the chart and check the BTN column.',
  question: 'By the Sharky starting chart, what is the clean action?',
  feedbackTitle: 'Discipline confirms.',
  feedbackReason:
      'AJo is Medium. The Sharky starting chart opens it from HJ through BTN when no one has raised.',
  table: _world3ButtonOpenRunner.table.copyWith(
    heroCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'A', suit: 's'),
      Act0CardStateV1(rank: 'J', suit: 'd'),
    ],
    centerLabel: 'Medium on BTN',
    activeSeatId: 'btn',
    highlightedSeatIds: const <String>['btn'],
    highlightedCardIds: const <String>['hero_0', 'hero_1'],
  ),
  options: _sharkyOpenChartChoices,
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'AJo in the starting chart.',
      body:
          'AJo is in the Medium group. Before a raise, its opening seats are HJ, CO and BTN. BTN acts last after the flop.',
      focusSeatIds: <String>['btn'],
      focusCardIds: <String>['hero_0', 'hero_1'],
      focusLabels: <String>['AJo', 'BTN', 'Open'],
    ),
  ],
);

final _w1DisciplineApplyHjMediumRunner = _world3ButtonOpenRunner.copyWith(
  lessonId: 'w1_apply_hj_medium',
  lessonTitle: 'Discipline at the table',
  lessonSubtitle: 'Hand Discipline',
  caption: 'HJ. Pot unopened. You hold K♦ Q♣.',
  hint: 'Medium hand, middle seat, unopened pot. Open with a clear reason.',
  question: 'By the Sharky starting chart, what is the clean action?',
  feedbackTitle: 'HJ open is clean.',
  feedbackReason:
      'KQo is a medium hand, and HJ can open it when the pot is unopened.',
  table: _act0ReassignHeroSeatV1(
    _world3ButtonOpenRunner.table.copyWith(
      seats: _act0WithAuthoredPreActionSeatsV1(
        _world3ButtonOpenRunner.table,
        foldedSeatIds: const <String>{'utg'},
      ).seats,
      heroCards: const <Act0CardStateV1>[
        Act0CardStateV1(rank: 'K', suit: 'd'),
        Act0CardStateV1(rank: 'Q', suit: 'c'),
      ],
      centerLabel: 'HJ, medium hand',
      activeSeatId: 'hj',
      handContributions: _act0UnopenedPriceContributionsV1('hj'),
      actionTrail: const [
        Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
        Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
        Act0ActionTrailItemV1(label: 'UTG folds'),
        Act0ActionTrailItemV1.note(label: 'HJ acts'),
      ],
      highlightedSeatIds: const <String>['hj'],
      highlightedCardIds: const <String>['hero_0', 'hero_1'],
    ),
    heroSeatId: 'hj',
    activeSeatId: 'hj',
  ),
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'fold',
      label: 'Fold',
      isCorrect: false,
      preferredLabel: 'Raise',
      betterAnswerLabel: 'Raise',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too tight for this hand.',
      feedbackReason:
          'KQo is not weak. From HJ in an unopened pot, it can open instead of auto-folding.',
      repairFocusSeatIds: <String>['hj'],
      repairFocusCardIds: <String>['hero_0', 'hero_1'],
      repairFocusLabels: <String>['HJ', 'KQo', 'Medium hand'],
    ),
    Act0RunnerOptionV1(
      id: 'call',
      label: 'Call',
      amountLabel: '1 BB',
      isCorrect: false,
      preferredLabel: 'Raise',
      betterAnswerLabel: 'Raise',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Limping loses pressure.',
      feedbackReason:
          'Calling the blind enters passively. The cleaner first-in action is open-raise or fold, and KQo is strong enough to open here.',
      repairFocusSeatIds: <String>['hj', 'sb', 'bb'],
      repairFocusCardIds: <String>['hero_0', 'hero_1'],
      repairFocusLabels: <String>['Unopened pot', 'Open, not limp'],
    ),
    Act0RunnerOptionV1(
      id: 'raise',
      label: 'Raise',
      amountLabel: '2.5 BB',
      isCorrect: true,
      preferredLabel: 'Raise',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'HJ open is clean.',
      feedbackReason:
          "From HJ, raise KQo because CO, BTN and the blinds can fold or continue with weaker high cards. A limp invites them to enter cheaply.",
      repairFocusSeatIds: <String>['hj'],
      repairFocusCardIds: <String>['hero_0', 'hero_1'],
      repairFocusLabels: <String>['HJ open', 'KQo'],
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Medium hand, middle seat.',
      body:
          'KQo is not the same as early weak. In HJ with an unopened pot, the clean decision is to open rather than limp.',
      focusSeatIds: <String>['hj'],
      focusCardIds: <String>['hero_0', 'hero_1'],
      focusLabels: <String>['KQo', 'HJ', 'Open'],
    ),
  ],
);

Act0LessonTaskV1 _w2WeakAceTask(Act0LessonTaskV1 task) {
  final extra = switch (task.taskId) {
    'w3_dominated_fold' => (
      label: 'Reraise to 7.5 BB',
      reason:
          'A reraise risks 7.5 BB on A6o and can get called by a better ace. Folding keeps those chips.',
    ),
    'w3_strong_continue' => (
      label: 'Reraise to 7.5 BB',
      reason:
          'Against the 2.5 BB HJ open, the BTN call row includes KQo. '
          'Reraising instead risks five extra blinds against better hands.',
    ),
    'w3_dominated_recap' => (
      label: 'Reraise to 7.5 BB',
      reason:
          'A5o on BTN can lose to higher aces in CO. Putting in 7.5 BB '
          'instead of folding makes that kicker problem costlier.',
    ),
    _ => null,
  };
  if (extra == null) return task;
  return Act0LessonTaskV1(
    taskId: task.taskId,
    title: task.title,
    phase: task.phase,
    runner: _w2WithDistractor(
      task.runner,
      id: 'raise',
      label: extra.label,
      reason: extra.reason,
    ),
    rewardXp: task.rewardXp,
    stepKind: task.stepKind,
    taskFamily: task.taskFamily,
    tablePresentation: task.tablePresentation,
    repairOnly: task.repairOnly,
    summary: task.summary,
    lockedSummary: task.lockedSummary,
  );
}

Act0RunnerStateV1 _w2WithDistractor(
  Act0RunnerStateV1 runner, {
  required String id,
  required String label,
  required String reason,
}) {
  final answer = runner.options.firstWhere(act0RunnerOptionIsAuthoredCorrectV1);
  return runner.copyWith(
    options: [
      ...runner.options,
      Act0RunnerOptionV1(
        id: id,
        label: label,
        isCorrect: false,
        preferredLabel: answer.label,
        betterAnswerLabel: answer.label,
        feedbackTitle: 'Read the hand and earlier action.',
        feedbackReason: reason,
        quality: Act0FeedbackQualityV1.wrong,
      ),
    ],
  );
}

Act0RunnerStateV1 _w2ReasonDecision(
  Act0RunnerStateV1 runner, {
  required String question,
  required String correctTitle,
  required List<({String id, String label, String reason})> choices,
  required int correct,
}) => runner.copyWith(
  question: question,
  options: [
    for (final (index, choice) in choices.indexed)
      Act0RunnerOptionV1(
        id: choice.id,
        label: choice.label,
        isCorrect: index == correct,
        preferredLabel: choices[correct].label,
        betterAnswerLabel: index == correct ? '' : choices[correct].label,
        feedbackTitle: index == correct ? correctTitle : 'Use the table facts.',
        feedbackReason: choice.reason,
        quality: index == correct
            ? Act0FeedbackQualityV1.correct
            : Act0FeedbackQualityV1.wrong,
      ),
  ],
  teachingSteps: const [],
);

Act0RunnerStateV1 _w2UnopenedSeat(
  Act0RunnerStateV1 runner,
  String hero,
  String hand,
) {
  final authored = _day7PreflopV1(hero, hand, showTurn: true);
  return runner.copyWith(
    table: authored.copyWith(
      centerLabel: runner.table.centerLabel,
      highlightedCardIds: runner.table.highlightedCardIds,
    ),
  );
}

const _w2ThreeBetLessonId = 'w2_narrow_three_bet';
const _w2ThreeBetQuestion =
    'Under the narrow 3-bet rule, how should you respond to the open?';

final _w2ThreeBetIntroRunner = _world3BucketsIntroRunner.copyWith(
  lessonId: _w2ThreeBetLessonId,
  lessonTitle: 'The narrow 3-bet',
  caption: 'Face one opening raise with nobody else in the pot.',
  hint: '',
  question: 'What changes when you raise over an open?',
  table: _day7PreflopV1('co', 'Ah Ac', opener: 'hj', showTurn: true),
  teachingSteps: const [
    Act0TeachingStepV1(
      title: 'A 3-bet is a raise over the first raise.',
      body:
          'A 4-bet is a raise over a 3-bet; at micro stakes it usually means QQ+ or AK. '
          'Here HJ or CO opens once, and you act after them. Reraise AA, KK, QQ, and AK (suited or offsuit). '
          'Call with the other Strong hands: JJ, TT, AQs, and AJs. '
          'With Medium hands, call from BTN with AQo, AJo, KQs, KQo, ATs, ATo, KJs, or QJs. '
          'Fold the rest of Medium, including all Medium hands from CO, '
          'and fold Weak hands. This rule requires position and no other callers.',
    ),
  ],
);

Act0RunnerStateV1 _w2ThreeBetDecision({
  required String hero,
  required String opener,
  required String cards,
  required String correctId,
  required String raiseReason,
  required String callReason,
  required String foldReason,
  double openBb = 2.5,
}) {
  final labels = {
    'raise': 'Reraise to ${_act0BbLabelV1(openBb * 3)}',
    'call': 'Call ${_act0BbLabelV1(openBb)}',
    'fold': 'Fold',
  };
  final reasons = {
    'raise': raiseReason,
    'call': callReason,
    'fold': foldReason,
  };
  return _w2ThreeBetIntroRunner.copyWith(
    phase: Act0LessonPhaseV1.drill,
    caption:
        '${opener.toUpperCase()} opened to ${_act0BbLabelV1(openBb)}. '
        'No one has called.',
    question: _w2ThreeBetQuestion,
    teachingSteps: const [],
    table: _act0FacingOpenTableV1(
      _legacyFacingOpenTableV1.copyWith(
        heroCards: _act0LessonCardsV1(cards),
        centerLabel: 'Facing one open',
      ),
      opener: opener,
      hero: hero,
      openingBb: openBb,
    ),
    options: [
      for (final id in reasons.keys)
        Act0RunnerOptionV1(
          id: id,
          label: labels[id]!,
          isCorrect: correctId == id,
          preferredLabel: labels[correctId]!,
          betterAnswerLabel: correctId == id ? '' : labels[correctId]!,
          quality: correctId == id
              ? Act0FeedbackQualityV1.correct
              : Act0FeedbackQualityV1.wrong,
          feedbackTitle: correctId == id
              ? 'Correct.'
              : 'Check the response rule.',
          feedbackReason: reasons[id]!,
        ),
    ],
  );
}

Act0RunnerStateV1 _w3AddAlternative(
  Act0RunnerStateV1 runner, {
  required String id,
  required String label,
  required String reason,
  String? seat,
  String? question,
}) {
  final correct = runner.options.singleWhere(
    act0RunnerOptionIsAuthoredCorrectV1,
  );
  return runner.copyWith(
    question: question,
    table: seat == null
        ? runner.table
        : runner.table.copyWith(
            selectableSeatIds: [...runner.table.selectableSeatIds, seat],
          ),
    options: [
      ...runner.options,
      Act0RunnerOptionV1(
        id: id,
        label: label,
        seatId: seat,
        isCorrect: false,
        preferredLabel: correct.label,
        betterAnswerLabel: correct.label,
        quality: Act0FeedbackQualityV1.wrong,
        feedbackTitle: 'Read the earlier actions and seat order.',
        feedbackReason: reason,
      ),
    ],
  );
}

Act0RunnerStateV1 _w3OrientationFromSeat(
  Act0RunnerStateV1 runner,
  String observerSeat,
) => runner.copyWith(
  table: _act0ReassignHeroSeatV1(
    runner.table,
    heroSeatId: observerSeat,
    activeSeatId: '',
  ),
);

final _w3SeatOrderReasonRunner =
    _w3OrientationFromSeat(_w3SixSeatsIntroRunner, 'utg').copyWith(
      phase: Act0LessonPhaseV1.drill,
      caption: 'Compare UTG to SB.',
      question: 'What is the order after UTG?',
      teachingSteps: const [],
      table: _w3OrientationFromSeat(_w3SixSeatsIntroRunner, 'utg').table
          .copyWith(highlightedSeatIds: const [], selectableSeatIds: const []),
      options: const [
        Act0RunnerOptionV1(
          id: 'cutoff_first',
          label: 'CO, HJ, BTN',
          isCorrect: false,
          preferredLabel: 'HJ, CO, BTN',
          quality: Act0FeedbackQualityV1.wrong,
          feedbackTitle: 'Follow the seat after UTG.',
          feedbackReason:
              'HJ is next after UTG in this 1.5 BB pot. Putting CO '
              'first reverses which of the two can see the other act.',
        ),
        Act0RunnerOptionV1(
          id: 'seat_order',
          label: 'HJ, CO, BTN',
          isCorrect: true,
          preferredLabel: 'HJ, CO, BTN',
          quality: Act0FeedbackQualityV1.correct,
          feedbackTitle: 'Read three seats clockwise.',
          feedbackReason:
              'HJ acts after UTG, CO acts after HJ, and BTN acts '
              'before the two blinds on the first preflop pass.',
        ),
        Act0RunnerOptionV1(
          id: 'button_before_cutoff',
          label: 'HJ, BTN, CO',
          isCorrect: false,
          preferredLabel: 'HJ, CO, BTN',
          quality: Act0FeedbackQualityV1.wrong,
          feedbackTitle: 'CO is before BTN.',
          feedbackReason:
              'On this six-seat table, CO sits immediately before '
              'the dealer marker. Switching them reverses who sees the other act.',
        ),
      ],
    );

final _w3PositionApplyRecapRunner = _world3LateOpenRunner.copyWith(
  caption: 'Folded to BTN with AJo.',
  hint: 'Find your hand and seat in the chart.',
  question: 'Why does the chart prefer an open here?',
  table: _world3LateOpenRunner.table.copyWith(
    heroCards: _act0LessonCardsV1('Ad Jc'),
    centerLabel: 'No one has raised',
  ),
  teachingSteps: const [],
  options: const [
    Act0RunnerOptionV1(
      id: 'raise',
      label: 'AJo can put the blinds to a decision',
      isCorrect: true,
      preferredLabel: 'AJo can put the blinds to a decision',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Use the opening row.',
      feedbackReason:
          'AJo can raise first in from HJ through BTN. A 3 BB '
          'raise gives you a chance to win the 1.5 BB already in the pot.',
    ),
    Act0RunnerOptionV1(
      id: 'call',
      label: 'A limp puts the blinds under more pressure',
      isCorrect: false,
      preferredLabel: 'AJo can put the blinds to a decision',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Compare the prices.',
      feedbackReason:
          'Limping AJo on BTN for 1 BB lets BB check for free '
          'and gives SB a cheaper path to the flop.',
    ),
    Act0RunnerOptionV1(
      id: 'off_chart',
      label: 'AJo opens from HJ and CO alone',
      isCorrect: false,
      preferredLabel: 'AJo can put the blinds to a decision',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Read the whole opening row.',
      feedbackReason:
          'The HJ–BTN row includes the Button. Folding AJo here '
          'gives up the chance to contest the posted 1.5 BB.',
    ),
  ],
);

Act0TableStateV1 _w3ButtonOrderTable(Act0TableStateV1 table, String cards) =>
    _act0ReassignHeroSeatV1(
      table.copyWith(heroCards: _act0LessonCardsV1(cards)),
      heroSeatId: 'btn',
      activeSeatId: '',
    );

final _w3ButtonOrderReasonRunner = _postflopButtonActorRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  caption: 'UTG and BTN still have cards on an A-7-2 flop.',
  question: 'Why can BTN make a more informed first decision on this flop?',
  teachingSteps: const [],
  table: _w3ButtonOrderTable(
    _postflopButtonActorRunner.table,
    'Td Ts',
  ).copyWith(selectableSeatIds: const []),
  options: const [
    Act0RunnerOptionV1(
      id: 'sees_first_action',
      label: 'BTN sees UTG act first',
      isCorrect: true,
      preferredLabel: 'BTN sees UTG act first',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Acting later gives information.',
      feedbackReason:
          'BTN can see whether UTG checks or bets at this 5 BB '
          'pot before risking chips on the same flop.',
    ),
    Act0RunnerOptionV1(
      id: 'smaller_price',
      label: 'BTN pays less for the same bet',
      isCorrect: false,
      preferredLabel: 'BTN sees UTG act first',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Position does not change the wager.',
      feedbackReason:
          'If UTG bets into this 5 BB pot, the amount BTN owes '
          'comes from the wager. BTN does get to see that amount before acting.',
    ),
    Act0RunnerOptionV1(
      id: 'owns_first_turn',
      label: 'BTN takes the first flop turn',
      isCorrect: false,
      preferredLabel: 'BTN sees UTG act first',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Look left of the Button.',
      feedbackReason:
          'UTG takes its first flop turn before BTN. Assuming BTN '
          'acts first misses the chance to learn from UTG’s action.',
    ),
  ],
);

final _w3BlindDefenseIntroRunner = _w3SixSeatsIntroRunner.copyWith(
  lessonId: 'w3_play_from_blinds',
  lessonTitle: 'Play from the blinds',
  caption: '',
  question: 'What price remains?',
  hint: '',
  options: const [],
  table: _day7PreflopV1('bb', 'Qc Tc', opener: 'btn', showTurn: true),
  teachingSteps: const [
    Act0TeachingStepV1(
      title: 'Facing BTN.',
      body:
          'SB reraises Premium, Strong and HJ Medium. Fold CO Medium and Weak. '
          '"Defend your blind" means calling or reraising from SB or BB. '
          'From BB subtract your 1 BB post. Equity means pot share from wins and ties. A 1.5 BB call for 5.5 BB needs about 27%.',
    ),
    Act0TeachingStepV1(
      title: 'Only the blinds remain.',
      body:
          'Blind versus blind means everyone folded to SB. SB acts before BB after the flop. '
          'An SB limp means completing the blind, usually worse than raising or folding. '
          'A raise to 3 BB makes BB pay 2 BB more. BB’s call ends preflop here.',
    ),
  ],
);

Act0RunnerStateV1 _w3BlindDefenseRunner({
  required String hero,
  required String cards,
  required String caption,
  required String question,
  required List<({String id, String label, String reason})> options,
  required int correct,
  Act0TableStateV1? table,
}) => _w3BlindDefenseIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  caption: caption,
  question: question,
  table: (table ?? _day7PreflopV1(hero, cards, opener: 'btn', showTurn: true))
      .copyWith(showDecisionPremise: true),
  teachingSteps: const [],
  options: [
    for (final (index, option) in options.indexed)
      Act0RunnerOptionV1(
        id: option.id,
        label: option.label,
        isCorrect: index == correct,
        preferredLabel: options[correct].label,
        betterAnswerLabel: index == correct ? '' : options[correct].label,
        quality: index == correct
            ? Act0FeedbackQualityV1.correct
            : Act0FeedbackQualityV1.wrong,
        feedbackTitle: index == correct
            ? 'Correct.'
            : 'Read the price and seat.',
        feedbackReason: option.reason,
      ),
  ],
);

Act0TableStateV1 _w3BigBlindFacingSmallBlindV1(String hand) => _day7TableV1(
  hero: 'bb',
  hand: hand,
  street: PokerStreet.preflop,
  actor: 'bb',
  folded: const {'utg', 'hj', 'co', 'btn'},
  entries: const [
    ..._act0LessonBlinds,
    Act0ContributionV1(
      PokerStreet.preflop,
      'sb',
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
    Act0ActionTrailItemV1(label: 'BTN folds'),
    Act0ActionTrailItemV1(label: 'SB raises to 3 BB'),
  ],
  bets: const {
    'sb': Act0SeatBetStateV1(
      kind: Act0SeatBetKindV1.raise,
      label: 'Raise',
      amountLabel: '3 BB',
    ),
    'bb': _bigBlindPost,
  },
);

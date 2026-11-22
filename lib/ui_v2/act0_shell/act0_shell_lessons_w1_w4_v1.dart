part of 'act0_shell_state_v1.dart';

// Used only by adjudicated seat-recognition tasks. Their assessment
// stays neutral while authored teaching keeps its original table and focus.
Act0RunnerStateV1 _act0NeutralSeatAssessmentPreservingTeachingV1(
  Act0RunnerStateV1 source,
) => source.copyWith(
  table: source.table.copyWith(
    highlightedSeatIds: const <String>[],
    activeSeatId: '',
  ),
  teachingSteps: [
    for (final step in source.teachingSteps)
      Act0TeachingStepV1(
        title: step.title,
        body: step.body,
        table: step.table ?? source.table,
        focusSeatIds: step.focusSeatIds,
        focusCardIds: step.focusCardIds,
        focusLabels: step.focusLabels,
        identityTeachingSemantics: step.identityTeachingSemantics,
        ctaLabel: step.ctaLabel,
      ),
  ],
);

Act0TableStateV1 _act0W1MoveHeroV1(
  Act0TableStateV1 table,
  String destination, {
  bool keepSeatCues = false,
  List<Act0ActionTrailItemV1>? history,
}) {
  final origin = table.heroSeat.seatId;
  final bySeat = {for (final seat in table.seats) seat.seatId: seat};
  String? moved(String? id) => switch (id) {
    final id when id == origin => destination,
    final id when id == destination => origin,
    _ => id,
  };
  final ledger = table.handContributions;
  return table.copyWith(
    heroSeatId: destination,
    activeSeatId: moved(table.activeSeatId),
    decisionSeatId: moved(table.decisionSeatId),
    selectedSeatId: keepSeatCues
        ? table.selectedSeatId
        : moved(table.selectedSeatId),
    highlightedSeatIds: keepSeatCues
        ? table.highlightedSeatIds
        : table.highlightedSeatIds.map((id) => moved(id)!).toList(),
    actionTrail: history ?? table.actionTrail,
    handContributions: ledger == null
        ? null
        : Act0HandContributionsV1(
            throughStreet: ledger.throughStreet,
            fromStreet: ledger.fromStreet,
            startingStackBbBySeat: {
              for (final entry in ledger.startingStackBbBySeat.entries)
                moved(entry.key)!: entry.value,
            },
            minimumStartingStackBbBySeat: {
              for (final entry in ledger.minimumStartingStackBbBySeat.entries)
                moved(entry.key)!: entry.value,
            },
            entries: [
              for (final entry in ledger.entries)
                Act0ContributionV1(
                  entry.street,
                  moved(entry.seatId)!,
                  entry.kind,
                  entry.amountBb,
                ),
            ],
          ),
    seats: [
      for (final seat in table.seats)
        if (seat.seatId == origin || seat.seatId == destination)
          _act0W1RelocatePlayerV1(bySeat[moved(seat.seatId)]!, seat)
        else
          seat,
    ],
  );
}

Act0SeatStateV1 _act0W1RelocatePlayerV1(
  Act0SeatStateV1 player,
  Act0SeatStateV1 seat,
) => Act0SeatStateV1(
  seatId: seat.seatId,
  seatLabel: seat.seatLabel,
  displayName: player.isHero ? 'Hero' : _act0DefaultSeatDisplayNameV1(seat),
  isHero: player.isHero,
  isDealerButton: seat.isDealerButton,
  isSmallBlind: seat.isSmallBlind,
  isBigBlind: seat.isBigBlind,
  blindAmountLabel: seat.blindAmountLabel,
  isActive: player.isActive,
  isTarget: seat.isTarget,
  isInHand: player.isInHand,
  isFolded: player.isFolded,
  hasActed: player.hasActed,
  isLastAggressor: player.isLastAggressor,
  isOccupied: player.isOccupied,
  stackLabel: player.stackLabel,
  holeCards: player.holeCards,
  cardsVisibleMode: player.cardsVisibleMode,
  currentBetLabel: player.currentBetLabel,
  bet: player.bet,
);

Act0RunnerStateV1 _act0W1SeatObserverV1(
  Act0RunnerStateV1 source,
  String seat,
) => source.copyWith(
  table: _act0W1MoveHeroV1(source.table, seat, keepSeatCues: true),
);

final _w1PotStackSeatedRunner = _potStackRunner.copyWith(
  table: _act0W1MoveHeroV1(_potStackRunner.table, 'hj'),
  teachingSteps: [
    _potStackRunner.teachingSteps.first,
    const Act0TeachingStepV1(
      title: 'Pot and stack are different.',
      body: 'The pot is in the middle. Your stack stays with your seat.',
      focusSeatIds: ['hj'],
      focusLabels: ['Middle', 'Seat'],
    ),
  ],
);

final _w1SeatedAllInTable =
    _act0W1MoveHeroV1(
      _allInMeaningRunner.table,
      'hj',
      history: const [
        Act0ActionTrailItemV1.note(label: 'Blinds: 1.5 BB'),
        Act0ActionTrailItemV1.note(label: 'UTG folds'),
        Act0ActionTrailItemV1.note(
          label: 'Hero all-in 20 BB',
          displayLabel: 'You go all-in for 20 BB',
        ),
        Act0ActionTrailItemV1.note(label: 'CO calls, 20 BB total'),
        Act0ActionTrailItemV1.note(label: 'BTN folds'),
        Act0ActionTrailItemV1.note(label: 'SB folds'),
        Act0ActionTrailItemV1.note(label: 'BB folds'),
      ],
    ).copyWith(
      handContributions: const Act0HandContributionsV1(
        throughStreet: PokerStreet.preflop,
        startingStackBbBySeat: {'hj': 20, 'co': 100},
        entries: [
          ..._act0LessonBlinds,
          Act0ContributionV1(
            PokerStreet.preflop,
            'hj',
            Act0ContributionKindV1.wager,
            20,
          ),
          Act0ContributionV1(
            PokerStreet.preflop,
            'co',
            Act0ContributionKindV1.wager,
            20,
          ),
        ],
      ),
    );

final _w1SeatedAllInRunner = _allInMeaningRunner.copyWith(
  table: _w1SeatedAllInTable,
);

final _w1SeatedMatchedChipsRunner = _matchedChipsTransferRunner.copyWith(
  table: _w1SeatedAllInTable.copyWith(
    centerLabel: 'Matched chips set the contest',
  ),
);

Act0RunnerStateV1 _w1WithDistractorV1(
  Act0RunnerStateV1 runner, {
  required String id,
  required String label,
  required String reason,
  String? seatId,
}) {
  final answer = runner.options.singleWhere(
    act0RunnerOptionIsAuthoredCorrectV1,
  );
  return runner.copyWith(
    options: [
      ...runner.options,
      Act0RunnerOptionV1(
        id: id,
        label: label,
        seatId: seatId,
        isCorrect: false,
        preferredLabel: answer.preferredLabel,
        betterAnswerLabel: answer.betterAnswerLabel,
        quality: Act0FeedbackQualityV1.wrong,
        feedbackTitle: 'Read the deciding detail.',
        feedbackReason: reason,
      ),
    ],
    table: seatId == null
        ? runner.table
        : runner.table.copyWith(
            selectableSeatIds: [...runner.table.selectableSeatIds, seatId],
          ),
  );
}

Act0TableStateV1 _w1WithPocketPairV1(
  Act0TableStateV1 table,
  String rank, {
  String firstSuit = 'h',
}) {
  final cards = [
    Act0CardStateV1(
      rank: rank,
      suit: firstSuit,
      tone: firstSuit == 'h' ? Act0CardToneV1.red : Act0CardToneV1.dark,
    ),
    Act0CardStateV1(rank: rank, suit: 's'),
  ];
  return table.copyWith(
    heroCards: cards,
    seats: [
      for (final seat in table.seats)
        seat.isHero ? _act0CopySeatStateV1(seat, holeCards: cards) : seat,
    ],
  );
}

Act0RunnerStateV1 _w1WithNumericLabelsV1(
  Act0RunnerStateV1 runner,
  Map<String, String> labels, {
  String? question,
  Map<String, String> reasons = const {},
  Map<String, String> ids = const {},
  List<String>? focusSeats,
}) {
  final correct = runner.options.singleWhere(
    act0RunnerOptionIsAuthoredCorrectV1,
  );
  final answer = labels[correct.label]!;
  return runner.copyWith(
    question: question,
    table: runner.table.selectableSeatIds.isEmpty
        ? runner.table
        : runner.table.copyWith(selectableSeatIds: const []),
    options: [
      for (final option in runner.options)
        Act0RunnerOptionV1(
          id: ids[option.id] ?? option.id,
          label: labels[option.label]!,
          preferredLabel: answer,
          isCorrect: option.isCorrect,
          quality: option.quality,
          feedbackTitle: option.feedbackTitle,
          feedbackReason: reasons[option.id] ?? option.feedbackReason,
          repairFocusSeatIds: focusSeats ?? option.repairFocusSeatIds,
          repairFocusCardIds: option.repairFocusCardIds,
          repairFocusLabels: option.repairFocusLabels,
        ),
    ],
  );
}

// Keep the canonical trail for source consumers and anonymize only learner copy.
Act0TableStateV1 _w1EarlySeatCopyV1(
  Act0TableStateV1 table, {
  required String opener,
  bool adjacentOpener = false,
  bool hideEarlySeats = false,
}) => table.copyWith(
  handContributions: table.handContributions,
  actionTrail: [
    for (final action in table.actionTrail)
      if (action.isNote)
        action
      else
        Act0ActionTrailItemV1(
          label: action.label,
          displayLabel: action.learnerLabel
              .replaceAllMapped(
                RegExp('\\b$opener (raises|checks)\\b'),
                (match) => switch (match[1]) {
                  'raises' =>
                    adjacentOpener
                        ? 'The player before you raises'
                        : 'Another player raises',
                  _ => 'The raiser checks',
                },
              )
              .replaceAll(
                RegExp(
                  hideEarlySeats
                      ? r'\b(?:UTG|HJ|CO|BTN)\b'
                      : r'\b(?:UTG|HJ|CO)\b',
                ),
                'An earlier player',
              ),
        ),
  ],
);

final _w1FirstDecisionRunner = Act0RunnerStateV1(
  lessonId: 'first_table_guide_first_decision',
  lessonTitle: 'First Table Guide',
  lessonSubtitle: '',
  beatIndex: 1,
  beatCount: 1,
  phase: Act0LessonPhaseV1.drill,
  caption: 'The player before you raised to 2.5 BB.',
  hint: '',
  question: 'How will you play your aces?',
  options: const [
    Act0RunnerOptionV1(
      id: 'fold',
      label: 'Fold',
      isCorrect: false,
      preferredLabel: 'Raise to 7.5 BB',
      betterAnswerLabel: 'Raise to 7.5 BB',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Your aces can play.',
      feedbackReason:
          'Folding aces to one raise gives up the strongest starting hand and the chance to win this pot.',
    ),
    Act0RunnerOptionV1(
      id: 'call',
      label: 'Call',
      amountLabel: '2.5 BB',
      isCorrect: false,
      preferredLabel: 'Raise to 7.5 BB',
      betterAnswerLabel: 'Raise to 7.5 BB',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Calling keeps you in.',
      feedbackReason:
          'Calling 2.5 BB keeps you in. Raising can get the player before you to pay more while you have the strongest hand.',
    ),
    Act0RunnerOptionV1(
      id: 'raise',
      label: 'Raise to 7.5 BB',
      isCorrect: true,
      preferredLabel: 'Raise to 7.5 BB',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Raise with aces.',
      feedbackReason:
          'With AA, a raise can get the earlier raiser to pay more with weaker pairs or strong aces. A call keeps the pot smaller against those hands.',
    ),
  ],
  feedbackTitle: 'Raise with aces.',
  feedbackReason:
      'Aces are the strongest starting hand. Raise to build the pot.',
  primaryCtaLabel: '',
  nextLessonId: null,
  returnTarget: '',
  table: _w1EarlySeatCopyV1(
    _day7PreflopV1('co', 'As Ac', opener: 'hj', showTurn: true),
    opener: 'HJ',
    adjacentOpener: true,
  ),
  teachingSteps: const [
    Act0TeachingStepV1(
      title: 'Three choices.',
      body:
          'Fold gives up. Call matches the bet. Raise increases it. Two aces are the strongest starting hand. With the strongest hand you want more chips in the pot, so you raise.',
    ),
  ],
);

final _w1FirstIndependentDecisionRunner = _w1FirstDecisionRunner.copyWith(
  lessonId: 'cards_ranks_suits_premium_decision',
  lessonTitle: 'Cards, ranks & suits',
  caption: 'The player before you raised to 2.5 BB.',
  question: 'How will you play your kings?',
  table: _w1EarlySeatCopyV1(
    _day7PreflopV1('btn', 'Kh Kd', opener: 'co', showTurn: true),
    opener: 'CO',
    adjacentOpener: true,
  ),
  hintPolicy: Act0HintPolicyV1.hidden,
  teachingSteps: const [
    Act0TeachingStepV1(
      title: 'Your starting cards.',
      body: 'Two kings are a top starting pair. BTN is Button.',
    ),
  ],
  feedbackTitle: 'Raise with kings.',
  feedbackReason: 'Kings can raise to get paid by a weaker hand.',
  options: const [
    Act0RunnerOptionV1(
      id: 'call',
      label: 'Call',
      amountLabel: '2.5 BB',
      isCorrect: false,
      preferredLabel: 'Raise to 7.5 BB',
      repairFocusLabels: ['Top starting pairs'],
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'The call keeps you in.',
      feedbackReason:
          'Calling 2.5 BB keeps your kings in the hand but gives up the chance to charge a weaker hand more to see the shared cards.',
    ),
    Act0RunnerOptionV1(
      id: 'raise',
      label: 'Raise to 7.5 BB',
      isCorrect: true,
      preferredLabel: 'Raise to 7.5 BB',
      repairFocusLabels: ['Top starting pairs'],
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Raise with kings.',
      feedbackReason:
          "Raise KK to 7.5 BB because the earlier raiser can call with weaker pairs and strong aces. Calling keeps the pot smaller against hands that would pay the raise.",
    ),
    Act0RunnerOptionV1(
      id: 'fold',
      label: 'Fold',
      isCorrect: false,
      preferredLabel: 'Raise to 7.5 BB',
      repairFocusLabels: ['Top starting pairs'],
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Your kings can play.',
      feedbackReason:
          'Folding KK on BTN gives up your chance to win the 4 BB already in against a single raise.',
    ),
  ],
);

final _w1CompareAceStraightsRunner = Act0RunnerStateV1(
  lessonId: 'hand_rankings_compare_ace_straights',
  lessonTitle: 'Compare made hands',
  lessonSubtitle: '',
  beatIndex: 1,
  beatCount: 1,
  phase: Act0LessonPhaseV1.drill,
  caption: 'Suppose the other player has 4♠ 5♥.',
  hint: '',
  question: 'Which straight wins, Broadway or A-2-3-4-5?',
  options: const [
    Act0RunnerOptionV1(
      id: 'broadway',
      label: 'Broadway wins',
      isCorrect: true,
      preferredLabel: 'Broadway wins',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'The ace-high straight wins.',
      feedbackReason:
          'Your king and queen join the ace, jack and ten. This ace-high straight beats the other player’s five-high straight.',
    ),
    Act0RunnerOptionV1(
      id: 'wheel',
      label: 'A-2-3-4-5 wins',
      isCorrect: false,
      preferredLabel: 'Broadway wins',
      betterAnswerLabel: 'Broadway wins',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Read the top of the sequence.',
      feedbackReason:
          'The four and five connect to the board’s ace, two and three. The five is the highest card in that straight. Picking it awards the pot to the lower hand.',
    ),
    Act0RunnerOptionV1(
      id: 'tie',
      label: 'Both straights tie',
      isCorrect: false,
      preferredLabel: 'Broadway wins',
      betterAnswerLabel: 'Broadway wins',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'The ace plays at opposite ends.',
      feedbackReason:
          'The board ace starts the other player’s straight and tops yours. Splitting the pot gives away half of a pot that your higher straight wins.',
    ),
  ],
  feedbackTitle: 'Compare the highest ranks.',
  feedbackReason: 'An ace-high straight beats a five-high straight.',
  primaryCtaLabel: '',
  nextLessonId: null,
  returnTarget: '',
  table: _w1EarlySeatCopyV1(
    _day7PostflopV1('bb', 'Kc Qd', 'Ah 2c 3d Ts Jc', opponent: 'co'),
    opener: 'CO',
  ),
  teachingSteps: const [
    Act0TeachingStepV1(
      title: 'Compare the highest rank.',
      body:
          'Broadway ranks are ten, jack, queen, king, and ace. A-2-3-4-5 is the five-high straight, called the wheel. The higher straight wins.',
    ),
  ],
);

Act0RunnerStateV1 _w1ExtraReadV1({
  required Act0RunnerStateV1 source,
  required String id,
  required String caption,
  required String question,
  required Act0TableStateV1 table,
  required List<(String, String, String)> choices,
  required int correct,
  List<String> repairLabels = const [],
  List<String> repairCards = const [],
}) {
  final answer = choices[correct];
  return source.copyWith(
    lessonId: id,
    phase: Act0LessonPhaseV1.drill,
    caption: caption,
    hint: '',
    question: question,
    table: table,
    teachingSteps: const [],
    feedbackTitle: 'Read the visible facts.',
    feedbackReason: answer.$3,
    options: [
      for (final (index, choice) in choices.indexed)
        Act0RunnerOptionV1(
          id: choice.$1,
          label: choice.$2,
          preferredLabel: answer.$2,
          betterAnswerLabel: index == correct ? '' : answer.$2,
          isCorrect: index == correct,
          quality: index == correct
              ? Act0FeedbackQualityV1.correct
              : Act0FeedbackQualityV1.wrong,
          feedbackTitle: index == correct
              ? 'Correct.'
              : 'Read the table again.',
          feedbackReason: choice.$3,
          repairFocusLabels: repairLabels,
          repairFocusCardIds: repairCards,
        ),
    ],
  );
}

final _pokerFromZeroLessons = <Act0LessonCardV1>[
  Act0LessonCardV1(
    lessonId: 'what_poker_is',
    title: 'Your cards and the board',
    subtitle: 'Tell your own cards apart from the cards everyone can use.',
    state: Act0LessonStateV1.completed,
    phaseLabel: 'Start',
    primaryCtaLabel: 'Replay',
    isSelectable: true,
    isLocked: false,
    rewardXp: 20,
    runner: _firstTableGuideMeetTableRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'what_poker_is_theory',
        title: 'Meet the table',
        phase: Act0LessonPhaseV1.theory,
        runner: _firstTableGuideMeetTableRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _firstTableGuideMeetTableRunner.options,
            correctOptionId: 'bottom',
            correctIndex: 2,
          ),
        ),
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.learn,
        summary: 'Find the two cards that belong to you.',
      ),
      Act0LessonTaskV1(
        taskId: 'what_poker_is_find_hero',
        title: 'Find your seat',
        phase: Act0LessonPhaseV1.drill,
        runner: _firstTableGuideFindHeroRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
        summary: 'Spot where Hero sits before anything else starts moving.',
      ),
      Act0LessonTaskV1(
        taskId: 'first_table_guide_one_clear_choice',
        title: 'Read the preflop setup',
        phase: Act0LessonPhaseV1.drill,
        runner: _firstTableGuideActionRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _firstTableGuideActionRunner.options,
            correctOptionId: 'hero_btn_preflop_setup',
            correctIndex: 1,
          ),
        ),
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
        summary: 'Identify the private cards when the middle is empty.',
      ),
      Act0LessonTaskV1(
        taskId: 'w1_shared_card_access',
        title: 'Which cards can both players use?',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1ExtraReadV1(
          source: _firstTableGuideFindHeroRunner,
          id: 'w1_shared_card_access',
          caption:
              'A second player still has cards at another seat. Your two cards sit beside you, and three more sit in the middle. Read the ranks and check where each group is placed.',
          question: 'Which of the visible cards can that other player use too?',
          table: _day7PostflopV1('bb', 'Jd 4c', 'Qh 8s 3d').copyWith(
            scope: Act0TableScopeV1.orientation,
            potLabel: '',
            actionTrail: const [],
          ),
          choices: const [
            (
              'private',
              'The jack and four beside you',
              'The jack and four sit beside your seat. Giving them to the other player would mix up the two sets of cards.',
            ),
            (
              'shared',
              'The queen, eight and three',
              'The queen, eight and three are in the middle, where both players can use them.',
            ),
            (
              'all',
              'Jack, four, queen, eight and three',
              'The queen, eight and three are shared. Your jack and four belong to your seat, so the other player cannot use them.',
            ),
          ],
          correct: 1,
          repairCards: const ['board_0', 'board_1', 'board_2'],
        ),
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'first_table_guide_shared_cards_repair',
        title: 'Read the cards',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1WithDistractorV1(
          _act0W1SeatObserverV1(
            _privateBoardRunner.copyWith(
              lessonId: 'first_table_guide_shared_cards_repair',
              lessonTitle: 'First Table Guide',
              caption: 'There are two groups of cards in view.',
              feedbackReason:
                  'Everyone can use the cards in the middle. Your two cards belong only to you.',
              table: _privateBoardRunner.table.copyWith(
                scope: Act0TableScopeV1.orientation,
                potLabel: '',
                heroCards: const [
                  Act0CardStateV1(rank: 'K', suit: 'c'),
                  Act0CardStateV1(
                    rank: '9',
                    suit: 'd',
                    tone: Act0CardToneV1.red,
                  ),
                ],
                boardCards: const [
                  Act0CardStateV1(
                    rank: '8',
                    suit: 'h',
                    tone: Act0CardToneV1.red,
                  ),
                  Act0CardStateV1(
                    rank: '5',
                    suit: 'd',
                    tone: Act0CardToneV1.red,
                  ),
                  Act0CardStateV1(rank: '2', suit: 'c'),
                ],
              ),
              teachingSteps: const [],
            ),
            'co',
          ),
          id: 'burn_cards',
          label: 'Cards set aside by the dealer',
          reason:
              'The three middle cards on 8-5-2 can play. Cards set aside by the dealer cannot complete any player’s hand.',
        ),
        rewardXp: 0,
        stepKind: Act0LessonStepKindV1.fixMistakes,
        repairOnly: true,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'chips_in_the_middle',
    title: 'Blinds and the pot',
    subtitle: 'Read the posted chips and the running total in the middle.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Chips',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 15,
    runner: _firstTableGuideMeetTableRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w1_chips_starting_pot',
        title: 'Read the two forced posts',
        phase: Act0LessonPhaseV1.drill,
        runner:
            _w1ExtraReadV1(
              source: _firstTableGuideFindHeroRunner,
              id: 'w1_chips_starting_pot',
              caption:
                  'The two marked seats have put in their starting amounts. Every other stack is still untouched. Read their two contributions before you read the total.',
              question:
                  'What is the total in the middle before anyone chooses what to do?',
              table: _day7PreflopV1('utg', '5s 8c', showTurn: true),
              choices: const [
                (
                  'only_big',
                  '1 BB',
                  'The big blind put in 1 BB. Counting that seat alone leaves out the half chip unit at the other marked seat.',
                ),
                (
                  'both',
                  '1.5 BB',
                  'The two forced amounts are 0.5 and 1 BB. Adding them gives the 1.5 BB already in the middle.',
                ),
                (
                  'only_small',
                  '0.5 BB',
                  'The small blind put in 0.5 BB. The 1 BB from the other marked seat belongs in the same total.',
                ),
              ],
              correct: 1,
            ).copyWith(
              teachingSteps: const [
                Act0TeachingStepV1(
                  title: 'The first two contributions',
                  body:
                      'Blinds are forced contributions: the small blind puts in 0.5 BB and the big blind puts in 1 BB before anyone chooses.',
                ),
                Act0TeachingStepV1(
                  title: 'Read the middle',
                  body:
                      'The pot is the chips in the middle, so add what both players have put in and leave out the chips still in their stacks.',
                ),
              ],
            ),
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w1_chips_matched_pot',
        title: 'Count each contribution once',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1ExtraReadV1(
          source: _firstTableGuideFindHeroRunner,
          id: 'w1_chips_matched_pot',
          caption:
              'One player put in 2.5 BB. The big blind added enough to reach the same total. The small blind stopped playing, and the shared cards arrived with no new chips added.',
          question:
              'How many chips are in the pot when the shared cards arrive?',
          table: _w1EarlySeatCopyV1(
            _day7PostflopV1('bb', '9h 3c', 'Ks 7d 2h', openBb: 2.5),
            opener: 'HJ',
            hideEarlySeats: true,
          ),
          choices: const [
            (
              'two_players',
              '5 BB',
              'Two contributions of 2.5 BB add to 5 BB. That leaves out the half BB the small blind already put in.',
            ),
            (
              'post_twice',
              '6.5 BB',
              'The big blind reached 2.5 BB by adding to its first chip. Adding that first chip again counts it twice.',
            ),
            (
              'total',
              '5.5 BB',
              'Count 2.5 BB from each continuing player and 0.5 BB left by the small blind.',
            ),
          ],
          correct: 2,
        ),
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w1_chips_read_middle',
        title: 'Separate the pot from a stack',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1ExtraReadV1(
          source: _firstTableGuideFindHeroRunner,
          id: 'w1_chips_read_middle',
          caption:
              'The two players still in each put in 3.25 BB. A third player left a half BB in the middle. The numbers beside the seats show the chips those players have left. Keep the chips in those stacks separate from everything the players have put in.',
          question:
              'Which amount tells you how much the players have put in together?',
          table: _w1EarlySeatCopyV1(
            _day7PostflopV1('bb', 'Ts 6d', 'Ah 5s 3h', openBb: 3.25),
            opener: 'HJ',
            hideEarlySeats: true,
          ),
          choices: const [
            (
              'pot',
              '7 BB',
              'The two 3.25 BB amounts and the half BB add up to 7 BB already in the middle.',
            ),
            (
              'one_share',
              '3.25 BB',
              'This is one player’s contribution. Using it alone leaves out the other player and the small blind.',
            ),
            (
              'stack',
              '96.75 BB',
              'This amount is still beside a seat. Counting a remaining stack mistakes chips available for chips already put in.',
            ),
          ],
          correct: 0,
        ),
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'first_table_guide',
    title: 'First Table Guide',
    subtitle:
        'Learn Fold, Call and Raise, then make your first coached choice.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Start',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 15,
    runner: _w1FirstDecisionRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'first_table_guide_first_decision',
        title: 'Decide with your coach',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1FirstDecisionRunner,
        guidedDecision: true,
        rewardXp: 0,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'what_poker_is_table_read_transfer',
        title: 'Read the table',
        phase: Act0LessonPhaseV1.drill,
        runner: _firstTableGuideReadTableRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _firstTableGuideReadTableRunner.options,
            correctOptionId: 'two_three_six',
            correctIndex: 1,
          ),
        ),
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.transfer,
        summary:
            'Read one real table spot: your cards, the board, and the pot.',
      ),
      Act0LessonTaskV1(
        taskId: 'what_poker_is_table_read_recheck',
        title: 'Table read recheck',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1WithNumericLabelsV1(
          _firstTableGuideReadTableRecheckRunner.copyWith(
            table: _w1WithPocketPairV1(
              _firstTableGuideReadTableRecheckRunner.table,
              '8',
            ),
            options: _act0AuthoredCorrectOptionAtV1(
              _firstTableGuideReadTableRecheckRunner.options,
              correctOptionId: 'two_three_four',
              correctIndex: 2,
            ),
          ),
          const {
            '5 board cards are out': '5 board cards are out',
            'Check your two cards and skip the board':
                '2 private cards, no board',
            '2 private cards, 3 board cards, 4 BB in the pot':
                '2 private cards, 3 board cards, 4 BB in the pot',
          },
        ),
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.transfer,
        summary:
            'Repeat the same table scan on a second spot: Hero cards, board, and pot.',
      ),
      Act0LessonTaskV1(
        taskId: 'first_table_guide_route_roles',
        title: 'Where to go next',
        phase: Act0LessonPhaseV1.review,
        runner: _firstTableGuideRouteRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _firstTableGuideRouteRunner.options,
            correctOptionId: 'review',
            correctIndex: 1,
          ),
        ),
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.proveIt,
        taskFamily: Act0TaskFamilyV1.transfer,
        summary:
            'Lock in what Home, Learn, Practice, Review, and You do after the first loop.',
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'cards_ranks_suits',
    title: 'Cards, ranks & suits',
    subtitle: '52 cards, 4 suits, 13 ranks.',
    state: Act0LessonStateV1.completed,
    phaseLabel: 'Cards',
    primaryCtaLabel: 'Replay',
    isSelectable: true,
    isLocked: false,
    rewardXp: 20,
    runner: _firstHandRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'cards_ranks_suits_theory',
        title: 'The deck',
        phase: Act0LessonPhaseV1.theory,
        runner: _deckIntroRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'cards_ranks_suits_rank_drill',
        title: 'Higher card',
        phase: Act0LessonPhaseV1.drill,
        runner: _cardsRanksRunner.copyWith(
          teachingSteps: [
            ..._cardsRanksRunner.teachingSteps,
            const Act0TeachingStepV1(
              title: 'Pairs at the top.',
              body:
                  'Top starting pairs can reraise to get paid by weaker hands.',
            ),
          ],
          options: _act0AuthoredCorrectOptionAtV1(
            _cardsRanksRunner.options,
            correctOptionId: 'ace',
            correctIndex: 2,
          ),
        ),
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'cards_ranks_suits_premium_decision',
        title: 'Decide with kings',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1FirstIndependentDecisionRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'cards_ranks_suits_suit_drill',
        title: 'Name a suit',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1WithNumericLabelsV1(
          _w1WithDistractorV1(
            _suitsRunner,
            id: 'diamonds',
            label: 'Diamonds',
            reason:
                'Ah ends in h for hearts. Kd ends in d for diamonds, so reading d here mixes up the two private cards.',
          ),
          const {
            'Hearts': '1 heart',
            'Ace': '0 hearts',
            'Diamonds': '2 hearts',
          },
          question:
              'Read which suit each private card has. How many are hearts?',
          reasons: const {
            'hearts': 'Ah is one heart. The other card, Kd, is a diamond.',
            'rank': 'The A in Ah names the rank. The h shows one heart.',
            'diamonds':
                'Kd is the diamond. Ah is the one card with a heart suit.',
          },
          ids: const {},
        ),
        taskFamily: Act0TaskFamilyV1.recognition,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'cards_ranks_suits_private_board',
        title: 'Private vs board',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1WithDistractorV1(
          _privateBoardRunner.copyWith(
            table: _w1WithPocketPairV1(_privateBoardRunner.table, '9'),
            options: _act0AuthoredCorrectOptionAtV1(
              _privateBoardRunner.options,
              correctOptionId: 'board',
              correctIndex: 1,
            ),
          ),
          id: 'burn_cards',
          label: 'Cards the dealer sets aside',
          reason:
              'The shared cards shown on A-7-2 stay in play. A card set aside by the dealer cannot be used in your best five.',
        ),
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'cards_ranks_suits_board_count',
        title: 'Board count',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1WithNumericLabelsV1(
          _boardCountRunner.copyWith(
            table: _w1WithPocketPairV1(_boardCountRunner.table, '9'),
            teachingSteps: const [
              Act0TeachingStepV1(
                title: 'Count the board.',
                body:
                    'The flop has three shared cards. The turn is the fourth.',
                focusCardIds: [
                  'board_0',
                  'board_1',
                  'board_2',
                  'board_3',
                  'board_4',
                ],
                focusLabels: ['Shared cards'],
              ),
            ],
          ),
          const {'Five': '5 cards', 'Two': '2 cards', 'Three': '3 cards'},
        ),
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.counting,
      ),
      Act0LessonTaskV1(
        taskId: 'cards_ranks_suits_best_five',
        title: 'Best five idea',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1WithDistractorV1(
          _bestFiveCardsRunner.copyWith(
            table: _w1WithPocketPairV1(_bestFiveCardsRunner.table, 'T'),
          ),
          id: 'three',
          label: 'Three',
          reason:
              'Ah 7c 2d Jc 4s are five shared cards. Using only three cards leaves your final hand incomplete.',
        ),
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'cards_ranks_suits_recap',
        title: 'Cards recap',
        phase: Act0LessonPhaseV1.review,
        runner: _w1WithDistractorV1(
          _act0WithWrongFeedbackReasonsV1(
            _cardsRecapRunner.copyWith(
              table: _w1WithPocketPairV1(_cardsRecapRunner.table, 'T'),
              options: _act0AuthoredCorrectOptionAtV1(
                _cardsRecapRunner.options,
                correctOptionId: 'five',
                correctIndex: 1,
              ),
            ),
            const {
              'seven':
                  'With Th Ts and five board cards on Ah 7c 2d Jc 4s, counting seven cards misreads your hand because only the best five count in your final hand.',
            },
          ),
          id: 'two',
          label: 'Two',
          reason:
              'Th Ts are your two private cards. Stopping there misses the shared cards that complete the best five.',
        ),
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.proveIt,
        summary:
            'Prove you can separate rank, suit, board, and best-five ideas cleanly.',
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'hand_rankings_table',
    title: 'Hand rankings 1',
    subtitle: 'High card, a pair, two pair, and three of a kind.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Ranks',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 30,
    runner: _readBoardRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'hand_rankings_theory',
        title: 'Hands use five cards',
        phase: Act0LessonPhaseV1.theory,
        runner: _w1WithDistractorV1(
          _handRankingIntroRunner,
          id: 'suit_rank',
          label: 'Which suit is strongest',
          reason:
              'Your private ace matches the board ace. Ranking suits instead of hands misses that one pair beats high card.',
        ),
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'hand_rankings_pair_drill',
        title: 'Find the pair',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1WithNumericLabelsV1(
          _w1WithDistractorV1(
            _handRankingsRunner.copyWith(
              options: _act0AuthoredCorrectOptionAtV1(
                _handRankingsRunner.options,
                correctOptionId: 'pair',
                correctIndex: 1,
              ),
            ),
            id: 'two_pair',
            label: 'Two pair',
            reason:
                'A-K matches the ace on A-7-2. Your king has no match, so counting it as another pair overstates the hand.',
          ),
          const {
            'High card': '0 pairs',
            'Pair': '1 pair',
            'Two pair': '2 pairs',
          },
          question: 'How many paired ranks are in your hand here?',
        ),
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'hand_rankings_two_pair_drill',
        title: 'Two pair vs one pair',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1WithDistractorV1(
          _twoPairRunner,
          id: 'high_card',
          label: 'High card',
          reason:
              'A-7 matches both the shared ace and the shared seven. Calling it high card overlooks two pairs.',
        ),
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'hand_rankings_trips_drill',
        title: 'Trips or set',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1WithDistractorV1(
          _tripsRankRunner.copyWith(
            options: _act0AuthoredCorrectOptionAtV1(
              _tripsRankRunner.options,
              correctOptionId: 'trips',
              correctIndex: 1,
            ),
          ),
          id: 'one_pair',
          label: 'One pair',
          reason:
              'With two matching private cards and a third of the same rank on the board, counting one pair leaves out the third card that wins the comparison.',
        ),
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'hand_rankings_find_the_match',
        title: 'Match a private card',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1ExtraReadV1(
          source: _twoPairRunner,
          id: 'hand_rankings_find_the_match',
          caption:
              'Compare each of your two cards with the three shared cards.',
          question: 'Which rank forms your pair here?',
          table: _w1EarlySeatCopyV1(
            _day7PostflopV1('bb', 'Kd 8d', 'Qh 8c 2h', opponent: 'btn'),
            opener: 'BTN',
          ),
          choices: const [
            (
              'kings',
              'Kings',
              'Your king has no match among Q-8-2. Counting kings gives your hand a pair it cannot make.',
            ),
            (
              'queens',
              'Queens',
              'There is one queen in the middle and none at your seat. Counting queens misses the two eights.',
            ),
            (
              'eights',
              'Eights',
              'Your eight matches the shared eight, making one pair.',
            ),
          ],
          correct: 2,
          repairCards: const ['board_0', 'board_1', 'board_2'],
        ),
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'hand_rankings_sequences',
    title: 'Straights and flushes',
    subtitle: 'Use consecutive ranks and matching suits.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Ranks',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 29,
    runner: _straightRankRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'hand_rankings_straight_drill',
        title: 'Find the straight',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1WithNumericLabelsV1(
          _w1WithDistractorV1(
            _straightRankRunner,
            id: 'matching_ranks',
            label: 'Five cards with a pair',
            reason:
                'The 5-6-7 on the board joins your 8-9 with no rank repeated. Looking for a pair would miss this straight.',
          ),
          const {
            'Five in a row': '5 ranks in a row',
            'Same suit': '5 cards of one suit',
            'Five cards with a pair': '5 cards including one pair',
          },
        ),
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'hand_rankings_flush_drill',
        title: 'Flush beats straight',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1WithDistractorV1(
          _flushRankRunner.copyWith(
            options: _act0AuthoredCorrectOptionAtV1(
              _flushRankRunner.options,
              correctOptionId: 'flush',
              correctIndex: 1,
            ),
          ),
          id: 'high_card',
          label: 'High card',
          reason:
              'Your king and queen join three hearts on the board. Reading a high card misses the five matching suits that win.',
        ),
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'hand_rankings_royal_flush_drill',
        title: 'Royal flush check',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1WithDistractorV1(
          _royalFlushRankRunner,
          id: 'mixed_straight',
          label: 'Straight with mixed suits',
          reason:
              'The run T-J-Q-K-A is made of hearts. Ignoring the suit understates the ace-high straight flush.',
        ),
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'hand_rankings_review',
        title: 'Ranking recap',
        phase: Act0LessonPhaseV1.review,
        runner: _w1WithDistractorV1(
          _rankingRecapRunner,
          id: 'tied_ranks',
          label: 'They rank the same',
          reason:
              'Your two hearts join three on the board for a flush. A straight uses a different pattern and ranks lower.',
        ),
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.proveIt,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'hand_rankings_upper',
    title: 'Full houses and four of a kind',
    subtitle: 'Count matching ranks and compare the resulting hands.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Ranks',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 28,
    runner: _fullHouseRankRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'hand_rankings_full_house_drill',
        title: 'Full house shape',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1WithDistractorV1(
          _fullHouseRankRunner,
          id: 'four_of_a_kind',
          label: 'Four of a kind',
          reason:
              'The board has three aces. Your two sevens form the pair, so there is no fourth ace for four of a kind.',
        ),
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'hand_rankings_quads_drill',
        title: 'Four of a kind',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1WithNumericLabelsV1(
          _w1WithDistractorV1(
            _quadsRankRunner.copyWith(
              options: _act0AuthoredCorrectOptionAtV1(
                _quadsRankRunner.options,
                correctOptionId: 'quads',
                correctIndex: 1,
              ),
            ),
            id: 'three_of_a_kind',
            label: 'Three of a kind',
            reason:
                'Two matching private cards join the two matching board cards. Three of a kind leaves out one card from the four of that rank.',
          ),
          const {
            'Four of a kind': '4 of one rank',
            'Full house': '3 of one rank and a pair',
            'Three of a kind': '3 of one rank',
          },
          question: 'What matching ranks make up your best hand?',
        ),
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'hand_rankings_full_house_vs_flush_drill',
        title: 'Full house beats flush',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1WithDistractorV1(
          _fullHouseVsFlushRunner.copyWith(
            options: _act0AuthoredCorrectOptionAtV1(
              _fullHouseVsFlushRunner.options,
              correctOptionId: 'hero_full_house',
              correctIndex: 1,
            ),
          ),
          id: 'board_tie',
          label: 'Tie on the shared board',
          reason:
              'The two shown hands use different private cards. Aces full of sevens rank higher than the other player’s flush, so these two shown hands do not tie.',
        ),
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.compare,
      ),
      Act0LessonTaskV1(
        taskId: 'hand_rankings_quads_vs_full_house_drill',
        title: 'Four of a kind beats a full house',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1WithDistractorV1(
          _quadsVsFullHouseRunner,
          id: 'board_tie',
          label: 'The two shown hands tie',
          reason:
              'The pair in your hand completes four of a kind on this board. A tie would miss the difference between four of a kind and a full house.',
        ),
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.compare,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'hand_rankings_comparisons',
    title: 'Compare made hands',
    subtitle: 'Use the best five to break a tie or rank two hands.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Ranks',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 28,
    runner: _bestFiveShowdownRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'hand_rankings_best_five_drill',
        title: 'Choose best five',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1WithDistractorV1(
          _bestFiveShowdownRunner,
          id: 'omit_pair',
          label: 'Seven',
          reason:
              'The sevens form one of your two pairs. The jack plays as a side card, leaving the four outside the best five.',
        ),
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'hand_rankings_compare_ace_straights',
        title: 'Two straights, one winner',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1CompareAceStraightsRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.compare,
      ),
      Act0LessonTaskV1(
        taskId: 'hand_rankings_royal_vs_flush_drill',
        title: 'Royal flush wins',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1WithNumericLabelsV1(
          _w1WithDistractorV1(
            _royalFlushVsFlushRunner.copyWith(
              options: _act0AuthoredCorrectOptionAtV1(
                _royalFlushVsFlushRunner.options,
                correctOptionId: 'hero_royal_flush',
                correctIndex: 1,
              ),
            ),
            id: 'heart_tie',
            label: 'The two heart hands tie',
            reason:
                'You finish the T-J-Q-K-A run in hearts. Treating it like the other flush ignores the connected ranks that win.',
          ),
          const {
            'Your royal flush': '5 in a row, yours',
            'Other player: ace-high flush': '3 in a row, other player’s',
            'The two heart hands tie': '3 in a row each',
          },
          question: 'Which run of hearts wins this comparison?',
        ),
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.compare,
      ),
      Act0LessonTaskV1(
        taskId: 'showdown_kicker_drill',
        title: 'Same pair, better kicker',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1WithDistractorV1(
          _showdownKickerRunner,
          id: 'tie',
          label: 'Both pairs tie',
          reason:
              'The board ace gives both players a pair of aces. Your king beats the queen as the highest side card, so splitting would miss the winner.',
        ),
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.compare,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'blinds_action_order',
    title: 'Seats and blinds',
    subtitle: 'Read where everyone sits and what the blinds post.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Order',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 30,
    runner: _whatYouCanDoRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'positions_theory',
        title: 'Six seats',
        phase: Act0LessonPhaseV1.theory,
        runner: _act0W1SeatObserverV1(
          _positionsRunner.copyWith(
            teachingSteps: const [
              Act0TeachingStepV1(
                title: 'When cards reach the board',
                body: 'Preflop means no board cards yet. The flop has three.',
              ),
              Act0TeachingStepV1(
                title: 'Read the seat labels.',
                body:
                    'UTG means Under the Gun. HJ is Hijack, CO is Cutoff and BTN is Button. SB and BB are the blinds. Acting later lets you see more moves before you decide.',
                focusLabels: ['UTG', 'HJ', 'CO', 'BTN', 'SB', 'BB'],
              ),
            ],
            options: _act0AuthoredCorrectOptionAtV1(
              const <Act0RunnerOptionV1>[
                Act0RunnerOptionV1(
                  id: 'top',
                  label: 'UTG',
                  seatId: 'utg',
                  isCorrect: false,
                  preferredLabel: 'BTN',
                  quality: Act0FeedbackQualityV1.wrong,
                  feedbackTitle: 'Read the dealer marker.',
                  feedbackReason:
                      'UTG is an early position, not the dealer button.',
                ),
                Act0RunnerOptionV1(
                  id: 'bottom',
                  label: 'BTN',
                  seatId: 'btn',
                  isCorrect: true,
                  preferredLabel: 'BTN',
                  quality: Act0FeedbackQualityV1.correct,
                  feedbackTitle: 'Button marker identified.',
                  feedbackReason:
                      'BTN marks the dealer button in this six-seat table.',
                ),
                Act0RunnerOptionV1(
                  id: 'random',
                  label: 'BB',
                  seatId: 'bb',
                  isCorrect: false,
                  preferredLabel: 'BTN',
                  quality: Act0FeedbackQualityV1.wrong,
                  feedbackTitle: 'Read the dealer marker.',
                  feedbackReason: 'BB is the big blind, not the dealer button.',
                ),
              ],
              correctOptionId: 'bottom',
              correctIndex: 2,
            ),
          ),
          'co',
        ),
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'positions_button',
        title: 'Tap the Button',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1WithDistractorV1(
          _buttonSeatRunner,
          id: 'bb',
          label: 'BB',
          reason:
              'BB posts 1 BB. The dealer marker sits by BTN, so choosing BB identifies the wrong role.',
          seatId: 'bb',
        ),
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'positions_utg',
        title: 'Tap UTG',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1WithDistractorV1(
          _act0W01ExplicitOrderRunnerV1(
            _utgSeatRunner.copyWith(
              // Recognition choices stay neutral; authored teaching keeps its focus.
              table: _utgSeatRunner.table.copyWith(
                highlightedSeatIds: const <String>[],
                activeSeatId: '',
              ),
              options: _act0AuthoredCorrectOptionAtV1(
                _utgSeatRunner.options,
                correctOptionId: 'utg',
                correctIndex: 1,
              ),
            ),
            frame: _Act0W01OrderFrameV1.first,
            taskId: 'positions_utg',
          ),
          id: 'sb',
          label: 'SB',
          reason:
              'SB is the seat between BTN and BB. UTG is the next seat clockwise after BB.',
          seatId: 'sb',
        ),
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'positions_cutoff',
        title: 'Tap the cutoff',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1WithDistractorV1(
          _act0W1SeatObserverV1(
            _act0NeutralSeatAssessmentPreservingTeachingV1(_cutoffSeatRunner),
            'hj',
          ),
          id: 'sb',
          label: 'SB',
          reason:
              'SB sits after the Button. The cutoff is the seat before it, so this would put the cutoff on the wrong side.',
          seatId: 'sb',
        ),
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'blinds_missing_post_amount',
        title: 'Find the big blind amount',
        phase: Act0LessonPhaseV1.drill,
        runner: _blindsOrderRunner.copyWith(
          phase: Act0LessonPhaseV1.drill,
          teachingSteps: const [],
          table: _act0W01ExplicitOrderRunnerV1(
            _blindsOrderRunner,
            frame: _Act0W01OrderFrameV1.first,
            taskId: 'blinds_missing_post_amount',
          ).table.copyWith(selectableSeatIds: const []),
          caption: 'The pot starts at 1.5 BB. SB posted 0.5 BB.',
          hint: '',
          question: 'How much of the starting pot came from BB?',
          feedbackTitle: 'Subtract the small blind.',
          feedbackReason:
              'Subtract the 0.5 BB from SB. The remaining 1 BB came from BB.',
          options: const [
            Act0RunnerOptionV1(
              id: 'small_blind_only',
              label: '0.5 BB',
              isCorrect: false,
              preferredLabel: '1 BB',
              repairFocusSeatIds: ['bb', 'sb'],
              quality: Act0FeedbackQualityV1.wrong,
              feedbackTitle: 'Look at which player paid.',
              feedbackReason:
                  'The 0.5 BB was posted by SB. Using it for BB would leave half a big blind uncounted.',
            ),
            Act0RunnerOptionV1(
              id: 'big_blind_amount',
              label: '1 BB',
              isCorrect: true,
              preferredLabel: '1 BB',
              repairFocusSeatIds: ['bb', 'sb'],
              quality: Act0FeedbackQualityV1.correct,
              feedbackTitle: 'BB posted 1 BB.',
              feedbackReason:
                  'One big blind plus the small blind of 0.5 BB makes the 1.5 BB pot.',
            ),
            Act0RunnerOptionV1(
              id: 'both_posts',
              label: '1.5 BB',
              isCorrect: false,
              preferredLabel: '1 BB',
              repairFocusSeatIds: ['bb', 'sb'],
              quality: Act0FeedbackQualityV1.wrong,
              feedbackTitle: 'Separate the two posts.',
              feedbackReason:
                  'The 1.5 BB includes both posts. Giving BB all of it counts SB’s 0.5 BB twice.',
            ),
          ],
        ),
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'blinds_theory',
        title: 'Blinds post first',
        phase: Act0LessonPhaseV1.theory,
        runner: _w1WithNumericLabelsV1(
          _act0W1SeatObserverV1(
            _blindsOrderRunner.copyWith(
              table: _blindsOrderRunner.table.copyWith(
                selectableSeatIds: const ['btn', 'bb', 'sb'],
              ),
            ),
            'co',
          ),
          const {'BTN': '0 BB', 'BB': '1 BB', 'SB': '0.5 BB'},
          question: 'How many chips did BB post before anyone acted?',
          focusSeats: const ['bb'],
          reasons: const {
            'button_is_not_a_blind':
                'The Button did not post a blind. BB already has a 1 BB chip in front of that seat.',
            'bb':
                'BB posted the full 1 BB. That is the unit used to measure the 1.5 BB pot.',
            'sb':
                'The 0.5 BB post belongs to SB. Counting it as the big blind halves the unit.',
          },
        ),
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'blinds_posts_drill',
        title: '1 BB unit',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1WithDistractorV1(
          _act0WithWrongFeedbackReasonsV1(
            _act0W1SeatObserverV1(_bigBlindPostRunner, 'hj'),
            const {
              'sb':
                  'The 0.5 BB next to SB is half of the 1 BB used to measure this pot.',
            },
          ),
          id: 'btn',
          label: 'BTN',
          reason:
              'BTN has not paid a blind in this hand. The 1 BB chips are in front of BB.',
          seatId: 'btn',
        ),
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'blinds_order_practice',
    title: 'First and last to act',
    subtitle: 'Read where the first betting pass starts and ends.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Order',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 25,
    runner: _firstPreflopActorRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'blinds_first_actor',
        title: 'First preflop actor',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1WithDistractorV1(
          _act0W01ExplicitOrderRunnerV1(
            _act0NeutralSeatAssessmentPreservingTeachingV1(
              _firstPreflopActorRunner,
            ),
            frame: _Act0W01OrderFrameV1.first,
            taskId: 'blinds_first_actor',
            question: 'Who acts first preflop in this frame?',
          ).copyWith(teachingSteps: const <Act0TeachingStepV1>[]),
          id: 'bb',
          label: 'BB',
          reason:
              'BB posted 1 BB but has yet to act voluntarily. UTG chooses first after the blind posts.',
          seatId: 'bb',
        ),
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'blinds_last_actor',
        title: 'Last preflop actor',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1WithDistractorV1(
          _act0W01ExplicitOrderRunnerV1(
            _lastPreflopActorRunner.copyWith(
              // Recognition choices stay neutral; authored teaching keeps its focus.
              table: _lastPreflopActorRunner.table.copyWith(
                highlightedSeatIds: const <String>[],
                activeSeatId: '',
              ),
              options: _act0AuthoredCorrectOptionAtV1(
                _lastPreflopActorRunner.options,
                correctOptionId: 'bb',
                correctIndex: 1,
              ),
            ),
            frame: _Act0W01OrderFrameV1.option,
            taskId: 'blinds_last_actor',
            question: 'Who has the next option before the flop here?',
          ).copyWith(teachingSteps: const <Act0TeachingStepV1>[]),
          id: 'btn',
          label: 'BTN',
          reason:
              'BTN has already matched the blind. BB has posted the same amount and still has the option.',
          seatId: 'btn',
        ),
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'blinds_postflop_button',
        title: 'Last to act on the flop',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1WithDistractorV1(
          _act0W01ExplicitOrderRunnerV1(
            _postflopButtonActorRunner,
            frame: _Act0W01OrderFrameV1.flop,
            taskId: 'blinds_postflop_button',
          ),
          id: 'bb',
          label: 'BB',
          reason:
              'BB acts near the start of this flop. Choosing BB overlooks the Button, which sees the earlier actions.',
          seatId: 'bb',
        ),
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'blinds_button_moves',
        title: 'Button moves',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1WithNumericLabelsV1(
          _w1WithDistractorV1(
            _act0W1SeatObserverV1(
              _act0WithWrongFeedbackReasonsV1(
                _buttonMovesRunner.copyWith(
                  options: _act0AuthoredCorrectOptionAtV1(
                    _buttonMovesRunner.options,
                    correctOptionId: 'btn',
                    correctIndex: 1,
                  ),
                ),
                const {
                  'co':
                      'CO sits one seat before BTN in this 1.5 BB preflop pot, so picking CO misidentifies the dealer marker and who acts last after the flop.',
                },
              ),
              'utg',
            ),
            id: 'bb',
            label: 'BB',
            reason:
                'BB shows the 1 BB post in this hand. Its blind chips mark a different role from the dealer marker beside BTN.',
            seatId: 'bb',
          ),
          const {'CO': '0 seats', 'BTN': '1 seat', 'BB': '2 seats'},
          question: 'How far does the dealer marker move after this hand?',
          reasons: const {
            'co':
                'The marker at BTN does move. Leaving it in place would repeat the same blind positions.',
            'btn':
                'It goes one seat clockwise. Moving one seat changes who posts the blinds on the next hand.',
            'bb':
                'Moving two seats skips the next player. The marker moves one seat at a time.',
          },
        ),
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'blinds_pot_after_posts',
        title: 'Count the two posts',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1ExtraReadV1(
          source: _firstPreflopActorRunner,
          id: 'blinds_pot_after_posts',
          caption:
              'Both blinds have posted. You are first to act and nobody else has added chips.',
          question: 'What total have the two players put in the middle?',
          table: _day7PreflopV1('utg', 'Jc 6h', showTurn: true),
          choices: const [
            (
              'both',
              '1.5 BB',
              'The small blind added 0.5 BB and the big blind added 1 BB. Together that is 1.5 BB.',
            ),
            (
              'bb_only',
              '1 BB',
              'The big blind paid 1 BB. That leaves out the 0.5 BB small blind already in the middle.',
            ),
            (
              'equal_posts',
              '2 BB',
              'The small blind paid 0.5 BB, so counting two full blinds adds half a BB that nobody paid.',
            ),
          ],
          correct: 0,
          repairLabels: const ['Big blind'],
        ),
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'blinds_review',
        title: 'Order recap',
        phase: Act0LessonPhaseV1.review,
        runner: _w1WithDistractorV1(
          _act0WithWrongFeedbackReasonsV1(
            _act0W01ExplicitOrderRunnerV1(
              _meetTableRunner.copyWith(
                phase: Act0LessonPhaseV1.review,
                lessonId: 'blinds_order_recap',
                caption: 'Lesson learned: blinds post before the first choice.',
                hint: 'Think about who makes the first voluntary choice.',
                question: 'Who acts first preflop?',
                feedbackTitle: 'Order takeaway.',
                feedbackReason:
                    'Preflop starts left of the big blind. After the flop, action starts left of the Button.',
                options: _act0AuthoredCorrectOptionAtV1(
                  _firstPreflopActorRunner.options,
                  correctOptionId: 'utg',
                  correctIndex: 0,
                ),
                table: _meetTableRunner.table.copyWith(
                  highlightedSeatIds: const <String>[],
                  selectableSeatIds: const <String>['utg', 'btn'],
                ),
                teachingSteps: const <Act0TeachingStepV1>[
                  Act0TeachingStepV1(
                    title: 'Order recap.',
                    body: 'Blinds post before the first voluntary decision.',
                    focusSeatIds: <String>['sb', 'bb'],
                    focusLabels: <String>['Post first'],
                  ),
                ],
              ),
              frame: _Act0W01OrderFrameV1.first,
              taskId: 'blinds_review',
            ).copyWith(teachingSteps: const <Act0TeachingStepV1>[]),
            const {
              'btn':
                  'BTN acts after UTG, HJ and CO on this first preflop pass. UTG has the first voluntary decision.',
            },
          ),
          id: 'sb',
          label: 'SB',
          reason:
              'The 0.5 BB post starts the pot. It does not make SB first to act voluntarily before the flop.',
          seatId: 'sb',
        ),
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.proveIt,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'positions',
    title: 'Why position matters',
    subtitle: 'Early seats decide first. The Button sees more.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Seats',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 20,
    runner: _meetTableRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'positions_late_seat',
        title: 'Late seat meaning',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1WithDistractorV1(
          _act0W01ExplicitOrderRunnerV1(
            _latePositionRunner.copyWith(
              options: _act0AuthoredCorrectOptionAtV1(
                _latePositionRunner.options,
                correctOptionId: 'btn',
                correctIndex: 1,
              ),
            ),
            frame: _Act0W01OrderFrameV1.flop,
            taskId: 'positions_late_seat',
            question:
                'Who can use the information if UTG checks before their turn?',
          ),
          id: 'bb',
          label: 'BB',
          reason:
              'BB acts before UTG after the flop in this hand. It cannot use a check that UTG has yet to make.',
          seatId: 'bb',
        ),
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'positions_early_late',
        title: 'Early vs late',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1WithDistractorV1(
          _act0W01ExplicitOrderRunnerV1(
            _act0NeutralSeatAssessmentPreservingTeachingV1(
              _earlyLatePositionRunner,
            ),
            frame: _Act0W01OrderFrameV1.first,
            taskId: 'positions_early_late',
            question:
                'Which seat has more players left to act behind it, UTG or BTN?',
          ),
          id: 'hj',
          label: 'HJ',
          reason:
              'HJ follows UTG, so one fewer seat remains behind HJ on this first pass.',
          seatId: 'hj',
        ),
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'positions_read_first_check',
        title: 'Use the earlier action',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1ExtraReadV1(
          source: _postflopButtonActorRunner,
          id: 'positions_read_first_check',
          caption:
              'Only you and the big blind saw the flop. The action list starts with the forced posts and includes actions from both rounds. You still have a decision to make.',
          question: 'Who has already acted since the shared cards arrived?',
          table: _day7PostflopV1(
            'btn',
            'Tc 8d',
            'As 8h 3c',
            checkedToHero: true,
            showTurn: true,
          ),
          choices: const [
            (
              'hj',
              'HJ',
              'HJ folded before the shared cards. Counting that seat misses the check from the remaining opponent.',
            ),
            (
              'bb',
              'BB',
              'BB checked first. You can use that information before choosing what to do on the Button.',
            ),
            (
              'btn',
              'BTN',
              'BTN is still waiting to act. BB is the seat that already checked on this flop.',
            ),
          ],
          correct: 1,
          repairLabels: const ['Hero on the Button'],
        ),
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'positions_review',
        title: 'Position recap',
        phase: Act0LessonPhaseV1.review,
        runner: _w1WithNumericLabelsV1(
          _act0W01ExplicitOrderRunnerV1(
            _positionsRecapRunner.copyWith(
              options: _act0AuthoredCorrectOptionAtV1(
                const <Act0RunnerOptionV1>[
                  Act0RunnerOptionV1(
                    id: 'top',
                    label: 'UTG',
                    seatId: 'utg',
                    isCorrect: false,
                    preferredLabel: 'BTN',
                    quality: Act0FeedbackQualityV1.wrong,
                    feedbackTitle: 'Read the order after the flop.',
                    feedbackReason:
                        'UTG acts before BTN after the flop in this six-seat hand.',
                  ),
                  Act0RunnerOptionV1(
                    id: 'bottom',
                    label: 'BTN',
                    seatId: 'btn',
                    isCorrect: true,
                    preferredLabel: 'BTN',
                    quality: Act0FeedbackQualityV1.correct,
                    feedbackTitle: 'Order after the flop read.',
                    feedbackReason:
                        'BTN acts last after the flop in this six-seat hand.',
                  ),
                  Act0RunnerOptionV1(
                    id: 'random',
                    label: 'BB',
                    seatId: 'bb',
                    isCorrect: false,
                    preferredLabel: 'BTN',
                    quality: Act0FeedbackQualityV1.wrong,
                    feedbackTitle: 'Read the order after the flop.',
                    feedbackReason:
                        'BB acts before BTN after the flop in this six-seat hand.',
                  ),
                ],
                correctOptionId: 'bottom',
                correctIndex: 2,
              ),
            ),
            frame: _Act0W01OrderFrameV1.flop,
            taskId: 'positions_review',
          ).copyWith(teachingSteps: const <Act0TeachingStepV1>[]),
          const {'UTG': '2 players', 'BTN': '5 players', 'BB': '1 player'},
          question:
              'How many players act before the Button on this first flop pass?',
          focusSeats: const ['btn'],
          reasons: const {
            'top':
                'Two is the number of blinds. UTG, HJ and CO also act before BTN on this flop.',
            'bottom':
                'SB, BB, UTG, HJ and CO are all still in. Those five seats act before BTN.',
            'random':
                "One would be a two-player hand. This flop still has six players, five of them before BTN.",
          },
        ),
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.proveIt,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'fold_check_call_raise',
    title: 'Actions and the price',
    subtitle: 'Match the price, pass for free, fold, or raise.',
    state: Act0LessonStateV1.current,
    phaseLabel: 'Action',
    primaryCtaLabel: 'Continue',
    isSelectable: true,
    isLocked: false,
    rewardXp: 20,
    runner: _whatYouCanDoRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'actions_theory',
        title: 'Action words',
        phase: Act0LessonPhaseV1.theory,
        runner: _act0W01FoldedToBtnMechanicalContextV1(
          _actionWordsRunner.copyWith(
            options: _act0AuthoredCorrectOptionAtV1(
              _actionWordsRunner.options,
              correctOptionId: 'raise',
              correctIndex: 0,
            ),
          ),
        ).copyWith(caption: 'You’re on BTN. Everyone before you folded.'),
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.learn,
        tablePresentation: Act0TaskTablePresentationV1.spatialTheory,
        summary: 'Lock in the four core verbs first: fold, check, call, raise.',
      ),
      Act0LessonTaskV1(
        taskId: 'actions_legal_context',
        title: 'Legal actions',
        phase: Act0LessonPhaseV1.drill,
        runner: _act0W01ExplicitFreeCheckContextV1(
          _legalActionRunner,
          heroSeatId: 'co',
          firstBoardCard: const Act0CardStateV1(
            rank: 'K',
            suit: 'h',
            tone: Act0CardToneV1.red,
          ),
        ),
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
        summary:
            'Match the table state to the actions that are actually allowed.',
        lockedSummary:
            'Open Action words first, then this node starts making sense.',
      ),
      Act0LessonTaskV1(
        taskId: 'actions_check_drill',
        title: 'Check when no bet',
        phase: Act0LessonPhaseV1.drill,
        runner: _act0WithWrongFeedbackReasonsV1(
          _act0W01ExplicitFreeCheckContextV1(_checkActionRunner),
          const {
            'fold':
                'You give up your chance at the pot when you fold. BB has checked, so you can stay in for free.',
            'call':
                'No wager followed BB’s check. A call needs a bet to match. Check for the next board card.',
          },
        ),
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
        tablePresentation: Act0TaskTablePresentationV1.stablePractice,
        summary: 'Recognize the one moment checking is free and correct.',
        lockedSummary: 'Clear Action words first, then unlock the no-bet read.',
      ),
      Act0LessonTaskV1(
        taskId: 'actions_call_chip_cost',
        title: 'Count the cost of a call',
        phase: Act0LessonPhaseV1.drill,
        runner: _callActionRunner.copyWith(
          phase: Act0LessonPhaseV1.drill,
          table: _day7PostflopV1(
            'co',
            'Qc 9c',
            'Ks 9d 5h 2s',
            betBb: 2,
            showTurn: true,
          ),
          teachingSteps: const [],
          caption:
              'BB bets 2 BB on the turn. You have put in nothing on this street.',
          hint: '',
          question: 'How many BB would your call add?',
          feedbackTitle: 'A call matches the bet.',
          feedbackReason:
              'Match the 2 BB turn bet. Chips paid on earlier streets do not count toward the call.',
          options: const [
            Act0RunnerOptionV1(
              id: 'free',
              label: '0 BB',
              isCorrect: false,
              preferredLabel: '2 BB',
              quality: Act0FeedbackQualityV1.wrong,
              feedbackTitle: 'A bet has arrived.',
              feedbackReason:
                  'BB put out 2 BB on this street. Paying nothing leaves the bet unmatched and gives up the hand.',
            ),
            Act0RunnerOptionV1(
              id: 'match_bet',
              label: '2 BB',
              isCorrect: true,
              preferredLabel: '2 BB',
              quality: Act0FeedbackQualityV1.correct,
              feedbackTitle: 'Match the 2 BB.',
              feedbackReason:
                  'BB bet 2 BB and your turn contribution is zero, so the full 2 BB is due.',
            ),
            Act0RunnerOptionV1(
              id: 'match_pot',
              label: '8 BB',
              isCorrect: false,
              preferredLabel: '2 BB',
              quality: Act0FeedbackQualityV1.wrong,
              feedbackTitle: 'Read the bet amount.',
              feedbackReason:
                  'The middle shows 8 BB after the bet. Paying that amount would put in 6 BB more than a call requires.',
            ),
          ],
        ),
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'actions_fold_drill',
        title: 'Fold to exit',
        phase: Act0LessonPhaseV1.drill,
        runner: _act0W01ExplicitFoldMechanicalContextV1(_foldActionRunner),
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.fixMistakes,
        summary:
            'Recognize the action that gives up the hand without paying the bet.',
        lockedSummary:
            'Finish the opener first, then come back to this repair node.',
      ),
      Act0LessonTaskV1(
        taskId: 'actions_call_drill',
        title: 'Call a price',
        phase: Act0LessonPhaseV1.drill,
        runner: _act0W01ExplicitCallPriceContextV1(
          _callActionRunner.copyWith(
            options: _act0AuthoredCorrectOptionAtV1(
              _callActionRunner.options,
              correctOptionId: 'call',
              correctIndex: 2,
            ),
          ),
        ),
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
        summary: 'Read when matching the bet is the cheapest correct continue.',
        lockedSummary:
            'This opens after Action words, once the basic verbs are stable.',
      ),
      Act0LessonTaskV1(
        taskId: 'actions_raise_drill',
        title: 'Raise the price',
        phase: Act0LessonPhaseV1.drill,
        runner: _act0WithWrongFeedbackReasonsV1(
          _act0W01FoldedToBtnMechanicalContextV1(
            _whatYouCanDoRunner,
            heroCards: _heroQJsCards,
            handDescription: 'a queen and jack of the same suit',
          ),
          const {
            'fold':
                'Folding Qs Js on BTN gives up the 1.5 BB pot without putting in chips or forcing SB and BB to pay more than the 1 BB blind.',
            'call':
                'Calling 1 BB on BTN with Qs Js only matches the big blind in the 1.5 BB pot instead of raising to 3 BB and making the blinds pay more.',
          },
          repairLabelsByOptionId: const {
            'fold': ['Your turn', 'Blinds posted', 'QJs'],
          },
        ).copyWith(caption: 'You’re on BTN. Everyone before you folded.'),
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
        summary:
            'Recognize which option increases the price for the next player.',
        lockedSummary:
            'First learn the action menu, then unlock the aggressive option.',
      ),
      Act0LessonTaskV1(
        taskId: 'actions_review',
        title: 'Action recap',
        phase: Act0LessonPhaseV1.review,
        runner: _act0WithWrongFeedbackReasonsV1(
          _act0W01FoldedToBtnMechanicalContextV1(
            _actionRecapRunner.copyWith(
              options: _act0AuthoredCorrectOptionAtV1(
                _actionRecapRunner.options,
                correctOptionId: 'raise',
                correctIndex: 0,
              ),
            ),
          ),
          const {
            'fold':
                'Folding Ks Ts on BTN surrenders the 1.5 BB pot immediately and leaves the 1 BB blind price unchanged for SB and BB.',
            'call':
                'Calling 1 BB on BTN with Ks Ts only matches the blind in the 1.5 BB pot and gives up the chance to raise to 3 BB and pressure the blinds.',
          },
        ).copyWith(caption: 'You’re on BTN. Everyone before you folded.'),
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.proveIt,
        summary: 'Prove you can name the right action without prompts.',
        lockedSummary: 'The recap opens after the action drills are clean.',
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'your_first_hand',
    title: 'Streets and showdown',
    subtitle: 'See each street, then compare the best five cards.',
    state: Act0LessonStateV1.completed,
    phaseLabel: 'Hand',
    primaryCtaLabel: 'Replay',
    isSelectable: true,
    isLocked: false,
    rewardXp: 25,
    runner: _firstHandRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'your_first_hand_preflop',
        title: 'Preflop',
        phase: Act0LessonPhaseV1.theory,
        runner: _act0FirstHandAkRunnerV1(_firstHandRunner).copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _firstHandRunner.options,
            correctOptionId: 'two',
            correctIndex: 0,
          ),
        ),
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'your_first_hand_private_cards_recheck',
        title: 'Private cards recheck',
        phase: Act0LessonPhaseV1.drill,
        runner: _act0FirstHandAkRunnerV1(_privateCardsRecheckRunner),
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.practice,
        summary:
            'Recheck the two private cards that belong to Hero before the board appears.',
      ),
      Act0LessonTaskV1(
        taskId: 'your_first_hand_flop',
        title: 'Flop',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1WithNumericLabelsV1(
          _act0W01NewFirstHandStackContextV1(
            _act0FirstHandAkRunnerV1(_readBoardRunner),
          ),
          const {'Two': '2 cards', 'Three': '3 cards', 'Five': '5 cards'},
        ),
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'your_first_hand_turn',
        title: 'Turn card',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1WithNumericLabelsV1(
          _act0W01NewFirstHandStackContextV1(
            _act0FirstHandAkRunnerV1(_turnBoardRunner),
          ),
          const {'Three': '3 cards', 'Four': '4 cards', 'Five': '5 cards'},
        ),
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'your_first_hand_river',
        title: 'River card',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1WithNumericLabelsV1(
          _act0W01NewFirstHandStackContextV1(
            _act0FirstHandAkRunnerV1(_riverBoardRunner).copyWith(
              options: _act0AuthoredCorrectOptionAtV1(
                _riverBoardRunner.options,
                correctOptionId: 'five',
                correctIndex: 0,
              ),
            ),
          ),
          const {'Five': '5 cards', 'Four': '4 cards', 'Six': '6 cards'},
        ),
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'your_first_hand_showdown',
        title: 'Showdown read',
        phase: Act0LessonPhaseV1.review,
        runner: _act0FirstHandAkRunnerV1(
          _showdownBestHandRunner.copyWith(
            question: 'Who wins, and which five cards win the pot?',
            options: const [
              Act0RunnerOptionV1(
                id: 'first_actor',
                label: 'Other player — J-J-A-K-7',
                isCorrect: false,
                preferredLabel: 'You — A-A-K-J-7',
                quality: Act0FeedbackQualityV1.wrong,
                feedbackTitle: 'Compare the rank of each pair.',
                feedbackReason:
                    'Two aces beat two jacks. Having an ace beside the jacks does not change the rank of the pair.',
              ),
              Act0RunnerOptionV1(
                id: 'hero_cards_only',
                label: 'You — A-A-K-J-4',
                isCorrect: false,
                preferredLabel: 'You — A-A-K-J-7',
                quality: Act0FeedbackQualityV1.wrong,
                feedbackTitle: 'Keep the highest side cards.',
                feedbackReason:
                    'You win with aces. The shared seven is higher than the four, so it belongs in your best five.',
              ),
              Act0RunnerOptionV1(
                id: 'best_hand',
                label: 'You — A-A-K-J-7',
                isCorrect: true,
                preferredLabel: 'You — A-A-K-J-7',
                quality: Act0FeedbackQualityV1.correct,
                feedbackTitle: 'You win with a pair of aces.',
                feedbackReason:
                    'Your ace and the shared ace make the winning pair. The king, jack, and seven complete your best five.',
              ),
            ],
          ),
          showdown: true,
        ),
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.review,
      ),
      Act0LessonTaskV1(
        taskId: 'your_first_hand_action_trail',
        title: 'Action history',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1WithDistractorV1(
          _act0W01NewFirstHandStackContextV1(
            _act0FirstHandAkRunnerV1(
              _actionTrailRunner,
              history: true,
            ).copyWith(
              options: _act0AuthoredCorrectOptionAtV1(
                _actionTrailRunner.options,
                correctOptionId: 'bb_check',
                correctIndex: 1,
              ),
            ),
            earlierFlop: true,
          ),
          id: 'hj_limp',
          label: 'HJ calls 1 BB',
          reason:
              'HJ puts 1 BB in before the flop. Stopping at that call misses BB’s later check on A-7-2.',
        ),
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'your_first_hand_recap',
        title: 'Street recap',
        phase: Act0LessonPhaseV1.review,
        runner: _act0FirstHandAkRunnerV1(_streetOrderRecapRunner),
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.proveIt,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'what_poker_is_content',
    title: 'Stacks, all-in and the pot',
    subtitle: 'See which chips an all-in player can win.',
    state: Act0LessonStateV1.completed,
    phaseLabel: 'Poker',
    primaryCtaLabel: 'Replay',
    isSelectable: true,
    isLocked: false,
    rewardXp: 15,
    runner: _w1PotStackSeatedRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'what_poker_is_pot_stack',
        title: 'Pot and stack',
        phase: Act0LessonPhaseV1.theory,
        runner: _w1WithDistractorV1(
          _w1PotStackSeatedRunner.copyWith(
            caption: '',
            teachingSteps: const [
              Act0TeachingStepV1(
                title: 'BB also counts chips.',
                body:
                    r'BB also measures chips. In a $1/$2 game, $200 is 100 BB.',
              ),
              Act0TeachingStepV1(
                title: 'Pot and stack',
                body:
                    'The pot is in the middle. Your stack stays at your seat.',
              ),
            ],
          ),
          id: 'blind',
          label: 'Blind',
          reason:
              'The blind is one forced post. Once the 0.5 BB and 1 BB are in the middle, the pot names their combined total.',
        ),
        rewardXp: 4,
        stepKind: Act0LessonStepKindV1.learn,
        summary:
            'Separate chips in the middle from chips that still belong to a player.',
      ),
      Act0LessonTaskV1(
        taskId: 'what_poker_is_all_in_meaning',
        title: 'All-in meaning',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1SeatedAllInRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _w1SeatedAllInRunner.options,
            correctOptionId: 'all_remaining_committed',
            correctIndex: 1,
          ),
        ),
        rewardXp: 4,
        stepKind: Act0LessonStepKindV1.practice,
        summary:
            'See that all-in means all remaining chips are committed, not that the pot is automatically won.',
      ),
      Act0LessonTaskV1(
        taskId: 'what_poker_is_matched_chips_transfer',
        title: 'Matched chips',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1WithNumericLabelsV1(
          _w1SeatedMatchedChipsRunner.copyWith(
            options: _act0AuthoredCorrectOptionAtV1(
              _w1SeatedMatchedChipsRunner.options,
              correctOptionId: 'matched_amount_only',
              correctIndex: 2,
            ),
          ),
          const {
            'Only the chips CO matched against the 20 BB all-in': '20 BB',
            "The other player's whole 100 BB stack": '100 BB',
            'Nothing counts until all stacks are equal': '0 BB',
          },
        ),
        rewardXp: 4,
        stepKind: Act0LessonStepKindV1.proveIt,
        taskFamily: Act0TaskFamilyV1.transfer,
        summary:
            'A short stack can only win the chips that were actually matched in front of it.',
      ),
      Act0LessonTaskV1(
        taskId: 'what_poker_is_side_pot_eligibility',
        title: 'Which chips can you win?',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1SidePotEligibilityRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'what_poker_is_win_ways',
        title: 'How pots are won',
        phase: Act0LessonPhaseV1.drill,
        runner: _act0W1SeatObserverV1(
          _winWaysRunner.copyWith(
            caption: '',
            options: _act0AuthoredCorrectOptionAtV1(
              _winWaysRunner.options,
              correctOptionId: 'everyone_folds',
              correctIndex: 2,
            ),
          ),
          'utg',
        ),
        rewardXp: 4,
        stepKind: Act0LessonStepKindV1.practice,
        summary: 'See the two basic ways a hand ends: folds or showdown.',
      ),
      Act0LessonTaskV1(
        taskId: 'what_poker_is_showdown_win',
        title: 'Win at showdown',
        phase: Act0LessonPhaseV1.drill,
        runner: _showdownBestHandRunner.copyWith(
          table:
              _w1WithPocketPairV1(
                _act0W1MoveHeroV1(_showdownBestHandRunner.table, 'hj'),
                'K',
                firstSuit: 'c',
              ).copyWith(
                centerLabel: 'Your pair of kings beats CO’s pair of jacks',
              ),
          teachingSteps: const [
            Act0TeachingStepV1(
              title: 'Showdown compares hands.',
              body:
                  'You use K-K-A-J-7. CO uses J-J-A-K-7. Your kings beat CO’s jacks.',
              focusLabels: ['Best five', 'Kings beat jacks'],
            ),
          ],
          caption:
              'The last betting round is over and both players reveal their cards.',
          options: _act0AuthoredCorrectOptionAtV1(
            _showdownBestHandRunner.options,
            correctOptionId: 'best_hand',
            correctIndex: 2,
          ),
        ),
        rewardXp: 4,
        stepKind: Act0LessonStepKindV1.practice,
        summary: 'Pick which hand wins once the cards are all face up.',
      ),
      Act0LessonTaskV1(
        taskId: 'what_poker_is_live_win_transfer',
        title: 'Live win paths',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1LiveWinTransferRunner.copyWith(
          caption: 'Only the blinds have posted.',
          teachingSteps: const [],
          table: _act0W1MoveHeroV1(
            _w1LiveWinTransferRunner.table,
            'co',
          ).copyWith(centerLabel: 'Blinds and pot'),
        ),
        rewardXp: 4,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.transfer,
        summary:
            'Carry folds and showdown into one live table frame before strategy starts.',
      ),
      Act0LessonTaskV1(
        taskId: 'what_poker_is_review',
        title: 'Poker recap',
        phase: Act0LessonPhaseV1.review,
        runner: _w1WithNumericLabelsV1(
          _act0W1SeatObserverV1(
            _tableRecapRunner.copyWith(
              options: _act0AuthoredCorrectOptionAtV1(
                _tableRecapRunner.options,
                correctOptionId: 'pot_committed_chips',
                correctIndex: 2,
              ),
            ),
            'co',
          ),
          const {
            'The largest stack still held by a player': '100 BB',
            'Everyone else folds before showdown': '0 BB',
            'Chips already committed to the middle': '1.5 BB',
          },
          question: 'How many chips are in the pot after the blinds post?',
          reasons: const {
            'pot_committed_chips':
                'The two posts are 0.5 BB and 1 BB. The 1.5 BB total is in the pot and the stacks stay by each seat.',
            'largest_stack':
                'The 100 BB shown belongs to your stack. The 0.5 BB and 1 BB posts make the 1.5 BB pot.',
            'everyone_folds':
                'Chips are already in the middle before anyone decides to fold. The two posts make 1.5 BB.',
          },
        ),
        rewardXp: 3,
        stepKind: Act0LessonStepKindV1.proveIt,
        summary:
            'Close the lesson by separating hero, pot, folds, and showdown cleanly.',
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'showdown_winning',
    title: 'Rules checkpoint',
    subtitle: 'Read the hand and decide how the pot ends.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Showdown',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 30,
    runner: _whatYouCanDoRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'showdown_theory',
        title: 'Two ways to win',
        phase: Act0LessonPhaseV1.theory,
        runner: _w1WithDistractorV1(
          _showdownIntroRunner.copyWith(
            table: _w1WithPocketPairV1(
              _act0W1MoveHeroV1(_showdownIntroRunner.table, 'co'),
              '8',
            ),
            options: _act0AuthoredCorrectOptionAtV1(
              _showdownIntroRunner.options,
              correctOptionId: 'win_now',
              correctIndex: 1,
            ),
          ),
          id: 'another_round',
          label: 'Wait for the next card',
          reason:
              'When the other players fold on this flop, no one is left to contest the 5 BB pot. Waiting for another card delays an award that is already decided.',
        ),
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'showdown_foldout_drill',
        title: 'Everyone else folds',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1WithDistractorV1(
          _act0WithWrongFeedbackReasonsV1(
            _showdownRunner.copyWith(
              caption: 'The final player facing your bet folds.',
              question:
                  'What happens when the last other player folds before showing any cards?',
              options: _act0AuthoredCorrectOptionAtV1(
                _foldoutChoices,
                correctOptionId: 'win_now',
                correctIndex: 1,
              ),
              table: _act0W1MoveHeroV1(
                _showdownRunner.table.copyWith(
                  handContributions: _act0FoldoutPot,
                  heroCards: const [
                    Act0CardStateV1(rank: 'J', suit: 'h'),
                    Act0CardStateV1(rank: 'J', suit: 's'),
                  ],
                ),
                'co',
              ),
            ),
            const {
              'show_cards':
                  'With everyone else folded on Ah 7c 2d, you already win the 5 BB pot in CO with Jh Js without revealing your cards or giving away free information.',
            },
          ),
          id: 'return_pot',
          label: 'Return the whole pot to the players',
          reason:
              'The last opponent folded on A-7-2. The uncalled bet is returned to you, and you also win the 5 BB already in the middle.',
        ),
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'showdown_best_hand_drill',
        title: 'Best hand at showdown',
        phase: Act0LessonPhaseV1.drill,
        runner: _showdownKickerRunner.copyWith(
          question: 'Who wins, and which five cards play?',
          caption: 'The players show their cards on the river.',
          hint: 'Build one five-card hand for each player from the same board.',
          table: _act0CheckpointShowdownTableV1(
            heroCards: const [
              Act0CardStateV1(rank: '8', suit: 'd'),
              Act0CardStateV1(rank: '8', suit: 's'),
            ],
            otherCards: const [
              Act0CardStateV1(rank: 'K', suit: 'c'),
              Act0CardStateV1(rank: 'T', suit: 'c'),
            ],
            boardCards: const [
              Act0CardStateV1(rank: 'K', suit: 'd'),
              Act0CardStateV1(rank: 'Q', suit: 'd'),
              Act0CardStateV1(rank: '8', suit: 'h'),
              Act0CardStateV1(rank: '4', suit: 'c'),
              Act0CardStateV1(rank: '2', suit: 's'),
            ],
          ),
          options: const [
            Act0RunnerOptionV1(
              id: 'first_actor',
              label: 'Other player · K-K-Q-T-8',
              isCorrect: false,
              preferredLabel: 'You · 8-8-8-K-Q',
              quality: Act0FeedbackQualityV1.wrong,
              feedbackTitle: 'Compare three of a kind with a pair.',
              feedbackReason:
                  'The other player makes a pair of kings. Your three eights rank higher.',
            ),
            Act0RunnerOptionV1(
              id: 'hero_cards_only',
              label: 'You · 8-8-8-K-4',
              isCorrect: false,
              preferredLabel: 'You · 8-8-8-K-Q',
              quality: Act0FeedbackQualityV1.wrong,
              feedbackTitle: 'Use the better side card.',
              feedbackReason:
                  'You win with three eights. The queen plays instead of the four.',
            ),
            Act0RunnerOptionV1(
              id: 'best_hand',
              label: 'You · 8-8-8-K-Q',
              isCorrect: true,
              preferredLabel: 'You · 8-8-8-K-Q',
              quality: Act0FeedbackQualityV1.correct,
              feedbackTitle: 'Your three eights win.',
              feedbackReason:
                  'Your two eights and the eight on the board make three of a kind. The king and queen complete your best five.',
            ),
          ],
          teachingSteps: const <Act0TeachingStepV1>[],
        ),
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.compare,
      ),
      Act0LessonTaskV1(
        taskId: 'showdown_board_plays_drill',
        title: 'Board plays',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1WithDistractorV1(
          _boardPlaysRunner.copyWith(
            table: _w1WithPocketPairV1(
              _act0W1MoveHeroV1(_boardPlaysRunner.table, 'hj'),
              '9',
            ),
            options: _act0AuthoredCorrectOptionAtV1(
              _boardPlaysRunner.options,
              correctOptionId: 'tie',
              correctIndex: 1,
            ),
          ),
          id: 'private_cards_break_tie',
          label: 'The higher private card wins',
          reason:
              'Both shown hands use the same ace-high straight. A private card outside the best five cannot break the tie.',
        ),
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.fixMistakes,
        taskFamily: Act0TaskFamilyV1.compare,
      ),
      Act0LessonTaskV1(
        taskId: 'showdown_tie_drill',
        title: 'Tie the pot',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1WithNumericLabelsV1(
          _w1WithDistractorV1(
            _tiePotRunner.copyWith(
              table: _w1WithPocketPairV1(
                _act0W1MoveHeroV1(_tiePotRunner.table, 'utg'),
                '9',
              ),
              options: _act0AuthoredCorrectOptionAtV1(
                _tiePotRunner.options,
                correctOptionId: 'split',
                correctIndex: 1,
              ),
            ),
            id: 'replay_hand',
            label: 'Deal again to decide the winner',
            reason:
                'A-K-Q-J-T is already the best five for both shown players. A new deal has no effect on how the current pot is split.',
          ),
          const {
            'Split': '50% each',
            'First seat wins': '100% to the earlier seat',
            'Deal again to decide the winner': '0% until another deal',
          },
          question: 'If these are the tied winners, what share does each take?',
        ),
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.compare,
      ),
      Act0LessonTaskV1(
        taskId: 'showdown_review',
        title: 'Win recap',
        phase: Act0LessonPhaseV1.review,
        runner: _worldOneCheckpointRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.proveIt,
      ),
    ],
  ),
];

List<Act0LessonTaskV1> _retitledTasksV1(
  List<Act0LessonTaskV1> tasks, {
  required String lessonId,
  required String lessonTitle,
  required String lessonSubtitle,
  required String taskPrefix,
}) {
  return <Act0LessonTaskV1>[
    for (final task in tasks)
      Act0LessonTaskV1(
        taskId: '${taskPrefix}_${task.taskId}',
        title: task.title,
        phase: task.phase,
        runner: task.runner.copyWith(
          // Keep this admitted leaf identity for its exact premise receipt.
          // Canonical task ID and the route's selected lesson stay unchanged.
          lessonId:
              lessonId == 'turn_river_changes' &&
                  taskPrefix == 'turn_river_changes' &&
                  task.taskId == 'w5_turn_texture_shift_transfer' &&
                  task.runner.lessonId == 'w5_turn_texture_shift_transfer' &&
                  task.runner.feedbackSignalId == 'board_texture_change'
              ? task.runner.lessonId
              : lessonId,
          lessonTitle: lessonTitle,
          lessonSubtitle: lessonSubtitle,
        ),
        rewardXp: task.rewardXp,
        stepKind: task.stepKind,
        taskFamily: task.taskFamily,
        repairOnly: task.repairOnly,
        summary: task.summary,
        lockedSummary: task.lockedSummary,
      ),
  ];
}

List<Act0RunnerOptionV1> _act0AuthoredCorrectOptionAtV1(
  List<Act0RunnerOptionV1> options, {
  required String correctOptionId,
  required int correctIndex,
}) {
  final currentIndex = options.indexWhere(
    (option) => option.id == correctOptionId && option.isCorrect,
  );
  if (currentIndex == -1) {
    throw StateError('Missing correct option $correctOptionId.');
  }
  if (correctIndex < 0 || correctIndex >= options.length) {
    throw RangeError.range(correctIndex, 0, options.length - 1, 'correctIndex');
  }
  if (currentIndex == correctIndex) {
    return options;
  }

  final reordered = List<Act0RunnerOptionV1>.of(options);
  final correctOption = reordered.removeAt(currentIndex);
  reordered.insert(correctIndex, correctOption);
  return List<Act0RunnerOptionV1>.unmodifiable(reordered);
}

Act0RunnerStateV1 _act0WithWrongFeedbackReasonsV1(
  Act0RunnerStateV1 runner,
  Map<String, String> reasonsByOptionId, {
  Map<String, List<String>> repairLabelsByOptionId = const {},
}) {
  final matched = <String>{};
  final updatedOptions = <Act0RunnerOptionV1>[
    for (final option in runner.options)
      if (!option.isCorrect && reasonsByOptionId.containsKey(option.id)) ...[
        () {
          matched.add(option.id);
          return Act0RunnerOptionV1(
            id: option.id,
            label: option.label,
            amountLabel: option.amountLabel,
            seatId: option.seatId,
            isCorrect: option.isCorrect,
            preferredLabel: option.preferredLabel,
            betterAnswerLabel: option.betterAnswerLabel,
            quality: option.quality,
            feedbackTitle: option.feedbackTitle,
            feedbackReason: reasonsByOptionId[option.id]!,
            repairFocusSeatIds: option.repairFocusSeatIds,
            repairFocusCardIds: option.repairFocusCardIds,
            repairFocusLabels:
                repairLabelsByOptionId[option.id] ?? option.repairFocusLabels,
          );
        }(),
      ] else
        option,
  ];
  if (matched.length != reasonsByOptionId.length) {
    final missing = reasonsByOptionId.keys.where((k) => !matched.contains(k));
    throw StateError(
      'Missing wrong option(s) ${missing.join(', ')} in ${runner.lessonId}.',
    );
  }
  return runner.copyWith(
    options: List<Act0RunnerOptionV1>.unmodifiable(updatedOptions),
  );
}

Act0LessonCardV1 _lessonFromTasksV1({
  required String lessonId,
  required String title,
  required String subtitle,
  required String phaseLabel,
  required int rewardXp,
  required List<Act0LessonTaskV1> sourceTasks,
  List<Act0LessonTaskV1> extraDrills = const <Act0LessonTaskV1>[],
}) {
  final recapStartIndex = sourceTasks.lastIndexWhere(
    (task) => task.phase == Act0LessonPhaseV1.review,
  );
  final insertIndex = recapStartIndex == -1
      ? sourceTasks.length
      : recapStartIndex;
  final mergedSourceTasks = <Act0LessonTaskV1>[
    ...sourceTasks.take(insertIndex),
    ...extraDrills,
    ...sourceTasks.skip(insertIndex),
  ];
  final tasks = _retitledTasksV1(
    mergedSourceTasks,
    lessonId: lessonId,
    lessonTitle: title,
    lessonSubtitle: subtitle,
    taskPrefix: lessonId,
  );
  return Act0LessonCardV1(
    lessonId: lessonId,
    title: title,
    subtitle: subtitle,
    state: Act0LessonStateV1.locked,
    phaseLabel: phaseLabel,
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: rewardXp,
    runner: tasks.first.runner,
    tasks: tasks,
  );
}

final _handValuePositionLessons = <Act0LessonCardV1>[
  Act0LessonCardV1(
    lessonId: 'which_hand_wins',
    title: 'Which hand wins?',
    subtitle: 'Compare hands cleanly at showdown.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Showdown',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 30,
    runner: _world2ShowdownIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w2_showdown_intro',
        title: 'Showdown rule',
        phase: Act0LessonPhaseV1.theory,
        runner: _world2ShowdownIntroRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w2_best_hand_drill',
        title: 'Best hand',
        phase: Act0LessonPhaseV1.drill,
        runner: _showdownBestHandRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.compare,
      ),
      Act0LessonTaskV1(
        taskId: 'w2_kicker_drill',
        title: 'Kicker check',
        phase: Act0LessonPhaseV1.drill,
        runner: _showdownKickerRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.compare,
      ),
      Act0LessonTaskV1(
        taskId: 'w2_showdown_recap',
        title: 'Compare recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world2ShowdownRecapRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'best_five_cards',
    title: 'Best five cards',
    subtitle: 'Use only the five cards that count.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Best five',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 30,
    runner: _world2BestFiveIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w2_best_five_intro',
        title: 'Five cards count',
        phase: Act0LessonPhaseV1.theory,
        runner: _world2BestFiveIntroRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w2_best_five_count',
        title: 'Count the hand',
        phase: Act0LessonPhaseV1.drill,
        runner: _bestFiveCardsRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.counting,
      ),
      Act0LessonTaskV1(
        taskId: 'w2_best_five_showdown',
        title: 'Showdown five',
        phase: Act0LessonPhaseV1.drill,
        runner: _bestFiveShowdownRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.compare,
      ),
      Act0LessonTaskV1(
        taskId: 'w2_best_five_recap',
        title: 'Five-card recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world2BestFiveRecapRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'kicker_decides',
    title: 'Kicker decides',
    subtitle: 'Break ties when the main hand matches.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Kicker',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 30,
    runner: _world2KickerIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w2_kicker_intro',
        title: 'Side card rule',
        phase: Act0LessonPhaseV1.theory,
        runner: _world2KickerIntroRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w2_kicker_side_card',
        title: 'Find the kicker',
        phase: Act0LessonPhaseV1.drill,
        runner: _showdownKickerRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w2_same_board_tie',
        title: 'No kicker help',
        phase: Act0LessonPhaseV1.drill,
        runner: _boardPlaysRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w2_kicker_recap',
        title: 'Tie-break recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world2KickerRecapRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'board_plays',
    title: 'Board plays',
    subtitle: 'See when the board makes the same hand.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Board',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 30,
    runner: _world2BoardIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w2_board_intro',
        title: 'Shared board',
        phase: Act0LessonPhaseV1.theory,
        runner: _world2BoardIntroRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w2_board_same_five',
        title: 'Same five',
        phase: Act0LessonPhaseV1.drill,
        runner: _boardPlaysRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w2_board_split_pot',
        title: 'Split pot',
        phase: Act0LessonPhaseV1.drill,
        runner: _tiePotRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w2_board_recap',
        title: 'Board recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world2BoardRecapRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'position_changes_value',
    title: 'Position changes value',
    subtitle: 'Later seats see more before acting.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Position',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 30,
    runner: _world2PositionIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w2_position_intro',
        title: 'Info changes',
        phase: Act0LessonPhaseV1.theory,
        runner: _w3AddAlternative(
          _act0WithWrongFeedbackReasonsV1(_world2PositionIntroRunner, const {
            'utg':
                'UTG takes the first preflop turn and sees no earlier voluntary actions. BTN acts later than UTG and HJ.',
          }),
          question:
              'Which of UTG, HJ and BTN usually gets the most information before acting?',
          id: 'hj',
          label: 'HJ',
          reason:
              'HJ acts after UTG but before CO and BTN. Reading HJ as the latest seat misses decisions BTN can observe.',
          seat: 'hj',
        ),
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w2_late_position',
        title: 'Late seat',
        phase: Act0LessonPhaseV1.drill,
        runner: _w3AddAlternative(
          _act0WithWrongFeedbackReasonsV1(
            _latePositionRunner.copyWith(
              question:
                  'When UTG checks, which seat can respond after seeing that choice?',
              hint:
                  'Follow how the order moves from the blinds to the dealer marker.',
              options: _act0AuthoredCorrectOptionAtV1(
                _latePositionRunner.options,
                correctOptionId: 'btn',
                correctIndex: 1,
              ),
            ),
            const {
              'utg':
                  'UTG acts first preflop and sees no earlier voluntary actions. BTN sees the most earlier actions among these seats.',
            },
          ),
          question:
              'Which of these seats sees the most actions before its first turn preflop?',
          id: 'co',
          label: 'CO',
          reason:
              'CO sees UTG and HJ act, but BTN can also see CO act before taking its first turn.',
          seat: 'co',
        ),
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w2_early_position',
        title: 'Early seat',
        phase: Act0LessonPhaseV1.drill,
        runner: _w3AddAlternative(
          _act0NeutralSeatAssessmentPreservingTeachingV1(
            _earlyLatePositionRunner,
          ),
          question: 'Which seat acts first on this preflop pass?',
          id: 'co',
          label: 'CO',
          reason:
              'CO is third on the first preflop pass, after UTG and HJ. UTG starts the pass after the blinds.',
          seat: 'co',
        ),
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w2_position_recap',
        title: 'Position recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world2PositionRecapRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'who_has_initiative',
    title: 'Who has initiative?',
    subtitle: 'Track who made the last aggressive action.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Initiative',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 35,
    runner: _world2InitiativeIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w2_initiative_intro',
        title: 'Last aggressor',
        phase: Act0LessonPhaseV1.theory,
        runner: _world2InitiativeIntroRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w2_initiative_find',
        title: 'Find initiative',
        phase: Act0LessonPhaseV1.drill,
        runner: _world2InitiativeDrillRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w2_initiative_active',
        title: 'Active seat',
        phase: Act0LessonPhaseV1.drill,
        runner: _world2InitiativeActiveRunner,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w2_initiative_recap',
        title: 'Initiative recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world2InitiativeRecapRunner,
        rewardXp: 12,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'hand_value_checkpoint',
    title: 'Hand value checkpoint',
    subtitle: 'Mix showdown, position, and initiative.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Checkpoint',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 35,
    runner: _world2CheckpointIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w2_checkpoint_intro',
        title: 'Bridge setup',
        phase: Act0LessonPhaseV1.theory,
        runner: _world2CheckpointIntroRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w2_checkpoint_showdown',
        title: 'Compare hand',
        phase: Act0LessonPhaseV1.drill,
        runner: _showdownBestHandRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w2_checkpoint_position',
        title: 'Use position',
        phase: Act0LessonPhaseV1.drill,
        runner: _earlyLatePositionRunner,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w2_checkpoint_review',
        title: 'Bridge recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world2CheckpointRunner,
        rewardXp: 12,
        stepKind: Act0LessonStepKindV1.proveIt,
      ),
    ],
  ),
];

final _preflopBasicsLessons = <Act0LessonCardV1>[
  Act0LessonCardV1(
    lessonId: 'preflop_hand_buckets',
    title: 'Hand buckets',
    subtitle: 'Sort hands before choosing an action.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Buckets',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 30,
    runner: _world3BucketsIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w3_buckets_intro',
        title: 'Four buckets',
        phase: Act0LessonPhaseV1.theory,
        runner: _world3BucketsIntroRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w3_premium_bucket',
        title: 'Premium hand',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3PremiumBucketRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w3_trash_bucket',
        title: 'Trash hand',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3TrashBucketRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w3_buckets_recap',
        title: 'Bucket recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world3BucketsRecapRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'first_in_open',
    title: 'First-in open',
    subtitle: 'When nobody entered, raising starts the pot.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Open',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 30,
    runner: _world3FirstInIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w3_first_in_intro',
        title: 'Unopened pot',
        phase: Act0LessonPhaseV1.theory,
        runner: _world3FirstInIntroRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w3_button_open',
        title: 'Button open',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3ButtonOpenRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w3_early_fold',
        title: 'Early fold',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3EarlyFoldRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w3_first_in_recap',
        title: 'Open recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world3FirstInRecapRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'facing_an_open',
    title: 'Facing an open',
    subtitle: 'A raise before you changes the first decision.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Facing open',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 30,
    runner: _world3FacingOpenIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w3_facing_open_intro',
        title: 'Someone opened',
        phase: Act0LessonPhaseV1.theory,
        runner: _world3FacingOpenIntroRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w3_playable_call',
        title: 'Playable call',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3PlayableCallRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w3_weak_facing_fold',
        title: 'Weak facing fold',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3WeakFacingFoldRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w3_facing_open_recap',
        title: 'Facing-open recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world3FacingOpenRecapRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'position_preflop',
    title: 'Position preflop',
    subtitle: 'Position can improve a hand, not rescue every hand.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Position',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 30,
    runner: _world3PositionIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w3_position_intro',
        title: 'Seat changes context',
        phase: Act0LessonPhaseV1.theory,
        runner: _world3PositionIntroRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w3_late_position_open',
        title: 'Late open',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3LateOpenRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w3_position_not_free_pass',
        title: 'Not a free pass',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3PositionDisciplineRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w3_position_recap',
        title: 'Position recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world3PositionRecapRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'same_hand_different_frame',
    title: 'Same hand, different frame',
    subtitle: 'One hand can open, call, or fold by context.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Frame',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 35,
    runner: _world3SameHandIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w3_same_hand_intro',
        title: 'Context first',
        phase: Act0LessonPhaseV1.theory,
        runner: _w3AddAlternative(
          _world3SameHandIntroRunner,
          id: 'seat_and_action',
          label: 'Your seat and earlier bets',
          reason:
              'The 1.5 BB pot shows only posted blinds. Your two cards still determine whether you can open from your seat.',
        ),
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w3_same_hand_open',
        title: 'Open frame',
        phase: Act0LessonPhaseV1.drill,
        runner: _act0WithWrongFeedbackReasonsV1(_world3CutoffOpenRunner, const {
          'call':
              'Limping 1 BB from CO with AJo into the 1.5 BB pot instead of raising to 2.5 BB loses fold pressure and invites BTN and the blinds in cheaply.',
          'fold':
              'Folding AJo from CO into an unopened 1.5 BB pot gives up a profitable late-position open with only BTN and the blinds left behind you.',
        }),
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w3_same_hand_call',
        title: 'Players behind',
        phase: Act0LessonPhaseV1.drill,
        runner: _w3AddAlternative(
          _world3CutoffCallRunner.copyWith(
            options: _act0AuthoredCorrectOptionAtV1(
              _world3CutoffCallRunner.options,
              correctOptionId: 'players_behind',
              correctIndex: 1,
            ),
          ),
          id: 'opener_and_button',
          label: 'HJ and BTN',
          reason:
              'HJ has already raised. Picking it leaves SB and BB out of the three players still to act after CO.',
        ),
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w3_same_hand_recap',
        title: 'Frame recap',
        phase: Act0LessonPhaseV1.review,
        runner: _w3AddAlternative(
          _world3SameHandRecapRunner.copyWith(
            options: _act0AuthoredCorrectOptionAtV1(
              _world3SameHandRecapRunner.options,
              correctOptionId: 'framework',
              correctIndex: 1,
            ),
          ),
          id: 'seat_blind_only',
          label: 'The seat and posted blinds',
          reason:
              'The 1.5 BB blinds are the start of the pot. You also need to know your cards and whether anyone raised before your turn.',
        ),
        rewardXp: 12,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'dominated_hand_warning',
    title: 'Dominated hand warning',
    subtitle: 'Familiar hands can still be trouble.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Discipline',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 35,
    runner: _world3DominatedIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w3_dominated_intro',
        title: 'Trouble hands',
        phase: Act0LessonPhaseV1.theory,
        runner: _world3DominatedIntroRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w3_dominated_fold',
        title: 'Fold trouble',
        phase: Act0LessonPhaseV1.drill,
        runner: _act0WeakHandAfterRaiseContrastV1(
          _world3DominatedFoldRunner,
          handName: 'ace-six offsuit',
          cards: const [
            Act0CardStateV1(rank: 'A', suit: 's'),
            Act0CardStateV1(rank: '6', suit: 'd', tone: Act0CardToneV1.red),
          ],
          correctIndex: 1,
        ),
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w3_strong_continue',
        title: 'Strong continue',
        phase: Act0LessonPhaseV1.drill,
        runner: _act0WithWrongFeedbackReasonsV1(
          _world2StrongContinueRunner.copyWith(
            options: _act0AuthoredCorrectOptionAtV1(
              _world2StrongContinueRunner.options,
              correctOptionId: 'call',
              correctIndex: 1,
            ),
          ),
          const {
            'fold':
                'HJ opened to 2.5 BB with 1.5 BB in the pot. The pot is 4 BB after the open. Folding KQo on BTN gives up the in-position call in the Sharky starting chart.',
          },
        ),
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w3_dominated_recap',
        title: 'Discipline recap',
        phase: Act0LessonPhaseV1.review,
        runner: _act0WeakHandAfterRaiseContrastV1(
          _world3DominatedRecapRunner,
          handName: 'ace-five offsuit',
          cards: const [
            Act0CardStateV1(rank: 'A', suit: 's'),
            Act0CardStateV1(rank: '5', suit: 'd', tone: Act0CardToneV1.red),
          ],
          correctIndex: 0,
        ),
        rewardXp: 12,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'preflop_checkpoint',
    title: 'Preflop checkpoint',
    subtitle: 'Bucket, position, frame, then action.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Checkpoint',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 40,
    runner: _world3CheckpointIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w3_checkpoint_intro',
        title: 'Three checks',
        phase: Act0LessonPhaseV1.theory,
        runner: _world3CheckpointIntroRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w3_checkpoint_open',
        title: 'Open decision',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3ButtonOpenRunner,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w3_checkpoint_fold',
        title: 'Fold decision',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3EarlyFoldRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w3_checkpoint_review',
        title: 'Preflop recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world3CheckpointRunner,
        rewardXp: 15,
        stepKind: Act0LessonStepKindV1.proveIt,
      ),
    ],
  ),
];

final _w2FirstInIntroRunner =
    _w2UnopenedSeat(_world3BucketsIntroRunner, 'co', 'Ks Ts').copyWith(
      teachingSteps: [
        const Act0TeachingStepV1(
          title: 'You are first in.',
          body: 'Enter first voluntarily. Open means the first raise.',
        ),
        ..._world3BucketsIntroRunner.teachingSteps,
      ],
    );

final _handDisciplineLessons = <Act0LessonCardV1>[
  Act0LessonCardV1(
    lessonId: 'hand_discipline_buckets',
    title: 'Hand buckets',
    subtitle: 'Sort hands before putting chips in.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Buckets',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 30,
    runner: _w2FirstInIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'hand_discipline_buckets_intro',
        title: 'Four buckets',
        phase: Act0LessonPhaseV1.theory,
        runner: _w2FirstInIntroRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'hand_discipline_buckets_premium',
        title: 'Premium hand',
        phase: Act0LessonPhaseV1.drill,
        runner: _act0WithWrongFeedbackReasonsV1(
          _w2UnopenedSeat(_world3PremiumBucketRunner, 'utg', 'As Ah'),
          const {
            "medium":
                "AA belongs to Premium. Folding AA from UTG under a Medium rule gives up an open and a chance to win both blinds.",
            "strong":
                "Both rows can open from UTG here. Against a prior raise, putting AA in Strong gives up the Premium reraise.",
          },
        ),
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'hand_discipline_buckets_strong',
        title: 'Strong hand',
        phase: Act0LessonPhaseV1.drill,
        runner: _act0WithWrongFeedbackReasonsV1(
          _w2UnopenedSeat(_w1StrongBucketRunner, 'hj', 'Jh Js').copyWith(
            options: _act0AuthoredCorrectOptionAtV1(
              _w1StrongBucketRunner.options,
              correctOptionId: 'strong',
              correctIndex: 1,
            ),
          ),
          const {
            "premium":
                "JJ on HJ is Strong. If UTG opens to 2.5 BB, treating JJ as Premium risks 7.5 BB on a reraise outside the narrow chart.",
            "medium":
                "JJ is Strong and HJ can open it. Applying the CO–BTN Medium row would give up an HJ open and the chance to win 1.5 BB.",
          },
        ),
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'hand_discipline_buckets_medium',
        title: 'Medium hand',
        phase: Act0LessonPhaseV1.drill,
        runner: _act0WithWrongFeedbackReasonsV1(
          _w2UnopenedSeat(_w1MediumBucketRunner, 'co', 'Kd Tc').copyWith(
            options: _act0AuthoredCorrectOptionAtV1(
              _w1MediumBucketRunner.options,
              correctOptionId: 'medium',
              correctIndex: 2,
            ),
          ),
          const {
            "strong":
                "KTo can open first in from this CO seat. Treating it as Strong from UTG risks 2.5 BB on an open the chart folds.",
            "trash":
                "KTo is in the second Medium row. Folding it first in from CO gives up a chart open and the chance to win both blinds.",
          },
        ),
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'hand_discipline_buckets_trash',
        title: 'Weak hand',
        phase: Act0LessonPhaseV1.drill,
        runner: _act0WithWrongFeedbackReasonsV1(
          _world3TrashBucketRunner.copyWith(
            options: _act0AuthoredCorrectOptionAtV1(
              _world3TrashBucketRunner.options,
              correctOptionId: 'trash',
              correctIndex: 1,
            ),
          ),
          const {
            "strong":
                "UTG has J8o with five players still to act. Putting in 2.5 BB would risk chips with a Weak hand outside the chart.",
            "medium":
                "J8o is outside both Medium rows. Treating it as Medium at CO risks 2.5 BB on an open the chart folds.",
          },
        ),
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'hand_discipline_buckets_borderline',
        title: 'Borderline hand',
        phase: Act0LessonPhaseV1.drill,
        runner: _act0WithWrongFeedbackReasonsV1(
          _w2UnopenedSeat(_w2BorderlineBucketRunner, 'co', 'Qs Js').copyWith(
            options: _act0AuthoredCorrectOptionAtV1(
              _w2BorderlineBucketRunner.options,
              correctOptionId: 'medium',
              correctIndex: 1,
            ),
          ),
          const {
            "strong":
                "QJs can open here from CO. Treating it as Strong from HJ risks 2.5 BB with a hand the chart folds there.",
            "trash":
                "QJs is Medium and CO is in its opening row. Calling it Weak gives up a first-in raise and the chance to win 1.5 BB.",
          },
        ),
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'hand_discipline_buckets_recap',
        title: 'Bucket recap',
        phase: Act0LessonPhaseV1.review,
        runner: _act0WithWrongFeedbackReasonsV1(
          _w2ReasonDecision(
            _w2UnopenedSeat(_world3BucketsRecapRunner, 'co', 'Ks Ts'),
            question:
                'Which pair of facts should you check together before a first-in raise?',
            correctTitle: 'Use the hand group and seat.',
            choices: const [
              (
                id: 'suit_only',
                label: 'The suits and your chip color',
                reason:
                    'KTs shares a suit, but knowing that alone can put 1 BB in with a hand your seat should fold.',
              ),
              (
                id: 'bucket_and_seat',
                label: 'Your hand group and your seat',
                reason:
                    'KTs is Medium and CO is in the CO–BTN opening row. The same hand from HJ falls outside that row.',
              ),
              (
                id: 'blinds_only',
                label: 'The blind amounts and dealer puck',
                reason:
                    'The 1.5 BB in blinds cannot tell you whether KTs can open. Using the bank alone can cost a raise from the wrong seat.',
              ),
            ],
            correct: 1,
          ),
          const {
            "blinds_only":
                "The 1.5 BB in blinds is the same from CO and HJ. Ignoring the seat can cost a 2.5 BB raise from HJ, where the chart folds KTs.",
          },
        ),
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  _lessonFromTasksV1(
    lessonId: 'fold_discipline',
    title: 'Fold discipline',
    subtitle: 'Learn that folding weak hands saves chips.',
    phaseLabel: 'Discipline',
    rewardXp: 35,
    sourceTasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'discipline_intro',
        title: 'Fold is a tool',
        phase: Act0LessonPhaseV1.theory,
        runner: _act0WithWrongFeedbackReasonsV1(
          _act0W01ExplicitFoldMechanicalContextV1(_foldActionRunner).copyWith(
            question:
                'If you choose to exit this hand, which action does that?',
            options: _foldMeaningChoices,
            teachingSteps: [
              const Act0TeachingStepV1(
                title: 'Before anyone raises',
                body:
                    'An open is the first raise before the flop. The opener is the player who makes that raise.',
              ),
              const Act0TeachingStepV1(
                title: 'Calling before a raise',
                body:
                    'Limping means calling the big blind before anyone has raised.',
              ),
              ..._foldActionRunner.teachingSteps,
            ],
          ),
          const {
            'call':
                'Calling HJ’s 2 BB keeps your queens in the hand and costs chips. Fold to leave with your remaining stack.',
            'raise':
                'Raising to 6 BB against HJ\'s 2 BB bet in the 7 BB pot risks even more chips with Qh Qs on Ah 7c 2d instead of folding out.',
          },
        ),
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'early_fold',
        title: 'Early weak hand',
        phase: Act0LessonPhaseV1.drill,
        runner: _w2WithDistractor(
          _act0WithWrongFeedbackReasonsV1(
            _world3EarlyFoldRunner.copyWith(
              options: _act0AuthoredCorrectOptionAtV1(
                _world3EarlyFoldRunner.options,
                correctOptionId: 'fold',
                correctIndex: 1,
              ),
            ),
            const {
              'raise':
                  'Raising J8o from UTG into the 1.5 BB pot risks chips from an early seat with five players still to act behind a weak offsuit hand.',
            },
          ),
          id: 'call',
          label: 'Call',
          reason:
              'Limping J8o from UTG pays 1 BB while five players remain free to raise. Folding saves that blind.',
        ),
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'facing_fold',
        title: 'Facing pressure',
        phase: Act0LessonPhaseV1.drill,
        runner: _w2ReasonDecision(
          _world3WeakFacingFoldRunner,
          question: 'Why does folding save chips here?',
          correctTitle: 'J8o still folds versus a CO open.',
          choices: const [
            (
              id: 'call',
              label: 'Position makes this jack strong enough to call',
              reason:
                  'Position does not fix J8o. Calling costs 2.5 BB and can cost more when CO has the better jack.',
            ),
            (
              id: 'fold',
              label: 'CO already raised and J8o is weak',
              reason:
                  'J8o is Weak in the chart. Folding from BTN against CO keeps the 2.5 BB call in your stack.',
            ),
            (
              id: 'raise_for_pot',
              label: 'The existing pot makes a reraise safe',
              reason:
                  'The 4 BB pot does not protect J8o. A reraise risks extra chips against CO, who can continue with stronger hands.',
            ),
          ],
          correct: 1,
        ),
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'discipline_stack_protect',
        title: 'Protect stack',
        phase: Act0LessonPhaseV1.drill,
        runner: _w2WithDistractor(
          _act0WeakAcePriceContrastV1(3),
          id: 'raise',
          label: 'Reraise to 9 BB',
          reason:
              'Reraising A7o to 9 BB against CO risks more with a kicker that can lose even after pairing your ace. Folding saves the whole wager.',
        ),
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'fold_recap',
        title: 'Discipline recap',
        phase: Act0LessonPhaseV1.review,
        runner: _act0WeakHandAfterRaiseContrastV1(
          _world3DominatedRecapRunner,
          handName: 'ace-four offsuit',
          cards: const [
            Act0CardStateV1(rank: 'A', suit: 's'),
            Act0CardStateV1(rank: '4', suit: 'd'),
          ],
          correctIndex: 0,
          cutoffFacingHijack: true,
        ),
        rewardXp: 12,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  _lessonFromTasksV1(
    lessonId: 'weak_ace_warning',
    title: 'Weak ace warning',
    subtitle: 'Familiar hands can still be dominated.',
    phaseLabel: 'Trouble hands',
    rewardXp: 35,
    sourceTasks: [
      for (final task in _preflopBasicsLessons[5].taskList)
        _w2WeakAceTask(task),
    ],
    extraDrills: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'weak_ace_pressure_fold',
        title: 'Pressure fold',
        phase: Act0LessonPhaseV1.drill,
        runner: _act0WeakHandAfterRaiseContrastV1(
          _world3WeakFacingFoldPressureRunner,
          handName: 'king-seven offsuit',
          cards: const [
            Act0CardStateV1(rank: 'K', suit: 's'),
            Act0CardStateV1(rank: '7', suit: 'd', tone: Act0CardToneV1.red),
          ],
          correctIndex: 0,
          cutoffFacingHijack: true,
        ),
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'weak_ace_kicker_compare',
        title: 'A7 vs KQ spot',
        phase: Act0LessonPhaseV1.drill,
        runner: _act0WithWrongFeedbackReasonsV1(
          _w2WithDistractor(
            _world2KqoContrastRunner.copyWith(
              options: _act0AuthoredCorrectOptionAtV1(
                _world2KqoContrastRunner.options,
                correctOptionId: 'less_dominated',
                correctIndex: 1,
              ),
            ),
            id: 'ace_and_king_equal',
            label: 'Both hands lose for the same reason',
            reason:
                'A7o shares an ace with AK. KQo shares a king with AK or a queen with AQ. Which paired rank leaves you with the weaker side card depends on the matchup.',
          ),
          const {
            "two_big_cards_auto":
                "KQo on BTN shares a king with AK, which wins on a king-high board if the other cards do not change the best hand. Treating KQ as safe can cost extra chips after the 2.5 BB call.",
          },
        ),
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
    ],
  ),
  _lessonFromTasksV1(
    lessonId: 'continue_or_let_go',
    title: 'Continue or let go',
    subtitle: 'Separate strong continues from weak hopes.',
    phaseLabel: 'Continue',
    rewardXp: 35,
    sourceTasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'continue_intro',
        title: 'Strong enough',
        phase: Act0LessonPhaseV1.theory,
        runner: _w2UnopenedSeat(_world3BucketsIntroRunner, 'co', 'Ks Ts').copyWith(
          caption: 'Check whether a player raised before your turn.',
          hint: 'Check whether anyone raised before you and which seat raised.',
          question: 'What changed when the player before you raised?',
          options: const <Act0RunnerOptionV1>[],
          teachingSteps: const [
            Act0TeachingStepV1(
              title: 'Look for the first raise.',
              body:
                  'Without a raise, use the opening part of the chart. After a raise, read its source and use the response for that seat and your hand.',
            ),
          ],
        ),
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'premium_continue',
        title: 'Premium continue',
        phase: Act0LessonPhaseV1.drill,
        runner: _act0WithWrongFeedbackReasonsV1(
          _w2WithDistractor(
            _world3PremiumBucketRunner.copyWith(
              caption: 'You hold ace-king suited.',
              table: _day7PreflopV1(
                'utg',
                'As Ks',
                showTurn: true,
              ).copyWith(centerLabel: ''),
              question: 'Which bucket does ace-king suited fit?',
              options: const <Act0RunnerOptionV1>[
                Act0RunnerOptionV1(
                  id: 'premium',
                  label: 'Premium',
                  isCorrect: true,
                  preferredLabel: 'Premium',
                  quality: Act0FeedbackQualityV1.correct,
                  feedbackTitle: 'Check the suited ace-king row.',
                  feedbackReason:
                      'AK suited from UTG is Premium. That group can raise even from the first seat.',
                ),
                Act0RunnerOptionV1(
                  id: 'medium',
                  label: 'Medium',
                  isCorrect: false,
                  preferredLabel: 'Premium',
                  quality: Act0FeedbackQualityV1.wrong,
                  feedbackTitle: 'Check the top of the chart.',
                  feedbackReason:
                      'AK suited from UTG qualifies for a first-in raise. Treating it as Medium can make you fold and miss a chance to build the pot.',
                ),
              ],
              teachingSteps: const <Act0TeachingStepV1>[],
            ),
            id: 'strong',
            label: 'Strong',
            reason:
                'AK suited from UTG has the same opening seats as Strong, but this chart puts it in Premium. Using the Strong row would miss its reraise in the narrow model.',
          ),
          const {
            "medium":
                "AKs is Premium, so it can raise first from UTG. Applying the later Medium row gives up the open and the chance to win 1.5 BB.",
            "strong":
                "AKs opens here from UTG under either label. The cost appears when facing an open: calling it Strong gives up the Premium reraise.",
          },
        ),
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'medium_open',
        title: 'Medium hand opens',
        phase: Act0LessonPhaseV1.drill,
        runner: _act0WithWrongFeedbackReasonsV1(
          _w1MediumOpenRunner.copyWith(
            options: _act0AuthoredCorrectOptionAtV1(
              _w1MediumOpenRunner.options,
              correctOptionId: 'raise',
              correctIndex: 1,
            ),
          ),
          const {
            'fold':
                'Folding KQo from BTN passes up the chart’s first-in raise and the chance to collect the blinds if SB and BB both fold.',
            'call':
                'Limping 1 BB on BTN with KQo into the 1.5 BB pot instead of raising to 2.5 BB gives up fold pressure and lets the blinds see a cheap flop.',
          },
        ),
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'weak_let_go',
        title: 'Weak let go',
        phase: Act0LessonPhaseV1.drill,
        runner: _act0WithWrongFeedbackReasonsV1(
          _w2WithDistractor(
            _act0WeakHandAfterRaiseContrastV1(
              _world3WeakFacingFoldRunner,
              handName: 'jack-seven offsuit',
              cards: const [
                Act0CardStateV1(rank: 'J', suit: 's'),
                Act0CardStateV1(rank: '7', suit: 'd'),
              ],
              correctIndex: 0,
            ),
            id: 'raise',
            label: 'Reraise to 7.5 BB',
            reason:
                'A 7.5 BB reraise from BTN with J7o risks three times the price of calling a CO open with a hand outside the chart.',
          ),
          const {
            "raise":
                "J7o is Weak and CO already opened. A BTN reraise risks 7.5 BB with a hand this chart folds to one open.",
          },
        ),
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'medium_call_or_fold',
        title: 'Medium facing open',
        phase: Act0LessonPhaseV1.drill,
        runner: _w2WithDistractor(
          _act0WithWrongFeedbackReasonsV1(
            _world3PlayableCallRunner.copyWith(
              options: _act0AuthoredCorrectOptionAtV1(
                _world3PlayableCallRunner.options,
                correctOptionId: 'call',
                correctIndex: 1,
              ),
            ),
            const {
              'fold':
                  'CO opened to 2.5 BB with 1.5 BB in the pot. The pot is 4 BB after the open. Folding KQo on BTN gives up the in-position call in the Sharky starting chart.',
            },
          ),
          id: 'raise',
          label: 'Reraise to 7.5 BB',
          reason:
              'KQo on BTN is a call against CO in this chart. A 7.5 BB reraise risks 5 BB extra without a Premium hand.',
        ),
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'continue_recap',
        title: 'Continue recap',
        phase: Act0LessonPhaseV1.review,
        runner: _w2WithDistractor(
          _act0WithWrongFeedbackReasonsV1(
            _world3FacingOpenRecapRunner.copyWith(
              options: _act0AuthoredCorrectOptionAtV1(
                _world3FacingOpenRecapRunner.options,
                correctOptionId: 'call',
                correctIndex: 1,
              ),
            ),
            const {
              'fold':
                  'Folding KQo on BTN for 2.5 BB gives up the chart’s in-position call against CO.',
            },
          ),
          id: 'raise',
          label: 'Reraise to 7.5 BB',
          reason:
              'The 4 BB pot includes CO’s 2.5 BB open. Reraising KQo from BTN puts 5 BB more at risk than the chart call.',
        ),
        rewardXp: 12,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  _lessonFromTasksV1(
    lessonId: _w2ThreeBetLessonId,
    title: 'The narrow 3-bet',
    subtitle: 'Choose when to reraise, call, or fold against one open.',
    phaseLabel: 'Reraise',
    rewardXp: 45,
    sourceTasks: [
      Act0LessonTaskV1(
        taskId: 'intro',
        title: 'One open ahead',
        phase: Act0LessonPhaseV1.theory,
        runner: _w2ThreeBetIntroRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'premium',
        title: 'Facing an HJ open',
        phase: Act0LessonPhaseV1.drill,
        runner: _act0WithWrongFeedbackReasonsV1(
          _w2ThreeBetDecision(
            hero: 'co',
            opener: 'hj',
            cards: 'Ad Ac',
            correctId: 'raise',
            raiseReason:
                "Raise AA to 7.5 BB because HJ can call with high pairs and strong aces that trail you. Calling 2.5 BB leaves the pot smaller against those hands.",
            callReason:
                'Calling 2.5 BB with AA on CO leaves the pot small and '
                'misses a chance to charge weaker hands for a flop.',
            foldReason:
                'Folding AA on CO surrenders the strongest starting '
                'hand to HJ and gives up the chance to win the 4 BB already in.',
          ),
          const {
            "fold":
                "CO holds AA facing an HJ open. Folding gives up a chance to win the 4 BB already in the pot with the highest starting pair.",
          },
        ),
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'medium',
        title: 'Facing a CO open',
        phase: Act0LessonPhaseV1.drill,
        runner: _act0WithWrongFeedbackReasonsV1(
          _w2ReasonDecision(
            _w2ThreeBetIntroRunner.copyWith(
              phase: Act0LessonPhaseV1.drill,
              caption: 'CO opened to 2.5 BB. No one has called.',
              table: _day7PreflopV1(
                'btn',
                'Qc Jc',
                opener: 'co',
                showTurn: true,
              ),
            ),
            question: 'Which table fact supports matching the 2.5 BB open?',
            correctTitle: 'QJs can call in position.',
            choices: const [
              (
                id: 'premium',
                label: 'QJs is in the top group',
                reason:
                    'QJs is Medium. Treating it as Premium on BTN can '
                    'put 5 BB more than a call at risk against CO.',
              ),
              (
                id: 'call',
                label: 'QJs is Medium and you act after CO',
                reason:
                    'The chart calls one CO open with QJs from BTN. Paying '
                    '2.5 BB keeps the pot smaller while you act after CO.',
              ),
              (
                id: 'unopened',
                label: 'Nobody has raised yet',
                reason:
                    'CO already raised to 2.5 BB. Treating this as an '
                    'unopened pot can turn a call into a more expensive reraise.',
              ),
            ],
            correct: 1,
          ),
          const {
            "unopened":
                "CO already put in 2.5 BB. Treating it as unopened can turn BTN’s QJs call into a reraise that risks 5 BB more.",
          },
        ),
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'strong',
        title: 'Tens facing an HJ open',
        phase: Act0LessonPhaseV1.drill,
        runner: _w2ThreeBetDecision(
          hero: 'co',
          opener: 'hj',
          cards: 'Th Tc',
          correctId: 'call',
          raiseReason:
              'TT is Strong on CO. Reraising to 7.5 BB risks '
              '5 BB more than the call against HJ.',
          callReason:
              "Call 2.5 BB with TT because HJ also opens AQ, AJ and KQ, which your tens lead. HJ can call a reraise with higher pairs, so raising can build a bigger pot when you are behind.",
          foldReason:
              'Folding TT on CO gives up a call with a Strong '
              'pair against one 2.5 BB open from HJ.',
        ),
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'fold',
        title: 'A high card facing a raise',
        phase: Act0LessonPhaseV1.review,
        runner: _act0WithWrongFeedbackReasonsV1(
          _w2ThreeBetDecision(
            hero: 'co',
            opener: 'hj',
            cards: 'Ad 5c',
            correctId: 'fold',
            openBb: 3,
            raiseReason:
                'Reraising to 9 BB risks the full wager with a weak ace that can lose even when it pairs. A fold saves those chips.',
            callReason:
                'Calling 3 BB with A5o on CO can lose more when an ace '
                'pairs both you and a stronger ace in HJ.',
            foldReason:
                "Fold A5o because HJ can raise stronger aces. Calling costs 3 BB and a paired ace can still lose to a higher kicker.",
          ),
          const {
            "call":
                "Calling costs 3 BB with A5o and you can still lose when you pair the ace. A fold preserves those chips.",
          },
        ),
        rewardXp: 12,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  // Apply lesson: combines bucket + seat + frame in a realistic table scenario.
  Act0LessonCardV1(
    lessonId: 'hand_discipline_apply',
    title: 'Discipline at the table',
    subtitle: 'Bucket, seat, and frame — then the action is simple.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Apply',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 40,
    runner: _w2UnopenedSeat(_w1DisciplineApplyIntroRunner, 'co', 'Ks Ts'),
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'apply_intro',
        title: 'Three-step habit',
        phase: Act0LessonPhaseV1.theory,
        runner: _w2UnopenedSeat(_w1DisciplineApplyIntroRunner, 'co', 'Ks Ts'),
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'apply_utg_fold',
        title: 'UTG, trash hand',
        phase: Act0LessonPhaseV1.drill,
        runner: _w2WithDistractor(
          _act0WithWrongFeedbackReasonsV1(
            _w1DisciplineApplyEarlyFoldRunner,
            const {
              'raise':
                  'Raising 84o from UTG risks chips in a 1.5 BB pot while five players can still act behind you.',
            },
          ),
          id: 'call',
          label: 'Call',
          reason:
              'Limping from UTG costs 1 BB with 84o and leaves five players the chance to raise. Folding keeps that chip.',
        ),
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.fixMistakes,
      ),
      Act0LessonTaskV1(
        taskId: 'apply_btn_open',
        title: 'BTN, medium hand',
        phase: Act0LessonPhaseV1.drill,
        runner: _act0WithWrongFeedbackReasonsV1(
          _w1DisciplineApplyLateOpenRunner,
          const {
            'fold':
                "Folding AJo on BTN gives up a raise that can win the blind pot or get paid by a weaker ace.",
            'call':
                'Limping 1 BB on BTN with AJo into the 1.5 BB pot instead of raising to 3 BB gives up fold pressure and invites SB and BB in cheaply.',
          },
        ),
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.fixMistakes,
      ),
      Act0LessonTaskV1(
        taskId: 'apply_hj_decision',
        title: 'HJ, medium hand',
        phase: Act0LessonPhaseV1.drill,
        runner: _act0WithWrongFeedbackReasonsV1(
          _w1DisciplineApplyHjMediumRunner,
          const {
            'fold':
                'Folding KQo from HJ into an unopened 1.5 BB pot is too tight and gives up a profitable first-in open from middle position.',
            'call':
                'Limping 1 BB from HJ with KQo into the 1.5 BB pot instead of raising to 2.5 BB loses fold pressure and lets CO, BTN, and the blinds enter cheaply.',
          },
        ),
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.fixMistakes,
      ),
      Act0LessonTaskV1(
        taskId: 'apply_recap',
        title: 'Discipline holds',
        phase: Act0LessonPhaseV1.review,
        runner: _act0WithWrongFeedbackReasonsV1(
          _w2ReasonDecision(
            _act0WeakHandAfterRaiseContrastV1(
              _world3DominatedRecapRunner,
              handName: 'ace-three offsuit',
              cards: const [
                Act0CardStateV1(rank: 'A', suit: 's'),
                Act0CardStateV1(rank: '3', suit: 'd'),
              ],
              correctIndex: 0,
              cutoffFacingHijack: true,
            ),
            question: 'Which fact makes matching this raise risky?',
            correctTitle: 'A better ace can outkick A3o.',
            choices: const [
              (
                id: 'fold',
                label: 'A3o can lose to a higher ace when both pair',
                reason:
                    'A3o from CO can be dominated by HJ. Folding saves the 2.5 BB call and avoids paying more with a worse pair.',
              ),
              (
                id: 'call',
                label: 'The ace makes your kicker unimportant',
                reason:
                    'If both players pair an ace, HJ can win with a higher kicker. A call puts 2.5 BB at risk with A3o.',
              ),
              (
                id: 'seat_guarantee',
                label: 'Sitting in CO makes your kicker play higher',
                reason:
                    'Position can give information, but cannot change A3o. A 2.5 BB call still pays in with a weak kicker.',
              ),
            ],
            correct: 0,
          ),
          const {
            "seat_guarantee":
                "CO’s seat cannot improve the three kicker. Calling pays 2.5 BB even though HJ can win with a higher ace when both pair.",
          },
        ),
        rewardXp: 16,
        stepKind: Act0LessonStepKindV1.proveIt,
      ),
    ],
  ),
  _lessonFromTasksV1(
    lessonId: 'discipline_checkpoint',
    title: 'Hand discipline checkpoint',
    subtitle: 'Name the bucket, then protect your stack.',
    phaseLabel: 'Checkpoint',
    rewardXp: 40,
    sourceTasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'checkpoint_intro',
        title: 'Bucket first',
        phase: Act0LessonPhaseV1.theory,
        runner: _w2UnopenedSeat(_world3BucketsRecapRunner, 'co', 'Ks Ts').copyWith(
          question:
              'When the two cards stay the same, what else does the chart ask you to check?',
          options: _world3BucketsRecapRunner.options,
          teachingSteps: const [
            Act0TeachingStepV1(
              title: 'Read the cards with the seat.',
              body:
                  'Before the first raise, look up the two cards and then check which seats can raise them.',
            ),
          ],
        ),
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'checkpoint_premium',
        title: 'Premium hand',
        phase: Act0LessonPhaseV1.drill,
        runner: _act0WithWrongFeedbackReasonsV1(
          _w2WithDistractor(
            _world3PremiumBucketRunner.copyWith(
              caption: 'You hold a pair of kings.',
              table: _day7PreflopV1(
                'hj',
                'Ks Kh',
                showTurn: true,
              ).copyWith(centerLabel: ''),
              question: 'Which bucket does this pair fit?',
              options: const <Act0RunnerOptionV1>[
                Act0RunnerOptionV1(
                  id: 'premium',
                  label: 'Premium',
                  isCorrect: true,
                  preferredLabel: 'Premium',
                  quality: Act0FeedbackQualityV1.correct,
                  feedbackTitle: 'Use the highest pairs row.',
                  feedbackReason:
                      'A pair of kings is in the Premium group of the chart.',
                ),
                Act0RunnerOptionV1(
                  id: 'medium',
                  label: 'Medium',
                  isCorrect: false,
                  preferredLabel: 'Premium',
                  quality: Act0FeedbackQualityV1.wrong,
                  feedbackTitle: 'Check the top of the chart.',
                  feedbackReason:
                      'The Medium group has lower pairs. The Premium group includes kings.',
                ),
              ],
              teachingSteps: const <Act0TeachingStepV1>[],
            ),
            id: 'strong',
            label: 'Strong',
            reason:
                'KK from HJ is Premium. Dropping it to Strong would miss a chance to reraise with a stronger hand against one open in position.',
          ),
          const {
            "medium":
                "KK on HJ can open first because it is Premium. Using a CO–BTN Medium row gives up the HJ open and a chance at both blinds.",
            "strong":
                "KK can open from HJ either way here. The Strong row gives up a Premium reraise if UTG has already raised.",
          },
        ),
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'checkpoint_fold',
        title: 'Disciplined fold',
        phase: Act0LessonPhaseV1.drill,
        runner: _w2WithDistractor(
          _act0WeakAcePriceContrastV1(4),
          id: 'raise',
          label: 'Reraise to 12 BB',
          reason:
              'A7o from BTN would put in 12 BB against a 4 BB CO open, risking more with a kicker that loses to better aces.',
        ),
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'checkpoint_borderline_continue',
        title: 'Borderline continue',
        phase: Act0LessonPhaseV1.drill,
        runner: _w2WithDistractor(
          _act0WithWrongFeedbackReasonsV1(_world2BorderlineContinueRunner, const {
            'fold':
                'CO opened to 2.5 BB with 1.5 BB in the pot. The pot is 4 BB after the open. Folding QJs on BTN gives up the call the Sharky starting chart allows against one CO open.',
          }),
          id: 'raise',
          label: 'Reraise to 7.5 BB',
          reason:
              'QJs on BTN can match CO for 2.5 BB. Putting in 7.5 BB instead gives CO the chance to call your larger bet with better hands.',
        ),
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'checkpoint_table_discipline',
        title: 'Real-table discipline read',
        phase: Act0LessonPhaseV1.drill,
        runner: _act0WithWrongFeedbackReasonsV1(
          _act0WithWrongFeedbackReasonsV1(_w2DisciplineTableNoticeRunner, const {
            'looks_fun_open':
                'Raising J4o from HJ into the 1.5 BB pot risks chips with a weak offsuit hand while CO, BTN, and both blinds still act behind you.',
            'maybe_limp':
                'Limping 1 BB from HJ with J4o into the 1.5 BB pot leaks chips with a weak offsuit hand instead of folding and saving your stack.',
          }),
          const {
            "maybe_limp":
                "HJ holds J4o, outside the chart. Limping pays 1 BB and leaves CO, BTN and the blinds free to raise.",
          },
        ),
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'checkpoint_review',
        title: 'Discipline recap',
        phase: Act0LessonPhaseV1.review,
        runner: _act0WithWrongFeedbackReasonsV1(
          _w2WithDistractor(
            _w1DisciplineCheckpointRunner.copyWith(
              options: _act0AuthoredCorrectOptionAtV1(
                _w1DisciplineCheckpointRunner.options,
                correctOptionId: 'seat_context',
                correctIndex: 1,
              ),
            ),
            id: 'fix_size',
            label: 'Choose a size first',
            reason:
                'A7o faces a CO raise. Picking a size before checking the seat and prior action can lead to paying 2.5 BB with a weak ace.',
          ),
          const {
            "auto_action":
                "BTN sees a CO raise and holds A7o. Choosing by bucket alone gives up the chance to read that raise and can cost a 2.5 BB call.",
          },
        ),
        rewardXp: 15,
        stepKind: Act0LessonStepKindV1.proveIt,
      ),
    ],
  ),
];

final _positionThinkingLessons = <Act0LessonCardV1>[
  Act0LessonCardV1(
    lessonId: 'position_six_seats',
    title: 'The 6 positions',
    subtitle: 'Recognize UTG, HJ, CO, BTN, SB, and BB.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Seats',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 36,
    runner: _w3OrientationFromSeat(_w3SixSeatsIntroRunner, 'hj'),
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'position_six_seats_positions_theory',
        title: 'Six seat labels',
        phase: Act0LessonPhaseV1.theory,
        runner: _w3OrientationFromSeat(_w3SixSeatsIntroRunner, 'hj'),
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'position_six_seats_positions_utg',
        title: 'Find UTG',
        phase: Act0LessonPhaseV1.drill,
        runner: _act0WithWrongFeedbackReasonsV1(
          _w3AddAlternative(
            _w3SeatIdUtgRunner.copyWith(
              options: _act0AuthoredCorrectOptionAtV1(
                _w3SeatIdUtgRunner.options,
                correctOptionId: 'utg',
                correctIndex: 1,
              ),
            ),
            id: 'bb',
            label: 'BB',
            reason:
                'BB posted 1 BB. When you pick BB, you miss the next seat clockwise that opens the first round.',
            seat: 'bb',
          ).copyWith(teachingSteps: const []),
          const {
            "hj":
                "HJ is one seat clockwise after UTG. UTG sits immediately clockwise after BB and acts first preflop here.",
            "bb":
                "BB is the seat that posted the full blind. UTG sits immediately clockwise after BB and takes the first voluntary action.",
          },
        ),
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'position_six_seats_hj_co_contrast',
        title: 'HJ or CO',
        phase: Act0LessonPhaseV1.drill,
        runner: _act0WithWrongFeedbackReasonsV1(
          _w3AddAlternative(
            _w3OrientationFromSeat(
              _w3SeatIdHjRunner.copyWith(
                options: _act0AuthoredCorrectOptionAtV1(
                  _w3SeatIdHjRunner.options,
                  correctOptionId: 'hj',
                  correctIndex: 1,
                ),
              ),
              'utg',
            ),
            id: 'utg',
            label: 'UTG',
            reason:
                'UTG acts first. Picking it skips the next seat clockwise, which is HJ.',
            seat: 'utg',
          ).copyWith(teachingSteps: const []),
          const {
            "co": "CO comes one seat after HJ. HJ sits between UTG and CO.",
            "utg":
                "UTG sits between BB and HJ. HJ is the seat immediately after UTG.",
          },
        ),
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'position_six_seats_positions_cutoff',
        title: 'Find CO',
        phase: Act0LessonPhaseV1.drill,
        runner: _act0WithWrongFeedbackReasonsV1(
          _w3AddAlternative(
            _w3OrientationFromSeat(_w3SeatIdCoRunner, 'hj'),
            id: 'btn',
            label: 'BTN',
            reason:
                'BTN has the dealer marker. The 1.5 BB pot is unopened, and CO acts one seat before BTN.',
            seat: 'btn',
          ).copyWith(teachingSteps: const []),
          const {
            "hj":
                "HJ comes immediately before CO. CO is the seat between HJ and BTN.",
            "btn":
                "BTN holds the dealer marker. CO is the seat immediately before it in the preflop order.",
          },
        ),
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'position_six_seats_position_order_reason',
        title: 'Read three seats in order',
        phase: Act0LessonPhaseV1.drill,
        runner: _act0WithWrongFeedbackReasonsV1(_w3SeatOrderReasonRunner, const {
          "cutoff_first":
              "HJ comes immediately after UTG. The correct sequence continues through CO and BTN.",
          "button_before_cutoff":
              "CO follows HJ and acts before BTN on the first preflop pass. This list swaps CO and BTN.",
        }),
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'position_six_seats_positions_button',
        title: 'Find BTN',
        phase: Act0LessonPhaseV1.drill,
        runner: _act0WithWrongFeedbackReasonsV1(
          _w3AddAlternative(
            _w3SeatIdBtnRunner,
            id: 'sb',
            label: 'SB',
            reason:
                'SB posted 0.5 BB and sits after the marker. Picking SB misses the seat that holds the marker.',
            seat: 'sb',
          ).copyWith(teachingSteps: const []),
          const {
            "co":
                "CO sits immediately before the dealer marker. The seat with the marker is BTN.",
            "sb":
                "SB is one seat clockwise after BTN. The dealer marker belongs to BTN.",
          },
        ),
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'position_six_seats_sb_recognition',
        title: 'Find SB',
        phase: Act0LessonPhaseV1.drill,
        runner: _act0WithWrongFeedbackReasonsV1(
          _w3AddAlternative(
            _w3OrientationFromSeat(
              _w3SeatIdSbRunner.copyWith(
                options: _act0AuthoredCorrectOptionAtV1(
                  _w3SeatIdSbRunner.options,
                  correctOptionId: 'sb',
                  correctIndex: 1,
                ),
              ),
              'utg',
            ),
            id: 'btn',
            label: 'BTN',
            reason:
                'The dealer marker is on BTN. The 0.5 BB post is one seat clockwise from it.',
            seat: 'btn',
          ).copyWith(teachingSteps: const []),
          const {
            "bb":
                "BB has posted 1 BB. Mixing it up with SB makes you count the wrong 0.5 BB post.",
            "btn":
                "BTN has the dealer marker. Its neighbor SB posts the 0.5 BB small blind in this setup.",
          },
        ),
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'position_six_seats_bb_recognition',
        title: 'Find BB',
        phase: Act0LessonPhaseV1.drill,
        runner: _act0WithWrongFeedbackReasonsV1(
          _w3AddAlternative(
            _w3OrientationFromSeat(
              _w3SeatIdBbRunner.copyWith(
                options: _act0AuthoredCorrectOptionAtV1(
                  _w3SeatIdBbRunner.options,
                  correctOptionId: 'bb',
                  correctIndex: 1,
                ),
              ),
              'hj',
            ),
            id: 'utg',
            label: 'UTG',
            reason:
                'UTG starts the first betting round. Picking it skips the seat that already posted the full 1 BB.',
            seat: 'utg',
          ).copyWith(teachingSteps: const []),
          const {
            "sb":
                "SB put in 0.5 BB. Treating it as BB leaves another 0.5 BB missing from your count.",
            "utg":
                "UTG sits immediately after BB. The seat that posted the full 1 BB is BB.",
          },
        ),
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'position_six_seats_position_repair_seat_id_btn',
        repairOnly: true,
        title: 'Repair BTN seat',
        phase: Act0LessonPhaseV1.drill,
        runner: _w3AddAlternative(
          _w3SeatIdBtnRepairRunner,
          id: 'bb',
          label: 'BB',
          reason:
              'BB posted the full blind. The dealer marker sits two seats before BB on this six-player table.',
          seat: 'bb',
        ),
        rewardXp: 4,
        stepKind: Act0LessonStepKindV1.fixMistakes,
      ),
      Act0LessonTaskV1(
        taskId: 'position_six_seats_position_repair_seat_id_utg',
        repairOnly: true,
        title: 'Repair UTG seat',
        phase: Act0LessonPhaseV1.drill,
        runner: _w3AddAlternative(
          _w3SeatIdUtgRepairRunner.copyWith(
            options: _act0AuthoredCorrectOptionAtV1(
              _w3SeatIdUtgRepairRunner.options,
              correctOptionId: 'utg',
              correctIndex: 1,
            ),
          ),
          id: 'sb',
          label: 'SB',
          reason:
              'SB sits before BB. Picking SB goes back a seat when the question asks who comes after BB.',
          seat: 'sb',
        ),
        rewardXp: 4,
        stepKind: Act0LessonStepKindV1.fixMistakes,
      ),
      Act0LessonTaskV1(
        taskId: 'position_six_seats_positions_review',
        title: 'Six-seat recap',
        phase: Act0LessonPhaseV1.review,
        runner: _act0WithWrongFeedbackReasonsV1(
          _w3AddAlternative(
            _w3OrientationFromSeat(
              _w3SixSeatsRecapRunner.copyWith(
                teachingSteps: const <Act0TeachingStepV1>[],
                options: _act0AuthoredCorrectOptionAtV1(
                  _w3SixSeatsRecapRunner.options,
                  correctOptionId: 'six_seats',
                  correctIndex: 1,
                ),
              ),
              'co',
            ),
            id: 'blinds_and_button_only',
            label: 'UTG, MP, CO, BTN, SB, BB',
            reason:
                'This table uses HJ between UTG and CO. Looking for MP can make you misread the seat before CO.',
          ),
          const {
            "only_blinds":
                "BTN, SB and BB are on the table, but this list leaves out UTG, HJ and CO.",
            "blinds_and_button_only":
                "This list keeps CO but labels the seat before it MP. On this table that seat is HJ.",
          },
        ),
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  _lessonFromTasksV1(
    lessonId: 'button_advantage',
    title: 'Button advantage',
    subtitle: 'The Button often acts last and sees more.',
    phaseLabel: 'Button',
    rewardXp: 41,
    sourceTasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'button_intro',
        title: 'Best seat',
        phase: Act0LessonPhaseV1.theory,
        runner: _w3AddAlternative(
          _w3OrientationFromSeat(
            _world2PositionIntroRunner.copyWith(
              question:
                  'Which seat gets to see CO act on the first pass after the flop?',
              options: _laterSeatChoices,
            ),
            'hj',
          ),
          id: 'co',
          label: 'CO',
          reason:
              'After the flop, CO takes its first turn before BTN. BTN is the seat that can observe CO’s first action.',
          seat: 'co',
        ),
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'find_button',
        title: 'Tap BTN',
        phase: Act0LessonPhaseV1.drill,
        runner: _act0WithWrongFeedbackReasonsV1(
          _w3AddAlternative(
            _act0WithWrongFeedbackReasonsV1(
              _buttonSeatRunner.copyWith(
                caption: 'You are at CO in this hand.',
                table: _act0ReassignHeroSeatV1(
                  _buttonSeatRunner.table,
                  heroSeatId: 'co',
                  activeSeatId: '',
                ),
                question:
                    'Which seat has the dealer marker when you sit one seat earlier?',
                options: _dealerMarkerChoices,
              ),
              const {
                'co':
                    'Sitting at CO in this 1.5 BB pot puts you one seat earlier than BTN, so tapping CO misses which seat actually holds the dealer marker.',
              },
            ),
            id: 'sb',
            label: 'SB',
            reason:
                'SB posted 0.5 BB next to the marker. Reading the small blind as the Button puts you one seat too late.',
            seat: 'sb',
          ),
          const {
            "co":
                "CO sits one seat before BTN clockwise. The round dealer marker identifies BTN itself.",
            "sb":
                "SB is immediately clockwise after the seat with the dealer marker. The marker is on BTN.",
          },
        ),
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'button_open',
        title: 'BTN first-in open',
        phase: Act0LessonPhaseV1.drill,
        runner: _act0WithWrongFeedbackReasonsV1(_world3ButtonOpenRunner, const {
          'fold':
              "Folding KTs on BTN gives up the blinds you could collect if both players fold to a raise.",
          'call':
              'Limping 1 BB on BTN with KTs into the 1.5 BB pot instead of raising to 3 BB loses fold pressure and lets SB and BB see a cheap flop.',
        }),
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'button_last',
        title: 'Acts last',
        phase: Act0LessonPhaseV1.drill,
        runner: _w3AddAlternative(
          _act0WithWrongFeedbackReasonsV1(_postflopButtonActorRunner, const {
            'utg':
                'On this 5 BB flop (Ah 7c 2d), UTG acts before BTN rather than last, so tapping UTG misreads who gets to see everyone else act first.',
          }),
          id: 'bb',
          label: 'BB',
          reason:
              'BB acts earlier on this A-7-2 flop. If you stop at BB, you miss the Button decision that ends the first pass.',
          seat: 'bb',
        ),
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'button_vs_cutoff',
        title: 'BTN vs CO',
        phase: Act0LessonPhaseV1.drill,
        runner: _act0WithWrongFeedbackReasonsV1(
          _w3AddAlternative(
            _w3OrientationFromSeat(
              _w3LateSeatContrastRunner.copyWith(
                options: _act0AuthoredCorrectOptionAtV1(
                  _w3LateSeatContrastRunner.options,
                  correctOptionId: 'btn',
                  correctIndex: 1,
                ),
              ),
              'hj',
            ),
            id: 'hj',
            label: 'HJ',
            reason:
                'HJ acts before both CO and BTN on the first preflop pass. BTN is the latest of these three seats.',
            seat: 'hj',
          ),
          const {
            "co":
                "CO acts immediately before BTN on the first preflop pass. BTN therefore acts later than CO.",
          },
        ),
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'button_order_reason',
        title: 'Why acting last helps',
        phase: Act0LessonPhaseV1.drill,
        runner: _w3ButtonOrderReasonRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'button_recap',
        title: 'Button recap',
        phase: Act0LessonPhaseV1.review,
        runner: _w3OrientationFromSeat(
          _world2PositionRecapRunner.copyWith(
            caption:
                'All six players put in 1 BB before the flop. The first betting round on the flop is about to start.',
            hint: 'Compare the live-seat order after the flop.',
            question:
                'Which of these seats acts last on the flop when the dealer is still in the hand?',
            options: _positionsRecapRunner.options,
            table: _world2PositionRecapRunner.table.copyWith(
              streetLabel: 'Flop',
              boardCards: _flopA72Cards,
              potLabel: 'Pot 6 BB',
              handContributions: const Act0HandContributionsV1(
                throughStreet: PokerStreet.flop,
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
                    .5,
                  ),
                ],
              ),
              centerLabel: 'First pass on the flop',
              seats: [
                for (final seat in _world2PositionRecapRunner.table.seats)
                  _act0CopySeatStateV1(seat, clearCommitment: true),
              ],
              actionTrail: const [],
              activeSeatId: '',
              selectableSeatIds: const ['utg', 'btn', 'bb'],
            ),
          ),
          'co',
        ),
        rewardXp: 12,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
    extraDrills: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'position_repair_btn_last_postflop',
        repairOnly: true,
        title: 'Who acts last on the flop?',
        phase: Act0LessonPhaseV1.drill,
        runner: _w3AddAlternative(
          _w3BtnLastPostflopRepairRunner.copyWith(
            table: _w3ButtonOrderTable(
              _w3BtnLastPostflopRepairRunner.table,
              'Jd Js',
            ),
          ),
          id: 'bb',
          label: 'BB',
          reason:
              'BB acts before BTN on A-7-2. BTN acts after the other live seats on the first flop pass.',
          seat: 'bb',
        ),
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.fixMistakes,
      ),
    ],
  ),
  _lessonFromTasksV1(
    lessonId: 'early_vs_late',
    title: 'Early vs late',
    subtitle: 'Early seats decide with less information.',
    phaseLabel: 'Seat value',
    rewardXp: 35,
    sourceTasks: _handValuePositionLessons[4].taskList,
    extraDrills: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'early_pressure_choice',
        title: 'Early pressure',
        phase: Act0LessonPhaseV1.drill,
        runner: _act0WithWrongFeedbackReasonsV1(
          _w3AddAlternative(
            _w3EarlySeatPressureRunner.copyWith(
              options: _act0AuthoredCorrectOptionAtV1(
                _w3EarlySeatPressureRunner.options,
                correctOptionId: 'more_players_behind',
                correctIndex: 1,
              ),
            ),
            id: 'position_returns_chips',
            label: 'The blinds return UTG’s raise if they call',
            reason:
                'UTG opens before five players. A call from either blind keeps UTG’s chips in the pot and can lead to more bets.',
          ),
          const {
            "same_as_btn":
                "Opening from UTG with five players behind risks an open into more possible calls and raises than opening from BTN.",
            "position_returns_chips":
                "Opening from UTG costs chips immediately. A better seat cannot return that raise after another player acts.",
          },
        ),
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'position_repair_utg_players_behind',
        repairOnly: true,
        title: 'Repair UTG pressure',
        phase: Act0LessonPhaseV1.drill,
        runner: _w3AddAlternative(
          _w3UtgPlayersBehindRepairRunner.copyWith(
            options: _act0AuthoredCorrectOptionAtV1(
              _w3UtgPlayersBehindRepairRunner.options,
              correctOptionId: 'five_players_behind',
              correctIndex: 1,
            ),
          ),
          id: 'only_hj',
          label: 'The next turn belongs to HJ, then the round ends',
          reason:
              'HJ is next, but CO, BTN and both blinds also have a turn. Counting one player can make a weak UTG raise look safer.',
        ),
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.fixMistakes,
      ),
      Act0LessonTaskV1(
        taskId: 'late_info_choice',
        title: 'Late info edge',
        phase: Act0LessonPhaseV1.drill,
        runner: _act0WithWrongFeedbackReasonsV1(
          _w3AddAlternative(
            _w3LateInfoEdgeRunner,
            id: 'smaller_blinds',
            label: "CO gets to act again before BTN",
            reason:
                'CO has already seen two folds, but BTN and both blinds still act. CO does not get a second turn before BTN.',
          ),
          const {
            "always_last":
                "CO has BTN, SB and BB still to act preflop. CO has fewer players behind than UTG, but it does not close this pass.",
            "smaller_blinds":
                "CO and UTG post no blind. After seeing two folds, CO acts once before BTN, SB and BB.",
          },
        ),
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
    ],
  ),
  _lessonFromTasksV1(
    lessonId: 'same_hand_different_seat',
    title: 'Same hand, different seat',
    subtitle: 'A seat can change how comfortable a hand is.',
    phaseLabel: 'Context',
    rewardXp: 35,
    sourceTasks: _preflopBasicsLessons[4].taskList,
    extraDrills: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'same_hand_early_fold',
        title: 'Early seat fold',
        phase: Act0LessonPhaseV1.drill,
        runner: _act0WithWrongFeedbackReasonsV1(
          _w3AddAlternative(
            _world3PositionDisciplineRunner,
            id: 'call',
            label: 'Call',
            reason:
                "Limping ATo from UTG costs 1 BB while five players can still raise. Folding saves that chip.",
          ),
          const {
            "raise":
                "Raising ATo from UTG costs 2.5 BB with five players ready to respond. The Sharky starting chart folds here to save that wager.",
          },
        ),
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'same_hand_late_open',
        title: 'Late seat open',
        phase: Act0LessonPhaseV1.drill,
        runner: _act0WithWrongFeedbackReasonsV1(
          _w3AddAlternative(
            _world3LateOpenRunner.copyWith(
              options: _act0AuthoredCorrectOptionAtV1(
                _world3LateOpenRunner.options,
                correctOptionId: 'raise',
                correctIndex: 1,
              ),
            ),
            id: 'fold',
            label: 'Fold',
            reason:
                'ATo on BTN is in the HJ–BTN opening row. Folding gives up a chance to contest the 1.5 BB in blinds.',
          ),
          const {
            "call":
                "A 1 BB limp from BTN lets both blinds see a cheap flop and gives up the fold pressure of a 2.5 BB raise.",
            "fold":
                "Folding from BTN gives up a chance to win the 1.5 BB in blinds with only SB and BB left to act.",
          },
        ),
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'position_repair_same_hand_different_seat',
        repairOnly: true,
        title: 'Repair same hand, different seat',
        phase: Act0LessonPhaseV1.drill,
        runner: _w3SameHandDifferentSeatRepairRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.fixMistakes,
      ),
    ],
  ),
  // Apply lesson: position in action — same hand, different seat, strategic decision.
  Act0LessonCardV1(
    lessonId: 'position_apply',
    title: 'Position at the table',
    subtitle: 'Seat shapes the decision before anything else.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Apply',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 40,
    runner: _w3PositionApplyIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'position_apply_intro',
        title: 'Position shapes action',
        phase: Act0LessonPhaseV1.theory,
        runner: _w3AddAlternative(
          _act0WithWrongFeedbackReasonsV1(_w3PositionApplyIntroRunner, const {
            'utg':
                'UTG has five players left to act behind it in this 1.5 BB preflop pot, so picking UTG overlooks how much more crowded early position is than BTN.',
          }),
          id: 'co',
          label: 'CO',
          reason:
              'CO has BTN, SB and BB behind it on the first preflop pass. BTN has only SB and BB behind it.',
          seat: 'co',
        ),
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'position_apply_btn_open',
        title: "BTN: open playable hand",
        phase: Act0LessonPhaseV1.drill,
        runner: _act0WithWrongFeedbackReasonsV1(
          _world3ButtonOpenQtsRunner.copyWith(
            options: _act0AuthoredCorrectOptionAtV1(
              _world3ButtonOpenQtsRunner.options,
              correctOptionId: 'raise',
              correctIndex: 1,
            ),
          ),
          const {
            'fold':
                "Folding QTs on BTN misses the 1.5 BB you could collect if both blinds fold to a raise.",
            'call':
                'Limping 1 BB on BTN with QTs into the 1.5 BB pot instead of raising to 3 BB gives up fold pressure and lets the blinds see a cheap flop.',
          },
        ),
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'position_apply_late_open',
        title: 'Late: open or limp?',
        phase: Act0LessonPhaseV1.drill,
        runner: _act0WithWrongFeedbackReasonsV1(
          _w3AddAlternative(
            _world3LateOpenRunner.copyWith(
              caption: 'Folded to BTN with KTo.',
              hint: 'Find your hand and seat in the chart.',
              table: _world3LateOpenRunner.table.copyWith(
                heroCards: const <Act0CardStateV1>[
                  Act0CardStateV1(rank: 'K', suit: 'd'),
                  Act0CardStateV1(rank: 'T', suit: 'c'),
                ],
                centerLabel: 'No one has raised',
              ),
              options: _additionalLateOpenChoices,
              teachingSteps: const <Act0TeachingStepV1>[],
            ),
            id: 'fold',
            label: 'Fold',
            reason:
                'KTo on BTN belongs to the CO–BTN opening row. Folding gives up a chance to contest the 1.5 BB in blinds.',
          ),
          const {
            "call":
                "Calling 1 BB from BTN lets the blinds see a cheap flop and gives up the pressure of a 3 BB open.",
            "fold":
                "Folding KTo on BTN misses the blinds you could collect if both players fold to a raise.",
          },
        ),
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'position_apply_early_fold',
        title: 'Early: AQo first in',
        phase: Act0LessonPhaseV1.drill,
        runner: _w3AddAlternative(
          _world3PositionDisciplineRunner.copyWith(
            caption: 'You are first to act with AQo.',
            question:
                'With AQo under the gun, what does the Sharky starting chart say to do?',
            hint: 'Find the first seat that opens this hand in the chart.',
            table: _world3PositionDisciplineRunner.table.copyWith(
              centerLabel: 'Before the first raise',
              heroCards: const [
                Act0CardStateV1(rank: 'A', suit: 'd', tone: Act0CardToneV1.red),
                Act0CardStateV1(rank: 'Q', suit: 'c'),
              ],
            ),
            options: const [
              Act0RunnerOptionV1(
                id: 'fold',
                label: 'Fold',
                isCorrect: true,
                preferredLabel: 'Fold',
                quality: Act0FeedbackQualityV1.correct,
                feedbackTitle: 'UTG is before HJ.',
                feedbackReason:
                    "The Sharky starting chart folds AQo at UTG because five players can still raise or call with strong hands. Limping risks 1 BB before they act.",
              ),
              Act0RunnerOptionV1(
                id: 'raise',
                label: 'Raise',
                isCorrect: false,
                preferredLabel: 'Fold',
                quality: Act0FeedbackQualityV1.wrong,
                feedbackTitle: 'Find the first seat for AQo.',
                feedbackReason:
                    'Raising AQo from UTG into the 1.5 BB pot risks chips with five players still to act behind you, before HJ, where the Sharky starting chart first opens AQo.',
              ),
            ],
            teachingSteps: const <Act0TeachingStepV1>[
              Act0TeachingStepV1(
                title: 'Check the seat and the hand.',
                body:
                    'Find where you sit, then read across the chart for your hand.',
              ),
            ],
          ),
          id: 'call',
          label: 'Call',
          reason:
              'Calling AQo costs 1 BB from UTG, with five players behind who can raise and make you pay more.',
        ),
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.fixMistakes,
      ),
      Act0LessonTaskV1(
        taskId: 'position_apply_hj_fold',
        title: 'HJ: discipline hold',
        phase: Act0LessonPhaseV1.drill,
        runner: _w3AddAlternative(
          _act0WithWrongFeedbackReasonsV1(
            _world3HijDisciplineRunner.copyWith(
              table: _world3HijDisciplineRunner.table.copyWith(
                highlightedSeatIds: const ['hj'],
              ),
              options: _act0AuthoredCorrectOptionAtV1(
                _world3HijDisciplineRunner.options,
                correctOptionId: 'fold',
                correctIndex: 1,
              ),
            ),
            const {
              'raise':
                  'Raising KTo from HJ into the 1.5 BB pot risks chips with CO, BTN, and both blinds still behind you, one seat too early for KTo in the Sharky starting chart.',
            },
          ),
          id: 'call',
          label: 'Call',
          reason:
              "Limping KTo from HJ costs 1 BB before CO, BTN and the blinds decide. Folding keeps that chip.",
        ),
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.fixMistakes,
      ),
      Act0LessonTaskV1(
        taskId: 'position_apply_recap',
        title: 'Position apply recap',
        phase: Act0LessonPhaseV1.review,
        runner: _act0WithWrongFeedbackReasonsV1(
          _w3PositionApplyRecapRunner,
          const {
            "off_chart":
                "The chart opens AJo from HJ, CO and BTN. This choice leaves out BTN, your seat in this hand.",
          },
        ),
        rewardXp: 16,
        stepKind: Act0LessonStepKindV1.proveIt,
      ),
    ],
  ),
  _lessonFromTasksV1(
    lessonId: 'w3_play_from_blinds',
    title: 'Play from the blinds',
    subtitle: 'Your posted blind changes the price of calling.',
    phaseLabel: 'Blinds',
    rewardXp: 80,
    sourceTasks: [
      Act0LessonTaskV1(
        taskId: 'intro',
        title: 'Two blinds, different choices',
        phase: Act0LessonPhaseV1.theory,
        runner: _w3BlindDefenseIntroRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'small_blind_fold',
        title: 'Weak hand in SB',
        phase: Act0LessonPhaseV1.drill,
        runner: _w3BlindDefenseRunner(
          hero: 'sb',
          cards: 'Qc 5d',
          caption: 'BB acts next.',
          question: 'Play Q5o?',
          options: const [
            (
              id: 'call',
              label: 'Call 2 BB',
              reason:
                  'Calling costs 2 BB with Q5o from SB, and BB still has a turn. A better queen can cost you more after the flop.',
            ),
            (
              id: 'fold',
              label: 'Fold',
              reason:
                  "Fold Q5o because BTN can raise stronger queens and BB still has a turn. Calling 2 BB leaves you acting before BTN after the flop with a low second card.",
            ),
            (
              id: 'raise',
              label: 'Reraise to 10 BB',
              reason:
                  "A reraise from SB costs 9.5 BB more and can get called by stronger hands. Folding keeps those chips with Q5o.",
            ),
          ],
          correct: 1,
        ),
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'small_blind_raise',
        title: 'Premium in SB',
        phase: Act0LessonPhaseV1.drill,
        runner: _w3BlindDefenseRunner(
          hero: 'sb',
          cards: 'As Ad',
          caption: 'BB acts next.',
          question: 'Play AA?',
          options: const [
            (
              id: 'raise',
              label: 'Reraise to 10 BB',
              reason:
                  "Reraise AA to 10 BB because BTN can call with weaker pairs or strong aces. Calling lets BB enter cheaply and keeps the pot smaller.",
            ),
            (
              id: 'call',
              label: 'Call 2 BB',
              reason:
                  'A call gives BB a cheaper flop and misses a chance to build the pot with AA. A reraise charges both players more.',
            ),
            (
              id: 'fold',
              label: 'Fold',
              reason:
                  'Folding AA from SB hands the 0.5 BB already posted to the pot and gives up a chance to build value against BTN.',
            ),
          ],
          correct: 0,
        ),
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'small_blind_medium_raise',
        title: 'HJ Medium in SB',
        phase: Act0LessonPhaseV1.drill,
        runner: _act0WithWrongFeedbackReasonsV1(
          _w3BlindDefenseRunner(
            hero: 'sb',
            cards: 'Ah Qd',
            caption: 'BB acts next.',
            question: 'Play AQo?',
            options: const [
              (
                id: 'raise',
                label: 'Reraise to 10 BB',
                reason:
                    "Reraise AQo to 10 BB because BTN can open weaker aces such as AJo and ATs. BTN can fold or call the higher price. Calling lets BB in cheaply while you act before BTN after the flop.",
              ),
              (
                id: 'call',
                label: 'Call 2 BB',
                reason:
                    'Calling 2 BB with AQo gives BB a cheap entry while you still act before BTN after the flop. A reraise charges BB more.',
              ),
              (
                id: 'fold',
                label: 'Fold',
                reason:
                    'Folding AQo from SB against one BTN open gives up the 0.5 BB already posted and folds a hand strong enough to reraise in the HJ Medium row.',
              ),
            ],
            correct: 0,
          ),
          const {
            "fold":
                "Folding gives up a chance to win the 2.5 BB BTN open and the BB post with a hand in the chart's SB reraise row.",
          },
        ),
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'small_blind_medium_fold',
        title: 'CO Medium in SB',
        phase: Act0LessonPhaseV1.drill,
        runner: _w3BlindDefenseRunner(
          hero: 'sb',
          cards: 'Kd Jc',
          caption: 'BB acts next.',
          question: 'Play KJo?',
          options: const [
            (
              id: 'call',
              label: 'Call 2 BB',
              reason:
                  'Calling 2 BB from SB with KJo puts you first to act after the flop while BB can still raise behind you. In this small-blind rule, the CO Medium row folds.',
            ),
            (
              id: 'fold',
              label: 'Fold',
              reason:
                  "Fold KJo because BTN can raise stronger kings and BB still has a turn. Calling costs 2 BB and puts you first after the flop.",
            ),
            (
              id: 'raise',
              label: 'Reraise to 10 BB',
              reason:
                  "A reraise costs 9.5 BB more with KJo, and BTN can continue with better kings. Folding keeps those chips.",
            ),
          ],
          correct: 1,
        ),
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'big_blind_price',
        title: 'Call price',
        phase: Act0LessonPhaseV1.drill,
        runner: _act0WithWrongFeedbackReasonsV1(
          _w3BlindDefenseRunner(
            hero: 'bb',
            cards: 'Kd 8d',
            caption: 'BTN opens to 2.5 BB. SB folds.',
            question: 'How much more to call?',
            options: const [
              (
                id: 'two_five',
                label: '2.5 BB',
                reason:
                    'BTN put in 2.5 BB total. Paying that much again from BB would count your posted 1 BB twice.',
              ),
              (
                id: 'one',
                label: '1 BB',
                reason:
                    '1 BB is the amount already in from your seat, leaving 1.5 BB still due against BTN.',
              ),
              (
                id: 'one_five',
                label: '1.5 BB',
                reason:
                    'BTN raised to 2.5 BB, so subtract your posted 1 BB to get the 1.5 BB call. Paying 2.5 BB again would count your post twice.',
              ),
            ],
            correct: 2,
          ),
          const {
            "one":
                "Putting in only 1 BB leaves the BB contribution at 2 BB, still 0.5 BB short of the open.",
          },
        ),
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'big_blind_defend',
        title: 'Call or fold',
        phase: Act0LessonPhaseV1.review,
        runner: _w3BlindDefenseRunner(
          hero: 'bb',
          cards: 'Jh Th',
          caption: 'SB folds. Assume you win 32% and face no later bets.',
          question: 'Can you call?',
          options: const [
            (
              id: 'fold',
              label: 'The price is too high',
              reason:
                  'Calling costs 1.5 BB and makes a 5.5 BB pot. Folding gives up this call with a 32% chance, above the roughly 27% threshold.',
            ),
            (
              id: 'call',
              label: 'The chance to win clears the price',
              reason:
                  'BTN raises and your 1.5 BB call makes a 5.5 BB pot, so you need about 27%. Call because the stated 32% clears the price while folding gives up that edge.',
            ),
            (
              id: 'posted_free',
              label: 'The flop is free after posting BB',
              reason:
                  'Your 1 BB post counts, but matching BTN still costs 1.5 BB. Treating it as free can lead to paying with hands below the threshold.',
            ),
          ],
          correct: 1,
        ),
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
    extraDrills: [
      Act0LessonTaskV1(
        taskId: 'bvb_sb_open',
        title: 'First in from SB',
        phase: Act0LessonPhaseV1.drill,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
        runner: _w3BlindDefenseRunner(
          hero: 'sb',
          cards: 'As Ah',
          table: _day7PreflopV1('sb', 'As Ah', showTurn: true),
          caption: 'Folded to you in SB.',
          question: 'What do you do with AA?',
          correct: 1,
          options: const [
            (
              id: 'call',
              label: 'Call 0.5 BB',
              reason:
                  'Completing costs 0.5 BB and gives BB a free check. A raise can get more chips in while your aces are ahead.',
            ),
            (
              id: 'raise',
              label: 'Raise to 3 BB',
              reason:
                  'Raise AA so BB can call with weaker pairs or strong aces. Calling gives BB a free check.',
            ),
            (
              id: 'fold',
              label: 'Fold',
              reason:
                  'Folding gives up a chance to win the blinds or get paid by a weaker hand. Raise against the one player still to act.',
            ),
          ],
        ),
      ),
      Act0LessonTaskV1(
        taskId: 'bvb_bb_call',
        title: 'Defend BB',
        phase: Act0LessonPhaseV1.drill,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
        runner: _w3BlindDefenseRunner(
          hero: 'bb',
          cards: 'Qh Jh',
          table: _w3BigBlindFacingSmallBlindV1('Qh Jh'),
          caption: 'SB opens to 3 BB. Assume 38% wins, no ties or later bets.',
          question: 'What do you do?',
          correct: 2,
          options: const [
            (
              id: 'fold',
              label: 'Fold',
              reason:
                  'Folding gives up a call that needs only one win in three. Your assumed 38% clears that price.',
            ),
            (
              id: 'check',
              label: 'Check',
              reason:
                  'Checking leaves SB’s raise unmatched. A call pays the remaining 2 BB.',
            ),
            (
              id: 'call',
              label: 'Call 2 BB',
              reason:
                  'Call 2 BB into a final pot of 6 BB, so you need about 33%. SB has raised and the 38% assumption makes calling better than folding.',
            ),
          ],
        ),
      ),
      Act0LessonTaskV1(
        taskId: 'bvb_bb_repeat',
        title: 'Compare the price',
        phase: Act0LessonPhaseV1.drill,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
        runner: _w3BlindDefenseRunner(
          hero: 'bb',
          cards: '7s 3d',
          table: _w3BigBlindFacingSmallBlindV1('7s 3d'),
          caption: 'SB opens to 3 BB. Assume 25% wins, no ties or later bets.',
          question: 'What do you do?',
          correct: 0,
          options: const [
            (
              id: 'fold',
              label: 'Fold',
              reason:
                  'SB raises to 3 BB, so a 2 BB call makes a 6 BB pot and needs about 33%. Fold because 25% wins too rarely for that price.',
            ),
            (
              id: 'call',
              label: 'Call 2 BB',
              reason:
                  'Calling puts 2 BB at risk with a 25% chance of winning the 6 BB final pot. Folding avoids that loss.',
            ),
            (
              id: 'check',
              label: 'Check',
              reason:
                  'SB has a live wager. Checking cannot answer it, so fold to leave the hand without paying more.',
            ),
          ],
        ).copyWith(hintPolicy: Act0HintPolicyV1.hidden),
      ),
    ],
  ),
  _lessonFromTasksV1(
    lessonId: 'position_checkpoint',
    title: 'Position checkpoint',
    subtitle: 'Use seat order before choosing an action.',
    phaseLabel: 'Checkpoint',
    rewardXp: 40,
    sourceTasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'position_checkpoint_intro',
        title: 'Seat before action',
        phase: Act0LessonPhaseV1.theory,
        runner: _w3AddAlternative(
          _w3OrientationFromSeat(
            _act0WithWrongFeedbackReasonsV1(
              _world2PositionIntroRunner.copyWith(
                question:
                    'Which of these seats sees HJ act before making its own first decision before the flop?',
                options: _laterSeatChoices,
              ),
              const {
                'utg':
                    'UTG takes its first preflop turn before HJ. BTN follows HJ and can see that action first.',
              },
            ),
            'co',
          ),
          id: 'hj',
          label: 'HJ',
          reason:
              'HJ takes the action the question asks you to observe. BTN acts later and can see what HJ did.',
          seat: 'hj',
        ),
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'position_checkpoint_late_open',
        title: 'Late: open or limp?',
        phase: Act0LessonPhaseV1.drill,
        runner: _act0WithWrongFeedbackReasonsV1(
          _w3AddAlternative(
            _world3LateOpenRunner.copyWith(
              caption: 'Folded to BTN with QTo.',
              hint: 'Find your hand and seat in the chart.',
              table: _world3LateOpenRunner.table.copyWith(
                heroCards: const <Act0CardStateV1>[
                  Act0CardStateV1(rank: 'Q', suit: 'd'),
                  Act0CardStateV1(rank: 'T', suit: 'c'),
                ],
                centerLabel: 'No one has raised',
              ),
              options: _additionalLateOpenChoices,
              teachingSteps: const <Act0TeachingStepV1>[],
            ),
            id: 'fold',
            label: 'Fold',
            reason:
                'The chart opens QTo in BTN. Folding from this seat passes up an open into the 1.5 BB blinds.',
          ),
          const {
            'call':
                'Limping QTo from BTN stakes 1 BB and offers BB a free check. A 3 BB open gives the blinds a fold decision.',
          },
        ),
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'position_checkpoint_early_fold',
        title: 'Early: A9o first in',
        phase: Act0LessonPhaseV1.drill,
        runner: _act0WithWrongFeedbackReasonsV1(
          _w3AddAlternative(
            _act0WithWrongFeedbackReasonsV1(
              _world3CheckpointEarlyFoldRunner.copyWith(
                options: _act0AuthoredCorrectOptionAtV1(
                  _world3CheckpointEarlyFoldRunner.options,
                  correctOptionId: 'fold',
                  correctIndex: 1,
                ),
              ),
              const {
                'raise':
                    'Raising A9o from UTG into the 1.5 BB pot risks chips with five players still to act. The Sharky starting chart folds A9o here because stronger aces can dominate it.',
              },
            ),
            id: 'call',
            label: 'Call',
            reason:
                'Calling 1 BB with A9o from UTG invites players behind to raise. Folding keeps that blind.',
          ),
          const {
            "call":
                "Limping A9o from UTG costs 1 BB before any of the five seats behind have acted.",
          },
        ),
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'position_checkpoint_btn_call',
        title: 'BTN: callable spot',
        phase: Act0LessonPhaseV1.drill,
        runner: _w3AddAlternative(
          _act0WithWrongFeedbackReasonsV1(
            _world3PositionCheckpointCallRunner,
            const {
              'fold':
                  'HJ opened to 2.5 BB, making the pot 4 BB before you act. Folding KJs on BTN gives up the in-position call in the Sharky starting chart.',
            },
          ),
          id: 'raise',
          label: 'Reraise to 7.5 BB',
          reason:
              'The chart calls HJ for 2.5 BB with KJs on BTN. Reraising risks 5 BB extra against better hands.',
        ),
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'position_checkpoint_table_notice',
        title: 'Real-table seat read',
        phase: Act0LessonPhaseV1.drill,
        runner: _act0WithWrongFeedbackReasonsV1(
          _w3TablePositionNoticeRunner.copyWith(
            options: _act0AuthoredCorrectOptionAtV1(
              _w3TablePositionNoticeRunner.options,
              correctOptionId: 'players_behind',
              correctIndex: 2,
            ),
          ),
          const {
            "acts_last":
                "CO acts before BTN, SB and BB on this first pass. Those three seats still have decisions.",
            "late_free_pass":
                "CO can still face a call or raise from BTN, SB or BB. Opening from CO puts chips at risk even after the earlier folds.",
          },
        ),
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'position_checkpoint_review',
        title: 'Position recap',
        phase: Act0LessonPhaseV1.review,
        runner: _act0WithWrongFeedbackReasonsV1(
          _act0WithWrongFeedbackReasonsV1(
            _w3AddAlternative(
              _world3LateOpenRunner.copyWith(
                caption: 'Folded to BTN with ATs.',
                hint: 'Find your hand and seat in the chart.',
                table: _world3LateOpenRunner.table.copyWith(
                  heroCards: const <Act0CardStateV1>[
                    Act0CardStateV1(rank: 'A', suit: 'h'),
                    Act0CardStateV1(rank: 'T', suit: 'h'),
                  ],
                  centerLabel: 'No one has raised',
                ),
                options: _act0AuthoredCorrectOptionAtV1(
                  _additionalLateOpenChoices,
                  correctOptionId: 'raise',
                  correctIndex: 0,
                ),
                teachingSteps: const <Act0TeachingStepV1>[],
              ),
              id: 'fold',
              label: 'Fold',
              reason:
                  'ATs on BTN is in the HJ–BTN opening row. Folding gives up a chance to raise for the 1.5 BB already posted.',
            ),
            const {
              'call':
                  'A 1 BB limp with ATs from BTN keeps SB and BB in cheaply. A 3 BB raise can win the 1.5 BB already posted.',
            },
          ),
          const {
            "call":
                "Limping ATs on BTN costs 1 BB, gives BB a free check and misses the chance to take the blind pot with a raise.",
          },
        ),
        rewardXp: 15,
        stepKind: Act0LessonStepKindV1.proveIt,
      ),
    ],
  ),
];

final _preflopFrameworkLessons = <Act0LessonCardV1>[
  _lessonFromTasksV1(
    lessonId: 'preflop_first_in_open',
    title: 'First-in open',
    subtitle: 'When nobody entered, raising can start the hand.',
    phaseLabel: 'Open',
    rewardXp: 30,
    sourceTasks: _preflopBasicsLessons[1].taskList,
  ),
  _lessonFromTasksV1(
    lessonId: 'preflop_facing_open',
    title: 'Facing an open',
    subtitle: 'A raise before you changes the decision.',
    phaseLabel: 'Facing open',
    rewardXp: 30,
    sourceTasks: _preflopBasicsLessons[2].taskList,
  ),
  _lessonFromTasksV1(
    lessonId: 'open_call_fold',
    title: 'Open, call, fold',
    subtitle: 'Read first-in, facing-open, then act.',
    phaseLabel: 'Frame',
    rewardXp: 35,
    sourceTasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'frame_intro',
        title: 'Frame first',
        phase: Act0LessonPhaseV1.theory,
        runner: _world3FirstInIntroRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'frame_open',
        title: 'Open',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3ButtonOpenA9sRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'frame_call',
        title: 'Call',
        phase: Act0LessonPhaseV1.drill,
        runner: _world4CallFrameRunner,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'frame_recap',
        title: 'Action frame recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world3FirstInRecapRunner,
        rewardXp: 12,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  _lessonFromTasksV1(
    lessonId: 'preflop_frame_before_action',
    title: 'Frame before action',
    subtitle: 'Same hand, different action frame.',
    phaseLabel: 'Context',
    rewardXp: 35,
    sourceTasks: _preflopBasicsLessons[4].taskList,
  ),
  _lessonFromTasksV1(
    lessonId: 'preflop_framework_checkpoint',
    title: 'Preflop checkpoint',
    subtitle: 'Bucket, seat, frame, then action.',
    phaseLabel: 'Checkpoint',
    rewardXp: 40,
    sourceTasks: _preflopBasicsLessons[6].taskList,
    extraDrills: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'checkpoint_table_frame',
        title: 'Real-table frame read',
        phase: Act0LessonPhaseV1.drill,
        runner: _w4TableFrameNoticeRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
    ],
  ),
];

final _w4IdentifyBettorRunner = _world4PriceIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w4_price_find_bettor',
  caption: 'You checked the flop. Now there is a bet to match.',
  hint: '',
  question: 'Tap the seat that made the flop bet you are facing.',
  table: _day7PostflopV1(
    'bb',
    'Ad Jc',
    'As 8s 4d',
    opponent: 'co',
    betBb: 3,
    showTurn: true,
  ).copyWith(selectableSeatIds: const ['bb', 'co', 'btn']),
  feedbackTitle: 'CO set the new price.',
  feedbackReason: 'CO put 3 BB in on the flop after you checked.',
  teachingSteps: const [],
  options: const [
    Act0RunnerOptionV1(
      id: 'bb',
      seatId: 'bb',
      label: 'Your seat',
      isCorrect: false,
      preferredLabel: 'Cutoff',
      betterAnswerLabel: 'Cutoff',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Checking added no new chips.',
      feedbackReason:
          'You checked from BB. Counting the preflop blind as a flop bet would make you read the wrong price.',
    ),
    Act0RunnerOptionV1(
      id: 'btn',
      seatId: 'btn',
      label: 'Button',
      isCorrect: false,
      preferredLabel: 'Cutoff',
      betterAnswerLabel: 'Cutoff',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'The dealer marker does not show a bet.',
      feedbackReason:
          'BTN folded before the flop. Looking at the dealer marker instead of the new wager would miss the 3 BB you face.',
    ),
    Act0RunnerOptionV1(
      id: 'co',
      seatId: 'co',
      label: 'Cutoff',
      isCorrect: true,
      preferredLabel: 'Cutoff',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'CO set the new price.',
      feedbackReason:
          'CO put 3 BB in after your check. That flop bet is now the amount you must match to stay in.',
    ),
  ],
);

Act0RunnerStateV1 _w4SeatDecisionV1({
  required String id,
  required String caption,
  required String question,
  required Act0TableStateV1 table,
  required String answer,
  required Map<String, (String, String)> feedback,
}) {
  final preferred = feedback[answer]!.$1;
  return _w4IdentifyBettorRunner.copyWith(
    lessonId: id,
    caption: caption,
    question: question,
    table: table.copyWith(selectableSeatIds: feedback.keys.toList()),
    feedbackTitle: 'You found the seat.',
    feedbackReason: feedback[answer]!.$2,
    options: [
      for (final entry in feedback.entries)
        Act0RunnerOptionV1(
          id: entry.key,
          seatId: entry.key,
          label: entry.value.$1,
          isCorrect: entry.key == answer,
          quality: entry.key == answer
              ? Act0FeedbackQualityV1.correct
              : Act0FeedbackQualityV1.wrong,
          preferredLabel: preferred,
          betterAnswerLabel: entry.key == answer ? '' : preferred,
          feedbackTitle: entry.key == answer
              ? 'You found the seat.'
              : 'Check who can respond.',
          feedbackReason: entry.value.$2,
          repairFocusCardIds: const ['board_0', 'board_1', 'board_2'],
        ),
    ],
  );
}

Act0RunnerStateV1 _w4ChooseSmallBetV1({
  required Act0RunnerStateV1 source,
  required String id,
  required String caption,
  required String question,
  required Act0TableStateV1 table,
  required String correctReason,
  required String checkReason,
  required String largerBetReason,
  required int correctIndex,
  Act0FeedbackQualityV1 largerBetQuality = Act0FeedbackQualityV1.wrong,
}) => source.copyWith(
  lessonId: id,
  phase: Act0LessonPhaseV1.drill,
  caption: caption,
  question: question,
  hint: '',
  table: table,
  teachingSteps: const [],
  feedbackTitle: 'The smaller bet fits.',
  feedbackReason: correctReason,
  options: _act0AuthoredCorrectOptionAtV1(
    [
      Act0RunnerOptionV1(
        id: 'check',
        label: 'Check',
        isCorrect: false,
        preferredLabel: 'Bet 2 BB',
        betterAnswerLabel: 'Bet 2 BB',
        quality: Act0FeedbackQualityV1.wrong,
        feedbackTitle: 'Look at the response.',
        feedbackReason: checkReason,
        repairFocusCardIds: const ['board_0', 'board_1', 'board_2'],
      ),
      Act0RunnerOptionV1(
        id: 'bet_two',
        label: 'Bet 2 BB',
        isCorrect: true,
        preferredLabel: 'Bet 2 BB',
        quality: Act0FeedbackQualityV1.correct,
        feedbackTitle: 'The smaller bet fits.',
        feedbackReason: correctReason,
        repairFocusCardIds: const ['board_0', 'board_1', 'board_2'],
      ),
      Act0RunnerOptionV1(
        id: 'bet_four',
        label: 'Bet 4 BB',
        isCorrect: false,
        preferredLabel: 'Bet 2 BB',
        betterAnswerLabel: 'Bet 2 BB',
        quality: largerBetQuality,
        feedbackTitle: 'Compare both bets.',
        feedbackReason: largerBetReason,
        repairFocusCardIds: const ['board_0', 'board_1', 'board_2'],
      ),
    ],
    correctOptionId: 'bet_two',
    correctIndex: correctIndex,
  ),
);

final _betPurposePriceLessons = <Act0LessonCardV1>[
  Act0LessonCardV1(
    lessonId: 'why_bets_happen',
    title: 'Why bets happen',
    subtitle: 'Every bet should have a simple purpose.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Purpose',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 30,
    runner: _world4PurposeIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w4_purpose_intro',
        title: 'Bet purpose',
        phase: Act0LessonPhaseV1.theory,
        runner: _world4PurposeIntroRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_value_purpose',
        title: 'Value reason',
        phase: Act0LessonPhaseV1.drill,
        runner: _w4CheckedFlopScenarioV1(
          _world4ValuePurposeRunner.copyWith(
            options: _act0AuthoredCorrectOptionAtV1(
              _world4ValuePurposeRunner.options,
              correctOptionId: 'value',
              correctIndex: 2,
            ),
          ),
          hero: 'co',
        ),
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_bluff_purpose',
        title: 'Bluff reason',
        phase: Act0LessonPhaseV1.drill,
        runner: _w4CheckedFlopScenarioV1(
          _world4BluffPurposeRunner.copyWith(
            options: _act0AuthoredCorrectOptionAtV1(
              _world4BluffPurposeRunner.options,
              correctOptionId: 'bluff',
              correctIndex: 1,
            ),
          ),
          hero: 'hj',
        ),
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_purpose_collect_value',
        title: 'Get a call from a worse hand',
        phase: Act0LessonPhaseV1.drill,
        runner: _w4ChooseSmallBetV1(
          source: _world4ValuePurposeRunner,
          id: 'w4_purpose_collect_value',
          correctIndex: 0,
          caption: 'BB checks with Q-8 and will call 2 BB or fold to 4 BB.',
          question: 'What do you do to get paid by the weaker queen?',
          table: _day7PostflopV1(
            'co',
            'Qs Jc',
            'Qh 6d 2c',
            checkedToHero: true,
            showTurn: true,
          ),
          correctReason:
              "Bet 2 BB because BB’s Q-8 calls and has the worse kicker. A bet of 4 BB loses that call.",
          checkReason:
              "Checking misses a 2 BB call from Q-8. Betting 2 BB earns that payment.",
          largerBetReason:
              'BB folds Q-8 to 4 BB under this rule, so the bigger bet loses the call you wanted.',
        ),
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_purpose_recap',
        title: 'Purpose recap',
        phase: Act0LessonPhaseV1.review,
        runner: _w4CheckedFlopScenarioV1(
          _world4PurposeRecapRunner,
          hero: 'co',
          hand: 'Jh Jc',
        ),
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'small_half_pot',
    title: 'Small, half, pot',
    subtitle: 'Size says how much pressure you create.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Sizing',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 35,
    runner: _world4SizingIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w4_sizing_intro',
        title: 'Size language',
        phase: Act0LessonPhaseV1.theory,
        runner: _w4CheckedFlopScenarioV1(
          _world4SizingIntroRunner,
          hero: 'hj',
          hand: 'As Kc',
        ),
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_small_bet',
        title: 'One-third bet',
        phase: Act0LessonPhaseV1.drill,
        runner: _w4CheckedFlopScenarioV1(
          _world4SmallBetRunner.copyWith(
            options: _act0AuthoredCorrectOptionAtV1(
              _world4SmallBetRunner.options,
              correctOptionId: 'two',
              correctIndex: 1,
            ),
          ),
          hero: 'co',
          hand: '8h 8s',
        ),
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.sizing,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_half_pot_bet',
        title: 'Half-pot bet',
        phase: Act0LessonPhaseV1.drill,
        runner: _w4CheckedFlopScenarioV1(
          _world4HalfPotRunner,
          hero: 'hj',
          hand: 'Ks Kh',
        ),
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.sizing,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_pot_bet',
        title: 'Pot-size bet',
        phase: Act0LessonPhaseV1.drill,
        runner: _w4CheckedFlopScenarioV1(
          _world4PotBetRunner,
          hero: 'co',
          hand: 'Td Tc',
        ),
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.sizing,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_min_raise_preflop',
        title: 'Preflop minimum raise',
        phase: Act0LessonPhaseV1.drill,
        runner: _world4MinRaisePreflopRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_min_raise_postflop',
        title: 'Flop minimum raise',
        phase: Act0LessonPhaseV1.drill,
        runner: _world4MinRaisePostflopRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_sizing_recap',
        title: 'Sizing recap',
        phase: Act0LessonPhaseV1.review,
        runner: _w4CheckedFlopScenarioV1(
          _world4SizingRecapRunner,
          hero: 'hj',
          hand: '9c 9h',
        ),
        rewardXp: 12,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'call_price',
    title: 'Call price',
    subtitle: 'A bet gives you a price to continue.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Price',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 30,
    runner: _world4PriceIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w4_price_intro',
        title: 'Facing a price',
        phase: Act0LessonPhaseV1.theory,
        runner: _world4PriceIntroRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_good_price_call',
        title: 'Call small price',
        phase: Act0LessonPhaseV1.drill,
        runner: _world4GoodPriceCallRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_bad_price_fold',
        title: 'Fold high price',
        phase: Act0LessonPhaseV1.drill,
        runner: _world4BadPriceFoldRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _world4BadPriceFoldRunner.options,
            correctOptionId: 'fold',
            correctIndex: 2,
          ),
        ),
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_price_find_bettor',
        title: 'Find the bet you face',
        phase: Act0LessonPhaseV1.drill,
        runner: _w4IdentifyBettorRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_cheap_price_marginal_call',
        title: 'Cheap call with middle pair',
        phase: Act0LessonPhaseV1.drill,
        runner: _world4CheapPriceMarginalCallRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _world4CheapPriceMarginalCallRunner.options,
            correctOptionId: 'call',
            correctIndex: 1,
          ),
        ),
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_big_price_marginal_fold',
        title: 'Big price, thinner hand',
        phase: Act0LessonPhaseV1.drill,
        runner: _world4BigPriceMarginalFoldRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _world4BigPriceMarginalFoldRunner.options,
            correctOptionId: 'fold',
            correctIndex: 1,
          ),
        ),
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_price_recap',
        title: 'Price recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world4PriceRecapRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'value_bets',
    title: 'Value bets',
    subtitle: 'Bet when worse hands can still call.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Value',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 30,
    runner: _world4ValueIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w4_value_intro',
        title: 'Worse calls',
        phase: Act0LessonPhaseV1.theory,
        runner: _w4CheckedFlopScenarioV1(_world4ValueIntroRunner, hero: 'co'),
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_value_bet',
        title: 'Bet top pair',
        phase: Act0LessonPhaseV1.drill,
        runner: _w4CheckedFlopScenarioV1(_world4ValueBetRunner, hero: 'co'),
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_value_missed',
        title: 'Do not hide value',
        phase: Act0LessonPhaseV1.drill,
        runner: _w4CheckedFlopScenarioV1(
          _world4ValueCheckMissRunner.copyWith(
            options: _act0AuthoredCorrectOptionAtV1(
              _world4ValueCheckMissRunner.options,
              correctOptionId: 'bet_half',
              correctIndex: 2,
            ),
          ),
          hero: 'hj',
        ),
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_value_worse_call_seat',
        title: 'Find the worse caller',
        phase: Act0LessonPhaseV1.drill,
        runner: _w4SeatDecisionV1(
          id: 'w4_value_worse_call_seat',
          caption: 'A pair of eights will call a 2 BB bet. Use the live seats.',
          question: 'Tap the seat that can pay off a value bet.',
          table: _day7PostflopV1(
            'btn',
            'Kd Qs',
            'Kh 8c 3h',
            checkedToHero: true,
            showTurn: true,
          ),
          answer: 'bb',
          feedback: const {
            'btn': (
              'Button',
              'You hold a pair of kings on the Button. Choosing your own seat misses the opponent who can add chips.',
            ),
            'bb': (
              'Big blind',
              'BB can call 2 BB with eights, a weaker pair than your kings.',
            ),
            'co': (
              'Cutoff',
              'CO folded before the flop. A folded seat cannot add 2 BB to the pot.',
            ),
          },
        ),
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_value_recap',
        title: 'Value recap',
        phase: Act0LessonPhaseV1.review,
        runner: _w4CheckedFlopScenarioV1(_world4ValueRecapRunner, hero: 'co'),
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'bluff_pressure',
    title: 'Bluff pressure',
    subtitle: 'A bluff tries to make better hands fold.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Bluff',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 30,
    runner: _world4BluffIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w4_bluff_intro',
        title: 'Fold pressure',
        phase: Act0LessonPhaseV1.theory,
        runner: _w4CheckedFlopScenarioV1(_world4BluffIntroRunner, hero: 'hj'),
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_bluff_pressure',
        title: 'Apply pressure',
        phase: Act0LessonPhaseV1.drill,
        runner: _w4CheckedFlopScenarioV1(
          _world4BluffPressureRunner,
          hero: 'co',
        ),
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_bad_bluff',
        title: 'Bad pressure',
        phase: Act0LessonPhaseV1.drill,
        runner: _world4BadBluffRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _world4BadBluffRunner.options,
            correctOptionId: 'check',
            correctIndex: 1,
          ),
        ),
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_bluff_target_seat',
        title: 'Find the target of a bluff',
        phase: Act0LessonPhaseV1.drill,
        runner: _w4SeatDecisionV1(
          id: 'w4_bluff_target_seat',
          caption: 'A pair of fives will fold to 3 BB. You have ace-high.',
          question: 'Tap the seat your 3 BB bluff is aimed at.',
          table: _day7PostflopV1(
            'co',
            'Ah 7c',
            'Js 5d 2c',
            checkedToHero: true,
            showTurn: true,
          ),
          answer: 'bb',
          feedback: const {
            'btn': (
              'Button',
              'The Button folded preflop. Betting cannot make that seat give up another hand.',
            ),
            'co': (
              'Cutoff',
              'You are CO with ace-high. Choosing your seat misses who decides whether your bet wins immediately.',
            ),
            'bb': (
              'Big blind',
              'BB is your only live opponent. A fold from BB wins the 6 BB pot with ace-high.',
            ),
          },
        ),
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_bluff_recap',
        title: 'Bluff recap',
        phase: Act0LessonPhaseV1.review,
        runner: _w4CheckedFlopScenarioV1(_world4BluffRecapRunner, hero: 'hj'),
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'protection_and_denial',
    title: 'Protection and denial',
    subtitle: 'Bet so the next card is not free.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Protection',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 46,
    runner: _world4ProtectionIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w4_protection_intro',
        title: 'Deny free card',
        phase: Act0LessonPhaseV1.theory,
        runner: _world4ProtectionIntroRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_protection_bet',
        title: 'Protect pair',
        phase: Act0LessonPhaseV1.drill,
        runner: _world4ProtectionBetRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_protection_check',
        title: 'Free card risk',
        phase: Act0LessonPhaseV1.drill,
        runner: _world4ProtectionCheckRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _world4ProtectionCheckRunner.options,
            correctOptionId: 'free_card',
            correctIndex: 2,
          ),
        ),
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_protection_small_denial',
        title: 'Charge for the next card',
        phase: Act0LessonPhaseV1.drill,
        runner: _w4ChooseSmallBetV1(
          source: _world4ProtectionBetRunner,
          id: 'w4_protection_small_denial',
          correctIndex: 2,
          caption:
              'BB checks. BB’s overcards (A-K, A-Q, K-Q) fold to either bet. If BB has a set, it calls and wins.',
          question:
              'Which bet makes the overcards fold and risks the fewest chips?',
          table: _day7PostflopV1(
            'co',
            'Ts 9c',
            'Th 6s 3d',
            checkedToHero: true,
            showTurn: true,
          ),
          correctReason:
              'Bet 2 BB because overcards fold to either bet and you win the same 6 BB pot. When BB calls with a set, you lose 2 BB less than betting 4 BB.',
          checkReason:
              'Checking gives BB’s overcards a free chance to beat your tens. A 2 BB bet makes those hands fold.',
          largerBetQuality: Act0FeedbackQualityV1.suboptimal,
          largerBetReason:
              'Betting 4 BB costs 2 BB more when a set calls and wins. Betting 2 BB already gets the overcards to fold.',
        ),
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_protection_guided_raise_read',
        title: 'Read a raise with help',
        phase: Act0LessonPhaseV1.drill,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
        runner:
            _day7ExampleV1(
              4,
              'protection_and_denial',
              'guided_raise_read',
              _day7PostflopV1(
                'co',
                'Kh Qh',
                'Kc 8d 4s',
                heroLeadBb: 3,
                betBb: 9,
                showTurn: true,
              ),
              caption:
                  'Hand reading means using the action to see which hands are more likely. This BB usually calls with one pair and seldom raises a weak hand.',
              question: 'What became more likely after BB raised?',
              choices: const [
                'Weaker kings',
                'Sets',
                'Weak hands with no pair',
              ],
              correct: 1,
              reason:
                  'BB’s raise points toward sets because one pair usually calls in this model. Weaker kings remain possible.',
              wrongReasons: const {
                0: 'A weaker king tends to call in the stated model. A raise makes a set more likely.',
                2: 'BB rarely raises a weak hand in this model. Treating the raise like a weak hand risks paying off a set.',
              },
            ).task.runner.copyWith(
              hint: 'Compare the model’s calls with its raises.',
              hintPolicy: Act0HintPolicyV1.always,
            ),
      ),
      Act0LessonTaskV1(
        taskId: 'w4_protection_short_shove_price',
        title: 'A short all-in',
        phase: Act0LessonPhaseV1.drill,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
        runner: _day7ExampleV1(
          4,
          'protection_and_denial',
          'short_shove_price',
          _day7PostflopV1(
            'co',
            'Qd Jd',
            'Qs 9c 5h 2d',
            betBb: 6,
            opponentStartingBb: 8.75,
            opponentAllIn: true,
            showTurn: true,
          ),
          caption: 'BB goes all-in for 6 BB. Assume you win 40% and never tie.',
          question: 'Which choice earns more?',
          choices: const ['Fold', 'Both earn the same', 'Call'],
          correct: 2,
          reason:
              'BB goes all-in for its last 6 BB, so calling makes an 18 BB pot and needs 33%. Call because 40% beats that price. Folding misses the gain.',
          wrongReasons: const {
            0: 'Folding gives up a call with positive value. You need one win in three and the stated chance is 40%.',
            1: 'Calling wins 12 BB four times in ten and loses 6 BB six times in ten. That averages +1.2 BB, above folding.',
          },
        ).task.runner,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_protection_recap',
        title: 'Protection recap',
        phase: Act0LessonPhaseV1.review,
        runner: _w4CheckedFlopScenarioV1(
          _world4ProtectionRecapRunner,
          hero: 'co',
        ),
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'price_checkpoint',
    title: 'Price checkpoint',
    subtitle: 'Read purpose, size, and price before action.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Checkpoint',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 40,
    runner: _world4CheckpointIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w4_checkpoint_intro',
        title: 'Three reads',
        phase: Act0LessonPhaseV1.theory,
        runner: _w4CheckedFlopScenarioV1(
          _world4CheckpointIntroRunner,
          hero: 'hj',
          hand: 'Ts Tc',
        ),
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_checkpoint_value',
        title: 'Value or bluff',
        phase: Act0LessonPhaseV1.drill,
        runner: _world4ValuePurposeRunner.copyWith(
          question:
              'If BB can have A-T, A-J or A-Q, which hand could call a 3 BB bet while behind yours?',
          caption: 'BB checks on ace, seven and two.',
          table: _world4ValuePurposeRunner.table.copyWith(
            heroCards: const [
              Act0CardStateV1(rank: 'A', suit: 's'),
              Act0CardStateV1(rank: 'J', suit: 'd'),
            ],
          ),
          options: const [
            Act0RunnerOptionV1(
              id: 'bluff',
              label: 'A-Q',
              isCorrect: false,
              preferredLabel: 'A-T',
              quality: Act0FeedbackQualityV1.wrong,
              feedbackTitle: 'Compare the side cards.',
              feedbackReason:
                  'A-Q beats your pair of aces with its higher side card.',
            ),
            Act0RunnerOptionV1(
              id: 'value',
              label: 'A-T',
              isCorrect: true,
              preferredLabel: 'A-T',
              quality: Act0FeedbackQualityV1.correct,
              feedbackTitle: 'Your jack beats the ten.',
              feedbackReason:
                  'A-T can call with a weaker pair of aces. Your jack is higher than its ten.',
            ),
            Act0RunnerOptionV1(
              id: 'same_pair',
              label: 'A-J',
              isCorrect: false,
              preferredLabel: 'A-T',
              betterAnswerLabel: 'A-T',
              quality: Act0FeedbackQualityV1.wrong,
              feedbackTitle: 'Same best five.',
              feedbackReason:
                  'The two A-J hands tie on this flop. You are looking for a hand behind yours right now, such as the weaker A-T.',
            ),
          ],
          teachingSteps: const <Act0TeachingStepV1>[],
        ),
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_checkpoint_price',
        title: 'Call or fold',
        phase: Act0LessonPhaseV1.drill,
        runner: _world4BadPriceFoldRunner.copyWith(
          caption: 'HJ bet 3 BB on the turn. $_world4PriceReminder',
          table: _act0W4FacingTurnPriceV1(
            _world4BadPriceFoldRunner.table,
            potBeforeBet: 7,
            price: 3,
          ),
          options: const [
            Act0RunnerOptionV1(
              id: 'call',
              label: 'Call',
              amountLabel: '3 BB',
              isCorrect: true,
              preferredLabel: 'Call',
              quality: Act0FeedbackQualityV1.correct,
              feedbackTitle: 'Compare the two chances.',
              feedbackReason:
                  "HJ bets 3 BB, so a call makes a 13 BB pot and needs about 23%. The stated 25% clears that price. Folding gives up the gain.",
            ),
            Act0RunnerOptionV1(
              id: 'fold',
              label: 'Fold',
              isCorrect: false,
              preferredLabel: 'Call',
              quality: Act0FeedbackQualityV1.wrong,
              feedbackTitle: 'Find the threshold from the displayed price.',
              feedbackReason:
                  'You need about a 23% chance at this price. One win in four is enough, so folding gives up a profitable call.',
            ),
            Act0RunnerOptionV1(
              id: 'call_ignore_price',
              label: 'Call because 25% wins often enough',
              isCorrect: false,
              preferredLabel: 'Call',
              betterAnswerLabel: 'Call',
              quality: Act0FeedbackQualityV1.suboptimal,
              feedbackTitle: 'The action fits. Compare the price too.',
              feedbackReason:
                  'You must pay 3 BB for a 13 BB final pot. At about 23% to break even, 25% just covers it. On a bigger wager that same win rate can lose chips.',
            ),
          ],
        ),
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_checkpoint_table_price',
        title: 'Real-table price read',
        phase: Act0LessonPhaseV1.drill,
        runner: _world4PriceTableTransferRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _world4PriceTableTransferRunner.options,
            correctOptionId: 'call',
            correctIndex: 2,
          ),
        ),
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_checkpoint_table_purpose_price',
        title: 'Live purpose and price',
        phase: Act0LessonPhaseV1.drill,
        runner: _world4PurposePriceTableTransferRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_checkpoint_review',
        title: 'Price recap',
        phase: Act0LessonPhaseV1.review,
        runner: _w4CheckedFlopScenarioV1(
          _world4CheckpointRunner,
          hero: 'co',
          hand: 'Js Jc',
        ),
        rewardXp: 15,
        stepKind: Act0LessonStepKindV1.proveIt,
      ),
    ],
  ),
];

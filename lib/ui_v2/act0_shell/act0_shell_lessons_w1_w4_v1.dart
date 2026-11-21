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

final _pokerFromZeroLessons = <Act0LessonCardV1>[
  Act0LessonCardV1(
    lessonId: 'what_poker_is',
    title: 'First Table Guide',
    subtitle: 'Find your cards, the shared board, and the chips in the middle.',
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
        summary:
            'Start with one calm read: hero, blinds, table, and the Sharky loop.',
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
        runner: _firstTableGuideReadTableRecheckRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _firstTableGuideReadTableRecheckRunner.options,
            correctOptionId: 'two_three_four',
            correctIndex: 2,
          ),
        ),
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.transfer,
        summary:
            'Repeat the same table scan on a second spot: Hero cards, board, and pot.',
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
        summary:
            'Carry the same scan into a preflop setup read before strategy choices start.',
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
      Act0LessonTaskV1(
        taskId: 'first_table_guide_shared_cards_repair',
        title: 'Read the cards',
        phase: Act0LessonPhaseV1.drill,
        runner: _privateBoardRunner.copyWith(
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
              Act0CardStateV1(rank: '9', suit: 'd', tone: Act0CardToneV1.red),
            ],
            boardCards: const [
              Act0CardStateV1(rank: '8', suit: 'h', tone: Act0CardToneV1.red),
              Act0CardStateV1(rank: '5', suit: 'd', tone: Act0CardToneV1.red),
              Act0CardStateV1(rank: '2', suit: 'c'),
            ],
          ),
          teachingSteps: const [],
        ),
        rewardXp: 0,
        stepKind: Act0LessonStepKindV1.fixMistakes,
        repairOnly: true,
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
        taskId: 'cards_ranks_suits_suit_drill',
        title: 'Name a suit',
        phase: Act0LessonPhaseV1.drill,
        runner: _suitsRunner,
        taskFamily: Act0TaskFamilyV1.recognition,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'cards_ranks_suits_private_board',
        title: 'Private vs board',
        phase: Act0LessonPhaseV1.drill,
        runner: _privateBoardRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _privateBoardRunner.options,
            correctOptionId: 'board',
            correctIndex: 1,
          ),
        ),
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'cards_ranks_suits_board_count',
        title: 'Board count',
        phase: Act0LessonPhaseV1.drill,
        runner: _boardCountRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.counting,
      ),
      Act0LessonTaskV1(
        taskId: 'cards_ranks_suits_best_five',
        title: 'Best five idea',
        phase: Act0LessonPhaseV1.drill,
        runner: _bestFiveCardsRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'cards_ranks_suits_recap',
        title: 'Cards recap',
        phase: Act0LessonPhaseV1.review,
        runner: _cardsRecapRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _cardsRecapRunner.options,
            correctOptionId: 'five',
            correctIndex: 1,
          ),
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
        runner: _handRankingIntroRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'hand_rankings_pair_drill',
        title: 'Find the pair',
        phase: Act0LessonPhaseV1.drill,
        runner: _handRankingsRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _handRankingsRunner.options,
            correctOptionId: 'pair',
            correctIndex: 1,
          ),
        ),
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'hand_rankings_two_pair_drill',
        title: 'Two pair vs one pair',
        phase: Act0LessonPhaseV1.drill,
        runner: _twoPairRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'hand_rankings_trips_drill',
        title: 'Trips or set',
        phase: Act0LessonPhaseV1.drill,
        runner: _tripsRankRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _tripsRankRunner.options,
            correctOptionId: 'trips',
            correctIndex: 1,
          ),
        ),
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'hand_rankings_upper',
    title: 'Hand rankings 2',
    subtitle: 'Compare sequences, suits, and stronger groups.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Ranks',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 30,
    runner: _straightRankRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'hand_rankings_straight_drill',
        title: 'Find the straight',
        phase: Act0LessonPhaseV1.drill,
        runner: _straightRankRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'hand_rankings_flush_drill',
        title: 'Flush beats straight',
        phase: Act0LessonPhaseV1.drill,
        runner: _flushRankRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _flushRankRunner.options,
            correctOptionId: 'flush',
            correctIndex: 1,
          ),
        ),
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'hand_rankings_full_house_drill',
        title: 'Full house shape',
        phase: Act0LessonPhaseV1.drill,
        runner: _fullHouseRankRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'hand_rankings_quads_drill',
        title: 'Four of a kind',
        phase: Act0LessonPhaseV1.drill,
        runner: _quadsRankRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _quadsRankRunner.options,
            correctOptionId: 'quads',
            correctIndex: 1,
          ),
        ),
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'hand_rankings_royal_flush_drill',
        title: 'Royal flush check',
        phase: Act0LessonPhaseV1.drill,
        runner: _royalFlushRankRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'hand_rankings_full_house_vs_flush_drill',
        title: 'Full house beats flush',
        phase: Act0LessonPhaseV1.drill,
        runner: _fullHouseVsFlushRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _fullHouseVsFlushRunner.options,
            correctOptionId: 'hero_full_house',
            correctIndex: 1,
          ),
        ),
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.compare,
      ),
      Act0LessonTaskV1(
        taskId: 'hand_rankings_quads_vs_full_house_drill',
        title: 'Four of a kind beats a full house',
        phase: Act0LessonPhaseV1.drill,
        runner: _quadsVsFullHouseRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.compare,
      ),
      Act0LessonTaskV1(
        taskId: 'hand_rankings_royal_vs_flush_drill',
        title: 'Royal flush wins',
        phase: Act0LessonPhaseV1.drill,
        runner: _royalFlushVsFlushRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _royalFlushVsFlushRunner.options,
            correctOptionId: 'hero_royal_flush',
            correctIndex: 1,
          ),
        ),
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.compare,
      ),
      Act0LessonTaskV1(
        taskId: 'hand_rankings_best_five_drill',
        title: 'Choose best five',
        phase: Act0LessonPhaseV1.drill,
        runner: _bestFiveShowdownRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'hand_rankings_review',
        title: 'Ranking recap',
        phase: Act0LessonPhaseV1.review,
        runner: _rankingRecapRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.proveIt,
      ),
      Act0LessonTaskV1(
        taskId: 'showdown_kicker_drill',
        title: 'Same pair, better kicker',
        phase: Act0LessonPhaseV1.drill,
        runner: _showdownKickerRunner,
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
    rewardXp: 20,
    runner: _whatYouCanDoRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'positions_theory',
        title: 'Six seats',
        phase: Act0LessonPhaseV1.theory,
        runner: _positionsRunner.copyWith(
          teachingSteps: const [
            Act0TeachingStepV1(
              title: 'When cards reach the board',
              body:
                  'Preflop means no board cards yet. The flop has three. The turn is the fourth board card and the river is the fifth.',
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
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'positions_button',
        title: 'Tap the Button',
        phase: Act0LessonPhaseV1.drill,
        runner: _buttonSeatRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'positions_utg',
        title: 'Tap UTG',
        phase: Act0LessonPhaseV1.drill,
        runner: _act0W01ExplicitOrderRunnerV1(
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
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'positions_cutoff',
        title: 'Tap the cutoff',
        phase: Act0LessonPhaseV1.drill,
        runner: _act0NeutralSeatAssessmentPreservingTeachingV1(
          _cutoffSeatRunner,
        ),
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'blinds_theory',
        title: 'Blinds post first',
        phase: Act0LessonPhaseV1.theory,
        runner: _blindsOrderRunner.copyWith(
          table: _blindsOrderRunner.table.copyWith(
            selectableSeatIds: const ['btn', 'bb', 'sb'],
          ),
        ),
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'blinds_posts_drill',
        title: '1 BB baseline',
        phase: Act0LessonPhaseV1.drill,
        runner: _bigBlindPostRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'blinds_first_actor',
        title: 'First preflop actor',
        phase: Act0LessonPhaseV1.drill,
        runner: _act0W01ExplicitOrderRunnerV1(
          _act0NeutralSeatAssessmentPreservingTeachingV1(
            _firstPreflopActorRunner,
          ),
          frame: _Act0W01OrderFrameV1.first,
          taskId: 'blinds_first_actor',
          question: 'Who acts first preflop in this frame?',
        ),
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'blinds_last_actor',
        title: 'Last preflop actor',
        phase: Act0LessonPhaseV1.drill,
        runner: _act0W01ExplicitOrderRunnerV1(
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
        ),
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'blinds_postflop_button',
        title: 'Last to act on the flop',
        phase: Act0LessonPhaseV1.drill,
        runner: _act0W01ExplicitOrderRunnerV1(
          _postflopButtonActorRunner,
          frame: _Act0W01OrderFrameV1.flop,
          taskId: 'blinds_postflop_button',
        ),
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'blinds_button_moves',
        title: 'Button moves',
        phase: Act0LessonPhaseV1.drill,
        runner: _buttonMovesRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _buttonMovesRunner.options,
            correctOptionId: 'btn',
            correctIndex: 1,
          ),
        ),
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'blinds_review',
        title: 'Order recap',
        phase: Act0LessonPhaseV1.review,
        runner: _act0W01ExplicitOrderRunnerV1(
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
        runner: _act0W01ExplicitOrderRunnerV1(
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
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'positions_early_late',
        title: 'Early vs late',
        phase: Act0LessonPhaseV1.drill,
        runner: _act0W01ExplicitOrderRunnerV1(
          _act0NeutralSeatAssessmentPreservingTeachingV1(
            _earlyLatePositionRunner,
          ),
          frame: _Act0W01OrderFrameV1.first,
          taskId: 'positions_early_late',
          question:
              'Which seat has more players left to act behind it, UTG or BTN?',
        ),
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'positions_review',
        title: 'Position recap',
        phase: Act0LessonPhaseV1.review,
        runner: _act0W01ExplicitOrderRunnerV1(
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
        ),
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
        runner: _act0W01ExplicitFreeCheckContextV1(_checkActionRunner),
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
        tablePresentation: Act0TaskTablePresentationV1.stablePractice,
        summary: 'Recognize the one moment checking is free and correct.',
        lockedSummary: 'Clear Action words first, then unlock the no-bet read.',
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
        runner: _act0W01FoldedToBtnMechanicalContextV1(
          _whatYouCanDoRunner,
          heroCards: _heroQJsCards,
          handDescription: 'a queen and jack of the same suit',
        ),
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
        runner: _act0W01FoldedToBtnMechanicalContextV1(
          _actionRecapRunner.copyWith(
            options: _act0AuthoredCorrectOptionAtV1(
              _actionRecapRunner.options,
              correctOptionId: 'raise',
              correctIndex: 0,
            ),
          ),
        ),
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
        runner: _act0W01NewFirstHandStackContextV1(
          _act0FirstHandAkRunnerV1(_readBoardRunner),
        ),
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'your_first_hand_turn',
        title: 'Turn card',
        phase: Act0LessonPhaseV1.drill,
        runner: _act0W01NewFirstHandStackContextV1(
          _act0FirstHandAkRunnerV1(_turnBoardRunner),
        ),
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'your_first_hand_river',
        title: 'River card',
        phase: Act0LessonPhaseV1.drill,
        runner: _act0W01NewFirstHandStackContextV1(
          _act0FirstHandAkRunnerV1(_riverBoardRunner).copyWith(
            options: _act0AuthoredCorrectOptionAtV1(
              _riverBoardRunner.options,
              correctOptionId: 'five',
              correctIndex: 0,
            ),
          ),
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
                feedbackTitle: 'Compare the two pairs.',
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
        runner: _act0W01NewFirstHandStackContextV1(
          _act0FirstHandAkRunnerV1(_actionTrailRunner, history: true).copyWith(
            options: _act0AuthoredCorrectOptionAtV1(
              _actionTrailRunner.options,
              correctOptionId: 'bb_check',
              correctIndex: 1,
            ),
          ),
          earlierFlop: true,
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
    runner: _potStackRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'what_poker_is_pot_stack',
        title: 'Pot and stack',
        phase: Act0LessonPhaseV1.theory,
        runner: _potStackRunner,
        rewardXp: 4,
        stepKind: Act0LessonStepKindV1.learn,
        summary:
            'Separate chips in the middle from chips that still belong to a player.',
      ),
      Act0LessonTaskV1(
        taskId: 'what_poker_is_all_in_meaning',
        title: 'All-in meaning',
        phase: Act0LessonPhaseV1.drill,
        runner: _allInMeaningRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _allInMeaningRunner.options,
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
        runner: _matchedChipsTransferRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _matchedChipsTransferRunner.options,
            correctOptionId: 'matched_amount_only',
            correctIndex: 2,
          ),
        ),
        rewardXp: 4,
        stepKind: Act0LessonStepKindV1.proveIt,
        taskFamily: Act0TaskFamilyV1.transfer,
        summary:
            'A short stack can only win the chips that were actually matched in front of it.',
      ),
      Act0LessonTaskV1(
        taskId: 'what_poker_is_win_ways',
        title: 'How pots are won',
        phase: Act0LessonPhaseV1.drill,
        runner: _winWaysRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _winWaysRunner.options,
            correctOptionId: 'everyone_folds',
            correctIndex: 2,
          ),
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
        runner: _w1LiveWinTransferRunner,
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
        runner: _tableRecapRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _tableRecapRunner.options,
            correctOptionId: 'pot_committed_chips',
            correctIndex: 2,
          ),
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
        runner: _showdownIntroRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _showdownIntroRunner.options,
            correctOptionId: 'win_now',
            correctIndex: 1,
          ),
        ),
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'showdown_foldout_drill',
        title: 'Everyone else folds',
        phase: Act0LessonPhaseV1.drill,
        runner: _showdownRunner.copyWith(
          caption: 'The final player facing your bet folds.',
          question:
              'What happens when the last other player folds before showing any cards?',
          options: _act0AuthoredCorrectOptionAtV1(
            _foldoutChoices,
            correctOptionId: 'win_now',
            correctIndex: 1,
          ),
          table: _showdownRunner.table.copyWith(
            handContributions: _act0FoldoutPot,
            heroCards: const [
              Act0CardStateV1(rank: 'J', suit: 'h'),
              Act0CardStateV1(rank: 'J', suit: 's'),
            ],
          ),
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
              Act0CardStateV1(rank: 'Q', suit: 'h'),
              Act0CardStateV1(rank: 'Q', suit: 's'),
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
              preferredLabel: 'You · Q-Q-Q-K-8',
              quality: Act0FeedbackQualityV1.wrong,
              feedbackTitle: 'Compare three of a kind with a pair.',
              feedbackReason:
                  'The other player makes a pair of kings. Your three queens rank higher.',
            ),
            Act0RunnerOptionV1(
              id: 'hero_cards_only',
              label: 'You · Q-Q-Q-K-4',
              isCorrect: false,
              preferredLabel: 'You · Q-Q-Q-K-8',
              quality: Act0FeedbackQualityV1.wrong,
              feedbackTitle: 'Use the better side card.',
              feedbackReason:
                  'You win with three queens. The eight plays instead of the four.',
            ),
            Act0RunnerOptionV1(
              id: 'best_hand',
              label: 'You · Q-Q-Q-K-8',
              isCorrect: true,
              preferredLabel: 'You · Q-Q-Q-K-8',
              quality: Act0FeedbackQualityV1.correct,
              feedbackTitle: 'Your three queens win.',
              feedbackReason:
                  'Your two queens and the queen on the board make three of a kind. The king and eight complete your best five.',
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
        runner: _boardPlaysRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _boardPlaysRunner.options,
            correctOptionId: 'tie',
            correctIndex: 1,
          ),
        ),
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.fixMistakes,
        taskFamily: Act0TaskFamilyV1.compare,
      ),
      Act0LessonTaskV1(
        taskId: 'showdown_tie_drill',
        title: 'Tie the pot',
        phase: Act0LessonPhaseV1.drill,
        runner: _tiePotRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _tiePotRunner.options,
            correctOptionId: 'split',
            correctIndex: 1,
          ),
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
        runner: _world2PositionIntroRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w2_late_position',
        title: 'Late seat',
        phase: Act0LessonPhaseV1.drill,
        runner: _latePositionRunner.copyWith(
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
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w2_early_position',
        title: 'Early seat',
        phase: Act0LessonPhaseV1.drill,
        runner: _act0NeutralSeatAssessmentPreservingTeachingV1(
          _earlyLatePositionRunner,
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
        runner: _world3SameHandIntroRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w3_same_hand_open',
        title: 'Open frame',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3CutoffOpenRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w3_same_hand_call',
        title: 'Players behind',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3CutoffCallRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _world3CutoffCallRunner.options,
            correctOptionId: 'players_behind',
            correctIndex: 1,
          ),
        ),
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w3_same_hand_recap',
        title: 'Frame recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world3SameHandRecapRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _world3SameHandRecapRunner.options,
            correctOptionId: 'framework',
            correctIndex: 1,
          ),
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
        runner: _world2StrongContinueRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _world2StrongContinueRunner.options,
            correctOptionId: 'call',
            correctIndex: 1,
          ),
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
    runner: _world3BucketsIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'hand_discipline_buckets_intro',
        title: 'Four buckets',
        phase: Act0LessonPhaseV1.theory,
        runner: _world3BucketsIntroRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'hand_discipline_buckets_premium',
        title: 'Premium hand',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3PremiumBucketRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'hand_discipline_buckets_strong',
        title: 'Strong hand',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1StrongBucketRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _w1StrongBucketRunner.options,
            correctOptionId: 'strong',
            correctIndex: 1,
          ),
        ),
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'hand_discipline_buckets_medium',
        title: 'Medium hand',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1MediumBucketRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _w1MediumBucketRunner.options,
            correctOptionId: 'medium',
            correctIndex: 2,
          ),
        ),
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'hand_discipline_buckets_trash',
        title: 'Weak hand',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3TrashBucketRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _world3TrashBucketRunner.options,
            correctOptionId: 'trash',
            correctIndex: 1,
          ),
        ),
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'hand_discipline_buckets_borderline',
        title: 'Borderline hand',
        phase: Act0LessonPhaseV1.drill,
        runner: _w2BorderlineBucketRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _w2BorderlineBucketRunner.options,
            correctOptionId: 'medium',
            correctIndex: 1,
          ),
        ),
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'hand_discipline_buckets_recap',
        title: 'Bucket recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world3BucketsRecapRunner,
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
        runner: _act0W01ExplicitFoldMechanicalContextV1(_foldActionRunner).copyWith(
          question: 'If you choose to exit this hand, which action does that?',
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
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'early_fold',
        title: 'Early weak hand',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3EarlyFoldRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _world3EarlyFoldRunner.options,
            correctOptionId: 'fold',
            correctIndex: 1,
          ),
        ),
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'facing_fold',
        title: 'Facing pressure',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3WeakFacingFoldRunner,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'discipline_stack_protect',
        title: 'Protect stack',
        phase: Act0LessonPhaseV1.drill,
        runner: _act0WeakAcePriceContrastV1(3),
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
    sourceTasks: _preflopBasicsLessons[5].taskList,
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
        ),
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'weak_ace_kicker_compare',
        title: 'A7 vs KQ spot',
        phase: Act0LessonPhaseV1.drill,
        runner: _world2KqoContrastRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _world2KqoContrastRunner.options,
            correctOptionId: 'less_dominated',
            correctIndex: 1,
          ),
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
        runner: _world3BucketsIntroRunner.copyWith(
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
        runner: _world3PremiumBucketRunner.copyWith(
          caption: 'You hold a pair of queens.',
          table: _world3PremiumBucketRunner.table.copyWith(
            heroCards: const <Act0CardStateV1>[
              Act0CardStateV1(rank: 'Q', suit: 's'),
              Act0CardStateV1(rank: 'Q', suit: 'h'),
            ],
            centerLabel: '',
          ),
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
                  'A pair of queens is in the Premium group of the chart.',
            ),
            Act0RunnerOptionV1(
              id: 'medium',
              label: 'Medium',
              isCorrect: false,
              preferredLabel: 'Premium',
              quality: Act0FeedbackQualityV1.wrong,
              feedbackTitle: 'Check the top of the chart.',
              feedbackReason:
                  'The Medium group has lower pairs. The Premium group includes queens.',
            ),
          ],
          teachingSteps: const <Act0TeachingStepV1>[],
        ),
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'medium_open',
        title: 'Medium hand opens',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1MediumOpenRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _w1MediumOpenRunner.options,
            correctOptionId: 'raise',
            correctIndex: 1,
          ),
        ),
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'weak_let_go',
        title: 'Weak let go',
        phase: Act0LessonPhaseV1.drill,
        runner: _act0WeakHandAfterRaiseContrastV1(
          _world3WeakFacingFoldRunner,
          handName: 'jack-seven offsuit',
          cards: const [
            Act0CardStateV1(rank: 'J', suit: 's'),
            Act0CardStateV1(rank: '7', suit: 'd'),
          ],
          correctIndex: 0,
        ),
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'medium_call_or_fold',
        title: 'Medium facing open',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3PlayableCallRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _world3PlayableCallRunner.options,
            correctOptionId: 'call',
            correctIndex: 1,
          ),
        ),
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'continue_recap',
        title: 'Continue recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world3FacingOpenRecapRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _world3FacingOpenRecapRunner.options,
            correctOptionId: 'call',
            correctIndex: 1,
          ),
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
    runner: _w1DisciplineApplyIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'apply_intro',
        title: 'Three-step habit',
        phase: Act0LessonPhaseV1.theory,
        runner: _w1DisciplineApplyIntroRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'apply_utg_fold',
        title: 'UTG, trash hand',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1DisciplineApplyEarlyFoldRunner,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.fixMistakes,
      ),
      Act0LessonTaskV1(
        taskId: 'apply_btn_open',
        title: 'BTN, medium hand',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1DisciplineApplyLateOpenRunner,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.fixMistakes,
      ),
      Act0LessonTaskV1(
        taskId: 'apply_hj_decision',
        title: 'HJ, medium hand',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1DisciplineApplyHjMediumRunner,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.fixMistakes,
      ),
      Act0LessonTaskV1(
        taskId: 'apply_recap',
        title: 'Discipline holds',
        phase: Act0LessonPhaseV1.review,
        runner: _act0WeakHandAfterRaiseContrastV1(
          _world3DominatedRecapRunner,
          handName: 'ace-three offsuit',
          cards: const [
            Act0CardStateV1(rank: 'A', suit: 's'),
            Act0CardStateV1(rank: '3', suit: 'd'),
          ],
          correctIndex: 0,
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
        runner: _world3BucketsRecapRunner.copyWith(
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
        runner: _world3PremiumBucketRunner.copyWith(
          caption: 'You hold a pair of kings.',
          table: _world3PremiumBucketRunner.table.copyWith(
            heroCards: const <Act0CardStateV1>[
              Act0CardStateV1(rank: 'K', suit: 's'),
              Act0CardStateV1(rank: 'K', suit: 'h'),
            ],
            centerLabel: '',
          ),
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
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'checkpoint_fold',
        title: 'Disciplined fold',
        phase: Act0LessonPhaseV1.drill,
        runner: _act0WeakAcePriceContrastV1(4),
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'checkpoint_borderline_continue',
        title: 'Borderline continue',
        phase: Act0LessonPhaseV1.drill,
        runner: _world2BorderlineContinueRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'checkpoint_table_discipline',
        title: 'Real-table discipline read',
        phase: Act0LessonPhaseV1.drill,
        runner: _w2DisciplineTableNoticeRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'checkpoint_review',
        title: 'Discipline recap',
        phase: Act0LessonPhaseV1.review,
        runner: _w1DisciplineCheckpointRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _w1DisciplineCheckpointRunner.options,
            correctOptionId: 'seat_context',
            correctIndex: 1,
          ),
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
    rewardXp: 30,
    runner: _w3SixSeatsIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'position_six_seats_positions_theory',
        title: 'Six seat labels',
        phase: Act0LessonPhaseV1.theory,
        runner: _w3SixSeatsIntroRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'position_six_seats_positions_utg',
        title: 'Find UTG',
        phase: Act0LessonPhaseV1.drill,
        runner: _w3SeatIdUtgRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _w3SeatIdUtgRunner.options,
            correctOptionId: 'utg',
            correctIndex: 1,
          ),
        ),
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'position_six_seats_hj_co_contrast',
        title: 'HJ or CO',
        phase: Act0LessonPhaseV1.drill,
        runner: _w3SeatIdHjRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _w3SeatIdHjRunner.options,
            correctOptionId: 'hj',
            correctIndex: 1,
          ),
        ),
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'position_six_seats_positions_cutoff',
        title: 'Find CO',
        phase: Act0LessonPhaseV1.drill,
        runner: _w3SeatIdCoRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'position_six_seats_positions_button',
        title: 'Find BTN',
        phase: Act0LessonPhaseV1.drill,
        runner: _w3SeatIdBtnRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'position_six_seats_sb_recognition',
        title: 'Find SB',
        phase: Act0LessonPhaseV1.drill,
        runner: _w3SeatIdSbRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _w3SeatIdSbRunner.options,
            correctOptionId: 'sb',
            correctIndex: 1,
          ),
        ),
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'position_six_seats_bb_recognition',
        title: 'Find BB',
        phase: Act0LessonPhaseV1.drill,
        runner: _w3SeatIdBbRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _w3SeatIdBbRunner.options,
            correctOptionId: 'bb',
            correctIndex: 1,
          ),
        ),
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'position_six_seats_position_repair_seat_id_btn',
        repairOnly: true,
        title: 'Repair BTN seat',
        phase: Act0LessonPhaseV1.drill,
        runner: _w3SeatIdBtnRepairRunner,
        rewardXp: 4,
        stepKind: Act0LessonStepKindV1.fixMistakes,
      ),
      Act0LessonTaskV1(
        taskId: 'position_six_seats_position_repair_seat_id_utg',
        repairOnly: true,
        title: 'Repair UTG seat',
        phase: Act0LessonPhaseV1.drill,
        runner: _w3SeatIdUtgRepairRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _w3SeatIdUtgRepairRunner.options,
            correctOptionId: 'utg',
            correctIndex: 1,
          ),
        ),
        rewardXp: 4,
        stepKind: Act0LessonStepKindV1.fixMistakes,
      ),
      Act0LessonTaskV1(
        taskId: 'position_six_seats_positions_review',
        title: 'Six-seat recap',
        phase: Act0LessonPhaseV1.review,
        runner: _w3SixSeatsRecapRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _w3SixSeatsRecapRunner.options,
            correctOptionId: 'six_seats',
            correctIndex: 1,
          ),
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
    rewardXp: 35,
    sourceTasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'button_intro',
        title: 'Best seat',
        phase: Act0LessonPhaseV1.theory,
        runner: _world2PositionIntroRunner.copyWith(
          question:
              'Which seat gets to see CO act on the first pass after the flop?',
          options: _laterSeatChoices,
        ),
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'find_button',
        title: 'Tap BTN',
        phase: Act0LessonPhaseV1.drill,
        runner: _buttonSeatRunner.copyWith(
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
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'button_open',
        title: 'BTN first-in open',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3ButtonOpenRunner,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'button_last',
        title: 'Acts last',
        phase: Act0LessonPhaseV1.drill,
        runner: _postflopButtonActorRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'button_vs_cutoff',
        title: 'BTN vs CO',
        phase: Act0LessonPhaseV1.drill,
        runner: _w3LateSeatContrastRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _w3LateSeatContrastRunner.options,
            correctOptionId: 'btn',
            correctIndex: 1,
          ),
        ),
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'button_recap',
        title: 'Button recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world2PositionRecapRunner.copyWith(
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
        runner: _w3BtnLastPostflopRepairRunner,
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
        runner: _w3EarlySeatPressureRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _w3EarlySeatPressureRunner.options,
            correctOptionId: 'more_players_behind',
            correctIndex: 1,
          ),
        ),
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'position_repair_utg_players_behind',
        repairOnly: true,
        title: 'Repair UTG pressure',
        phase: Act0LessonPhaseV1.drill,
        runner: _w3UtgPlayersBehindRepairRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _w3UtgPlayersBehindRepairRunner.options,
            correctOptionId: 'five_players_behind',
            correctIndex: 1,
          ),
        ),
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.fixMistakes,
      ),
      Act0LessonTaskV1(
        taskId: 'late_info_choice',
        title: 'Late info edge',
        phase: Act0LessonPhaseV1.drill,
        runner: _w3LateInfoEdgeRunner,
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
        runner: _world3PositionDisciplineRunner,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'same_hand_late_open',
        title: 'Late seat open',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3LateOpenRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _world3LateOpenRunner.options,
            correctOptionId: 'raise',
            correctIndex: 1,
          ),
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
        runner: _w3PositionApplyIntroRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'position_apply_btn_open',
        title: 'BTN: open strong hand',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3ButtonOpenQtsRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _world3ButtonOpenQtsRunner.options,
            correctOptionId: 'raise',
            correctIndex: 1,
          ),
        ),
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'position_apply_late_open',
        title: 'Late: open or limp?',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3LateOpenRunner.copyWith(
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
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'position_apply_early_fold',
        title: 'Early: AQo first in',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3PositionDisciplineRunner.copyWith(
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
                  'The Sharky starting chart opens AQo from HJ or later. Fold it from UTG here. Experienced players sometimes open AQo from earlier seats.',
            ),
            Act0RunnerOptionV1(
              id: 'raise',
              label: 'Raise',
              isCorrect: false,
              preferredLabel: 'Fold',
              quality: Act0FeedbackQualityV1.wrong,
              feedbackTitle: 'Find the first seat for AQo.',
              feedbackReason:
                  'AQo can raise from HJ by the Sharky starting chart, but UTG acts before HJ.',
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
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.fixMistakes,
      ),
      Act0LessonTaskV1(
        taskId: 'position_apply_hj_fold',
        title: 'HJ: discipline hold',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3HijDisciplineRunner.copyWith(
          table: _world3HijDisciplineRunner.table.copyWith(
            highlightedSeatIds: const ['hj'],
          ),
          options: _act0AuthoredCorrectOptionAtV1(
            _world3HijDisciplineRunner.options,
            correctOptionId: 'fold',
            correctIndex: 1,
          ),
        ),
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.fixMistakes,
      ),
      Act0LessonTaskV1(
        taskId: 'position_apply_recap',
        title: 'Position apply recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world3LateOpenRunner.copyWith(
          caption: 'Folded to BTN with AJo.',
          hint: 'Find your hand and seat in the chart.',
          table: _world3LateOpenRunner.table.copyWith(
            heroCards: const <Act0CardStateV1>[
              Act0CardStateV1(rank: 'A', suit: 'd'),
              Act0CardStateV1(rank: 'J', suit: 'c'),
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
        rewardXp: 16,
        stepKind: Act0LessonStepKindV1.proveIt,
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
        runner: _world2PositionIntroRunner.copyWith(
          question:
              'Which of these seats sees HJ act before making its own first decision before the flop?',
          options: _laterSeatChoices,
        ),
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'position_checkpoint_late_open',
        title: 'Late: open or limp?',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3LateOpenRunner.copyWith(
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
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'position_checkpoint_early_fold',
        title: 'Early: A9o first in',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3CheckpointEarlyFoldRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _world3CheckpointEarlyFoldRunner.options,
            correctOptionId: 'fold',
            correctIndex: 1,
          ),
        ),
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'position_checkpoint_btn_call',
        title: 'BTN: callable spot',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3PositionCheckpointCallRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'position_checkpoint_table_notice',
        title: 'Real-table seat read',
        phase: Act0LessonPhaseV1.drill,
        runner: _w3TablePositionNoticeRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _w3TablePositionNoticeRunner.options,
            correctOptionId: 'players_behind',
            correctIndex: 2,
          ),
        ),
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'position_checkpoint_review',
        title: 'Position recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world3LateOpenRunner.copyWith(
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
        runner: _world4ValuePurposeRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _world4ValuePurposeRunner.options,
            correctOptionId: 'value',
            correctIndex: 1,
          ),
        ),
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_bluff_purpose',
        title: 'Bluff reason',
        phase: Act0LessonPhaseV1.drill,
        runner: _world4BluffPurposeRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _world4BluffPurposeRunner.options,
            correctOptionId: 'bluff',
            correctIndex: 1,
          ),
        ),
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_purpose_recap',
        title: 'Purpose recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world4PurposeRecapRunner,
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
        runner: _world4SizingIntroRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_small_bet',
        title: 'One-third bet',
        phase: Act0LessonPhaseV1.drill,
        runner: _world4SmallBetRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _world4SmallBetRunner.options,
            correctOptionId: 'two',
            correctIndex: 1,
          ),
        ),
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.sizing,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_half_pot_bet',
        title: 'Half-pot bet',
        phase: Act0LessonPhaseV1.drill,
        runner: _world4HalfPotRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.sizing,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_pot_bet',
        title: 'Pot-size bet',
        phase: Act0LessonPhaseV1.drill,
        runner: _world4PotBetRunner,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.sizing,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_sizing_recap',
        title: 'Sizing recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world4SizingRecapRunner,
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
            correctIndex: 1,
          ),
        ),
        rewardXp: 8,
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
        runner: _world4ValueIntroRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_value_bet',
        title: 'Bet top pair',
        phase: Act0LessonPhaseV1.drill,
        runner: _world4ValueBetRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_value_missed',
        title: 'Do not hide value',
        phase: Act0LessonPhaseV1.drill,
        runner: _world4ValueCheckMissRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _world4ValueCheckMissRunner.options,
            correctOptionId: 'bet_half',
            correctIndex: 1,
          ),
        ),
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_value_recap',
        title: 'Value recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world4ValueRecapRunner,
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
        runner: _world4BluffIntroRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_bluff_pressure',
        title: 'Apply pressure',
        phase: Act0LessonPhaseV1.drill,
        runner: _world4BluffPressureRunner,
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
        taskId: 'w4_bluff_recap',
        title: 'Bluff recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world4BluffRecapRunner,
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
    rewardXp: 30,
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
            correctIndex: 1,
          ),
        ),
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_protection_recap',
        title: 'Protection recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world4ProtectionRecapRunner,
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
        runner: _world4CheckpointIntroRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_checkpoint_value',
        title: 'Value or bluff',
        phase: Act0LessonPhaseV1.drill,
        runner: _world4ValuePurposeRunner.copyWith(
          question:
              'If BB can have A-T or A-Q, which hand could call a 3 BB bet while behind yours?',
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
                  '3 ÷ (3 + 10) is about 23%. You win 1 time in 4, or 25%, so the call earns more.',
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
            correctIndex: 1,
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
        runner: _world4CheckpointRunner,
        rewardXp: 15,
        stepKind: Act0LessonStepKindV1.proveIt,
      ),
    ],
  ),
];

part of 'act0_shell_state_v1.dart';

final _w5TextureDryValueRunner = _world5DryBoardRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w5_texture_dry_value',
  caption:
      'BB checks. You want one more bet from a worse pair. A seven can call 2 BB, but folds to a larger bet.',
  hint: '',
  question: 'Which action gets a call from the weaker pair?',
  table: _day7PostflopV1(
    'co',
    'Jh Jd',
    'Qs 7c 2h',
    checkedToHero: true,
    showTurn: true,
  ),
  teachingSteps: const [],
  feedbackReason:
      "Bet 2 BB because BB calls with a pair of sevens, which your jacks beat. A bet of 6 BB makes that pair fold.",
  options: const [
    Act0RunnerOptionV1(
      id: 'check',
      label: 'Check',
      isCorrect: false,
      preferredLabel: 'Bet 2 BB',
      repairFocusCardIds: ['board_0', 'board_1', 'board_2'],
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Compare the board and price.',
      feedbackReason:
          "Checking misses the 2 BB that a worse pair pays on Q-7-2. Bet that size to collect it.",
    ),
    Act0RunnerOptionV1(
      id: 'two',
      label: 'Bet 2 BB',
      isCorrect: true,
      preferredLabel: 'Bet 2 BB',
      repairFocusCardIds: ['board_0', 'board_1', 'board_2'],
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Read the board and response.',
      feedbackReason:
          "Bet 2 BB because BB calls with a pair of sevens, which your jacks beat. A bet of 6 BB makes that pair fold.",
    ),
    Act0RunnerOptionV1(
      id: 'six',
      label: 'Bet 6 BB',
      isCorrect: false,
      preferredLabel: 'Bet 2 BB',
      repairFocusCardIds: ['board_0', 'board_1', 'board_2'],
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Compare the board and price.',
      feedbackReason:
          'A seven folds to a pot-size bet on this board, so betting 6 BB gives up the call you wanted.',
    ),
  ],
);

final _w5TextureWetShowdownRunner = _world5WetBoardRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w5_texture_wet_showdown',
  caption:
      'BB checks and will call a bet only with a straight or two pair or better.',
  hint: '',
  question: 'Which action fits a plan to bet only when a worse hand calls?',
  table: _day7PostflopV1(
    'co',
    'Ac Ad',
    'Jh Th 9c',
    checkedToHero: true,
    showTurn: true,
  ),
  teachingSteps: const [],
  feedbackReason:
      "Check on J-T-9 because BB only calls with hands ahead of your aces. A bet of 2 BB pays to face straights or two pair.",
  options: const [
    Act0RunnerOptionV1(
      id: 'small',
      label: 'Bet 2 BB',
      isCorrect: false,
      preferredLabel: 'Check',
      repairFocusCardIds: ['board_0', 'board_1', 'board_2'],
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Compare the board and price.',
      feedbackReason:
          "The bet of 2 BB risks chips against straights or two pair, which already beat your aces. Check to keep your chips.",
    ),
    Act0RunnerOptionV1(
      id: 'large',
      label: 'Bet 6 BB',
      isCorrect: false,
      preferredLabel: 'Check',
      repairFocusCardIds: ['board_0', 'board_1', 'board_2'],
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Compare the board and price.',
      feedbackReason:
          "Betting 6 BB costs more while the only callers already beat your aces. Checking avoids putting those chips at risk.",
    ),
    Act0RunnerOptionV1(
      id: 'check',
      label: 'Check',
      isCorrect: true,
      preferredLabel: 'Check',
      repairFocusCardIds: ['board_0', 'board_1', 'board_2'],
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Read the board and response.',
      feedbackReason:
          "Check on J-T-9 because BB only calls with hands ahead of your aces. A bet of 2 BB pays to face straights or two pair.",
    ),
  ],
);

final _w5ConnectedReadBetRunner = _world5ConnectedBoardRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w5_connected_read_bet',
  caption:
      'BB bets 4 BB with a made straight. Continue only if your current hand is at least as strong.',
  hint: '',
  question: 'What will you do with ace-king?',
  table: _day7PostflopV1('co', 'As Kd', '9s 8c 7d', betBb: 4, showTurn: true),
  teachingSteps: const [],
  feedbackReason:
      "BB bets 4 BB with a straight on 9-8-7, so your ace-high falls short of the stated rule. Fold because a call pays with a weaker hand.",
  options: const [
    Act0RunnerOptionV1(
      id: 'fold',
      label: 'Fold',
      isCorrect: true,
      preferredLabel: 'Fold',
      repairFocusCardIds: ['board_0', 'board_1', 'board_2'],
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Read the board and response.',
      feedbackReason:
          "BB bets 4 BB with a straight on 9-8-7, so your ace-high falls short of the stated rule. Fold because a call pays with a weaker hand.",
    ),
    Act0RunnerOptionV1(
      id: 'call',
      label: 'Call',
      isCorrect: false,
      preferredLabel: 'Fold',
      repairFocusCardIds: ['board_0', 'board_1', 'board_2'],
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Compare the board and price.',
      feedbackReason:
          "Calling costs 4 BB with ace-high against the stated straight. Fold to keep those chips.",
    ),
    Act0RunnerOptionV1(
      id: 'raise',
      label: 'Raise',
      isCorrect: false,
      preferredLabel: 'Fold',
      repairFocusCardIds: ['board_0', 'board_1', 'board_2'],
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Compare the board and price.',
      feedbackReason:
          'A raise risks more than 4 BB with a hand below the stated continuation threshold. Ace-high still trails the straight.',
    ),
  ],
);

final _boardDrawsLessons = <Act0LessonCardV1>[
  _lessonFromTasksV1(
    lessonId: 'board_texture_basics',
    title: 'Dry or wet board',
    subtitle: 'Start by asking how much the board can change.',
    phaseLabel: 'Texture',
    rewardXp: 35,
    sourceTasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w5_texture_intro',
        title: 'Board texture',
        phase: Act0LessonPhaseV1.theory,
        runner: _world5TextureIntroRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w5_dry_board',
        title: 'Two ways a flop can change',
        phase: Act0LessonPhaseV1.drill,
        runner: _world5DryBoardRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w5_wet_board',
        title: 'Read another flop',
        phase: Act0LessonPhaseV1.drill,
        runner: _world5WetBoardRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _world5WetBoardRunner.options,
            correctOptionId: 'wet',
            correctIndex: 1,
          ),
        ),
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w5_texture_dry_value',
        title: 'Dry flop bet size',
        phase: Act0LessonPhaseV1.drill,
        runner: _w5TextureDryValueRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w5_texture_wet_showdown',
        title: 'Wet flop, protect your stack',
        phase: Act0LessonPhaseV1.drill,
        runner: _w5TextureWetShowdownRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w5_texture_recap',
        title: 'Texture recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world5TextureRecapRunner,
        rewardXp: 12,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  _lessonFromTasksV1(
    lessonId: 'connected_boards',
    title: 'Connected boards',
    subtitle: 'Connected ranks create more ways to improve.',
    phaseLabel: 'Connected',
    rewardXp: 51,
    sourceTasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w5_connected_intro',
        title: 'Connected ranks',
        phase: Act0LessonPhaseV1.theory,
        runner: _world5ConnectedIntroRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w5_disconnected_board',
        title: 'Read the rank gaps',
        phase: Act0LessonPhaseV1.drill,
        runner: _world5DisconnectedBoardRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w5_connected_board',
        title: 'Read the next flop',
        phase: Act0LessonPhaseV1.drill,
        runner: _world5ConnectedBoardRunner,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w5_connected_read_bet',
        title: 'Connected flop against a straight',
        phase: Act0LessonPhaseV1.drill,
        runner: _w5ConnectedReadBetRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: "w5_raise_read_guided",
        title: "Read the raise on three spades",
        phase: Act0LessonPhaseV1.drill,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
        runner:
            _day7ExampleV1(
              5,
              "connected_boards",
              "w5_raise_read_guided",
              _day7PostflopV1(
                'co',
                '9d 9h',
                'Ks 7s 2s',
                heroLeadBb: 3,
                betBb: 9,
                showTurn: true,
              ),
              caption:
                  "On a monotone flop this BB usually calls with one pair and raises strong made hands.",
              question: "After the raise, which group becomes more likely?",
              choices: const [
                "One small pair",
                "A made flush",
                "Unpaired cards without a spade",
              ],
              correct: 1,
              reason:
                  "BB raises strong made hands on the three-spade flop, so a flush becomes more likely. One pair more often calls.",
              wrongReasons: const {
                0: "Small pairs tend to call here. With three spades showing, a raise makes a made flush more likely.",
                2: "BB seldom raises hands that missed in this model. Assuming a weak hand risks paying a flush.",
              },
            ).task.runner.copyWith(
              hint: "First ask what two spades would make.",
              hintPolicy: Act0HintPolicyV1.always,
            ),
      ),
      Act0LessonTaskV1(
        taskId: "w5_raise_read_repeat",
        title: "Price after a turn raise",
        phase: Act0LessonPhaseV1.drill,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
        runner: _day7ExampleV1(
          5,
          "connected_boards",
          "w5_raise_read_repeat",
          _day7PostflopV1(
            'co',
            'Ah Qh',
            'Kh 8h 5c 2s',
            heroLeadBb: 3,
            betBb: 9,
            showTurn: true,
          ),
          caption:
              "Assume BB calls a reraise. Nine hearts win and every other river loses. No more bets after this round.",
          question: "What earns most now?",
          choices: const ["Call", "Fold", "Raise to 18 BB"],
          correct: 1,
          reason:
              "BB raised, so calling 6 BB makes a 24 BB pot and needs 25%. Fold because nine wins out of 46 are only about 20%.",
          wrongReasons: const {
            0: "Calling costs 6 BB for 24 BB in the middle. Nine wins out of 46 falls short of the price, so fold.",
            2: "A raise to 18 BB costs another 15 BB and BB calls in the model. Folding keeps the chips you would risk on a draw.",
          },
        ).task.runner,
      ),
      Act0LessonTaskV1(
        taskId: 'w5_connected_recap',
        title: 'Connected recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world5ConnectedRecapRunner,
        rewardXp: 12,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  _lessonFromTasksV1(
    lessonId: 'flush_draws',
    title: 'Flush draws',
    subtitle: 'Three or four cards of a suit make suit pressure visible.',
    phaseLabel: 'Flush draw',
    rewardXp: 35,
    extraDrills: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w5_made_hand_vs_flush_draw_transfer',
        title: 'Made hand or future pressure',
        phase: Act0LessonPhaseV1.drill,
        runner: _world5MadeHandVsFlushDrawTransferRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.proveIt,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'w5_flush_draw_recheck_transfer',
        title: 'Find your draw',
        phase: Act0LessonPhaseV1.drill,
        runner: _world5FlushDrawRecheckTransferRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _world5FlushDrawRecheckTransferRunner.options,
            correctOptionId: 'flush_draw_only',
            correctIndex: 1,
          ),
        ),
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.proveIt,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
    ],
    sourceTasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w5_flush_intro',
        title: 'Same suit pressure',
        phase: Act0LessonPhaseV1.theory,
        runner: _world5FlushIntroRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w5_flush_draw_find',
        title: 'Count the matching suits',
        phase: Act0LessonPhaseV1.drill,
        runner: _world5FlushDrawRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _world5FlushDrawRunner.options,
            correctOptionId: 'flush_draw',
            correctIndex: 2,
          ),
        ),
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w5_no_flush_draw',
        title: 'Read the suits',
        phase: Act0LessonPhaseV1.drill,
        runner: _world5NoFlushDrawRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _world5NoFlushDrawRunner.options,
            correctOptionId: 'no',
            correctIndex: 1,
          ),
        ),
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w5_flush_recap',
        title: 'Flush recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world5FlushRecapRunner,
        rewardXp: 12,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  _lessonFromTasksV1(
    lessonId: 'straight_draws',
    title: 'Straight draws',
    subtitle: 'Neighboring ranks can point to a straight.',
    phaseLabel: 'Straight draw',
    rewardXp: 35,
    extraDrills: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w5_gutshot_contrast_transfer',
        title: 'Read another straight draw',
        phase: Act0LessonPhaseV1.drill,
        runner: _world5GutshotContrastTransferRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.proveIt,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
    ],
    sourceTasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w5_straight_intro',
        title: 'Rank ladder',
        phase: Act0LessonPhaseV1.theory,
        runner: _world5StraightIntroRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w5_straight_draw_find',
        title: 'Read the four ranks',
        phase: Act0LessonPhaseV1.drill,
        runner: _world5StraightDrawRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w5_gap_board',
        title: 'Read the gaps',
        phase: Act0LessonPhaseV1.drill,
        runner: _world5GapBoardRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _world5GapBoardRunner.options,
            correctOptionId: 'no',
            correctIndex: 1,
          ),
        ),
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w5_gutshot_draw',
        title: 'Which rank fits?',
        phase: Act0LessonPhaseV1.drill,
        runner: _world5GutshotDrawRunner,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w5_straight_recap',
        title: 'Straight recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world5StraightRecapRunner,
        rewardXp: 12,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  _lessonFromTasksV1(
    lessonId: 'outs_improvement',
    title: 'Outs as improvement cards',
    subtitle: 'Outs are cards that can improve a hand.',
    phaseLabel: 'Outs',
    rewardXp: 35,
    extraDrills: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w5_table_outs_flush_transfer',
        title: 'Flush draw and price',
        phase: Act0LessonPhaseV1.drill,
        runner: _world5TableOutsFlushTransferRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _world5TableOutsFlushTransferRunner.options,
            correctOptionId: 'heart_outs',
            correctIndex: 1,
          ),
        ),
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.proveIt,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'w5_clean_vs_risky_out_transfer',
        title: 'Safer out or risky out',
        phase: Act0LessonPhaseV1.drill,
        runner: _world5CleanVsRiskyOutTransferRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _world5CleanVsRiskyOutTransferRunner.options,
            correctOptionId: 'five_clubs_cleaner',
            correctIndex: 2,
          ),
        ),
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.proveIt,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'w5_table_outs_straight_transfer',
        title: 'Straight draw and price',
        phase: Act0LessonPhaseV1.drill,
        runner: _world5TableOutsStraightTransferRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _world5TableOutsStraightTransferRunner.options,
            correctOptionId: 'four_or_nine',
            correctIndex: 0,
          ),
        ),
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.proveIt,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
    ],
    sourceTasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w5_outs_intro',
        title: 'Improvement cards',
        phase: Act0LessonPhaseV1.theory,
        runner: _world5OutsIntroRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w5_flush_out',
        title: 'Which suit helps?',
        phase: Act0LessonPhaseV1.drill,
        runner: _world5FlushOutRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _world5FlushOutRunner.options,
            correctOptionId: 'heart',
            correctIndex: 1,
          ),
        ),
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w5_straight_out',
        title: 'Which rank helps?',
        phase: Act0LessonPhaseV1.drill,
        runner: _world5StraightOutRunner,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w5_outs_recap',
        title: 'Outs recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world5OutsRecapRunner,
        rewardXp: 12,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  _lessonFromTasksV1(
    lessonId: 'w5_semi_bluff',
    title: 'Bet with a draw',
    subtitle: 'Weigh the chance of folds and winning rivers.',
    phaseLabel: 'Semi-bluff',
    rewardXp: 30,
    sourceTasks: [
      Act0LessonTaskV1(
        taskId: 'intro',
        title: 'Two ways to win',
        phase: Act0LessonPhaseV1.theory,
        runner: _world5OutsIntroRunner.copyWith(
          caption: 'You have a draw on the turn.',
          question: 'When can a bet earn more than a check?',
          table: _day7PostflopV1(
            'co',
            'As 8s',
            'Qs 6s 2d Tc',
            checkedToHero: true,
            showTurn: true,
          ),
          options: const [],
          feedbackReason:
              'A bet with a draw can win on a fold or when the draw completes.',
          teachingSteps: const [
            Act0TeachingStepV1(
              title: 'Two ways to win.',
              body:
                  'A semi-bluff is a bet with a draw. It can win when a better hand folds, '
                  'or later when your draw hits. Checking gets the next card free. '
                  'Compare what each choice wins and loses on average. '
                  'Checking can earn the pot if the draw hits. '
                  'When you bet, a fold wins the chips already in the middle. '
                  'A call gives you a chance to win a bigger pot and costs you the bet when you miss. '
                  'Count each good river once, even if it completes two draws.',
            ),
          ],
        ),
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: "flush_draw",
        title: "Bet the flush draw",
        phase: Act0LessonPhaseV1.drill,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
        runner: _day7ExampleV1(
          5,
          "w5_semi_bluff",
          "flush_draw",
          _day7PostflopV1(
            'co',
            'Ah 7h',
            'Kh 9h 4s 2c',
            checkedToHero: true,
            showTurn: true,
          ),
          caption:
              "BB always calls 1 BB and folds to 3 BB on a third of hands. Nine rivers win either way. No more bets or ties.",
          question: "Which play earns most?",
          choices: const ["Check", "Bet 3 BB", "Bet 1 BB"],
          correct: 1,
          reason:
              "Bet 3 BB. BB’s folds and nine winning rivers make the bet worth about 1.57 BB on average. Checking earns about 1.17 BB.",
          wrongReasons: const {
            0: "Checking leaves only nine winning rivers, worth about 1.17 BB on average. A bet of 3 BB can win immediately too.",
            2: "BB always calls 1 BB, so that bet costs an extra chip on the rivers you miss. The 3 BB bet can win by getting a fold.",
          },
        ).task.runner,
      ),
      Act0LessonTaskV1(
        taskId: "combo_draw",
        title: "Two draws, fewer folds",
        phase: Act0LessonPhaseV1.drill,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
        runner: _day7ExampleV1(
          5,
          "w5_semi_bluff",
          "combo_draw",
          _day7PostflopV1(
            'co',
            'Jh 8h',
            'Th 7s 4h 2c',
            checkedToHero: true,
            showTurn: true,
          ),
          caption:
              "BB always calls 1 BB and folds 20% of the time to 3 BB. A flush or straight wins. Other rivers lose. No more bets.",
          question: "Which play earns most?",
          choices: const ["Bet 1 BB", "Check", "Bet 3 BB"],
          correct: 1,
          reason:
              "Nine hearts and four nines share one card, so you have 12 outs. Check for about 1.57 BB on average. BB folds too rarely for a bet of 3 BB to beat it.",
          wrongReasons: const {
            0: "A bet of 1 BB never gets a fold here, so it costs a chip on most rivers. Checking sees the same river for free.",
            2: "BB folds too rarely for a bet of 3 BB to pay more than a check. The bet earns about 1.30 BB on average against about 1.57 BB for checking.",
          },
        ).task.runner,
      ),
      Act0LessonTaskV1(
        taskId: "short_draw",
        title: "A draw against a short stack",
        phase: Act0LessonPhaseV1.drill,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
        runner: _day7ExampleV1(
          5,
          "w5_semi_bluff",
          "short_draw",
          _day7PostflopV1(
            'co',
            'As 7s',
            'Kd 9s 4s 2c',
            checkedToHero: true,
            opponentStartingBb: 4.75,
            showTurn: true,
          ),
          caption:
              "BB has 2 BB left and calls either bet. With 100 BB it would fold to 3 BB on a third of hands. Nine spades win. Other rivers lose. No more bets.",
          question: "Which play earns most?",
          choices: const ["Check", "Bet 2 BB", "Bet 1 BB"],
          correct: 0,
          reason:
              "Check because BB always calls with its last 2 BB or less and you miss 37 of 46 rivers. A bet of 1 BB pays more for the same draw.",
          wrongReasons: const {
            1: "A bet of 2 BB gets called and costs the most on the 37 misses. Checking keeps the same chance of taking the chips in the middle.",
            2: "Even a bet of 1 BB costs more on misses when BB always calls. Checking earns about 0.61 BB more on average.",
          },
        ).task.runner,
      ),
    ],
  ),
  _lessonFromTasksV1(
    lessonId: 'turn_river_changes',
    title: 'Turn and river changes',
    subtitle: 'Later streets can complete or miss a draw.',
    phaseLabel: 'Street changes',
    rewardXp: 40,
    extraDrills: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w5_turn_texture_shift_transfer',
        title: 'Checkpoint: the new turn card',
        phase: Act0LessonPhaseV1.drill,
        runner: _world5TurnTextureShiftTransferRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _world5TurnTextureShiftTransferRunner.options,
            correctOptionId: 'board_got_wetter',
            correctIndex: 1,
          ),
        ),
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.proveIt,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'w5_river_draw_story_transfer',
        title: 'Checkpoint: the last card',
        phase: Act0LessonPhaseV1.drill,
        runner: _world5RiverDrawStoryTransferRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _world5RiverDrawStoryTransferRunner.options,
            correctOptionId: 'draw_missed_story',
            correctIndex: 2,
          ),
        ),
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.proveIt,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
    ],
    sourceTasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w5_street_change_intro',
        title: 'One new card',
        phase: Act0LessonPhaseV1.theory,
        runner: _world5StreetChangeIntroRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w5_turn_hits',
        title: 'Checkpoint: check the turn',
        phase: Act0LessonPhaseV1.drill,
        runner: _world5TurnHitsRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _world5TurnHitsRunner.options,
            correctOptionId: 'draw_hit',
            correctIndex: 1,
          ),
        ),
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w5_river_misses',
        title: 'Checkpoint: check the river',
        phase: Act0LessonPhaseV1.drill,
        runner: _world5RiverMissesRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _world5RiverMissesRunner.options,
            correctOptionId: 'draw_missed',
            correctIndex: 1,
          ),
        ),
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w5_street_repair',
        title: 'Repair the turn read',
        phase: Act0LessonPhaseV1.drill,
        runner: _world5StreetRepairRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _world5StreetRepairRunner.options,
            correctOptionId: 'repair_story',
            correctIndex: 2,
          ),
        ),
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.fixMistakes,
        taskFamily: Act0TaskFamilyV1.repair,
        repairOnly: true,
      ),
      Act0LessonTaskV1(
        taskId: 'w5_board_checkpoint',
        title: 'Board checkpoint',
        phase: Act0LessonPhaseV1.review,
        runner: _world5DrawPriceCheckpointRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _world5DrawPriceCheckpointRunner.options,
            correctOptionId: 'texture_draw_outs',
            correctIndex: 1,
          ),
        ),
        rewardXp: 15,
        stepKind: Act0LessonStepKindV1.proveIt,
      ),
    ],
  ),
];

final _rangeThinkingLiteLessons = <Act0LessonCardV1>[
  Act0LessonCardV1(
    lessonId: 'range_bucket_basics',
    title: 'Range buckets',
    subtitle: 'Sort hands into value, bluff candidate, and missed buckets.',
    phaseLabel: 'Buckets',
    primaryCtaLabel: 'Locked',
    state: Act0LessonStateV1.locked,
    isLocked: true,
    isSelectable: false,
    rewardXp: 40,
    runner: _w6FromCutoff(_w6RangeIntroRunner),
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w6_range_intro',
        title: 'Three buckets',
        phase: Act0LessonPhaseV1.theory,
        runner: _w6FromCutoff(_w6RangeIntroRunner),
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w6_value_dry_board',
        title: 'Value on dry board',
        phase: Act0LessonPhaseV1.drill,
        runner: _w6FromCutoff(
          _w6ValueDryBoardRunner.copyWith(
            question: 'What can KQ do if weaker kings will call a small bet?',
            options: const [
              Act0RunnerOptionV1(
                id: 'value',
                label: 'Bet for value',
                isCorrect: true,
                preferredLabel: 'Bet for value',
                quality: Act0FeedbackQualityV1.correct,
                feedbackTitle: 'Top pair can bet for value.',
                feedbackReason:
                    "Bet KQ for value because BB can call with weaker kings on K-7-2. Checking misses the payment you can collect now.",
              ),
              Act0RunnerOptionV1(
                id: 'bluff',
                label: 'Bet as a bluff',
                isCorrect: false,
                preferredLabel: 'Bet for value',
                betterAnswerLabel: 'Bet for value',
                quality: Act0FeedbackQualityV1.wrong,
                feedbackTitle: 'Think about calls from weaker hands.',
                feedbackReason:
                    'KQ makes top pair on K-7-2. Treating the bet as a bluff misses why you want a weaker king to call.',
              ),
              Act0RunnerOptionV1(
                id: 'missed',
                label: 'Check because you missed',
                isCorrect: false,
                preferredLabel: 'Bet for value',
                betterAnswerLabel: 'Bet for value',
                quality: Act0FeedbackQualityV1.wrong,
                feedbackTitle: 'The king makes a pair.',
                feedbackReason:
                    'KQ shares a king with K-7-2. Treating it as a miss can give up a call from a weaker king.',
              ),
            ],
          ),
        ),
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w6_missed_dry_board',
        title: 'Missed on dry board',
        phase: Act0LessonPhaseV1.drill,
        runner: _w6MissedDryBoardRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w6_table_bucket_notice',
        title: 'First live read',
        phase: Act0LessonPhaseV1.drill,
        runner: _w6TableBucketNoticeRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _w6TableBucketNoticeRunner.options,
            correctOptionId: 'bucket_first',
            correctIndex: 2,
          ),
        ),
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w6_buckets_recap',
        title: 'Buckets recap',
        phase: Act0LessonPhaseV1.review,
        runner: _w6FromCutoff(_w6BucketsRecapRunner),
        rewardXp: 15,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'range_board_fit',
    title: 'Range meets board',
    subtitle: 'Board texture can shift a hand from value to missed.',
    phaseLabel: 'Board fit',
    primaryCtaLabel: 'Locked',
    state: Act0LessonStateV1.locked,
    isLocked: true,
    isSelectable: false,
    rewardXp: 40,
    runner: _w6FromCutoff(_w6BoardFitIntroRunner),
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w6_board_fit_intro',
        title: 'Board shifts bucket',
        phase: Act0LessonPhaseV1.theory,
        runner: _w6FromCutoff(_w6BoardFitIntroRunner),
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w6_wrong_board',
        title: 'Missed on wet board',
        phase: Act0LessonPhaseV1.drill,
        runner: _w6FromCutoff(_w6WrongBoardRunner),
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w6_value_wet_board',
        title: 'Compare ranges on a low flop',
        phase: Act0LessonPhaseV1.drill,
        runner: _w6ValueWetBoardRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w6_turn_shift_bucket',
        title: 'Turn changes bucket',
        phase: Act0LessonPhaseV1.drill,
        runner: _w6TurnShiftBucketRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _w6TurnShiftBucketRunner.options,
            correctOptionId: 'slide_missed',
            correctIndex: 2,
          ),
        ),
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w6_board_fit_recap',
        title: 'Compare ranges on a high flop',
        phase: Act0LessonPhaseV1.review,
        runner: _w6BoardFitRecapRunner,
        rewardXp: 15,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'range_pressure_lines',
    title: 'Value, bluff, missed',
    subtitle: 'Each bucket suggests a different action direction.',
    phaseLabel: 'Pressure',
    primaryCtaLabel: 'Locked',
    state: Act0LessonStateV1.locked,
    isLocked: true,
    isSelectable: false,
    rewardXp: 40,
    runner: _w6FromCutoff(_w6PressureLinesIntroRunner),
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w6_pressure_lines_intro',
        title: 'Bucket shapes action',
        phase: Act0LessonPhaseV1.theory,
        runner: _w6FromCutoff(_w6PressureLinesIntroRunner),
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w6_value_range_action',
        title: 'Value bets',
        phase: Act0LessonPhaseV1.drill,
        runner: _w6ValueRangeActionRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _w6ValueRangeActionRunner.options,
            correctOptionId: 'bet',
            correctIndex: 2,
          ),
        ),
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w6_bluff_candidate',
        title: 'When better hands fold',
        phase: Act0LessonPhaseV1.drill,
        runner: _w6BluffCandidateRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _w6BluffCandidateRunner.options,
            correctOptionId: 'bluff',
            correctIndex: 1,
          ),
        ),
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w6_missed_hand_action',
        title: 'Missed hand direction',
        phase: Act0LessonPhaseV1.drill,
        runner: _w6MissedHandActionRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _w6MissedHandActionRunner.options,
            correctOptionId: 'check_fold',
            correctIndex: 2,
          ),
        ),
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w6_table_value_line_transfer',
        title: 'Live-table value line',
        phase: Act0LessonPhaseV1.drill,
        runner: _w6TableValueLineTransferRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _w6TableValueLineTransferRunner.options,
            correctOptionId: 'bet_value',
            correctIndex: 2,
          ),
        ),
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.proveIt,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'w6_turn_pressure_shift_transfer',
        title: 'Turn pressure shift',
        phase: Act0LessonPhaseV1.drill,
        runner: _w6TurnPressureShiftTransferRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _w6TurnPressureShiftTransferRunner.options,
            correctOptionId: 'check_more',
            correctIndex: 1,
          ),
        ),
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.proveIt,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'w6_wet_board_repair',
        title: 'Repair wet-board read',
        phase: Act0LessonPhaseV1.drill,
        runner: _w6WetBoardRepairRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _w6WetBoardRepairRunner.options,
            correctOptionId: 'respect_wetter_board',
            correctIndex: 1,
          ),
        ),
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.fixMistakes,
        taskFamily: Act0TaskFamilyV1.repair,
        repairOnly: true,
      ),
      Act0LessonTaskV1(
        taskId: 'w6_pressure_lines_recap',
        title: 'Pressure recap',
        phase: Act0LessonPhaseV1.review,
        runner: _w6FromCutoff(_w6PressureLinesRecapRunner),
        rewardXp: 15,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'range_combo_counts',
    title: 'Count the combos',
    subtitle: 'AK has 16 combos. A pocket pair has 6.',
    phaseLabel: 'Combos',
    primaryCtaLabel: 'Locked',
    state: Act0LessonStateV1.locked,
    isLocked: true,
    isSelectable: false,
    rewardXp: 40,
    runner: _w6ComboCountsIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w6_combo_counts_intro',
        title: 'Why combo counts matter',
        phase: Act0LessonPhaseV1.theory,
        runner: _w6ComboCountsIntroRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w6_ak_combos',
        title: 'AK combo count',
        phase: Act0LessonPhaseV1.drill,
        runner: _w6AkComboRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _w6AkComboRunner.options,
            correctOptionId: 'sixteen',
            correctIndex: 2,
          ),
        ),
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.counting,
      ),
      Act0LessonTaskV1(
        taskId: 'w6_pair_combos',
        title: 'Pocket pair combo count',
        phase: Act0LessonPhaseV1.drill,
        runner: _w6PairComboRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.counting,
      ),
      Act0LessonTaskV1(
        taskId: 'w6_combo_weight_compare',
        title: 'Which family appears more?',
        phase: Act0LessonPhaseV1.drill,
        runner: _w6ComboWeightCompareRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _w6ComboWeightCompareRunner.options,
            correctOptionId: 'ak_more',
            correctIndex: 2,
          ),
        ),
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.counting,
      ),
      Act0LessonTaskV1(
        taskId: 'w6_combo_counts_recap',
        title: 'Combo recap',
        phase: Act0LessonPhaseV1.review,
        runner: _w6ComboCountsRecapRunner,
        rewardXp: 15,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  _lessonFromTasksV1(
    lessonId: 'w6_continuation_bet',
    title: 'After your preflop raise',
    subtitle: 'Use the flop texture before choosing whether to bet again.',
    phaseLabel: 'Flop plan',
    rewardXp: 24,
    sourceTasks: [
      Act0LessonTaskV1(
        taskId: 'intro',
        title: 'The next bet after a raise',
        phase: Act0LessonPhaseV1.theory,
        runner: _w6ContinuationBetIntro,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'dry_size',
        title: 'Size a bet on a dry flop',
        phase: Act0LessonPhaseV1.drill,
        runner: _w6ContinuationBetDry,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'value_size',
        title: 'Bet a size that gets called',
        phase: Act0LessonPhaseV1.drill,
        runner: _w6ContinuationBetValue,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'wet_check',
        title: 'Missed on a wet flop',
        phase: Act0LessonPhaseV1.review,
        runner: _w6ContinuationBetWet,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'range_reading_review',
    title: 'Review range reads and combinations',
    subtitle: 'Read hand strength on the flop and count the possible hands.',
    phaseLabel: 'Range review',
    primaryCtaLabel: 'Locked',
    state: Act0LessonStateV1.locked,
    isLocked: true,
    isSelectable: false,
    rewardXp: 76,
    runner: _world6RangeCheckpointRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'range_checkpoint_intro',
        title: 'Read both sides of the flop',
        phase: Act0LessonPhaseV1.theory,
        runner: _w6RangeIntroRunner.copyWith(
          table: _act0BoardLessonTableV1(
            heroCards: _act0LessonCardsV1('Qc Jd'),
            boardCards: _act0LessonCardsV1('Qh 7h 3c'),
            centerLabel: 'Read the range',
          ),
          caption:
              'Start with your own pair, then consider the hands BB can call with.',
          question: 'Where can value come from here?',
          teachingSteps: const <Act0TeachingStepV1>[
            Act0TeachingStepV1(
              title: 'Connect the hand to the range.',
              body:
                  'You pair the queen. If BB calls with a seven, a bet can earn chips. '
                  'If only a stronger queen calls, the same bet has a different result.',
              focusLabels: <String>['Your pair', 'Hands that call'],
            ),
            Act0TeachingStepV1(
              title: 'When they bet after your check.',
              body:
                  'A check-call means calling the bet after you check. '
                  'A check-fold means folding to that bet. A check-raise means raising it. '
                  'In the examples ahead, the raising player often has two pair or a stronger hand.',
            ),
          ],
          feedbackTitle: 'Put the reads together.',
          feedbackReason:
              'Read how the flop fits the hand, then consider weaker calls and the hands that might fold.',
        ),
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'range_checkpoint_value',
        title: 'A flop bet against a stated range',
        phase: Act0LessonPhaseV1.drill,
        runner: _w6ValueDryBoardRunner.copyWith(
          caption:
              "BB checks. Assume BB calls half pot with Q-9 and 5-4; other unpaired hands fold.",
          hint: 'Read the cards and the stated range.',
          question: "What do you do to earn a call from a weaker hand?",
          feedbackTitle: 'Read the range in this hand.',
          feedbackReason:
              "Bet half pot because BB calls with Q-9 and 5-4, which trail your queens. Checking leaves the payment from those weaker pairs uncollected.",
          teachingSteps: const [],
          table: _act0BoardLessonTableV1(
            heroCards: _act0LessonCardsV1('Qd Tc'),
            boardCards: _act0LessonCardsV1('Qs 5h 2d'),
            centerLabel: 'Read the range',
          ),
          options: const <Act0RunnerOptionV1>[
            Act0RunnerOptionV1(
              id: 'value',
              label: "Bet half pot for value",
              isCorrect: true,
              preferredLabel: "Bet half pot for value",
              quality: Act0FeedbackQualityV1.correct,
              feedbackTitle: "A bet can earn weaker calls.",
              feedbackReason:
                  "Bet half pot because BB calls with Q-9 and 5-4, which trail your queens. Checking leaves the payment from those weaker pairs uncollected.",
            ),
            Act0RunnerOptionV1(
              id: 'bluff',
              label: "Bet half pot as a bluff",
              isCorrect: false,
              preferredLabel: "Bet half pot for value",
              betterAnswerLabel: "Bet half pot for value",
              quality: Act0FeedbackQualityV1.wrong,
              feedbackTitle: "Read the hands that call.",
              feedbackReason:
                  "Treating the bet as a bluff misses the point. The goal is to collect calls from the smaller pairs and weaker queen.",
            ),
            Act0RunnerOptionV1(
              id: 'missed',
              label: "Check",
              isCorrect: false,
              preferredLabel: "Bet half pot for value",
              betterAnswerLabel: "Bet half pot for value",
              quality: Act0FeedbackQualityV1.wrong,
              feedbackTitle: "You paired the queen.",
              feedbackReason:
                  "Checking misses a chance to collect from the two weaker pairs. Betting half pot gets their calls in this example.",
            ),
          ],
        ),
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'range_checkpoint_board_fit',
        title: 'Compare your hand with the flop',
        phase: Act0LessonPhaseV1.drill,
        runner: _w6WrongBoardRunner.copyWith(
          caption:
              "BB can hold pairs and unpaired hands. First read your own cards.",
          hint: 'Read the cards and the stated range.',
          question: "What do your cards make on this flop?",
          feedbackTitle: 'Read the range in this hand.',
          feedbackReason:
              "A-J does not pair on 9-6-2. Your best five start with an ace.",
          teachingSteps: const [],
          table: _act0BoardLessonTableV1(
            heroCards: _act0LessonCardsV1('Ah Jc'),
            boardCards: _act0LessonCardsV1('9h 6s 2c'),
            centerLabel: 'Read the range',
          ),
          options: const <Act0RunnerOptionV1>[
            Act0RunnerOptionV1(
              id: 'missed',
              label: "Ace-high",
              isCorrect: true,
              preferredLabel: "Ace-high",
              quality: Act0FeedbackQualityV1.correct,
              feedbackTitle: "Your cards are unpaired.",
              feedbackReason:
                  "A-J does not pair on 9-6-2. Your best five start with an ace.",
            ),
            Act0RunnerOptionV1(
              id: 'bluff',
              label: "One pair",
              isCorrect: false,
              preferredLabel: "Ace-high",
              betterAnswerLabel: "Ace-high",
              quality: Act0FeedbackQualityV1.wrong,
              feedbackTitle: "Check for a matching rank.",
              feedbackReason:
                  "There are no equal ranks among your two cards and this flop.",
            ),
            Act0RunnerOptionV1(
              id: 'value',
              label: "A made straight",
              isCorrect: false,
              preferredLabel: "Ace-high",
              betterAnswerLabel: "Ace-high",
              quality: Act0FeedbackQualityV1.wrong,
              feedbackTitle: "Count five consecutive ranks.",
              feedbackReason:
                  "The cards do not form five consecutive ranks. Your hand is ace-high.",
            ),
          ],
        ),
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'range_checkpoint_combos',
        title: 'Count a broadway hand',
        phase: Act0LessonPhaseV1.drill,
        runner: _w6AkComboRunner.copyWith(
          caption: "You have not seen an ace or a queen.",
          hint: 'Read the cards and the stated range.',
          question: "How many A-Q combinations are possible?",
          feedbackTitle: 'Read the range in this hand.',
          feedbackReason:
              "There are four aces and four queens available, giving 16 exact two-card hands.",
          teachingSteps: const [],
          table: _act0UnopenedLessonTableV1(
            heroCards: _act0LessonCardsV1('8c 7c'),
            centerLabel: 'Read the range',
          ),
          options: const <Act0RunnerOptionV1>[
            Act0RunnerOptionV1(
              id: 'twelve',
              label: "12",
              isCorrect: false,
              preferredLabel: "16",
              betterAnswerLabel: "16",
              quality: Act0FeedbackQualityV1.wrong,
              feedbackTitle: "Count all suit combinations.",
              feedbackReason:
                  "Twelve counts only the offsuit hands. Four suited combinations are possible as well.",
            ),
            Act0RunnerOptionV1(
              id: 'six',
              label: "6",
              isCorrect: false,
              preferredLabel: "16",
              betterAnswerLabel: "16",
              quality: Act0FeedbackQualityV1.wrong,
              feedbackTitle: "A-Q has two different ranks.",
              feedbackReason:
                  "Six is the count for a pocket pair. For A-Q, any of four aces can go with any of four queens.",
            ),
            Act0RunnerOptionV1(
              id: 'sixteen',
              label: "16",
              isCorrect: true,
              preferredLabel: "16",
              quality: Act0FeedbackQualityV1.correct,
              feedbackTitle: "Four times four is sixteen.",
              feedbackReason:
                  "There are four aces and four queens available, giving 16 exact two-card hands.",
            ),
          ],
        ),
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: "w6_check_line_call",
        title: "Check, then call",
        phase: Act0LessonPhaseV1.drill,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
        runner: _day7ExampleV1(
          6,
          'range_reading_review',
          "w6_check_line_call",
          _day7PostflopV1(
            'bb',
            'Jh 8h',
            'Jd 7s 4c 2s',
            betBb: 2,
            showTurn: true,
          ),
          caption:
              "Assume you win 30% with no ties or further bets. The bettor calls your raise.",
          question: "There is a bet after your check. What earns most now?",
          choices: const ["Raise to 6 BB", "Fold", "Call"],
          correct: 2,
          reason:
              "The bettor puts in 2 BB, so a call makes a 10 BB pot and needs 20%. Check-call because 30% beats that price. Folding misses a gain.",
          wrongReasons: const {
            0: "A raise of 6 BB gets called in the model and creates an 18 BB pot. At 30%, it loses 0.6 BB on average.",
            1: "Folding gives up a call worth 1 BB. Your chance of winning exceeds the 20% threshold.",
          },
        ).task.runner,
      ),
      Act0LessonTaskV1(
        taskId: "w6_check_line_fold",
        title: "Check, then fold",
        phase: Act0LessonPhaseV1.drill,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
        runner: _day7ExampleV1(
          6,
          'range_reading_review',
          "w6_check_line_fold",
          _day7PostflopV1(
            'bb',
            '8h 7d',
            'Kd 8s 4c 2s',
            betBb: 4,
            showTurn: true,
          ),
          caption:
              "Assume 20% wins, no ties and no further bets. The bettor calls your raise.",
          question: "Was checking a reason to keep playing?",
          choices: const ["Fold", "Call", "Raise to 12 BB"],
          correct: 0,
          reason:
              "The bettor puts in 4 BB, so calling makes a 14 BB pot and needs about 29%. Check-fold because 20% falls short of the price.",
          wrongReasons: const {
            1: "A call costs 4 BB and loses 1.2 BB on average at the stated 20%. Folding keeps the rest of your stack.",
            2: "A raise of 12 BB gets called and costs you more when you lose. At 20% it loses 6 BB on average.",
          },
        ).task.runner,
      ),
      Act0LessonTaskV1(
        taskId: "w6_check_line_raise_short",
        title: "Check, then raise for value",
        phase: Act0LessonPhaseV1.drill,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
        runner: _day7ExampleV1(
          6,
          'range_reading_review',
          "w6_check_line_raise_short",
          _day7PostflopV1(
            'bb',
            '9c 9d',
            '9h 6s 2d Qs',
            betBb: 1,
            opponentStartingBb: 4.75,
            showTurn: true,
          ),
          caption:
              "The bettor can call only 1 BB more and does so with a pair of queens. Assume your set wins. At full depth, that pair would pay up to 6 BB.",
          question: "What earns most against this stack?",
          choices: const ["Call", "Raise to 2 BB", "Fold"],
          correct: 1,
          reason:
              "Check-raise to 2 BB because the bettor calls with a weaker pair and has just 1 BB left. Calling leaves that extra chip behind.",
          wrongReasons: const {
            0: "Calling the bet gets no more chips. Raising to 2 BB collects the last 1 BB from the weaker pair.",
            2: "Folding gives up the pot with the winning set in this example. Raise to collect the last chip.",
          },
        ).task.runner,
      ),
      Act0LessonTaskV1(
        taskId: "w6_check_raise_read",
        title: "Read a check-raise",
        phase: Act0LessonPhaseV1.drill,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
        runner:
            _day7ExampleV1(
              6,
              'range_reading_review',
              "w6_check_raise_read",
              _day7PostflopV1(
                'co',
                'As Jc',
                'Ad 9d 5c',
                heroLeadBb: 3,
                betBb: 9,
                showTurn: true,
              ),
              caption:
                  "This BB calls with most one-pair hands and seldom raises a weak hand.",
              question: "What became more likely when BB checked and raised?",
              choices: const [
                "A weaker top pair",
                "Unpaired cards with no draw",
                "Two pair or a set",
              ],
              correct: 2,
              reason:
                  "BB checked and raised, so two pair or a set becomes more likely under this model. A weaker ace usually just calls.",
              wrongReasons: const {
                0: "The model says weaker aces usually call. Treating this raise as a weaker ace can make you pay off a stronger hand.",
                1: "A weak hand rarely raises in this example, so assuming a bluff risks paying against value.",
              },
            ).task.runner.copyWith(
              hint: "Start with the hands BB usually calls.",
              hintPolicy: Act0HintPolicyV1.always,
            ),
      ),
      Act0LessonTaskV1(
        taskId: "w6_check_raise_repeat",
        title: "Answer the turn raise",
        phase: Act0LessonPhaseV1.drill,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
        runner: _day7ExampleV1(
          6,
          'range_reading_review',
          "w6_check_raise_repeat",
          _day7PostflopV1(
            'co',
            'Kh Qd',
            'Kd 8s 4s 2c',
            heroLeadBb: 3,
            betBb: 9,
            showTurn: true,
          ),
          caption:
              "Assume 20% wins, with no ties or further bets. BB will call a reraise.",
          question: "What earns most after BB raises?",
          choices: const ["Call", "Fold", "Raise to 18 BB"],
          correct: 1,
          reason:
              "BB raises, so calling 6 BB makes a 24 BB pot and needs 25%. Fold because the stated 20% falls short.",
          wrongReasons: const {
            0: "A call costs 6 BB and needs 25% wins. With 20%, you lose 1.2 BB per call on average.",
            2: "A raise of 18 BB costs another 15 BB and BB calls. Folding avoids adding chips against hands that usually win.",
          },
        ).task.runner,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'range_thinking_checkpoint',
    title: 'Range thinking checkpoint',
    subtitle: 'Compare value, bluff pressure and hand combinations.',
    phaseLabel: 'Checkpoint',
    primaryCtaLabel: 'Locked',
    state: Act0LessonStateV1.locked,
    isLocked: true,
    isSelectable: false,
    rewardXp: 86,
    runner: _world6RangeCheckpointRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w6_suited_offsuit_weight_compare',
        title: 'Suited or offsuit weight',
        phase: Act0LessonPhaseV1.drill,
        runner: _w6SuitedOffsuitWeightCompareRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _w6SuitedOffsuitWeightCompareRunner.options,
            correctOptionId: 'ak_offsuit',
            correctIndex: 1,
          ),
        ),
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w6_pair_vs_suited_weight_compare',
        title: 'Pair or suited family',
        phase: Act0LessonPhaseV1.drill,
        runner: _w6PairVsSuitedWeightCompareRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _w6PairVsSuitedWeightCompareRunner.options,
            correctOptionId: 'pair_nines',
            correctIndex: 2,
          ),
        ),
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w6_checkpoint_table_combo_weight',
        title: 'Live-table combo weight',
        phase: Act0LessonPhaseV1.drill,
        runner: _w6CheckpointTableComboWeightRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _w6CheckpointTableComboWeightRunner.options,
            correctOptionId: 'ak_offsuit',
            correctIndex: 1,
          ),
        ),
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.proveIt,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'range_checkpoint_pressure',
        title: 'Pressure after a check',
        phase: Act0LessonPhaseV1.drill,
        runner: _w6BluffCandidateRunner.copyWith(
          caption:
              'On K-8-3, BB checks. Any pair calls half pot. Q-J and A-9 fold. Check if your hand already beats either unpaired hand.',
          question: 'What do you do with nine-six after BB checks?',
          feedbackTitle: 'A bet can fold better hands.',
          feedbackReason:
              'On K-8-3, 9-6 trails both Q-J and A-9. In this example, both of those hands fold to a half-pot bet.',
          table: _act0BoardLessonTableV1(
            heroCards: _act0LessonCardsV1('9h 6d'),
            boardCards: _act0LessonCardsV1('Kd 8s 3h'),
            centerLabel: 'Read the flop',
          ),
          options: _act0AuthoredCorrectOptionAtV1(
            _w6BluffCandidateOptionsV1('9-6'),
            correctOptionId: 'bluff',
            correctIndex: 2,
          ),
        ),
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w6_kicker_showdown_compare',
        title: 'Find weaker calls',
        phase: Act0LessonPhaseV1.drill,
        runner: _world6RangeCheckpointRunner.copyWith(
          phase: Act0LessonPhaseV1.drill,
          caption:
              "BB checks. Assume BB calls half pot with any pair and folds hands without a pair.",
          hint: 'Read the cards and the stated range.',
          question: "Which option lists two weaker hands that would call?",
          feedbackTitle: 'Read the range in this hand.',
          feedbackReason:
              "Both hands pair the flop and are behind your jacks. BB calls both under this rule.",
          teachingSteps: const [],
          table: _act0BoardLessonTableV1(
            heroCards: _act0LessonCardsV1('Jd Js'),
            boardCards: _act0LessonCardsV1('9c 6s 2d'),
            centerLabel: 'Read the range',
          ),
          options: const <Act0RunnerOptionV1>[
            Act0RunnerOptionV1(
              id: 'hero_ak',
              label: "9-8 and 6-5",
              isCorrect: true,
              preferredLabel: "9-8 and 6-5",
              quality: Act0FeedbackQualityV1.correct,
              feedbackTitle: "Both weaker pairs call.",
              feedbackReason:
                  "Both hands pair the flop and are behind your jacks. BB calls both under this rule.",
            ),
            Act0RunnerOptionV1(
              id: 'villain_kq',
              label: "A-K and Q-J",
              isCorrect: false,
              preferredLabel: "9-8 and 6-5",
              betterAnswerLabel: "9-8 and 6-5",
              quality: Act0FeedbackQualityV1.wrong,
              feedbackTitle: "Both hands miss this flop.",
              feedbackReason:
                  "Neither hand has a pair. They fold under the stated rule.",
            ),
            Act0RunnerOptionV1(
              id: 'tie',
              label: "9-9 and 6-6",
              isCorrect: false,
              preferredLabel: "9-8 and 6-5",
              betterAnswerLabel: "9-8 and 6-5",
              quality: Act0FeedbackQualityV1.wrong,
              feedbackTitle: "Both callers are stronger.",
              feedbackReason:
                  "Both pocket pairs make three of a kind and beat your jacks. Look for weaker calls.",
            ),
          ],
        ),
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w6_board_pair_strength_compare',
        title: 'Read the caller’s range',
        phase: Act0LessonPhaseV1.drill,
        runner: _world6RangeCheckpointRunner.copyWith(
          phase: Act0LessonPhaseV1.drill,
          caption: "BTN opens J-J, A-A, A-K. BB calls J-8, 8-8, 4-4, 5-5.",
          hint: 'Read the cards and the stated range.',
          question:
              "In these ranges, who has more hand types at two pair or better?",
          feedbackTitle: 'Read the range in this hand.',
          feedbackReason:
              "J-8 makes two pair, while 8-8 and 4-4 make sets. BTN has only J-J at this strength.",
          teachingSteps: const [],
          table: _act0BoardLessonTableV1(
            heroCards: _act0LessonCardsV1('Jh Jc'),
            boardCards: _act0LessonCardsV1('Js 8d 4h'),
            centerLabel: 'Read the range',
          ),
          options: const <Act0RunnerOptionV1>[
            Act0RunnerOptionV1(
              id: 'hero_aj',
              label: "BTN, the raiser",
              isCorrect: false,
              preferredLabel: "BB, the caller",
              betterAnswerLabel: "BB, the caller",
              quality: Act0FeedbackQualityV1.wrong,
              feedbackTitle: "BTN has one strong hand type.",
              feedbackReason:
                  "J-J makes a set. Neither A-A nor A-K makes two pair or better. BB has three strong hand types.",
            ),
            Act0RunnerOptionV1(
              id: 'villain_k8',
              label: "BB, the caller",
              isCorrect: true,
              preferredLabel: "BB, the caller",
              quality: Act0FeedbackQualityV1.correct,
              feedbackTitle: "Three hand types fit the caller.",
              feedbackReason:
                  "J-8 makes two pair, while 8-8 and 4-4 make sets. BTN has only J-J at this strength.",
            ),
            Act0RunnerOptionV1(
              id: 'tie',
              label: "They have the same number",
              isCorrect: false,
              preferredLabel: "BB, the caller",
              betterAnswerLabel: "BB, the caller",
              quality: Act0FeedbackQualityV1.wrong,
              feedbackTitle: "Count the two lists separately.",
              feedbackReason:
                  "BB has three kinds of strong hands: two sets and two pair. BTN has one set.",
            ),
          ],
        ),
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w6_checkpoint_table_best_five',
        title: 'Count the two possible families',
        phase: Act0LessonPhaseV1.drill,
        runner: _world6RangeCheckpointRunner.copyWith(
          phase: Act0LessonPhaseV1.drill,
          caption:
              "Compare pocket sevens with A-T suited before seeing a flop. All their ranks are available.",
          hint: 'Read the cards and the stated range.',
          question: "Which family has more exact two-card hands?",
          feedbackTitle: 'Read the range in this hand.',
          feedbackReason:
              "There are six ways to pick two sevens. A-T suited has one combination for each of the four suits.",
          teachingSteps: const [],
          table: _act0UnopenedLessonTableV1(
            heroCards: _act0LessonCardsV1('3h 6c'),
            centerLabel: 'Read the range',
          ),
          options: const <Act0RunnerOptionV1>[
            Act0RunnerOptionV1(
              id: 'hero_wins',
              label: "A-T suited",
              isCorrect: false,
              preferredLabel: "Pocket sevens",
              betterAnswerLabel: "Pocket sevens",
              quality: Act0FeedbackQualityV1.wrong,
              feedbackTitle: "Only same-suit cards count here.",
              feedbackReason:
                  "A-T has 16 combinations overall, but only four are suited. The pair family has six.",
            ),
            Act0RunnerOptionV1(
              id: 'split',
              label: "Pocket sevens",
              isCorrect: true,
              preferredLabel: "Pocket sevens",
              quality: Act0FeedbackQualityV1.correct,
              feedbackTitle: "Six combinations are more than four.",
              feedbackReason:
                  "There are six ways to pick two sevens. A-T suited has one combination for each of the four suits.",
            ),
            Act0RunnerOptionV1(
              id: 'villain_wins',
              label: "They have the same count",
              isCorrect: false,
              preferredLabel: "Pocket sevens",
              betterAnswerLabel: "Pocket sevens",
              quality: Act0FeedbackQualityV1.wrong,
              feedbackTitle: "The counting rules differ.",
              feedbackReason:
                  "A pocket pair chooses two of four cards. A suited hand with two ranks has one combination per suit.",
            ),
          ],
        ),
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.proveIt,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'range_checkpoint_review',
        title: 'World 6 checkpoint',
        phase: Act0LessonPhaseV1.review,
        runner: _world6RangeCheckpointRunner.copyWith(
          caption:
              "The flop shows an ace. Think about a range that allowed any pocket aces before the flop.",
          hint: 'Read the cards and the stated range.',
          question: "Which fact can narrow that range now?",
          feedbackTitle: 'Read the range in this hand.',
          feedbackReason:
              "The flop ace cannot be in BB’s hand, so fewer ace pairs are possible. Pot size alone does not remove a card.",
          teachingSteps: const [],
          table: _act0BoardLessonTableV1(
            heroCards: _act0LessonCardsV1('Tc 7d'),
            boardCards: _act0LessonCardsV1('Ac 9h 3s'),
            centerLabel: 'Read the range',
          ),
          options: const <Act0RunnerOptionV1>[
            Act0RunnerOptionV1(
              id: 'range_plus_stack_depth',
              label: "One ace is already on the board",
              isCorrect: true,
              preferredLabel: "One ace is already on the board",
              quality: Act0FeedbackQualityV1.correct,
              feedbackTitle: "A visible card cannot be in a private hand.",
              feedbackReason:
                  "The flop ace cannot be in BB’s hand, so fewer ace pairs are possible. Pot size alone does not remove a card.",
            ),
            Act0RunnerOptionV1(
              id: 'range_plus_pot_size',
              label: "The pot is 5.5 BB",
              isCorrect: false,
              preferredLabel: "One ace is already on the board",
              betterAnswerLabel: "One ace is already on the board",
              quality: Act0FeedbackQualityV1.suboptimal,
              feedbackTitle: "Pot size does not remove a card.",
              feedbackReason:
                  "Look for information about which private cards are still physically available.",
            ),
            Act0RunnerOptionV1(
              id: 'range_only',
              label: "BTN has the dealer marker",
              isCorrect: false,
              preferredLabel: "One ace is already on the board",
              betterAnswerLabel: "One ace is already on the board",
              quality: Act0FeedbackQualityV1.wrong,
              feedbackTitle: "The marker only shows position.",
              feedbackReason:
                  "Position explains action order. A card on the board directly rules out hands that need it.",
            ),
          ],
        ),
        rewardXp: 16,
        stepKind: Act0LessonStepKindV1.proveIt,
      ),
    ],
  ),
];

final _w7VisibleCardComboDensityLesson = Act0LessonCardV1(
  lessonId: 'range_thinking_lite_combo_density',
  title: 'Visible Cards Change Ranges',
  subtitle: 'See how shown cards narrow the hands someone can still hold.',
  state: Act0LessonStateV1.locked,
  phaseLabel: 'Visible Cards Change Ranges',
  primaryCtaLabel: 'Locked',
  isSelectable: false,
  isLocked: true,
  rewardXp: 45,
  runner: _w7VisibleCardRunnerFromSpecV1(
    act0W7VisibleAceHiddenTaskSpecsV1.first,
    phase: Act0LessonPhaseV1.theory,
  ),
  tasks: _w7VisibleCardTasksFromSpecsV1(),
);

final _rangeThinkingFoundationLessons = <Act0LessonCardV1>[
  _rangeThinkingLiteLessons[0],
  _rangeThinkingLiteLessons[1],
  _rangeThinkingLiteLessons[2],
  _rangeThinkingLiteLessons[3],
  _rangeThinkingLiteLessons[4],
  _rangeThinkingLiteLessons[5],
  _rangeThinkingLiteLessons[6],
];

final _visibleCardRangeContinuationLessons = <Act0LessonCardV1>[
  _w7VisibleCardComboDensityLesson,
  _w7PriceLessonV1,
  _w7RangeCheckpointV1,
];

final _w7PriceLessonV1 = _w7AppliedLessonV1(
  id: 'w7_visible_cards_and_price',
  title: 'Read the table and compare the price',
  subtitle: 'See what changes when another player enters or the price goes up.',
  tasks: [
    _w7FlopTaskV1(multiway: false),
    _w7FlopTaskV1(multiway: true),
    _w7AppliedTaskV1(
      id: 'w7_count_winning_rivers',
      title: 'Which cards actually win?',
      question:
          'Suppose BB has K♣ Q♠. How many river cards give you the winning hand?',
      caption: 'Count the rivers that beat the stated hand. One card is left.',
      table: _w7TurnPriceTableV1(3),
      labels: const ['9', '12', '11'],
      correctAt: 1,
      feedback: const [
        'Nine hearts make a winning flush. Three non-heart aces also win.',
        'Nine hearts make a winning flush. The three unseen aces also win with a pair of aces.',
        'Count the three unseen aces as well as all nine unseen hearts.',
      ],
      family: Act0TaskFamilyV1.counting,
    ),
    _w7TurnPriceTaskV1(
      id: 'w7_clean_outs_lower_price',
      bet: 3,
      correctAt: 0,
      feedback:
          'You win on 12 of 44 rivers, about 27%. Calling 3 BB needs 3 of the final 14 BB, about 21%. Your chance is higher.',
      wrongFeedback:
          'Folding gives up nine winning hearts and three winning aces. Those 12 rivers give you more than the roughly 21% the 3 BB call needs.',
    ),
    _w7TurnPriceTaskV1(
      id: 'w7_clean_outs_higher_price',
      bet: 6,
      correctAt: 1,
      feedback:
          'You still win on 12 of 44 rivers, about 27%. To call 6 BB you need 6 of the final 20 BB, or 30%. The chance did not change; the price did.',
      wrongFeedback:
          'The draw wins on the same 12 of 44 rivers. Paying 6 BB now requires 30%, so the call risks more than this chance is worth.',
    ),
  ],
);

final _w7RangeCheckpointV1 = _w7AppliedLessonV1(
  id: 'w7_visible_cards_range_checkpoint',
  title: 'Range and price checkpoint',
  subtitle:
      'Make three river decisions from the hands that are still possible.',
  tasks: [
    _w7RiverTaskV1(
      id: 'w7_river_one_bluff_of_six',
      range: 'K♥ Q♦, K♦ Q♣, A♥ Q♦, A♦ Q♣, J♥ T♥ or A♣ Q♦',
      correctAt: 1,
      feedback:
          'If BB has J♥ T♥, you win. Every other hand on the list beats you. You win one of six times, about 17%, but paying 4 BB for a final pot of 16 BB needs 25%.',
      wrongFeedback:
          'Your queen-jack beats just the jack-ten bluff. Paying 4 BB with one win in six fails the 25% threshold and loses chips on average.',
    ),
    _w7RiverTaskV1(
      id: 'w7_river_two_bluffs_of_six',
      range: 'K♥ Q♦, K♦ Q♣, A♥ Q♦, A♦ Q♣, J♥ T♥ or A♠ 8♠',
      correctAt: 0,
      feedback:
          "BB bets all-in with two bluffs among six equally likely hands. Call because two wins in six clear the 25% price, and folding gives up about 1.33 BB.",
      wrongFeedback:
          'Folding gives up wins against jack-ten and ace-eight. Those two of the six hands are enough to clear the 25% call price.',
    ),
    _w7UnseenRiverTaskV1(),
    Act0LessonTaskV1(
      taskId: "w7_read_visible_card_guided",
      title: "Read the possible value hands",
      phase: Act0LessonPhaseV1.drill,
      rewardXp: 8,
      stepKind: Act0LessonStepKindV1.practice,
      runner:
          _day7ExampleV1(
            7,
            "w7_visible_cards_range_checkpoint",
            "w7_read_visible_card_guided",
            _day7PostflopV1(
              'co',
              'Jh Jd',
              'Js 9c 7c 4h 2s',
              openBb: 3.75,
              betBb: 5,
              opponentStartingBb: 8.75,
              opponentAllIn: true,
              showTurn: true,
            ),
            caption:
                "BB can bet T♣8♣, 9♥9♦ or 2♠2♦ if the cards are available.",
            question: "Which possible hand did the river remove?",
            choices: const ["T♣8♣", "2♠2♦", "9♥9♦"],
            correct: 1,
            reason:
                "BB cannot bet the listed twos because the river is 2♠. Ten-eight remains possible and can bet a straight.",
            wrongReasons: const {
              0: "Ten-eight can still bet a straight. Removing it would miss a hand that beats your jacks.",
              2: "Nines can still bet a lower set. Removing them would miss a hand your set beats.",
            },
          ).task.runner.copyWith(
            hint: "Find the river card in one of the possible hands.",
            hintPolicy: Act0HintPolicyV1.always,
          ),
    ),
    Act0LessonTaskV1(
      taskId: "w7_read_visible_card_call",
      title: "Use the hands left in range",
      phase: Act0LessonPhaseV1.drill,
      rewardXp: 8,
      stepKind: Act0LessonStepKindV1.practice,
      taskFamily: Act0TaskFamilyV1.transfer,
      runner: _day7ExampleV1(
        7,
        "w7_visible_cards_range_checkpoint",
        "w7_read_visible_card_call",
        _day7PostflopV1(
          'co',
          'Qh Jd',
          'Qs 9c 7d 4h Ac',
          openBb: 3.75,
          betBb: 4,
          opponentStartingBb: 7.75,
          opponentAllIn: true,
          showTurn: true,
        ),
        caption:
            "Before the river, BB could bet A♣ Q♦, K♥ Q♦, Q♣ T♦ or T♥ 8♥. Give all hands still possible equal weight.",
        question: "What is your decision?",
        choices: const ["Fold", "Call"],
        correct: 1,
        reason:
            "BB bets one better queen and two hands you beat after the A♣ removes ace-queen. Call because two wins in three clear the 25% price, and folding misses that gain.",
        wrongReasons: const {
          0: "Folding gives up two wins in three against the hands that can remain. Calling 4 BB only needs 25%.",
        },
      ).task.runner,
    ),
  ],
);

Act0LessonTaskV1 _w7UnseenRiverTaskV1() => _w7AppliedTaskV1(
  id: 'w7_checkpoint_river_card_excludes_hand',
  title: 'The river all-in',
  question:
      'BB is all-in. Before the river, BB could have T♣ 8♣, T♠ 8♠, '
      'T♦ 8♦, 9♥ 9♦ or 2♠ 2♦. Give all hands that are still possible '
      'equal weight. Call or fold?',
  caption: 'Read the final board.',
  table: _w7AllInTableV1(
    holeCards: 'Jh Jd',
    boardCards: 'Js 9c 7c 4h 2s',
    street: 'River',
    bet: 5,
  ),
  labels: const ['Call', 'Fold'],
  correctAt: 1,
  feedback: const [
    'The 2♠ is on the board. BB cannot have a pair of twos from that list. '
        'If BB has a pair of nines, you win. The three ten-eight hands '
        'make a straight. Calling costs 5 BB and needs about 28%, so fold with just one win in four.',
    "BB bets three straights and a lower set once the river 2♠ removes the listed pocket twos. Fold because one win in four falls short of the 28% needed to call 5 BB.",
  ],
  family: Act0TaskFamilyV1.transfer,
  kind: Act0LessonStepKindV1.proveIt,
);

Act0LessonCardV1 _w7AppliedLessonV1({
  required String id,
  required String title,
  required String subtitle,
  required List<Act0LessonTaskV1> tasks,
}) => Act0LessonCardV1(
  lessonId: id,
  title: title,
  subtitle: subtitle,
  state: Act0LessonStateV1.locked,
  phaseLabel: 'Visible Cards Change Ranges',
  primaryCtaLabel: 'Locked',
  isSelectable: false,
  isLocked: true,
  rewardXp: tasks.fold<int>(0, (total, task) => total + task.rewardXp),
  runner: tasks.first.runner,
  tasks: tasks,
);

Act0LessonTaskV1 _w7FlopTaskV1({required bool multiway}) {
  final opponents = multiway ? 'SB and BB both check.' : 'BB checks.';
  final foldRate = multiway ? '16%' : '40%';
  final table = _w7FlopTableV1(multiway: multiway);
  final explanation = multiway
      ? 'Everyone folds only 16% of the time in this example. The bet wins '
            '9 BB on those folds but loses 3 BB the other 84% of the time. '
            'That is a loss of about 1.1 BB on average. Checking risks 0 BB.'
      : 'With one opponent, the bet wins 6.5 BB on the 40% of hands where '
            'they fold and loses 3 BB otherwise. That is a gain of 0.8 BB '
            'on average in this example.';
  return _w7AppliedTaskV1(
    id: multiway ? 'w7_flop_bluff_two_players' : 'w7_flop_bluff_one_player',
    title: 'A flop decision',
    question:
        '$opponents Everyone folds to a 3 BB bet $foldRate of the time. For this '
        'exercise, count the full bet as lost if anyone continues. Checking '
        'has a value of 0 BB. Which action is better in this model?',
    caption:
        'Compare what you win on folds with what you risk when someone continues.',
    table: table,
    labels: const ['Bet 3 BB', 'Check'],
    correctAt: multiway ? 1 : 0,
    feedback: multiway
        ? [
            'With SB and BB both in, the 3 BB bet loses money on average. '
                'It wins 9 BB on 16% of hands and costs 3 BB on the rest.',
            explanation,
          ]
        : [
            explanation,
            'Checking gets 0 BB in this model. With BB as the only opponent, '
                'winning 6.5 BB on 40% of hands more than offsets the 3 BB you '
                'lose when BB continues.',
          ],
    family: Act0TaskFamilyV1.decision,
  );
}

Act0TableStateV1 _w7FlopTableV1({required bool multiway}) {
  final heroCards = _act0LessonCardsV1('7h 6h');
  final table = _act0BoardLessonTableV1(
    heroCards: heroCards,
    boardCards: _act0LessonCardsV1('As 9d 3c'),
    centerLabel: 'Flop decision',
  );
  const wager = Act0ContributionKindV1.wager;
  return table.copyWith(
    heroSeatId: 'co',
    activeSeatId: 'co',
    decisionSeatId: 'co',
    potLabel: multiway ? 'Pot 9 BB' : 'Pot 6.5 BB',
    actionTrail: [
      const Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
      const Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
      const Act0ActionTrailItemV1(label: 'UTG folds'),
      const Act0ActionTrailItemV1(label: 'HJ folds'),
      const Act0ActionTrailItemV1(label: 'CO raises to 3 BB'),
      const Act0ActionTrailItemV1(label: 'BTN folds'),
      if (multiway)
        const Act0ActionTrailItemV1(
          label: 'SB calls 3 BB',
          displayLabel: 'SB calls 2.5 BB more',
        )
      else
        const Act0ActionTrailItemV1(label: 'SB folds'),
      const Act0ActionTrailItemV1(
        label: 'BB calls 3 BB',
        displayLabel: 'BB calls 2 BB more',
      ),
      if (multiway) const Act0ActionTrailItemV1(label: 'Flop: SB checks'),
      Act0ActionTrailItemV1(label: multiway ? 'BB checks' : 'Flop: BB checks'),
    ],
    handContributions: Act0HandContributionsV1(
      throughStreet: PokerStreet.flop,
      startingStackBbBySeat: const {'co': 100, 'bb': 100, 'sb': 100},
      entries: [
        ..._act0LessonBlinds,
        const Act0ContributionV1(PokerStreet.preflop, 'co', wager, 3),
        if (multiway)
          const Act0ContributionV1(PokerStreet.preflop, 'sb', wager, 2.5),
        const Act0ContributionV1(PokerStreet.preflop, 'bb', wager, 2),
      ],
    ),
    seats: [
      for (final seat in table.seats)
        _act0CopySeatStateV1(
          seat,
          clearCommitment: true,
          isHero: seat.seatId == 'co',
          isActive: seat.seatId == 'co',
          hasActed: seat.seatId != 'co',
          isInHand:
              seat.seatId == 'co' ||
              seat.seatId == 'bb' ||
              (multiway && seat.seatId == 'sb'),
          isFolded:
              seat.seatId != 'co' &&
              seat.seatId != 'bb' &&
              (!multiway || seat.seatId != 'sb'),
          stackLabel: switch (seat.seatId) {
            'co' || 'bb' => '97 BB',
            'sb' => multiway ? '97 BB' : '99.5 BB',
            _ => '100 BB',
          },
          holeCards: seat.seatId == 'co' ? heroCards : _unknownHoleCards,
          cardsVisibleMode: switch (seat.seatId) {
            'co' => Act0CardsVisibleModeV1.faceUp,
            'bb' => Act0CardsVisibleModeV1.faceDown,
            'sb' when multiway => Act0CardsVisibleModeV1.faceDown,
            _ => Act0CardsVisibleModeV1.none,
          },
        ),
    ],
  );
}

Act0TableStateV1 _w7TurnPriceTableV1(int bet) => _w7AllInTableV1(
  holeCards: 'Ah 8h',
  boardCards: 'Kh 7h 2c 4d',
  street: 'Turn',
  bet: bet,
);

Act0LessonTaskV1 _w7TurnPriceTaskV1({
  required String id,
  required int bet,
  required int correctAt,
  required String feedback,
  required String wrongFeedback,
}) => _w7AppliedTaskV1(
  id: id,
  title: 'A turn price',
  question: 'BB is all-in. Suppose BB holds K♣ Q♠. Call or fold?',
  caption: 'Compare your chance to win with the price.',
  table: _w7TurnPriceTableV1(bet),
  labels: const ['Call', 'Fold'],
  correctAt: correctAt,
  feedback: [
    for (var index = 0; index < 2; index++)
      index == correctAt ? feedback : wrongFeedback,
  ],
  family: Act0TaskFamilyV1.decision,
);

Act0LessonTaskV1 _w7RiverTaskV1({
  required String id,
  required String range,
  required int correctAt,
  required String feedback,
  required String wrongFeedback,
}) => _w7AppliedTaskV1(
  id: id,
  title: 'A river decision',
  question:
      'BB is all-in and could have any of these equally likely hands: $range. Call or fold?',
  caption: 'Use the stated range for this decision.',
  table: _w7AllInTableV1(
    holeCards: 'Qs Jd',
    boardCards: 'Qh 9c 5s 4d 2c',
    street: 'River',
    bet: 4,
  ),
  labels: const ['Call', 'Fold'],
  correctAt: correctAt,
  feedback: [
    for (var index = 0; index < 2; index++)
      index == correctAt ? feedback : wrongFeedback,
  ],
  family: Act0TaskFamilyV1.transfer,
  kind: Act0LessonStepKindV1.proveIt,
);

Act0TableStateV1 _w7AllInTableV1({
  required String holeCards,
  required String boardCards,
  required String street,
  required int bet,
}) {
  final table = _act0BoardLessonTableV1(
    heroCards: _act0LessonCardsV1(holeCards),
    boardCards: _act0LessonCardsV1(boardCards),
    centerLabel: '$street decision',
    flopBetBb: 1.25,
    facingBb: bet,
    bbBehindBb: 0,
  );
  final amount = _act0BbLabelV1(bet);
  return table.copyWith(
    handContributions: table.handContributions,
    actionTrail: [
      ...table.actionTrail.take(table.actionTrail.length - 1),
      Act0ActionTrailItemV1(
        label: '$street: BB all-in $amount',
        displayLabel: '$street: BB goes all-in for $amount',
      ),
    ],
    seats: [
      for (final seat in table.seats)
        if (seat.seatId == 'bb')
          _act0CopySeatStateV1(
            seat,
            clearCommitment: true,
            bet: Act0SeatBetStateV1(
              kind: Act0SeatBetKindV1.allIn,
              label: 'BB',
              amountLabel: amount,
            ),
          )
        else
          seat,
    ],
  );
}

Act0LessonTaskV1 _w7AppliedTaskV1({
  required String id,
  required String title,
  required String question,
  required String caption,
  required Act0TableStateV1 table,
  required List<String> labels,
  required int correctAt,
  required List<String> feedback,
  required Act0TaskFamilyV1 family,
  List<Act0TeachingStepV1> teaching = const [],
  Act0LessonStepKindV1 kind = Act0LessonStepKindV1.practice,
}) {
  final phase = teaching.isEmpty
      ? Act0LessonPhaseV1.drill
      : Act0LessonPhaseV1.theory;
  return Act0LessonTaskV1(
    taskId: id,
    title: title,
    phase: phase,
    rewardXp: 10,
    taskFamily: family,
    stepKind: teaching.isEmpty ? kind : Act0LessonStepKindV1.learn,
    runner: _w6ComboCountsIntroRunner.copyWith(
      lessonId: id,
      lessonTitle: title,
      lessonSubtitle: 'Visible Cards Change Ranges',
      phase: phase,
      caption: caption,
      question: question,
      hint: '',
      table: table,
      teachingSteps: teaching,
      feedbackTitle: 'Compare the numbers.',
      feedbackReason: feedback[correctAt],
      options: [
        for (var index = 0; index < labels.length; index++)
          Act0RunnerOptionV1(
            id: 'choice_${index + 1}',
            label: labels[index],
            isCorrect: index == correctAt,
            preferredLabel: labels[correctAt],
            betterAnswerLabel: index == correctAt ? null : labels[correctAt],
            quality: index == correctAt
                ? Act0FeedbackQualityV1.correct
                : Act0FeedbackQualityV1.wrong,
            feedbackTitle: index == correctAt
                ? 'That fits the table.'
                : 'Check what can still win.',
            feedbackReason: feedback[index],
          ),
      ],
    ),
  );
}

List<Act0LessonTaskV1> _w7VisibleCardTasksFromSpecsV1() {
  final tasks = <Act0LessonTaskV1>[];
  for (
    var index = 0;
    index < act0W7VisibleAceHiddenTaskSpecsV1.length;
    index++
  ) {
    final spec = act0W7VisibleAceHiddenTaskSpecsV1[index];
    final isIntro = index == 0;
    final isTransfer = spec.drillKind.contains('transfer');
    final phase = isIntro ? Act0LessonPhaseV1.theory : Act0LessonPhaseV1.drill;
    tasks.add(
      Act0LessonTaskV1(
        taskId: spec.taskId,
        title: _w7LearnerTaskTitleV1(spec.taskId),
        phase: phase,
        runner: _w7VisibleCardRunnerFromSpecV1(spec, phase: phase),
        rewardXp: isTransfer ? 12 : 10,
        stepKind: isIntro
            ? Act0LessonStepKindV1.learn
            : (isTransfer
                  ? Act0LessonStepKindV1.proveIt
                  : Act0LessonStepKindV1.practice),
        taskFamily: isTransfer ? Act0TaskFamilyV1.transfer : null,
      ),
    );
  }
  final recapSpec = act0W7VisibleAceHiddenTaskSpecsV1.last;
  tasks.add(
    Act0LessonTaskV1(
      taskId: 'visible_card_combo_reduction_recap',
      title: 'Visible-card recap',
      phase: Act0LessonPhaseV1.review,
      runner: _w7VisibleCardRunnerFromSpecV1(recapSpec, phase: Act0LessonPhaseV1.review).copyWith(
        caption: 'Use the cards you can see at this table.',
        question: 'How many A-Q combinations could BB still hold?',
        hint: 'Count the aces and queens that are still available.',
        table: _day7PostflopV1(
          'co',
          'Td 8d',
          'Qc 6h 2s',
          openBb: 2.5,
          checkedToHero: true,
          showTurn: true,
        ).copyWith(centerLabel: 'Count available cards'),
        teachingSteps: const [],
        feedbackTitle: 'Four choices times three.',
        feedbackReason:
            'Four aces and three queens remain, so there are 12 A-Q combinations. '
            'World 8 uses stack depth to show how much those hands can risk.',
        options: const <Act0RunnerOptionV1>[
          Act0RunnerOptionV1(
            id: 'only_board_low_cards_matter',
            label: '16',
            isCorrect: false,
            preferredLabel: '12',
            betterAnswerLabel: '12',
            quality: Act0FeedbackQualityV1.wrong,
            feedbackTitle: 'One queen is already on the board.',
            feedbackReason:
                'Sixteen would count four queens. The visible queen leaves only three to pair with four aces.',
          ),
          Act0RunnerOptionV1(
            id: 'visible_cards_show_exact_hand',
            label: '6',
            isCorrect: false,
            preferredLabel: '12',
            betterAnswerLabel: '12',
            quality: Act0FeedbackQualityV1.wrong,
            feedbackTitle: 'A-Q has two different ranks.',
            feedbackReason:
                'Count any of the four aces with any of the three remaining queens. Six is the starting count for a pocket pair.',
          ),
          Act0RunnerOptionV1(
            id: 'visible_rank_reduces_matching_rank_combos',
            label: '12',
            isCorrect: true,
            preferredLabel: '12',
            quality: Act0FeedbackQualityV1.correct,
            feedbackTitle: 'Four aces times three queens.',
            feedbackReason:
                'Four aces and three queens remain. Four times three gives 12 exact hands. Next, stack depth sets how much either player can put in.',
          ),
        ],
      ),
      rewardXp: 12,
      stepKind: Act0LessonStepKindV1.review,
    ),
  );
  return tasks;
}

Act0RunnerStateV1 _w7VisibleCardRunnerFromSpecV1(
  Act0W7VisibleAceHiddenTaskSpecV1 spec, {
  required Act0LessonPhaseV1 phase,
}) {
  final heroCards = switch (spec.taskId) {
    'visible_ace_combo_reduction_intro' => _act0LessonCardsV1('Js Tc'),
    'visible_king_combo_reduction_intro' => _act0LessonCardsV1('Qd Jd'),
    'paired_board_texture_lite_intro' => _act0LessonCardsV1('Kh 9s'),
    _ when phase == Act0LessonPhaseV1.review => _act0LessonCardsV1('Qh Qs'),
    _ => _heroQdQsCards,
  };
  final boardCards = phase == Act0LessonPhaseV1.review
      ? _act0LessonCardsV1('Qc Jd 5s')
      : _w7VisibleBoardCardsForSpecV1(spec);
  return _w6ComboCountsIntroRunner.copyWith(
    lessonId: spec.taskId,
    lessonTitle: 'Visible Cards Change Ranges',
    lessonSubtitle: 'Range Thinking',
    phase: phase,
    caption: spec.boardContext,
    hint: _w7LearnerHintV1(spec.taskId),
    question: spec.learnerPrompt,
    options: <Act0RunnerOptionV1>[
      for (final choiceId in spec.choiceIds)
        Act0RunnerOptionV1(
          id: choiceId,
          label: choiceId == 'pair_does_not_change_combos'
              ? 'The paired board leaves seven-containing combinations unchanged.'
              : spec.choiceLabels[choiceId]!,
          isCorrect: choiceId == spec.expectedChoiceId,
          preferredLabel: spec.choiceLabels[spec.expectedChoiceId]!,
          quality: choiceId == spec.expectedChoiceId
              ? Act0FeedbackQualityV1.correct
              : Act0FeedbackQualityV1.wrong,
          feedbackTitle: choiceId == spec.expectedChoiceId
              ? _w7LearnerFeedbackTitleV1(spec.taskId)
              : 'Recheck the visible cards.',
          feedbackReason: choiceId == spec.expectedChoiceId
              ? spec.feedbackReason
              : spec.incorrectFeedback[choiceId]!,
        ),
    ],
    feedbackTitle: _w7LearnerFeedbackTitleV1(spec.taskId),
    feedbackReason: spec.feedbackReason,
    table: _day7PostflopV1(
      'co',
      heroCards.map((card) => card.label).join(' '),
      boardCards.map((card) => card.label).join(' '),
      openBb: 2.5,
      checkedToHero: true,
      showTurn: true,
    ).copyWith(centerLabel: spec.boardContext),
    teachingSteps: <Act0TeachingStepV1>[
      Act0TeachingStepV1(
        title: _w7LearnerTheoryTitleV1(spec.taskId),
        body: phase == Act0LessonPhaseV1.theory
            ? 'If you see an ace, only three aces can be in another hand. '
                  'A-A drops from 6 combos to 3. A-K drops from 4 × 4 = 16 combos to 3 × 4 = 12.'
            : spec.learnerPrompt,
        focusLabels: <String>[spec.boardContext, 'What hands can still fit?'],
      ),
    ],
  );
}

String _w7LearnerTaskTitleV1(String taskId) => switch (taskId) {
  'visible_ace_combo_reduction_intro' => 'One ace is already out',
  'visible_king_combo_reduction_intro' => 'One king is already out',
  'paired_board_texture_lite_intro' => 'Read the paired board',
  'visible_card_combo_density_transfer_check' => 'Use the same table clue',
  _ => 'Read the visible cards',
};

String _w7LearnerHintV1(String taskId) => switch (taskId) {
  'paired_board_texture_lite_intro' => 'Start from what is still possible.',
  'visible_card_combo_density_transfer_check' => '',
  _ => 'A shown card cannot also be in a private hand.',
};

String _w7LearnerFeedbackTitleV1(String taskId) => switch (taskId) {
  'paired_board_texture_lite_intro' => 'Paired-board read.',
  'visible_card_combo_density_transfer_check' => 'Carry the clue forward.',
  _ => 'Count what is still possible.',
};

String _w7LearnerTheoryTitleV1(String taskId) => switch (taskId) {
  'paired_board_texture_lite_intro' => 'A pair on the board changes the count',
  'visible_card_combo_density_transfer_check' =>
    'The same clue works across boards',
  _ => 'Shown cards change the possible hands',
};

final _w8EffectiveStackSeatRunner = _w7EffectiveStackIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w8_effective_stack_seat',
  caption: 'You and one opponent reached the flop.',
  hint: '',
  question:
      'Tap the seat whose stack limits how much the two of you can still bet.',
  table: _act0BoardLessonTableV1(
    openingSeat: 'co',
    heroCards: _act0LessonCardsV1('Th Tc'),
    boardCards: _act0LessonCardsV1('9d 5c 2h'),
    centerLabel: 'Compare the stacks',
    heroBehindBb: 70,
    bbBehindBb: 18,
  ).copyWith(selectableSeatIds: const ['co', 'sb', 'bb']),
  teachingSteps: const [],
  options: const [
    Act0RunnerOptionV1(
      id: 'co',
      label: 'Your seat',
      seatId: 'co',
      isCorrect: false,
      preferredLabel: 'Big blind',
      betterAnswerLabel: 'Big blind',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Compare both live stacks.',
      feedbackReason:
          'From CO you have 70 BB left, but BB can match only 18 BB. Using your own stack overstates how much you can win from BB.',
    ),
    Act0RunnerOptionV1(
      id: 'bb',
      label: 'Big blind',
      seatId: 'bb',
      isCorrect: true,
      preferredLabel: 'Big blind',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'The smaller live stack.',
      feedbackReason:
          'You have 18 BB effective against BB. Your larger stack can match that amount, so 18 BB is the most either of you can still lose to the other.',
    ),
    Act0RunnerOptionV1(
      id: 'sb',
      label: 'Small blind',
      seatId: 'sb',
      isCorrect: false,
      preferredLabel: 'Big blind',
      betterAnswerLabel: 'Big blind',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Use the seats still in the hand.',
      feedbackReason:
          'SB folded before the flop. Using that stack hides the 18 BB limit on what the remaining opponent can pay.',
    ),
  ],
);

Act0RunnerStateV1 _w8StackSeatDecisionV1({
  required String id,
  required String caption,
  required String question,
  required Act0TableStateV1 table,
  required String answer,
  required Map<String, (String, String)> feedback,
}) {
  final preferred = feedback[answer]!.$1;
  final completedFlop = answer == table.heroSeatId;
  return _w8EffectiveStackSeatRunner.copyWith(
    lessonId: id,
    caption: caption,
    question: question,
    table: table.copyWith(
      activeSeatId: completedFlop ? '' : table.activeSeatId,
      clearDecisionSeatId: completedFlop,
      handContributions: table.handContributions,
      actionTrail: [
        ...table.actionTrail,
        if (completedFlop)
          Act0ActionTrailItemV1(label: '${answer.toUpperCase()} checks'),
      ],
      seats: completedFlop
          ? [
              for (final seat in table.seats)
                _act0CopySeatStateV1(seat, isActive: false, hasActed: true),
            ]
          : table.seats,
      highlightedSeatIds: const [],
      selectableSeatIds: feedback.keys.toList(),
    ),
    feedbackTitle: 'The smaller stack sets the limit.',
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
              ? 'The smaller stack sets the limit.'
              : 'Compare the chips behind each live seat.',
          feedbackReason: entry.value.$2,
        ),
    ],
  );
}

final _w8SprValueSizeRunner = _w7SprIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w8_spr_value_size',
  caption:
      'BB checked. In this example, BB calls up to 4 BB with weaker kings and folds to larger bets.',
  hint: '',
  question: 'Which bet wins the most chips when a weaker king calls?',
  table: _act0BoardLessonTableV1(
    openingSeat: 'co',
    heroCards: _act0LessonCardsV1('Ks Qc'),
    boardCards: _act0LessonCardsV1('Kd 8c 4h'),
    centerLabel: 'Choose a bet',
    heroBehindBb: 16,
    bbBehindBb: 18,
    openBb: 3.75,
  ),
  teachingSteps: const [],
  sizingConfig: const Act0SizingConfigV1(
    mode: Act0SizingUiModeV1.presetsOnly,
    showGuidance: false,
    presets: [
      Act0SizingPresetV1(id: 'two', label: '2 BB', potFraction: 0.25),
      Act0SizingPresetV1(id: 'four', label: '4 BB', potFraction: 0.5),
      Act0SizingPresetV1(id: 'eight', label: '8 BB', potFraction: 1),
    ],
  ),
  options: const [
    Act0RunnerOptionV1(
      id: 'two',
      label: '2 BB',
      isCorrect: false,
      preferredLabel: '4 BB',
      betterAnswerLabel: '4 BB',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'It gets called, but earns less.',
      feedbackReason:
          'Weaker kings call 2 BB in this example. Those same hands also call 4 BB, so betting 2 BB gives up 2 BB of value on each call.',
    ),
    Act0RunnerOptionV1(
      id: 'four',
      label: '4 BB',
      isCorrect: true,
      preferredLabel: '4 BB',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'The largest bet they call.',
      feedbackReason:
          'Your king and queen beat weaker kings here. BB pays up to 4 BB with those hands, so that is the largest bet that earns those calls.',
    ),
    Act0RunnerOptionV1(
      id: 'eight',
      label: '8 BB',
      isCorrect: false,
      preferredLabel: '4 BB',
      betterAnswerLabel: '4 BB',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'This price loses the weaker calls.',
      feedbackReason:
          'The 8 BB bet fits your stack, but BB folds weaker kings above 4 BB. You lose the extra chips those hands would have paid.',
    ),
  ],
);

final _stackDepthRiskLessons = <Act0LessonCardV1>[
  Act0LessonCardV1(
    lessonId: 'effective_stack_basics',
    title: 'Effective stack',
    subtitle: 'The smaller of two stacks caps what those players can match.',
    phaseLabel: 'Effective stack',
    primaryCtaLabel: 'Locked',
    state: Act0LessonStateV1.locked,
    isLocked: true,
    isSelectable: false,
    rewardXp: 40,
    runner: _w7EffectiveStackIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w7_effective_stack_intro',
        title: 'Smaller stack rules',
        phase: Act0LessonPhaseV1.theory,
        runner: _w7EffectiveStackIntroRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w7_effective_stack_30bb',
        title: '200 vs 30',
        phase: Act0LessonPhaseV1.drill,
        runner: _w7EffectiveStackThirtyRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _w7EffectiveStackThirtyRunner.options,
            correctOptionId: '30',
            correctIndex: 2,
          ),
        ),
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w7_effective_stack_100bb',
        title: '100 vs 100',
        phase: Act0LessonPhaseV1.drill,
        runner: _w7EffectiveStackEvenRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _w7EffectiveStackEvenRunner.options,
            correctOptionId: '100',
            correctIndex: 2,
          ),
        ),
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w7_table_effective_notice',
        title: 'Find the real risk',
        phase: Act0LessonPhaseV1.drill,
        runner: _w7EffectiveStackTableNoticeRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'w8_effective_stack_seat',
        title: 'Find the smaller live stack',
        phase: Act0LessonPhaseV1.drill,
        runner: _w8EffectiveStackSeatRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.compare,
      ),
      Act0LessonTaskV1(
        taskId: 'w8_hero_stack_cap_seat',
        title: 'Find the stack that caps the bet',
        phase: Act0LessonPhaseV1.drill,
        runner: _w8StackSeatDecisionV1(
          id: 'w8_hero_stack_cap_seat',
          caption:
              'Only you and the big blind saw the flop. Compare the chips behind.',
          question:
              'Tap the seat that caps how much either player can still win from the other.',
          table: _act0BoardLessonTableV1(
            openingSeat: 'hj',
            heroCards: _act0LessonCardsV1('Ac 9h'),
            boardCards: _act0LessonCardsV1('Ad 8s 4c'),
            centerLabel: 'Read the stacks',
            heroBehindBb: 22,
            bbBehindBb: 65,
          ),
          answer: 'hj',
          feedback: const {
            'hj': (
              'Hijack',
              'You have 22 BB left in HJ. BB can match those 22 BB, so that is the most either live seat can add against the other.',
            ),
            'sb': (
              'Small blind',
              'SB folded. Including that seat would use chips no live player can win during this flop.',
            ),
            'bb': (
              'Big blind',
              'BB can still bet 65 BB and you can match only 22 BB. Using 65 BB overstates how much BB could win from you by 43 BB.',
            ),
          },
        ),
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.compare,
      ),
      Act0LessonTaskV1(
        taskId: 'w7_effective_stack_recap',
        title: 'Effective stack recap',
        phase: Act0LessonPhaseV1.review,
        runner: _w7EffectiveStackRecapRunner,
        rewardXp: 15,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'same_hand_different_depth',
    title: 'Same hand, different depth',
    subtitle: 'Compare the room left for later bets at 20 BB and 100 BB.',
    phaseLabel: 'Depth shift',
    primaryCtaLabel: 'Locked',
    state: Act0LessonStateV1.locked,
    isLocked: true,
    isSelectable: false,
    rewardXp: 40,
    runner: _w7DepthShiftIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w7_depth_shift_intro',
        title: 'Depth changes the plan',
        phase: Act0LessonPhaseV1.theory,
        runner: _w7DepthShiftIntroRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w7_20bb_wider',
        title: '20 BB decision',
        phase: Act0LessonPhaseV1.drill,
        runner: _w7TwentyBbWiderRunner,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w7_100bb_tighter',
        title: '100 BB decision',
        phase: Act0LessonPhaseV1.drill,
        runner: _w7HundredBbTighterRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _w7HundredBbTighterRunner.options,
            correctOptionId: 'more_risk',
            correctIndex: 2,
          ),
        ),
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w7_40bb_middle',
        title: '40 BB middle plan',
        phase: Act0LessonPhaseV1.drill,
        runner: _w7FortyBbMiddleRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'w7_ajs_btn_25bb_transfer',
        title: 'A-J suited at 25 BB',
        phase: Act0LessonPhaseV1.drill,
        runner: _w7AjsButtonTwentyFiveBbRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _w7AjsButtonTwentyFiveBbRunner.options,
            correctOptionId: 'cleaner_shallow',
            correctIndex: 2,
          ),
        ),
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'w7_ajs_btn_100bb_transfer',
        title: 'A-J suited at 100 BB',
        phase: Act0LessonPhaseV1.drill,
        runner: _w7AjsButtonHundredBbRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'w7_depth_shift_recap',
        title: 'Depth recap',
        phase: Act0LessonPhaseV1.review,
        runner: _w7DepthShiftRecapRunner,
        rewardXp: 15,
        stepKind: Act0LessonStepKindV1.review,
      ),
      Act0LessonTaskV1(
        taskId: 'w8_pot_bet_committed_seat',
        title: 'Find who would be all-in',
        phase: Act0LessonPhaseV1.drill,
        runner: _w8StackSeatDecisionV1(
          id: 'w8_pot_bet_committed_seat',
          caption: 'Imagine you bet one pot and your opponent calls.',
          question:
              'Tap the seat that would have zero chips left after the call.',
          table: _act0BoardLessonTableV1(
            openingSeat: 'co',
            heroCards: _act0LessonCardsV1('Jc Td'),
            boardCards: _act0LessonCardsV1('Js 6h 2d'),
            centerLabel: 'Read the pot and stacks',
            openBb: 2.75,
            heroBehindBb: 42,
            bbBehindBb: 6,
          ),
          answer: 'bb',
          feedback: const {
            'co': (
              'Cutoff',
              'CO starts with 42 BB behind and would keep 36 BB after betting 6 BB. Selecting CO hides the remaining chips.',
            ),
            'bb': (
              'Big blind',
              'BB has 6 BB left. Calling the 6 BB bet would use that entire stack.',
            ),
            'sb': (
              'Small blind',
              'SB folded preflop, so no extra chips come from that seat after the flop bet.',
            ),
          },
        ),
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.compare,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'spr_and_commitment',
    title: 'Room or commitment',
    subtitle:
        'A smaller stack relative to the pot leaves fewer betting choices.',
    phaseLabel: 'SPR',
    primaryCtaLabel: 'Locked',
    state: Act0LessonStateV1.locked,
    isLocked: true,
    isSelectable: false,
    rewardXp: 40,
    runner: _w7SprIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w7_spr_intro',
        title: 'Low room vs high room',
        phase: Act0LessonPhaseV1.theory,
        runner: _w7SprIntroRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w7_low_spr_commit',
        title: 'SPR 2',
        phase: Act0LessonPhaseV1.drill,
        runner: _w7LowSprCommitRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _w7LowSprCommitRunner.options,
            correctOptionId: 'commit',
            correctIndex: 1,
          ),
        ),
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w7_high_spr_room',
        title: 'SPR 8',
        phase: Act0LessonPhaseV1.drill,
        runner: _w7HighSprRoomRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _w7HighSprRoomRunner.options,
            correctOptionId: 'room',
            correctIndex: 1,
          ),
        ),
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w8_spr_value_size',
        title: 'Choose a size for value',
        phase: Act0LessonPhaseV1.drill,
        runner: _w8SprValueSizeRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.sizing,
      ),
      Act0LessonTaskV1(
        taskId: 'w7_spr4_middle',
        title: 'SPR 4',
        phase: Act0LessonPhaseV1.drill,
        runner: _w7SprFourRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _w7SprFourRunner.options,
            correctOptionId: 'middle_spr',
            correctIndex: 2,
          ),
        ),
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'what_poker_is_side_pot_intro',
        title: 'Read the short stack limit',
        phase: Act0LessonPhaseV1.drill,
        runner: _sidePotIntroRunner.copyWith(
          caption:
              'You moved all-in. Both opponents had more chips and continued betting against each other.',
          hint: 'Use your stack, not the amount the opponents added later.',
          question:
              'What was the most either opponent could match against you?',
          feedbackTitle: 'The shorter stack sets the limit.',
          feedbackReason:
              'Each opponent could match up to your 20 BB. Any extra commitment was between the deeper stacks.',
          table: _sidePotIntroRunner.table.copyWith(
            centerLabel: 'Read the stack limit',
            highlightedSeatIds: const [],
          ),
          teachingSteps: const [],
          options: const <Act0RunnerOptionV1>[
            Act0RunnerOptionV1(
              id: 'hero_main_only',
              label: '20 BB',
              isCorrect: true,
              preferredLabel: '20 BB',
              quality: Act0FeedbackQualityV1.correct,
              feedbackTitle: 'Your stack capped the match at 20 BB.',
              feedbackReason:
                  'You went all-in for 20 BB, so that is all either bigger stack could match against you.',
            ),
            Act0RunnerOptionV1(
              id: 'hero_wins_everything',
              label: '50 BB',
              isCorrect: false,
              preferredLabel: '20 BB',
              betterAnswerLabel: '20 BB',
              quality: Act0FeedbackQualityV1.wrong,
              feedbackTitle: 'Use the smaller stack.',
              feedbackReason:
                  'The opponents each invested 50 BB, but their extra 30 BB was against each other. Each matched only your 20 BB.',
            ),
            Act0RunnerOptionV1(
              id: 'side_pot_is_penalty',
              label: '30 BB',
              isCorrect: false,
              preferredLabel: '20 BB',
              betterAnswerLabel: '20 BB',
              quality: Act0FeedbackQualityV1.wrong,
              feedbackTitle: 'Thirty was the additional amount.',
              feedbackReason:
                  'After matching you for 20 BB, the deeper stacks each put in 30 BB more against each other.',
            ),
          ],
        ),
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
        summary:
            'Find the short stack limit when deeper opponents keep betting.',
      ),
      Act0LessonTaskV1(
        taskId: 'w7_top_pair_spr2_transfer',
        title: 'Top pair at SPR 2',
        phase: Act0LessonPhaseV1.drill,
        runner: _w7TopPairSprTwoRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _w7TopPairSprTwoRunner.options,
            correctOptionId: 'faster_commitment',
            correctIndex: 1,
          ),
        ),
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.proveIt,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'w7_top_pair_spr8_transfer',
        title: 'Top pair at SPR 8',
        phase: Act0LessonPhaseV1.drill,
        runner: _w7TopPairSprEightRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _w7TopPairSprEightRunner.options,
            correctOptionId: 'room_and_risk',
            correctIndex: 2,
          ),
        ),
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'w7_spr_recap',
        title: 'SPR recap',
        phase: Act0LessonPhaseV1.review,
        runner: _w7SprRecapRunner,
        rewardXp: 15,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'format_pressure',
    title: '6-max vs full ring',
    subtitle: 'Compare opening from UTG at tables of different sizes.',
    phaseLabel: 'Format',
    primaryCtaLabel: 'Locked',
    state: Act0LessonStateV1.locked,
    isLocked: true,
    isSelectable: false,
    rewardXp: 45,
    runner: _w7FormatPressureIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w7_format_intro',
        title: 'Format changes pressure',
        phase: Act0LessonPhaseV1.theory,
        runner: _w7FormatPressureIntroRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w7_6max_wider',
        title: 'Checkpoint: act from first position',
        phase: Act0LessonPhaseV1.drill,
        runner: _w7SixMaxWiderRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _w7SixMaxWiderRunner.options,
            correctOptionId: '6max',
            correctIndex: 2,
          ),
        ),
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w7_fullring_tighter',
        title: 'Checkpoint: add three seats',
        phase: Act0LessonPhaseV1.drill,
        runner: _w7FullRingTighterRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w7_format_table_notice',
        title: 'Checkpoint: leave chips behind',
        phase: Act0LessonPhaseV1.drill,
        runner: _w7FormatTableNoticeRunner.copyWith(
          options: _act0AuthoredCorrectOptionAtV1(
            _w7FormatTableNoticeRunner.options,
            correctOptionId: 'tighten_early',
            correctIndex: 2,
          ),
        ),
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'w7_format_recap',
        title: 'Format recap',
        phase: Act0LessonPhaseV1.review,
        runner: _w7FormatRecapRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.review,
      ),
      Act0LessonTaskV1(
        taskId: 'w7_stack_checkpoint',
        title: 'Checkpoint: compare stack and pot',
        phase: Act0LessonPhaseV1.review,
        runner: _world7StackCheckpointRunner,
        rewardXp: 16,
        stepKind: Act0LessonStepKindV1.proveIt,
      ),
    ],
  ),
];

Act0RunnerStateV1 _w6FromCutoff(Act0RunnerStateV1 runner) {
  final original = runner.table;
  final table = _day7PostflopV1(
    'co',
    original.heroCards.map((card) => card.label).join(' '),
    original.boardCards.map((card) => card.label).join(' '),
    openBb: 2.5,
    checkedToHero: true,
    showTurn: true,
  ).copyWith(centerLabel: original.centerLabel);
  return runner.copyWith(table: table);
}

final _w6ContinuationBetIntro = _w6BoardFitIntroRunner.copyWith(
  lessonId: 'w6_continuation_bet',
  caption:
      'CO raised and BB called, then checked the flop. Read the three ranks and suits first. Ask which weaker hands could pay a small bet and which draws BB could continue with.',
  question: 'How does the flop change your next decision?',
  hint: '',
  feedbackTitle: 'Read the flop before betting.',
  feedbackReason:
      'CO can bet again after BB checks. A dry flop with a made hand gives weaker hands a reason to call a small bet.',
  options: const [],
  table: _day7PostflopV1(
    'co',
    'Ac Qd',
    'Ah 6s 2c',
    checkedToHero: true,
    showTurn: true,
  ),
  teachingSteps: const [
    Act0TeachingStepV1(
      title: 'Continuation bet, or c-bet',
      body:
          'A continuation bet is a flop bet by the player who last raised preflop. '
          'Against one caller who checks, a small bet is a good starting plan when you have a made hand on a dry flop. '
          'On a wet flop, check back if you missed and have no useful draw. '
          'The dry and wet textures tell you how many hands can connect, as in World 5. '
          'On a dry rainbow flop, a one-third-pot bet leaves weaker hands a smaller call. '
          'Connected two-tone flops give callers more ways to continue.',
    ),
  ],
);

final _w6ContinuationBetDry = _w6ContinuationBetIntro.copyWith(
  phase: Act0LessonPhaseV1.drill,
  caption: 'CO opened. BB called and checked on Q-7-2 rainbow. You have QJ.',
  question: 'Which size fits the small-bet plan when weaker queens can call?',
  feedbackTitle: 'One third of the pot.',
  feedbackReason:
      'In a 6 BB pot on Q-7-2 rainbow, top pair can use a 2 BB bet so weaker queens can call.',
  table: _day7PostflopV1(
    'co',
    'Qc Jc',
    'Qh 7s 2d',
    checkedToHero: true,
    showTurn: true,
  ),
  teachingSteps: const [],
  sizingConfig: const Act0SizingConfigV1(
    mode: Act0SizingUiModeV1.presetsOnly,
    showGuidance: false,
    presets: [
      Act0SizingPresetV1(id: 'bet_two', label: '2 BB', potFraction: 1 / 3),
      Act0SizingPresetV1(id: 'bet_six', label: '6 BB', potFraction: 1),
      Act0SizingPresetV1(id: 'bet_nine', label: '9 BB', potFraction: 1.5),
    ],
  ),
  options: const [
    Act0RunnerOptionV1(
      id: 'bet_two',
      label: '2 BB',
      isCorrect: true,
      preferredLabel: '2 BB',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'One third of the pot.',
      feedbackReason:
          'In the 6 BB pot on Q-7-2 rainbow, a 2 BB bet with top pair gives weaker queens a manageable price.',
    ),
    Act0RunnerOptionV1(
      id: 'bet_six',
      label: '6 BB',
      isCorrect: false,
      preferredLabel: '2 BB',
      betterAnswerLabel: '2 BB',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'That is a full-pot bet.',
      feedbackReason:
          'On this dry flop, a 6 BB bet with QJ can drive out the weaker queens you want to call.',
    ),
    Act0RunnerOptionV1(
      id: 'bet_nine',
      label: '9 BB',
      isCorrect: false,
      preferredLabel: '2 BB',
      betterAnswerLabel: '2 BB',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'That is bigger than the pot.',
      feedbackReason:
          'With QJ on Q-7-2, putting in 9 BB risks 7 BB more than the small bet and can leave you facing stronger hands.',
    ),
  ],
);

final _w6ContinuationBetValue = _w6ContinuationBetIntro.copyWith(
  phase: Act0LessonPhaseV1.drill,
  caption:
      'BB checked. In this example, weaker kings call bets of 3 BB or less.',
  hint: '',
  question: 'How much can you bet to get the most chips from those calls?',
  feedbackTitle: 'Use the highest price they pay.',
  feedbackReason: 'A weaker king calls 3 BB in this example and folds to 6 BB.',
  table: _day7PostflopV1(
    'co',
    'Kh Qh',
    'Kc 8d 3s',
    checkedToHero: true,
    showTurn: true,
  ),
  teachingSteps: const [],
  sizingConfig: const Act0SizingConfigV1(
    mode: Act0SizingUiModeV1.presetsOnly,
    showGuidance: false,
    presets: [
      Act0SizingPresetV1(
        id: 'bet_one_five',
        label: '1.5 BB',
        potFraction: 0.25,
      ),
      Act0SizingPresetV1(id: 'bet_six', label: '6 BB', potFraction: 1),
      Act0SizingPresetV1(id: 'bet_three', label: '3 BB', potFraction: 0.5),
    ],
  ),
  options: const [
    Act0RunnerOptionV1(
      id: 'bet_one_five',
      label: '1.5 BB',
      isCorrect: false,
      preferredLabel: '3 BB',
      betterAnswerLabel: '3 BB',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'The bet leaves value behind.',
      feedbackReason:
          'A weaker king calls 1.5 BB on K-8-3 in this example. If you pick that amount, you miss the extra 1.5 BB the same hand would pay.',
    ),
    Act0RunnerOptionV1(
      id: 'bet_six',
      label: '6 BB',
      isCorrect: false,
      preferredLabel: '3 BB',
      betterAnswerLabel: '3 BB',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'The weaker hands fold.',
      feedbackReason:
          'The 6 BB bet is the size of the pot. BB folds weaker kings at that price in this example, costing you their 3 BB calls.',
    ),
    Act0RunnerOptionV1(
      id: 'bet_three',
      label: '3 BB',
      isCorrect: true,
      preferredLabel: '3 BB',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Three is the largest bet they call.',
      feedbackReason:
          "Bet 3 BB because weaker kings call that much and your KQ beats them. Betting 1.5 BB collects half as much from the same hands.",
    ),
  ],
);

final _w6ContinuationBetWet = _w6ContinuationBetIntro.copyWith(
  phase: Act0LessonPhaseV1.review,
  caption:
      'CO opened. BB called and checked on J-T-9 with two hearts. You hold A4o.',
  question: 'What is the cleaner line with no pair or direct draw?',
  feedbackTitle: 'Take the free turn.',
  feedbackReason:
      'On J-T-9, A4o has no pair or direct draw. Checking keeps the chips you would risk on a bluff.',
  table: _day7PostflopV1(
    'co',
    'As 4d',
    'Jh Th 9c',
    checkedToHero: true,
    showTurn: true,
  ),
  teachingSteps: const [],
  options: const [
    Act0RunnerOptionV1(
      id: 'bet_small',
      label: 'Bet 2 BB',
      isCorrect: false,
      preferredLabel: 'Check',
      betterAnswerLabel: 'Check',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Look at what can continue.',
      feedbackReason:
          "A small bet costs 2 BB when BB can call with pairs and draws. Check A4o to keep that wager.",
    ),
    Act0RunnerOptionV1(
      id: 'check',
      label: 'Check',
      isCorrect: true,
      preferredLabel: 'Check',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Take the free turn.',
      feedbackReason:
          "Check A4o on J-T-9 because BB can continue with pairs, straights and draws. A bet of 2 BB risks chips against that range without a strong reason to expect folds.",
    ),
    Act0RunnerOptionV1(
      id: 'bet_large',
      label: 'Bet 6 BB',
      isCorrect: false,
      preferredLabel: 'Check',
      betterAnswerLabel: 'Check',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'A bigger bluff costs more.',
      feedbackReason:
          "A big bet costs 6 BB when BB can continue with pairs, straights and draws. Checking saves that wager.",
    ),
  ],
);

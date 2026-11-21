part of 'act0_shell_state_v1.dart';

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
    rewardXp: 35,
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
                    'KQ pairs the highest card on K-7-2. A weaker king can call a small bet.',
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
            correctIndex: 1,
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
            correctIndex: 1,
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
    rewardXp: 36,
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
          question: "What is a half-pot bet trying to achieve?",
          feedbackTitle: 'Read the range in this hand.',
          feedbackReason:
              "Q-9 has a worse kicker and 5-4 has a smaller pair. Both call in this example.",
          teachingSteps: const [],
          table: _act0BoardLessonTableV1(
            heroCards: _act0LessonCardsV1('Qd Tc'),
            boardCards: _act0LessonCardsV1('Qs 5h 2d'),
            centerLabel: 'Read the range',
          ),
          options: const <Act0RunnerOptionV1>[
            Act0RunnerOptionV1(
              id: 'value',
              label: "Get called by worse hands",
              isCorrect: true,
              preferredLabel: "Get called by worse hands",
              quality: Act0FeedbackQualityV1.correct,
              feedbackTitle: "A bet can earn weaker calls.",
              feedbackReason:
                  "Q-9 has a worse kicker and 5-4 has a smaller pair. Both call in this example.",
            ),
            Act0RunnerOptionV1(
              id: 'bluff',
              label: "Make stronger hands fold",
              isCorrect: false,
              preferredLabel: "Get called by worse hands",
              betterAnswerLabel: "Get called by worse hands",
              quality: Act0FeedbackQualityV1.wrong,
              feedbackTitle: "Read the hands that call.",
              feedbackReason:
                  "The hands named as calls are behind your pair of queens. That makes this a value bet.",
            ),
            Act0RunnerOptionV1(
              id: 'missed',
              label: "Give up on a missed flop",
              isCorrect: false,
              preferredLabel: "Get called by worse hands",
              betterAnswerLabel: "Get called by worse hands",
              quality: Act0FeedbackQualityV1.wrong,
              feedbackTitle: "You paired the queen.",
              feedbackReason:
                  "You have a pair of queens. Both of the named calls make weaker hands.",
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
              'On K-8-3, BB checks with pairs, Q-J, and A-9. In this example, BB calls a half-pot bet with a pair and folds both high-card hands. Check if you can already beat either high-card hand.',
          question: 'Which plan fits 9-6 under this rule?',
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
            correctIndex: 1,
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
              "The ace on the flop removes any combination containing that exact card. World 7 shows you how to count what remains.",
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
                  "The ace on the flop removes any combination containing that exact card. World 7 shows you how to count what remains.",
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
    ),
    _w7TurnPriceTaskV1(
      id: 'w7_clean_outs_higher_price',
      bet: 6,
      correctAt: 1,
      feedback:
          'You still win on 12 of 44 rivers, about 27%. To call 6 BB you need 6 of the final 20 BB, or 30%. The chance did not change; the price did.',
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
    ),
    _w7RiverTaskV1(
      id: 'w7_river_two_bluffs_of_six',
      range: 'K♥ Q♦, K♦ Q♣, A♥ Q♦, A♦ Q♣, J♥ T♥ or A♠ 8♠',
      correctAt: 0,
      feedback:
          'You win if BB has J♥ T♥ or A♠ 8♠. Two of six is about 33%, more than the 25% this same call needs.',
    ),
    _w7UnseenRiverTaskV1(),
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
        'make a straight. One win in four (25%) is below the roughly '
        '28% needed to call 5 BB for a final pot of 18 BB.',
    'The 2♠ is on the board. BB cannot have a pair of twos from that list. '
        'If BB has a pair of nines, you win. The three ten-eight hands '
        'make a straight. One win in four (25%) is below the roughly '
        '28% this call needs.',
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
}) => _w7AppliedTaskV1(
  id: id,
  title: 'A turn price',
  question: 'BB is all-in. Suppose BB holds K♣ Q♠. Call or fold?',
  caption: 'Compare your chance to win with the price.',
  table: _w7TurnPriceTableV1(bet),
  labels: const ['Call', 'Fold'],
  correctAt: correctAt,
  feedback: [feedback, feedback],
  family: Act0TaskFamilyV1.decision,
);

Act0LessonTaskV1 _w7RiverTaskV1({
  required String id,
  required String range,
  required int correctAt,
  required String feedback,
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
  feedback: [feedback, feedback],
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
          'With A4o on J-T-9, spending 2 BB can get called by pairs and draws that connected with those three cards.',
    ),
    Act0RunnerOptionV1(
      id: 'check',
      label: 'Check',
      isCorrect: true,
      preferredLabel: 'Check',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Take the free turn.',
      feedbackReason:
          'On J-T-9, A4o has no pair or direct draw. Checking behind keeps the 2 BB you would have put in for a small bet.',
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
          'Betting the 6 BB pot on J-T-9 risks another 6 BB while BB can continue with pairs, straights and draws.',
    ),
  ],
);

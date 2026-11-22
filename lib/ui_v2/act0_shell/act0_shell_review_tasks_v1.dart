part of 'act0_shell_state_v1.dart';

/// Review-only situations. They do not participate in course order or XP.
final act0NewReviewTasksV1 = <_SpacedReviewEntryV1>[
  (
    worldId: 'world_1',
    lessonId: 'fold_check_call_raise',
    conceptFamilyId: 'no_bet_yet',
    task: _noBetReviewTaskV1(
      id: 'spaced_review_check_turn_v1',
      street: 'Turn',
      caption:
          'BB and BTN both checked the flop. On the turn, BB checks again. BTN acts next.',
      question: 'How can BTN see the river without putting in chips?',
      board: const [
        Act0CardStateV1(rank: 'Q', suit: 'c'),
        Act0CardStateV1(rank: '5', suit: 'd', tone: Act0CardToneV1.red),
        Act0CardStateV1(rank: '3', suit: 's'),
        Act0CardStateV1(rank: 'K', suit: 'h', tone: Act0CardToneV1.red),
      ],
      laterActions: const [
        Act0ActionTrailItemV1(label: 'Flop: BTN checks'),
        Act0ActionTrailItemV1(label: 'Turn: BB checks'),
      ],
    ),
  ),
  (
    worldId: 'world_1',
    lessonId: 'fold_check_call_raise',
    conceptFamilyId: 'no_bet_yet',
    task: _noBetReviewTaskV1(
      id: 'spaced_review_check_river_v1',
      street: 'River',
      caption:
          'BB and BTN checked the flop and turn. On the river, BB checks. BTN acts next.',
      question: 'Which action gets BTN to showdown without adding chips?',
      board: const [
        Act0CardStateV1(rank: 'J', suit: 'c'),
        Act0CardStateV1(rank: '6', suit: 's'),
        Act0CardStateV1(rank: '4', suit: 'd', tone: Act0CardToneV1.red),
        Act0CardStateV1(rank: 'T', suit: 'c'),
        Act0CardStateV1(rank: '3', suit: 'h', tone: Act0CardToneV1.red),
      ],
      laterActions: const [
        Act0ActionTrailItemV1(label: 'Flop: BTN checks'),
        Act0ActionTrailItemV1(label: 'Turn: BB checks'),
        Act0ActionTrailItemV1(label: 'Turn: BTN checks'),
        Act0ActionTrailItemV1(label: 'River: BB checks'),
      ],
    ),
  ),
  ..._act0Day7ReviewTasksV1,
];

// Misses from the W1 rules check replay by their own source identity.
final act0W1RulesReviewTasksV1 = [
  for (final (index, question) in act0W1RulesQuestionsV1.indexed)
    (
      worldId: 'world_1',
      lessonId: question.lessonId,
      conceptFamilyId: question.taskId,
      task: Act0LessonTaskV1(
        taskId: question.taskId,
        title: question.topic,
        phase: Act0LessonPhaseV1.drill,
        rewardXp: 0,
        runner: question.runner(index),
      ),
    ),
];

String? act0NewReviewConceptFamilyV1(
  String worldId,
  String lessonId,
  String taskId,
) => act0NewReviewTasksV1
    .where(
      (entry) =>
          entry.worldId == worldId &&
          entry.lessonId == lessonId &&
          entry.task.taskId == taskId,
    )
    .firstOrNull
    ?.conceptFamilyId;

// Earlier W6 saves attached these authored card-counting tasks to a
// table-price fallback. Use their current Day 7 family for lookup while the
// existing due item keeps its schedule, history and exact task id.
String act0Day7FamilyForSavedSourceV1({
  required String worldId,
  required String lessonId,
  required String taskId,
  required String family,
}) {
  if (worldId != 'world_6' || family != 'pot_to_call') return family;
  return switch ((lessonId, taskId)) {
    (
      'range_combo_counts',
      'w6_ak_combos' || 'w6_pair_combos' || 'w6_combo_weight_compare',
    ) ||
    ('range_reading_review', 'range_checkpoint_combos') ||
    (
      'range_thinking_checkpoint',
      'w6_suited_offsuit_weight_compare' ||
          'w6_pair_vs_suited_weight_compare' ||
          'w6_checkpoint_table_combo_weight',
    ) => 'starting_hand_combinations',
    ('range_thinking_checkpoint', 'w6_checkpoint_table_best_five') =>
      'board_cards',
    _ => family,
  };
}

Act0LessonTaskV1? act0ReviewOnlyTaskV1(
  String worldId,
  String lessonId,
  String taskId,
) {
  for (final entry in act0NewReviewTasksV1.followedBy(
    act0W1RulesReviewTasksV1,
  )) {
    if (entry.worldId == worldId &&
        entry.lessonId == lessonId &&
        entry.task.taskId == taskId) {
      return entry.task;
    }
  }
  return null;
}

Act0LessonTaskV1 _noBetReviewTaskV1({
  required String id,
  required String street,
  required String caption,
  required String question,
  required List<Act0CardStateV1> board,
  required List<Act0ActionTrailItemV1> laterActions,
}) {
  final source = _act0W01ExplicitFreeCheckContextV1(_checkActionRunner);
  return Act0LessonTaskV1(
    taskId: id,
    title: 'A ${street.toLowerCase()} decision',
    phase: Act0LessonPhaseV1.drill,
    rewardXp: 0,
    runner: source.copyWith(
      caption: caption,
      question: question,
      hint: '',
      feedbackReason: street == 'Turn'
          ? 'BB checked the turn, so you can check to see one more card.'
          : 'BB checked the river, so checking takes both hands to showdown.',
      teachingSteps: const [],
      options: _act0AuthoredCorrectOptionAtV1(
        source.options,
        correctOptionId: 'check',
        correctIndex: street == 'Turn' ? 2 : 0,
      ),
      table: source.table.copyWith(
        streetLabel: street,
        emptyBoardLabel: '',
        boardCards: board,
        actionTrail: [...source.table.actionTrail, ...laterActions],
        handContributions: Act0HandContributionsV1(
          throughStreet: street == 'Turn'
              ? PokerStreet.turn
              : PokerStreet.river,
          entries: source.table.handContributions!.entries,
          startingStackBbBySeat:
              source.table.handContributions!.startingStackBbBySeat,
        ),
      ),
    ),
  );
}

import 'dart:convert';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_progress_store_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_gap_adjudication_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w1_rules_check_v1.dart';

import '../support/act0_source_choreography_test_wait_v1.dart';

// Long session through the real app shell on iPhone 14 Pro: a fresh learner
// goes through Worlds 1–7 by default, or 1–12 with
// --dart-define=ACT0_LONG_SESSION_FULL_ROUTE=true. The app is
// restarted in every world, and progress must carry on from where it stopped.
// ACT0_LONG_SESSION_W7_TO_W8 resumes a save at W7 for focused Q7 checks.
// Any exception thrown by the app fails the test.
const _continueKeys = [
  'act0_shell_feedback_continue_cta',
  'act0_shell_block_summary_continue_cta',
  'act0_shell_continue_cta',
  'act0_shell_welcome_primary_cta',
  'act0_shell_main_cta',
  'act0_academy_home_leaf_cta',
];

Future<void> _mount(WidgetTester t, {bool firstRun = false}) async {
  await t.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      home: Act0ShellPreviewScreenV1(
        key: UniqueKey(),
        initialTab: Act0ShellTabV1.home,
        showPlacementOnStart: firstRun,
      ),
    ),
  );
  await t.pumpAndSettle();
}

final _tapLog = <String>[];

Future<bool> _tapFirst(WidgetTester t, List<Finder> finders) async {
  for (final f in finders) {
    if (f.evaluate().isEmpty) continue;
    await t.ensureVisible(f.first);
    await t.pumpAndSettle();
    final hit = f.hitTestable();
    if (hit.evaluate().isEmpty) continue;
    _tapLog.add(RegExp(r"'([a-z0-9_]+)'").firstMatch('$f')?.group(1) ?? '?');
    await t.tap(hit.first, warnIfMissed: false);
    await t.pump(const Duration(milliseconds: 800));
    // Route assertions use the settled screen. Sample fewer intermediate
    // animation frames while preserving the real navigation and dwell timers.
    await t.pumpAndSettle(const Duration(milliseconds: 250));
    return true;
  }
  return false;
}

Future<void> _onboard(WidgetTester t, {required bool useRulesCheck}) async {
  Future<void> tap(String key) async {
    final button = find.byKey(Key(key)).hitTestable();
    expect(button, findsOneWidget);
    await t.tap(button);
    await t.pumpAndSettle();
  }

  if (useRulesCheck) {
    await tap('act0_shell_w1_start_check');
    for (final question in act0W1RulesQuestionsV1) {
      await tap('act0_shell_option_choice_${question.correctChoice}');
    }
    await tap('act0_shell_w1_rules_continue');
  } else {
    await tap('act0_shell_w1_start_basics');
  }
}

Future<Map<String, dynamic>> _saved(WidgetTester t) async {
  Map<String, dynamic>? result;
  await t.runAsync(() async {
    await Act0ProgressStoreV1(
      key: 'act0_shell_progress_v1',
      isValidPayload: (_) => false,
    ).flush().timeout(const Duration(seconds: 3));
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final head = prefs.getString('act0_shell_progress_v1_head');
    expect(head, isNotNull);
    expect(prefs.getString('act0_shell_progress_v1_backup'), head);
    expect(prefs.getString('act0_shell_progress_v1_recovery'), head);
    result =
        jsonDecode((jsonDecode(head!) as Map)['payload'] as String)
            as Map<String, dynamic>;
  });
  return result!;
}

Future<int> _openSavedCourseTask(
  WidgetTester t, {
  required String worldId,
  required String taskId,
}) async {
  final state = Act0ShellStateV1.sample;
  final world = state.worldById(worldId);
  final lesson = world.lessons.singleWhere(
    (lesson) => lesson.courseTaskList.any((task) => task.taskId == taskId),
  );
  final earlierLessons = [
    for (final earlierWorld in state.worlds.takeWhile(
      (candidate) => candidate.worldId != worldId,
    ))
      ...earlierWorld.lessons,
    ...world.lessons.takeWhile(
      (candidate) => candidate.lessonId != lesson.lessonId,
    ),
  ];
  final completed = [
    for (final earlier in earlierLessons) ...earlier.courseTaskList,
    ...lesson.courseTaskList.takeWhile((task) => task.taskId != taskId),
  ];
  final xp = completed.fold(0, (sum, task) => sum + task.rewardXp);
  SharedPreferences.setMockInitialValues({
    'act0_welcome_completed_v1': true,
    'intake_completed_v1': true,
    'act0_shell_progress_v1': jsonEncode({
      'schemaVersion': 20,
      'pendingDecisionAssistance': <Object>[],
      'learningEvidenceHistory': <Object>[],
      'learningEvidenceLineage': const Act0LearningEvidenceHistoryV1()
          .lineagePayload(),
      'durableRetentionHistory': <Object>[],
      'completedTaskIds': completed.map((task) => task.taskId).toList(),
      'completedLessonIds': earlierLessons
          .map((lesson) => lesson.lessonId)
          .toList(),
      'skippedTaskIds': <String>[],
      'earnedXp': xp,
      'selectedWorldId': worldId,
      'selectedLessonId': lesson.lessonId,
      'selectedTaskId': taskId,
    }),
  });
  t.view.physicalSize = const Size(393, 852);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  await _mount(t);
  await t.runAsync(() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
  });
  await t.pumpAndSettle();
  await _tapFirst(t, [find.text('Learn')]);
  expect(
    await _tapFirst(t, [
      find.byKey(const Key('act0_shell_current_mission_cta')),
      find.byKey(const Key('act0_academy_home_leaf_cta')),
    ]),
    isTrue,
    reason: t
        .widgetList<Text>(find.byType(Text))
        .map((text) => text.data)
        .whereType<String>()
        .take(25)
        .join(' | '),
  );
  final shell = find.byType(Act0LessonRunnerShellV1);
  expect(t.widget<Act0LessonRunnerShellV1>(shell).selectedTaskId, taskId);
  while (t.widget<Act0LessonRunnerShellV1>(shell).runner.activeTeachingStep !=
      null) {
    expect(
      await _tapFirst(t, [
        find.byKey(const Key('act0_shell_theory_continue_cta')),
        find.byKey(const Key('act0_shell_continue_cta')),
      ]),
      isTrue,
    );
  }
  await pumpSourceChoreographyToDecisionV1(
    t,
    t.widget<Act0LessonRunnerShellV1>(shell).runner.table,
  );
  return xp;
}

void main() {
  testWidgets('pre-L1 saved progress resumes at the first new prerequisite', (
    t,
  ) async {
    // In the previous route the all-in lesson came before ranks. This saved
    // learner completed the first three lessons and had not studied ranks.
    const oldCompleted = <String>[
      'what_poker_is_theory',
      'what_poker_is_find_hero',
      'what_poker_is_table_read_transfer',
      'what_poker_is_table_read_recheck',
      'first_table_guide_one_clear_choice',
      'first_table_guide_route_roles',
      'what_poker_is_pot_stack',
      'what_poker_is_win_ways',
      'what_poker_is_showdown_win',
      'what_poker_is_all_in_meaning',
      'what_poker_is_matched_chips_transfer',
      'what_poker_is_live_win_transfer',
      'what_poker_is_review',
      'cards_ranks_suits_theory',
      'cards_ranks_suits_rank_drill',
      'cards_ranks_suits_suit_drill',
      'cards_ranks_suits_private_board',
      'cards_ranks_suits_board_count',
      'cards_ranks_suits_best_five',
      'cards_ranks_suits_recap',
    ];
    const oldXp = 101;
    SharedPreferences.setMockInitialValues(<String, Object>{
      'act0_welcome_completed_v1': true,
      'intake_completed_v1': true,
      'act0_shell_progress_v1': jsonEncode({
        'schemaVersion': 20,
        'pendingDecisionAssistance': <Object>[],
        'learningEvidenceHistory': <Object>[],
        'learningEvidenceLineage': const Act0LearningEvidenceHistoryV1()
            .lineagePayload(),
        'durableRetentionHistory': <Object>[],
        'completedTaskIds': oldCompleted,
        'completedLessonIds': [
          'what_poker_is',
          'what_poker_is_content',
          'cards_ranks_suits',
        ],
        'skippedTaskIds': <String>[],
        'earnedXp': oldXp,
        'selectedWorldId': 'world_1',
        'selectedLessonId': 'cards_ranks_suits',
        'selectedTaskId': 'cards_ranks_suits_recap',
      }),
    });
    t.view.physicalSize = const Size(393, 852);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await _mount(t);
    await t.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await t.pumpAndSettle();
    expect(
      await _tapFirst(
        t,
        _continueKeys.map((key) => find.byKey(Key(key))).toList(),
      ),
      isTrue,
      reason: t
          .widgetList<Text>(find.byType(Text))
          .map((text) => text.data)
          .whereType<String>()
          .take(25)
          .join(' | '),
    );
    final runner = t.widget<Act0LessonRunnerShellV1>(
      find.byType(Act0LessonRunnerShellV1),
    );
    expect(runner.selectedTaskId, 'hand_rankings_theory');
    final saved = await _saved(t);
    expect((saved['completedTaskIds'] as List).toSet(), oldCompleted.toSet());
    expect(saved['earnedXp'], oldXp);
    expect(saved['skippedTaskIds'], isEmpty);
    expect(t.takeException(), isNull);
  });

  testWidgets('pre-Q9 save keeps World 2 credit and opens the new lesson', (
    t,
  ) async {
    const q9 = 'w2_narrow_three_bet';
    final state = Act0ShellStateV1.sample;
    final earlier = [
      for (final world in state.worlds.take(2))
        for (final lesson in world.lessons)
          if (lesson.lessonId != q9) lesson,
    ];
    final completed = [for (final lesson in earlier) ...lesson.courseTaskList];
    final xp = completed.fold(0, (sum, task) => sum + task.rewardXp);
    final w3 = state.worldById('world_3').lessons.first;
    SharedPreferences.setMockInitialValues({
      'act0_welcome_completed_v1': true,
      'intake_completed_v1': true,
      'act0_shell_progress_v1': jsonEncode({
        'schemaVersion': 20,
        'pendingDecisionAssistance': <Object>[],
        'learningEvidenceHistory': <Object>[],
        'learningEvidenceLineage': const Act0LearningEvidenceHistoryV1()
            .lineagePayload(),
        'durableRetentionHistory': <Object>[],
        'completedTaskIds': completed.map((task) => task.taskId).toList(),
        'completedLessonIds': earlier.map((lesson) => lesson.lessonId).toList(),
        'skippedTaskIds': <String>[],
        'earnedXp': xp,
        'selectedWorldId': 'world_3',
        'selectedLessonId': w3.lessonId,
        'selectedTaskId': w3.courseTaskList.first.taskId,
      }),
    });
    t.view.physicalSize = const Size(393, 852);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await _mount(t);
    await t.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await t.pumpAndSettle();
    expect(
      await _tapFirst(
        t,
        _continueKeys.map((key) => find.byKey(Key(key))).toList(),
      ),
      isTrue,
    );
    final runner = t.widget<Act0LessonRunnerShellV1>(
      find.byType(Act0LessonRunnerShellV1),
    );
    expect(runner.selectedTaskId, '${q9}_intro');
    final saved = await _saved(t);
    expect(
      saved['completedTaskIds'],
      unorderedEquals(completed.map((task) => task.taskId)),
    );
    expect(saved['earnedXp'], xp);
    expect(saved['skippedTaskIds'], isEmpty);
  });

  testWidgets('pre-Q10 save keeps World 6 credit and opens the new lesson', (
    t,
  ) async {
    const q10 = 'w6_continuation_bet';
    final state = Act0ShellStateV1.sample;
    final earlier = [
      for (final world in state.worlds.take(6))
        for (final lesson in world.lessons)
          if (lesson.lessonId != q10) lesson,
    ];
    final completed = [for (final lesson in earlier) ...lesson.courseTaskList];
    final xp = completed.fold(0, (sum, task) => sum + task.rewardXp);
    final w7 = state.worldById('world_7').lessons.first;
    SharedPreferences.setMockInitialValues({
      'act0_welcome_completed_v1': true,
      'intake_completed_v1': true,
      'act0_shell_progress_v1': jsonEncode({
        'schemaVersion': 20,
        'pendingDecisionAssistance': <Object>[],
        'learningEvidenceHistory': <Object>[],
        'learningEvidenceLineage': const Act0LearningEvidenceHistoryV1()
            .lineagePayload(),
        'durableRetentionHistory': <Object>[],
        'completedTaskIds': completed.map((task) => task.taskId).toList(),
        'completedLessonIds': [
          for (final lesson in earlier)
            if (lesson.lessonId != 'range_reading_review') lesson.lessonId,
        ],
        'skippedTaskIds': <String>[],
        'earnedXp': xp,
        'selectedWorldId': 'world_7',
        'selectedLessonId': w7.lessonId,
        'selectedTaskId': w7.courseTaskList.first.taskId,
      }),
    });
    t.view.physicalSize = const Size(393, 852);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await _mount(t);
    await t.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await t.pumpAndSettle();
    expect(
      await _tapFirst(
        t,
        _continueKeys.map((key) => find.byKey(Key(key))).toList(),
      ),
      isTrue,
    );
    final runner = t.widget<Act0LessonRunnerShellV1>(
      find.byType(Act0LessonRunnerShellV1),
    );
    expect(runner.selectedTaskId, '${q10}_intro');
    final saved = await _saved(t);
    expect(
      saved['completedTaskIds'],
      unorderedEquals(completed.map((task) => task.taskId)),
    );
    expect(saved['earnedXp'], xp);
    expect(saved['skippedTaskIds'], isEmpty);
  });

  testWidgets('P8 keeps progress earned before the full hand moved', (
    tester,
  ) async {
    const earlierLessons = [
      'what_poker_is',
      'cards_ranks_suits',
      'hand_rankings_table',
      'hand_rankings_upper',
      'your_first_hand',
    ];
    final world = Act0ShellStateV1.sample.worldById('world_1');
    final completed = [
      for (final lesson in world.lessons)
        if (earlierLessons.contains(lesson.lessonId)) ...lesson.courseTaskList,
    ];
    final completedIds = completed.map((task) => task.taskId).toList();
    final xp = completed.fold(0, (sum, task) => sum + task.rewardXp);
    SharedPreferences.setMockInitialValues(<String, Object>{
      'act0_welcome_completed_v1': true,
      'intake_completed_v1': true,
      'act0_shell_progress_v1': jsonEncode({
        'schemaVersion': 20,
        'pendingDecisionAssistance': <Object>[],
        'learningEvidenceHistory': <Object>[],
        'learningEvidenceLineage': const Act0LearningEvidenceHistoryV1()
            .lineagePayload(),
        'durableRetentionHistory': <Object>[],
        'completedTaskIds': completedIds,
        'completedLessonIds': earlierLessons,
        'skippedTaskIds': <String>[],
        'earnedXp': xp,
        'selectedWorldId': 'world_1',
        'selectedLessonId': 'your_first_hand',
        'selectedTaskId': 'your_first_hand_recap',
      }),
    });
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await _mount(tester);
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pumpAndSettle();
    expect(
      await _tapFirst(
        tester,
        _continueKeys.map((key) => find.byKey(Key(key))).toList(),
      ),
      isTrue,
      reason: tester
          .widgetList<Text>(find.byType(Text))
          .map((text) => text.data)
          .whereType<String>()
          .take(25)
          .join(' | '),
    );
    final runner = tester.widget<Act0LessonRunnerShellV1>(
      find.byType(Act0LessonRunnerShellV1),
    );
    expect(runner.selectedLessonId, 'blinds_action_order');
    final saved = await _saved(tester);
    expect(saved['completedTaskIds'], unorderedEquals(completedIds));
    expect(saved['earnedXp'], xp);
    expect(saved['skippedTaskIds'], isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('W9 shows its short-stack premise before answering', (t) async {
    await _openSavedCourseTask(
      t,
      worldId: 'world_9',
      taskId: 'w9_short_stack_survival',
    );
    expect(
      find.text('You have 9 BB with blinds about to hit.'),
      findsOneWidget,
    );
    expect(find.text('Very short stacks cannot wait forever.'), findsNothing);
    expect(
      find.byKey(const Key('act0_shell_option_take_spot')).hitTestable(),
      findsOneWidget,
    );
  });

  testWidgets('W9 long inline history keeps the current decision playable', (
    t,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    t.view.physicalSize = const Size(393, 852);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    await t.pumpWidget(
      const MaterialApp(
        locale: Locale('en'),
        home: Act0ShellPreviewScreenV1(
          initialPhase: Act0LessonPhaseV1.drill,
          showPlacementOnStart: false,
          debugHarnessEntry: Act0ShellDebugHarnessEntryV1(
            mode: Act0ControlledDemoCaptureModeV1.directState,
            surface: Act0ControlledDemoCaptureSurfaceV1.runnerDrill,
            worldId: 'world_9',
            lessonId: 'bubble_risk_premium',
            taskId: 'w9_bubble_table_risk_transfer',
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    final runner = t.widget<Act0LessonRunnerShellV1>(
      find.byType(Act0LessonRunnerShellV1),
    );
    expect(runner.selectedTaskId, 'w9_bubble_table_risk_transfer');
    await pumpSourceChoreographyToDecisionV1(t, runner.runner.table);
    expect(
      find.descendant(
        of: find.byKey(const Key('act0_shell_center_pot_stat')),
        matching: find.text('Pot 21 BB'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_center_to_call_stat')),
      findsNothing,
    );
    final history = find.byKey(const Key('act0_shell_street_replay_scroll'));
    expect(history, findsOneWidget);
    final scroll = t.state<ScrollableState>(
      find.descendant(of: history, matching: find.byType(Scrollable)),
    );
    expect(scroll.position.maxScrollExtent, greaterThan(0));
    expect(scroll.position.pixels, 0);
    final correct = runner.runner.options.singleWhere(
      (option) => option.isCorrect,
    );
    final answer = find.byKey(Key('act0_shell_option_${correct.id}'));
    expect(answer.hitTestable(), findsOneWidget);
    await t.tap(answer);
    await t.pumpAndSettle();
    expect(
      find.byKey(const Key('act0_shell_feedback_continue_cta')),
      findsOneWidget,
    );
    expect(t.takeException(), isNull);
  });

  testWidgets(
    'W8 exact replay describes the same question without a board clue',
    (t) async {
      const taskId = 'w7_effective_stack_30bb';
      await _openSavedCourseTask(t, worldId: 'world_8', taskId: taskId);
      expect(
        await _tapFirst(t, [find.byKey(const Key('act0_shell_option_200'))]),
        isTrue,
      );

      final state = t.state(find.byType(Act0ShellPreviewScreenV1)) as dynamic;
      final replay =
          state.debugReviewSupportCopySnapshotV1() as Map<String, Object?>;
      expect(replay['targetTaskId'], taskId);
      expect(replay['lineKind'], 'exact_replay_repair');
      expect(replay['renderedLine'], 'Try this question again.');
    },
  );

  testWidgets('a correct W5 retry offers to continue the lesson', (t) async {
    const taskId = 'board_texture_basics_w5_dry_board';
    await _openSavedCourseTask(t, worldId: 'world_5', taskId: taskId);
    final cta = find.byKey(const Key('act0_shell_feedback_continue_cta'));

    expect(
      await _tapFirst(t, [find.byKey(const Key('act0_shell_option_wet'))]),
      isTrue,
    );
    expect(
      find.descendant(of: cta, matching: find.text('Try same clue')),
      findsOneWidget,
    );
    expect(await _tapFirst(t, [cta]), isTrue);
    expect(
      await _tapFirst(t, [find.byKey(const Key('act0_shell_option_dry'))]),
      isTrue,
    );

    expect(
      find.descendant(of: cta, matching: find.text('Continue')),
      findsOneWidget,
    );
    expect(find.text('Try the same table clue once more.'), findsNothing);
    expect(await _tapFirst(t, [cta]), isTrue);
    expect(
      t
          .widget<Act0LessonRunnerShellV1>(find.byType(Act0LessonRunnerShellV1))
          .selectedTaskId,
      'board_texture_basics_w5_wet_board',
    );
  });

  testWidgets('a W7 king miss persists the same exercise for replay', (
    t,
  ) async {
    const taskId = 'visible_king_combo_reduction_intro';
    final xp = await _openSavedCourseTask(
      t,
      worldId: 'world_7',
      taskId: taskId,
    );
    expect(
      await _tapFirst(t, [
        find.byKey(const Key('act0_shell_option_king_combos_unchanged')),
      ]),
      isTrue,
    );
    Map<dynamic, dynamic> repair(Map<String, dynamic> snapshot) =>
        (snapshot['openRepairIntents'] as List).cast<Map>().singleWhere(
          (row) => row['sourceTaskId'] == taskId,
        );
    final before = await _saved(t);
    final intent = repair(before);
    expect(intent['targetTaskId'], taskId);
    expect(intent['mappingType'], 'intentional_exact');
    expect(intent['repairOccurrenceId'], isNotEmpty);
    expect(before['earnedXp'], xp);

    await _mount(t);
    final restored = await _saved(t);
    expect(repair(restored), intent);
    expect(restored['earnedXp'], xp);
    expect(restored['completedTaskIds'], before['completedTaskIds']);
  });

  testWidgets('a W6 suited-combo miss opens the earlier suited comparison', (
    t,
  ) async {
    const taskId = 'w6_checkpoint_table_best_five';
    const targetId = 'w6_pair_vs_suited_weight_compare';
    final firstSuitedComparison = act0RepairGoalContractForSourceV1(
      worldId: 'world_6',
      lessonId: 'range_thinking_checkpoint',
      taskId: targetId,
      choiceId: 'kq_suited',
    );
    expect(firstSuitedComparison?.targetTaskId, targetId);
    expect(firstSuitedComparison?.mappingType, 'intentional_exact');
    final xp = await _openSavedCourseTask(
      t,
      worldId: 'world_6',
      taskId: taskId,
    );
    expect(
      await _tapFirst(t, [
        find.byKey(const Key('act0_shell_option_hero_wins')),
      ]),
      isTrue,
    );

    Map<dynamic, dynamic> sourceRepair(Map<String, dynamic> saved) =>
        (saved['openRepairIntents'] as List).cast<Map>().singleWhere(
          (row) => row['sourceTaskId'] == taskId,
        );
    Map<dynamic, dynamic> sourceAnswer(Map<String, dynamic> saved) =>
        (saved['learningEvidenceHistory'] as List).cast<Map>().singleWhere(
          (row) => row['taskId'] == taskId,
        );
    final before = await _saved(t);
    expect(sourceRepair(before)['targetTaskId'], targetId);
    expect(sourceAnswer(before)['choiceId'], 'hero_wins');
    expect(sourceAnswer(before)['isCorrect'], isFalse);
    expect(before['earnedXp'], xp);
    expect(
      await _tapFirst(t, [
        find.byKey(const Key('act0_shell_feedback_continue_cta')),
      ]),
      isTrue,
    );
    expect(
      t
          .widget<Act0LessonRunnerShellV1>(find.byType(Act0LessonRunnerShellV1))
          .selectedTaskId,
      targetId,
    );

    await _mount(t);
    final restored = await _saved(t);
    expect(sourceRepair(restored), sourceRepair(before));
    expect(sourceAnswer(restored), sourceAnswer(before));
    expect(restored['earnedXp'], xp);
    expect(restored['completedTaskIds'], before['completedTaskIds']);
  });

  for (final (name, worldId, taskId, choiceId, targetId) in const [
    (
      'a W9 yellow-zone miss reopens yellow-zone planning',
      'world_9',
      'w9_m_ratio_table_window_transfer',
      'wait_for_red',
      'w9_m_ratio_yellow_zone',
    ),
    (
      'a W10 blind-overfold miss reopens the one-lever exercise',
      'world_10',
      'w10_checkpoint_table_notice',
      'rewrite_everything',
      'w10_vs_nit_open_wider',
    ),
    (
      'a W11 planning miss reopens choosing one session focus',
      'world_11',
      'w11_checkpoint_plan_line',
      'complex_plan',
      'w11_plan_focus_choice',
    ),
    (
      'a W12 outcome-bias miss reopens reviewing the decision',
      'world_12',
      'w12_checkpoint_process_line',
      'outcome_only',
      'w12_good_fold_bad_result',
    ),
  ]) {
    testWidgets(name, (t) async {
      final xp = await _openSavedCourseTask(
        t,
        worldId: worldId,
        taskId: taskId,
      );
      expect(
        await _tapFirst(t, [find.byKey(Key('act0_shell_option_$choiceId'))]),
        isTrue,
      );

      Map<dynamic, dynamic> sourceRepair(Map<String, dynamic> saved) =>
          (saved['openRepairIntents'] as List).cast<Map>().singleWhere(
            (row) => row['sourceTaskId'] == taskId,
          );
      final before = await _saved(t);
      final intent = sourceRepair(before);
      expect(intent['targetTaskId'], targetId);
      expect(intent['mappingType'], 'repair');
      expect(before['earnedXp'], xp);
      expect(
        await _tapFirst(t, [
          find.byKey(const Key('act0_shell_feedback_continue_cta')),
        ]),
        isTrue,
      );
      expect(
        t
            .widget<Act0LessonRunnerShellV1>(
              find.byType(Act0LessonRunnerShellV1),
            )
            .selectedTaskId,
        targetId,
      );

      await _mount(t);
      final restored = await _saved(t);
      expect(sourceRepair(restored), intent);
      expect(
        restored['learningEvidenceHistory'],
        before['learningEvidenceHistory'],
      );
      expect(restored['earnedXp'], xp);
      expect(restored['completedTaskIds'], before['completedTaskIds']);
    });
  }

  testWidgets('pre-Q8 save keeps Position Thinking credit', (t) async {
    const insertedTasks = {
      'position_six_seats_position_order_reason',
      'button_advantage_button_order_reason',
    };
    final state = Act0ShellStateV1.sample;
    final priorLessons = [
      for (final world in state.worlds.take(3))
        for (final lesson in world.lessons)
          if (lesson.lessonId != 'w3_play_from_blinds') lesson,
    ];
    final priorTasks = [
      for (final lesson in priorLessons)
        for (final task in lesson.courseTaskList)
          if (!insertedTasks.contains(task.taskId)) task,
    ];
    final priorXp = priorTasks.fold(0, (sum, task) => sum + task.rewardXp);
    final w4 = state.worldById('world_4').lessons.first;
    SharedPreferences.setMockInitialValues({
      'act0_welcome_completed_v1': true,
      'intake_completed_v1': true,
      'act0_shell_progress_v1': jsonEncode({
        'schemaVersion': 20,
        'pendingDecisionAssistance': <Object>[],
        'learningEvidenceHistory': <Object>[],
        'learningEvidenceLineage': const Act0LearningEvidenceHistoryV1()
            .lineagePayload(),
        'durableRetentionHistory': <Object>[],
        'completedTaskIds': priorTasks.map((task) => task.taskId).toList(),
        'completedLessonIds': priorLessons
            .map((lesson) => lesson.lessonId)
            .toList(),
        'skippedTaskIds': <String>[],
        'earnedXp': priorXp,
        'selectedWorldId': 'world_4',
        'selectedLessonId': w4.lessonId,
        'selectedTaskId': w4.courseTaskList.first.taskId,
      }),
    });
    t.view.physicalSize = const Size(393, 852);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await _mount(t);
    await t.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await t.pumpAndSettle();
    expect(
      await _tapFirst(
        t,
        _continueKeys.map((key) => find.byKey(Key(key))).toList(),
      ),
      isTrue,
    );
    final runner = t.widget<Act0LessonRunnerShellV1>(
      find.byType(Act0LessonRunnerShellV1),
    );
    expect(runner.selectedTaskId, 'position_six_seats_position_order_reason');
    final saved = await _saved(t);
    expect(
      saved['completedTaskIds'],
      unorderedEquals(priorTasks.map((task) => task.taskId)),
    );
    expect(saved['earnedXp'], priorXp);
    expect(saved['skippedTaskIds'], isEmpty);
  });

  const fullRoute = bool.fromEnvironment('ACT0_LONG_SESSION_FULL_ROUTE');
  const w7ToW8 = bool.fromEnvironment('ACT0_LONG_SESSION_W7_TO_W8');
  const lastWorld = w7ToW8 ? 8 : (fullRoute ? 12 : 7);
  for (final firstWorld in w7ToW8 ? [7] : (fullRoute ? [1, 2] : [1])) {
    final expectedWorlds = {
      for (var world = firstWorld; world <= lastWorld; world++) world,
    };
    final useRulesCheck = firstWorld == 2;
    testWidgets(
      'a ${w7ToW8 ? 'returning' : 'fresh'} learner finishes W$firstWorld–W$lastWorld with mistakes, retries and restarts',
      (t) async {
        SharedPreferences.setMockInitialValues(<String, Object>{});
        t.view.physicalSize = const Size(393, 852);
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.resetPhysicalSize);
        addTearDown(t.view.resetDevicePixelRatio);
        final worlds = Act0ShellStateV1.sample.worlds
            .where(
              (w) => w.worldNumber >= firstWorld && w.worldNumber <= lastWorld,
            )
            .toList();
        final taskWorld = {
          for (final w in worlds)
            for (final l in w.lessons)
              for (final task in l.courseTaskList) task.taskId: w.worldNumber,
        };
        final repairWorld = {
          for (final w in worlds)
            for (final l in w.lessons)
              for (final task in l.taskList)
                if (task.repairOnly) task.taskId: w.worldNumber,
        };
        final rewards = {
          for (final w in worlds)
            for (final l in w.lessons)
              for (final task in l.taskList) task.taskId: task.rewardXp,
        };
        final answered = <String>{};
        final missedWorlds = <int>{};
        final confirmedMisses = <int>{};
        final restartedWorlds = <int>{};
        final enteredWorlds = <int>{};
        var complete = false;
        const w7Checkpoint = 'w7_checkpoint_river_card_excludes_hand';
        var priorXp = 0;
        if (w7ToW8) {
          priorXp = await _openSavedCourseTask(
            t,
            worldId: 'world_7',
            taskId: worlds.first.lessons.first.courseTaskList.first.taskId,
          );
        } else {
          await _mount(t, firstRun: true);
          await _onboard(t, useRulesCheck: useRulesCheck);
        }

        for (
          var step = 0;
          step < (fullRoute ? 5200 : 3600) && !complete;
          step++
        ) {
          Map<String, dynamic>? routeSnapshot;
          final runnerFinder = find.byType(Act0LessonRunnerShellV1);
          if (runnerFinder.evaluate().isNotEmpty) {
            final shell = t.widget<Act0LessonRunnerShellV1>(runnerFinder.first);
            final runner = shell.runner;
            final taskId = shell.selectedTaskId ?? '';
            final world = taskWorld[taskId] ?? repairWorld[taskId];
            if (world == null) break; // Never answer a future-world task.
            if (repairWorld.containsKey(taskId)) {
              expect(confirmedMisses, contains(world), reason: taskId);
            }
            if (enteredWorlds.add(world)) {
              if (!w7ToW8 && taskId == 'visible_ace_combo_reduction_intro') {
                expect(runner.phase, Act0LessonPhaseV1.theory);
                expect(runner.options, hasLength(4));
                expect(
                  find.byKey(
                    const Key('act0_shell_accessibility_answer_group'),
                  ),
                  findsNothing,
                );
                expect(
                  find.byKey(const Key('act0_shell_continue_cta')),
                  findsOneWidget,
                );
              }
              final snapshot = await _saved(t);
              final completed = (snapshot['completedTaskIds'] as List)
                  .cast<String>()
                  .toSet();
              final prerequisites = taskWorld.entries
                  .where((e) => e.value < world)
                  .map((e) => e.key)
                  .toSet();
              expect(
                completed.containsAll(prerequisites),
                isTrue,
                reason:
                    'W$world unlocked before ${prerequisites.difference(completed)}',
              );
            }
            if (_tapLog.isEmpty || _tapLog.last != '@$taskId')
              _tapLog.add('@$taskId');
            final deciding =
                runner.phase == Act0LessonPhaseV1.drill &&
                runner.activeTeachingStep == null &&
                runner.selectedOptionId == null &&
                runner.options.isNotEmpty;
            if (deciding) {
              await pumpSourceChoreographyToDecisionV1(t, runner.table);
              final wrong = runner.options.where((o) => !o.isCorrect).toList();
              final injectMiss =
                  !missedWorlds.contains(world) &&
                  wrong.isNotEmpty &&
                  (world != 7 || taskId == w7Checkpoint);
              final choice = injectMiss
                  ? wrong.first
                  : runner.options.firstWhere((o) => o.isCorrect);
              if (injectMiss) missedWorlds.add(world);
              final tapped = await _tapFirst(t, [
                if (runner.sizingConfig.isEnabled)
                  find.byKey(Key('act0_shell_sizing_preset_${choice.id}')),
                find.byKey(Key('act0_shell_option_${choice.id}')),
                if (choice.seatId case final seatId?) ...[
                  find.byKey(Key('act0_shell_seat_tap_$seatId')),
                  find.descendant(
                    of: find.byKey(Key('act0_shell_seat_tap_$seatId')),
                    matching: find.text(seatId.toUpperCase()),
                  ),
                ],
              ]);
              expect(tapped, isTrue, reason: '$taskId: no answer');
              if (runner.sizingConfig.isEnabled) {
                expect(
                  await _tapFirst(t, [
                    find.byKey(const Key('act0_shell_sizing_confirm_cta')),
                  ]),
                  isTrue,
                );
              }
              if (injectMiss) {
                expect(
                  find.byKey(const Key('act0_shell_feedback_continue_cta')),
                  findsOneWidget,
                  reason: '$taskId should show a way to continue from feedback',
                );
                final missSnapshot = await _saved(t);
                final evidence =
                    (missSnapshot['learningEvidenceHistory'] as List)
                        .cast<Map>();
                expect(
                  evidence.any(
                    (r) => r['taskId'] == taskId && r['isCorrect'] == false,
                  ),
                  isTrue,
                );
                if (taskId == w7Checkpoint) {
                  expect(
                    find.textContaining('The 2♠ is on the board').last,
                    findsOneWidget,
                  );
                }
                confirmedMisses.add(world);
              }
              answered.add(taskId);
              final worldAnswered = answered
                  .where((id) => taskWorld[id] == world)
                  .length;
              final worldTotal = taskWorld.values
                  .where((n) => n == world)
                  .length;
              if (!restartedWorlds.contains(world) &&
                  (world == 7
                      ? taskId == w7Checkpoint && injectMiss
                      : worldAnswered >= worldTotal ~/ 2)) {
                final before = await _saved(t);
                await _mount(t);
                final after = await _saved(t);
                expect(after['completedTaskIds'], before['completedTaskIds']);
                expect(after['earnedXp'], before['earnedXp']);
                expect(after['selectedWorldId'], before['selectedWorldId']);
                expect(after['selectedTaskId'], before['selectedTaskId']);
                restartedWorlds.add(world);
                // A learner can return to Learn even while an open repair is shown on Home.
                await _tapFirst(t, [find.text('Learn').last]);
                await _tapFirst(t, [
                  find.byKey(const Key('act0_shell_current_mission_cta')),
                ]);
              }
              continue;
            }
          } else {
            routeSnapshot = await _saved(t);
            final completed = (routeSnapshot['completedTaskIds'] as List)
                .cast<String>()
                .toSet();
            complete = completed.containsAll(taskWorld.keys);
            if (complete) break;
          }
          // The summary can promote a saved review above the course route.
          // This traversal follows the map once the in-lesson retry is done.
          var moved = await _tapFirst(t, [
            if (find.text('Practice this clue').evaluate().isNotEmpty)
              find.byKey(const Key('act0_shell_block_summary_map_cta')),
            find.byKey(const Key('act0_shell_theory_continue_cta')),
            for (final key in _continueKeys) find.byKey(Key(key)),
          ]);
          final mission = find.byKey(
            const Key('act0_shell_current_mission_cta'),
          );
          final levels = find.byKey(const Key('act0_shell_levels_menu_button'));
          if (!moved &&
              find
                  .byKey(const Key('act0_academy_review_leaf'))
                  .evaluate()
                  .isNotEmpty) {
            await _tapFirst(t, [find.text('Learn').last]);
          }
          if (!moved && levels.evaluate().isNotEmpty) {
            routeSnapshot ??= await _saved(t);
            final completed = (routeSnapshot['completedTaskIds'] as List)
                .cast<String>()
                .toSet();
            final nextWorld = taskWorld.entries
                .firstWhere((entry) => !completed.contains(entry.key))
                .value;
            // A summary can open the map of the world just completed. Choose
            // the next unlocked world using the same menu a learner uses.
            if (routeSnapshot['selectedWorldId'] != 'world_$nextWorld') {
              expect(await _tapFirst(t, [levels]), isTrue);
              final world = find.byKey(Key('act0_shell_world_$nextWorld'));
              if (world.evaluate().isEmpty) {
                await t.scrollUntilVisible(
                  world,
                  250,
                  scrollable: find.descendant(
                    of: find.byKey(
                      const Key('act0_shell_worlds_content_scroll'),
                    ),
                    matching: find.byType(Scrollable),
                  ),
                );
              }
              expect(
                await _tapFirst(t, [world]),
                isTrue,
                reason: 'The level menu should offer W$nextWorld',
              );
            }
            moved = await _tapFirst(t, [mission]);
          }
          final visible = moved
              ? ''
              : t
                    .widgetList<Text>(find.byType(Text))
                    .map((widget) => widget.data)
                    .whereType<String>()
                    .take(18)
                    .join(' | ');
          expect(
            moved,
            isTrue,
            reason:
                'Step $step stalled; recent taps: ${_tapLog.reversed.take(12).toList()}; visible: $visible',
          );
        }
        final snapshot = await _saved(t);
        final completed = (snapshot['completedTaskIds'] as List)
            .cast<String>()
            .toSet();
        expect(taskWorld.keys.toSet().difference(completed), isEmpty);
        final w1Ids = Act0ShellStateV1.sample
            .worldById('world_1')
            .lessons
            .expand((lesson) => lesson.courseTaskList)
            .map((task) => task.taskId)
            .toSet();
        final expectedCount = w7ToW8 ? 43 : (fullRoute ? 393 : 275);
        expect(
          taskWorld.length,
          useRulesCheck ? expectedCount - w1Ids.length : expectedCount,
        );
        if (useRulesCheck) expect(completed.intersection(w1Ids), isEmpty);
        if (fullRoute && !w7ToW8) {
          expect(completed, contains('w12_checkpoint_full_loop_line'));
          expect(completed, contains('w12_checkpoint_review'));
        }
        expect(missedWorlds, expectedWorlds);
        expect(restartedWorlds, expectedWorlds);
        expect(snapshot['skippedTaskIds'], isEmpty);
        expect(
          snapshot['earnedXp'],
          completed.fold<int>(
            useRulesCheck
                ? act0W1RulesQuestionsV1.length *
                      Act0W1RulesResultV1.xpPerCorrectAnswer
                : priorXp,
            (sum, id) => sum + (rewards[id] ?? 0),
          ),
        );
        expect(confirmedMisses, expectedWorlds);
        if (fullRoute) {
          await _mount(t);
          final restored = await _saved(t);
          expect(restored['completedTaskIds'], snapshot['completedTaskIds']);
          expect(restored['earnedXp'], snapshot['earnedXp']);
        }
        expect(t.takeException(), isNull);
      },
      timeout: const Timeout(Duration(minutes: fullRoute ? 8 : 5)),
    );
  }
}

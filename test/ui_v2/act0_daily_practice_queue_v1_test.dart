import 'package:poker_analyzer/ui_v2/act0_shell/academy_leaves/act0_academy_practice_leaf_v1.dart';
import 'dart:convert';
import '../support/act0_y5d_catalog_contract_v1.dart';
import '../support/act0_w3_catalog_contract_v1.dart';
import '../support/act0_y5b_catalog_contract_v1.dart';
import '../support/act0_y5c_catalog_contract_v1.dart';

import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_curriculum_pilot_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_daily_practice_coverage_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_learning_time_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_daily_practice_queue_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_path_progress_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_gap_adjudication_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

import '../support/act0_wave6_contract_v1.dart';
import '../support/act0_cur04b_summary_contract_v1.dart';
import '../support/act0_route_practice_runner_test_v1.dart';
import '../support/act0_w11_wave4_contract_v1.dart';
import '../support/act0_w12_wave4_contract_v1.dart';

void main() {
  for (final pair in [
    (
      throughWorld: 6,
      firstTask: 'board_texture_basics_w5_dry_board',
      secondTask: 'w6_value_dry_board',
    ),
    (
      throughWorld: 8,
      firstTask: 'visible_king_combo_reduction_intro',
      secondTask: 'w7_effective_stack_30bb',
    ),
    (
      throughWorld: 10,
      firstTask: 'w9_cash_vs_tournament',
      secondTask: 'w10_nit_tag',
    ),
    (
      throughWorld: 12,
      firstTask: 'w11_plan_focus_choice',
      secondTask: 'w12_good_fold_bad_result',
    ),
  ]) {
    testWidgets(
      'Daily Practice serves completed W${pair.throughWorld - 1}–W${pair.throughWorld} drills and resumes',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(393, 852));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        const progressKey = 'act0_shell_progress_v1';
        final worlds = Act0ShellStateV1.sample.worlds;
        final secondWorld = worlds.singleWhere(
          (world) => world.worldNumber == pair.throughWorld,
        );
        final secondLesson = secondWorld.lessons.singleWhere(
          (lesson) => lesson.courseTaskList.any(
            (task) => task.taskId == pair.secondTask,
          ),
        );
        final upcomingTask = secondLesson.courseTaskList
            .skipWhile((task) => task.taskId != pair.secondTask)
            .skip(1)
            .first;
        final completed = [
          for (final world in worlds)
            if (world.worldNumber < pair.throughWorld)
              for (final lesson in world.lessons) ...lesson.courseTaskList,
          for (final lesson in secondWorld.lessons.takeWhile(
            (lesson) => lesson.lessonId != secondLesson.lessonId,
          ))
            ...lesson.courseTaskList,
          ...secondLesson.courseTaskList.takeWhile(
            (task) => task.taskId != upcomingTask.taskId,
          ),
        ];
        final completedIds = completed.map((task) => task.taskId).toList();
        final xp = completed.fold(0, (sum, task) => sum + task.rewardXp);
        SharedPreferences.setMockInitialValues({
          progressKey: jsonEncode({
            'schemaVersion': 17,
            'completedTaskIds': completedIds,
            'selectedWorldId': secondWorld.worldId,
            'selectedLessonId': secondLesson.lessonId,
            'selectedTaskId': upcomingTask.taskId,
            'earnedXp': xp,
            'lastActiveDay': '2026-11-21',
            'dailyCompletedTaskIds': [
              for (final task in completed)
                if (task.phase == Act0LessonPhaseV1.drill &&
                    task.taskId != pair.firstTask &&
                    task.taskId != pair.secondTask)
                  task.taskId,
            ],
          }),
        });

        Future<void> openDaily() async {
          await tester.pumpWidget(
            MaterialApp(
              key: UniqueKey(),
              home: Act0ShellPreviewScreenV1(
                initialTab: Act0ShellTabV1.home,
                showPlacementOnStart: false,
                clock: Act0FixedUtcClockV1(DateTime.utc(2026, 11, 21, 12)),
              ),
            ),
          );
          await tester.pumpAndSettle();
          await tester.tap(
            find.descendant(
              of: find.byKey(const Key('act0_shell_bottom_nav')),
              matching: find.text('Practice'),
            ),
          );
          await tester.pumpAndSettle();
          final start = find.byKey(
            const Key('act0_academy_practice_leaf_start'),
          );
          expect(start, findsOneWidget);
          await tester.ensureVisible(start);
          await tester.tap(start);
          await tester.pumpAndSettle();
        }

        Future<void> answer(String taskId) async {
          final shell = tester.widget<Act0LessonRunnerShellV1>(
            find.byType(Act0LessonRunnerShellV1),
          );
          expect(shell.selectedTaskId, taskId);
          final correct = shell.runner.options.singleWhere(
            (option) => option.isCorrect,
          );
          final button = find.byKey(Key('act0_shell_option_${correct.id}'));
          await tester.ensureVisible(button);
          await tester.tap(button);
          await tester.pumpAndSettle();
          await tester.pump(const Duration(milliseconds: 700));
          await tester.pumpAndSettle();
        }

        final secondFirst =
            pair.throughWorld == 12 && wave6ContractsV1.containsKey('world_11');
        await openDaily();
        await answer(secondFirst ? pair.secondTask : pair.firstTask);
        await openDaily();
        await answer(secondFirst ? pair.firstTask : pair.secondTask);
        final prefs = await SharedPreferences.getInstance();
        final saved = jsonDecode(prefs.getString(progressKey)!) as Map;
        expect(saved['completedTaskIds'], unorderedEquals(completedIds));
        expect(saved['earnedXp'], xp);
        expect(
          saved['dailyPracticeQueue']['answeredTaskIds'],
          containsAll([pair.firstTask, pair.secondTask]),
        );
        expect(
          saved['dailyPracticeQueue']['taskIds'],
          isNot(contains(upcomingTask.taskId)),
        );
      },
    );
  }

  for (final (lastWorld, day) in [
    (5, 21),
    (8, 22),
    (12, 23),
    if (act0CurriculumPilotEnabledV1) (18, 24),
  ]) {
    testWidgets(
      'generated Daily Practice through W$lastWorld advances and restores without course XP',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(393, 852));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        const progressKey = 'act0_shell_progress_v1';
        final date = '2026-11-$day';
        final worlds = Act0ShellStateV1.sample.worlds;
        final completed = [
          for (final world in worlds.take(lastWorld))
            for (final lesson in world.lessons) ...lesson.courseTaskList,
        ];
        final completedIds = completed.map((task) => task.taskId).toList();
        final xp = completed.fold(0, (total, task) => total + task.rewardXp);
        SharedPreferences.setMockInitialValues({
          progressKey: jsonEncode({
            'schemaVersion': 17,
            'completedTaskIds': completedIds,
            'selectedWorldId': worlds[lastWorld - 1].worldId,
            'selectedLessonId': worlds[lastWorld - 1].lessons.last.lessonId,
            'selectedTaskId':
                worlds[lastWorld - 1].lessons.last.courseTaskList.last.taskId,
            'earnedXp': xp,
            'lastActiveDay': date,
            'dailyCompletedTaskIds': completedIds,
          }),
        });

        Future<Act0LessonRunnerShellV1> openDaily() async {
          await tester.pumpWidget(
            MaterialApp(
              key: UniqueKey(),
              home: Act0ShellPreviewScreenV1(
                initialTab: Act0ShellTabV1.home,
                showPlacementOnStart: false,
                clock: Act0FixedUtcClockV1(DateTime.utc(2026, 11, day, 12)),
              ),
            ),
          );
          await tester.pumpAndSettle();
          await tester.tap(
            find.descendant(
              of: find.byKey(const Key('act0_shell_bottom_nav')),
              matching: find.text('Practice'),
            ),
          );
          await tester.pumpAndSettle();
          final start = find.byKey(
            const Key('act0_academy_practice_leaf_start'),
          );
          await tester.ensureVisible(start);
          await tester.tap(start);
          await tester.pumpAndSettle();
          return tester.widget<Act0LessonRunnerShellV1>(
            find.byType(Act0LessonRunnerShellV1),
          );
        }

        final first = await openDaily();
        final firstId = first.selectedTaskId!;
        final recipe = act0DailyDealRecipeV1(firstId)!;
        expect(completedIds, contains(recipe.sourceTaskId));
        if (lastWorld == 8) {
          expect(recipe.template, Act0DailyDealTemplateV1.lowSpr);
          expect(recipe.sourceTaskId, 'w7_low_spr_commit');
          expect(first.runner.table.boardCards, hasLength(3));
        }
        if (lastWorld == 18) {
          expect(act0IsPilotDailyDealSourceV1(recipe.sourceTaskId), isTrue);
          expect(act0PilotDailyDealTableIsValidV1(first.runner.table), isTrue);
        }
        final choice = first.runner.options.singleWhere(
          (option) => option.isCorrect,
        );
        final button = find.byKey(Key('act0_shell_option_${choice.id}'));
        await tester.ensureVisible(button);
        await tester.tap(button);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 700));
        await tester.pumpAndSettle();
        final prefs = await SharedPreferences.getInstance();
        final saved = jsonDecode(prefs.getString(progressKey)!) as Map;
        final queue = Act0DailyPracticeQueueV1.tryParse(
          saved['dailyPracticeQueue'],
        )!;
        if (!act0CurriculumPilotEnabledV1 && lastWorld == 12) {
          const oldFirst =
              'daily_deal_v1:20780:callPrice:price_checkpoint:w4_checkpoint_price';
          const oldQueue = <String, Object>{
            'taskIds': [
              oldFirst,
              'daily_deal_v1:20780:cleanOuts:table_trigger_multiway_and_spr:w11_multiway_dirty_outs',
              'daily_deal_v1:20780:open:hand_discipline_apply:apply_btn_open',
            ],
            'answeredTaskIds': [oldFirst],
            'cleanTaskIds': [oldFirst],
          };
          expect(
            utf8.encode(jsonEncode(queue.toPayload())),
            utf8.encode(jsonEncode(oldQueue)),
          );
        }
        expect(queue.answeredTaskIds, contains(firstId));
        expect(queue.nextTaskId, isNotNull);
        expect(saved['completedTaskIds'], unorderedEquals(completedIds));
        expect(saved['earnedXp'], xp);
        final next = await openDaily();
        expect(next.selectedTaskId, queue.nextTaskId);
        expect(next.selectedTaskId, isNot(firstId));
        expect(act0DailyDealRecipeV1(next.selectedTaskId!), isNotNull);
        if (lastWorld == 18) {
          final restored = act0DailyDealRecipeV1(next.selectedTaskId!)!;
          expect(act0IsPilotDailyDealSourceV1(restored.sourceTaskId), isTrue);
          expect(act0PilotDailyDealTableIsValidV1(next.runner.table), isTrue);
        }
      },
    );
  }

  test(
    'real queue keeps normal order, fills thin sets by skill, and replays oldest',
    () {
      final today = DateTime.utc(2026, 11, 24);
      final later = today.add(const Duration(hours: 1));
      final pool = {
        'z': ['Position play'],
        'c': ['Position play'],
        'b': ['Blind play'],
        'a': ['Board reading'],
      };
      Act0DailyPracticeQueueV1 build(
        Map<String, DateTime> history, [
        Set<String> practicedToday = const {},
      ]) => Act0DailyPracticeQueueV1.startCovered(
        pool,
        recentHistory: history,
        todayStartedAt: today,
        practicedToday: practicedToday,
      );
      final normal = build({});
      expect(normal.taskIds, ['z', 'c', 'b']);
      expect(normal.poolStatus, Act0DailyPracticeExhaustionStatusV1.fresh);
      expect(normal.toPayload().containsKey('poolStatus'), isFalse);

      final thin = build({'c': today, 'b': later, 'a': later});
      expect(thin.taskIds, ['z', 'a', 'b']);
      expect(thin.poolStatus, Act0DailyPracticeExhaustionStatusV1.recycling);
      final recycling = build({
        'z': today.subtract(const Duration(days: 1)),
        'c': today.subtract(const Duration(days: 2)),
        'b': today.subtract(const Duration(days: 3)),
        'a': today.subtract(const Duration(days: 4)),
      });
      expect(recycling.taskIds, ['a', 'b', 'c']);
      expect(recycling.includesRepeats, isTrue);

      final exhausted = build({'z': later, 'c': today, 'b': later, 'a': today});
      expect(exhausted.taskIds, ['a', 'c', 'b']);
      expect(exhausted.isExhausted, isTrue);
      final restored = Act0DailyPracticeQueueV1.tryParse(
        exhausted.answer('a', independentCorrect: true).toPayload(),
      )!;
      expect(restored.nextTaskId, 'c');
      expect(restored.isExhausted, isTrue);

      final legacy = build({}, pool.keys.toSet());
      expect(legacy.isExhausted, isTrue);
      expect(legacy.taskIds, ['a', 'b', 'c']);
    },
  );

  for (final exhausted in [false, true]) {
    testWidgets(
      'Completed W1–W12 offers ${exhausted ? "exhausted" : "thin"} repeat set without extra XP or streak',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(393, 852));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        const progressKey = 'act0_shell_progress_v1';
        final now = DateTime.utc(2026, 11, 24, 12);
        final day = act0DailyDealDayV1(now.toLocal());
        final worlds = Act0ShellStateV1.sample.worlds.take(12).toList();
        final completed = [
          for (final world in worlds)
            for (final lesson in world.lessons) ...lesson.courseTaskList,
        ];
        final completedIds = completed.map((task) => task.taskId).toList();
        const freshTaskId = 'what_poker_is_table_read_transfer';
        final xp = completed.fold(0, (sum, task) => sum + task.rewardXp);
        final generatedIds = [
          for (final world in worlds)
            for (final lesson in world.lessons)
              for (final task in lesson.courseTaskList)
                if (act0DailyDealTemplateForSourceV1(task.taskId)
                    case final template?)
                  act0DailyDealIdV1((
                    day: day,
                    template: template,
                    lessonId: lesson.lessonId,
                    sourceTaskId: task.taskId,
                  )),
        ];
        SharedPreferences.setMockInitialValues({
          progressKey: jsonEncode({
            'schemaVersion': 17,
            'completedTaskIds': completedIds,
            'selectedWorldId': worlds.last.worldId,
            'selectedLessonId': worlds.last.lessons.last.lessonId,
            'selectedTaskId':
                worlds.last.lessons.last.courseTaskList.last.taskId,
            'earnedXp': xp,
            'lastActiveDay': '2026-11-24',
            'lastEarnedDailyDay': '2026-11-24',
            'dailyCompletedRepCount': 3,
            'persistedStreakDays': 4,
            'dailyCompletedTaskIds': [
              ...completedIds.where((id) => exhausted || id != freshTaskId),
              ...generatedIds,
            ],
          }),
        });
        await tester.pumpWidget(
          MaterialApp(
            home: Act0ShellPreviewScreenV1(
              initialTab: Act0ShellTabV1.home,
              showPlacementOnStart: false,
              clock: Act0FixedUtcClockV1(now),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(
          find.descendant(
            of: find.byKey(const Key('act0_shell_bottom_nav')),
            matching: find.text('Practice'),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.text(
            exhausted
                ? 'All drills seen today — repeating the ones you saw longest ago.'
                : 'This set includes repeats to keep your skills fresh.',
          ),
          findsWidgets,
        );
        final start = find.byKey(const Key('act0_academy_practice_leaf_start'));
        await tester.ensureVisible(start);
        await tester.tap(start);
        await tester.pumpAndSettle();
        final shell = tester.widget<Act0LessonRunnerShellV1>(
          find.byType(Act0LessonRunnerShellV1),
        );
        final correct = shell.runner.options.singleWhere(
          (option) => option.isCorrect,
        );
        final button = find.byKey(Key('act0_shell_option_${correct.id}'));
        await tester.ensureVisible(button);
        await tester.tap(button);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 700));
        await tester.pumpAndSettle();
        final prefs = await SharedPreferences.getInstance();
        final saved = jsonDecode(prefs.getString(progressKey)!) as Map;
        final queue = Act0DailyPracticeQueueV1.tryParse(
          saved['dailyPracticeQueue'],
        )!;
        expect(queue.isExhausted, exhausted);
        expect(queue.includesRepeats, isTrue);
        if (!exhausted) expect(queue.taskIds.first, freshTaskId);
        expect(queue.taskIds, hasLength(3));
        expect(queue.answeredTaskIds, contains(shell.selectedTaskId));
        expect(queue.nextTaskId, isNotNull);
        expect(saved['completedTaskIds'], unorderedEquals(completedIds));
        expect(saved['earnedXp'], xp);
        expect(saved['dailyCompletedRepCount'], 3);
        expect(saved['persistedStreakDays'], 4);
      },
    );
  }

  test(
    'every W1–W12 drill can enter a finite distinct set and survive restart',
    () {
      var count = 0;
      for (final world in Act0ShellStateV1.sample.worlds.where(
        (w) => w.worldNumber <= act0DailyPracticeLastWorldV1,
      )) {
        final ids = [
          for (final lesson in world.lessons)
            for (final task in lesson.taskList)
              if (task.phase == Act0LessonPhaseV1.drill) task.taskId,
        ];
        expect(ids, isNotEmpty);
        for (var i = 0; i < ids.length; i++) {
          var queue = Act0DailyPracticeQueueV1.start([
            ...ids.skip(i),
            ...ids.take(i),
          ]);
          expect(queue.taskIds.first, ids[i]);
          final seen = <String>{};
          while (queue.nextTaskId != null) {
            expect(seen.add(queue.nextTaskId!), isTrue);
            queue = queue.answer(
              queue.nextTaskId!,
              independentCorrect: seen.length != 1,
            );
            queue = Act0DailyPracticeQueueV1.tryParse(
              jsonDecode(jsonEncode(queue.toPayload())),
            )!;
          }
          expect(seen, queue.taskIds.toSet());
          expect(queue.answeredTaskIds.length, 3);
          expect(queue.cleanTaskIds.length, 2);
          expect(queue.nextTaskId, isNull);
          count++;
        }
      }
      expect(
        count,
        311 +
            y5dNewChoicesV1.length +
            w3BlindVsBlindChoicesV1.length +
            y5bDrillCountV1 +
            y5cDrillCountV1 +
            w11Wave4ChoiceContractV1.length +
            w12Wave4ChoiceContractV1.length +
            cur04bSummaryChoicesV1.length +
            wave6CurrentRowsV1.values
                .where((row) => row['identity'][3] == 'drill')
                .length -
            wave6PreviousRowsV1.values
                .where((row) => row['identity'][3] == 'drill')
                .length,
      );
    },
  );

  test(
    'empty and small pools end without silently repeating; restart is explicit',
    () {
      expect(Act0DailyPracticeQueueV1.start([]).nextTaskId, isNull);
      for (final ids in [
        ['a'],
        ['a', 'b'],
        ['a', 'a', 'b'],
      ]) {
        var queue = Act0DailyPracticeQueueV1.start(ids);
        for (final id in ids.toSet()) {
          queue = queue.answer(id, independentCorrect: false);
          expect(
            identical(queue.answer(id, independentCorrect: true), queue),
            isTrue,
          );
        }
        expect(queue.nextTaskId, isNull);
        expect(queue.cleanTaskIds, isEmpty);
        final restarted = Act0DailyPracticeQueueV1.start(ids);
        expect(restarted.nextTaskId, 'a');
        expect(restarted.answeredTaskIds, isEmpty);
      }
    },
  );

  test(
    'today preference never loses an eligible spot or accepts stale membership',
    () {
      final queue = Act0DailyPracticeQueueV1.start(
        ['a', 'b', 'c', 'd'],
        practicedToday: {'a', 'c'},
      );
      expect(queue.taskIds, ['b', 'd', 'a']);
      expect(queue.isValidFor({'a', 'b', 'd'}), isTrue);
      expect(queue.isValidFor({'b', 'd'}), isFalse);
      expect(
        identical(queue.answer('d', independentCorrect: true), queue),
        isTrue,
      );
    },
  );

  test('malformed or non-prefix progress cannot skip practice', () {
    for (final raw in [
      null,
      {},
      {
        'taskIds': ['a', 'a'],
        'answeredTaskIds': [],
        'cleanTaskIds': [],
      },
      {
        'taskIds': ['a', 'b'],
        'answeredTaskIds': ['b'],
        'cleanTaskIds': [],
      },
      {
        'taskIds': ['a'],
        'answeredTaskIds': [],
        'cleanTaskIds': ['a'],
      },
      {
        'taskIds': ['a'],
        'answeredTaskIds': ['x'],
        'cleanTaskIds': [],
      },
      {
        'taskIds': ['a', 'b', 'c', 'd'],
        'answeredTaskIds': [],
        'cleanTaskIds': [],
      },
    ]) {
      expect(Act0DailyPracticeQueueV1.tryParse(raw), isNull);
    }
  });
  testWidgets(
    'Practice starts a finite set and preserves course XP across days',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(393, 852));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final beforeMidnight = DateTime(2026, 11, 19, 23, 59);
      const taskId = 'what_poker_is_table_read_transfer';
      const progressKey = 'act0_shell_progress_v1';
      SharedPreferences.setMockInitialValues({
        progressKey: jsonEncode({
          'schemaVersion': 17,
          'completedTaskIds': [taskId],
          'skippedTaskIds': [
            'what_poker_is_theory',
            'what_poker_is_find_hero',
            'first_table_guide_one_clear_choice',
            'w1_shared_card_access',
            'w1_chips_starting_pot',
            'w1_chips_matched_pot',
            'w1_chips_read_middle',
            'first_table_guide_first_decision',
          ],
          'selectedWorldId': 'world_1',
          'selectedLessonId': 'first_table_guide',
          'selectedTaskId': taskId,
          'earnedXp': 5,
          'lastActiveDay': '2026-11-19',
        }),
      });
      Future<void> mount(DateTime time) async {
        await tester.pumpWidget(
          MaterialApp(
            key: ValueKey(time),
            home: Act0ShellPreviewScreenV1(
              initialTab: Act0ShellTabV1.home,
              showPlacementOnStart: false,
              clock: Act0FixedUtcClockV1(time),
            ),
          ),
        );
        await tester.pumpAndSettle();
      }

      final daily = find.byKey(const Key('act0_academy_practice_leaf_start'));
      Future<void> openPractice() async {
        await tester.tap(
          find.descendant(
            of: find.byKey(const Key('act0_shell_bottom_nav')),
            matching: find.text('Practice'),
          ),
        );
        await tester.pumpAndSettle();
        expect(daily, findsOneWidget);
      }

      await mount(beforeMidnight);
      expect(find.byKey(const Key('act0_home_daily_practice')), findsNothing);
      await openPractice();
      await tester.ensureVisible(daily);
      await tester.tap(daily);
      await tester.pumpAndSettle();
      final answer = find.byKey(const Key('act0_shell_option_two_three_six'));
      await tester.ensureVisible(answer);
      await tester.tap(answer);
      await tester.pumpAndSettle();
      // Short sets use the existing rapid feedback advance.
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byKey(const Key('act0_shell_bottom_nav')),
          matching: find.text('Home'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('act0_home_daily_practice')), findsNothing);
      final prefs = await SharedPreferences.getInstance();
      var saved =
          jsonDecode(prefs.getString(progressKey)!) as Map<String, dynamic>;
      expect(saved['dailyCompletedRepCount'], 1);
      expect(saved['earnedXp'], 5);

      await mount(DateTime(2026, 11, 22, 0, 1));
      await openPractice();
      expect(find.text('Start new set'), findsNothing);
      saved = jsonDecode(prefs.getString(progressKey)!) as Map<String, dynamic>;
      expect(saved['completedTaskIds'], [taskId]);
      expect(saved['earnedXp'], 5);
    },
  );

  testWidgets(
    'Home opens required practice and Practice offers a voluntary daily set after three lessons',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(393, 852));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      const progressKey = 'act0_shell_progress_v1';
      final w1 = Act0ShellStateV1.sample.worldById('world_1');
      final lesson1 = w1.lessons[0];
      final lesson2 = w1.lessons[1];
      final lesson3 = w1.lessons[2];
      final lesson4 = w1.lessons[3];
      final preThirdTasks = [
        ...lesson1.courseTaskList,
        ...lesson2.courseTaskList,
        ...lesson3.courseTaskList.take(lesson3.courseTaskList.length - 1),
      ];
      final xp = preThirdTasks.fold<int>(0, (sum, t) => sum + t.rewardXp);
      final dayOne = DateTime.utc(2026, 11, 21, 10);

      SharedPreferences.setMockInitialValues({
        'act0_welcome_completed_v1': true,
        'intake_completed_v1': true,
        progressKey: jsonEncode({
          'schemaVersion': 20,
          'learningEvidenceHistory': <Object>[],
          'learningEvidenceLineage': const Act0LearningEvidenceHistoryV1()
              .lineagePayload(),
          'durableRetentionHistory': <Object>[],
          'pendingDecisionAssistance': <Object>[],
          'completedTaskIds': preThirdTasks.map((t) => t.taskId).toList(),
          'completedLessonIds': [lesson1.lessonId, lesson2.lessonId],
          'dailyCompletedLessonIds': [lesson1.lessonId, lesson2.lessonId],
          'skippedTaskIds': <String>[],
          'earnedXp': xp,
          'selectedWorldId': 'world_1',
          'selectedLessonId': lesson3.lessonId,
          'selectedTaskId': lesson3.courseTaskList.last.taskId,
          'lastActiveDay': '2026-11-21',
          'dailyCompletedRepCount': 0,
        }),
      });

      Future<void> mountAt(DateTime time) async {
        await tester.pumpWidget(
          MaterialApp(
            key: ValueKey(time),
            home: Act0ShellPreviewScreenV1(
              initialTab: Act0ShellTabV1.home,
              showPlacementOnStart: false,
              clock: Act0FixedUtcClockV1(time),
            ),
          ),
        );
        await tester.pumpAndSettle();
      }

      await mountAt(dayOne);
      expect(find.text('Start lesson'), findsOneWidget);
      expect(find.text('Start daily set'), findsNothing);

      await tester.tap(find.byKey(const Key('act0_academy_home_leaf_cta')));
      await tester.pumpAndSettle();

      while (tester
              .widget<Act0LessonRunnerShellV1>(
                find.byType(Act0LessonRunnerShellV1),
              )
              .runner
              .activeTeachingStep !=
          null) {
        final theoryCta = find.byKey(
          const Key('act0_shell_theory_continue_cta'),
        );
        final target = theoryCta.evaluate().isNotEmpty
            ? theoryCta
            : find.byKey(const Key('act0_shell_continue_cta'));
        await tester.ensureVisible(target);
        await tester.tap(target);
        await tester.pumpAndSettle();
      }

      final runner = tester.widget<Act0LessonRunnerShellV1>(
        find.byType(Act0LessonRunnerShellV1),
      );
      expect(runner.selectedLessonId, lesson3.lessonId);
      final correct = runner.runner.options.singleWhere((o) => o.isCorrect);
      await tester.ensureVisible(
        find.byKey(Key('act0_shell_option_${correct.id}')),
      );
      await tester.tap(find.byKey(Key('act0_shell_option_${correct.id}')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('act0_shell_feedback_continue_cta')),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Act0BlockCompletionShellV1), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await tapAct0RoutePracticeKeyV1(tester, 'act0_shell_nav_home');

      expect(find.text('Start practice'), findsOneWidget);
      expect(find.text('Start daily set'), findsNothing);
      await tapAct0RoutePracticeKeyV1(tester, 'act0_academy_home_leaf_cta');
      expect(act0RoutePracticeFinder, findsOneWidget);
      final practice = tester.widget<Act0LessonRunnerShellV1>(
        find.byType(Act0LessonRunnerShellV1),
      );
      for (var index = 0; index < practice.runner.beatCount; index++) {
        await answerAct0RoutePracticeV1(tester, correct: true);
        await tapAct0RoutePracticeKeyV1(
          tester,
          'act0_shell_feedback_continue_cta',
        );
      }
      expect(act0RoutePracticeFinder, findsNothing);

      expect(find.text('Start lesson'), findsOneWidget);
      expect(find.text('Start daily set'), findsNothing);

      final prefs = await SharedPreferences.getInstance();
      final saved =
          jsonDecode(prefs.getString(progressKey)!) as Map<String, dynamic>;
      expect(
        (saved['dailyCompletedLessonIds'] as List).toSet(),
        equals({lesson1.lessonId, lesson2.lessonId, lesson3.lessonId}),
      );

      // Next lesson in Learn stays open and selectable.
      await tester.tap(
        find.descendant(
          of: find.byKey(const Key('act0_shell_bottom_nav')),
          matching: find.text('Learn'),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byKey(const Key('act0_shell_current_mission_card')),
          matching: find.text(lesson4.title),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_current_mission_cta')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('act0_shell_nav_play')));
      await tester.pumpAndSettle();
      final practiceLeaf = tester.widget<Act0AcademyPracticeLeafV1>(
        find.byType(Act0AcademyPracticeLeafV1),
      );
      final daily = practiceLeaf.input.groups.singleWhere(
        (group) => group.groupId == 'daily',
      );
      expect(daily.isEnabled, isTrue);
      final dailyStart = practiceLeaf.input.recommendedGroupId == 'daily'
          ? find.byKey(const Key('act0_academy_practice_leaf_start'))
          : find.byKey(const Key('act0_academy_practice_leaf_topic_daily'));
      if (dailyStart.evaluate().isEmpty) {
        await tester.scrollUntilVisible(dailyStart, 150);
      }
      await tester.ensureVisible(dailyStart);
      expect(dailyStart.hitTestable(), findsOneWidget);
      await tester.tap(dailyStart);
      await tester.pumpAndSettle();
      final dailyRunner = tester.widget<Act0LessonRunnerShellV1>(
        find.byType(Act0LessonRunnerShellV1),
      );
      expect(dailyRunner.rapidReviewMode, isTrue);

      // Next day clears daily completed lessons and restores Start lesson on Home.
      await mountAt(dayOne.add(const Duration(days: 1)));
      expect(find.text('Start lesson'), findsOneWidget);
      expect(find.text('Start daily set'), findsNothing);
    },
  );

  testWidgets(
    'held mistake without an available same-day Review target does not lock world checkpoint',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(393, 852));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final w1 = Act0ShellStateV1.sample.worldById('world_1');
      final preCheckpointLessons = w1.lessons
          .take(w1.lessons.length - 1)
          .toList();
      final preCheckpointTasks = [
        for (final lesson in preCheckpointLessons) ...lesson.courseTaskList,
      ];
      final xp = preCheckpointTasks.fold<int>(0, (sum, t) => sum + t.rewardXp);
      final checkpoint = w1.lessons.last;

      SharedPreferences.setMockInitialValues({
        'act0_welcome_completed_v1': true,
        'intake_completed_v1': true,
        'act0_shell_progress_v1': jsonEncode({
          'schemaVersion': 20,
          'learningEvidenceHistory': <Object>[],
          'learningEvidenceLineage': const Act0LearningEvidenceHistoryV1()
              .lineagePayload(),
          'durableRetentionHistory': <Object>[],
          'pendingDecisionAssistance': <Object>[],
          'completedTaskIds': preCheckpointTasks.map((t) => t.taskId).toList(),
          'completedLessonIds': preCheckpointLessons
              .map((l) => l.lessonId)
              .toList(),
          'skippedTaskIds': <String>[],
          'earnedXp': xp,
          'selectedWorldId': 'world_1',
          'selectedLessonId': preCheckpointLessons.last.lessonId,
          'selectedTaskId':
              preCheckpointLessons.last.courseTaskList.last.taskId,
          'retentionSequence': 1,
          'retentionMemory': [
            {
              'taskId': 'what_poker_is_find_hero',
              'lessonId': 'what_poker_is',
              'worldId': 'world_1',
              'status': 'openRepair',
              'attempts': 1,
              'fixedAtSequence': 0,
              'lastRecheckSequence': 0,
              'successfulRecheckCount': 0,
            },
          ],
          'openRepairIntents': [
            {
              'schemaVersion': 1,
              'sourceWorldId': 'world_1',
              'sourceLessonId': 'what_poker_is',
              'sourceTaskId': 'what_poker_is_find_hero',
              'choiceId': 'top',
              'result': 'incorrect',
              'errorType': 'confused_table_identity',
              'missedSignalId': 'hero_button',
              'missedSignalLabel': 'Hero on the Button',
              'skillAtomId': 'table_position_read',
              'skillLabel': 'Table position read',
              'targetWorldId': 'world_3',
              'targetLessonId': 'position_checkpoint',
              'targetTaskId':
                  'position_checkpoint_position_checkpoint_table_notice',
              'mappingType': 'repair',
              'reasonCode': 'same_signal_table_position_read_hero_button',
            },
          ],
        }),
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: Act0ShellPreviewScreenV1(
            initialTab: Act0ShellTabV1.learn,
            showPlacementOnStart: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Clear weak spots in Review to unlock'), findsNothing);
      expect(
        find.byKey(
          Key('act0_shell_learn_lesson_state_text_${checkpoint.lessonId}'),
        ),
        findsNothing,
      );
      expect(
        find.byKey(const Key('act0_shell_current_mission_cta')),
        findsOneWidget,
      );
    },
  );

  test(
    'checkpoint locks only for worlds with clearable mistakes and reopens once cleared',
    () {
      final worlds = Act0ShellStateV1.sample.worlds;
      final w1 = worlds.first;
      final preCheckpointTaskIds = <String>{
        for (final lesson in w1.lessons.take(w1.lessons.length - 1))
          for (final task in lesson.courseTaskList) task.taskId,
      };
      Act0LessonCardV1 checkpointOf(Set<String> open) => act0ProgressWorldsV1(
        worlds,
        pathClosedTaskIds: preCheckpointTaskIds,
        earnedTaskIds: preCheckpointTaskIds,
        worldsWithOpenMistakes: open,
      ).first.lessons.last;

      final locked = checkpointOf({'world_1'});
      expect(locked.state, Act0LessonStateV1.locked);
      expect(locked.primaryCtaLabel, 'Clear weak spots');
      expect(locked.isSelectable, isFalse);

      // Same day, after Review clears the weak spot, the world is no longer
      // reported as having clearable mistakes and the checkpoint reopens.
      final reopened = checkpointOf(const <String>{});
      expect(reopened.state, Act0LessonStateV1.current);
      expect(reopened.isSelectable, isTrue);
    },
  );

  test(
    'every W1-W12 pre-checkpoint mistake either has a launchable same-day Review target or is excluded from checkpoint lock',
    () {
      final worlds = Act0ShellStateV1.sample.worlds;
      final tasksByKey = <String, Act0LessonTaskV1>{
        for (final world in worlds)
          for (final lesson in world.lessons)
            for (final task in lesson.taskList)
              '${world.worldId}|${lesson.lessonId}|${task.taskId}': task,
      };
      var clearableCount = 0;
      var nonLockingHeldCount = 0;

      for (final world in worlds) {
        for (final lesson in world.lessons) {
          if (act0LessonIsWorldCheckpointV1(world, lesson)) {
            continue;
          }
          for (final task in lesson.courseTaskList) {
            for (final option in task.runner.options.where(
              (o) => !o.isCorrect,
            )) {
              final contract = act0RepairGoalContractForSourceV1(
                worldId: world.worldId,
                lessonId: lesson.lessonId,
                taskId: task.taskId,
                choiceId: option.id,
              );
              if (contract != null && contract.hasValidatedTarget) {
                final targetKey =
                    '${contract.targetWorldId}|${contract.targetLessonId}|${contract.targetTaskId}';
                final targetTask = tasksByKey[targetKey];
                expect(
                  targetTask,
                  isNotNull,
                  reason:
                      'Validated repair target missing for ${world.worldId}:${lesson.lessonId}:${task.taskId}:${option.id} -> $targetKey',
                );
                final launchablePhase =
                    targetTask!.phase == Act0LessonPhaseV1.drill ||
                    contract.mappingType == 'intentional_exact';
                expect(
                  launchablePhase,
                  isTrue,
                  reason:
                      'Validated repair target is not launchable in Review for ${task.taskId}:${option.id} -> $targetKey',
                );
                clearableCount += 1;
              } else {
                nonLockingHeldCount += 1;
              }
            }
          }
        }
      }
      expect(clearableCount, greaterThan(0));
      expect(nonLockingHeldCount, 0);
    },
  );
}

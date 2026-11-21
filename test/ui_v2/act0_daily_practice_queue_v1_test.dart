import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_learning_time_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_daily_practice_queue_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

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

        await openDaily();
        await answer(pair.firstTask);
        await openDaily();
        await answer(pair.secondTask);
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
      expect(count, 255);
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
          'selectedWorldId': 'world_1',
          'selectedLessonId': 'what_poker_is',
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
    'Home suggests Practice after 3 new lessons today while keeping next lesson open in Learn',
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
      await tester.tap(
        find.byKey(const Key('act0_shell_block_summary_home_cta')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Practice a short set'), findsOneWidget);
      expect(find.text('Start daily set'), findsOneWidget);
      expect(
        find.text(
          'You finished 3 lessons today. Practice a short set — the next lesson stays open in Learn.',
        ),
        findsOneWidget,
      );

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

      // Returning Home and tapping Start daily set launches a daily practice drill.
      await tester.tap(
        find.descendant(
          of: find.byKey(const Key('act0_shell_bottom_nav')),
          matching: find.text('Home'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('act0_academy_home_leaf_cta')));
      await tester.pumpAndSettle();
      expect(find.byType(Act0LessonRunnerShellV1), findsOneWidget);

      // Next day clears daily completed lessons and restores Start lesson on Home.
      await mountAt(dayOne.add(const Duration(days: 1)));
      expect(find.text('Start lesson'), findsOneWidget);
      expect(find.text('Start daily set'), findsNothing);
    },
  );

  testWidgets(
    'Learn shows checkpoint locked with weak-spot hint when world has open mistakes',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(393, 852));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final w1 = Act0ShellStateV1.sample.worldById('world_1');
      final preCheckpointLessons = w1.lessons.take(w1.lessons.length - 1);
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

      expect(find.text(checkpoint.title), findsOneWidget);
      expect(find.text('Clear weak spots in Review to unlock'), findsOneWidget);
      final stateText = tester.widget<Text>(
        find.byKey(
          Key('act0_shell_learn_lesson_state_text_${checkpoint.lessonId}'),
        ),
      );
      expect(stateText.data, 'Locked');
      await tester.ensureVisible(find.text(checkpoint.title));
      await tester.pumpAndSettle();
      await tester.tap(find.text(checkpoint.title));
      await tester.pumpAndSettle();
      expect(find.byType(Act0LessonRunnerShellV1), findsNothing);
    },
  );
}

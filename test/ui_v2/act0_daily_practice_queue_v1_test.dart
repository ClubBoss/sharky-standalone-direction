import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_learning_time_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_daily_practice_queue_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  test(
    'every W1-W4 drill can enter a finite distinct set and survive restart',
    () {
      var count = 0;
      for (final world in Act0ShellStateV1.sample.worlds.where(
        (w) => w.worldNumber <= 4,
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
      expect(count, 125);
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
}

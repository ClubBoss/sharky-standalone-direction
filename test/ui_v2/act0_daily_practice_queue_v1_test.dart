import 'dart:convert';
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
      expect(count, 124);
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
}

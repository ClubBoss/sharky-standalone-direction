import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  test(
    'W3 position recognition does not expose the correct seat by pre-choice emphasis',
    () {
      final world = Act0ShellStateV1.sample.worldById('world_3');
      final targetTasks = world.lessons
          .expand((lesson) => lesson.taskList)
          .where(
            (task) =>
                task.runner.lessonTitle == 'The 6 positions' &&
                task.runner.options.any(
                  (option) => option.seatId != null && option.isCorrect,
                ),
          )
          .toList(growable: false);

      expect(targetTasks, isNotEmpty);
      for (final task in targetTasks) {
        final correctSeat = task.runner.options
            .firstWhere((option) => option.isCorrect)
            .seatId;
        expect(
          task.runner.table.selectableSeatIds,
          contains(correctSeat),
          reason: '${task.taskId}: seat must remain selectable',
        );
        expect(
          task.runner.table.highlightedSeatIds,
          isNot(contains(correctSeat)),
          reason: '${task.taskId}: pre-choice spotlight gives away the answer',
        );
        expect(
          task.runner.table.activeSeatId,
          isNot(correctSeat),
          reason:
              '${task.taskId}: active-seat treatment must not reveal the answer',
        );
      }
    },
  );
}

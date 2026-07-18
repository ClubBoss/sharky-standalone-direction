import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  test(
    'blinds review keeps the six-max first-preflop actor contract truthful',
    () {
      final lesson = Act0ShellStateV1.sample.worlds
          .singleWhere((world) => world.worldId == 'world_1')
          .lessons
          .singleWhere((lesson) => lesson.lessonId == 'blinds_action_order');
      final task = lesson.taskList.singleWhere(
        (task) => task.taskId == 'blinds_review',
      );
      final runner = task.runner;
      final firstActor = runner.table!.seats.singleWhere(
        (seat) => seat.seatId == 'utg',
      );
      final correct = runner.options.singleWhere((option) => option.isCorrect);

      expect(firstActor.seatLabel, 'UTG');
      expect(runner.question, 'Who acts first preflop?');
      expect(correct.id, 'utg');
      expect(correct.seatId, 'utg');
      expect(runner.caption, isNot(contains('UTG')));
      expect(runner.hint, isNot(contains('UTG')));
      expect(runner.hint, isNot(contains('left of the big blind')));
      expect(runner.feedbackReason, contains('left of the big blind'));
      expect(
        runner.options.map((option) => option.id),
        containsAll(<String>['utg', 'btn']),
      );
      expect(runner.options.map((option) => option.id), isNot(contains('bb')));
      expect(runner.table!.highlightedSeatIds, isEmpty);
    },
  );
}

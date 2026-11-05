import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

Act0LessonTaskV1 _task(String id) => Act0ShellStateV1.sample.worlds
    .expand((world) => world.lessons)
    .expand((lesson) => lesson.taskList)
    .singleWhere((task) => task.taskId == id);

void main() {
  test('checked-through W4 flop has no active actor', () {
    final task = _task('w4_protection_check');
    final table = task.runner.table;
    expect(table.potLabel, 'Pot 6 BB');
    expect(table.actionTrail.map((item) => item.label).toList().sublist(
      table.actionTrail.length - 2,
    ), ['Flop: BB checks', 'BTN checks']);
    expect(table.activeSeatId, anyOf(isNull, isEmpty));
    expect(task.rewardXp, 8);
    final correct = task.runner.options.singleWhere((option) => option.isCorrect);
    expect(correct.id, 'free_card');
    expect(correct.feedbackReason, contains('without paying'));
  });

  test('open W4 protection decision still belongs to BTN', () {
    final table = _task('w4_protection_bet').runner.table;
    expect(table.potLabel, 'Pot 6 BB');
    expect(table.activeSeatId, 'btn');
    expect(table.actionTrail.last.label, 'Flop: BB checks');
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_solver/poker_solver.dart';

void main() {
  test('W6 checkpoint counts stronger hand types from the named ranges', () {
    final task = Act0ShellStateV1.sample.worlds
        .expand((world) => world.lessons)
        .expand((lesson) => lesson.taskList)
        .singleWhere((task) => task.taskId == 'w6_board_pair_strength_compare');
    final board = task.runner.table.boardCards
        .map((card) => '${card.rank}${card.suit}')
        .toList();
    expect(board, ['Js', '8d', '4h']);
    final handTypes = [
      for (final cards in [
        ['Jh', 'Jc'],
        ['Jd', '8s'],
        ['8c', '8h'],
        ['4d', '4s'],
      ])
        Hand.solveHand([...board, ...cards]).name,
    ];
    expect(handTypes, [
      'Three of a Kind',
      'Two Pair',
      'Three of a Kind',
      'Three of a Kind',
    ]);
    expect(task.rewardXp, 10);
    expect(
      task.runner.options.singleWhere((option) => option.isCorrect).label,
      'BB, the caller',
    );
  });
}

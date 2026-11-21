import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  test('W7 keeps its original lesson and adds applied decisions', () {
    final world = Act0ShellStateV1.sample.worldById('world_7');
    expect(world.lessons.map((lesson) => lesson.lessonId), [
      'range_thinking_lite_combo_density',
      'w7_visible_cards_and_price',
      'w7_visible_cards_range_checkpoint',
    ]);
    expect(
      world.lessons.first.taskList.map((task) => task.taskId),
      contains('visible_card_combo_reduction_recap'),
    );
  });

  test('the turn answer changes with price, not with cards', () {
    final state = Act0ShellStateV1.sample;
    final tasks = state.lessonById('w7_visible_cards_and_price').taskList;
    final cheaper = tasks[1].runner;
    final dearer = tasks[2].runner;
    expect(
      cheaper.table.heroCards.map((c) => '${c.rank}${c.suit}'),
      dearer.table.heroCards.map((c) => '${c.rank}${c.suit}'),
    );
    expect(
      cheaper.table.boardCards.map((c) => '${c.rank}${c.suit}'),
      dearer.table.boardCards.map((c) => '${c.rank}${c.suit}'),
    );
    expect(cheaper.table.potLabel, 'Pot 11 BB');
    expect(dearer.table.potLabel, 'Pot 14 BB');
    expect(cheaper.table.toCallLabel, 'To call 3 BB');
    expect(dearer.table.toCallLabel, 'To call 6 BB');
    expect(cheaper.options.singleWhere((o) => o.isCorrect).label, 'Call');
    expect(dearer.options.singleWhere((o) => o.isCorrect).label, 'Fold');
  });

  test('the river answer changes with range at the same price', () {
    final tasks = Act0ShellStateV1.sample
        .lessonById('w7_visible_cards_range_checkpoint')
        .taskList;
    final narrow = tasks[0].runner;
    final wide = tasks[1].runner;
    expect(
      narrow.table.heroCards.map((c) => '${c.rank}${c.suit}'),
      wide.table.heroCards.map((c) => '${c.rank}${c.suit}'),
    );
    expect(
      narrow.table.boardCards.map((c) => '${c.rank}${c.suit}'),
      wide.table.boardCards.map((c) => '${c.rank}${c.suit}'),
    );
    expect(narrow.table.potLabel, 'Pot 12 BB');
    expect(wide.table.potLabel, narrow.table.potLabel);
    expect(narrow.table.toCallLabel, 'To call 4 BB');
    expect(wide.table.toCallLabel, narrow.table.toCallLabel);
    expect(narrow.options.singleWhere((o) => o.isCorrect).label, 'Fold');
    expect(wide.options.singleWhere((o) => o.isCorrect).label, 'Call');
  });
}

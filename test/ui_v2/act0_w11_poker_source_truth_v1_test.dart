import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  test('W11 QJs flop-to-turn is one coherent 35 BB effective hand', () {
    final lesson = Act0ShellStateV1.sample
        .worldById('world_11')
        .lessons
        .firstWhere((l) => l.lessonId == 'table_trigger_reads');
    final flop = lesson.taskList.firstWhere(
      (t) => t.taskId == 'w11_trigger_small_price_continue',
    );
    final turn = lesson.taskList.firstWhere(
      (t) => t.taskId == 'w11_trigger_bad_price_fold',
    );

    expect(flop.runner.table.potLabel, 'Pot 8 BB');
    expect(flop.runner.table.toCallLabel, 'To call 2 BB');
    expect(flop.runner.caption, contains('0.25 BB ante each'));
    expect(flop.runner.caption, contains('35 BB behind'));
    expect(turn.runner.table.potLabel, 'Pot 12 BB');
    expect(turn.runner.table.toCallLabel, 'To call 12 BB');
    expect(turn.runner.caption.toLowerCase(), contains('same hand again'));
    expect(turn.runner.caption, contains('33 BB behind'));
    expect(turn.runner.caption, contains('rarely bluffs'));

    // Preflop: 2*2.5 invested + SB/BB 1.5 + 6*0.25 antes = 8.
    expect(2 * 2.5 + 1.5 + 6 * .25, 8);
    // Flop: a 2 BB bet/call brings the 8 BB pot to 12; both lose 2 BB.
    expect(8 + 2 + 2, 12);
    expect(35 - 2, 33);
    expect(flop.runner.table.boardCards.map((c) => c.rank).toList(), <String>[
      'J',
      '7',
      '4',
    ]);
    expect(turn.runner.table.boardCards.map((c) => c.rank).toList(), <String>[
      'J',
      '7',
      '4',
      '2',
    ]);
    expect(
      flop.runner.table.heroCards.map((c) => c.label).toList(),
      turn.runner.table.heroCards.map((c) => c.label).toList(),
    );
  });

  test('W11 turn fold is opponent-conditioned, not universal poker advice', () {
    final lesson = Act0ShellStateV1.sample
        .worldById('world_11')
        .lessons
        .firstWhere((l) => l.lessonId == 'table_trigger_reads');
    final turn = lesson.taskList.firstWhere(
      (t) => t.taskId == 'w11_trigger_bad_price_fold',
    );
    final fold = turn.runner.options.firstWhere((o) => o.id == 'fold_turn');
    final call = turn.runner.options.firstWhere((o) => o.id == 'call_top_pair');

    expect(fold.isCorrect, isTrue);
    expect(call.isCorrect, isFalse);
    expect(fold.feedbackReason, contains('33%'));
    expect(fold.feedbackReason, contains('rarely bluffs'));
    expect(fold.feedbackReason, contains('not an automatic rule'));
    expect(call.feedbackReason, contains('betting range'));
    expect(12 / (12 + 12 + 12), closeTo(1 / 3, 1e-8));
  });
}

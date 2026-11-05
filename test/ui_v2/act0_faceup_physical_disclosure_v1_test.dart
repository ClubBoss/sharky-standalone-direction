// Baseline source: 7babeea17626b2103b9da3b2ea4dfd3bffd20a73.
// The 198fefc executed runtime snapshot is byte-identical for this corpus.
// Authored corpus invariant, not a synthetic poker hand or native proof.
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

Iterable<Act0LessonTaskV1> get _tasks => Act0ShellStateV1.sample.worlds
    .expand((world) => world.lessons)
    .expand((lesson) => lesson.taskList);

void main() {
  test('a played-hand faceUp seat discloses two real physical cards', () {
    final invalid = <String>[];
    final cardPattern = RegExp(r'^[23456789TJQKA][shdc]$');
    var revealed = 0;
    for (final task in _tasks) {
      final tables = <Act0TableStateV1>[
        task.runner.table,
        for (final step in task.runner.teachingSteps)
          if (step.table != null) step.table!,
      ];
      for (var variant = 0; variant < tables.length; variant++) {
        final table = tables[variant];
        if (table.scope != Act0TableScopeV1.playedHand) continue;
        for (final seat in table.seats) {
          if (seat.cardsVisibleMode != Act0CardsVisibleModeV1.faceUp) {
            continue;
          }
          revealed++;
          final cards = [
            for (final card in seat.holeCards) '${card.rank}${card.suit}',
          ];
          if (cards.length != 2 ||
              cards.any((card) => !cardPattern.hasMatch(card)) ||
              cards.toSet().length != 2) {
            invalid.add('${task.taskId}/$variant/${seat.seatId}: $cards');
          }
        }
      }
    }
    expect(revealed, greaterThan(0));
    expect(
      invalid,
      isEmpty,
      reason: 'faceUp is a physical two-card disclosure, not a styling flag',
    );
  });

  test('late information keeps its authored facts and choice contract', () {
    final task = _tasks.singleWhere(
      (task) => task.taskId == 'early_vs_late_late_info_choice',
    );
    final table = task.runner.table;
    expect(task.rewardXp, 9);
    expect(task.phase, Act0LessonPhaseV1.drill);
    expect(table.scope, Act0TableScopeV1.playedHand);
    expect(table.heroSeatId, 'btn');
    expect(table.heroSeat.seatId, 'btn');
    expect(table.activeSeatId, 'co');
    expect(table.heroCards, isEmpty);
    expect(table.heroSeat.holeCards, isEmpty);
    expect(table.boardCards, isEmpty);
    expect(table.potLabel, 'Pot 1.5 BB');
    expect(table.toCallLabel, isEmpty);
    expect(table.actionTrail.map((action) => action.label), [
      'UTG folds',
      'HJ folds',
      'CO acts',
    ]);
    expect(
      table.seats
          .where((seat) => seat.isInHand && !seat.isFolded)
          .map((seat) => seat.seatId),
      ['co', 'btn', 'sb', 'bb'],
    );
    expect(task.runner.options.map((option) => option.id), [
      'fewer_behind',
      'always_last',
    ]);
    expect(task.runner.options.map((option) => option.isCorrect), [
      true,
      false,
    ]);
    expect(task.runner.options.map((option) => option.quality), [
      Act0FeedbackQualityV1.correct,
      Act0FeedbackQualityV1.wrong,
    ]);
  });
}

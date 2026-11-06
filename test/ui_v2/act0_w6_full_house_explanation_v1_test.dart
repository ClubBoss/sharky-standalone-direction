// The authored cards and grade key are preserved. No synthetic hand is added.
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_solver/poker_solver.dart';

List<String> _cards(List<Act0CardStateV1> cards) => [
  for (final card in cards) '${card.rank}${card.suit}',
];

void main() {
  test('W6 paired-board explanation names the actual full house', () {
    final task = Act0ShellStateV1.sample.worlds
        .expand((world) => world.lessons)
        .expand((lesson) => lesson.taskList)
        .singleWhere((task) => task.taskId == 'w6_board_pair_strength_compare');
    final runner = task.runner;
    final table = runner.table;
    expect(task.rewardXp, 10);
    expect(task.phase, Act0LessonPhaseV1.drill);
    final villainSeat = table.seats.singleWhere((seat) => seat.seatId == 'co');
    final board = _cards(table.boardCards);
    final heroCards = _cards(table.heroCards);
    final villainCards = _cards(villainSeat.holeCards);
    expect(board, ['Jh', '8c', '8d', '2s', '2c']);
    expect(heroCards, ['As', 'Jd']);
    expect(villainCards, ['Kc', '8s']);
    expect(table.potLabel, 'Pot 14 BB');
    expect(
      table.seats
          .where((seat) => seat.isInHand && !seat.isFolded)
          .map((seat) => seat.seatId),
      ['co', 'btn'],
    );
    expect(runner.options.map((option) => option.id), [
      'hero_aj',
      'villain_k8',
      'tie',
    ]);
    expect(runner.options.map((option) => option.isCorrect), [
      false,
      true,
      false,
    ]);
    expect(runner.options.map((option) => option.quality), [
      Act0FeedbackQualityV1.suboptimal,
      Act0FeedbackQualityV1.correct,
      Act0FeedbackQualityV1.wrong,
    ]);

    // Expected categories come from the explicit five-card combinations:
    // CO = 8-8-8-2-2; Hero = J-J-8-8-A. Reuse the accepted PKR-07 solver.
    final hero = Hand.solveHand([...board, ...heroCards]);
    final villain = Hand.solveHand([...board, ...villainCards]);
    expect(hero.name, 'Two Pair');
    expect(villain.name, 'Full House');
    expect(Hand.winners([hero, villain]).single, same(villain));

    for (final id in ['hero_aj', 'villain_k8']) {
      final reason = runner.options
          .singleWhere((option) => option.id == id)
          .feedbackReason
          .toLowerCase();
      expect(reason, contains('full house'), reason: id);
      expect(reason, isNot(contains('trips')), reason: id);
    }
    final step = runner.teachingSteps.single;
    expect(step.body.toLowerCase(), contains('full house'));
    expect(step.body.toLowerCase(), isNot(contains('trips')));
    expect(step.focusLabels, contains('Full house'));
    expect(step.focusLabels, isNot(contains('Trips')));
  });
}

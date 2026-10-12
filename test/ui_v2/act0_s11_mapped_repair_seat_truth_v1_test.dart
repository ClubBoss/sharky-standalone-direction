import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  test('authored Cutoff transfer has a live Hero before three players act', () {
    final task = Act0ShellStateV1.sample
        .worldById('world_3')
        .lessons
        .expand((lesson) => lesson.taskList)
        .firstWhere(
          (task) => task.taskId.endsWith('position_checkpoint_table_notice'),
        );
    final table = task.runner.table;
    expect(table.heroSeatId, 'co');
    expect(table.heroSeat.seatId, 'co');
    expect(table.seats.where((seat) => seat.isHero), hasLength(1));
    expect(table.heroSeat.isFolded, isFalse);
    expect(table.heroSeat.isInHand, isTrue);
    expect(table.heroSeat.hasActed, isFalse);
    expect(table.heroSeat.holeCards.map((card) => '${card.rank}${card.suit}'), [
      'Qs',
      'Js',
    ]);
    expect(table.activeSeatId, 'co');
    for (final id in ['btn', 'sb', 'bb']) {
      final seat = table.seats.firstWhere((seat) => seat.seatId == id);
      expect(seat.isHero, isFalse, reason: '$id is behind Hero');
      expect(seat.isInHand, isTrue, reason: '$id must still act');
      expect(seat.isFolded, isFalse, reason: '$id must still act');
      expect(seat.hasActed, isFalse, reason: '$id must still act');
    }
    for (final id in ['utg', 'hj']) {
      final seat = table.seats.firstWhere((seat) => seat.seatId == id);
      expect(seat.isFolded, isTrue, reason: 'authored trail says $id folds');
      expect(seat.isInHand, isFalse);
      expect(seat.hasActed, isTrue);
    }
    final button = table.seats.firstWhere((seat) => seat.seatId == 'btn');
    expect(button.isDealerButton, isTrue);
    expect(button.cardsVisibleMode, Act0CardsVisibleModeV1.faceDown);
    expect(
      task.runner.options.firstWhere((option) => option.isCorrect).id,
      'players_behind',
    );
  });
}

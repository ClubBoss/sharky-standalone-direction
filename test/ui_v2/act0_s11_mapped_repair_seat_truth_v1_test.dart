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

  test(
    'authored Cutoff first-in AJo has a live Hero and correct prior folds',
    () {
      final task = Act0ShellStateV1.sample
          .worldById('world_3')
          .lessons
          .expand((lesson) => lesson.taskList)
          .firstWhere((task) => task.taskId.endsWith('w3_same_hand_open'));
      final table = task.runner.table;
      expect(table.heroSeatId, 'co');
      expect(table.heroSeat.isOccupied, isTrue);
      expect(table.heroSeat.isInHand, isTrue);
      expect(table.heroSeat.isFolded, isFalse);
      expect(table.heroSeat.hasActed, isFalse);
      expect(
        table.heroSeat.holeCards.map((card) => '${card.rank}${card.suit}'),
        ['Ad', 'Jc'],
      );
      for (final id in ['utg', 'hj']) {
        final seat = table.seats.firstWhere((seat) => seat.seatId == id);
        expect(seat.isFolded, isTrue, reason: '$id has folded before CO');
        expect(seat.isInHand, isFalse);
        expect(seat.hasActed, isTrue);
      }
      for (final id in ['btn', 'sb', 'bb']) {
        final seat = table.seats.firstWhere((seat) => seat.seatId == id);
        expect(seat.isFolded, isFalse, reason: '$id is still to act');
        expect(seat.isInHand, isTrue);
        expect(seat.hasActed, isFalse);
      }
    },
  );

  test('authored UTG pre-action scenes keep Hero occupied and CO unacted', () {
    final tasks = Act0ShellStateV1.sample.worlds
        .expand((world) => world.lessons)
        .expand((lesson) => lesson.taskList);
    for (final suffix in [
      'same_hand_early_fold',
      'position_checkpoint_early_fold',
      'position_apply_early_fold',
      'apply_utg_fold',
      'hand_discipline_buckets_trash',
      'fold_discipline_early_fold',
    ]) {
      final task = tasks.firstWhere((task) => task.taskId.endsWith(suffix));
      final table = task.runner.table;
      expect(table.heroSeatId, 'utg', reason: suffix);
      expect(table.heroSeat.isOccupied, isTrue, reason: suffix);
      expect(table.heroSeat.isFolded, isFalse, reason: suffix);
      expect(table.heroSeat.isInHand, isTrue, reason: suffix);
      expect(table.heroSeat.hasActed, isFalse, reason: suffix);
      final co = table.seats.firstWhere((seat) => seat.seatId == 'co');
      expect(co.isFolded, isFalse, reason: '$suffix: CO has not acted');
      expect(co.isInHand, isTrue, reason: suffix);
      expect(co.hasActed, isFalse, reason: suffix);
    }
  });
  test('all actionable authored runners keep a live Hero before choice', () {
    final mismatches = <String>[];
    var count = 0;
    for (final world in Act0ShellStateV1.sample.worlds) {
      for (final lesson in world.lessons) {
        for (final task in lesson.taskList) {
          if (task.runner.options.length < 2) continue;
          count++;
          final hero = task.runner.table.heroSeat;
          if (hero.isFolded ||
              !hero.isInHand ||
              hero.hasActed ||
              !hero.isOccupied) {
            mismatches.add('${world.worldId}/${task.taskId}: ${hero.seatId}');
          }
        }
      }
    }
    expect(count, greaterThan(0));
    expect(
      mismatches,
      isEmpty,
      reason:
          'An actionable Hero must not be folded, missing, or already acted',
    );
  });
}

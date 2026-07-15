import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  Act0LessonTaskV1 task(String worldId, String taskId) => Act0ShellStateV1
      .sample
      .worldById(worldId)
      .lessons
      .expand((lesson) => lesson.taskList)
      .firstWhere((task) => task.taskId == taskId);

  group('Act0 curriculum integrity', () {
    test('W4 price decisions show the opponent source of Hero call price', () {
      final expectedPrices = <String, String>{
        'w4_good_price_call': '1 BB',
        'w4_bad_price_fold': '7 BB',
        'w4_cheap_price_marginal_call': '1 BB',
        'w4_big_price_marginal_fold': '6 BB',
      };

      for (final entry in expectedPrices.entries) {
        final runner = task('world_4', entry.key).runner;
        final hero = runner.table.heroSeat;
        final bettor = runner.table.seats.firstWhere(
          (seat) => seat.seatId == 'hj',
        );
        expect(hero.bet, isNull, reason: entry.key);
        expect(bettor.bet?.amountLabel, entry.value, reason: entry.key);
        expect(runner.table.toCallLabel, 'To call ${entry.value}');
        expect(runner.table.actionTrail.map((item) => item.label), <String>[
          'HJ bets ${entry.value}',
          'Hero acts',
        ], reason: entry.key);
      }
    });

    test(
      'W7 visible-card tasks render the board named by their source spec',
      () {
        final expectedBoards = <String, List<String>>{
          'visible_ace_combo_reduction_intro': <String>['A', '7', '2'],
          'visible_king_combo_reduction_intro': <String>['K', '8', '4'],
          'paired_board_texture_lite_intro': <String>['7', '7', '2'],
        };

        for (final entry in expectedBoards.entries) {
          final cards = task('world_7', entry.key).runner.table.boardCards;
          expect(
            cards.map((card) => card.rank),
            entry.value,
            reason: entry.key,
          );
          expect(
            cards.map((card) => '${card.rank}${card.suit}').toSet().length,
            cards.length,
            reason: entry.key,
          );
        }
      },
    );
  });
}

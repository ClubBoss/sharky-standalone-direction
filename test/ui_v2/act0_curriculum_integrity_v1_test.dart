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
          'visible_card_combo_density_transfer_check': <String>['Q', 'J', '5'],
        };

        for (final entry in expectedBoards.entries) {
          final table = task('world_7', entry.key).runner.table;
          final cards = table.boardCards;
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
          expect(
            <String>{
              for (final card in <Act0CardStateV1>[
                ...table.heroCards,
                ...cards,
              ])
                '${card.rank}${card.suit}',
            },
            hasLength(table.heroCards.length + cards.length),
            reason: '${entry.key} must not reuse a visible card',
          );
        }
      },
    );

    test('W8 side-pot intro uses one contribution ledger', () {
      final runner = task('world_8', 'what_poker_is_side_pot_intro').runner;
      final seats = <String, Act0SeatStateV1>{
        for (final seat in runner.table.seats) seat.seatId: seat,
      };
      const contributions = <String, double>{
        'hero': 20,
        'co': 50,
        'bb': 50,
        'folded_sb': 0.5,
      };
      const mainEligible = <String, double>{
        'hero': 20,
        'co': 20,
        'bb': 20,
        'folded_sb': 0.5,
      };
      const sideEligible = <String, double>{'co': 30, 'bb': 30};

      expect(contributions.values.reduce((a, b) => a + b), 120.5);
      expect(mainEligible.values.reduce((a, b) => a + b), 60.5);
      expect(sideEligible.values.reduce((a, b) => a + b), 60);
      expect(runner.table.potLabel, 'Main 60.5 BB; side 60 BB');
      expect(seats['btn']?.currentBetLabel, '20 BB');
      expect(seats['co']?.currentBetLabel, '50 BB');
      expect(seats['bb']?.currentBetLabel, '50 BB');
      expect(seats['co']?.bet?.label, 'Total in');
      expect(seats['co']?.bet?.amountLabel, '50 BB');
      expect(seats['bb']?.bet?.label, 'Total in');
      expect(seats['bb']?.bet?.amountLabel, '50 BB');
      expect(runner.table.actionTrail.map((item) => item.label), <String>[
        'SB posts 0.5 BB, then folds',
        'BB post is included in BB total',
        'Hero all-in 20 BB',
        'CO contributes 50 BB total',
        'BB contributes 50 BB total',
        'CO and BB: 30 BB each to side',
      ]);
    });
  });
}

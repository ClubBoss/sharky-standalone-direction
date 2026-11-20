import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_table_choreography_contract_v1.dart';

// S12.V-16/-17 source-truth only: no fake native screenshots or earned progress.
void main() {
  group('canonical blinds, positions, and board size', () {
    test('canonical 6/9/10-seat order ends with button, SB, BB', () {
      for (final entry in act0CanonicalSeatOrderByFormatV1.entries) {
        final seats = entry.value;
        expect(seats.length, act0ExpectedPlayerCountForFormatV1(entry.key));
        expect(seats.sublist(seats.length - 3), ['BTN', 'SB', 'BB']);
        expect(seats.toSet().length, seats.length);
      }
    });

    test('preflop/flop/turn/river must reveal 0/3/4/5 cards', () {
      expect(Act0TableChoreographyStreetV1.preflop.boardCardCount, 0);
      expect(Act0TableChoreographyStreetV1.flop.boardCardCount, 3);
      expect(Act0TableChoreographyStreetV1.turn.boardCardCount, 4);
      expect(Act0TableChoreographyStreetV1.river.boardCardCount, 5);
    });
  });

  group('the same table positions must own every BB in the pot', () {
    test('ordinary six-max BTN raise and BB call remains 6.5 BB', () {
      final pot = act0CalcTrailPotV1(const [
        'SB blind 0.5 BB',
        'BB blind 1 BB',
        'BTN raises 3 BB',
        'BB calls 3 BB',
        'Flop: BB checks',
      ], 4);
      expect(pot.street, 'Flop');
      expect(pot.potBb, 6.5);
    });

    test('nine-max UTG+1 raise counts in source-owned pot', () {
      final pot = act0CalcTrailPotV1(const [
        'SB blind 0.5 BB',
        'BB blind 1 BB',
        'UTG+1 raises 3 BB',
        'BB calls 3 BB',
        'Flop: BB checks',
      ], 4);
      expect(pot.street, 'Flop');
      expect(pot.potBb, 6.5);
    });

    test('ten-max UTG+2 call and river bet are counted by street', () {
      final pot = act0CalcTrailPotV1(const [
        'SB blind 0.5 BB',
        'BB blind 1 BB',
        'UTG+2 raises 2.5 BB',
        'BB calls 2.5 BB',
        'Flop: UTG+2 bets 2 BB',
        'Flop: BB calls 2 BB',
        'Turn: UTG+2 checks',
        'River: UTG+2 bets 1 BB',
      ], 7);
      // preflop 0.5+2.5+2.5=5.5, flop +4, river +1
      expect(pot.street, 'River');
      expect(pot.potBb, 10.5);
    });
  });

  test('authored flop/turn/river highlight the newly revealed street card', () {
    final lesson = Act0ShellStateV1.sample.lessonById('your_first_hand');
    final byId = {for (final t in lesson.taskList) t.taskId: t};
    final cases =
        <
          ({
            String taskId,
            String street,
            List<String> cards,
            List<String> focus,
          })
        >[
          (
            taskId: 'your_first_hand_flop',
            street: 'Flop',
            cards: ['Ah', '7c', '2d'],
            focus: ['board_0', 'board_1', 'board_2'],
          ),
          (
            taskId: 'your_first_hand_turn',
            street: 'Turn',
            cards: ['Ah', '7c', '2d', 'Jc'],
            focus: ['board_3'],
          ),
          (
            taskId: 'your_first_hand_river',
            street: 'River',
            cards: ['Ah', '7c', '2d', 'Jc', '4s'],
            focus: ['board_4'],
          ),
        ];
    for (final item in cases) {
      final table = byId[item.taskId]!.runner.table;
      expect(table.streetLabel, item.street);
      expect(table.boardCards.map((card) => card.label).toList(), item.cards);
      expect(
        table.highlightedCardIds,
        item.focus,
        reason:
            '${item.taskId} table focus must match its authored teaching focus',
      );
      expect(table.potLabel, 'Pot 5 BB');
      expect(table.heroCards, hasLength(2));
      expect(table.seats.where((seat) => seat.isHero), hasLength(1));
      expect(
        table.seats.where((seat) => seat.isSmallBlind).single.seatLabel,
        'SB',
      );
      expect(
        table.seats.where((seat) => seat.isBigBlind).single.seatLabel,
        'BB',
      );
      expect(
        table.seats.where((seat) => seat.isDealerButton).single.seatLabel,
        'BTN',
      );
    }
  });

  group('all-in shove must count in source pot', () {
    test('authored Hero shoves 20 BB cannot drop Hero chips', () {
      final pot = act0CalcTrailPotV1(const [
        'SB blind 0.5 BB',
        'BB blind 1 BB',
        'Hero shoves 20 BB',
        'BB calls 20 BB',
      ], 3);
      expect(pot.potBb, 40.5);
    });

    test('authored BB shoves 18 BB while CO calls to 18 BB', () {
      final pot = act0CalcTrailPotV1(const [
        'SB blind 0.5 BB',
        'BB blind 1 BB',
        'CO raises 3 BB',
        'BB shoves 18 BB',
        'CO calls 18 BB',
      ], 4);
      expect(pot.potBb, 36.5);
    });
  });
}

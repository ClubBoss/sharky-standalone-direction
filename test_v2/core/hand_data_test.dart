import 'package:test/test.dart';
import 'package:poker_analyzer/models/v2/hand_data.dart';
import 'package:poker_analyzer/models/v2/hero_position.dart';
import 'package:poker_analyzer/models/action_entry.dart';

void main() {
  group('HandData', () {
    test('HandData initializes with all required fields', () {
      final hand = HandData(
        heroCards: 'Ah Kh',
        position: HeroPosition.btn,
        heroIndex: 0,
        playerCount: 6,
        board: ['Qh', 'Jh', '2c'],
        actions: {
          0: [
            ActionEntry(0, 0, 'raise', amount: 3.0),
            ActionEntry(0, 1, 'call', amount: 3.0),
          ],
        },
        stacks: {'0': 100.0, '1': 100.0},
      );

      expect(hand.heroCards, 'Ah Kh');
      expect(hand.position, HeroPosition.btn);
      expect(hand.heroIndex, 0);
      expect(hand.playerCount, 6);
      expect(hand.board.length, 3);
      expect(hand.actions[0]?.length, 2);
      expect(hand.stacks['0'], 100.0);
    });

    test('HandData supports empty board for preflop', () {
      final hand = HandData(
        heroCards: 'Ah Kh',
        position: HeroPosition.btn,
        heroIndex: 0,
        playerCount: 6,
        board: [],
        actions: {},
        stacks: {},
      );

      expect(hand.board, isEmpty);
    });

    test('HandData supports full board for river', () {
      final hand = HandData(
        heroCards: 'Ah Kh',
        position: HeroPosition.btn,
        heroIndex: 0,
        playerCount: 6,
        board: ['Qh', 'Jh', '2c', '5d', '9s'],
        actions: {},
        stacks: {},
      );

      expect(hand.board.length, 5);
    });

    test('HandData supports ante blinds', () {
      final hand = HandData(
        heroCards: 'Ah Kh',
        position: HeroPosition.btn,
        heroIndex: 0,
        playerCount: 6,
        board: [],
        actions: {},
        stacks: {},
        anteBb: 1,
      );

      expect(hand.anteBb, 1);
    });

    test('HandData supports multiple streets of actions', () {
      final hand = HandData(
        heroCards: 'Ah Kh',
        position: HeroPosition.btn,
        heroIndex: 0,
        playerCount: 6,
        board: ['Qh', 'Jh', '2c', '5d'],
        actions: {
          0: [ActionEntry(0, 0, 'raise', amount: 3.0)],
          1: [ActionEntry(1, 0, 'bet', amount: 5.0)],
          2: [ActionEntry(2, 0, 'bet', amount: 10.0)],
        },
        stacks: {},
      );

      expect(hand.actions.keys.length, 3);
      expect(hand.actions[0]?.first.action, 'raise');
      expect(hand.actions[1]?.first.action, 'bet');
      expect(hand.actions[2]?.first.action, 'bet');
    });

    test('HandData supports multiple players with stacks', () {
      final hand = HandData(
        heroCards: 'Ah Kh',
        position: HeroPosition.btn,
        heroIndex: 0,
        playerCount: 6,
        board: [],
        actions: {},
        stacks: {
          '0': 100.0,
          '1': 150.0,
          '2': 75.0,
          '3': 200.0,
          '4': 90.0,
          '5': 110.0,
        },
      );

      expect(hand.stacks.length, 6);
      expect(hand.stacks['1'], 150.0);
      expect(hand.stacks['3'], 200.0);
    });

    test('HandData validates player count', () {
      final hand = HandData(
        heroCards: 'Ah Kh',
        position: HeroPosition.btn,
        heroIndex: 0,
        playerCount: 9,
        board: [],
        actions: {},
        stacks: {},
      );

      expect(hand.playerCount, 9);
      expect(hand.playerCount >= 2, isTrue);
      expect(hand.playerCount <= 10, isTrue);
    });
  });

  group('HeroPosition', () {
    test('HeroPosition has all standard positions', () {
      expect(HeroPosition.values.contains(HeroPosition.sb), isTrue);
      expect(HeroPosition.values.contains(HeroPosition.bb), isTrue);
      expect(HeroPosition.values.contains(HeroPosition.utg), isTrue);
      expect(HeroPosition.values.contains(HeroPosition.mp), isTrue);
      expect(HeroPosition.values.contains(HeroPosition.co), isTrue);
      expect(HeroPosition.values.contains(HeroPosition.btn), isTrue);
    });

    test('HeroPosition string representation is correct', () {
      expect(HeroPosition.btn.toString(), contains('btn'));
      expect(HeroPosition.co.toString(), contains('co'));
      expect(HeroPosition.sb.toString(), contains('sb'));
    });
  });

  group('ActionEntry', () {
    test('ActionEntry initializes correctly', () {
      final action = ActionEntry(0, 0, 'raise', amount: 3.0);

      expect(action.street, 0);
      expect(action.playerIndex, 0);
      expect(action.action, 'raise');
      expect(action.amount, 3.0);
    });

    test('ActionEntry supports optional fields', () {
      final action = ActionEntry(
        0,
        0,
        'raise',
        amount: 3.0,
        generated: true,
        manualEvaluation: 'good',
        customLabel: 'test',
      );

      expect(action.generated, true);
      expect(action.manualEvaluation, 'good');
      expect(action.customLabel, 'test');
    });

    test('ActionEntry supports fold without amount', () {
      final action = ActionEntry(0, 0, 'fold');

      expect(action.action, 'fold');
      expect(action.amount, isNull);
    });

    test('ActionEntry supports check without amount', () {
      final action = ActionEntry(0, 0, 'check');

      expect(action.action, 'check');
      expect(action.amount, isNull);
    });

    test('ActionEntry supports bet with amount', () {
      final action = ActionEntry(0, 0, 'bet', amount: 10.0);

      expect(action.action, 'bet');
      expect(action.amount, 10.0);
    });

    test('ActionEntry supports raise with amount', () {
      final action = ActionEntry(0, 0, 'raise', amount: 15.0);

      expect(action.action, 'raise');
      expect(action.amount, 15.0);
    });

    test('ActionEntry supports call with amount', () {
      final action = ActionEntry(0, 0, 'call', amount: 5.0);

      expect(action.action, 'call');
      expect(action.amount, 5.0);
    });
  });
}

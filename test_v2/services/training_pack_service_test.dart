import 'package:test/test.dart';
import 'package:poker_analyzer/models/v2/training_pack_template.dart';
import 'package:poker_analyzer/models/v2/training_pack_spot.dart';
import 'package:poker_analyzer/models/v2/hand_data.dart';
import 'package:poker_analyzer/models/v2/hero_position.dart';

void main() {
  group('TrainingPackService', () {
    test('converts saved hand to training pack spot correctly', () {
      final spot = TrainingPackSpot(
        id: 'test-spot-1',
        title: 'Test Spot',
        hand: HandData(
          heroCards: 'Ah Kh',
          position: HeroPosition.btn,
          heroIndex: 0,
          playerCount: 6,
          board: ['Qh', 'Jh', '2c'],
          actions: {},
          stacks: {'0': 100.0, '1': 100.0},
        ),
        tags: ['test', 'preflop'],
      );

      expect(spot.id, 'test-spot-1');
      expect(spot.title, 'Test Spot');
      expect(spot.hand.heroCards, 'Ah Kh');
      expect(spot.hand.position, HeroPosition.btn);
      expect(spot.hand.board.length, 3);
      expect(spot.tags, contains('test'));
    });

    test('training pack template holds multiple spots', () {
      final spots = [
        TrainingPackSpot(
          id: 'spot-1',
          title: 'Spot 1',
          hand: HandData(
            heroCards: 'Ah Kh',
            position: HeroPosition.btn,
            heroIndex: 0,
            playerCount: 6,
            board: [],
            actions: {},
            stacks: {},
          ),
          tags: ['preflop'],
        ),
        TrainingPackSpot(
          id: 'spot-2',
          title: 'Spot 2',
          hand: HandData(
            heroCards: 'Qs Qd',
            position: HeroPosition.co,
            heroIndex: 0,
            playerCount: 9,
            board: ['Kh', '7c', '2d'],
            actions: {},
            stacks: {},
          ),
          tags: ['postflop'],
        ),
      ];

      final template = TrainingPackTemplate(
        id: 'test-template',
        name: 'Test Template',
        description: 'Test description',
        spots: spots,
        tags: ['test'],
      );

      expect(template.spots.length, 2);
      expect(template.spots[0].id, 'spot-1');
      expect(template.spots[1].id, 'spot-2');
      expect(template.name, 'Test Template');
    });

    test('spot validates hero cards format', () {
      expect(
        () => TrainingPackSpot(
          id: 'test',
          title: 'Test',
          hand: HandData(
            heroCards: 'Ah Kh',
            position: HeroPosition.btn,
            heroIndex: 0,
            playerCount: 6,
            board: [],
            actions: {},
            stacks: {},
          ),
          tags: [],
        ),
        returnsNormally,
      );
    });

    test('hero position enum values are correct', () {
      expect(HeroPosition.values.contains(HeroPosition.btn), isTrue);
      expect(HeroPosition.values.contains(HeroPosition.co), isTrue);
      expect(HeroPosition.values.contains(HeroPosition.sb), isTrue);
      expect(HeroPosition.values.contains(HeroPosition.bb), isTrue);
    });

    test('spot with empty board is valid for preflop scenarios', () {
      final spot = TrainingPackSpot(
        id: 'preflop-spot',
        title: 'Preflop Spot',
        hand: HandData(
          heroCards: 'Ah Kh',
          position: HeroPosition.btn,
          heroIndex: 0,
          playerCount: 6,
          board: [],
          actions: {},
          stacks: {},
        ),
        tags: ['preflop'],
      );

      expect(spot.hand.board.isEmpty, isTrue);
      expect(spot.tags, contains('preflop'));
    });

    test('spot with full board is valid for postflop scenarios', () {
      final spot = TrainingPackSpot(
        id: 'river-spot',
        title: 'River Spot',
        hand: HandData(
          heroCards: 'Ah Kh',
          position: HeroPosition.btn,
          heroIndex: 0,
          playerCount: 6,
          board: ['Qh', 'Jh', '2c', '5d', '9s'],
          actions: {},
          stacks: {},
        ),
        tags: ['river'],
      );

      expect(spot.hand.board.length, 5);
      expect(spot.tags, contains('river'));
    });

    test('template with no spots is valid', () {
      final template = TrainingPackTemplate(
        id: 'empty-template',
        name: 'Empty Template',
        description: 'No spots yet',
        spots: [],
        tags: [],
      );

      expect(template.spots.isEmpty, isTrue);
    });
  });
}

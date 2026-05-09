import 'package:test/test.dart';
import 'package:poker_analyzer/models/v2/training_pack_spot.dart';
import 'package:poker_analyzer/models/v2/hand_data.dart';
import 'package:poker_analyzer/models/v2/hero_position.dart';

void main() {
  group('TrainingPackSpot', () {
    test('TrainingPackSpot initializes with required fields', () {
      final spot = TrainingPackSpot(
        id: 'spot-1',
        title: 'Test Spot',
        hand: HandData(
          heroCards: 'Ah Kh',
          position: HeroPosition.btn,
          heroIndex: 0,
          playerCount: 6,
          board: [],
          actions: {},
          stacks: {},
        ),
        tags: ['test', 'preflop'],
      );

      expect(spot.id, 'spot-1');
      expect(spot.title, 'Test Spot');
      expect(spot.hand.heroCards, 'Ah Kh');
      expect(spot.tags, contains('test'));
      expect(spot.tags, contains('preflop'));
    });

    test('TrainingPackSpot with note', () {
      final spot = TrainingPackSpot(
        id: 'spot-1',
        title: 'Test Spot',
        note: 'This is a test spot note',
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
      );

      expect(spot.note, 'This is a test spot note');
    });

    test('TrainingPackSpot with correct action', () {
      final spot = TrainingPackSpot(
        id: 'spot-1',
        title: 'Test Spot',
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
        correctAction: 'raise',
      );

      expect(spot.correctAction, 'raise');
    });

    test('TrainingPackSpot with explanation', () {
      final spot = TrainingPackSpot(
        id: 'spot-1',
        title: 'Test Spot',
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
        explanation: 'This is why we should raise here',
      );

      expect(spot.explanation, isNotNull);
      expect(spot.explanation, 'This is why we should raise here');
    });

    test('TrainingPackSpot supports multiple tags', () {
      final spot = TrainingPackSpot(
        id: 'spot-1',
        title: 'Test Spot',
        hand: HandData(
          heroCards: 'Ah Kh',
          position: HeroPosition.btn,
          heroIndex: 0,
          playerCount: 6,
          board: ['Qh', 'Jh', '2c'],
          actions: {},
          stacks: {},
        ),
        tags: ['postflop', 'flop', 'value', 'button', 'vs-cutoff'],
      );

      expect(spot.tags.length, 5);
      expect(spot.tags, contains('postflop'));
      expect(spot.tags, contains('value'));
    });

    test('TrainingPackSpot with priority', () {
      final spot = TrainingPackSpot(
        id: 'spot-1',
        title: 'Test Spot',
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
        priority: 5,
      );

      expect(spot.priority, 5);
    });

    test('TrainingPackSpot with pinned flag', () {
      final spot = TrainingPackSpot(
        id: 'spot-1',
        title: 'Test Spot',
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
        pinned: true,
      );

      expect(spot.pinned, isTrue);
    });

    test('TrainingPackSpot equality based on id', () {
      final spot1 = TrainingPackSpot(
        id: 'spot-1',
        title: 'Test Spot',
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
      );

      final spot2 = TrainingPackSpot(
        id: 'spot-1',
        title: 'Different Title',
        hand: HandData(
          heroCards: 'Qs Qd',
          position: HeroPosition.co,
          heroIndex: 0,
          playerCount: 6,
          board: [],
          actions: {},
          stacks: {},
        ),
        tags: [],
      );

      expect(spot1.id, spot2.id);
    });

    test('TrainingPackSpot with category tag', () {
      final spot = TrainingPackSpot(
        id: 'spot-1',
        title: 'Test Spot',
        hand: HandData(
          heroCards: 'Ah Kh',
          position: HeroPosition.btn,
          heroIndex: 0,
          playerCount: 6,
          board: [],
          actions: {},
          stacks: {},
        ),
        tags: ['cat:3bet', 'preflop'],
      );

      expect(spot.tags.any((t) => t.startsWith('cat:')), isTrue);
    });
  });
}

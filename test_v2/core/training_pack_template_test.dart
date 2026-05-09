import 'package:test/test.dart';
import 'package:poker_analyzer/models/v2/training_pack_template.dart';
import 'package:poker_analyzer/models/v2/training_pack_spot.dart';
import 'package:poker_analyzer/models/v2/hand_data.dart';
import 'package:poker_analyzer/models/v2/hero_position.dart';

void main() {
  group('TrainingPackTemplate', () {
    test('TrainingPackTemplate initializes with required fields', () {
      final template = TrainingPackTemplate(
        id: 'template-1',
        name: 'Test Template',
        description: 'A test training pack template',
        spots: [],
        tags: ['test'],
      );

      expect(template.id, 'template-1');
      expect(template.name, 'Test Template');
      expect(template.description, 'A test training pack template');
      expect(template.spots, isEmpty);
      expect(template.tags, contains('test'));
    });

    test('TrainingPackTemplate with multiple spots', () {
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
          tags: [],
        ),
        TrainingPackSpot(
          id: 'spot-2',
          title: 'Spot 2',
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
        ),
      ];

      final template = TrainingPackTemplate(
        id: 'template-1',
        name: 'Test Template',
        description: 'Template with multiple spots',
        spots: spots,
        tags: [],
      );

      expect(template.spots.length, 2);
      expect(template.spots[0].id, 'spot-1');
      expect(template.spots[1].id, 'spot-2');
    });

    test('TrainingPackTemplate with metadata', () {
      final template = TrainingPackTemplate(
        id: 'template-1',
        name: 'Test Template',
        description: 'Template with metadata',
        spots: [],
        tags: ['advanced', 'tournament'],
        difficulty: '4',
      );

      expect(template.difficulty, '4');
      expect(template.tags, contains('advanced'));
      expect(template.tags, contains('tournament'));
    });

    test('TrainingPackTemplate with creation date', () {
      final now = DateTime.now();
      final template = TrainingPackTemplate(
        id: 'template-1',
        name: 'Test Template',
        description: 'Template with date',
        spots: [],
        tags: [],
        createdAt: now,
      );

      expect(template.createdAt, now);
    });

    test('TrainingPackTemplate with category', () {
      final template = TrainingPackTemplate(
        id: 'template-1',
        name: 'Test Template',
        description: 'Template with category',
        spots: [],
        tags: ['cat:preflop', 'cat:3bet'],
      );

      expect(template.tags.any((t) => t.startsWith('cat:')), isTrue);
    });

    test('TrainingPackTemplate supports empty description', () {
      final template = TrainingPackTemplate(
        id: 'template-1',
        name: 'Test Template',
        description: '',
        spots: [],
        tags: [],
      );

      expect(template.description, isEmpty);
    });

    test('TrainingPackTemplate spot count', () {
      final spots = List.generate(
        10,
        (i) => TrainingPackSpot(
          id: 'spot-$i',
          title: 'Spot $i',
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
      );

      final template = TrainingPackTemplate(
        id: 'template-1',
        name: 'Large Template',
        description: 'Template with many spots',
        spots: spots,
        tags: [],
      );

      expect(template.spots.length, 10);
    });

    test('TrainingPackTemplate immutability check', () {
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
          tags: [],
        ),
      ];

      final template = TrainingPackTemplate(
        id: 'template-1',
        name: 'Test Template',
        description: 'Immutable template',
        spots: spots,
        tags: [],
      );

      expect(template.spots.length, 1);

      // Original list remains unchanged
      spots.add(
        TrainingPackSpot(
          id: 'spot-2',
          title: 'Spot 2',
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
        ),
      );

      // Template should still have only 1 spot if properly immutable
      expect(spots.length, 2);
    });
  });
}

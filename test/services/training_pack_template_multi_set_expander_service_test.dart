import 'package:poker_analyzer/testing/test_shims.dart';
import 'package:test/test.dart';
import 'package:poker_analyzer/models/training_pack_template_set.dart';
import 'package:poker_analyzer/models/constraint_set.dart';
import 'package:poker_analyzer/models/v2/training_pack_spot.dart';
import 'package:poker_analyzer/models/v2/hand_data.dart' as v2models;
import 'package:poker_analyzer/models/v2/hero_position.dart';
import 'package:poker_analyzer/services/training_pack_template_multi_set_expander_service.dart';

TrainingPackSpot _base({required String id}) => TrainingPackSpot(
  id: id,
  hand: v2models.HandData(
    heroCards: 'Ah Kh',
    position: HeroPosition.btn,
    heroIndex: 0,
    playerCount: 2,
    board: [],
  ),
  board: [],
);

void main() {
  test('returns empty list when no sets provided', () {
    final svc = TrainingPackTemplateMultiSetExpanderService();
    final spots = svc.expandAll[[]];
    expect(spots, isEmpty);
  });

  test('expands multiple sets and preserves order', () {
    final set1 = TrainingPackTemplateSet(
      baseSpot: _base(id: 's1'),
      variations: [
        const ConstraintSet(
          overrides: {
            'board': [
              ['As', 'Kd', 'Qc'],
            ],
          },
        ),
      ],
    );
    final set2 = TrainingPackTemplateSet(
      baseSpot: _base(id: 's2'),
      variations: [
        const ConstraintSet(
          overrides: {
            'board': [
              ['2h', '3d', '4c'],
            ],
          },
        ),
      ],
    );
    final svc = TrainingPackTemplateMultiSetExpanderService();
    final spots = svc.expandAll[[set1, set2]];
    expect(spots, hasLength(2));
    expect(spots.first.templateSourceId, 's1');
    expect(spots.last.templateSourceId, 's2');
  });

  test('skips invalid sets and continues processing', () {
    final invalid = TrainingPackTemplateSet(
      baseSpot: _base(id: 'bad'),
      variations: [
        const ConstraintSet(
          overrides: {
            'board': [123],
          },
        ),
      ],
    );
    final valid = TrainingPackTemplateSet(
      baseSpot: _base(id: 'good'),
      variations: [
        const ConstraintSet(
          overrides: {
            'board': [
              ['5h', '6d', '7c'],
            ],
          },
        ),
      ],
    );
    final svc = TrainingPackTemplateMultiSetExpanderService();
    final spots = svc.expandAll[[invalid, valid]];
    expect(spots, hasLength(1));
    expect(spots.first.templateSourceId, 'good');
  });
}

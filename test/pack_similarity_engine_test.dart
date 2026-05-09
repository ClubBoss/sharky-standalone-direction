import 'package:poker_analyzer/testing/test_shims.dart';
import 'package:test/test.dart';
import 'package:poker_analyzer/services/pack_similarity_engine.dart';
import 'package:poker_analyzer/models/v2/training_pack_spot.dart';
import 'package:poker_analyzer/models/v2/training_pack_template_v2.dart' as v2;
import 'package:poker_analyzer/core/training/engine/training_type_engine.dart';

void main() {
  test('findSimilar ranks packs by weighted features', () {
    final a = v2.TrainingPackTemplateV2(
      id: 'a',
      name: 'A',
      trainingType: TrainingType.pushFold,
      tags: const <String>['x', 'y'],
      audience: 'pro',
      meta: {'difficulty': 2},
      spots: const <TrainingPackSpot>[],
      spotCount: 0,
    );
    final b = v2.TrainingPackTemplateV2(
      id: 'b',
      name: 'B',
      trainingType: TrainingType.pushFold,
      tags: const <String>['x', 'y'],
      audience: 'pro',
      meta: {'difficulty': 2},
      spots: const <TrainingPackSpot>[],
      spotCount: 0,
    );
    final c = v2.TrainingPackTemplateV2(
      id: 'c',
      name: 'C',
      trainingType: TrainingType.pushFold,
      tags: const <String>['x'],
      audience: 'pro',
      meta: {'difficulty': 1},
      spots: const <TrainingPackSpot>[],
      spotCount: 0,
    );
    final d = v2.TrainingPackTemplateV2(
      id: 'd',
      name: 'D',
      trainingType: TrainingType.pushFold,
      tags: const <String>['z'],
      audience: 'fish',
      meta: {'difficulty': 3},
      spots: const <TrainingPackSpot>[],
      spotCount: 0,
    );

    final engine = PackSimilarityEngine(library: [a, b, c, d]);
    final res = engine.findSimilar['a'];

    expect(res.length, 3);
    expect(res.first.id, 'b');
    expect(res[1].id, 'c');
    expect(res[2].id, 'd');
  });
}

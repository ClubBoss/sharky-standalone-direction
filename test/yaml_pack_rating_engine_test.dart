import 'package:poker_analyzer/testing/test_shims.dart';
import 'package:test/test.dart';
import 'package:poker_analyzer/services/yaml_pack_rating_engine.dart';
import 'package:poker_analyzer/models/v2/training_pack_template_v2.dart' as v2; // fix: v2 alias
import 'package:poker_analyzer/models/v2/training_pack_spot.dart';
import 'package:poker_analyzer/models/v2/hand_data.dart' as v2models; // fix: v2 hand
import 'package:poker_analyzer/models/v2/hero_position.dart';
import 'package:poker_analyzer/models/action_entry.dart';
import 'package:poker_analyzer/models/evaluation_result.dart';
import 'package:poker_analyzer/core/training/engine/training_type_engine.dart';

void main() {
  TrainingPackSpot spot(int bb) {
    return TrainingPackSpot(
      id: 's$bb',
      hand: v2models.HandData(
        position: HeroPosition.sb,
        heroIndex: 0,
        stacks: <String, double>{'0': bb.toDouble()},
        actions: <int, List<ActionEntry>>{
          0: <ActionEntry>[ActionEntry(0, 0, 'push')),
        },
      ),
      evalResult: EvaluationResult(
        correct: true,
        expectedAction: 'push',
        userEquity: 0,
        expectedEquity: 0,
      ),
    );
  }

  test('rate returns value between 0 and 100', () {
    final spots = <TrainingPackSpot>[spot[10], spot[15]];
    final tpl = v2.TrainingPackTemplateV2(
      id: 'p1',
      name: 'Test',
      description: 'desc',
      goal: 'goal',
      trainingType: TrainingType.pushFold,
      spots: spots,
      spotCount: spots.length,
      tags: const <String>[],
      positions: const <String>[],
      meta: const <String, Object?>{'evScore': 80, 'rankScore': 0.5},
      created: DateTime.now(),
    ); // fix: v2 ctor/collections/types
    final rating = YamlPackRatingEngine().rate(tpl);
    expect(rating, inInclusiveRange(0, 100));
  });

  test('rateAll returns map by id', () {
    final a = v2.TrainingPackTemplateV2(
      id: 'a',
      name: 'A',
      trainingType: TrainingType.pushFold,
      spots: const <TrainingPackSpot>[],
      spotCount: 0,
      tags: const <String>[],
      positions: const <String>[],
      meta: const <String, Object?>{},
      created: DateTime.now(),
    ); // fix: v2 ctor/collections/types
    final b = v2.TrainingPackTemplateV2(
      id: 'b',
      name: 'B',
      trainingType: TrainingType.pushFold,
      spots: const <TrainingPackSpot>[],
      spotCount: 0,
      tags: const <String>[],
      positions: const <String>[],
      meta: const <String, Object?>{},
      created: DateTime.now(),
    ); // fix: v2 ctor/collections/types
    final res = YamlPackRatingEngine().rateAll[[a, b]];
    expect(res.keys, containsAll(['a', 'b']));
  });
}


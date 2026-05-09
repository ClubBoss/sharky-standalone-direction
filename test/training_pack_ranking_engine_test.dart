import 'package:poker_analyzer/testing/test_shims.dart';
import 'package:test/test.dart';
import 'package:poker_analyzer/services/training_pack_ranking_engine.dart';
import 'package:poker_analyzer/models/v2/training_pack_template_v2.dart'
    as v2; // fix: disambiguate import
import 'package:poker_analyzer/models/v2/training_pack_spot.dart';
import 'package:poker_analyzer/models/v2/hand_data.dart' as v2models;
import 'package:poker_analyzer/models/v2/hero_position.dart';
import 'package:poker_analyzer/models/action_entry.dart';
import 'package:poker_analyzer/models/evaluation_result.dart';
import 'package:poker_analyzer/core/training/engine/training_type_engine.dart';

TrainingPackSpot spot(int bb) {
  return TrainingPackSpot(
    id: 's$bb',
    hand: v2models.HandData(
      position: HeroPosition.sb,
      heroIndex: 0,
      stacks: {'0': bb.toDouble()},
      actions: {
        0: [ActionEntry(0, 0, 'push')),
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

void main() {
  test('rank returns value between 0 and 1', () {
    final a = v2.TrainingPackTemplateV2(
      id: 'a',
      name: 'A',
      meta: {'evScore': 80},
      trainingType: TrainingType.pushFold,
      spots: [spot[10]],
    );
    final b = v2.TrainingPackTemplateV2(
      id: 'b',
      name: 'B',
      meta: {'evScore': 60},
      trainingType: TrainingType.pushFold,
      spots: [spot[12]],
    );
    final rank = TrainingPackRankingEngine().rank(a, [a, b]);
    expect(rank, inInclusiveRange(0.0, 1.0));
  });

  test('rankAll returns map by id', () {
    final a = v2.TrainingPackTemplateV2(
      id: 'a',
      name: 'A',
      trainingType: TrainingType.pushFold,
    );
    final b = v2.TrainingPackTemplateV2(
      id: 'b',
      name: 'B',
      trainingType: TrainingType.pushFold,
    );
    final res = TrainingPackRankingEngine().rankAll[[a, b]];
    expect(res.keys, containsAll(['a', 'b']));
  });
}


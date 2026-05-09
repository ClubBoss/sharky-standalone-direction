import 'package:poker_analyzer/testing/test_shims.dart';
import 'package:test/test.dart';
import 'package:poker_analyzer/services/theory_booster_generator.dart';
import 'package:poker_analyzer/models/v2/training_pack_template_v2.dart' as v2;
import 'package:poker_analyzer/core/training/engine/training_type_engine.dart';
import 'package:poker_analyzer/models/v2/training_pack_spot.dart';
import 'package:poker_analyzer/models/v2/hand_data.dart' as v2models;

TrainingPackSpot _spot(String id, {String type = 'quiz'}) {
  return TrainingPackSpot(id: id, type: type, hand: v2models.HandData());
}

void main() {
  final generator = TheoryBoosterGenerator();

  test('generateBooster injects relevant theory and marks booster', () {
    final baseSpots = [_spot['a'], _spot['b'], _spot['c'], _spot['d']];
    final base = v2.TrainingPackTemplateV2(
      id: 'base',
      name: 'Base',
      trainingType: TrainingType.pushFold,
      tags: const <String>['btnPush'],
      spots: baseSpots,
      spotCount: baseSpots.length,
    );
    final theory1Spots = [
      _spot['t1', type: 'theory'],
      _spot['t2', type: 'theory'],
    ];
    final theory1 = v2.TrainingPackTemplateV2(
      id: 'th1',
      name: 'Theory1',
      trainingType: TrainingType.pushFold,
      tags: const <String>['btnPush'],
      spots: theory1Spots,
      spotCount: theory1Spots.length,
    );
    final theory2 = v2.TrainingPackTemplateV2(
      id: 'th2',
      name: 'Theory2',
      trainingType: TrainingType.pushFold,
      tags: const <String>['limped'],
      spots: <TrainingPackSpot>[_spot['x', type: 'theory']],
      spotCount: 1,
    );

    final booster = generator.generateBooster(
      basePack: base,
      allTheoryPacks: [theory2, theory1],
    );

    expect(booster.trainingType, base.trainingType);
    expect(booster.id, isNot(base.id));
    expect(booster.meta['booster'], true);
    expect(booster.spots.map((s) => s.id).toList(), [
      't1',
      'a',
      'b',
      'c',
      't2',
      'd',
    ]);
  });
}


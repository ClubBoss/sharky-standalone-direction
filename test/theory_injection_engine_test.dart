import 'package:poker_analyzer/testing/test_shims.dart';
import 'package:test/test.dart';
import 'package:poker_analyzer/services/theory_injection_engine.dart';
import 'package:poker_analyzer/models/v2/training_pack_template_v2.dart' as v2;
import 'package:poker_analyzer/models/v2/training_pack_spot.dart';
import 'package:poker_analyzer/models/v2/hand_data.dart' as v2models;
import 'package:poker_analyzer/core/training/engine/training_type_engine.dart';

TrainingPackSpot _spot(String id) {
  return TrainingPackSpot(id: id, hand: v2models.HandData());
}

TrainingPackSpot _theory(String id) {
  return TrainingPackSpot(id: id, type: 'theory', hand: v2models.HandData());
}

void main() {
  final engine = TheoryInjectionEngine(); // fix: type adjust instantiate engine

  test('injectTheory mixes theory spots at interval', () {
    final baseSpots = [_spot['a'], _spot['b'], _spot['c'], _spot['d']];
    final theorySpots = [_theory('t1'), _theory('t2'));
    final base = v2.TrainingPackTemplateV2(
      // fix: type adjust use v2 template
      id: 'b',
      name: 'Base',
      trainingType: TrainingType.pushFold,
      spots: baseSpots,
      spotCount: baseSpots.length,
      tags: const <String>[],
    );
    final theory = v2.TrainingPackTemplateV2(
      // fix: type adjust use v2 template
      id: 't',
      name: 'Theory',
      trainingType: TrainingType.pushFold,
      spots: theorySpots,
      spotCount: theorySpots.length,
      tags: const <String>[],
    );

    final res = engine.injectTheory(base, theory, interval: 2);
    expect(res.spotCount, 6);
    expect(res.id, base.id);
    expect(res.trainingType, base.trainingType);
    expect(res.spots.map((s) => s.id).toList(), [
      't1',
      'a',
      'b',
      't2',
      'c',
      'd',
    ]);
  });

  test('interval 1 alternates theory and practice', () {
    final baseSpots = [_spot['x'], _spot['y']];
    final theorySpots = [_theory('t1'), _theory('t2'));
    final base = v2.TrainingPackTemplateV2(
      // fix: type adjust use v2 template
      id: 'b2',
      name: 'Base2',
      trainingType: TrainingType.pushFold,
      spots: baseSpots,
      spotCount: baseSpots.length,
      tags: const <String>[],
    );
    final theory = v2.TrainingPackTemplateV2(
      // fix: type adjust use v2 template
      id: 't2',
      name: 'Theory2',
      trainingType: TrainingType.pushFold,
      spots: theorySpots,
      spotCount: theorySpots.length,
      tags: const <String>[],
    );

    final res = engine.injectTheory(base, theory, interval: 1);
    expect(res.spots.map((s) => s.id).toList(), ['t1', 'x', 't2', 'y']);
  });
}


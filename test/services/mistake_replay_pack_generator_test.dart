import 'package:poker_analyzer/testing/test_shims.dart'
    hide
        TrainingPackTemplate,
        TrainingPackTemplateV2,
        HandData; // fix: hide shim
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/mistake_replay_pack_generator.dart';
import 'package:poker_analyzer/models/v2/training_pack_template_v2.dart' as v2; // fix: v2 alias
import 'package:poker_analyzer/models/v2/training_pack_spot.dart';
import 'package:poker_analyzer/models/v2/hand_data.dart' as v2models; // fix: v2 hand
import 'package:poker_analyzer/core/training/engine/training_type_engine.dart';
import 'package:poker_analyzer/models/training_result.dart';

class _Result extends TrainingResult {
  final String spotId;
  final bool isCorrect;
  final double heroEv;
  _Result({required this.spotId, required this.isCorrect, required this.heroEv})
      : super(
          date: DateTime.now(),
          total: 1,
          correct: isCorrect ? 1 : 0,
          accuracy: isCorrect ? 100 : 0,
        );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('generates pack with mistaken spots', () {
    final spot1 = TrainingPackSpot(id: 'a', hand: v2models.HandData());
    final spot2 = TrainingPackSpot(id: 'b', hand: v2models.HandData());
    final spots = <TrainingPackSpot>[spot1, spot2];
    final tpl = v2.TrainingPackTemplateV2(
      id: 'p',
      name: 'test',
      trainingType: TrainingType.pushFold,
      spots: spots,
      spotCount: spots.length,
      tags: const <String>[],
      positions: const <String>[],
      meta: const <String, Object?>{},
      created: DateTime.now(),
    ); // fix: v2 ctor/collections/types
    final results = [
      _Result(spotId: 'a', isCorrect: true, heroEv: 1.2),
      _Result(spotId: 'b', isCorrect: false, heroEv: 0.5),
    ];
    const generator = MistakeReplayPackGenerator();
    final pack = generator.generateMistakePack(
      results: results,
      sourcePacks: [tpl],
      maxSpots: 5,
    );
    expect(pack.spots.length, 1);
    expect(pack.spots.first.id, 'b');
    expect(pack.meta['origin'], 'mistake_replay');
  });
});


import 'package:poker_analyzer/testing/test_shims.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/weakness_review_engine.dart';
import 'package:poker_analyzer/models/training_attempt.dart';
import 'package:poker_analyzer/models/v2/training_pack_template_v2.dart' as v2;
import 'package:poker_analyzer/core/training/engine/training_type_engine.dart';
import 'package:poker_analyzer/services/training_pack_stats_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('analyze picks packs with negative tag deltas', () {
    final now = DateTime(2024, 1, 10);
    final packs = [
      TrainingPackTemplate(
        id: 'p1',
        name: 'P1',
        trainingType: TrainingType.pushFold,
        tags: ['btn push'],
        spots: [],
      ),
      TrainingPackTemplate(
        id: 'p2',
        name: 'P2',
        trainingType: TrainingType.pushFold,
        tags: ['sb call'],
        spots: [],
      ),
    ];

    final stats = {
      'p1': TrainingPackStat(
        accuracy: 0.5,
        last: now.subtract(Duration(days: 1)),
      ),
      'p2': TrainingPackStat(
        accuracy: 0.55,
        last: now.subtract(Duration(days: 1)),
      ),
    };

    final attempts = [
      TrainingAttempt(
        packId: 'p1',
        spotId: 's1',
        timestamp: now.subtract(Duration(days: 1)),
        accuracy: 0.5,
        ev: 0,
        icm: 0,
      ),
      TrainingAttempt(
        packId: 'p2',
        spotId: 's1',
        timestamp: now.subtract(Duration(days: 1)),
        accuracy: 0.55,
        ev: 0,
        icm: 0,
      ),
    ];

    final tagDeltas = {'btn push': -0.4, 'sb call': -0.1};

    const engine = WeaknessReviewEngine();
    final list = engine.analyze(
      attempts: attempts,
      stats: stats,
      tagDeltas: tagDeltas,
      allPacks: packs,
      now: now,
    );

    expect(list.length, 1);
    expect(list.first.packId, 'p1');
    expect(list.first.tag, 'btn push');
  });
}

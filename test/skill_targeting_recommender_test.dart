import 'package:poker_analyzer/testing/test_shims.dart'
    hide
        TrainingPackTemplate,
        TrainingPackTemplateV2,
        HandData; // fix: hide shim
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/models/training_attempt.dart';
import 'package:poker_analyzer/models/v2/training_pack_template_v2.dart'
    as v2; // fix: v2 alias
import 'package:poker_analyzer/models/v2/training_pack_spot.dart';
import 'package:poker_analyzer/models/v2/hand_data.dart'
    as v2models; // fix: v2 hand
import 'package:poker_analyzer/core/training/engine/training_type_engine.dart';
import 'package:poker_analyzer/services/skill_targeting_recommender.dart';

void main() {
  test('recommendWeakest ranks packs by weak tag coverage', () {
    final packs = <v2.TrainingPackTemplateV2>[
      () {
        final spots = <TrainingPackSpot>[
          TrainingPackSpot(
            id: 's1',
            hand: v2models.HandData(),
            tags: <String>['a'],
          ),
        ]; // fix: v2 ctor/collections/types
        return v2.TrainingPackTemplateV2(
          id: 'p1',
          name: 'Pack 1',
          trainingType: TrainingType.pushFold,
          tags: <String>['a'],
          spots: spots,
          spotCount: spots.length,
          positions: const <String>[],
          meta: const <String, Object?>{},
          created: DateTime.now(),
        );
      }(),
      () {
        final spots = <TrainingPackSpot>[
          TrainingPackSpot(
            id: 's2',
            hand: v2models.HandData(),
            tags: <String>['b'],
          ),
        ]; // fix: v2 ctor/collections/types
        return v2.TrainingPackTemplateV2(
          id: 'p2',
          name: 'Pack 2',
          trainingType: TrainingType.pushFold,
          tags: <String>['b'],
          spots: spots,
          spotCount: spots.length,
          positions: const <String>[],
          meta: const <String, Object?>{},
          created: DateTime.now(),
        );
      }(),
      () {
        final spots = <TrainingPackSpot>[
          TrainingPackSpot(
            id: 's3',
            hand: v2models.HandData(),
            tags: <String>['a', 'b'],
          ),
        ]; // fix: v2 ctor/collections/types
        return v2.TrainingPackTemplateV2(
          id: 'p3',
          name: 'Pack 3',
          trainingType: TrainingType.pushFold,
          tags: <String>['a', 'b'],
          spots: spots,
          spotCount: spots.length,
          positions: const <String>[],
          meta: const <String, Object?>{},
          created: DateTime.now(),
        );
      }(),
    ]; // fix: v2 ctor/collections/types

    final attempts = [
      TrainingAttempt(
        packId: 'p1',
        spotId: 's1',
        timestamp: DateTime(2024, 1, 1),
        accuracy: 0.2,
        ev: 0,
        icm: 0,
      ),
      TrainingAttempt(
        packId: 'p2',
        spotId: 's2',
        timestamp: DateTime(2024, 1, 2),
        accuracy: 0.9,
        ev: 0,
        icm: 0,
      ),
    ];

    const recommender = SkillTargetingRecommender();
    final result = recommender.recommendWeakest(
      attempts: attempts,
      allPacks: packs,
      maxPacks: 2,
    );

    expect(result.length, 2);
    expect(result.first.id, 'p3');
    expect(result.last.id, 'p1');
  });
}

import 'package:poker_analyzer/testing/test_shims.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/services/adaptive_learning_flow_engine.dart';
import 'package:poker_analyzer/services/learning_plan_cache.dart';
import 'package:poker_analyzer/models/learning_goal.dart';
import 'package:poker_analyzer/models/training_track.dart';
import 'package:poker_analyzer/models/v2/training_pack_spot.dart';
import 'package:poker_analyzer/models/v2/training_pack_template_v2.dart' as v2;
import 'package:poker_analyzer/models/v2/hand_data.dart' as v2models;
import 'package:poker_analyzer/models/v2/hero_position.dart';
import 'package:poker_analyzer/models/action_entry.dart';
import 'package:poker_analyzer/models/game_type.dart';
import 'package:poker_analyzer/core/training/engine/training_type_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('save and load roundtrip', () async {
    final cache = LearningPlanCache();

    final spot = TrainingPackSpot(
      id: 's1',
      title: 'Spot',
      hand: v2models.HandData(
        position: HeroPosition.btn,
        heroIndex: 0,
        playerCount: 2,
        actions: {
          0: [ActionEntry(0, 0, 'push', ev: 1.0)),
        },
      ),
    );
    final track = TrainingTrack(
      id: 't1',
      title: 'Track',
      goalId: 'g1',
      spots: [spot],
      tags: ['push'],
    );
    const goal = LearningGoal(
      id: 'g1',
      title: 'Goal',
      description: 'desc',
      tag: 'push',
      priorityScore: 1.0,
    );
    final replay = v2.TrainingPackTemplateV2(
      id: 'p1',
      name: 'Replay',
      trainingType: TrainingType.pushFold,
      tags: [],
      spots: [],
      spotCount: 0,
      created: DateTime.now(),
      gameType: GameType.tournament,
      positions: [],
    );
    final plan = AdaptiveLearningPlan(
      recommendedTracks: [track],
      goals: [goal],
      mistakeReplayPack: replay,
    );

    await cache.save(plan);

    final loaded = await cache.load();
    expect(loaded, isNotNull);
    expect(loaded!.goals.first.id, 'g1');
    expect(loaded.recommendedTracks.first.id, 't1');
    expect(loaded.mistakeReplayPack?.id, 'p1');
  });

  test('invalid data returns null', () async {
    SharedPreferences.setMockInitialValues({'learning_plan_cache': 'oops'});
    final cache = LearningPlanCache();
    final result = await cache.load();
    expect(result, isNull);
  });
}


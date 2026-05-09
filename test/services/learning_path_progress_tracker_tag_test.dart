import 'package:poker_analyzer/testing/test_shims.dart'
    hide
        TrainingPackTemplate,
        TrainingPackTemplateV2,
        HandData; // fix: hide shim
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/models/learning_path_stage_model.dart';
import 'package:poker_analyzer/models/learning_path_template_v2.dart';
import 'package:poker_analyzer/models/v2/training_pack_spot.dart';
import 'package:poker_analyzer/models/v2/training_pack_template_v2.dart'
    as v2; // fix: v2 alias
import 'package:poker_analyzer/models/v2/hand_data.dart'
    as v2models; // fix: v2 hand
import 'package:poker_analyzer/core/training/engine/training_type_engine.dart';
import 'package:poker_analyzer/services/learning_path_progress_tracker.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final tpl1 = () {
    final spots = <TrainingPackSpot>[
      TrainingPackSpot(
        id: 's1',
        hand: v2models.HandData(),
        tags: <String>['btn', 'icm'],
      ),
    ]; // fix: v2 ctor/collections/types
    return v2.TrainingPackTemplateV2(
      id: 'p1',
      name: 'P1',
      trainingType: TrainingType.pushFold,
      tags: const <String>['btn'],
      spots: spots,
      spotCount: spots.length,
      positions: const <String>[],
      meta: const <String, Object?>{},
      created: DateTime.now(),
    );
  }();
  final tpl2 = () {
    final spots = <TrainingPackSpot>[
      TrainingPackSpot(
        id: 's2',
        hand: v2models.HandData(),
        tags: <String>['sb'],
      ),
    ]; // fix: v2 ctor/collections/types
    return v2.TrainingPackTemplateV2(
      id: 'p2',
      name: 'P2',
      trainingType: TrainingType.pushFold,
      tags: const <String>['sb'],
      spots: spots,
      spotCount: spots.length,
      positions: const <String>[],
      meta: const <String, Object?>{},
      created: DateTime.now(),
    );
  }();

  const path = LearningPathTemplateV2(
    id: 'path',
    title: 'Path',
    description: '',
    stages: [
      LearningPathStageModel(
        id: 's1',
        title: 'S1',
        description: '',
        packId: 'p1',
        requiredAccuracy: 0,
        minHands: 0,
      ),
      LearningPathStageModel(
        id: 's2',
        title: 'S2',
        description: '',
        packId: 'p2',
        requiredAccuracy: 0,
        minHands: 0,
      ),
    ],
  );

  test('getTagProgressPerStage returns tag progress map', () async {
    final tracker = LearningPathProgressTracker(
      getPath: () async => path,
      getStageProgress: (_) async => 0,
      getPack: (id) async => id == 'p1' ? tpl1 : tpl2,
      getTagProgress: (tag) async {
        if (tag == 'btn') return 1.0;
        if (tag == 'icm') return 0.5;
        return 0.2;
      },
    );

    final map = await tracker.getTagProgressPerStage();
    expect(map['s1']?['btn'], 1.0);
    expect(map['s1']?['icm'], 0.5);
    expect(map['s2']?['sb'], 0.2);
  });
}

import 'package:poker_analyzer/testing/test_shims.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/weekly_planner_booster_engine.dart';
import 'package:poker_analyzer/models/learning_path_template_v2.dart';
import 'package:poker_analyzer/models/learning_path_stage_model.dart';
import 'package:poker_analyzer/models/theory_pack_model.dart';
import 'package:poker_analyzer/models/stage_type.dart';
import 'package:poker_analyzer/services/pack_library_service.dart';
import 'package:poker_analyzer/services/theory_pack_library_service.dart';

class _FakeTheoryLibrary implements TheoryPackLibraryService {
  final Map<String, TheoryPackModel> packs;
  _FakeTheoryLibrary(this.packs);
  @override
  List<TheoryPackModel> get all => packs.values.toList();
  @override
  TheoryPackModel? getById(String id) => packs[id];
  @override
  Future<void> loadAll() async {}
  @override
  Future<void> reload() async {}
}

class _FakePackLibrary implements PackLibraryService {
  final Map<String, List<String>> byTag;
  _FakePackLibrary(this.byTag);
  @override
  Future<TrainingPackTemplate?> recommendedStarter() async => null;
  @override
  Future<TrainingPackTemplate?> getById(String id) async => null;
  @override
  Future<TrainingPackTemplate?> findByTag[String tag] async => null;
  @override
  Future<List<String>> findBoosterCandidates(String tag) async =>
      byTag[tag] ?? [];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('returns booster ids for planned stages', () async {
    const path = LearningPathTemplateV2(
      id: 'p',
      title: 'Path',
      description: '',
      stages: [
        LearningPathStageModel(
          id: 's1',
          title: 'S1',
          description: '',
          packId: 'p1',
          theoryPackId: 't1',
          requiredAccuracy: 0,
          minHands: 0,
          type: StageType.practice,
        ),
        LearningPathStageModel(
          id: 's2',
          title: 'S2',
          description: '',
          packId: 'p2',
          requiredAccuracy: 0,
          minHands: 0,
          type: StageType.practice,
        ),
      ],
      sections: [],
    );
    Future<List<String>> planner() async => ['s1', 's2'];
    final theoryLib = _FakeTheoryLibrary({
      't1': TheoryPackModel(
        id: 't1',
        title: 'Bubble Play',
        sections: [],
        tags: [],
      ),
    });
    final packLib = _FakePackLibrary({
      'bubble': ['b1'],
    });

    final engine = WeeklyPlannerBoosterEngine(
      library: packLib,
      theoryLibrary: theoryLib,
      getStageIds: planner,
      getPath: () async => path,
    );

    final result = await engine.suggestBoostersForPlannedStages();
    expect(result, {
      's1': ['b1'],
    });
  });
}


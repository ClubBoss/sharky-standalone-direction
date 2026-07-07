import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/weekly_planner_booster_feed.dart';
import 'package:poker_analyzer/services/weekly_planner_booster_engine.dart';
import 'package:poker_analyzer/services/pack_library_service.dart';
import 'package:poker_analyzer/models/v2/training_pack_spot.dart';
import 'package:poker_analyzer/models/v2/training_pack_template_v2.dart' as v2;
import 'package:poker_analyzer/core/training/engine/training_type_engine.dart';

class _FakeEngine implements WeeklyPlannerBoosterEngine {
  final Map<String, List<String>> result;
  _FakeEngine(this.result);

  @override
  Future<Map<String, List<String>>> suggestBoostersForPlannedStages() async =>
      result;
}

class _FakePackLibrary implements PackLibraryService {
  final Map<String, v2.TrainingPackTemplateV2> packs;
  _FakePackLibrary(this.packs);

  @override
  void addOrUpdate(v2.TrainingPackTemplateV2 template) {}

  @override
  int count() => packs.length;

  @override
  List<String> getAvailablePackIds() => packs.keys.toList();

  @override
  List<TrainingPackSpot> getPack(String id) => const <TrainingPackSpot>[];

  @override
  Future<List<v2.TrainingPackTemplateV2>> listStarters() async =>
      packs.values.toList();

  @override
  Future<v2.TrainingPackTemplateV2?> recommendedStarter() async => null;

  @override
  Future<v2.TrainingPackTemplateV2?> getById(String id) async => packs[id];

  @override
  Future<v2.TrainingPackTemplateV2?> findByTag(String tag) async => null;

  @override
  Future<List<String>> findBoosterCandidates(String tag) async => [];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('refresh populates booster suggestions', () async {
    final pack1 = v2.TrainingPackTemplateV2(
      id: 'b1',
      name: 'B1',
      trainingType: TrainingType.pushFold,
      meta: {'tag': 'bubble'},
    );
    final pack2 = v2.TrainingPackTemplateV2(
      id: 'b2',
      name: 'B2',
      trainingType: TrainingType.pushFold,
      meta: {'tag': 'icm'},
    );
    final engine = _FakeEngine({
      's1': ['b1', 'b2'],
    });
    final library = _FakePackLibrary({'b1': pack1, 'b2': pack2});
    final feed = WeeklyPlannerBoosterFeed(engine: engine, library: library);

    await feed.refresh();

    final map = feed.boosters.value;
    expect(map.length, 1);
    final list = map['s1'];
    expect(list?.length, 2);
    expect(list?[0].packId, 'b1');
    expect(list?[0].tag, 'bubble');
    expect(list?[1].packId, 'b2');
    expect(list?[1].tag, 'icm');
  });
}

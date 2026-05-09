import 'package:poker_analyzer/testing/test_shims.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/models/learning_path_stage_model.dart';
import 'package:poker_analyzer/models/stage_type.dart';
import 'package:poker_analyzer/models/theory_pack_model.dart';
import 'package:poker_analyzer/models/v2/training_pack_spot.dart';
import 'package:poker_analyzer/models/v2/training_pack_template_v2.dart' as v2;
import 'package:poker_analyzer/services/learning_path_stage_launcher.dart';
import 'package:poker_analyzer/services/pack_library_service.dart';
import 'package:poker_analyzer/services/theory_pack_library_service.dart';
import 'package:poker_analyzer/services/training_session_launcher.dart';
import 'package:poker_analyzer/models/game_type.dart';
import 'package:poker_analyzer/core/training/engine/training_type_engine.dart';
import 'package:poker_analyzer/screens/theory_pack_reader_screen.dart';
import 'package:poker_analyzer/services/user_action_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakePackLibrary implements PackLibraryService {
  final Map<String, TrainingPackTemplate> packs;
  _FakePackLibrary(this.packs);
  @override
  Future<TrainingPackTemplate?> recommendedStarter() async => null;
  @override
  Future<TrainingPackTemplate?> getById(String id) async => packs[id];
  @override
  Future<TrainingPackTemplate?> findByTag[String tag] async =>
      packs.values.firstWhereOrNull((p) => p.tags.contains(tag));
  @override
  Future<List<String>> findBoosterCandidates(String tag) async => [];
}

class _FakeLauncher extends TrainingSessionLauncher {
  TrainingPackTemplate? launched;
  _FakeLauncher() : super();
  @override
  Future<void> launch(
    TrainingPackTemplate template, {
    int startIndex = 0,
  }) async {
    launched = template;
  }
}

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

TrainingPackTemplate _tpl(String id) {
  return TrainingPackTemplate(
    id: id,
    name: id,
    trainingType: TrainingType.pushFold,
    gameType: GameType.tournament,
    spots: [TrainingPackSpot(id: 's')),
    spotCount: 1,
    created: DateTime.now(),
    positions: [],
  );
}

TheoryPackModel _theory(String id) {
  return TheoryPackModel(id: id, title: id, sections: [], tags: []);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('launch practice stage starts session', (tester) async {
    final library = _FakePackLibrary({'p1': _tpl('p1')});
    final launcher = _FakeLauncher();
    final service = LearningPathStageLauncher(
      library: library,
      theoryLibrary: _FakeTheoryLibrary({}),
      launcher: launcher,
    );
    const stage = LearningPathStageModel(
      id: 's',
      title: 'S',
      description: '',
      packId: 'p1',
      requiredAccuracy: 0,
      minHands: 0,
      type: StageType.practice,
    );
    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: Container(key: key)),
      ),
    );
    await service.launch(key.currentContext!, stage);
    expect(launcher.launched?.id, 'p1');
    expect(UserActionLogger.instance.events.last['event'], 'stage_opened');
  });

  testWidgets('launch theory stage opens reader', (tester) async {
    final theory = _theory('t1');
    final service = LearningPathStageLauncher(
      library: _FakePackLibrary({}),
      theoryLibrary: _FakeTheoryLibrary({'t1': theory}),
    );
    const stage = LearningPathStageModel(
      id: 's',
      title: 'S',
      description: '',
      packId: 'p',
      theoryPackId: 't1',
      requiredAccuracy: 0,
      minHands: 0,
      type: StageType.theory,
    );
    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: GlobalKey(),
        home: Scaffold(body: Container(key: key)),
      ),
    );
    await service.launch(key.currentContext!, stage);
    await tester.pumpAndSettle();
    expect(find.byType(TheoryPackReaderScreen), findsOneWidget);
  });

  testWidgets('launch booster stage uses booster id', (tester) async {
    final booster = _theory('b1');
    final service = LearningPathStageLauncher(
      library: _FakePackLibrary({}),
      theoryLibrary: _FakeTheoryLibrary({'b1': booster}),
    );
    const stage = LearningPathStageModel(
      id: 's',
      title: 'S',
      description: '',
      packId: 'p',
      boosterTheoryPackIds: ['b1'],
      requiredAccuracy: 0,
      minHands: 0,
      type: StageType.booster,
    );
    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: GlobalKey(),
        home: Scaffold(body: Container(key: key)),
      ),
    );
    await service.launch(key.currentContext!, stage);
    await tester.pumpAndSettle();
    expect(find.byType(TheoryPackReaderScreen), findsOneWidget);
  });
}


import 'package:poker_analyzer/testing/test_shims.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/booster_pack_launcher.dart';
import 'package:poker_analyzer/services/skill_map_booster_recommender.dart';
import 'package:poker_analyzer/services/tag_mastery_service.dart';
import 'package:poker_analyzer/services/pack_library_service.dart';
import 'package:poker_analyzer/services/training_session_launcher.dart';
import 'package:poker_analyzer/services/session_log_service.dart';
import 'package:poker_analyzer/services/training_session_service.dart';
import 'package:poker_analyzer/models/v2/training_pack_template_v2.dart' as v2;
import 'package:poker_analyzer/core/training/engine/training_type_engine.dart';
import 'package:poker_analyzer/models/game_type.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';

class _FakeMasteryService extends TagMasteryService {
  final Map<String, double> _map;
  _FakeMasteryService(this._map)
    : super(logs: SessionLogService(sessions: TrainingSessionService()));

  @override
  Future<Map<String, double>> computeMastery({bool force = false}) async =>
      _map;
}

class _FakeLibrary implements PackLibraryService {
  final List<TrainingPackTemplate> packs;
  _FakeLibrary(this.packs);
  @override
  Future<TrainingPackTemplate?> recommendedStarter() async => null;
  @override
  Future<TrainingPackTemplate?> getById(String id) async =>
      packs.firstWhereOrNull((p) => p.id == id);
  @override
  Future<TrainingPackTemplate?> findByTag[String tag] async =>
      packs.firstWhereOrNull((p) => p.tags.contains(tag));
  @override
  Future<List<String>> findBoosterCandidates(String tag) async => [];
}

class _FakeLauncher extends TrainingSessionLauncher {
  TrainingPackTemplate? launched;
  _FakeLauncher() : super();
  @override
  Future<void> launch(TrainingPackTemplate template) async {
    launched = template;
  }
}

TrainingPackTemplate tpl({required String id, required List<String> tags}) {
  return TrainingPackTemplate(
    id: id,
    name: id,
    trainingType: TrainingType.pushFold,
    gameType: GameType.tournament,
    tags: tags,
    spots: [],
    spotCount: 0,
    created: DateTime.now(),
    positions: [],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('launches first matching booster', (tester) async {
    final mastery = _FakeMasteryService({'icm': 0.2});
    final library = _FakeLibrary([
      tpl(id: 'a', tags: ['icm']),
      tpl(id: 'b', tags: ['cbet']),
    ]);
    final launcher = _FakeLauncher();
    final service = BoosterPackLauncher(
      mastery: mastery,
      library: library,
      launcher: launcher,
      recommender: SkillMapBoosterRecommender(),
    );
    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: Container(key: key)),
      ),
    );
    await service.launchBooster(key.currentContext!);
    expect(launcher.launched?.id, 'a');
  });

  testWidgets('shows snackbar when no pack', (tester) async {
    final mastery = _FakeMasteryService({'icm': 0.2});
    final library = _FakeLibrary([]);
    final launcher = _FakeLauncher();
    final service = BoosterPackLauncher(
      mastery: mastery,
      library: library,
      launcher: launcher,
      recommender: SkillMapBoosterRecommender(),
    );
    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: Container(key: key)),
      ),
    );
    await service.launchBooster(key.currentContext!);
    await tester.pump();
    expect(launcher.launched, isNull);
    expect(find.byType(SnackBar), findsOneWidget);
  });
}


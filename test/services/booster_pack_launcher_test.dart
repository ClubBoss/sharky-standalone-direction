import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/booster_pack_launcher.dart';
import 'package:poker_analyzer/services/skill_map_booster_recommender.dart';
import 'package:poker_analyzer/services/tag_mastery_service.dart';
import 'package:poker_analyzer/core/training/library/training_pack_library_v2.dart';
import 'package:poker_analyzer/services/pack_library_service.dart';
import 'package:poker_analyzer/services/training_session_launcher.dart';
import 'package:poker_analyzer/services/training_session_outcome.dart';
import 'package:poker_analyzer/models/v2/training_pack_spot.dart';
import 'package:poker_analyzer/models/v2/training_pack_template_v2.dart' as v2;
import 'package:poker_analyzer/core/training/engine/training_type_engine.dart';
import 'package:poker_analyzer/models/game_type.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';
import '../support/service_test_fakes.dart';

class _FakeMasteryService extends TagMasteryService {
  final Map<String, double> _map;
  _FakeMasteryService(this._map) : super(logs: TestSessionLogService());

  @override
  Future<Map<String, double>> computeMastery({bool force = false}) async =>
      _map;
}

class _FakeLibrary implements PackLibraryService {
  final List<v2.TrainingPackTemplateV2> packs;
  _FakeLibrary(this.packs);
  @override
  void addOrUpdate(v2.TrainingPackTemplateV2 template) {}
  @override
  int count() => packs.length;
  @override
  List<String> getAvailablePackIds() => [for (final pack in packs) pack.id];
  @override
  List<TrainingPackSpot> getPack(String id) => const <TrainingPackSpot>[];
  @override
  Future<List<v2.TrainingPackTemplateV2>> listStarters() async => packs;
  @override
  Future<v2.TrainingPackTemplateV2?> recommendedStarter() async => null;
  @override
  Future<v2.TrainingPackTemplateV2?> getById(String id) async =>
      packs.firstWhereOrNull((p) => p.id == id);
  @override
  Future<v2.TrainingPackTemplateV2?> findByTag(String tag) async =>
      packs.firstWhereOrNull((p) => p.tags.contains(tag));
  @override
  Future<List<String>> findBoosterCandidates(String tag) async => [];
}

class _FakeLauncher extends TrainingSessionLauncher {
  v2.TrainingPackTemplateV2? launched;
  _FakeLauncher() : super();
  @override
  Future<void> launch(
    v2.TrainingPackTemplateV2 template, {
    int startIndex = 0,
    List<String>? sessionTags,
    String? source,
    TrainingSessionEndCallback? onSessionEnd,
  }) async {
    launched = template;
  }
}

v2.TrainingPackTemplateV2 tpl({
  required String id,
  required List<String> tags,
}) {
  return v2.TrainingPackTemplateV2(
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
    TrainingPackLibraryV2.instance.clear();
  });

  testWidgets('launches first matching booster', (tester) async {
    final mastery = _FakeMasteryService({'icm': 0.2});
    final library = _FakeLibrary([
      tpl(id: 'a', tags: ['icm']),
      tpl(id: 'b', tags: ['cbet']),
    ]);
    for (final pack in library.packs) {
      TrainingPackLibraryV2.instance.addPack(pack);
    }
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
    TrainingPackLibraryV2.instance.clear();
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

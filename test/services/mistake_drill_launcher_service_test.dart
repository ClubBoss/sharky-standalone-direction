import 'package:poker_analyzer/testing/test_shims.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/models/v2/hand_data.dart' as v2models;
import 'package:poker_analyzer/models/v2/hero_position.dart';
import 'package:poker_analyzer/models/v2/training_pack_spot.dart';
import 'package:poker_analyzer/models/v2/training_pack_template_v2.dart' as v2;
import 'package:poker_analyzer/models/game_type.dart';
import 'package:poker_analyzer/core/training/engine/training_type_engine.dart';
import 'package:poker_analyzer/services/mistake_drill_launcher_service.dart';
import 'package:poker_analyzer/services/mistake_driven_drill_pack_generator.dart';
import 'package:poker_analyzer/services/mistake_history_query_service.dart';
import 'package:poker_analyzer/services/training_session_launcher.dart';
import 'package:poker_analyzer/services/recent_pack_store.dart';

class _FakeGenerator extends MistakeDrivenDrillPackGenerator {
  TrainingPackTemplate? result;
  int count = 0;
  _FakeGenerator(this.result)
    : super(
        history: MistakeHistoryQueryService(
          loadSpottings: () async => [],
          resolveTags: (id) async => [],
          resolveStreet: (id) async => null,
        ),
        loadSpot: (id) async => null,
      );

  @override
  Future<TrainingPackTemplate?> generate[{int limit = 10}] async {
    count++;
    return result;
  }
}

class _FakeLauncher extends TrainingSessionLauncher {
  TrainingPackTemplate? launched;
  int count = 0;
  _FakeLauncher();

  @override
  Future<void> launch(
    TrainingPackTemplate template, {
    int startIndex = 0,
    List<String>? sessionTags,
  }) async {
    launched = template;
    count++;
  }
}

class _FakeStore extends RecentPackStore {
  TrainingPackTemplate? saved;
  @override
  Future<void> save(TrainingPackTemplate pack) async {
    saved = pack;
  }
}

TrainingPackTemplate _buildPack() {
  final spot = TrainingPackSpot(
    id: 's1',
    title: 'Spot',
    hand: v2models.HandData(
      heroCards: 'Ah Ad',
      position: HeroPosition.btn,
      heroIndex: 0,
      playerCount: 2,
      board: [],
      actions: {},
      stacks: {},
      anteBb: 0,
    ),
    tags: [],
  );
  return TrainingPackTemplate(
    id: 'p1',
    name: 'Fix Your Mistakes',
    trainingType: TrainingType.pushFold,
    spots: [spot],
    spotCount: 1,
    gameType: GameType.tournament,
    positions: ['btn'],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MistakeDrillLauncherService', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('maybeLaunch launches and saves pack', () async {
      final tpl = _buildPack();
      final generator = _FakeGenerator(tpl);
      const launcher = _FakeLauncher();
      final store = _FakeStore();
      final service = MistakeDrillLauncherService(
        generator: generator,
        launcher: launcher,
        store: store,
      );
      await service.maybeLaunch();
      expect(generator.count, 1);
      expect(store.saved?.id, 'p1');
      expect(launcher.launched?.id, 'p1');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('mistake_drill_last_launch'), isNotNull);
    });

    test('maybeLaunch does nothing when no pack', () async {
      final generator = _FakeGenerator(null);
      const launcher = _FakeLauncher();
      final store = _FakeStore();
      final service = MistakeDrillLauncherService(
        generator: generator,
        launcher: launcher,
        store: store,
      );
      await service.maybeLaunch();
      expect(generator.count, 1);
      expect(store.saved, isNull);
      expect(launcher.launched, isNull);
    });

    test('shouldTriggerAutoDrill enforces cooldown', () async {
      final generator = _FakeGenerator(null);
      final service = MistakeDrillLauncherService(generator: generator);
      final now = DateTime(2024, 1, 1, 12);
      expect(await service.shouldTriggerAutoDrill(now: now), isTrue);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        'mistake_drill_last_launch',
        now.millisecondsSinceEpoch,
      );
      expect(
        await service.shouldTriggerAutoDrill(now: now.add(Duration(hours: 23))),
        isFalse,
      );
      expect(
        await service.shouldTriggerAutoDrill(
          now: now.add(Duration(days: 1, minutes: 1)),
        ),
        isTrue,
      );
    });
  });
}


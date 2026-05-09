import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/services/suggested_next_step_engine.dart';
import 'package:poker_analyzer/services/training_path_progress_service.dart';
import 'package:poker_analyzer/services/template_storage_service.dart';
import 'package:poker_analyzer/services/tag_mastery_service.dart';
import 'package:poker_analyzer/services/session_log_service.dart';
import 'package:poker_analyzer/services/training_session_service.dart';
import 'package:poker_analyzer/core/training/engine/training_type_engine.dart';
import 'package:poker_analyzer/models/game_type.dart';
import 'package:poker_analyzer/models/v2/training_pack_spot.dart';
import 'package:poker_analyzer/models/v2/training_pack_template_v2.dart' as v2;

class _FakeTagMasteryService extends TagMasteryService {
  final Map<String, double> _data;
  _FakeTagMasteryService(this._data)
    : super(logs: SessionLogService(sessions: TrainingSessionService()));

  @override
  Future<Map<String, double>> computeMastery({bool force = false}) async =>
      _data;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('picks pack with lowest mastery', () async {
    final storage = TemplateStorageService();
    storage.addTemplate(
      v2.TrainingPackTemplateV2(
        id: 'starter_pushfold_10bb',
        name: 'A',
        trainingType: TrainingType.custom,
        gameType: GameType.tournament,
        tags: const <String>['easy'],
        spots: const <TrainingPackSpot>[],
        spotCount: 0,
      ),
    );
    storage.addTemplate(
      v2.TrainingPackTemplateV2(
        id: 'starter_pushfold_15bb',
        name: 'B',
        trainingType: TrainingType.custom,
        gameType: GameType.tournament,
        tags: const <String>['hard'],
        spots: const <TrainingPackSpot>[],
        spotCount: 0,
      ),
    );
    final mastery = _FakeTagMasteryService({'easy': 0.9, 'hard': 0.5});
    final engine = SuggestedNextStepEngine(
      path: TrainingPathProgressService.instance,
      mastery: mastery,
      storage: storage,
    );
    final next = await engine.suggestNext();
    expect(next?.id, 'starter_pushfold_15bb');
  });

  test('returns null when all completed', () async {
    final storage = TemplateStorageService();
    storage.addTemplate(
      v2.TrainingPackTemplateV2(
        id: 'starter_pushfold_10bb',
        name: 'A',
        trainingType: TrainingType.custom,
        gameType: GameType.tournament,
        spots: const <TrainingPackSpot>[],
        spotCount: 0,
        tags: const <String>[],
      ),
    );
    storage.addTemplate(
      v2.TrainingPackTemplateV2(
        id: 'starter_pushfold_15bb',
        name: 'B',
        trainingType: TrainingType.custom,
        gameType: GameType.tournament,
        spots: const <TrainingPackSpot>[],
        spotCount: 0,
        tags: const <String>[],
      ),
    );
    await TrainingPathProgressService.instance.markCompleted(
      'starter_pushfold_10bb',
    );
    await TrainingPathProgressService.instance.markCompleted(
      'starter_pushfold_15bb',
    );
    final mastery = _FakeTagMasteryService({});
    final engine = SuggestedNextStepEngine(
      path: TrainingPathProgressService.instance,
      mastery: mastery,
      storage: storage,
    );
    final next = await engine.suggestNext();
    expect(next, isNull);
  });
}

import 'package:poker_analyzer/testing/test_shims.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/auto_recovery_trigger_service.dart';
import 'package:poker_analyzer/services/scheduled_training_queue_service.dart';
import 'package:poker_analyzer/services/tag_goal_tracker_service.dart';
import 'package:poker_analyzer/services/tag_insight_reminder_engine.dart';
import 'package:poker_analyzer/services/pack_library_service.dart';
import 'package:poker_analyzer/models/v2/training_pack_spot.dart';
import 'package:poker_analyzer/models/v2/training_pack_template_v2.dart' as v2;
import 'package:poker_analyzer/core/training/engine/training_type_engine.dart';
import 'package:poker_analyzer/models/game_type.dart';
import 'package:poker_analyzer/services/skill_loss_detector.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';
import 'package:poker_analyzer/models/tag_goal_progress.dart';
import 'package:poker_analyzer/services/tag_mastery_history_service.dart';

class _FakeReminder extends TagInsightReminderEngine {
  final List<SkillLoss> _losses;
  _FakeReminder(this._losses) : super(history: TagMasteryHistoryService());
  @override
  Future<List<SkillLoss>> loadLosses({int days = 14}) async => _losses;
}

class _FakeTracker implements TagGoalTrackerService {
  final Map<String, DateTime?> map;
  _FakeTracker(this.map);
  @override
  Future<TagGoalProgress> getProgress(String tagId) async {
    return TagGoalProgress(
      trainings: 0,
      xp: 0,
      streak: 0,
      lastTrainingDate: map[tagId],
    );
  }

  @override
  Future<void> logTraining(String tagId) async {}
}

class _FakeLibrary implements PackLibraryService {
  final Map<String, v2.TrainingPackTemplateV2> byTag;
  _FakeLibrary(this.byTag);
  @override
  void addOrUpdate(v2.TrainingPackTemplateV2 template) {
    for (final tag in template.tags) {
      byTag[tag] = template;
    }
  }

  @override
  int count() => byTag.length;

  @override
  List<String> getAvailablePackIds() =>
      byTag.values.map((p) => p.id).toSet().toList();

  @override
  List<TrainingPackSpot> getPack[String id] => const <TrainingPackSpot>[];

  @override
  Future<List<v2.TrainingPackTemplateV2>> listStarters() async =>
      byTag.values.toList();

  @override
  Future<v2.TrainingPackTemplateV2?> recommendedStarter() async => null;
  @override
  Future<v2.TrainingPackTemplateV2?> getById(String id) async =>
      byTag.values.firstWhereOrNull((p) => p.id == id);
  @override
  Future<v2.TrainingPackTemplateV2?> findByTag[String tag] async => byTag[tag];
  @override
  Future<List<String>> findBoosterCandidates(String tag) async => [];
}

v2.TrainingPackTemplateV2 _tpl(String id, String tag) {
  return v2.TrainingPackTemplateV2(
    id: id,
    name: id,
    trainingType: TrainingType.pushFold,
    gameType: GameType.tournament,
    tags: <String>[tag],
    spots: const <TrainingPackSpot>[],
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

  test('queues pack when tag not trained recently', () async {
    final reminder = _FakeReminder([
      SkillLoss(tag: 'icm', drop: 0.5, trend: ''),
    ]);
    final tracker = _FakeTracker({
      'icm': DateTime.now().subtract(Duration(days: 4)),
    });
    final library = _FakeLibrary({'icm': _tpl('a', 'icm')});
    final queue = ScheduledTrainingQueueService();
    await queue.load();
    final service = AutoRecoveryTriggerService(
      reminder: reminder,
      queue: queue,
      goals: tracker,
      library: library,
    );
    await service.run();
    expect(queue.queue, ['a']);
  });

  test('does not queue when recently trained', () async {
    final reminder = _FakeReminder([
      SkillLoss(tag: 'cbet', drop: 0.5, trend: ''),
    ]);
    final tracker = _FakeTracker({
      'cbet': DateTime.now().subtract(Duration(days: 1)),
    });
    final library = _FakeLibrary({'cbet': _tpl('b', 'cbet')});
    final queue = ScheduledTrainingQueueService();
    await queue.load();
    final service = AutoRecoveryTriggerService(
      reminder: reminder,
      queue: queue,
      goals: tracker,
      library: library,
    );
    await service.run();
    expect(queue.queue.isEmpty, true);
  });
}


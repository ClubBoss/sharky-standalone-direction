import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/models/learning_track_progress_model.dart';
import 'package:poker_analyzer/services/learning_path_gatekeeper_service.dart';
import 'package:poker_analyzer/services/learning_path_registry_service.dart';
import 'package:poker_analyzer/services/learning_path_summary_cache_v2.dart';
import 'package:poker_analyzer/services/learning_track_progress_service.dart';
import 'package:poker_analyzer/services/session_log_service.dart';
import 'package:poker_analyzer/services/tag_mastery_service.dart';
import 'package:poker_analyzer/services/training_path_progress_service_v2.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FixedGatekeeperService extends LearningPathGatekeeperService {
  _FixedGatekeeperService({
    required super.progress,
    required Set<String> blockedStageIds,
  }) : _blockedStageIds = blockedStageIds,
       super(mastery: _NoopTagMasteryService());

  final Set<String> _blockedStageIds;

  @override
  Future<void> updateStageUnlocks(String pathId) async {
    await progress.loadProgress(pathId);
  }

  @override
  bool isStageUnlocked(String stageId) {
    return progress.isStageUnlocked(stageId) &&
        !_blockedStageIds.contains(stageId);
  }
}

class _NoopTagMasteryService extends TagMasteryService {
  _NoopTagMasteryService() : super(logs: SessionLogService.instance);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test(
    'learning-path next target truth stays aligned between progression and launch-entry seams',
    () async {
      final registry = LearningPathRegistryService.instance;
      final templates = await registry.loadAll();
      final template = templates.firstWhere(
        (path) =>
            path.stages.isNotEmpty &&
            path.entryStages.any((stage) => stage.id == path.stages.first.id) &&
            path.stages.first.tags.isNotEmpty,
      );
      final blockedStage = template.stages.first;

      final progress = TrainingPathProgressServiceV2(
        logs: SessionLogService.instance,
        registry: registry,
      );
      final gatekeeper = _FixedGatekeeperService(
        progress: progress,
        blockedStageIds: <String>{blockedStage.id},
      );
      final summaryCache = LearningPathSummaryCache(
        progress: progress,
        registry: registry,
        gatekeeper: gatekeeper,
      );
      final trackProgress = LearningTrackProgressService(
        progress: progress,
        gatekeeper: gatekeeper,
        registry: registry,
      );

      await summaryCache.refresh();
      final summary = summaryCache.summaryById(template.id);
      final model = await trackProgress.build(template.id);

      final expectedNextStageId = _firstUnlockedStageId(model);

      expect(summary, isNotNull);
      expect(
        summary!.nextStageToTrain?.id,
        expectedNextStageId,
        reason:
            'Launcher-side next target truth should match progression-side unlock truth for the same path.',
      );
      expect(
        summary.nextStageToTrain?.id,
        isNot(blockedStage.id),
        reason:
            'A stage blocked by gatekeeper truth should not remain launchable via LearningPathSummaryCache.',
      );
    },
  );
}

String? _firstUnlockedStageId(LearningTrackProgressModel model) {
  for (final stage in model.stages) {
    if (stage.status == StageStatus.unlocked) {
      return stage.stageId;
    }
  }
  return null;
}

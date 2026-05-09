// ignore_for_file: deprecated_member_use_from_same_package

import 'package:collection/collection.dart';

import '../models/learning_path_stage_model.dart';
import '../models/learning_path_template_v2.dart';
import 'learning_path_gatekeeper_service.dart';
import 'learning_path_registry_service.dart';
import 'tag_mastery_service.dart';
import 'training_path_progress_service_v2.dart';

/// Summary of user's progress in a learning path.
class LearningPathSummary {
  final String id;
  final String title;
  final int completedStages;
  final int totalStages;
  final double percentComplete;
  final int unlockedStageCount;
  final bool isFinished;
  final LearningPathStageModel? nextStageToTrain;

  LearningPathSummary({
    required this.id,
    required this.title,
    required this.completedStages,
    required this.totalStages,
    required this.percentComplete,
    required this.unlockedStageCount,
    required this.isFinished,
    required this.nextStageToTrain,
  });
}

class LearningPathSummaryCache {
  final TrainingPathProgressServiceV2 progress;
  final LearningPathRegistryService registry;
  final LearningPathGatekeeperService gatekeeper;

  LearningPathSummaryCache({
    required this.progress,
    LearningPathRegistryService? registry,
    LearningPathGatekeeperService? gatekeeper,
  }) : registry = registry ?? LearningPathRegistryService.instance,
       gatekeeper =
           gatekeeper ??
           LearningPathGatekeeperService(
             progress: progress,
             mastery: TagMasteryService(logs: progress.logs),
           );

  final List<LearningPathSummary> _summaries = [];
  Future<void>? _refreshing;

  List<LearningPathSummary> get summaries => List.unmodifiable(_summaries);

  LearningPathSummary? summaryById(String id) =>
      _summaries.firstWhereOrNull((e) => e.id == id);

  Future<void> refresh() async {
    if (_refreshing != null) {
      await _refreshing;
      return;
    }
    final future = _compute();
    _refreshing = future;
    await future;
    _refreshing = null;
  }

  Future<void> _compute() async {
    final templates = await registry.loadAll();
    _summaries.clear();
    for (final t in templates) {
      await progress.loadProgress(t.id);
      await gatekeeper.updateStageUnlocks(t.id);

      final unlocked = <String>{
        for (final stageId in progress.unlockedStageIds())
          if (gatekeeper.isStageUnlocked(stageId)) stageId,
      };
      final progressMap = <String, _StageProgress>{};
      for (final s in t.stages) {
        progressMap[s.id] = _StageProgress(
          accuracy: progress.getStageAccuracy(s.id),
          hands: progress.getStageHands(s.id),
        );
      }

      var completed = 0;
      LearningPathStageModel? nextStage;
      for (final s in t.stages) {
        final p = progressMap[s.id];
        final done =
            p != null &&
            p.hands >= s.minHands &&
            p.accuracy >= s.requiredAccuracy;
        if (done) {
          completed++;
        } else if (nextStage == null && unlocked.contains(s.id)) {
          nextStage = s;
        }
      }

      final percent = t.stages.isEmpty ? 0.0 : completed / t.stages.length;
      _summaries.add(
        LearningPathSummary(
          id: t.id,
          title: t.title,
          completedStages: completed,
          totalStages: t.stages.length,
          percentComplete: percent,
          unlockedStageCount: unlocked.length,
          isFinished: completed >= t.stages.length,
          nextStageToTrain: nextStage,
        ),
      );
    }
  }
}

class _StageProgress {
  final double accuracy;
  final int hands;
  const _StageProgress({required this.accuracy, required this.hands});
}

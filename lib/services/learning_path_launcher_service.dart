import 'package:flutter/material.dart';

import 'learning_path_summary_cache_v2.dart';
import 'learning_path_stage_launcher.dart';

/// Launches the next available stage for a learning path.
class LearningPathLauncherService {
  final LearningPathSummaryCache cache;
  final LearningPathStageLauncher stageLauncher;

  LearningPathLauncherService({
    required this.cache,
    LearningPathStageLauncher? stageLauncher,
  }) : stageLauncher = stageLauncher ?? LearningPathStageLauncher();

  /// Loads [pathId] summary and starts training for the next stage if possible.
  Future<void> launchNextStage(String pathId, BuildContext context) async {
    await cache.refresh();
    final summary = cache.summaryById(pathId);
    if (summary == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Learning path not found')));
      return;
    }

    final stage = summary.nextStageToTrain;
    if (stage == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('All stages completed')));
      return;
    }
    await stageLauncher.launch(context, stage);
  }
}

import 'act0_content_copy_registry_parser.dart';
import 'act0_content_copy_source_parser.dart';

class Act0CoverageSnapshot {
  const Act0CoverageSnapshot({
    required this.totalWorlds,
    required this.localizedWorlds,
    required this.totalLessons,
    required this.localizedLessons,
    required this.totalTasks,
    required this.localizedTasks,
    required this.totalRunnerTasks,
    required this.localizedRunnerPromptTasks,
    required this.localizedRunnerSupportTasks,
    required this.localizedRunnerQuestionTasks,
    required this.worlds,
  });

  final int totalWorlds;
  final int localizedWorlds;
  final int totalLessons;
  final int localizedLessons;
  final int totalTasks;
  final int localizedTasks;
  final int totalRunnerTasks;
  final int localizedRunnerPromptTasks;
  final int localizedRunnerSupportTasks;
  final int localizedRunnerQuestionTasks;
  final List<Act0WorldCoverage> worlds;
}

class Act0WorldCoverage {
  const Act0WorldCoverage({
    required this.world,
    required this.hasWorldCopy,
    required this.totalLessons,
    required this.localizedLessons,
    required this.totalTasks,
    required this.localizedTasks,
    required this.totalRunnerTasks,
    required this.localizedRunnerPromptTasks,
    required this.localizedRunnerSupportTasks,
    required this.localizedRunnerQuestionTasks,
  });

  final Act0WorldPack world;
  final bool hasWorldCopy;
  final int totalLessons;
  final int localizedLessons;
  final int totalTasks;
  final int localizedTasks;
  final int totalRunnerTasks;
  final int localizedRunnerPromptTasks;
  final int localizedRunnerSupportTasks;
  final int localizedRunnerQuestionTasks;
}

Act0CoverageSnapshot buildAct0CoverageSnapshot(
  Act0ContentBundle content,
  Act0CopyRegistryBundle registry,
) {
  final worlds = <Act0WorldCoverage>[];
  var totalLessons = 0;
  var localizedLessons = 0;
  var totalTasks = 0;
  var localizedTasks = 0;
  var totalRunnerTasks = 0;
  var localizedRunnerPromptTasks = 0;
  var localizedRunnerSupportTasks = 0;
  var localizedRunnerQuestionTasks = 0;

  for (final world in content.worlds) {
    var worldLocalizedLessons = 0;
    var worldTotalTasks = 0;
    var worldLocalizedTasks = 0;
    var worldTotalRunnerTasks = 0;
    var worldLocalizedRunnerPromptTasks = 0;
    var worldLocalizedRunnerSupportTasks = 0;
    var worldLocalizedRunnerQuestionTasks = 0;

    totalLessons += world.lessons.length;
    for (final lesson in world.lessons) {
      if (registry.lessons.containsKey(lesson.lessonId)) {
        localizedLessons += 1;
        worldLocalizedLessons += 1;
      }

      worldTotalTasks += lesson.tasks.length;
      totalTasks += lesson.tasks.length;

      for (final task in lesson.tasks) {
        final taskCopy = registry.tasks[task.taskId];
        if (taskCopy != null) {
          localizedTasks += 1;
          worldLocalizedTasks += 1;
        }

        if (!task.hasRunnerCopy) {
          continue;
        }
        totalRunnerTasks += 1;
        worldTotalRunnerTasks += 1;
        if (taskCopy?.runnerPrompt?.trim().isNotEmpty ?? false) {
          localizedRunnerPromptTasks += 1;
          worldLocalizedRunnerPromptTasks += 1;
        }
        if (taskCopy?.runnerSupport?.trim().isNotEmpty ?? false) {
          localizedRunnerSupportTasks += 1;
          worldLocalizedRunnerSupportTasks += 1;
        }
        if (taskCopy?.runnerQuestion?.trim().isNotEmpty ?? false) {
          localizedRunnerQuestionTasks += 1;
          worldLocalizedRunnerQuestionTasks += 1;
        }
      }
    }

    worlds.add(
      Act0WorldCoverage(
        world: world,
        hasWorldCopy: registry.worlds.containsKey(world.worldId),
        totalLessons: world.lessons.length,
        localizedLessons: worldLocalizedLessons,
        totalTasks: worldTotalTasks,
        localizedTasks: worldLocalizedTasks,
        totalRunnerTasks: worldTotalRunnerTasks,
        localizedRunnerPromptTasks: worldLocalizedRunnerPromptTasks,
        localizedRunnerSupportTasks: worldLocalizedRunnerSupportTasks,
        localizedRunnerQuestionTasks: worldLocalizedRunnerQuestionTasks,
      ),
    );
  }

  return Act0CoverageSnapshot(
    totalWorlds: content.worlds.length,
    localizedWorlds: content.worlds
        .where((world) => registry.worlds.containsKey(world.worldId))
        .length,
    totalLessons: totalLessons,
    localizedLessons: localizedLessons,
    totalTasks: totalTasks,
    localizedTasks: localizedTasks,
    totalRunnerTasks: totalRunnerTasks,
    localizedRunnerPromptTasks: localizedRunnerPromptTasks,
    localizedRunnerSupportTasks: localizedRunnerSupportTasks,
    localizedRunnerQuestionTasks: localizedRunnerQuestionTasks,
    worlds: worlds,
  );
}

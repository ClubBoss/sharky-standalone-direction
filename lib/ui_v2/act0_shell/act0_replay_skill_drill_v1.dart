import 'act0_task_skill_map_v1.dart';

typedef Act0ReplayTaskV1 = ({String lessonId, String taskId});
typedef Act0ReplayDecisionV1 = ({Act0ReplayTaskV1 task, bool isCorrect});
typedef Act0ReplayAttemptV1 = ({
  Act0ReplayTaskV1 task,
  Iterable<Act0ReplayDecisionV1> decisions,
});

/// Pass decisions in replay order and the completed, unlocked entries of the
/// Daily Practice deck as [completedDrillPool]. Each archived decision can
/// supply its task identity and grade from the recorded evidence.
///
/// Use the first authored topic when the task maps to several. History orders
/// are the evidence journal's nonnegative createdOrder values.
({String? skillId, String? taskId, String reason}) resolveReplaySkillDrillV1(
  Act0ReplayAttemptV1 attempt,
  Iterable<Act0ReplayTaskV1> completedDrillPool,
  Iterable<({String taskId, int createdOrder})> recentHistory,
) {
  var source = attempt.task;
  for (final decision in attempt.decisions) {
    if (!decision.isCorrect) {
      source = decision.task;
      break;
    }
  }
  final skillId = act0SkillsForTaskV1(
    source.lessonId,
    source.taskId,
  ).firstOrNull;
  if (skillId == null) {
    return (skillId: null, taskId: null, reason: 'unknown_skill');
  }

  return resolveSkillDrillV1(
    skillId,
    completedDrillPool,
    recentHistory,
    excludedTaskId: attempt.task.taskId,
  );
}

/// Shared same-skill selection for replay and the profile's explicit skill.
({String? skillId, String? taskId, String reason}) resolveSkillDrillV1(
  String skillId,
  Iterable<Act0ReplayTaskV1> completedDrillPool,
  Iterable<({String taskId, int createdOrder})> recentHistory, {
  String? excludedTaskId,
}) {
  final lastSeen = <String, int>{};
  for (final entry in recentHistory) {
    if (entry.createdOrder > (lastSeen[entry.taskId] ?? -1)) {
      lastSeen[entry.taskId] = entry.createdOrder;
    }
  }
  final candidates =
      [
        for (final drill in completedDrillPool)
          if (drill.taskId != excludedTaskId &&
              act0SkillsForTaskV1(
                drill.lessonId,
                drill.taskId,
              ).contains(skillId))
            drill.taskId,
      ]..sort((a, b) {
        final recency = (lastSeen[a] ?? -1).compareTo(lastSeen[b] ?? -1);
        return recency == 0 ? a.compareTo(b) : recency;
      });
  final taskId = candidates.firstOrNull;
  return (
    skillId: skillId,
    taskId: taskId,
    reason: taskId == null ? 'no_drill_for_skill' : 'same_skill',
  );
}

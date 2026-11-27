import 'act0_lesson_identity_alias_v1.dart';
import 'dart:convert';

import 'act0_authored_source_proof_v1.dart';
import 'act0_curriculum_pilot_v1.dart';
import 'act0_durable_learning_time_contract_v1.dart';
import 'act0_verified_transfer_v1.dart';
import 'act0_learning_evidence_contract_v1.dart';
import 'act0_shell_state_v1.dart';
import 'act0_task_skill_map_v1.dart' as task_skills;

export 'act0_task_skill_map_v1.dart' show act0W14LessonSkillsV1;

const act0SkillMapLastWorldV1 = act0LastCurriculumWorldV1;

List<String> act0SkillsForTaskV1(String lessonId, String taskId) =>
    task_skills.act0SkillsForTaskV1(
      lessonId,
      taskId,
      includeCurriculumPilot: act0CurriculumPilotEnabledV1,
    );

class Act0W14SkillStateV1 {
  const Act0W14SkillStateV1({
    required this.label,
    required this.lessonCount,
    required this.taskCount,
    required this.answeredTasks,
    required this.independentTasks,
    required this.helpedOrUnverifiedTasks,
    required this.tasksToRevisit,
  });

  final String label;
  final int lessonCount;
  final int taskCount;
  final int answeredTasks;
  final int independentTasks;
  final int helpedOrUnverifiedTasks;
  final int tasksToRevisit;

  String get stateLabel => answeredTasks == 0
      ? 'Not started'
      : tasksToRevisit > 0
      ? 'Needs practice'
      : independentTasks > 0
      ? 'Answers without help'
      : 'Practice recorded';

  String get explanation => answeredTasks == 0
      ? 'No lesson answers recorded yet.'
      : 'Tasks answered without help: $independentTasks. '
            'Helped or unverified: $helpedOrUnverifiedTasks. '
            'Recent tasks to revisit: $tasksToRevisit.';
}

/// Rebuilt from the existing durable journal, so no second saved state can
/// drift. Its retained source anchors and recent answers are evidence of
/// practice only, never retention or mastery. Placement and teaching-demo
/// answers cannot start a curriculum skill.
List<Act0W14SkillStateV1> act0W14SkillStatesV1({
  required List<Act0WorldCardV1> worlds,
  required Act0LearningEvidenceHistoryV1 history,
}) {
  final taskSkills = <String, List<String>>{};
  final lessons = <String, Set<String>>{};
  final tasks = <String, Set<String>>{};
  String identity(String world, String lesson, String task) => jsonEncode([
    world,
    act0CanonicalLessonForTaskV1(world, lesson, task),
    task,
  ]);
  for (final world in worlds.where(
    (world) =>
        world.worldNumber >= 1 && world.worldNumber <= act0SkillMapLastWorldV1,
  )) {
    for (final lesson in world.lessons) {
      for (final task in lesson.taskList) {
        final skills = act0SkillsForTaskV1(lesson.lessonId, task.taskId);
        final key = identity(world.worldId, lesson.lessonId, task.taskId);
        taskSkills[key] = skills;
        for (final skill in skills) {
          (lessons[skill] ??= {}).add(lesson.lessonId);
          (tasks[skill] ??= {}).add(key);
        }
      }
    }
  }
  final answered = <String, Set<String>>{};
  final independent = <String, Set<String>>{};
  final helped = <String, Set<String>>{};
  final missed = <String, Set<String>>{};
  final openMisses = <String, Act0LearningEvidenceRecordV1>{};
  // Anchors preserve first facts, not current Review debt. They still
  // prevent a familiar identity from becoming new independent proof when
  // the original miss has rolled out of the recent journal.
  final recentIds = history.records.map((record) => record.recordId).toSet();
  for (final record in history.provenanceRecords) {
    if (record.isPlacementAssessment || record.isDiagnosticLearningEntry) {
      continue;
    }
    final key = identity(record.worldId, record.lessonId, record.taskId);
    final unseenFamily = record.reviewKind == Act0ReviewKindV1.unseenTransfer
        ? act0NewReviewConceptFamilyV1(
            record.worldId,
            record.lessonId,
            record.taskId,
          )
        : null;
    final transferredMisses = [
      for (final entry in openMisses.entries)
        if (entry.key != key &&
            (_isVerifiedTargetV1(entry.value, record) ||
                (unseenFamily != null &&
                    entry.value.worldId == record.worldId &&
                    entry.value.lessonId == record.lessonId &&
                    act0Day7FamilyForSourceV1(
                          worldId: entry.value.worldId,
                          lessonId: entry.value.lessonId,
                          taskId: entry.value.taskId,
                          family: entry.value.conceptFamilyId.isNotEmpty
                              ? entry.value.conceptFamilyId
                              : entry.value.repairFocusId,
                        ) ==
                        unseenFamily)))
          entry.key,
    ];
    final skills = <String>{
      ...?taskSkills[key],
      for (final miss in transferredMisses) ...?taskSkills[miss],
    };
    if (skills.isEmpty) continue;
    final fingerprint = act0CurrentAuthoredSourceFingerprintForIdentityV1(
      worldId: record.worldId,
      lessonId: record.lessonId,
      taskId: record.taskId,
    );
    final currentSource =
        record.authoredSourceFingerprint.isNotEmpty &&
        record.authoredSourceFingerprint == fingerprint;
    final sameIdentityMiss = openMisses.containsKey(key);
    if (currentSource &&
        !record.isCorrect &&
        record.startedBy != 'lesson_extra_example') {
      openMisses[key] = record;
    }
    final independentlyCorrect =
        currentSource && record.isIndependentCorrect && !sameIdentityMiss;
    for (final skill in skills) {
      (answered[skill] ??= {}).add(key);
      if (!currentSource || (record.isCorrect && !independentlyCorrect)) {
        (helped[skill] ??= {}).add(key);
      } else if (!record.isCorrect) {
        if (recentIds.contains(record.recordId) &&
            record.startedBy != 'lesson_extra_example') {
          (missed[skill] ??= {}).add(key);
        }
      } else {
        (independent[skill] ??= {}).add(key);
        // Same-source retries never clear a skill miss. A verified
        // different example can; the Review queue has its own closing rule.
      }
    }
    if (independentlyCorrect) {
      for (final miss in transferredMisses) {
        openMisses.remove(miss);
        for (final skill in taskSkills[miss] ?? const <String>[]) {
          missed[skill]?.remove(miss);
        }
      }
    }
  }
  return [
    for (final label in tasks.keys)
      Act0W14SkillStateV1(
        label: label,
        lessonCount: lessons[label]!.length,
        taskCount: tasks[label]!.length,
        answeredTasks: answered[label]?.length ?? 0,
        independentTasks: independent[label]?.length ?? 0,
        helpedOrUnverifiedTasks: helped[label]?.length ?? 0,
        tasksToRevisit: missed[label]?.length ?? 0,
      ),
  ];
}

bool _isVerifiedTargetV1(
  Act0LearningEvidenceRecordV1 source,
  Act0LearningEvidenceRecordV1 answer,
) {
  final target = act0VerifiedTransferTargetV1(source.taskId);
  return target != null &&
      target.worldId == answer.worldId &&
      target.lessonId == answer.lessonId &&
      target.taskId == answer.taskId;
}

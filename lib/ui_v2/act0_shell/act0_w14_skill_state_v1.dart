import 'dart:convert';

import 'act0_authored_source_proof_v1.dart';
import 'act0_learning_evidence_contract_v1.dart';
import 'act0_shell_state_v1.dart';

// Explicit curriculum ownership, independent of task-name substring guesses.
// These are lesson topics; individual tasks can have a narrower topic.
const act0W14LessonSkillsV1 = <String, List<String>>{
  'what_poker_is': ['Table sense'],
  'what_poker_is_content': ['Table sense'],
  'cards_ranks_suits': ['Hand reading', 'Board reading'],
  'your_first_hand': ['Table sense', 'Board reading'],
  'fold_check_call_raise': ['Betting decisions'],
  'blinds_action_order': ['Blind play', 'Table sense'],
  'positions': ['Position play'],
  'hand_rankings_table': ['Hand reading', 'Board reading'],
  'hand_rankings_upper': ['Hand reading', 'Board reading'],
  'showdown_winning': ['Hand reading'],
  'hand_discipline_buckets': ['Hand reading', 'Betting decisions'],
  'fold_discipline': ['Hand reading', 'Betting decisions'],
  'weak_ace_warning': ['Hand reading'],
  'continue_or_let_go': ['Hand reading', 'Betting decisions'],
  'hand_discipline_apply': ['Hand reading', 'Betting decisions'],
  'discipline_checkpoint': ['Hand reading', 'Betting decisions'],
  'position_six_seats': ['Position play'],
  'button_advantage': ['Position play'],
  'early_vs_late': ['Position play'],
  'same_hand_different_seat': ['Position play'],
  'position_apply': ['Position play'],
  'position_checkpoint': ['Position play'],
  'why_bets_happen': ['Betting decisions'],
  'value_bets': ['Betting decisions'],
  'bluff_pressure': ['Betting decisions'],
  'protection_and_denial': ['Betting decisions', 'Board reading'],
  'call_price': ['Betting decisions'],
  'small_half_pot': ['Betting decisions'],
  'price_checkpoint': ['Betting decisions'],
};

const _w56LessonSkills = <String, List<String>>{
  'board_texture_basics': ['Board reading'],
  'connected_boards': ['Board reading'],
  'flush_draws': ['Board reading'],
  'straight_draws': ['Board reading'],
  'outs_improvement': ['Board reading'],
  'turn_river_changes': ['Board reading'],
  'range_bucket_basics': ['Range reading'],
  'range_board_fit': ['Range reading'],
  'range_pressure_lines': ['Range reading'],
  'range_combo_counts': ['Range reading'],
  'range_thinking_checkpoint': ['Range reading'],
};

const _skillOverridesByTaskId = <String, List<String>>{
  'positions_theory': ['Position play'],
  'positions_button': ['Position play'],
  'positions_utg': ['Position play'],
  'positions_cutoff': ['Position play'],
  'outs_improvement_w5_table_outs_flush_transfer': [
    'Board reading',
    'Betting decisions',
  ],
  'outs_improvement_w5_table_outs_straight_transfer': [
    'Board reading',
    'Betting decisions',
  ],
};

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
  String identity(String world, String lesson, String task) =>
      jsonEncode([world, lesson, task]);
  for (final world in worlds.where(
    (world) => world.worldNumber >= 1 && world.worldNumber <= 6,
  )) {
    for (final lesson in world.lessons) {
      final lessonSkills =
          act0W14LessonSkillsV1[lesson.lessonId] ??
          _w56LessonSkills[lesson.lessonId] ??
          const <String>[];
      for (final task in lesson.taskList) {
        final skills = _skillOverridesByTaskId[task.taskId] ?? lessonSkills;
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
  // Anchors preserve first facts, not the latest outcome. An old first-miss
  // anchor must not reopen a task whose later retry left the rolling journal.
  final recentIds = history.records.map((record) => record.recordId).toSet();
  for (final record in history.provenanceRecords) {
    if (record.isPlacementAssessment || record.isDiagnosticLearningEntry) {
      continue;
    }
    final key = identity(record.worldId, record.lessonId, record.taskId);
    final skills = taskSkills[key] ?? const <String>[];
    if (skills.isEmpty) continue;
    final fingerprint = act0CurrentAuthoredSourceFingerprintForIdentityV1(
      worldId: record.worldId,
      lessonId: record.lessonId,
      taskId: record.taskId,
    );
    final currentSource =
        record.authoredSourceFingerprint.isNotEmpty &&
        record.authoredSourceFingerprint == fingerprint;
    for (final skill in skills) {
      (answered[skill] ??= {}).add(key);
      if (!currentSource ||
          (record.isCorrect && !record.isIndependentCorrect)) {
        (helped[skill] ??= {}).add(key);
      } else if (!record.isCorrect) {
        if (recentIds.contains(record.recordId)) {
          (missed[skill] ??= {}).add(key);
        }
      } else {
        (independent[skill] ??= {}).add(key);
        // Another task, or a hinted retry, cannot clear this task's miss.
        if (recentIds.contains(record.recordId)) missed[skill]?.remove(key);
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

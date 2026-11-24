// Flutter catalog adapter. The audit itself reads this snapshot in pure Dart.
import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

// Authored repeats and rechecks with a distinct task ID. Day 2 reopens the
// source task (act0_shell_preview_answer_v1.dart, _unseenReviewTaskIdV1).
const act0AuthoredRepeatPairsV1 = [
  ['what_poker_is_table_read_transfer', 'what_poker_is_table_read_recheck'],
  ['your_first_hand_preflop', 'your_first_hand_private_cards_recheck'],
  ['w3_play_from_blinds_bvb_bb_call', 'w3_play_from_blinds_bvb_bb_repeat'],
  [
    'connected_boards_w5_raise_read_guided',
    'connected_boards_w5_raise_read_repeat',
  ],
  [
    'flush_draws_w5_flush_draw_find',
    'flush_draws_w5_flush_draw_recheck_transfer',
  ],
  ['w6_check_raise_read', 'w6_check_raise_repeat'],
];

void main() {
  const out = String.fromEnvironment(
    'OUT',
    defaultValue: 'output/b43/answer_positions.json',
  );
  final tasks = [
    for (final world in Act0ShellStateV1.sample.worlds)
      for (final lesson in world.lessons)
        for (final task in lesson.taskList)
          {
            'world': world.worldNumber,
            'lesson': lesson.lessonId,
            'id': task.taskId,
            'repairOnly': task.repairOnly,
            // Theory does not present choices. Seat targets and sizing
            // presets use separate controls.
            'multipleChoice':
                task.phase != Act0LessonPhaseV1.theory &&
                !task.runner.sizingConfig.isEnabled &&
                task.runner.options.every((option) => option.seatId == null),
            'options': [
              for (final option in task.runner.options)
                act0RunnerOptionIsPreferredV1(option),
            ],
          },
  ];
  File(out)
    ..createSync(recursive: true)
    ..writeAsStringSync(
      jsonEncode({'tasks': tasks, 'pairs': act0AuthoredRepeatPairsV1}),
    );
}

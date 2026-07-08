import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  test('W2-W5 recurring transfer debts stay closed in live Act0 route', () {
    final expectedCorrectIds = <String, String>{
      'discipline_checkpoint_checkpoint_table_discipline': 'trash_fold',
      'position_checkpoint_position_checkpoint_table_notice': 'players_behind',
      'w4_checkpoint_table_purpose_price': 'small_value_price',
      'flush_draws_w5_made_hand_vs_flush_draw_transfer':
          'made_hand_with_draw_pressure',
      'turn_river_changes_w5_turn_texture_shift_transfer': 'board_got_wetter',
    };

    for (final entry in expectedCorrectIds.entries) {
      final task = _taskById(entry.key);
      final options = task.runner.options;
      final correctOptions = options.where((option) => option.isCorrect);

      expect(task.taskFamily, Act0TaskFamilyV1.transfer, reason: entry.key);
      expect(options, hasLength(3), reason: entry.key);
      expect(correctOptions, hasLength(1), reason: entry.key);
      expect(correctOptions.single.id, entry.value, reason: entry.key);
    }
  });

  test(
    'W6 owns combo-count and checkpoint closure before W7 visible cards',
    () {
      final world6 = Act0ShellStateV1.sample.worldById('world_6');
      final world7 = Act0ShellStateV1.sample.worldById('world_7');
      final w6LessonIds = world6.lessons.map((lesson) => lesson.lessonId);
      final w7LessonIds = world7.lessons.map((lesson) => lesson.lessonId);

      expect(world6.title, 'Range Thinking');
      expect(
        w6LessonIds,
        containsAll(<String>[
          'range_bucket_basics',
          'range_board_fit',
          'range_pressure_lines',
          'range_combo_counts',
          'range_thinking_checkpoint',
        ]),
      );
      expect(world6.lessons.last.lessonId, 'range_thinking_checkpoint');

      expect(world7.title, 'Visible Cards Change Ranges');
      expect(
        world7.lessons.first.lessonId,
        'range_thinking_lite_combo_density',
      );
      expect(w7LessonIds, isNot(contains('range_combo_counts')));
      expect(w7LessonIds, isNot(contains('range_thinking_checkpoint')));
    },
  );
}

Act0LessonTaskV1 _taskById(String taskId) {
  return Act0ShellStateV1.sample.worlds
      .expand((world) => world.lessons)
      .expand((lesson) => lesson.taskList)
      .firstWhere(
        (task) => task.taskId == taskId,
        orElse: () => throw StateError('No live Act0 task $taskId'),
      );
}

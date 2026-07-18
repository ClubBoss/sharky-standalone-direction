import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w7_visible_ace_hidden_runtime_session_owner_v1.dart';

void main() {
  test('W7-W9 bridge checkpoints break the repeated template leak', () {
    final checkpoints = <String, Act0LessonTaskV1>{
      for (final taskId in const <String>[
        'range_checkpoint_review',
        'w7_stack_checkpoint',
        'w9_checkpoint_review',
      ])
        taskId: _taskById(taskId),
    };

    final correctIndexes = <int>[];
    for (final entry in checkpoints.entries) {
      final options = entry.value.runner.options;
      final correctOptions = options.where((option) => option.isCorrect);

      expect(correctOptions, hasLength(1), reason: entry.key);
      correctIndexes.add(options.indexWhere((option) => option.isCorrect));
    }

    expect(correctIndexes, isNot(<int>[0, 0, 0]));

    expect(
      _labelsFor(checkpoints['range_checkpoint_review']!),
      containsAll(['Range plus pot size', 'Range plus stack depth']),
    );
    expect(
      _labelsFor(checkpoints['range_checkpoint_review']!),
      isNot(contains('Guess the line')),
    );

    expect(
      _labelsFor(checkpoints['w7_stack_checkpoint']!),
      containsAll(['Range plus raw chip count', 'Range plus stack risk']),
    );
    expect(
      _labelsFor(checkpoints['w7_stack_checkpoint']!),
      isNot(contains('Chip count only')),
    );

    expect(
      _labelsFor(checkpoints['w9_checkpoint_review']!),
      containsAll([
        'Map pressure first, then adjust by player',
        'Map pressure, then copy every player read',
      ]),
    );
    expect(
      _labelsFor(checkpoints['w9_checkpoint_review']!),
      isNot(contains('Use only hole cards and ignore pressure')),
    );
  });

  test('first required blocker use defines blocker before assessment', () {
    final task = _taskById('range_checkpoint_combos');
    final copy = <String>[
      task.runner.caption,
      task.runner.hint,
      task.runner.question,
      task.runner.feedbackReason,
      for (final step in task.runner.teachingSteps) step.body,
      for (final option in task.runner.options) option.feedbackReason,
    ].join(' ').toLowerCase();

    expect(copy, contains('before blockers'));
    expect(copy, contains('blocker is a visible or known card'));
    expect(copy, contains('removes possible private-card combinations'));
    expect(
      task.runner.options.singleWhere((option) => option.isCorrect).id,
      'sixteen',
    );
  });

  test(
    'W7 visible-card transfer uses an unseen board and preserves exact-hand safety',
    () {
      final owner = const Act0W7VisibleAceHiddenRuntimeSessionOwnerV1();
      final transfer = owner.taskSpecs.singleWhere(
        (spec) => spec.taskId == 'visible_card_combo_density_transfer_check',
      );

      expect(transfer.boardContext, 'QJ5 rainbow');
      expect(transfer.learnerPrompt, contains('QJ5'));
      expect(
        transfer.choiceLabels[transfer.expectedChoiceId],
        allOf(
          contains('queen-containing combinations'),
          contains('no exact hand'),
        ),
      );
      expect(
        transfer.feedbackReason,
        allOf(
          contains('narrows a range'),
          contains('does not identify one exact hand'),
        ),
      );
      expect(
        transfer.expectedChoiceId,
        'visible_rank_reduces_matching_rank_combos',
      );
    },
  );
}

Act0LessonTaskV1 _taskById(String taskId) {
  return Act0ShellStateV1.sample.worlds
      .expand((world) => world.lessons)
      .expand((lesson) => lesson.taskList)
      .firstWhere((task) => task.taskId == taskId);
}

List<String> _labelsFor(Act0LessonTaskV1 task) =>
    task.runner.options.map((option) => option.label).toList();

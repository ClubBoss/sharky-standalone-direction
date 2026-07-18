import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w7_visible_ace_hidden_runtime_session_owner_v1.dart';

void main() {
  const owner = Act0W7VisibleAceHiddenRuntimeSessionOwnerV1();

  test('W7 v1 satisfies the outcome-based visible-card authority', () {
    final lesson = Act0ShellStateV1.sample.worldById('world_7').lessons.single;
    final tasks = lesson.taskList;
    final specs = owner.taskSpecs;

    expect(lesson.lessonId, 'range_thinking_lite_combo_density');
    expect(tasks.map((task) => task.taskId), <String>[
      'visible_ace_combo_reduction_intro',
      'visible_king_combo_reduction_intro',
      'paired_board_texture_lite_intro',
      'visible_card_combo_density_transfer_check',
      'visible_card_combo_reduction_recap',
    ]);
    expect(
      tasks.where((task) => task.phase == Act0LessonPhaseV1.theory),
      hasLength(1),
    );
    expect(
      tasks.where(
        (task) => task.resolvedTaskFamily == Act0TaskFamilyV1.transfer,
      ),
      hasLength(1),
    );

    final paired = specs.singleWhere(
      (spec) => spec.taskId == 'paired_board_texture_lite_intro',
    );
    final transfer = specs.singleWhere(
      (spec) => spec.taskId == 'visible_card_combo_density_transfer_check',
    );
    expect(specs.map((spec) => spec.boardContext).toSet(), hasLength(4));
    expect(paired.boardContext, '772 rainbow');
    expect(paired.feedbackReason, contains('prove one exact hand'));
    expect(transfer.boardContext, 'QJ5 rainbow');
    expect(transfer.learnerPrompt, isNot(contains('A72')));
    expect(transfer.learnerPrompt, isNot(contains('K84')));
    expect(transfer.learnerPrompt, isNot(contains('772')));
    expect(transfer.feedbackReason, contains('narrows a range'));
    expect(
      transfer.feedbackReason,
      contains('does not identify one exact hand'),
    );
  });

  test(
    'W7 keeps source-owned error, repair, recheck, and retention identities',
    () {
      for (final spec in owner.taskSpecs) {
        expect(spec.errorType, isNotEmpty);
        expect(spec.repairFocusId, isNotEmpty);
        expect(spec.sourceTaskId, spec.taskId);
        expect(spec.conceptFamilyId, 'w7_combo_density_visible_card_removal');
        expect(spec.choiceIds, contains(spec.expectedChoiceId));
        expect(
          spec.incorrectFeedback.keys,
          unorderedEquals(
            spec.choiceIds.where(
              (choiceId) => choiceId != spec.expectedChoiceId,
            ),
          ),
        );
      }
    },
  );

  test(
    'W6 prerequisite and W8 handoff remain explicit and vocabulary-safe',
    () {
      final worlds = Act0ShellStateV1.sample.worlds;
      final w6 = worlds.firstWhere((world) => world.worldId == 'world_6');
      final w6Copy = w6.lessons
          .expand((lesson) => lesson.taskList)
          .map(
            (task) => '${task.runner.question} ${task.runner.feedbackReason}',
          )
          .join(' ')
          .toLowerCase();
      final w8 = worlds.firstWhere((world) => world.worldId == 'world_8');

      final blockerTask = w6.lessons
          .expand((lesson) => lesson.taskList)
          .singleWhere((task) => task.taskId == 'range_checkpoint_combos');
      final blockerCopy = <String>[
        blockerTask.runner.caption,
        blockerTask.runner.hint,
        blockerTask.runner.question,
        blockerTask.runner.feedbackReason,
        for (final step in blockerTask.runner.teachingSteps) step.body,
        for (final option in blockerTask.runner.options) option.feedbackReason,
      ].join(' ').toLowerCase();

      expect(w6Copy, contains('before blockers'));
      expect(blockerCopy, contains('blocker is a visible or known card'));
      expect(w8.title, 'Stack Depth And Risk');
      expect(w8.subtitle.toLowerCase(), contains('different plans'));
    },
  );
}

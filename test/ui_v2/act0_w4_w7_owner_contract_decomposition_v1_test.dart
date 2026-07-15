import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w7_visible_ace_hidden_runtime_session_owner_v1.dart';

void main() {
  group('Act0 W4-W7 owner contract decomposition', () {
    test('binds W4-W7 to distinct normalized lesson owners', () {
      final worlds = Act0ShellStateV1.sample;
      final world4 = worlds.worldById('world_4');
      final world5 = worlds.worldById('world_5');
      final world6 = worlds.worldById('world_6');
      final world7 = worlds.worldById('world_7');

      expect(world4.title, 'Bet Purpose / Price');
      expect(
        world4.subtitle,
        'Understand why bets happen and what price asks you to risk.',
      );
      expect(
        world4.unlockLabel,
        'Finish Position Thinking to open this world.',
      );
      expect(world4.lessons.map((lesson) => lesson.lessonId), <String>[
        'why_bets_happen',
        'value_bets',
        'bluff_pressure',
        'protection_and_denial',
        'call_price',
        'small_half_pot',
        'price_checkpoint',
      ]);

      expect(world5.title, 'Board Awareness');
      expect(
        world5.subtitle,
        'Read board texture, draws, and how streets change the plan.',
      );
      expect(
        world5.unlockLabel,
        'Finish Bet Purpose / Price to open this world.',
      );
      expect(world5.lessons.map((lesson) => lesson.lessonId), <String>[
        'board_texture_basics',
        'connected_boards',
        'flush_draws',
        'straight_draws',
        'outs_improvement',
        'turn_river_changes',
      ]);

      expect(world6.title, 'Range Thinking');
      expect(
        world6.subtitle,
        'Group hands into ranges and see who has the advantage.',
      );
      expect(world6.unlockLabel, 'Finish Board Awareness to open this world.');
      expect(world6.lessons.map((lesson) => lesson.lessonId), <String>[
        'range_bucket_basics',
        'range_board_fit',
        'range_pressure_lines',
        'range_combo_counts',
        'range_thinking_checkpoint',
      ]);

      expect(world7.title, 'Visible Cards Change Ranges');
      expect(
        world7.subtitle,
        'Use visible cards to narrow what hands can still be there.',
      );
      expect(world7.unlockLabel, 'Finish Range Thinking to open this world.');
      expect(world7.lessons.map((lesson) => lesson.lessonId), <String>[
        'range_thinking_lite_combo_density',
      ]);

      expect(
        world6.lessons.map((lesson) => lesson.lessonId).toSet()
          ..retainAll(world7.lessons.map((lesson) => lesson.lessonId).toSet()),
        isEmpty,
      );
      expect(world6.lessons, isNot(world7.lessons));
    });

    test('backs W7 visible-card route lesson with accepted hidden specs', () {
      final owner = Act0W7VisibleAceHiddenRuntimeSessionOwnerV1();
      final world7 = Act0ShellStateV1.sample.worldById('world_7');
      final visibleLesson = world7.lessons.firstWhere(
        (lesson) => lesson.lessonId == 'range_thinking_lite_combo_density',
      );

      expect(visibleLesson.title, 'Visible Cards Change Ranges');
      final specTasks = visibleLesson.taskList.take(owner.taskSpecs.length);
      expect(
        specTasks.map((task) => task.taskId),
        owner.taskSpecs.map((spec) => spec.taskId),
      );
      expect(
        specTasks.map((task) => task.runner.question),
        owner.taskSpecs.map((spec) => spec.learnerPrompt),
      );
      expect(
        specTasks.map((task) => task.runner.feedbackReason),
        owner.taskSpecs.map((spec) => spec.feedbackReason),
      );
      expect(
        visibleLesson.taskList.last.taskId,
        'visible_card_combo_reduction_recap',
      );
      expect(specTasks.last.resolvedTaskFamily, Act0TaskFamilyV1.transfer);
    });

    test('keeps preflop bridge reachable before W4', () {
      final world3 = Act0ShellStateV1.sample.worldById('world_3');
      final world3Text = world3.lessons
          .expand((lesson) => lesson.taskList)
          .map(
            (task) =>
                '${task.title} ${task.runner.caption} ${task.runner.hint} '
                '${task.runner.question} ${task.runner.feedbackReason}',
          )
          .join(' ')
          .toLowerCase();

      expect(world3Text, contains('preflop'));
      expect(world3Text, contains('first'));
      expect(world3Text, contains('facing'));
      expect(world3Text, contains('frame'));
    });

    test('preserves W7-W12 lock state and W13 closure', () {
      final worlds = Act0ShellStateV1.sample;
      for (final worldId in const <String>[
        'world_7',
        'world_8',
        'world_9',
        'world_10',
        'world_11',
        'world_12',
      ]) {
        final world = worlds.worldById(worldId);
        expect(world.status, Act0WorldStateV1.locked, reason: worldId);
        expect(world.isLocked, isTrue, reason: worldId);
        expect(world.isSelectable, isFalse, reason: worldId);
      }

      expect(
        worlds.worlds.map((world) => world.worldId),
        isNot(contains('world_13')),
      );
    });
  });
}

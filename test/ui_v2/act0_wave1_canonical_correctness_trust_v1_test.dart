import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  group('Act0 Wave 1 canonical correctness and trust', () {
    Act0LessonTaskV1 taskFor({
      required String worldId,
      required String lessonId,
      required String taskId,
    }) {
      final world = Act0ShellStateV1.sample.worldById(worldId);
      final lesson = world.lessons.firstWhere(
        (lesson) => lesson.lessonId == lessonId,
      );

      return lesson.taskList.firstWhere((task) => task.taskId == taskId);
    }

    Act0RunnerOptionV1 correctOption(Act0LessonTaskV1 task) {
      return task.runner.options.firstWhere((option) => option.isCorrect);
    }

    test('repaired correct options use semantic feedback titles', () {
      final cases = <({Act0LessonTaskV1 task, String title})>[
        (
          task: taskFor(
            worldId: 'world_1',
            lessonId: 'positions',
            taskId: 'positions_button',
          ),
          title: 'BTN seat found.',
        ),
        (
          task: taskFor(
            worldId: 'world_1',
            lessonId: 'positions',
            taskId: 'positions_utg',
          ),
          title: 'UTG seat found.',
        ),
        (
          task: taskFor(
            worldId: 'world_1',
            lessonId: 'positions',
            taskId: 'positions_late_seat',
          ),
          title: 'Late seat found.',
        ),
        (
          task: taskFor(
            worldId: 'world_1',
            lessonId: 'hand_rankings_table',
            taskId: 'hand_rankings_pair_drill',
          ),
          title: 'Pair found.',
        ),
        (
          task: taskFor(
            worldId: 'world_4',
            lessonId: 'price_checkpoint',
            taskId: 'w4_checkpoint_review',
          ),
          title: 'Purpose and price connected.',
        ),
        (
          task: taskFor(
            worldId: 'world_5',
            lessonId: 'straight_draws',
            taskId: 'straight_draws_w5_gap_board',
          ),
          title: 'Gap board identified.',
        ),
      ];

      final repairedTitles = <String>[];
      for (final testCase in cases) {
        final correct = correctOption(testCase.task);
        repairedTitles.add(correct.feedbackTitle);
        expect(
          correct.feedbackTitle,
          testCase.title,
          reason: testCase.task.taskId,
        );
      }

      expect(
        repairedTitles,
        isNot(
          containsAll(<String>[
            'Win can hide a leak.',
            'Reset before next hand.',
            'Log it, then reset.',
            'Process ignores table talk.',
            'Discipline: fold early trash.',
            'Discipline: open strong late.',
          ]),
        ),
      );
    });

    test(
      'W2 apply_hj_decision uses HJ medium-hand source without old UTG trash',
      () {
        final task = taskFor(
          worldId: 'world_2',
          lessonId: 'hand_discipline_apply',
          taskId: 'apply_hj_decision',
        );
        final runner = task.runner;
        final heroCards = runner.table.heroCards
            .map((card) => card.label)
            .toList(growable: false);

        expect(task.taskId, 'apply_hj_decision');
        expect(runner.lessonId, 'w1_apply_hj_medium');
        expect(runner.caption, contains('HJ'));
        expect(runner.caption, isNot(contains('UTG')));
        expect(runner.caption, isNot(contains('8♠ 4♦')));
        expect(runner.table.activeSeatId, 'hj');
        expect(runner.table.heroSeatId, 'hj');
        expect(runner.table.heroSeat.seatId, 'hj');
        expect(heroCards, <String>['Kd', 'Qc']);

        final correct = correctOption(task);
        expect(correct.id, 'raise');
        expect(correct.feedbackTitle, 'HJ open is clean.');
      },
    );

    test('W4-W6 canonical runners do not display adjacent stale subtitles', () {
      final staleAdjacentSubtitles = <String, Set<String>>{
        'world_4': <String>{'Board Awareness', 'Range Thinking'},
        'world_5': <String>{'Range Thinking', 'Visible Cards Change Ranges'},
        'world_6': <String>{'Visible Cards Change Ranges'},
      };

      for (final entry in staleAdjacentSubtitles.entries) {
        final world = Act0ShellStateV1.sample.worldById(entry.key);
        for (final lesson in world.lessons) {
          for (final task in lesson.taskList) {
            expect(
              entry.value,
              isNot(contains(task.runner.lessonSubtitle)),
              reason: '${entry.key}/${lesson.lessonId}/${task.taskId}',
            );
          }
        }
      }
    });
  });
}

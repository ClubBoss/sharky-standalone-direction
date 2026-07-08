import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  group('Act0 Wave 2 canonical assessment validity', () {
    Act0LessonCardV1 lessonFor({
      required String worldId,
      required String lessonId,
    }) {
      return Act0ShellStateV1.sample
          .worldById(worldId)
          .lessons
          .firstWhere((lesson) => lesson.lessonId == lessonId);
    }

    Act0LessonTaskV1 taskFor({
      required String worldId,
      required String lessonId,
      required String taskId,
    }) {
      return lessonFor(
        worldId: worldId,
        lessonId: lessonId,
      ).taskList.firstWhere((task) => task.taskId == taskId);
    }

    Act0RunnerOptionV1 correctOption(Act0LessonTaskV1 task) {
      return task.runner.options.firstWhere((option) => option.isCorrect);
    }

    String assessedPromptText(Act0LessonTaskV1 task) {
      return '${task.runner.caption}\n${task.runner.hint}'.toLowerCase();
    }

    test('confirmed leakage is removed from assessed runner prompts', () {
      final leakCases = <({Act0LessonTaskV1 task, List<String> banned})>[
        (
          task: taskFor(
            worldId: 'world_1',
            lessonId: 'hand_rankings_table',
            taskId: 'hand_rankings_flush_drill',
          ),
          banned: <String>['flush beats straight'],
        ),
        (
          task: taskFor(
            worldId: 'world_2',
            lessonId: 'hand_discipline_buckets',
            taskId: 'hand_discipline_buckets_premium',
          ),
          banned: <String>['premium preflop hand', 'premium hands'],
        ),
        (
          task: taskFor(
            worldId: 'world_2',
            lessonId: 'hand_discipline_buckets',
            taskId: 'hand_discipline_buckets_strong',
          ),
          banned: <String>['strong preflop hand', 'strong hands'],
        ),
        (
          task: taskFor(
            worldId: 'world_2',
            lessonId: 'hand_discipline_buckets',
            taskId: 'hand_discipline_buckets_medium',
          ),
          banned: <String>['medium preflop hand', 'medium hands'],
        ),
        (
          task: taskFor(
            worldId: 'world_2',
            lessonId: 'hand_discipline_buckets',
            taskId: 'hand_discipline_buckets_trash',
          ),
          banned: <String>['trash bucket'],
        ),
        (
          task: taskFor(
            worldId: 'world_4',
            lessonId: 'why_bets_happen',
            taskId: 'w4_value_purpose',
          ),
          banned: <String>['worse hands can call', 'wants calls'],
        ),
        (
          task: taskFor(
            worldId: 'world_4',
            lessonId: 'why_bets_happen',
            taskId: 'w4_bluff_purpose',
          ),
          banned: <String>['wins by folds', 'fold pressure'],
        ),
        (
          task: taskFor(
            worldId: 'world_4',
            lessonId: 'protection_and_denial',
            taskId: 'w4_protection_check',
          ),
          banned: <String>['free next card'],
        ),
        (
          task: taskFor(
            worldId: 'world_5',
            lessonId: 'board_texture_basics',
            taskId: 'board_texture_basics_w5_wet_board',
          ),
          banned: <String>['make this wet', 'this is wet'],
        ),
      ];

      for (final leakCase in leakCases) {
        final prompt = assessedPromptText(leakCase.task);
        for (final banned in leakCase.banned) {
          expect(prompt, isNot(contains(banned)), reason: leakCase.task.taskId);
        }
      }
    });

    test('theory tasks may still explain concepts explicitly', () {
      final intro = taskFor(
        worldId: 'world_2',
        lessonId: 'hand_discipline_buckets',
        taskId: 'hand_discipline_buckets_intro',
      );
      final teachingText = intro.runner.teachingSteps
          .expand(
            (step) => <String>[step.title, step.body, ...step.focusLabels],
          )
          .join('\n');

      expect(teachingText, contains('Premium'));
      expect(teachingText, contains('Strong'));
      expect(teachingText, contains('Medium'));
      expect(teachingText, contains('Trash'));
    });

    test(
      'W3 position_six_seats covers all six positions from table evidence',
      () {
        final world3 = Act0ShellStateV1.sample.worldById('world_3');
        expect(world3.lessons.first.lessonId, 'position_six_seats');

        final lesson = lessonFor(
          worldId: 'world_3',
          lessonId: 'position_six_seats',
        );
        final correctSeatIds = <String>{
          for (final task in lesson.taskList)
            for (final option in task.runner.options)
              if (option.isCorrect && option.seatId != null) option.seatId!,
        };

        expect(correctSeatIds, containsAll(<String>['utg', 'hj', 'co', 'btn']));
        expect(correctSeatIds, containsAll(<String>['sb', 'bb']));

        final runnerIds = lesson.taskList
            .map((task) => task.runner.lessonId)
            .toSet();
        expect(
          runnerIds,
          isNot(
            containsAll(<String>['button_seat', 'utg_seat', 'late_position']),
          ),
        );
      },
    );

    test('W3 independently assesses HJ versus CO recognition', () {
      final lesson = lessonFor(
        worldId: 'world_3',
        lessonId: 'position_six_seats',
      );

      final contrastTask = lesson.taskList.firstWhere(
        (task) =>
            task.runner.table.selectableSeatIds.contains('hj') &&
            task.runner.table.selectableSeatIds.contains('co') &&
            correctOption(task).seatId == 'hj',
      );

      expect(contrastTask.taskId, 'position_six_seats_hj_co_contrast');
      expect(contrastTask.runner.table.selectableSeatIds, <String>['hj', 'co']);
      expect(contrastTask.runner.table.highlightedSeatIds, contains('hj'));
      expect(contrastTask.runner.table.highlightedSeatIds, contains('co'));
    });

    test('W2 strong and borderline bucket tasks use distinct examples', () {
      final world2 = Act0ShellStateV1.sample.worldById('world_2');
      final world2LessonIds = world2.lessons
          .map((lesson) => lesson.lessonId)
          .toList(growable: false);
      expect(
        world2LessonIds.indexOf('hand_discipline_buckets'),
        lessThan(world2LessonIds.indexOf('hand_discipline_apply')),
      );

      final strong = taskFor(
        worldId: 'world_2',
        lessonId: 'hand_discipline_buckets',
        taskId: 'hand_discipline_buckets_strong',
      );
      final borderline = taskFor(
        worldId: 'world_2',
        lessonId: 'hand_discipline_buckets',
        taskId: 'hand_discipline_buckets_borderline',
      );

      expect(strong.taskId, 'hand_discipline_buckets_strong');
      expect(borderline.taskId, 'hand_discipline_buckets_borderline');
      expect(strong.runner.lessonId, isNot(borderline.runner.lessonId));
      expect(strong.runner.caption, isNot(borderline.runner.caption));
      expect(strong.runner.table.heroCards.map((card) => card.label), <String>[
        'Jh',
        'Js',
      ]);
      expect(
        borderline.runner.table.heroCards.map((card) => card.label),
        <String>['Qh', 'Js'],
      );

      expect(correctOption(strong).id, 'strong');
      expect(correctOption(borderline).id, 'medium');
      expect(
        correctOption(borderline).feedbackReason.toLowerCase(),
        contains('context'),
      );
    });
  });
}

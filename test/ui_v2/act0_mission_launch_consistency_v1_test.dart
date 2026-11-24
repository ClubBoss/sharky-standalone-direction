import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learn_path_view_model_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  final world = Act0ShellStateV1.learnerCatalog(
    nineSeatPreview: true,
  ).worldById('world_4');
  final nineSeatLesson = world.lessons.firstWhere(
    (lesson) => lesson.lessonId == 'w04_9m_full_ring_transfer',
  );
  final nineSeatTask = nineSeatLesson.courseTaskList.first;
  final sixSeatTask = world.lessons
      .expand((lesson) => lesson.courseTaskList)
      .firstWhere((task) => !act0RunnerRequiresNineSeatPreviewV1(task.runner));
  // A mixed lesson exposes a filtering mismatch even with no saved progress.
  final lesson = nineSeatLesson.copyWith(
    state: Act0LessonStateV1.current,
    tasks: [nineSeatTask, sixSeatTask],
  );

  for (final nineSeatEnabled in [false, true]) {
    test(
      'mission matches shell launch with tableNineSeatV1=$nineSeatEnabled',
      () {
        // The shell passes its effective debug flag to this same gate.
        bool runnerAllowed(Act0RunnerStateV1 runner) =>
            act0RunnerAllowedByNineSeatGateV1(
              runner,
              nineSeatPreview: nineSeatEnabled,
            );

        expect(
          act0RunnerSupportsNineSeatPreviewV1(nineSeatTask.runner),
          isTrue,
        );
        expect(
          act0RunnerRequiresNineSeatPreviewV1(sixSeatTask.runner),
          isFalse,
        );
        final mission = Act0LearnPathViewModelV1(
          worlds: [
            world.copyWith(lessons: [lesson]),
          ],
          lessons: [lesson],
          selectedWorldId: world.worldId,
          selectedLessonId: lesson.lessonId,
          detailLessonId: null,
          worldDetailId: null,
          requiredPractice: null,
          pathClosedTaskIds: const {},
          runnerAllowed: runnerAllowed,
          completedTaskIds: const {},
          showFullPath: false,
          catalogFlag: false,
        );
        final launch = act0FirstIncompleteLessonTaskV1(
          lesson,
          const {},
          runnerAllowed: runnerAllowed,
        );
        expect(launch, same(nineSeatEnabled ? nineSeatTask : sixSeatTask));
        expect(mission.currentMissionTask.taskId, launch.taskId);
      },
    );
  }

  test('default selection never exposes nine-seat when six-seat exists', () {
    expect(
      act0FirstIncompleteLessonTaskV1(lesson, const {}),
      same(sixSeatTask),
      reason: 'An incomplete nine-seat task must not win by default.',
    );
    expect(
      act0FirstIncompleteLessonTaskV1(lesson, {sixSeatTask.taskId}),
      same(sixSeatTask),
      reason: 'The eligible replay fallback must also exclude nine-seat.',
    );
  });
}

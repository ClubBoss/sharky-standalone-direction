import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learn_path_view_model_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w1_rules_check_v1.dart';

void main() {
  group('Placement', () {
    final correct = [
      for (final question in act0W1RulesQuestionsV1) question.correctChoice,
    ];

    test('first run and in-progress question use the authored check', () {
      final first = Act0W1RulesViewModelV1();
      expect(first.state, Act0W1RulesScreenStateV1.firstRun);
      expect(first.question, isNull);
      final answers = [correct.first];
      final current = Act0W1RulesViewModelV1(answers: answers);
      answers.clear();
      expect(current.state, Act0W1RulesScreenStateV1.inProgress);
      expect(current.index, 1);
      expect(current.total, correct.length);
      expect(current.question, same(act0W1RulesQuestionsV1[1]));
    });

    test('passed lands in W2 with the source score', () {
      final view = Act0W1RulesViewModelV1(result: Act0W1RulesResultV1(correct));
      expect(view.state, Act0W1RulesScreenStateV1.passed);
      expect(view.landingWorldId, 'world_2');
      expect(view.result!.score, view.total);
    });

    test('not passed lands in W1 with the exact missed questions', () {
      final choices = [...correct];
      for (var i = 0; i < 2; i++) {
        choices[i] =
            (choices[i] + 1) % act0W1RulesQuestionsV1[i].choices.length;
      }
      final view = Act0W1RulesViewModelV1(result: Act0W1RulesResultV1(choices));
      expect(view.state, Act0W1RulesScreenStateV1.notPassed);
      expect(view.landingWorldId, 'world_1');
      expect(view.missed, act0W1RulesQuestionsV1.take(2));
    });

    test('saved skip bypasses Welcome without a score', () {
      final view = Act0W1RulesViewModelV1(introductionSkipped: true);
      expect(view.state, Act0W1RulesScreenStateV1.skipped);
      expect(view.showWelcomeAfterPlacement, isFalse);
      expect(view.result, isNull);
    });
  });

  group('Map', () {
    final worlds = Act0ShellStateV1.sample.worlds;
    final world = worlds.first;
    final lesson = world.lessons.first.copyWith(
      state: Act0LessonStateV1.current,
    );
    final lessons = [lesson, ...world.lessons.skip(1)];

    Act0LearnPathViewModelV1 view({
      List<Act0WorldCardV1>? catalog,
      Set<String> earned = const {},
      Set<String> closed = const {},
      String? detail,
      bool pilot = false,
    }) => Act0LearnPathViewModelV1(
      worlds: catalog ?? worlds,
      lessons: lessons,
      selectedWorldId: world.worldId,
      selectedLessonId: lesson.lessonId,
      detailLessonId: detail,
      worldDetailId: null,
      requiredPractice: null,
      pathClosedTaskIds: {...earned, ...closed},
      completedTaskIds: earned,
      showFullPath: false,
      catalogFlag: pilot,
    );

    test(
      'first run lands on the first mission and displays zero earned progress',
      () {
        final first = view();
        expect(first.firstRun, isTrue);
        expect(first.currentMissionTask, same(lesson.courseTaskList.first));
        expect(first.progressFraction, 0);
      },
    );

    test(
      'in progress keeps routing closure separate from earned completion',
      () {
        final current = view(
          detail: lesson.lessonId,
          closed: {lesson.courseTaskList.first.taskId},
        );
        expect(current.inProgress, isTrue);
        expect(current.detailLesson, same(lesson));
        expect(current.currentMissionStepIndex, 2);
        expect(current.progressFraction, 0);
      },
    );

    test('world done and all done use the supplied world statuses', () {
      final done = world.copyWith(status: Act0WorldStateV1.completed);
      expect(view(catalog: [done, ...worlds.skip(1)]).worldDone, isTrue);
      expect(view(catalog: [done, ...worlds.skip(1)]).allDone, isFalse);
      expect(view(catalog: [done]).allDone, isTrue);
    });

    test('flag-on catalog preserves supplied worlds and lesson statuses', () {
      final pilotWorld = Act0WorldCardV1(
        worldId: 'world_13',
        worldNumber: 13,
        title: '',
        subtitle: '',
        status: Act0WorldStateV1.locked,
        progressLabel: '',
        primaryCtaLabel: '',
        unlockLabel: '',
        isSelectable: false,
        isLocked: true,
        rewardXp: 0,
        lessons: world.lessons,
      );
      final extended = view(catalog: [...worlds, pilotWorld], pilot: true);
      expect(extended.catalogFlag, isTrue);
      expect(extended.worlds.last, same(pilotWorld));
      expect(extended.worlds.last.status, Act0WorldStateV1.locked);
      expect(view().catalogFlag, isFalse);
    });
  });
}

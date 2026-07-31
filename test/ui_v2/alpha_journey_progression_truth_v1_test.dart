import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

const _progressKey = 'act0_shell_progress_v1';
const _fixturePath =
    'tools/contracts/alpha_action_capability_prerequisite_progression_v1.json';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  Widget host({
    bool showPlacementOnStart = false,
    Act0ShellTabV1 initialTab = Act0ShellTabV1.home,
  }) {
    return MaterialApp(
      home: Act0ShellPreviewScreenV1(
        key: UniqueKey(),
        showPlacementOnStart: showPlacementOnStart,
        initialTab: initialTab,
      ),
    );
  }

  Future<void> pumpHost(WidgetTester tester, Widget child) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(child);
    await tester.pumpAndSettle();
  }

  Future<void> completeFreshBeginnerOnboarding(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('act0_shell_placement_intro_cta')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_placement_option_new')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_placement_next_cta')));
    await tester.pumpAndSettle();

    final welcomeCta = find.byKey(const Key('act0_shell_welcome_primary_cta'));
    expect(welcomeCta, findsOneWidget);
    await tester.tap(welcomeCta);
    await tester.pumpAndSettle();

    final runner = tester.widget<Act0LessonRunnerShellV1>(
      find.byType(Act0LessonRunnerShellV1),
    );
    final correct = runner.runner.options.firstWhere(
      (option) => option.isCorrect,
    );
    await tester.tap(find.byKey(Key('act0_shell_option_${correct.id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();
    await tester.tap(welcomeCta);
    await tester.pumpAndSettle();
  }

  Map<String, Object> validActionPrecondition() {
    final fixture =
        jsonDecode(File(_fixturePath).readAsStringSync())
            as Map<String, dynamic>;
    expect(fixture['schema'], 'act0_progression_fixture_v1');
    final lessonIds = (fixture['completed_lesson_ids'] as List<dynamic>)
        .map((value) => value.toString())
        .toList(growable: false);
    final state = Act0ShellStateV1.sample;
    final world = state.worldById(fixture['world_id'] as String);
    final completedTaskIds = <String>[
      for (final lessonId in lessonIds)
        ...world.lessons
            .firstWhere((lesson) => lesson.lessonId == lessonId)
            .taskList
            .map((task) => task.taskId),
    ];
    final target = fixture['target'] as Map<String, dynamic>;
    return <String, Object>{
      'schemaVersion': 16,
      'completedTaskIds': completedTaskIds,
      'skippedTaskIds': <String>[],
      'completedLessonIds': lessonIds,
      'selectedWorldId': world.worldId,
      'selectedLessonId': target['lesson_id'] as String,
      'selectedTaskId': target['task_id'] as String,
      'earnedXp': 0,
    };
  }

  Future<void> seedValidActionPrecondition() async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'intake_completed_v1': true,
      'act0_welcome_completed_v1': true,
      _progressKey: jsonEncode(validActionPrecondition()),
    });
  }

  Future<void> openLearn(WidgetTester tester) async {
    await tester.tap(find.text('Learn').last);
    await tester.pumpAndSettle();
  }

  testWidgets(
    'fresh install canonical onboarding reaches First Table Guide while Action stays locked',
    (tester) async {
      await pumpHost(tester, host(showPlacementOnStart: true));
      await completeFreshBeginnerOnboarding(tester);
      expect(find.byKey(const Key('act0_shell_home_screen')), findsOneWidget);

      await openLearn(tester);
      expect(find.textContaining('0 of 9 lessons'), findsOneWidget);
      expect(
        find.byKey(const Key('act0_shell_lesson_First Table Guide')),
        findsOneWidget,
      );
      final guideState = tester.widget<Text>(
        find.byKey(
          const Key('act0_shell_learn_lesson_state_text_what_poker_is'),
        ),
      );
      expect(guideState.data, 'Now');

      await tester.tap(find.text('All lessons'));
      await tester.pumpAndSettle();
      final actionState = tester.widget<Text>(
        find.byKey(
          const Key('act0_shell_learn_lesson_state_text_fold_check_call_raise'),
        ),
      );
      expect(actionState.data, 'Locked');
    },
  );

  testWidgets(
    'Home Continue opens the placement quick table check exactly once after fresh onboarding',
    (tester) async {
      await pumpHost(tester, host(showPlacementOnStart: true));
      await completeFreshBeginnerOnboarding(tester);
      expect(find.byKey(const Key('act0_shell_home_screen')), findsOneWidget);
      expect(find.text('First Table Guide'), findsWidgets);

      final continueCta = find.byKey(const Key('act0_shell_main_cta'));
      expect(continueCta, findsOneWidget);
      await tester.tap(continueCta);
      await tester.tap(continueCta);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('act0_shell_home_screen')), findsNothing);
      expect(find.byKey(const Key('act0_shell_runner_screen')), findsOneWidget);
      final runner = tester.widget<Act0LessonRunnerShellV1>(
        find.byType(Act0LessonRunnerShellV1),
      );
      expect(runner.runner.lessonTitle, 'Quick table check');
      expect(runner.runner.beatIndex, 1);
      expect(runner.runner.phase, Act0LessonPhaseV1.drill);
      expect(runner.runner.question, 'What does this table show?');
      final semanticsHandle = tester.ensureSemantics();
      final question = find.byKey(const Key('act0_shell_action_question'));
      final options = <Finder>[
        for (final option in runner.runner.options)
          find.byKey(Key('act0_shell_option_${option.id}')),
      ];
      final scrollable = find.byKey(const Key('act0_shell_lower_stage_scroll'));
      expect(scrollable, findsNothing);
      expect(question, findsOneWidget);
      expect(options, hasLength(runner.runner.options.length));
      expect(
        tester.getRect(question).bottom,
        lessThan(tester.getRect(options.first).top),
      );
      for (final option in options) {
        expect(tester.getRect(option).height, greaterThanOrEqualTo(48));
        expect(tester.getSemantics(option).label, isNotEmpty);
      }
      expect(tester.getRect(options.last).bottom, lessThanOrEqualTo(932));
      expect(tester.takeException(), isNull);
      semanticsHandle.dispose();
    },
  );

  testWidgets(
    'completed First Table Guide advances ordered progression without unlocking Action early',
    (tester) async {
      final state = Act0ShellStateV1.sample;
      final firstLesson = state.worldById('world_1').lessons.first;
      final completedTasks = firstLesson.taskList
          .map((task) => task.taskId)
          .toList(growable: false);
      SharedPreferences.setMockInitialValues(<String, Object>{
        'intake_completed_v1': true,
        'act0_welcome_completed_v1': true,
        _progressKey: jsonEncode(<String, Object>{
          'schemaVersion': 16,
          'completedTaskIds': completedTasks,
          'skippedTaskIds': <String>[],
          'completedLessonIds': <String>[firstLesson.lessonId],
          'selectedWorldId': 'world_1',
          'selectedLessonId': 'what_poker_is_content',
          'selectedTaskId': 'what_poker_is_pot_stack',
          'earnedXp': 0,
        }),
      });

      await pumpHost(tester, host(initialTab: Act0ShellTabV1.learn));
      expect(find.textContaining('1 of 9 lessons'), findsOneWidget);
      expect(find.text('What poker is'), findsWidgets);
      await tester.tap(find.text('All lessons'));
      await tester.pumpAndSettle();
      final actionState = tester.widget<Text>(
        find.byKey(
          const Key('act0_shell_learn_lesson_state_text_fold_check_call_raise'),
        ),
      );
      expect(actionState.data, 'Locked');
    },
  );

  testWidgets(
    'unmet Action precondition is normalized back to First Table Guide',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'intake_completed_v1': true,
        'act0_welcome_completed_v1': true,
        _progressKey: jsonEncode(<String, Object>{
          'schemaVersion': 16,
          'completedTaskIds': <String>[],
          'skippedTaskIds': <String>[],
          'completedLessonIds': <String>[],
          'selectedWorldId': 'world_1',
          'selectedLessonId': 'fold_check_call_raise',
          'selectedTaskId': 'actions_theory',
          'earnedXp': 0,
        }),
      });

      await pumpHost(tester, host(initialTab: Act0ShellTabV1.learn));
      expect(find.text('First Table Guide'), findsWidgets);
      expect(find.textContaining('0 of 9 lessons'), findsOneWidget);
    },
  );

  testWidgets(
    'valid Action progression fixture is deterministic and unlocks Action',
    (tester) async {
      await seedValidActionPrecondition();
      await pumpHost(tester, host(initialTab: Act0ShellTabV1.learn));
      expect(find.textContaining('4 of 9 lessons'), findsOneWidget);
      final actionState = tester.widget<Text>(
        find.byKey(
          const Key('act0_shell_learn_lesson_state_text_fold_check_call_raise'),
        ),
      );
      expect(actionState.data, 'Now');

      final firstSnapshot = validActionPrecondition();
      final secondSnapshot = validActionPrecondition();
      expect(firstSnapshot, secondSnapshot);
      expect(
        (firstSnapshot['completedTaskIds'] as List<String>).isNotEmpty,
        isTrue,
      );
    },
  );

  testWidgets(
    'Profile B uses Learn and the visible theory Continue to persist the Action decision target',
    (tester) async {
      await seedValidActionPrecondition();
      await pumpHost(tester, host(initialTab: Act0ShellTabV1.learn));

      final lesson = find.byKey(
        const Key('act0_shell_lesson_Fold, check, call, raise'),
      );
      await tester.ensureVisible(lesson);
      await tester.tap(lesson);
      await tester.pumpAndSettle();
      final theoryStep = find.byKey(
        const Key('act0_shell_lesson_step_actions_theory'),
      );
      await tester.scrollUntilVisible(
        theoryStep,
        120,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(theoryStep);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('act0_shell_selected_lesson_cta')));
      await tester.pumpAndSettle();

      for (var tap = 0; tap < 12; tap++) {
        final runner = tester.widget<Act0LessonRunnerShellV1>(
          find.byType(Act0LessonRunnerShellV1),
        );
        final correct = runner.runner.options.firstWhere(
          (option) => option.isCorrect,
        );
        final answer = find.byKey(Key('act0_shell_option_${correct.id}'));
        if (runner.selectedTaskId == 'actions_theory' &&
            answer.evaluate().isNotEmpty) {
          await tester.ensureVisible(answer);
          await tester.pumpAndSettle();
          await tester.tap(answer);
          await tester.pumpAndSettle();
          await tester.tap(
            find.byKey(const Key('act0_shell_feedback_continue_cta')),
          );
          await tester.pumpAndSettle();
          break;
        }
        if (runner.selectedTaskId == 'actions_check_drill' &&
            answer.evaluate().isNotEmpty) {
          break;
        }
        await tester.tap(find.byKey(const Key('act0_shell_continue_cta')));
        await tester.pumpAndSettle();
      }

      final decisionRunner = tester.widget<Act0LessonRunnerShellV1>(
        find.byType(Act0LessonRunnerShellV1),
      );
      expect(decisionRunner.selectedTaskId, 'actions_check_drill');
      final preferences = await SharedPreferences.getInstance();
      final persisted =
          jsonDecode(preferences.getString(_progressKey)!)
              as Map<String, dynamic>;
      expect(persisted['selectedTaskId'], 'actions_check_drill');
      expect(persisted['completedTaskIds'], contains('actions_theory'));
    },
  );
}

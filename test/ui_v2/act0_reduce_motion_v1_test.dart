import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Sharky stays visible without scale or tilt in Reduce Motion', (
    tester,
  ) async {
    Future<void> show(bool reduceMotion) => tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: reduceMotion),
          child: const Center(
            child: Act0SharkyMascotV1(
              mood: Act0SharkyMoodV1.celebrate,
              tone: Colors.teal,
              size: 56,
            ),
          ),
        ),
      ),
    );

    final motion = find.byKey(
      const Key('act0_shell_sharky_mascot_motion_celebrate'),
    );
    final art = find.byKey(const Key('act0_shell_sharky_mascot'));
    await show(false);
    expect(
      tester.widget<TweenAnimationBuilder<double>>(motion).duration,
      const Duration(milliseconds: 420),
    );
    await tester.pump(const Duration(milliseconds: 180));
    await show(true);
    expect(
      tester.widget<TweenAnimationBuilder<double>>(motion).duration,
      Duration.zero,
    );
    expect(tester.getSize(art), const Size(56, 56));
    expect(
      find.ancestor(of: art, matching: find.byType(Transform)),
      findsNothing,
    );
  });
  testWidgets('compact action history appears immediately with Reduce Motion', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final lesson = Act0ShellStateV1.sample
        .worldById('world_1')
        .lessons
        .singleWhere((lesson) => lesson.lessonId == 'fold_check_call_raise');
    final task = lesson.taskList.singleWhere(
      (task) => task.taskId == 'actions_call_drill',
    );
    expect(task.runner.table.actionTrail, isNotEmpty);
    final selected = task.runner.options.singleWhere(
      (option) => option.isCorrect,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            disableAnimations: true,
            size: Size(430, 932),
          ),
          child: Scaffold(
            body: Act0LessonRunnerShellV1(
              runner: task.runner.copyWith(
                phase: Act0LessonPhaseV1.review,
                selectedOptionId: selected.id,
                teachingStepIndex: task.runner.teachingSteps.length,
              ),
              selectedWorldId: 'world_1',
              selectedLessonId: lesson.lessonId,
              selectedTaskId: task.taskId,
              tableVisualVariant: Act0ShellTableVisualVariantV1.classic,
              onBack: () {},
              onContinueTheory: () {},
              onContinueReview: () {},
              onChooseOption: (_) {},
            ),
          ),
        ),
      ),
    );
    final first = find.byKey(const Key('act0_shell_action_trail_step_0'));
    expect(tester.widget<AnimatedSlide>(first).duration, Duration.zero);
    final opacity = tester.widget<AnimatedOpacity>(
      find.descendant(of: first, matching: find.byType(AnimatedOpacity)),
    );
    expect(opacity.duration, Duration.zero);
    expect(opacity.opacity, 1);
  });

  testWidgets('W9 live inline history and CTA are ready with Reduce Motion', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(
          disableAnimations: true,
          reduceMotion: true,
        );
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('en'),
        home: Act0ShellPreviewScreenV1(
          initialPhase: Act0LessonPhaseV1.drill,
          showPlacementOnStart: false,
          debugHarnessEntry: Act0ShellDebugHarnessEntryV1(
            mode: Act0ControlledDemoCaptureModeV1.directState,
            surface: Act0ControlledDemoCaptureSurfaceV1.runnerDrill,
            worldId: 'world_9',
            lessonId: 'm_ratio_zones_lite',
            taskId: 'w9_m_ratio_table_window_transfer',
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    final first = find.byKey(const Key('act0_shell_street_replay_step_0'));
    expect(first, findsOneWidget);
    final firstMotion = find.byKey(
      const Key('act0_shell_street_replay_step_motion_0'),
    );
    expect(
      find.descendant(of: firstMotion, matching: find.byType(AnimatedSlide)),
      findsNothing,
    );
    expect(
      find.byKey(const Key('act0_shell_street_replay_scroll')),
      findsOneWidget,
    );
    final task = Act0ShellStateV1.sample
        .worldById('world_9')
        .lessons
        .singleWhere((lesson) => lesson.lessonId == 'm_ratio_zones_lite')
        .courseTaskList
        .singleWhere(
          (task) => task.taskId == 'w9_m_ratio_table_window_transfer',
        );
    final answer = task.runner.options.singleWhere(
      (option) => option.isCorrect,
    );
    final cta = find.byKey(Key('act0_shell_option_${answer.id}'));
    expect(cta.hitTestable(), findsOneWidget);
    await tester.tap(cta);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('act0_shell_feedback_continue_cta')),
      findsOneWidget,
    );
  });
}

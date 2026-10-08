import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  testWidgets('parent rebuild must not permanently disable theory Next', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final task = Act0ShellStateV1.sample
        .worldById('world_1')
        .lessons
        .firstWhere((lesson) => lesson.lessonId == 'what_poker_is')
        .taskList
        .firstWhere((task) => task.taskId == 'what_poker_is_theory');
    final runner = task.runner.copyWith(
      phase: Act0LessonPhaseV1.theory,
      teachingStepIndex: 0,
    );
    final rebuild = ValueNotifier<int>(0);
    addTearDown(rebuild.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ValueListenableBuilder<int>(
            valueListenable: rebuild,
            builder: (_, value, child) => Act0LessonRunnerShellV1(
              key: const ValueKey('same-runner'),
              runner: runner,
              selectedWorldId: 'world_1',
              selectedLessonId: 'what_poker_is',
              selectedTaskId: task.taskId,
              onBack: () {},
              onContinueTheory: () {},
              onContinueReview: () {},
              onChooseOption: (_) {},
            ),
          ),
        ),
      ),
    );
    final next = find.byKey(const Key('act0_shell_continue_cta'));
    expect(next, findsOneWidget);
    await tester.pump(const Duration(milliseconds: 100));
    // A parent rebuilding during the 820ms dwell window is normal in runtime.
    rebuild.value += 1;
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    final button = tester.widget<TextButton>(next);
    expect(
      button.onPressed,
      isNotNull,
      reason: 'Same-step rebuild must preserve its original unlock timer.',
    );
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpCompactFlatFourOptionDecision(
    WidgetTester tester, {
    bool priced = false,
  }) async {
    final lesson = Act0ShellStateV1.sample
        .worldById('world_11')
        .lessons
        .firstWhere((candidate) => candidate.lessonId == 'session_plan_basics');
    final task = lesson.taskList.firstWhere(
      (candidate) => candidate.taskId == 'w11_plan_table_focus_transfer',
    );
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Act0LessonRunnerShellV1(
            runner: task.runner.copyWith(
              phase: Act0LessonPhaseV1.drill,
              teachingSteps: const <Act0TeachingStepV1>[],
              options: <Act0RunnerOptionV1>[
                Act0RunnerOptionV1(
                  id: 'fold',
                  label: 'Fold',
                  isCorrect: false,
                  preferredLabel: 'Call',
                  quality: Act0FeedbackQualityV1.wrong,
                  feedbackTitle: 'Try again.',
                  feedbackReason: 'Keep the answer list compact.',
                ),
                Act0RunnerOptionV1(
                  id: 'call',
                  label: 'Call',
                  isCorrect: true,
                  preferredLabel: 'Call',
                  quality: Act0FeedbackQualityV1.correct,
                  feedbackTitle: 'Correct.',
                  feedbackReason: 'Keep the answer list compact.',
                ),
                Act0RunnerOptionV1(
                  id: 'check',
                  label: 'Check',
                  isCorrect: false,
                  preferredLabel: 'Call',
                  quality: Act0FeedbackQualityV1.wrong,
                  feedbackTitle: 'Try again.',
                  feedbackReason: 'Keep the answer list compact.',
                ),
                Act0RunnerOptionV1(
                  id: 'raise',
                  label: 'Raise',
                  amountLabel: priced ? '2 BB' : '',
                  isCorrect: false,
                  preferredLabel: 'Call',
                  quality: Act0FeedbackQualityV1.wrong,
                  feedbackTitle: 'Try again.',
                  feedbackReason: 'Keep the answer list compact.',
                ),
              ],
            ),
            selectedTaskId: task.taskId,
            onBack: () {},
            onContinueTheory: () {},
            onChooseOption: (_) {},
            onContinueReview: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'flat four-option compact decisions reclaim lower-slot height without losing dock safety',
    (tester) async {
      await pumpCompactFlatFourOptionDecision(tester);

      final tableRect = tester.getRect(
        find.byKey(const Key('act0_shell_table')),
      );
      final dockRect = tester.getRect(
        find.byKey(const Key('act0_shell_runner_action_dock')),
      );
      final finalOptionRect = tester.getRect(
        find.byKey(const Key('act0_shell_option_raise')),
      );

      expect(tableRect.height, greaterThanOrEqualTo(430));
      expect(dockRect.top - tableRect.bottom, lessThanOrEqualTo(18));
      expect(dockRect.bottom - finalOptionRect.bottom, lessThanOrEqualTo(86));
      expect(finalOptionRect.height, greaterThanOrEqualTo(44));
      expect(finalOptionRect.bottom, lessThanOrEqualTo(812));
    },
  );

  testWidgets('priced four-option decisions keep the existing lower slot', (
    tester,
  ) async {
    await pumpCompactFlatFourOptionDecision(tester, priced: true);

    final tableRect = tester.getRect(find.byKey(const Key('act0_shell_table')));
    final finalOptionRect = tester.getRect(
      find.byKey(const Key('act0_shell_option_raise')),
    );

    expect(tableRect.height, lessThan(430));
    expect(finalOptionRect.height, greaterThanOrEqualTo(44));
    expect(finalOptionRect.bottom, lessThanOrEqualTo(812));
  });
}

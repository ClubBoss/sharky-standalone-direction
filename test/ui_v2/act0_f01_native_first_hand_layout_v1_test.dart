import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'F01 four-option first-hand accessibility shelf lays out decision and feedback',
    (tester) async {
      tester.view.physicalSize = const Size(402, 874);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final task = Act0ShellStateV1.sample
          .worldById('world_1')
          .lessons
          .firstWhere((lesson) => lesson.lessonId == 'what_poker_is')
          .taskList
          .firstWhere(
            (entry) => entry.taskId == 'what_poker_is_table_read_transfer',
          );
      final assessment = placementQuickCheckRunnerV1(
        task.runner.copyWith(
          phase: Act0LessonPhaseV1.drill,
          teachingSteps: const <Act0TeachingStepV1>[],
        ),
        signalId: 'table_read',
        checkIndex: 1,
        checkCount: 3,
      );
      expect(assessment.options, hasLength(4));
      var runner = assessment;
      var step = Act0AccessibilityPrototypeStepV1.evidence;
      var submitted = 0;
      var continued = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(402, 874),
              viewPadding: EdgeInsets.only(top: 59, bottom: 34),
              textScaler: TextScaler.linear(1.4),
            ),
            child: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) => Act0LessonRunnerShellV1(
                  runner: runner,
                  selectedTaskFamily: task.resolvedTaskFamily,
                  tableVisualVariant: Act0ShellTableVisualVariantV1.refinedDev2,
                  accessibilityPrototypeStep: step,
                  onAccessibilityPrototypeStepChanged: (next) {
                    setState(() => step = next);
                  },
                  onBack: () {},
                  onContinueTheory: () {},
                  onChooseOption: (option) {
                    setState(() {
                      submitted++;
                      runner = assessment.copyWith(
                        phase: Act0LessonPhaseV1.review,
                        selectedOptionId: option.id,
                        feedbackTitle: option.feedbackTitle,
                        feedbackReason: option.feedbackReason,
                        primaryCtaLabel: 'Next check',
                      );
                    });
                  },
                  onContinueReview: () => continued++,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(
        act0ShouldActivateCompactAccessibilityPrototypeV1(
          tester.element(find.byType(Act0LessonRunnerShellV1)),
          question: assessment.question,
          options: assessment.options,
        ),
        isTrue,
      );

      final dock = tester.getRect(
        find.byKey(const Key('act0_shell_runner_action_dock')),
      );
      expect(dock.height.isFinite, isTrue);
      expect(
        find.byKey(const Key('act0_shell_lower_stage_accessibility')),
        findsOneWidget,
      );
      for (final option in assessment.options) {
        final finder = find.byKey(Key('act0_shell_option_${option.id}'));
        expect(finder, findsOneWidget);
        final rect = tester.getRect(finder);
        expect(rect.height, greaterThanOrEqualTo(44));
        expect(rect.top, greaterThanOrEqualTo(0));
        expect(rect.bottom, lessThanOrEqualTo(874));
      }
      expect(
        find.byKey(const Key('act0_shell_accessibility_question')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_accessibility_guidance')),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const Key('act0_shell_option_two_three_six')),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(submitted, 1);
      expect(find.byKey(const Key('act0_shell_feedback_card')), findsOneWidget);
      expect(
        find.text(
          'Right: two private cards, three board cards, and a 6 BB pot.',
        ),
        findsOneWidget,
      );
      final feedback = tester.getRect(
        find.text(
          'Right: two private cards, three board cards, and a 6 BB pot.',
        ),
      );
      final nextCta = find.byKey(const Key('act0_shell_feedback_continue_cta'));
      expect(nextCta, findsOneWidget);
      final nextRect = tester.getRect(nextCta);
      expect(nextRect.top, greaterThanOrEqualTo(feedback.bottom));
      expect(nextRect.bottom, lessThanOrEqualTo(874));
      await tester.ensureVisible(nextCta);
      await tester.tap(nextCta);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(continued, 1);
    },
  );

  testWidgets('F01 ordinary non-accessibility shelf remains unchanged', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final task = Act0ShellStateV1.sample
        .worldById('world_1')
        .lessons
        .firstWhere((lesson) => lesson.lessonId == 'what_poker_is')
        .taskList
        .firstWhere(
          (entry) => entry.taskId == 'what_poker_is_table_read_transfer',
        );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Act0LessonRunnerShellV1(
            runner: task.runner.copyWith(phase: Act0LessonPhaseV1.drill),
            tableVisualVariant: Act0ShellTableVisualVariantV1.refinedDev2,
            onBack: () {},
            onContinueTheory: () {},
            onChooseOption: (_) {},
            onContinueReview: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(
      find.byKey(const Key('act0_shell_lower_stage_accessibility')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('act0_shell_runner_action_dock')),
      findsOneWidget,
    );
  });
}

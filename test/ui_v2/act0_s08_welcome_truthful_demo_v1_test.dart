import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_welcome_shell_v1.dart';

// F04 regression: Welcome's demo spot must stay a truthful orientation and
// never present a fabricated graded choice. The old behavior fed the real
// decision+review runner with a synthetic micro-win state, so picking the
// wrong option surfaced the real wrong-answer feedback screen with a
// "Try same clue" CTA that did not actually retry anything inside Welcome.
void main() {
  Future<void> pumpWelcomeToDemoSpot(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: Act0WelcomeShellV1(replayMode: false, onCompleted: () {}),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_welcome_primary_cta')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('act0_shell_welcome_demo_spot')), findsOneWidget);
  }

  testWidgets(
    'picking the wrong demo option never shows a graded wrong/retry state',
    (tester) async {
      await pumpWelcomeToDemoSpot(tester);

      final runner = tester
          .widget<Act0LessonRunnerShellV1>(
            find.byType(Act0LessonRunnerShellV1),
          )
          .runner;
      final wrongOption = runner.options.firstWhere(
        (option) => !option.isCorrect,
      );

      await tester.tap(
        find.byKey(Key('act0_shell_option_${wrongOption.id}')),
      );
      await tester.pumpAndSettle();

      // No fabricated graded feedback of any kind: no retry CTA promising a
      // redo that Welcome cannot deliver, and no real review/feedback chrome.
      expect(find.text('Try same clue'), findsNothing);
      expect(
        find.byKey(const Key('act0_shell_feedback_continue_cta')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('act0_shell_welcome_demo_spot')),
        findsNothing,
      );

      // Welcome moved straight to its truthful handoff beat instead.
      expect(
        find.byKey(const Key('act0_shell_welcome_next_step_line')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'picking the correct demo option reaches the same truthful handoff',
    (tester) async {
      await pumpWelcomeToDemoSpot(tester);

      final runner = tester
          .widget<Act0LessonRunnerShellV1>(
            find.byType(Act0LessonRunnerShellV1),
          )
          .runner;
      final correctOption = runner.options.firstWhere(
        (option) => option.isCorrect,
      );

      await tester.tap(
        find.byKey(Key('act0_shell_option_${correctOption.id}')),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('act0_shell_feedback_continue_cta')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('act0_shell_welcome_next_step_line')),
        findsOneWidget,
      );
    },
  );
}

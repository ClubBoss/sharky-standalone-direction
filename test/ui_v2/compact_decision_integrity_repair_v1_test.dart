import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'W1 table-read quick check keeps every compact choice tied to the visible table',
    (tester) async {
      final task = Act0ShellStateV1.sample
          .worldById('world_1')
          .lessons
          .firstWhere((lesson) => lesson.lessonId == 'what_poker_is')
          .taskList
          .firstWhere(
            (entry) => entry.taskId == 'what_poker_is_table_read_transfer',
          );
      final runner = placementQuickCheckRunnerV1(
        task.runner.copyWith(
          phase: Act0LessonPhaseV1.drill,
          teachingSteps: const <Act0TeachingStepV1>[],
        ),
        signalId: 'table_read',
        checkIndex: 1,
        checkCount: 3,
      );

      expect(
        runner.options.map((option) => option.id),
        containsAllInOrder(<String>[
          'two_three_six',
          'two_five_six',
          'two_three_four',
          'not_sure_yet',
        ]),
      );
      expect(
        runner.options.where((option) => option.isCorrect).single.id,
        'two_three_six',
      );
      expect(
        runner.options.map((option) => option.label),
        everyElement(hasLength(lessThanOrEqualTo(36))),
      );

      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Act0LessonRunnerShellV1(
              runner: runner,
              selectedTaskFamily: task.resolvedTaskFamily,
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

      expect(find.text('What does this table show?'), findsOneWidget);
      expect(find.text('2 private · 3 board · Pot 6 BB'), findsOneWidget);
      expect(find.text('2 private · 5 board · Pot 6 BB'), findsOneWidget);
      expect(find.text('2 private · 3 board · Pot 4 BB'), findsOneWidget);
      expect(
        tester.getRect(find.byKey(const Key('act0_shell_table'))).height,
        greaterThanOrEqualTo(430),
      );
      expect(
        tester
            .getRect(find.byKey(const Key('act0_shell_option_not_sure_yet')))
            .bottom,
        lessThanOrEqualTo(812),
      );
    },
  );
}

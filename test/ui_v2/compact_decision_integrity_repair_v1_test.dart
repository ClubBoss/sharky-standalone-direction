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
      expect(
        tester
            .getRect(find.byKey(const Key('act0_shell_runner_action_dock')))
            .bottom,
        greaterThanOrEqualTo(800),
      );
      expect(
        find.byKey(const Key('act0_shell_poker_action_icon_check')),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('act0_shell_option_marker_not_sure_yet')),
          matching: find.text('?'),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'compact seat instruction reserves a reachable lower panel and one learner identity',
    (tester) async {
      final lesson = Act0ShellStateV1.sample
          .worldById('world_1')
          .lessons
          .firstWhere((lesson) => lesson.lessonId == 'what_poker_is');
      final task = lesson.taskList.firstWhere(
        (entry) => entry.taskId == 'what_poker_is_find_hero',
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
              ),
              selectedTaskId: task.taskId,
              selectedTaskFamily: task.resolvedTaskFamily,
              onBack: () {},
              onContinueTheory: () {},
              onChooseOption: (_) {},
              onContinueReview: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(
          const Key('act0_shell_runner_envelope_compact_tableTapDecision'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_seat_tap_prompt')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_wave1_hero_you_badge')),
        findsOneWidget,
      );
      expect(find.text('BTN Hero'), findsNothing);
      expect(
        find.byKey(const Key('act0_shell_marker_btn_dealer')),
        findsNothing,
      );
      expect(
        tester
            .getRect(find.byKey(const Key('act0_shell_seat_tap_prompt')))
            .bottom,
        lessThanOrEqualTo(812),
      );
      expect(
        tester
            .getRect(find.byKey(const Key('act0_shell_runner_action_dock')))
            .bottom,
        greaterThanOrEqualTo(800),
      );
    },
  );

  testWidgets(
    'tall compact instruction rail keeps its content reachable without overflow',
    (tester) async {
      final lesson = Act0ShellStateV1.sample
          .worldById('world_1')
          .lessons
          .firstWhere((lesson) => lesson.lessonId == 'what_poker_is');
      final task = lesson.taskList.firstWhere(
        (entry) => entry.taskId == 'what_poker_is_theory',
      );

      tester.view.physicalSize = const Size(400, 874);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Act0LessonRunnerShellV1(
              runner: task.runner.copyWith(phase: Act0LessonPhaseV1.theory),
              selectedTaskId: task.taskId,
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

      final rail = find.byKey(const Key('act0_shell_learning_rail'));
      final lane = find.byKey(
        const Key('act0_shell_learning_rail_content_lane'),
      );
      final continueCta = find.byKey(const Key('act0_shell_continue_cta'));
      final railScroller = find.ancestor(
        of: lane,
        matching: find.byType(SingleChildScrollView),
      );

      expect(rail, findsOneWidget);
      expect(lane, findsOneWidget);
      expect(railScroller, findsOneWidget);
      expect(find.byKey(const Key('act0_shell_runner_prompt')), findsOneWidget);
      expect(continueCta, findsOneWidget);
      expect(tester.getRect(continueCta).bottom, lessThanOrEqualTo(874));
      await tester.drag(railScroller, const Offset(0, -48));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('act0_shell_runner_prompt')), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'tall compact decision panel owns its dock without stretching choices',
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

      tester.view.physicalSize = const Size(414, 896);
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

      final dock = tester.getRect(
        find.byKey(const Key('act0_shell_runner_action_dock')),
      );
      final panel = tester.getRect(
        find.byKey(const Key('act0_shell_compact_decision_surface')),
      );
      final first = tester.getRect(
        find.byKey(const Key('act0_shell_option_two_three_six')),
      );
      final second = tester.getRect(
        find.byKey(const Key('act0_shell_option_two_five_six')),
      );
      final third = tester.getRect(
        find.byKey(const Key('act0_shell_option_two_three_four')),
      );
      final notSure = tester.getRect(
        find.byKey(const Key('act0_shell_option_not_sure_yet')),
      );

      expect(panel.top, lessThanOrEqualTo(dock.top + 4));
      expect(panel.bottom, greaterThanOrEqualTo(dock.bottom - 4));
      expect(notSure.bottom, lessThanOrEqualTo(896));
      expect(notSure.height, greaterThanOrEqualTo(44));
      expect(second.top - first.bottom, closeTo(third.top - second.bottom, 1));
      expect(third.top - second.bottom, closeTo(notSure.top - third.bottom, 1));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'compact feedback keeps its concise CTA state inside the shared lower slot',
    (tester) async {
      final lesson = Act0ShellStateV1.sample
          .worldById('world_1')
          .lessons
          .firstWhere((lesson) => lesson.lessonId == 'what_poker_is');
      final task = lesson.taskList.firstWhere(
        (entry) => entry.taskId == 'what_poker_is_find_hero',
      );
      final selectedOption = task.runner.options.firstWhere(
        (option) => option.isCorrect,
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
                phase: Act0LessonPhaseV1.review,
                selectedOptionId: selectedOption.id,
                teachingSteps: const <Act0TeachingStepV1>[],
              ),
              selectedTaskId: task.taskId,
              selectedTaskFamily: task.resolvedTaskFamily,
              onBack: () {},
              onContinueTheory: () {},
              onChooseOption: (_) {},
              onContinueReview: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('act0_shell_runner_envelope_compact_feedback')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_feedback_continue_cta')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_feedback_sharky_slot_proof')),
        findsNothing,
      );
      expect(
        tester
            .getRect(find.byKey(const Key('act0_shell_feedback_continue_cta')))
            .bottom,
        lessThanOrEqualTo(812),
      );
      expect(
        tester
            .getRect(find.byKey(const Key('act0_shell_runner_action_dock')))
            .bottom,
        greaterThanOrEqualTo(800),
      );
    },
  );
}

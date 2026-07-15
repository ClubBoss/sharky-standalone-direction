import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void expectRectClose(Rect actual, Rect expected) {
  expect(actual.left, closeTo(expected.left, 0.05));
  expect(actual.top, closeTo(expected.top, 0.05));
  expect(actual.right, closeTo(expected.right, 0.05));
  expect(actual.bottom, closeTo(expected.bottom, 0.05));
}

void main() {
  test(
    'only the two source-owned Action tasks opt into table presentation',
    () {
      final lesson = Act0ShellStateV1.sample.lessonById(
        'fold_check_call_raise',
      );
      final byId = {for (final task in lesson.taskList) task.taskId: task};
      expect(
        byId['actions_theory']!.tablePresentation,
        Act0TaskTablePresentationV1.spatialTheory,
      );
      expect(
        byId['actions_check_drill']!.tablePresentation,
        Act0TaskTablePresentationV1.stablePractice,
      );
      expect(
        byId['actions_legal_context']!.tablePresentation,
        Act0TaskTablePresentationV1.legacy,
      );
    },
  );

  test('presentation semantics reach the active runner owner', () {
    final task = Act0ShellStateV1.sample
        .lessonById('fold_check_call_raise')
        .taskList
        .firstWhere((candidate) => candidate.taskId == 'actions_theory');
    final runner = Act0LessonRunnerShellV1(
      runner: task.runner,
      tablePresentation: task.tablePresentation,
      onBack: () {},
      onContinueTheory: () {},
      onChooseOption: (_) {},
      onContinueReview: () {},
    );

    expect(runner.tablePresentation, Act0TaskTablePresentationV1.spatialTheory);
  });

  testWidgets('spatial theory keeps its full table above a content panel', (
    tester,
  ) async {
    final task = Act0ShellStateV1.sample
        .lessonById('fold_check_call_raise')
        .taskList
        .firstWhere((candidate) => candidate.taskId == 'actions_theory');
    await tester.binding.setSurfaceSize(const Size(375, 812));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: Act0LessonRunnerShellV1(
          runner: task.runner,
          tablePresentation: task.tablePresentation,
          onBack: () {},
          onContinueTheory: () {},
          onChooseOption: (_) {},
          onContinueReview: () {},
        ),
      ),
    );

    final table = tester.getRect(
      find.byKey(const Key('act0_task_owned_theory_table_bounds')),
    );
    final panel = tester.getRect(
      find.byKey(const Key('act0_task_owned_theory_panel')),
    );
    expect(table.width / table.height, closeTo(0.576, 0.01));
    expect(panel.top - table.bottom, 12);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'refined stable practice keeps its task-owned table presentation',
    (tester) async {
      final task = Act0ShellStateV1.sample
          .lessonById('fold_check_call_raise')
          .taskList
          .firstWhere((candidate) => candidate.taskId == 'actions_check_drill');
      await tester.binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          home: Act0LessonRunnerShellV1(
            runner: task.runner.copyWith(phase: Act0LessonPhaseV1.review),
            tablePresentation: task.tablePresentation,
            onBack: () {},
            onContinueTheory: () {},
            onChooseOption: (_) {},
            onContinueReview: () {},
          ),
        ),
      );

      expect(
        find.byKey(const Key('act0_task_owned_practice_table_bounds')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Day 2 repair keeps the table locked above a content-sized active panel',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          home: Act0ShellPreviewScreenV1(
            state: Act0ShellStateV1.sample,
            showPlacementOnStart: false,
            debugHarnessEntry: const Act0ShellDebugHarnessEntryV1(
              mode: Act0ControlledDemoCaptureModeV1.directState,
              surface:
                  Act0ControlledDemoCaptureSurfaceV1.day2PracticeRepairTarget,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<Act0LessonRunnerShellV1>(
              find.byType(Act0LessonRunnerShellV1),
            )
            .selectedTaskId,
        'actions_check_drill',
      );
      expect(
        find.byKey(const Key('act0_task_owned_practice_table_bounds')),
        findsNothing,
      );
      final tableBefore = tester.getRect(
        find.byKey(const Key('act0_shell_table')),
      );
      final dockBefore = tester.getRect(
        find.byKey(const Key('act0_shell_runner_action_dock')),
      );
      expect(tableBefore.width, greaterThan(0));
      expect(tableBefore.height, greaterThan(0));
      expect(dockBefore.top, greaterThanOrEqualTo(tableBefore.bottom));
      expect(dockBefore.bottom, lessThanOrEqualTo(812));
      await tester.tap(find.byKey(const Key('act0_shell_continue_cta')));
      await tester.pumpAndSettle();

      final tableAfter = tester.getRect(
        find.byKey(const Key('act0_shell_table')),
      );
      expect(tableAfter, tableBefore);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('one hand keeps table geometry through decision and feedback', (
    tester,
  ) async {
    final task = Act0ShellStateV1.sample
        .lessonById('fold_check_call_raise')
        .taskList
        .firstWhere((candidate) => candidate.taskId == 'actions_call_drill');
    var phase = Act0LessonPhaseV1.theory;
    String? selectedOptionId;
    StateSetter? setHostState;

    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            setHostState = setState;
            return Act0LessonRunnerShellV1(
              runner: task.runner.copyWith(
                phase: phase,
                selectedOptionId: selectedOptionId,
                teachingSteps: const <Act0TeachingStepV1>[],
              ),
              selectedTaskId: task.taskId,
              selectedTaskFamily: task.resolvedTaskFamily,
              tableVisualVariant: Act0ShellTableVisualVariantV1.refinedDev2,
              onBack: () {},
              onContinueTheory: () {},
              onChooseOption: (option) {
                setState(() {
                  selectedOptionId = option.id;
                  phase = Act0LessonPhaseV1.review;
                });
              },
              onContinueReview: () {},
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    final theoryTable = tester.getRect(
      find.byKey(const Key('act0_shell_table')),
    );
    final theoryScene = tester.getRect(
      find.byKey(const Key('act0_shell_table_scene')),
    );
    final theoryFelt = tester.getRect(
      find.byKey(const Key('act0_shell_table_felt')),
    );

    setHostState!(() => phase = Act0LessonPhaseV1.drill);
    await tester.pumpAndSettle();
    expectRectClose(
      tester.getRect(find.byKey(const Key('act0_shell_table'))),
      theoryTable,
    );
    expectRectClose(
      tester.getRect(find.byKey(const Key('act0_shell_table_scene'))),
      theoryScene,
    );
    expectRectClose(
      tester.getRect(find.byKey(const Key('act0_shell_table_felt'))),
      theoryFelt,
    );
    final selectedOptionFinder = find.byKey(
      Key(
        'act0_shell_option_${task.runner.options.firstWhere((option) => option.isCorrect).id}',
      ),
    );
    final selectedOptionRect = tester.getRect(selectedOptionFinder);
    expect(selectedOptionRect.height, greaterThanOrEqualTo(44));
    expect(selectedOptionRect.bottom, lessThanOrEqualTo(844));
    expect(
      find.ancestor(
        of: selectedOptionFinder,
        matching: find.byType(SingleChildScrollView),
      ),
      findsNothing,
    );
    await tester.tap(selectedOptionFinder);
    await tester.pumpAndSettle();

    expectRectClose(
      tester.getRect(find.byKey(const Key('act0_shell_table'))),
      theoryTable,
    );
    expectRectClose(
      tester.getRect(find.byKey(const Key('act0_shell_table_scene'))),
      theoryScene,
    );
    expectRectClose(
      tester.getRect(find.byKey(const Key('act0_shell_table_felt'))),
      theoryFelt,
    );
    expect(tester.takeException(), isNull);
  });
}

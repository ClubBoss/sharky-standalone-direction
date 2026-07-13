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

  testWidgets('refined stable practice routes through shared allocation', (
    tester,
  ) async {
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
      findsNothing,
    );
    expect(
      find.byKey(const Key('act0_shell_shared_runner_lower_surface')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

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
        find.byKey(const Key('act0_shell_runner_envelope_repairFill')),
        findsOneWidget,
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
      expectRectClose(tableBefore, const Rect.fromLTRB(8, 46, 367, 669.3));
      expect(dockBefore.top, tableBefore.bottom);
      expect(dockBefore.bottom, 812);
      expect(
        find.byKey(const Key('act0_shell_shared_runner_lower_surface')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('act0_shell_continue_cta')));
      await tester.pumpAndSettle();

      final tableAfter = tester.getRect(
        find.byKey(const Key('act0_shell_table')),
      );
      expect(tableAfter, tableBefore);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('shared active runner allocation keeps the table exact', (
    tester,
  ) async {
    const samples = <(String, Act0ControlledDemoCaptureSurfaceV1)>[
      ('decision', Act0ControlledDemoCaptureSurfaceV1.runnerDrill),
      (
        'correct',
        Act0ControlledDemoCaptureSurfaceV1.runnerFirstCorrectFeedback,
      ),
      ('wrong', Act0ControlledDemoCaptureSurfaceV1.runnerFirstWrongFeedback),
      ('repair', Act0ControlledDemoCaptureSurfaceV1.day2PracticeRepairTarget),
      ('repairResult', Act0ControlledDemoCaptureSurfaceV1.repairResult),
    ];
    const viewports = <(String, Size)>[
      ('compact', Size(375, 812)),
      ('tall', Size(390, 844)),
      ('large', Size(430, 932)),
    ];
    const expectedTables = <Rect>[
      Rect.fromLTRB(8, 46, 367, 669.3),
      Rect.fromLTRB(8, 46, 382, 695.3),
      Rect.fromLTRB(28, 46, 402, 695.3),
    ];
    for (final viewport in viewports) {
      await tester.binding.setSurfaceSize(viewport.$2);
      for (final sample in samples) {
        await tester.pumpWidget(
          MaterialApp(
            home: Act0ShellPreviewScreenV1(
              key: ValueKey<String>('${viewport.$1}_${sample.$1}'),
              state: Act0ShellStateV1.sample,
              showPlacementOnStart: false,
              debugHarnessEntry: Act0ShellDebugHarnessEntryV1(
                mode: Act0ControlledDemoCaptureModeV1.directState,
                surface: sample.$2,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final table = tester.getRect(find.byKey(const Key('act0_shell_table')));
        final lowerSurface = tester.getRect(
          find.byKey(const Key('act0_shell_shared_runner_lower_surface')),
        );
        final expectedTable = expectedTables[viewports.indexOf(viewport)];
        expectRectClose(table, expectedTable);
        expect(lowerSurface.top, table.bottom);
        expect(lowerSurface.bottom, viewport.$2.height);
        expect(tester.takeException(), isNull);
      }
    }
    addTearDown(() => tester.binding.setSurfaceSize(null));
  });
}

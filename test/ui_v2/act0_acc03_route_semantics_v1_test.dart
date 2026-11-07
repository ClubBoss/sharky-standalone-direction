import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

Future<void> host(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));
  await tester.pumpAndSettle();
}

void activate(SemanticsNode node) {
  expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
  node.owner!.performAction(node.id, SemanticsAction.tap);
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  testWidgets('ACC-03: navigation exposes a single selected actionable tab', (
    tester,
  ) async {
    await host(
      tester,
      const Act0ShellPreviewScreenV1(showPlacementOnStart: false),
    );
    final nav = find.byKey(const Key('act0_shell_bottom_nav'));
    for (final label in ['Home', 'Learn', 'Practice', 'Review', 'You']) {
      final control = find.descendant(
        of: nav,
        matching: find.bySemanticsLabel(label),
      );
      expect(control, findsOneWidget);
      final node = tester.getSemantics(control);
      expect(node.getSemanticsData().hasFlag(SemanticsFlag.isButton), isTrue);
      activate(node);
      await tester.pumpAndSettle();
      final data = tester.getSemantics(control).getSemanticsData();
      expect(data.hasFlag(SemanticsFlag.isSelected), isTrue, reason: label);
      SemanticsNode root = tester.getSemantics(control);
      while (root.parent != null) {
        root = root.parent!;
      }
      final unnamedActions = <String>[];
      void visit(SemanticsNode current) {
        final semantics = current.getSemanticsData();
        // Flutter Tooltip supplies a spoken accessible name for icon buttons
        // in SemanticsData.tooltip rather than SemanticsData.label.
        if (semantics.hasAction(SemanticsAction.tap) &&
            semantics.label.trim().isEmpty &&
            semantics.tooltip.trim().isEmpty) {
          unnamedActions.add(current.toStringDeep());
        }
        current.visitChildren((child) {
          visit(child);
          return true;
        });
      }

      visit(root);
      expect(
        unnamedActions,
        isEmpty,
        reason: '$label route must name every exposed tap action',
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets(
    'ACC-03: choices have one full label and button action in source order',
    (tester) async {
      final world = Act0ShellStateV1.sample.worldById('world_1');
      final lesson = world.lessons.firstWhere(
        (l) => l.taskList.any((t) => t.taskId == 'actions_legal_context'),
      );
      final task = lesson.taskList.firstWhere(
        (t) => t.taskId == 'actions_legal_context',
      );
      final choices = <Act0RunnerOptionV1>[];
      await host(
        tester,
        Act0LessonRunnerShellV1(
          runner: task.runner.copyWith(
            phase: task.entryPhase,
            teachingStepIndex: task.runner.teachingSteps.length,
          ),
          worldNumber: world.worldNumber,
          selectedWorldId: world.worldId,
          selectedLessonId: lesson.lessonId,
          selectedTaskId: task.taskId,
          selectedTaskTitle: task.title,
          selectedTaskFamily: task.resolvedTaskFamily,
          compositionFamily: task.resolvedCompositionFamily,
          tablePresentation: task.tablePresentation,
          onBack: () {},
          onContinueTheory: () {},
          onChooseOption: choices.add,
          onContinueReview: () {},
        ),
      );
      for (final entry in task.runner.options.indexed) {
        final node = tester.getSemantics(
          find.byKey(Key('act0_shell_option_${entry.$2.id}')),
        );
        final data = node.getSemanticsData();
        expect(data.label, entry.$2.label);
        expect(data.hasFlag(SemanticsFlag.isButton), isTrue);
        expect(data.hasFlag(SemanticsFlag.isSelected), isFalse);
        expect((node.sortKey as OrdinalSortKey).order, entry.$1.toDouble());
      }
      final first = task.runner.options.first;
      final action = tester.getSemantics(
        find.byKey(Key('act0_shell_option_${first.id}')),
      );
      activate(action);
      await tester.pump();
      expect(choices.single.id, first.id);
      activate(action);
      await tester.pump();
      expect(
        choices,
        hasLength(1),
        reason: 'Semantic activation preserves the once-only choice guard',
      );
      expect(tester.takeException(), isNull);
    },
  );

  for (final assisted in [false, true]) {
    testWidgets(
      'ACC-03: choice result is a live region with assistance=$assisted',
      (tester) async {
        await host(
          tester,
          Act0FeedbackShellV1(
            title: 'Check is unavailable',
            reason: 'A bet is already facing you.',
            quality: Act0FeedbackQualityV1.wrong,
            sharkyLine: 'Read the current bet.',
            sharkyMood: Act0SharkyMoodV1.repair,
            selectedLabel: 'Check',
            preferredLabel: 'Call',
            betterLabel: 'Call',
            isAssistedDecision: assisted,
            onContinue: () {},
          ),
        );
        final result = tester
            .getSemantics(
              find.byKey(const Key('act0_accessibility_choice_result')),
            )
            .getSemanticsData();
        expect(result.hasFlag(SemanticsFlag.isLiveRegion), isTrue);
        expect(result.label, contains('Check is unavailable'));
        expect(result.label, contains('Selected: Check'));
        expect(result.label, contains('A bet is already facing you.'));
        expect(
          result.label,
          assisted ? contains('With help') : isNot(contains('With help')),
        );
      },
    );
  }
}

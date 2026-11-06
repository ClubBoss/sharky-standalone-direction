import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  const probes = <({String world, String task, String answer})>[
    (world: 'world_1', task: 'actions_legal_context', answer: 'Check'),
    (world: 'world_1', task: 'cards_ranks_suits_suit_drill', answer: 'Hearts'),
    (world: 'world_1', task: 'cards_ranks_suits_best_five', answer: 'Five'),
    (world: 'world_1', task: 'hand_rankings_flush_drill', answer: 'Flush'),
    (world: 'world_1', task: 'your_first_hand_recap', answer: 'River'),
    (
      world: 'world_1',
      task: 'cards_ranks_suits_private_board',
      answer: 'Board cards',
    ),
    (world: 'world_1', task: 'showdown_tie_drill', answer: 'Split'),
    (world: 'world_3', task: 'position_apply_early_fold', answer: 'Fold'),
    (world: 'world_1', task: 'blinds_posts_drill', answer: 'BB'),
    (world: 'world_6', task: 'w6_ak_combos', answer: '16 combos'),
  ];
  for (final probe in probes) {
    testWidgets('Full Idea does not disclose ${probe.answer} for ${probe.task}', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final world = Act0ShellStateV1.sample.worldById(probe.world);
      final lesson = world.lessons.firstWhere(
        (l) => l.taskList.any((task) => task.taskId == probe.task),
      );
      final task = lesson.taskList.firstWhere((t) => t.taskId == probe.task);
      final options = task.runner.options.where((o) => o.isCorrect).toList();
      expect(options, hasLength(1));
      expect(options.single.label, probe.answer);
      final choices = <Act0RunnerOptionV1>[];
      final decisions = <Act0CompletedDecisionV1>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Act0LessonRunnerShellV1(
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
              theoryRecallStep: task.runner.teachingSteps.last,
              onBack: () {},
              onContinueTheory: () {},
              onChooseOption: choices.add,
              onCompletedDecision: decisions.add,
              onContinueReview: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final open = find.byKey(const Key('act0_shell_theory_recall_cta'));
      expect(
        open,
        findsOneWidget,
        reason: 'Actual graded drill should expose assistance.',
      );
      await tester.ensureVisible(open);
      await tester.tap(open);
      await tester.pumpAndSettle();
      final reveal = find.byKey(const Key('act0_shell_review_full_idea_cta'));
      if (reveal.evaluate().isNotEmpty) {
        await tester.ensureVisible(reveal);
        await tester.tap(reveal);
        await tester.pumpAndSettle();
      }
      final sheet = find.byKey(const Key('act0_shell_theory_recall_sheet'));
      expect(sheet, findsOneWidget);
      final text = tester
          .widgetList<Text>(
            find.descendant(of: sheet, matching: find.byType(Text)),
          )
          .map((widget) => widget.data ?? '')
          .join(' ');
      final leaked = RegExp(
        '(^|[^a-z0-9])' + RegExp.escape(probe.answer) + r'([^a-z0-9]|$)',
        caseSensitive: false,
      ).hasMatch(text);
      expect(
        leaked,
        isFalse,
        reason:
            'Pre-choice assistance reveals the correct choice for ${probe.task}: $text',
      );
      expect(choices, isEmpty);
      expect(decisions, isEmpty);
      if (probe.task == 'actions_legal_context') {
        await tester.tap(
          find.byKey(const Key('act0_shell_theory_recall_close_cta')),
        );
        await tester.pumpAndSettle();
        final correct = options.single;
        await tester.tap(find.byKey(Key('act0_shell_option_' + correct.id)));
        await tester.pumpAndSettle();
        expect(choices.single.id, correct.id);
        expect(decisions.single.isCorrect, isTrue);
        expect(
          decisions.single.assistanceKind,
          Act0DecisionAssistanceV1.theoryRecall,
        );
      }
      expect(tester.takeException(), isNull);
    });
  }

  // Source body genuinely lists the range taxonomy without deciding which
  // category the current hand fits. Such teaching is not answer leakage.
  for (final taskId in ['w6_value_dry_board', 'w6_missed_dry_board']) {
    testWidgets('neutral category reference stays useful for $taskId', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final world = Act0ShellStateV1.sample.worldById('world_6');
      final lesson = world.lessons.firstWhere(
        (item) => item.taskList.any((task) => task.taskId == taskId),
      );
      final task = lesson.taskList.firstWhere((item) => item.taskId == taskId);
      final choices = <Act0RunnerOptionV1>[];
      final decisions = <Act0CompletedDecisionV1>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Act0LessonRunnerShellV1(
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
              theoryRecallStep: task.runner.teachingSteps.last,
              onBack: () {},
              onContinueTheory: () {},
              onChooseOption: choices.add,
              onCompletedDecision: decisions.add,
              onContinueReview: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final hint = find.byKey(const Key('act0_shell_theory_recall_cta'));
      await tester.ensureVisible(hint);
      await tester.tap(hint);
      await tester.pumpAndSettle();
      final full = find.byKey(const Key('act0_shell_review_full_idea_cta'));
      expect(full, findsOneWidget);
      await tester.tap(full);
      await tester.pumpAndSettle();
      final sheet = find.byKey(const Key('act0_shell_theory_recall_sheet'));
      final text = tester
          .widgetList<Text>(
            find.descendant(of: sheet, matching: find.byType(Text)),
          )
          .map((widget) => widget.data ?? '')
          .join(' ');
      expect(text, contains('sort your hand into value'));
      expect(text, contains('bluff candidate'));
      expect(text, contains('missed'));
      expect(choices, isEmpty);
      expect(decisions, isEmpty);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Quick Hint does not name the shared-card correct option', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final world = Act0ShellStateV1.sample.worldById('world_1');
    final lesson = world.lessons.firstWhere(
      (item) => item.taskList.any(
        (task) => task.taskId == 'cards_ranks_suits_private_board',
      ),
    );
    final task = lesson.taskList.firstWhere(
      (item) => item.taskId == 'cards_ranks_suits_private_board',
    );
    final choices = <Act0RunnerOptionV1>[];
    final decisions = <Act0CompletedDecisionV1>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Act0LessonRunnerShellV1(
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
            theoryRecallStep: task.runner.teachingSteps.last,
            onBack: () {},
            onContinueTheory: () {},
            onChooseOption: choices.add,
            onCompletedDecision: decisions.add,
            onContinueReview: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final hint = find.byKey(const Key('act0_shell_theory_recall_cta'));
    await tester.ensureVisible(hint);
    await tester.tap(hint);
    await tester.pumpAndSettle();
    final hintCopy = tester
        .widget<Text>(find.byKey(const Key('act0_shell_hint_body')))
        .data!;
    expect(
      RegExp(r'\bboard cards\b', caseSensitive: false).hasMatch(hintCopy),
      isFalse,
      reason:
          'Quick Hint must teach the private-vs-shared distinction '
          'without naming the assessed choice.',
    );
    expect(choices, isEmpty);
    expect(decisions, isEmpty);
    expect(tester.takeException(), isNull);
  });
}

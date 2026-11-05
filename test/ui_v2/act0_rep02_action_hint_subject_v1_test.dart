import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  testWidgets('chip-word action question keeps its action Quick Hint subject', (
    tester,
  ) async {
    final probe = await _openRealHint(tester);
    expect(probe.task.runner.question, contains('Which action'));
    expect(probe.task.runner.question, contains('chips'));
    expect(probe.choices, isEmpty);
    expect(probe.decisions, isEmpty);
    expect(
      tester.widget<Text>(find.byKey(const Key('act0_shell_hint_body'))).data,
      'Name the action before choosing what it means.',
      reason: 'The assessed subject is an action, not pot arithmetic.',
    );
  });

  testWidgets(
    'opening the real hint leaves choice to the learner and records help',
    (tester) async {
      final probe = await _openRealHint(tester);
      expect(probe.choices, isEmpty);
      expect(probe.decisions, isEmpty);
      final close = find.byKey(const Key('act0_shell_theory_recall_close_cta'));
      await tester.ensureVisible(close);
      await tester.tap(close);
      await tester.pumpAndSettle();
      final answer = probe.task.runner.options.singleWhere(
        act0RunnerOptionIsAuthoredCorrectV1,
      );
      final choice = find.byKey(Key('act0_shell_option_${answer.id}'));
      await tester.ensureVisible(choice);
      await tester.tap(choice);
      await tester.pumpAndSettle();
      expect(probe.choices.single.id, answer.id);
      expect(probe.decisions.single.selectedId, answer.id);
      expect(probe.decisions.single.expectedId, answer.id);
      expect(probe.decisions.single.isCorrect, isTrue);
      expect(
        probe.decisions.single.assistanceKind,
        Act0DecisionAssistanceV1.quickHint,
      );
      expect(tester.takeException(), isNull);
    },
  );
}

Future<_Probe> _openRealHint(WidgetTester tester) async {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final world = Act0ShellStateV1.sample.worldById('world_1');
  final lesson = world.lessons.firstWhere(
    (value) => value.lessonId == 'fold_check_call_raise',
  );
  final task = lesson.taskList.firstWhere(
    (value) => value.taskId == 'actions_legal_context',
  );
  final probe = _Probe(task);
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
          onChooseOption: probe.choices.add,
          onCompletedDecision: probe.decisions.add,
          onContinueReview: () {},
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  final hint = find.byKey(const Key('act0_shell_theory_recall_cta'));
  expect(hint, findsOneWidget);
  await tester.ensureVisible(hint);
  await tester.tap(hint);
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
  return probe;
}

class _Probe {
  _Probe(this.task);
  final Act0LessonTaskV1 task;
  final choices = <Act0RunnerOptionV1>[];
  final decisions = <Act0CompletedDecisionV1>[];
}

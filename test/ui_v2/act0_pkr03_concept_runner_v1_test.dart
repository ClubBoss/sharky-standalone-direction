// Actual Runner widgets over authored tasks; not native or natural navigation.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';

void main() {
  for (final id in const [
    'w6_turn_shift_bucket',
    'w6_wet_board_repair',
    'w12_bad_call_good_result',
  ]) {
    testWidgets('$id renders the context and submits each graded choice', (
      t,
    ) async {
      t.view.physicalSize = const Size(393, 852);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      final world = Act0ShellStateV1.sample.worlds.singleWhere(
        (w) =>
            w.lessons.any((l) => l.taskList.any((task) => task.taskId == id)),
      );
      final lesson = world.lessons.singleWhere(
        (l) => l.taskList.any((task) => task.taskId == id),
      );
      final task = lesson.taskList.singleWhere((task) => task.taskId == id);
      void expectContext({bool feedback = false}) {
        final dynamic tableWidget = t.widget(
          find.byWidgetPredicate(
            (widget) => widget.runtimeType.toString() == '_Act0TableV1',
          ),
        );
        final table = tableWidget.table as Act0TableStateV1;
        expect(table.scope, Act0TableScopeV1.playedHand);
        expect(table.boardCards, task.runner.table.boardCards);
        expect(table.boardCards, hasLength(4));
        expect(find.text('Hypothetical example'), findsNothing);
        if (id == 'w12_bad_call_good_result') {
          expect(table.streetLabel, 'Turn');
          expect(table.potLabel, 'Pot 22 BB');
          expect(table.toCallLabel, 'To call 12 BB');
          expect(table.heroCards.map((card) => card.label), ['Ah', 'Th']);
          if (!feedback) {
            expect(find.text('Call or fold?'), findsOneWidget);
            expect(find.textContaining('BB shows Kc Kd'), findsWidgets);
          }
        }
      }

      for (final option in task.runner.options) {
        final decisions = <Act0CompletedDecisionV1>[];
        String? selected;
        Widget runner(Act0RunnerStateV1 state) => MaterialApp(
          home: Scaffold(
            body: Act0LessonRunnerShellV1(
              key: ValueKey('$id/${option.id}/${state.phase.name}'),
              runner: state,
              selectedWorldId: world.worldId,
              selectedLessonId: lesson.lessonId,
              selectedTaskId: id,
              selectedTaskFamily: task.resolvedTaskFamily,
              onBack: () {},
              onContinueTheory: () {},
              onChooseOption: (o) => selected = o.id,
              onCompletedDecision: decisions.add,
              onContinueReview: () {},
            ),
          ),
        );
        await t.pumpWidget(
          runner(
            task.runner.copyWith(
              phase: Act0LessonPhaseV1.drill,
              teachingStepIndex: task.runner.teachingSteps.length,
            ),
          ),
        );
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
        expectContext();
        final choice = find.byKey(Key('act0_shell_option_${option.id}'));
        await t.ensureVisible(choice);
        await t.tap(choice);
        await t.pumpAndSettle();
        expect(selected, option.id);
        expect(decisions, hasLength(1));
        expect(decisions.single.sourceTaskId, id);
        expect(decisions.single.selectedId, option.id);
        expect(decisions.single.isCorrect, option.isCorrect);
        expect(decisions.single.assistanceKind, Act0DecisionAssistanceV1.none);
        expect(
          decisions.single.expectedId,
          task.runner.options.singleWhere((o) => o.isCorrect).id,
        );
        await t.pumpWidget(
          runner(
            task.runner.copyWith(
              phase: Act0LessonPhaseV1.review,
              selectedOptionId: option.id,
              teachingStepIndex: task.runner.teachingSteps.length,
            ),
          ),
        );
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
        expectContext(feedback: true);
        expect(find.textContaining(option.feedbackReason), findsWidgets);
      }
    });
  }
}

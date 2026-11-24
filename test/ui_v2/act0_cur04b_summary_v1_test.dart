import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

import '../support/act0_cur04b_summary_contract_v1.dart';

void main() {
  final world = Act0ShellStateV1.sample.worldById('world_12');
  final lesson = world.lessons.singleWhere(
    (lesson) => lesson.lessonId == cur04bSummaryLessonIdV1,
  );
  final tasks = lesson.courseTaskList;
  test(
    'W12 summary gives seven independent decisions at the authored prices',
    () {
      expect(tasks.map((task) => task.taskId), cur04bSummaryChoicesV1.keys);
      expect(world.lessons.last.lessonId, 'mindset_bridge_checkpoint');
      const amounts = [
        (10.5, 4),
        (12.5, 6),
        (15.5, 3),
        (11.5, 5),
        (1.5, 0.5),
        (6.5, 0),
        (17.5, 4),
      ];
      for (final (index, task) in tasks.indexed) {
        final runner = task.runner;
        final table = runner.table;
        final ledger = table.handContributions!;
        final price = ledger.amounts(
          seatIds: table.seats.map((seat) => seat.seatId).toSet(),
          actorSeatId: table.heroSeatId,
        );
        expect(
          (price.potBb, price.toCallBb),
          amounts[index],
          reason: task.taskId,
        );
        expect(table.activeSeatId, table.heroSeatId);
        expect(table.actionTrail, isNotEmpty);
        expect(
          runner.options.map((o) => (o.id, o.label, o.isCorrect)),
          cur04bSummaryChoicesV1[task.taskId],
        );
        expect(runner.teachingSteps, isEmpty);
        expect(runner.hint, isEmpty);
        expect(runner.table.showDecisionPremise, isTrue);
        expect(task.rewardXp, 0);
      }
    },
  );

  testWidgets('the bet mix is visible before choice and its EV appears after', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final task = tasks.first;
    var runner = task.runner;
    String? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) => Act0LessonRunnerShellV1(
            runner: runner,
            worldNumber: 12,
            selectedWorldId: world.worldId,
            selectedLessonId: lesson.lessonId,
            selectedTaskId: task.taskId,
            selectedTaskFamily: task.resolvedTaskFamily,
            tablePresentation: task.tablePresentation,
            onBack: () {},
            onContinueTheory: () {},
            onContinueReview: () {},
            onChooseOption: (option) {
              selected = option.id;
              setState(
                () => runner = runner.copyWith(
                  phase: Act0LessonPhaseV1.review,
                  selectedOptionId: option.id,
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('equally likely hands'), findsOneWidget);
    expect(find.textContaining('+0.83 BB'), findsNothing);
    final call = find.byKey(const Key('act0_shell_option_call_4_bb'));
    await tester.ensureVisible(call);
    await tester.tap(call);
    await tester.pumpAndSettle();
    expect(selected, 'call_4_bb');
    expect(find.textContaining('+0.83 BB'), findsWidgets);
  });
}

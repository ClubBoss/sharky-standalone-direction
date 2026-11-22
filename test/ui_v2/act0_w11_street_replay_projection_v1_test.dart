import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_street_replay_contract_v1.dart';

void main() {
  final lesson = Act0ShellStateV1.sample
      .worldById('world_11')
      .lessons
      .firstWhere((l) => l.lessonId == 'table_trigger_reads');
  for (final turn in [false, true]) {
    final id = turn
        ? 'w11_trigger_bad_price_fold'
        : 'w11_trigger_small_price_continue';
    final task = lesson.taskList.firstWhere((t) => t.taskId == id);
    testWidgets(
      '$id priced decision renders with the guarded inline replay closed',
      (tester) async {
        tester.view.physicalSize = const Size(393, 852);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Act0LessonRunnerShellV1(
                runner: task.runner.copyWith(
                  phase: task.entryPhase,
                  teachingStepIndex: task.runner.teachingSteps.length,
                ),
                worldNumber: 11,
                selectedWorldId: 'world_11',
                selectedLessonId: lesson.lessonId,
                selectedTaskId: id,
                selectedTaskTitle: task.title,
                selectedTaskFamily: task.resolvedTaskFamily,
                compositionFamily: task.resolvedCompositionFamily,
                tablePresentation: task.tablePresentation,
                onBack: () {},
                onContinueTheory: () {},
                onChooseOption: (_) {},
                onContinueReview: () {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final subtree = find.byKey(
          const Key('act0_shell_street_replay_inline'),
        );
        expect(subtree, findsNothing);
        final shell = tester.widget<Act0LessonRunnerShellV1>(
          find.byType(Act0LessonRunnerShellV1),
        );
        expect(shell.runner.table.potLabel, turn ? 'Pot 18 BB' : 'Pot 12 BB');
        expect(
          shell.runner.table.toCallLabel,
          turn ? 'To call 8 BB' : 'To call 2 BB',
        );
        expect(shell.runner.table.decisionSeatId, turn ? 'sb' : 'bb');
        expect(find.textContaining('winner', findRichText: true), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
    test('$id replays only its exact prefix and active decision', () {
      final table = task.runner.table;
      final replay = act0StreetReplayFromTableV1(table)!;
      expect(replay.isConsumerSafe, isTrue);
      expect(
        replay.currentStreet,
        turn ? Act0StreetReplayStreetV1.turn : Act0StreetReplayStreetV1.flop,
      );
      expect(table.decisionSeatId, turn ? 'sb' : 'bb');
      expect(replay.currentDecisionActor, 'Hero');
      expect(replay.steps.last.actorLabel, turn ? 'CO' : 'BTN');
      expect(replay.steps.last.actionTypeLabel, turn ? 'bets' : 'calls');
      expect(replay.steps.last.amountLabel, turn ? '8 BB' : '2 BB');
      expect(replay.steps.last.potAtStreet, turn ? 'Pot 18 BB' : 'Pot 12 BB');
      expect(replay.steps.last.isCurrentStreet, isTrue);
      expect(replay.steps.last.boardCardsAtStreet.length, turn ? 4 : 3);
      final missingFinalAction = table.copyWith(
        actionTrail: table.actionTrail
            .take(table.actionTrail.length - 1)
            .toList(),
      );
      expect(
        act0StreetReplayFromTableV1(missingFinalAction)?.isConsumerSafe,
        isNot(true),
      );
    });

    test('$id pot and call price reconcile with its complete ledger', () {
      final table = task.runner.table;
      final amounts = table.handContributions!.amounts(
        seatIds: table.seats.map((seat) => seat.seatId).toSet(),
        actorSeatId: table.decisionSeatId,
      );
      final pot = turn ? 18.0 : 12.0;
      final call = turn ? 8.0 : 2.0;
      expect(amounts.potBb, pot);
      expect(amounts.toCallBb, call);
      expect(table.toCallLabel, turn ? 'To call 8 BB' : 'To call 2 BB');
      expect(call / (pot + call), closeTo(turn ? 8 / 26 : 2 / 14, 1e-9));
    });
  }
}

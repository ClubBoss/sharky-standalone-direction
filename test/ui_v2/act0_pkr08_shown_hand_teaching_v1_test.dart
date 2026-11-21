// Narrow PKR-08 regression: shown-hand teaching is not a full-pot verdict.
// The two partial-showdown examples retain bounded teaching in the Runner.
// Compatibility-only w2_* references are source impact, not active Runner cases.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_solver/poker_solver.dart';

import '../support/act0_pot_showdown_truth_v1.dart';

const _bestHandTaskXp = <String, int>{'what_poker_is_showdown_win': 4};
const _tieTaskXp = <String, int>{'showdown_tie_drill': 7};
const _bestHandBody =
    'You use K-K-A-J-7. CO uses J-J-A-K-7. Your kings beat CO’s jacks.';
const _tieBody =
    'You and CO share the same A-K-Q-J-T straight from the board, so the two shown hands tie. Only these two hands are shown here.';

Act0LessonTaskV1 _task(String id) => [
  for (final world in Act0ShellStateV1.sample.worlds)
    for (final lesson in world.lessons) ...lesson.taskList,
].singleWhere((task) => task.taskId == id);

void main() {
  for (final entry in {..._bestHandTaskXp, ..._tieTaskXp}.entries) {
    final id = entry.key;
    final isTie = _tieTaskXp.containsKey(id);
    final expectedBody = isTie ? _tieBody : _bestHandBody;
    final heroSeat = isTie ? 'utg' : 'hj';

    test('PKR08 shown-hand teaching stays within source evidence: $id', () {
      final task = _task(id);
      final runner = task.runner;
      final teaching = runner.teachingSteps.single;
      expect(teaching.body, expectedBody);
      expect(
        teaching.focusLabels,
        isTie ? ['Shown hands tie'] : ['Best five', 'Kings beat jacks'],
      );
      expect(task.rewardXp, entry.value);
      expect(
        runner.options.where((option) => option.isCorrect).map((o) => o.id),
        [isTie ? 'split' : 'best_hand'],
      );

      // Do not fold, reveal or replace the other live participants to make a
      // two-hand comparison look like a complete showdown.
      final live = runner.table.seats.where(
        (seat) => seat.isOccupied && seat.isInHand && !seat.isFolded,
      );
      final shown = live.where(
        (seat) =>
            seat.isHero ||
            seat.cardsVisibleMode == Act0CardsVisibleModeV1.faceUp,
      );
      expect(shown.map((seat) => seat.seatId).toSet(), {heroSeat, 'co'});
      expect(
        live
            .where((seat) => !shown.contains(seat))
            .map((s) => s.seatId)
            .toSet(),
        {'btn', 'sb', 'bb', if (isTie) 'hj' else 'utg'},
      );

      // Rank only the two shown hands. This is deliberately not a pot oracle.
      final board = runner.table.boardCards.map(
        (c) => potTruthSolverCardV1(c)!,
      );
      final hands = {
        for (final seat in shown)
          seat.seatId: Hand.solveHand([
            ...board,
            ...(seat.isHero ? runner.table.heroCards : seat.holeCards).map(
              (c) => potTruthSolverCardV1(c)!,
            ),
          ]),
      };
      final bestShown = Hand.winners(hands.values.toList());
      expect(
        hands.entries
            .where((e) => bestShown.contains(e.value))
            .map((e) => e.key)
            .toSet(),
        isTie ? {heroSeat, 'co'} : {heroSeat},
      );
      final fullPot = resolveShowdownTruthV1(runner.table);
      expect(fullPot.verdict, PotTruthVerdictV1.unproved);
      expect(fullPot.reason, startsWith('hidden_live_hand_can_win_or_tie'));
      expect(fullPot.winners, isEmpty);
      expect(fullPot.potBb, isNull);
    });

    testWidgets('PKR08 Runner retains bounded teaching: $id', (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final runner = _task(id).runner;
      expect(runner.activeTeachingStep, isNotNull);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Act0LessonRunnerShellV1(
              runner: runner,
              selectedTaskId: id,
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
        find.textContaining(expectedBody, findRichText: true),
        findsWidgets,
      );
      expect(find.textContaining('You win', findRichText: true), findsNothing);
      expect(
        find.textContaining('so they split the pot', findRichText: true),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    });
  }
}

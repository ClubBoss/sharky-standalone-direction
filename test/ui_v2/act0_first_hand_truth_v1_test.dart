import 'package:flutter_test/flutter_test.dart';
import 'package:poker_solver/poker_solver.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import '../support/act0_table_truth_v1.dart';

void main() {
  test(
    'declared first hand: eight tasks, one deck, legal approved action order and cash pot',
    () {
      final tasks = Act0ShellStateV1.sample
          .lessonById('your_first_hand')
          .taskList;
      expect(tasks.length, 8);
      final fullBoard = ['Ah', '7c', '2d', 'Jc', '4s'];
      for (final task in tasks) {
        final t = task.runner.table;
        expect(t.heroCards.map(cardIdentity), [
          'As',
          'Kd',
        ], reason: task.taskId);
        expect(
          t.boardCards.map(cardIdentity),
          fullBoard.take(t.boardCards.length),
          reason: task.taskId,
        );
        expect(t.potLabel, 'Pot 7.5 BB', reason: task.taskId);
        final preflop = t.actionTrail
            .takeWhile((a) => !a.label.startsWith('Flop:'))
            .map((a) => a.label)
            .toList();
        expect(preflop, [
          'SB blind 0.5 BB',
          'BB blind 1 BB',
          'UTG folds',
          'HJ folds',
          'CO calls 1 BB',
          'BTN raises to 3 BB',
          'SB folds',
          'BB folds',
          'CO calls 2 BB more',
        ]);
        // Complete, explicitly owner-authored commitments: raise-to replaces BTN's
        // total; CO's second call adds two. Dead blind money remains in the pot.
        final contributions = <String, double>{};
        for (final label in preflop) {
          final m = RegExp(
            r'^(SB|BB|CO|BTN) (blind|calls|raises to) ([\d.]+) BB',
          ).firstMatch(label);
          if (m == null) continue;
          final value = double.parse(m[3]!);
          contributions[m[1]!] = m[2] == 'raises to'
              ? value
              : (contributions[m[1]!] ?? 0) + value;
        }
        expect(contributions.values.fold<double>(0, (a, b) => a + b), 7.5);
        expect(
          t.seats
              .where((s) => s.isInHand && !s.isFolded)
              .map((s) => s.seatId)
              .toSet(),
          {'co', 'btn'},
        );
        final history = task.taskId.endsWith('action_trail');
        if (history) {
          expect(t.streetLabel, 'Flop');
          expect(t.boardCards.length, 3);
          expect(t.actionTrail.last.label, 'Flop: CO checks');
          final choice = task.runner.options.singleWhere((o) => o.isCorrect);
          expect(choice.id, 'bb_check');
          expect(choice.label, 'Flop: CO checks');
          for (final o in task.runner.options) {
            expect(
              '${o.label} ${o.preferredLabel} ${o.betterAnswerLabel} ${o.feedbackReason}',
              isNot(contains('BB checks')),
            );
          }
        }
        final isShowdown =
            task.taskId.endsWith('showdown') || task.taskId.endsWith('recap');
        final co = t.seats.singleWhere((s) => s.seatId == 'co');
        expect(
          co.cardsVisibleMode,
          isShowdown
              ? Act0CardsVisibleModeV1.faceUp
              : Act0CardsVisibleModeV1.faceDown,
        );
        if (isShowdown) {
          expect(co.holeCards.map(cardIdentity), ['Kh', 'Jh']);
          final hero = Hand.solveHand(
            [...t.heroCards, ...t.boardCards].map(cardIdentity).toList(),
          );
          final villain = Hand.solveHand(
            [...co.holeCards, ...t.boardCards].map(cardIdentity).toList(),
          );
          expect(Hand.winners([hero, villain]), [hero]);
          for (final street in ['Flop', 'Turn', 'River']) {
            final lines = t.actionTrail
                .where((a) => a.label.startsWith('$street:'))
                .map((a) => a.label);
            expect(lines, ['$street: CO checks', '$street: BTN checks']);
          }
        }
      }
    },
  );
}

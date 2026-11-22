import 'package:flutter_test/flutter_test.dart';
import 'package:poker_solver/poker_solver.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import '../support/act0_table_truth_v1.dart';

void main() {
  test('W1 seats stay within the novice and whole-world BTN limits', () {
    final lessons = Act0ShellStateV1.sample.worldById('world_1').lessons;
    final tasks = lessons
        .expand((lesson) => lesson.taskList)
        .where((task) => task.runner.table.seats.isNotEmpty);
    final beginnerTasks = lessons
        .takeWhile((lesson) => lesson.lessonId != 'blinds_action_order')
        .expand((lesson) => lesson.taskList);
    expect(tasks, hasLength(80));
    expect(
      tasks.where((task) => task.runner.table.heroSeat.seatId == 'btn'),
      hasLength(37),
    );
    expect(
      beginnerTasks.where((task) => task.runner.table.heroSeat.seatId == 'btn'),
      hasLength(29),
    );
    final repair = beginnerTasks.singleWhere(
      (task) => task.taskId == 'first_table_guide_shared_cards_repair',
    );
    expect(repair.runner.table.heroSeat.seatId, 'co');
    expect(repair.rewardXp, 0);
    expect(
      repair.runner.question,
      isNot(matches(r'\b(UTG|HJ|CO|BTN|SB|BB)\b')),
    );
  });

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
          'HJ calls 1 BB',
          'CO raises to 3 BB',
          'BTN folds',
          'SB folds',
          'BB calls 2 BB more',
          'HJ folds',
        ]);
        // Complete, explicitly owner-authored commitments: raise-to replaces CO's
        // total; BB's call adds two. HJ's dead call and SB's blind stay in the pot.
        final contributions = <String, double>{};
        for (final label in preflop) {
          final m = RegExp(
            r'^(SB|BB|HJ|CO) (blind|calls|raises to) ([\d.]+) BB',
          ).firstMatch(label);
          if (m == null) continue;
          final value = double.parse(m[3]!);
          contributions[m[1]!] = m[2] == 'raises to'
              ? value
              : (contributions[m[1]!] ?? 0) + value;
        }
        expect(contributions, {'SB': 0.5, 'BB': 3.0, 'HJ': 1.0, 'CO': 3.0});
        expect(contributions.values.fold<double>(0, (a, b) => a + b), 7.5);
        expect(
          t.seats
              .where((s) => s.isInHand && !s.isFolded)
              .map((s) => s.seatId)
              .toSet(),
          {'bb', 'co'},
        );
        final history = task.taskId.endsWith('action_trail');
        if (history) {
          expect(t.streetLabel, 'Flop');
          expect(t.boardCards.length, 3);
          expect(t.actionTrail.last.label, 'Flop: BB checks');
          final choice = task.runner.options.singleWhere((o) => o.isCorrect);
          expect(choice.id, 'bb_check');
          expect(choice.label, 'Flop: BB checks');
          for (final o in task.runner.options) {
            expect(
              '${o.label} ${o.preferredLabel} ${o.betterAnswerLabel} ${o.feedbackReason}',
              isNot(contains('CO checks')),
            );
          }
        }
        final isShowdown =
            task.taskId.endsWith('showdown') || task.taskId.endsWith('recap');
        final bb = t.seats.singleWhere((s) => s.seatId == 'bb');
        final hj = t.seats.singleWhere((s) => s.seatId == 'hj');
        expect(t.heroSeat.seatId, 'co');
        expect(hj.isFolded, isTrue);
        expect(hj.cardsVisibleMode, Act0CardsVisibleModeV1.none);
        expect(
          t.activeSeatId,
          t.streetLabel != 'Preflop' && !isShowdown ? 'co' : '',
        );
        expect(
          bb.cardsVisibleMode,
          isShowdown
              ? Act0CardsVisibleModeV1.faceUp
              : Act0CardsVisibleModeV1.faceDown,
        );
        if (isShowdown) {
          if (task.taskId == 'your_first_hand_showdown') {
            expect(t.highlightedSeatIds, ['bb']);
            expect(t.highlightedSeatIds, isNot(contains('co')));
          }
          expect(bb.holeCards.map(cardIdentity), ['Kh', 'Jh']);
          final hero = Hand.solveHand(
            [...t.heroCards, ...t.boardCards].map(cardIdentity).toList(),
          );
          final villain = Hand.solveHand(
            [...bb.holeCards, ...t.boardCards].map(cardIdentity).toList(),
          );
          expect(Hand.winners([hero, villain]), [hero]);
          for (final street in ['Flop', 'Turn', 'River']) {
            final lines = t.actionTrail
                .where((a) => a.label.startsWith('$street:'))
                .map((a) => a.label);
            expect(lines, ['$street: BB checks', '$street: CO checks']);
          }
        }
      }
    },
  );
  test('historical BB choice is the last live action before CO acts', () {
    final task = Act0ShellStateV1.sample
        .lessonById('your_first_hand')
        .taskList
        .singleWhere((t) => t.taskId == 'your_first_hand_action_trail');
    final table = task.runner.table;
    expect(table.actionTrail.last.label, 'Flop: BB checks');
    expect(
      table.actionTrail
          .where((a) => a.label.startsWith('Flop:'))
          .map((a) => a.label),
      ['Flop: BB checks'],
    );
    expect(table.activeSeatId, 'co');
    final bb = table.seats.singleWhere((s) => s.seatId == 'bb');
    expect(bb.isInHand && !bb.isFolded, isTrue);
    expect(task.runner.options.map((o) => o.id), [
      'sb_post',
      'bb_check',
      'hj_limp',
    ]);
    for (final option in task.runner.options) {
      expect(option.preferredLabel, 'Flop: BB checks');
    }
    expect(
      task.runner.options.singleWhere((o) => o.id == 'bb_check').label,
      'Flop: BB checks',
    );
  });
}

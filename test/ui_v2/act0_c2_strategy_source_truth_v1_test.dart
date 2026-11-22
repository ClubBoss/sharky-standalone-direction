import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_solver/poker_solver.dart';

import '../support/act0_pot_showdown_truth_v1.dart' show potTruthBbV1;
import '../support/act0_table_truth_v1.dart' show cardIdentity;

final _tasks = {
  for (final world in Act0ShellStateV1.sample.worlds)
    for (final lesson in world.lessons)
      for (final task in lesson.taskList) task.taskId: task,
};

double _showdownShare(Act0TableStateV1 table, String opponent) {
  final hero = table.heroCards.map(cardIdentity).toList();
  final board = table.boardCards.map(cardIdentity).toList();
  final villain = opponent.split(' ');
  final known = {...hero, ...board, ...villain};
  expect(known, hasLength(4 + board.length));
  final deck = [
    for (final rank in '23456789TJQKA'.split(''))
      for (final suit in 'cdhs'.split(''))
        if (!known.contains('$rank$suit')) '$rank$suit',
  ];
  final runouts = switch (board.length) {
    3 => [
      for (var turn = 0; turn < deck.length; turn++)
        for (var river = turn + 1; river < deck.length; river++)
          [deck[turn], deck[river]],
    ],
    4 => [
      for (final card in deck) [card],
    ],
    5 => [const <String>[]],
    _ => throw ArgumentError.value(board, 'board'),
  };
  var share = 0.0;
  for (final runout in runouts) {
    final finalBoard = [...board, ...runout];
    final heroHand = Hand.solveHand([...hero, ...finalBoard]);
    final opponentHand = Hand.solveHand([...villain, ...finalBoard]);
    final winners = Hand.winners([heroHand, opponentHand]);
    if (winners.any((hand) => identical(hand, heroHand))) {
      share += 1 / winners.length;
    }
  }
  return share / runouts.length;
}

void main() {
  test(
    'the catalog distinguishes teaching conditions and range-dependent EV',
    () {
      const boundaries = {
        'outs_improvement_w5_table_outs_flush_transfer':
            'under the stated rule',
        'outs_improvement_w5_table_outs_straight_transfer':
            'under the stated rule',
        'w6_value_range_action': 'how often BB calls or raises',
        'w6_table_value_line_transfer': 'full response range',
        'w6_bluff_candidate': 'how often BB has those hands',
        'range_checkpoint_pressure': 'how often BB has those hands',
        'w7_ajs_btn_25bb_transfer': 'CO’s full range',
        'w7_ajs_btn_100bb_transfer': 'CO’s full range',
        'w9_bubble_table_risk_transfer':
            'different raise range, set of stacks or set of prizes',
        'w10_table_value_vs_caller_transfer':
            'calls, folds or raises with each hand',
        'w11_trigger_small_price_continue': 'CO’s range and later betting',
        'w11_trigger_bad_price_fold': 'how often CO bets hands you beat',
        'w11_checkpoint_mixed_table_line': 'betting range and later action',
        'w12_pretty_hand_bad_price_fold': 'wins 5% of this river bet range',
        'w12_revenge_raise_trap': 'keeps CO\'s weak bets in',
        'w12_checkpoint_full_loop_line': 'calling keeps weak aces and draws in',
      };
      for (final MapEntry(key: id, value: boundary) in boundaries.entries) {
        final correct = _tasks[id]!.runner.options.singleWhere(
          (o) => o.isCorrect,
        );
        expect(
          correct.feedbackReason.toLowerCase(),
          contains(boundary.toLowerCase()),
          reason: id,
        );
      }
    },
  );

  test('W10 counts winning cards against a known set', () {
    final practice = _tasks['w10_outs_and_turn_price']!.runner;
    final day7 = act0NewReviewTasksV1
        .singleWhere(
          (entry) =>
              entry.task.taskId ==
              'spaced_review_w10_exploit_guardrails_pot_to_call_v1',
        )
        .task
        .runner;
    for (final (runner, hand, price, best) in [
      (practice, '9c 9d', 2 / 14.5, 'call_seven_outs'),
      (day7, '8c 8d', 8 / 26.5, 'fold'),
    ]) {
      final table = runner.table;
      final amounts = table.handContributions!.amounts(
        seatIds: table.seats.map((seat) => seat.seatId).toSet(),
        actorSeatId: table.decisionSeatId,
      );
      final call = amounts.toCallBb!;
      final actualPrice = call / (amounts.potBb + call);
      expect(actualPrice, closeTo(price, 1e-9));
      expect(_showdownShare(table, hand), closeTo(7 / 44, 1e-9));
      expect(runner.options.singleWhere((option) => option.isCorrect).id, best);
      expect(7 / 44 > actualPrice, best != 'fold');
    }
  });

  test('the same price permits opposite equity comparisons', () {
    // These are legal opponent holdings used as counterexamples. A bet does
    // not establish how often either holding is in the opponent's range.
    const cases = {
      'w11_trigger_small_price_continue': (2 / 12, 'Jc Td', 'Jc Jd'),
      'w11_trigger_bad_price_fold': (12 / 36, '6h 5h', 'Ac Ad'),
      'w11_checkpoint_mixed_table_line': (5 / 18, 'Ad 9d', '8c 8d'),
      'w12_pretty_hand_bad_price_fold': (18 / 56, 'Js Ts', 'Kc As'),
      'w12_revenge_raise_trap': (2 / 12, 'Jc Td', 'Jc Jd'),
      'w12_checkpoint_full_loop_line': (2 / 12, 'Ad 9d', '8c 8d'),
    };
    for (final MapEntry(key: id, value: (price, weak, strong))
        in cases.entries) {
      final table = _tasks[id]!.runner.table;
      final pot = potTruthBbV1(table.potLabel.replaceFirst('Pot ', ''))!;
      final call = potTruthBbV1(
        table.toCallLabel.replaceFirst('To call ', ''),
      )!;
      expect(call / (pot + call), closeTo(price, 1e-9), reason: id);
      expect(
        _showdownShare(table, weak),
        greaterThan(price),
        reason: '$id $weak',
      );
      expect(
        _showdownShare(table, strong),
        lessThan(price),
        reason: '$id $strong',
      );
    }
  });
}

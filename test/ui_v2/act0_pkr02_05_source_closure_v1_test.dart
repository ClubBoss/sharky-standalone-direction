import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_betting_price_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_street_replay_contract_v1.dart';

import 'act0_betting_price_contract_v1_test.dart'
    show pkrPriceTableV1, pkrPriceOptionV1, pkrBlindStartV1, pkrButtonOpenV1;

void main() {
  test('unsupported call-to and by units never become additional chips', () {
    final table = pkrPriceTableV1(
      trail: [...pkrButtonOpenV1, 'BTN raises 4 BB', 'SB folds'],
      hero: 'BB',
      due: '3',
    ).copyWith(potLabel: 'Pot 5.5 BB');
    for (final claim in [
      ('Call to 3 BB', ''),
      ('Call to 4 BB', ''),
      ('Call to', '3'),
      ('Call by 3 BB', ''),
      ('Shove by', '99'),
      ('Bet by', '3'),
    ]) {
      final result = act0BettingPriceForOptionV1(
        table,
        pkrPriceOptionV1(claim.$1, claim.$2),
      );
      expect(result.truth, Act0BettingPriceTruthV1.unproved, reason: claim.$1);
      expect(result.reason, 'unsupported_option_units', reason: claim.$1);
    }
    final additional = act0BettingPriceForOptionV1(
      table,
      pkrPriceOptionV1('Call', '3'),
    );
    expect(additional.truth, Act0BettingPriceTruthV1.consistent);
    expect(additional.additionalCostBb, 3);
  });

  test('typed sizing rejects unknown units instead of becoming a quiz', () {
    for (final label in ['0.5BB', '-1 BB', '1e3 BB', '50% pot', '']) {
      final option = pkrPriceOptionV1(label, '');
      final result = act0BettingPriceForOptionV1(
        pkrPriceTableV1(),
        option,
        sizingBet: true,
      );
      expect(result.appliesToWager, isTrue, reason: label);
      expect(result.truth, Act0BettingPriceTruthV1.unproved, reason: label);
      expect(
        act0BettingPriceBlocksAuthoredSuccessV1(
          pkrPriceTableV1(),
          option,
          sizingBet: true,
        ),
        isTrue,
        reason: label,
      );
    }
  });

  test('typed sizing compares both authored amount claims', () {
    final result = act0BettingPriceForOptionV1(
      pkrPriceTableV1(
        trail: [
          ...pkrButtonOpenV1,
          'BTN raises 3 BB',
          'SB folds',
          'BB calls 3 BB',
          'Flop: BB checks',
        ],
        street: 'Flop',
        due: '',
      ).copyWith(potLabel: 'Pot 6.5 BB'),
      pkrPriceOptionV1('1 BB', '0.5'),
      sizingBet: true,
    );
    expect(result.truth, Act0BettingPriceTruthV1.unproved);
    expect(result.reason, 'conflicting_option_amounts');
  });

  test(
    'source intent preserves conceptual feedback without excusing wagers',
    () {
      const taskId = 'turn_river_changes_w5_street_repair';
      final task = Act0ShellStateV1.sample.worlds
          .expand((w) => w.lessons)
          .expand((l) => l.taskList)
          .singleWhere((t) => t.taskId == taskId);
      final conceptual = task.runner.options.singleWhere(
        (o) => o.id == 'small_same_story',
      );
      expect(conceptual.isCorrect, isFalse);
      expect(
        act0BettingPriceBlocksAuthoredSuccessV1(
          task.runner.table,
          conceptual,
          taskId: taskId,
        ),
        isFalse,
      );
      expect(
        act0BettingPriceBlocksAuthoredSuccessV1(
          task.runner.table,
          conceptual,
          taskId: 'unreviewed_task',
        ),
        isTrue,
      );
      for (final mutation in [('Bet 1 BB', ''), (conceptual.label, '1 BB')]) {
        final option = Act0RunnerOptionV1(
          id: conceptual.id,
          label: mutation.$1,
          amountLabel: mutation.$2,
          isCorrect: conceptual.isCorrect,
          preferredLabel: conceptual.preferredLabel,
          quality: conceptual.quality,
          feedbackTitle: conceptual.feedbackTitle,
          feedbackReason: conceptual.feedbackReason,
        );
        expect(
          act0BettingPriceBlocksAuthoredSuccessV1(
            task.runner.table,
            option,
            taskId: taskId,
          ),
          isTrue,
        );
      }
    },
  );

  test('the actual Hero-call alternative cannot bypass incomplete source', () {
    final task = Act0ShellStateV1.sample.worlds
        .expand((w) => w.lessons)
        .expand((l) => l.taskList)
        .singleWhere((t) => t.taskId == 'w12_pretty_hand_bad_price_fold');
    for (final option in task.runner.options) {
      expect(
        act0BettingPriceBlocksAuthoredSuccessV1(
          task.runner.table,
          option,
          taskId: task.taskId,
        ),
        isTrue,
        reason: option.id,
      );
    }
  });

  test(
    'complete authored ASM05 hands prove both legal calls independently of grade',
    () {
      final tasks = Act0ShellStateV1.sample.worlds
          .expand((w) => w.lessons)
          .expand((l) => l.taskList);
      for (final amount in [10, 40]) {
        final task = tasks.singleWhere(
          (t) => t.taskId == 'asm05_new_known_holes_turn_call_$amount',
        );
        final call = task.runner.options.singleWhere((o) => o.label == 'Call');
        // 20 + 20 preflop, check/check flop, then 10 or 40 on the turn.
        // Expected legality is independent of the intentionally wrong Call 40.
        expect(
          act0BettingRoundOrderTruthForTableV1(task.runner.table),
          Act0BettingRoundOrderTruthV1.consistent,
        );
        final price = act0BettingPriceForOptionV1(task.runner.table, call);
        expect(price.truth, Act0BettingPriceTruthV1.consistent);
        expect(price.callCostBb, amount);
        expect(price.additionalCostBb, amount);
        expect(price.potBeforeActionBb, 40 + amount);
        expect(price.sourceReady, isTrue);
        expect(call.isCorrect, amount == 10);
      }
    },
  );

  test(
    'an incomplete wager source cannot grant success or penalize a distractor',
    () {
      final partial = pkrPriceTableV1(trail: ['CO raises 2 BB']);
      for (final correct in [true, false]) {
        expect(
          act0BettingPriceBlocksAuthoredSuccessV1(
            partial,
            pkrPriceOptionV1('Call', '1', correct: correct),
          ),
          isTrue,
        );
      }
    },
  );

  test('bank claim is checked against actual contributions', () {
    final table = pkrPriceTableV1().copyWith(potLabel: 'Pot 99 BB');
    final result = act0BettingPriceForOptionV1(
      table,
      pkrPriceOptionV1('Call', '1'),
    );
    expect(result.truth, Act0BettingPriceTruthV1.contradiction);
    expect(result.reason, 'pot_mismatch');
  });

  test('explicit terminal decision marker moves no chips', () {
    final table = pkrPriceTableV1(
      trail: [...pkrButtonOpenV1, 'Hero acts'],
    ).copyWith(potLabel: 'Pot 1.5 BB');
    expect(
      act0BettingPriceForOptionV1(
        table,
        pkrPriceOptionV1('Raise to', '2'),
      ).truth,
      Act0BettingPriceTruthV1.consistent,
    );
  });

  test('bare Call uses the source cost without inventing a wager amount', () {
    final table = pkrPriceTableV1().copyWith(potLabel: 'Pot 1.5 BB');
    expect(
      act0BettingPriceForOptionV1(table, pkrPriceOptionV1('Call', '')).truth,
      Act0BettingPriceTruthV1.consistent,
    );
  });

  test('a player cannot raise against only all-in opponents', () {
    final table = pkrPriceTableV1(
      trail: [
        ...pkrBlindStartV1,
        'UTG shoves 3 BB',
        'HJ folds',
        'CO folds',
        'BTN folds',
        'SB folds',
      ],
      hero: 'BB',
      due: '2',
      stacks: {'UTG': '0 BB'},
    ).copyWith(potLabel: 'Pot 4.5 BB');
    final result = act0BettingPriceForOptionV1(
      table,
      pkrPriceOptionV1('Raise to', '5'),
    );
    expect(result.truth, Act0BettingPriceTruthV1.contradiction);
    expect(result.reason, 'no_opponent_can_call_raise');
    expect(
      act0BettingPriceForOptionV1(table, pkrPriceOptionV1('Call', '2')).truth,
      Act0BettingPriceTruthV1.consistent,
    );
  });

  test(
    'raise-to, raise increment and actual chips paid are different units',
    () {
      final table = pkrPriceTableV1(
        trail: [...pkrButtonOpenV1, 'BTN raises 3 BB', 'SB folds'],
        hero: 'BB',
        due: '2',
      ).copyWith(potLabel: 'Pot 4.5 BB');
      for (final option in [
        pkrPriceOptionV1('Raise to', '5'),
        pkrPriceOptionV1('Raise by', '2'),
        pkrPriceOptionV1(' Raise by', '2'),
        pkrPriceOptionV1('Raise  by 2 BB', ''),
      ]) {
        final result = act0BettingPriceForOptionV1(table, option);
        expect(result.truth, Act0BettingPriceTruthV1.consistent);
        expect(result.actorCommittedBb, 1);
        expect(result.minimumRaiseToBb, 5);
        expect(result.additionalCostBb, 4);
        expect(result.potBeforeActionBb, 4.5);
      }
      expect(
        act0BettingPriceForOptionV1(
          table,
          pkrPriceOptionV1('Raise more', '2'),
        ).truth,
        Act0BettingPriceTruthV1.unproved,
      );
    },
  );

  test(
    'short opening requires a full raise increment and respects the checker',
    () {
      const preflop = [
        ...pkrButtonOpenV1,
        'BTN raises 3 BB',
        'SB calls 3 BB',
        'BB calls 3 BB',
      ];
      final unacted = pkrPriceTableV1(
        trail: [...preflop, 'Flop: SB shoves 0.5 BB', 'BB calls 0.5 BB'],
        street: 'Flop',
        due: '0.5',
        stacks: {'SB': '0 BB'},
      ).copyWith(potLabel: 'Pot 10 BB');
      final legal = act0BettingPriceForOptionV1(
        unacted,
        pkrPriceOptionV1('Raise to', '1.5'),
      );
      expect(legal.truth, Act0BettingPriceTruthV1.consistent);
      expect(legal.minimumRaiseToBb, 1.5);
      expect(
        act0BettingPriceForOptionV1(
          unacted,
          pkrPriceOptionV1('Raise to', '1'),
        ).truth,
        Act0BettingPriceTruthV1.contradiction,
      );
      final checked = pkrPriceTableV1(
        trail: [
          ...preflop,
          'Flop: SB checks',
          'BB shoves 0.5 BB',
          'BTN calls 0.5 BB',
        ],
        street: 'Flop',
        hero: 'SB',
        due: '0.5',
        stacks: {'BB': '0 BB'},
      ).copyWith(potLabel: 'Pot 10 BB');
      expect(
        act0BettingPriceForOptionV1(
          checked,
          pkrPriceOptionV1('Raise to', '1.5'),
        ).reason,
        'raise_not_reopened',
      );
      expect(
        act0BettingPriceForOptionV1(
          checked,
          pkrPriceOptionV1('Call', '0.5'),
        ).truth,
        Act0BettingPriceTruthV1.consistent,
      );
    },
  );

  test(
    'typed sizing validates bare amounts while numeric quizzes remain quizzes',
    () {
      final table = pkrPriceTableV1(
        trail: [
          ...pkrButtonOpenV1,
          'BTN raises 3 BB',
          'SB folds',
          'BB calls 3 BB',
          'Flop: BB checks',
        ],
        street: 'Flop',
        due: '',
      ).copyWith(potLabel: 'Pot 6.5 BB');
      final legal = pkrPriceOptionV1('1 BB', '');
      final illegal = pkrPriceOptionV1('0.5 BB', '');
      expect(act0BettingPriceForOptionV1(table, legal).appliesToWager, isFalse);
      expect(
        act0BettingPriceForOptionV1(table, legal, sizingBet: true).truth,
        Act0BettingPriceTruthV1.consistent,
      );
      expect(
        act0BettingPriceBlocksAuthoredSuccessV1(
          table,
          illegal,
          sizingBet: true,
        ),
        isTrue,
      );
    },
  );

  test(
    'malformed embedded units and conflicting amount claims never certify',
    () {
      final table = pkrPriceTableV1().copyWith(potLabel: 'Pot 1.5 BB');
      for (final label in [
        'Call -1 BB',
        'Call 1e3 BB',
        'Call 1,000 BB',
        'Call 1.0000001 BB',
      ]) {
        expect(
          act0BettingPriceForOptionV1(table, pkrPriceOptionV1(label, '')).truth,
          Act0BettingPriceTruthV1.unproved,
          reason: label,
        );
        expect(
          act0BettingPriceBlocksAuthoredSuccessV1(
            table,
            pkrPriceOptionV1(label, ''),
          ),
          isTrue,
        );
      }
      expect(
        act0BettingPriceForOptionV1(
          table,
          pkrPriceOptionV1('Call 2 BB', '1'),
        ).reason,
        'conflicting_option_amounts',
      );
    },
  );
  test(
    'two exact W1 action definitions teach without imaginary bet history',
    () {
      final tasks = Act0ShellStateV1.sample.worlds
          .expand((world) => world.lessons)
          .expand((lesson) => lesson.taskList)
          .toList();
      for (final taskId in ['actions_legal_context', 'actions_check_drill']) {
        final task = tasks.singleWhere((item) => item.taskId == taskId);
        expect(task.runner.table.scope, Act0TableScopeV1.playedHand);
        expect(task.runner.table.actionTrail, isEmpty);
        expect(task.runner.table.toCallLabel, isEmpty);
        expect(task.runner.table.potLabel, 'Pot 3 BB');
        expect(task.runner.options.map((option) => option.id).toSet(), {
          'fold',
          'check',
          'call',
        });
        for (final option in task.runner.options) {
          expect(option.amountLabel, isEmpty);
          final safe = act0BettingPriceForOptionV1(
            task.runner.table,
            option,
            taskId: taskId,
            question: task.runner.question,
          );
          expect(safe.reason, 'source_action_definition');
          expect(safe.appliesToWager, isFalse);
          expect(
            act0BettingPriceBlocksAuthoredSuccessV1(
              task.runner.table,
              option,
              taskId: taskId,
              question: task.runner.question,
            ),
            isFalse,
          );
          // An edited or contradictory question is not grandfathered into the
          // source-only exemption merely because its task ID stays the same.
          expect(
            act0BettingPriceBlocksAuthoredSuccessV1(
              task.runner.table,
              option,
              taskId: taskId,
              question: 'Now face a real 2 BB bet.',
            ),
            isTrue,
          );
        }
        // If the task becomes an actual actor-bound scene, missing history
        // cannot be ignored even if the old question/choice copy remains.
        expect(
          act0BettingPriceBlocksAuthoredSuccessV1(
            task.runner.table.copyWith(activeSeatId: 'btn', heroSeatId: 'btn'),
            task.runner.options.singleWhere((o) => o.id == 'check'),
            taskId: taskId,
            question: task.runner.question,
          ),
          isTrue,
        );
        // Numeric execution must not opt out of source price/stack proof.
        expect(
          act0BettingPriceBlocksAuthoredSuccessV1(
            task.runner.table,
            pkrPriceOptionV1('Call', '2'),
            taskId: taskId,
            question: task.runner.question,
          ),
          isTrue,
        );
        expect(
          task.runner.options.singleWhere((o) => o.id == 'check').isCorrect,
          isTrue,
        );
      }
    },
  );
  test(
    'terminal Hero acts identifies a unique pending actor only when no projection is present',
    () {
      final complete = pkrPriceTableV1(
        trail: [...pkrButtonOpenV1, 'Hero acts'],
      );
      final missingProjection = complete.copyWith(activeSeatId: '');
      final legal = act0BettingPriceForOptionV1(
        missingProjection,
        pkrPriceOptionV1('Raise to', '3'),
      );
      expect(legal.truth, Act0BettingPriceTruthV1.consistent);
      expect(legal.reason, 'numeric_action_consistent');
      expect(legal.potBeforeActionBb, 1.5);
      expect(legal.minimumRaiseToBb, 2);
      expect(
        act0BettingPriceBlocksAuthoredSuccessV1(
          missingProjection,
          pkrPriceOptionV1('Raise to', '3'),
        ),
        isFalse,
      );
      final illegal = act0BettingPriceForOptionV1(
        missingProjection,
        pkrPriceOptionV1('Raise to', '1.5'),
      );
      expect(illegal.truth, Act0BettingPriceTruthV1.contradiction);
      expect(illegal.reason, 'wager_below_minimum');

      // A missing, nonterminal, or conflicting actor is never supplied by
      // merely selecting the unique hero seat in the table.
      for (final withoutMarker in [
        pkrPriceTableV1().copyWith(activeSeatId: ''),
        pkrPriceTableV1(
          trail: [...pkrButtonOpenV1, 'Hero checks'],
        ).copyWith(activeSeatId: ''),
      ]) {
        expect(
          act0BettingPriceForOptionV1(
            withoutMarker,
            pkrPriceOptionV1('Raise to', '3'),
          ).reason,
          'missing_active_actor',
        );
      }
      expect(
        act0BettingPriceForOptionV1(
          missingProjection.copyWith(heroSeatId: 'bb'),
          pkrPriceOptionV1('Raise to', '3'),
        ).reason,
        'missing_active_actor',
      );
      expect(
        act0BettingPriceForOptionV1(
          missingProjection.copyWith(activeSeatId: 'co'),
          pkrPriceOptionV1('Raise to', '3'),
        ).reason,
        'not_hero_action',
      );
    },
  );

  test('W4 explicit terminal hero is recovered but missing history stays held', () {
    final task = Act0ShellStateV1.sample.worlds
        .expand((world) => world.lessons)
        .expand((lesson) => lesson.taskList)
        .singleWhere((item) => item.taskId == 'w4_good_price_call');
    final call = task.runner.options.singleWhere((option) => option.id == 'call');
    expect(task.runner.table.activeSeatId, isNull);
    expect(task.runner.table.actionTrail.last.label, 'Hero acts');
    final result = act0BettingPriceForOptionV1(task.runner.table, call);
    expect(result.truth, Act0BettingPriceTruthV1.unproved);
    expect(result.reason, 'missing_blind_start');
    expect(result.sourceReady, isFalse);
    expect(
      act0BettingPriceBlocksAuthoredSuccessV1(task.runner.table, call),
      isTrue,
    );
  });

}

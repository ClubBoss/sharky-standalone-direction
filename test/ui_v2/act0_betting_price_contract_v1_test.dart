// Independent numeric vectors use ordinary 0.5/1 BB NLHE, no ante/rake.
// Poker TDA current rules 45/49 (2026): full raise increment and per-player
// reopening; https://www.pokertda.com/view-poker-tda-rules/ .
// Synthetic vectors are not catalog, native, source-authority or Human proof.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_betting_price_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

const pkrBlindStartV1 = <String>['SB blind 0.5 BB', 'BB blind 1 BB'];
const pkrButtonOpenV1 = <String>[
  ...pkrBlindStartV1,
  'UTG folds',
  'HJ folds',
  'CO folds',
];
const pkrFlopV1 = <String>[
  ...pkrButtonOpenV1,
  'BTN raises 3 BB',
  'SB folds',
  'BB calls 3 BB',
];

Act0TableStateV1 pkrPriceTableV1({
  List<String> trail = pkrButtonOpenV1,
  String street = 'Preflop',
  String hero = 'BTN',
  String due = '1',
  String? heroStack = '100 BB',
  Map<String, String?> stacks = const {},
  Act0TableScopeV1 scope = Act0TableScopeV1.playedHand,
}) {
  final folded = <String>{
    for (final label in trail)
      if (label.endsWith(' folds')) label.split(' ').first,
  };
  return Act0TableStateV1(
    scope: scope,
    tableFormat: Act0TableFormatV1.sixMax,
    playerCount: 6,
    seats: [
      for (final position in const ['UTG', 'HJ', 'CO', 'BTN', 'SB', 'BB'])
        Act0SeatStateV1(
          seatId: position.toLowerCase(),
          seatLabel: position,
          displayName: position == hero ? 'Hero' : position,
          isHero: position == hero,
          isActive: position == hero,
          isDealerButton: position == 'BTN',
          isSmallBlind: position == 'SB',
          isBigBlind: position == 'BB',
          isInHand: !folded.contains(position),
          isFolded: folded.contains(position),
          stackLabel: stacks.containsKey(position)
              ? stacks[position]
              : position == hero
              ? heroStack
              : '100 BB',
        ),
    ],
    heroCards: const [],
    boardCards: const [],
    streetLabel: street,
    potLabel: 'Pot 8.5 BB',
    toCallLabel: due.isEmpty ? '' : 'To call $due BB',
    centerLabel: 'Synthetic complete source price fixture',
    actionTrail: [
      for (final label in trail) Act0ActionTrailItemV1(label: label),
    ],
    activeSeatId: hero.toLowerCase(),
    heroSeatId: hero.toLowerCase(),
    highlightedSeatIds: const [],
    highlightedCardIds: const [],
  );
}

Act0RunnerOptionV1 pkrPriceOptionV1(
  String action,
  String amount, {
  bool correct = true,
}) => Act0RunnerOptionV1(
  id: action.toLowerCase().replaceAll(' ', '_'),
  label: action,
  amountLabel: amount.isEmpty ? '' : '$amount BB',
  isCorrect: correct,
  preferredLabel: action,
  quality: correct
      ? Act0FeedbackQualityV1.correct
      : Act0FeedbackQualityV1.wrong,
  feedbackTitle: 'Authored fixture result',
  feedbackReason: 'Synthetic fixture.',
);

void main() {
  const good = Act0BettingPriceTruthV1.consistent;
  const bad = Act0BettingPriceTruthV1.contradiction;
  const unknown = Act0BettingPriceTruthV1.unproved;
  Act0BettingPriceResultV1 run(Act0TableStateV1 t, String a, String n) =>
      act0BettingPriceForOptionV1(t, pkrPriceOptionV1(a, n));

  test(
    'explicit call display remains verified and wrong display contradicted',
    () {
      final table = pkrPriceTableV1();
      expect(run(table, 'Call', '1').truth, good);
      expect(
        act0BettingPriceBlocksAuthoredSuccessV1(
          table,
          pkrPriceOptionV1('Call', '1'),
        ),
        isFalse,
      );
      final mismatch = run(
        table.copyWith(toCallLabel: 'To call 2 BB'),
        'Call',
        '1',
      );
      expect(mismatch.truth, bad);
      expect(mismatch.reason, 'display_price_mismatch');
    },
  );

  test('missing positive display is unproved without denying a legal call', () {
    for (final display in ['', '   ']) {
      final table = pkrPriceTableV1().copyWith(toCallLabel: display);
      final result = run(table, 'Call', '1');
      expect(result.truth, unknown);
      expect(result.reason, 'missing_display_price');
      expect(result.amountToMatchBb, 1);
      expect(result.callCostBb, 1);
      expect(
        act0BettingPriceBlocksAuthoredSuccessV1(
          table,
          pkrPriceOptionV1('Call', '1'),
        ),
        isFalse,
      );
      final wrong = run(table, 'Call', '1.5');
      expect(wrong.truth, bad);
      expect(wrong.reason, 'call_cost_mismatch');
      expect(
        act0BettingPriceBlocksAuthoredSuccessV1(
          table,
          pkrPriceOptionV1('Call', '1.5'),
        ),
        isTrue,
      );
      expect(
        act0BettingPriceBlocksAuthoredSuccessV1(
          table,
          pkrPriceOptionV1('Call', '1.5', correct: false),
        ),
        isFalse,
      );
    }
  });

  test('empty display at zero due keeps the ordinary legal bet', () {
    final table = pkrPriceTableV1(
      trail: [...pkrFlopV1, 'Flop: BB checks'],
      street: 'Flop',
      due: '',
    );
    final empty = run(table, 'Bet', '1');
    final explicitZero = run(
      table.copyWith(toCallLabel: 'To call 0 BB'),
      'Bet',
      '1',
    );
    expect(empty.truth, good);
    expect(explicitZero.truth, good);
    expect(empty.reason, explicitZero.reason);
    expect(empty.amountToMatchBb, 0);
    expect(empty.reason, isNot('missing_display_price'));
  });

  test('missing earlier streets cannot prove a source contradiction', () {
    for (final probe in <(List<String>, String)>[
      (['Flop: BB checks'], 'Flop'),
      (['SB blind 0.5 BB', 'Flop: BB checks'], 'Flop'),
      ([...pkrBlindStartV1, 'Turn: BB checks'], 'Turn'),
    ]) {
      final table = pkrPriceTableV1(trail: probe.$1, street: probe.$2, due: '');
      expect(
        run(table, 'Bet', '1').truth,
        unknown,
        reason: probe.$1.join(', '),
      );
      expect(
        act0BettingPriceBlocksAuthoredSuccessV1(
          table,
          pkrPriceOptionV1('Bet', '1'),
        ),
        isFalse,
      );
    }
    // A supplied backwards street is a contradiction, not a missing prefix.
    final backwards = pkrPriceTableV1(
      trail: [
        ...pkrFlopV1,
        'Flop: BB checks',
        'Turn: BB checks',
        'Flop: BB checks',
      ],
      street: 'Flop',
      due: '',
    );
    expect(run(backwards, 'Bet', '1').truth, bad);
    expect(run(backwards, 'Bet', '1').reason, 'street_order');
  });

  test('ordinary opening minimum: 2 BB, not 1.5 BB', () {
    final table = pkrPriceTableV1();
    expect(run(table, 'Raise to', '2').truth, good);
    expect(run(table, 'Raise to', '1.5').reason, 'wager_below_minimum');
    expect(run(table, 'Raise to', '1.5').truth, bad);
    expect(run(table, 'Raise to', '2').minimumRaiseToBb, 2);
  });
  test('ordinary postflop bet minimum: 1 BB, not 0.5 BB', () {
    final table = pkrPriceTableV1(
      trail: [...pkrFlopV1, 'Flop: BB checks'],
      street: 'Flop',
      due: '',
    );
    expect(run(table, 'Bet', '1').truth, good);
    expect(run(table, 'Bet', '0.5').truth, bad);
  });
  test(
    'call amount comes from history, never false display or keyed answer',
    () {
      final table = pkrPriceTableV1(
        trail: [...pkrFlopV1, 'Flop: BB bets 2 BB'],
        street: 'Flop',
        due: '2',
      );
      expect(run(table, 'Call', '2').truth, good);
      expect(run(table, 'Call', '1').reason, 'call_cost_mismatch');
      expect(
        run(table.copyWith(toCallLabel: 'To call 1 BB'), 'Call', '1').truth,
        bad,
      );
      expect(
        run(table.copyWith(toCallLabel: 'To call 1 BB'), 'Call', '2').reason,
        'display_price_mismatch',
      );
    },
  );
  test('call subtracts an existing blind, raise amount remains a total', () {
    final table = pkrPriceTableV1(
      trail: [...pkrButtonOpenV1, 'BTN raises 3 BB', 'SB folds'],
      hero: 'BB',
      due: '2',
    );
    expect(run(table, 'Call', '2').truth, good);
    expect(run(table, 'Call', '3').truth, bad);
    expect(run(table, 'Raise to', '5').truth, good);
    expect(run(table, 'Raise to', '4').truth, bad);
    expect(run(table, 'Raise to', '5').actorCommittedBb, 1);
  });
  test('additional trail call does not double-count the posted blind', () {
    final table = pkrPriceTableV1(
      trail: [
        ...pkrButtonOpenV1,
        'BTN raises to 3 BB',
        'SB folds',
        'BB calls 2 BB more',
        'Flop: BB bets 2 BB',
      ],
      street: 'Flop',
      due: '2',
    );
    expect(run(table, 'Call', '2').truth, good);
  });
  test('last full increment controls re-raise, not two times current bet', () {
    final table = pkrPriceTableV1(
      trail: [
        ...pkrButtonOpenV1,
        'BTN raises 3 BB',
        'SB raises 7 BB',
        'BB folds',
      ],
      due: '4',
    );
    expect(run(table, 'Raise to', '11').truth, good);
    expect(run(table, 'Raise to', '10.5').truth, bad);
    expect(run(table, 'Call', '4').truth, good);
  });
  test('decimal boundary uses exact units', () {
    final table = pkrPriceTableV1(
      trail: [
        ...pkrButtonOpenV1,
        'BTN raises 2.75 BB',
        'SB raises 4.5 BB',
        'BB folds',
      ],
      due: '1.75',
    );
    expect(run(table, 'Raise to', '6.25').truth, good);
    expect(run(table, 'Raise to', '6.249999').truth, bad);
  });
  test('legal short all-in opening raise is not blocked', () {
    final table = pkrPriceTableV1(heroStack: '1.5 BB');
    expect(run(table, 'Raise to', '1.5').truth, good);
    expect(run(table, 'Shove to', '1.5').truth, good);
    expect(run(table, 'Raise to', '1.4').truth, bad);
  });
  test('legal short all-in opening bet is not blocked', () {
    final table = pkrPriceTableV1(
      trail: [...pkrFlopV1, 'Flop: BB checks'],
      street: 'Flop',
      due: '',
      heroStack: '0.5 BB',
    );
    expect(run(table, 'Bet', '0.5').truth, good);
    expect(run(table, 'Bet', '1').reason, 'wager_exceeds_stack');
  });
  test('legal short all-in call is capped by remaining chips', () {
    final table = pkrPriceTableV1(
      trail: [...pkrFlopV1, 'Flop: BB bets 2 BB'],
      street: 'Flop',
      due: '2',
      heroStack: '0.5 BB',
    );
    expect(run(table, 'Call', '0.5').truth, good);
    expect(run(table, 'Call', '0.5').callCostBb, 0.5);
    expect(run(table, 'Call', '0.5').amountToMatchBb, 2);
    expect(
      run(table.copyWith(toCallLabel: 'To call 0.5 BB'), 'Call', '0.5').truth,
      good,
    );
    expect(run(table, 'Shove to', '0.5').truth, good);
    expect(run(table, 'Call', '2').truth, bad);
  });
  test('all-in uses remaining plus existing street commitment', () {
    final table = pkrPriceTableV1(
      trail: [...pkrButtonOpenV1, 'BTN raises 3 BB', 'SB folds'],
      hero: 'BB',
      due: '2',
      heroStack: '0.5 BB',
    );
    expect(run(table, 'Shove to', '1.5').truth, good);
    expect(run(table, 'Shove to', '0.5').truth, bad);
    expect(run(table, 'Call', '0.5').truth, good);
  });
  test('a short all-in does not reopen a prior actor', () {
    final table = pkrPriceTableV1(
      trail: [
        ...pkrBlindStartV1,
        'UTG raises 3 BB',
        'HJ shoves to 4 BB',
        'CO folds',
        'BTN folds',
        'SB folds',
        'BB folds',
      ],
      hero: 'UTG',
      due: '1',
      stacks: {'HJ': '0 BB'},
    );
    expect(run(table, 'Raise to', '6').reason, 'raise_not_reopened');
    expect(run(table, 'Raise to', '6').truth, bad);
    // Existing PKR-03 order verifier does not certify all-in history, so a
    // price-consistent call stays UNPROVED, never a new full-hand PASS.
    expect(run(table, 'Call', '1').truth, unknown);
  });
  test('cumulative short all-ins reopen per player at a full increment', () {
    final table = pkrPriceTableV1(
      trail: [
        ...pkrBlindStartV1,
        'UTG raises 3 BB',
        'HJ shoves to 4 BB',
        'CO shoves to 5 BB',
        'BTN folds',
        'SB folds',
        'BB folds',
      ],
      hero: 'UTG',
      due: '2',
      stacks: {'HJ': '0 BB', 'CO': '0 BB'},
    );
    expect(run(table, 'Raise to', '7').isContradiction, isFalse);
    expect(run(table, 'Raise to', '6').reason, 'wager_below_minimum');
    expect(run(table, 'Raise to', '7').minimumRaiseToBb, 7);
  });
  test('a caller of the short raise has a different reopening threshold', () {
    final table = pkrPriceTableV1(
      trail: [
        ...pkrBlindStartV1,
        'UTG raises 3 BB',
        'HJ shoves to 4 BB',
        'CO calls 4 BB',
        'BTN shoves to 5 BB',
        'SB folds',
        'BB folds',
        'UTG calls 5 BB',
      ],
      hero: 'CO',
      due: '1',
      stacks: {'HJ': '0 BB', 'BTN': '0 BB'},
    );
    expect(run(table, 'Raise to', '7').reason, 'raise_not_reopened');
  });
  test('an unacted player may make a full raise over a short all-in', () {
    final table = pkrPriceTableV1(
      trail: [...pkrBlindStartV1, 'UTG raises 3 BB', 'HJ shoves to 4 BB'],
      hero: 'CO',
      due: '4',
      stacks: {'HJ': '0 BB'},
    );
    expect(run(table, 'Raise to', '6').isContradiction, isFalse);
    expect(run(table, 'Raise to', '5').truth, bad);
  });
  test('short opening completion and unsupported grammar stay unproved', () {
    final short = pkrPriceTableV1(
      trail: [...pkrFlopV1, 'Flop: BB shoves to 0.5 BB'],
      street: 'Flop',
      due: '0.5',
      stacks: {'BB': '0 BB'},
    );
    expect(run(short, 'Raise to', '1').truth, unknown);
    expect(run(short, 'Raise to', '1').minimumRaiseToBb, isNull);
    final partial = pkrPriceTableV1(trail: ['CO raises 2 BB']);
    expect(run(partial, 'Raise to', '3').truth, unknown);
    expect(
      run(
        pkrPriceTableV1(trail: [...pkrButtonOpenV1, 'Unknown source']),
        'Raise to',
        '2',
      ).truth,
      unknown,
    );
  });
  test(
    'sparse stacks cannot turn a legal short all-in into an illegal wager',
    () {
      expect(
        run(pkrPriceTableV1(heroStack: null), 'Raise to', '1.5').truth,
        unknown,
      );
      final table = pkrPriceTableV1(
        trail: [...pkrFlopV1, 'Flop: BB bets 2 BB'],
        street: 'Flop',
        due: '2',
        heroStack: null,
      );
      expect(run(table, 'Call', '1').truth, unknown);
      expect(run(table, 'Call', '3').truth, bad);
    },
  );
  test(
    'diagram, nonnumeric instruction, unknown unit and missing actor are unproved',
    () {
      expect(
        run(
          pkrPriceTableV1(scope: Act0TableScopeV1.explanation),
          'Raise to',
          '1',
        ).truth,
        unknown,
      );
      expect(
        run(
          pkrPriceTableV1(scope: Act0TableScopeV1.explanation),
          'Call',
          '0',
        ).truth,
        unknown,
      );
      expect(
        run(pkrPriceTableV1(), 'Which player raises?', '1').truth,
        unknown,
      );
      expect(run(pkrPriceTableV1(), 'Raise by', '2').truth, unknown);
      expect(run(pkrPriceTableV1(), 'Raise to', '').truth, unknown);
      expect(
        run(
          pkrPriceTableV1().copyWith(activeSeatId: ''),
          'Raise to',
          '2',
        ).truth,
        unknown,
      );
    },
  );
  test(
    'authored error guard does not punish an intentional wrong distractor',
    () {
      final table = pkrPriceTableV1();
      expect(
        act0BettingPriceBlocksAuthoredSuccessV1(
          table,
          pkrPriceOptionV1('Raise to', '1.5'),
        ),
        isTrue,
      );
      expect(
        act0BettingPriceBlocksAuthoredSuccessV1(
          table,
          pkrPriceOptionV1('Raise to', '1.5', correct: false),
        ),
        isFalse,
      );
    },
  );
  test(
    'write all-catalog numeric action applicability without promoting unknowns',
    () {
      final rows = <Map<String, Object?>>[];
      var tasks = 0;
      for (final world in Act0ShellStateV1.sample.worlds) {
        for (final lesson in world.lessons) {
          for (final task in lesson.taskList) {
            tasks++;
            for (final option in task.runner.options) {
              if (!RegExp(
                    r'^(call|bet|raise|shove|jam)\b',
                    caseSensitive: false,
                  ).hasMatch(option.label.trim()) ||
                  option.amountLabel.trim().isEmpty)
                continue;
              final result = act0BettingPriceForOptionV1(
                task.runner.table,
                option,
              );
              rows.add({
                'task': task.taskId,
                'option': option.id,
                'label': option.label,
                'amount': option.amountLabel,
                'sourceCorrect': option.isCorrect,
                'sourceQuality': option.quality.name,
                'truth': result.truth.name,
                'reason': result.reason,
                'callCostBb': result.callCostBb,
                'minimumRaiseToBb': result.minimumRaiseToBb,
                'blockAuthoredSuccess': act0BettingPriceBlocksAuthoredSuccessV1(
                  task.runner.table,
                  option,
                ),
              });
            }
          }
        }
      }
      expect(tasks, 367);
      expect(rows, isNotEmpty);
      final output = File(
        'output/pkr02-05-price-truth-20261107/catalog-price-applicability.json',
      );
      output.parent.createSync(recursive: true);
      output.writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert({
          'evidence': 'source-machine census, not acceptance',
          'tasks': tasks,
          'rows': rows,
          'limits':
              'Base task tables only. No Human/native/derived feedback/repair/source fact invention. UNPROVED is not legal proof.',
        }),
      );
    },
  );
}

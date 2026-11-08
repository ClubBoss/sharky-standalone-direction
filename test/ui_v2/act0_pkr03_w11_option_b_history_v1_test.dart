// PKR-03 W11 option B: full trigger-hand history with antes, blinds, folds
// and the sized 2.5 BB call, plus the playback pot that counts the ante once.
//
// The displayed pot is always computed by the Runner calculator
// (act0CalcTableTrailPotV1) from the State trail, and cross-checked step by
// step against an independent ledger. Neither side reads an expected number.
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_street_replay_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_table_choreography_contract_v1.dart';

import 'act0_pkr03_w11_option_b_history_v1.dart';

const _small = 'w11_trigger_small_price_continue';
const _bad = 'w11_trigger_bad_price_fold';
const _preflopOrder = ['UTG', 'HJ', 'CO', 'BTN', 'SB', 'BB'];
const _postflopOrder = ['SB', 'BB', 'UTG', 'HJ', 'CO', 'BTN'];
const _streets = ['Preflop', 'Flop', 'Turn', 'River'];

Act0RunnerStateV1 _runner(String taskId) {
  for (final w in Act0ShellStateV1.sample.worlds) {
    for (final l in w.lessons) {
      for (final t in l.taskList) {
        if (t.taskId == taskId) return t.runner;
      }
    }
  }
  throw StateError('missing $taskId');
}

double _bb(String label) =>
    double.parse(RegExp(r'(\d+(?:\.\d+)?)\s*BB').firstMatch(label)!.group(1)!);

class _LedgerError implements Exception {
  _LedgerError(this.reason);
  final String reason;
  @override
  String toString() => reason;
}

/// Independent hold'em ledger: order, price, closure, pot and stacks.
class _Ledger {
  String street = 'Preflop';
  double potBeforeStreet = 0;
  final commit = <String, double>{};
  final total = <String, double>{};
  final live = {..._preflopOrder};
  final acted = <String>{};
  double price = 0;
  String? last;
  int posts = 0;
  bool anteSeen = false;
  bool handOver = false;

  /// Everything in the middle now: antes, closed streets, current bets.
  double get pot => potBeforeStreet + commit.values.fold(0.0, (a, b) => a + b);
  List<String> get order =>
      street == 'Preflop' ? _preflopOrder : _postflopOrder;
  double c(String s) => commit[s] ?? 0;

  void _put(String seat, double to) {
    total[seat] = (total[seat] ?? 0) + to - c(seat);
    commit[seat] = to;
  }

  String? next() {
    if (live.length < 2) return null;
    final o = order;
    final start = last == null
        ? (street == 'Preflop' ? o.indexOf('BB') : o.length - 1)
        : o.indexOf(last!);
    for (var k = 1; k <= o.length; k++) {
      final s = o[(start + k) % o.length];
      if (!live.contains(s)) continue;
      if (!acted.contains(s) || c(s) < price) return s;
    }
    return null;
  }

  void apply(W11StepV1 step) {
    if (handOver) throw _LedgerError('action_after_hand_over');
    if (step.street != street) {
      if (_streets.indexOf(step.street) != _streets.indexOf(street) + 1) {
        throw _LedgerError('street_skipped_or_backwards');
      }
      if (next() != null) throw _LedgerError('round_not_closed:${next()}');
      potBeforeStreet = pot;
      commit.clear();
      acted.clear();
      price = 0;
      last = null;
      street = step.street;
    }
    switch (step.verb) {
      case W11VerbV1.ante:
        if (anteSeen || posts > 0) throw _LedgerError('ante_not_once_first');
        anteSeen = true;
        for (final s in _preflopOrder) {
          total[s] = (total[s] ?? 0) + step.to!;
          potBeforeStreet += step.to!;
        }
        return;
      case W11VerbV1.post:
        final expected = posts == 0 ? 'SB' : 'BB';
        if (street != 'Preflop' || step.seat != expected || posts > 1) {
          throw _LedgerError('blind_out_of_order');
        }
        posts++;
        _put(step.seat, step.to!);
        if (step.to! > price) price = step.to!;
        return;
      default:
        break;
    }
    if (street == 'Preflop' && posts < 2) throw _LedgerError('no_blinds');
    final expected = next();
    if (expected == null) throw _LedgerError('round_closed');
    if (step.seat != expected) {
      throw _LedgerError('out_of_turn:${step.seat}!=$expected');
    }
    switch (step.verb) {
      case W11VerbV1.fold:
        live.remove(step.seat);
        if (live.length == 1) handOver = true;
      case W11VerbV1.check:
        if (c(step.seat) < price) throw _LedgerError('check_facing_bet');
      case W11VerbV1.call:
        if (price <= c(step.seat)) throw _LedgerError('call_without_bet');
        if (step.to != null && step.to != price) {
          throw _LedgerError('call_not_price');
        }
        _put(step.seat, price);
      case W11VerbV1.bet:
        if (price > 0) throw _LedgerError('bet_facing_bet');
        _put(step.seat, step.to!);
        price = step.to!;
        acted.clear();
      case W11VerbV1.raiseTo:
        if (price == 0) throw _LedgerError('raise_without_bet');
        // A null size is an unauthored raise: order consequence only.
        final to = step.to ?? double.infinity;
        if (to <= price) throw _LedgerError('raise_not_above_price');
        if (to.isFinite) _put(step.seat, to);
        price = to;
        acted.clear();
      default:
        throw _LedgerError('unexpected_verb');
    }
    acted.add(step.seat);
    last = step.seat;
  }

  static _Ledger run(Iterable<W11StepV1> steps) {
    final l = _Ledger();
    for (final s in steps) {
      l.apply(s);
    }
    return l;
  }
}

String? _failure(List<W11StepV1> steps) {
  try {
    _Ledger.run(steps);
    return null;
  } on _LedgerError catch (e) {
    return e.reason;
  }
}

W11StepV1 _step(
  String street,
  String seat,
  W11VerbV1 verb, {
  double? to,
  String label = '',
}) => W11StepV1(
  street,
  seat,
  verb,
  W11ProvenanceV1.forcedByAuthoredFacts,
  to: to,
  label: label,
);

/// Runner playback pot after trail index [i], as the learner would see it.
double _shown(List<Act0ActionTrailItemV1> trail, int i) =>
    act0CalcTableTrailPotV1(
      _runner(_small).table.copyWith(actionTrail: trail),
      i,
    ).potBb;

List<Act0ActionTrailItemV1> _trailOf(List<W11StepV1> steps) => [
  for (final s in steps)
    s.isNote
        ? Act0ActionTrailItemV1.note(label: s.label)
        : Act0ActionTrailItemV1(label: s.label),
];

void main() {
  final small = _runner(_small);
  final bad = _runner(_bad);

  group('history in State (option B)', () {
    test('State trail is exactly the provenance sequence', () {
      for (final (runner, steps) in [
        (small, w11HonestSmallPriceV1),
        (bad, w11HonestBadPriceV1),
      ]) {
        expect(
          [
            for (final i in runner.table.actionTrail)
              '${i.isNote ? 'note' : 'action'}:${i.label}',
          ],
          [for (final s in steps) '${s.isNote ? 'note' : 'action'}:${s.label}'],
        );
      }
    });

    test('authored facts and new authored items are kept apart', () {
      String kind(W11StepV1 s) => s.provenance.name;
      expect(
        [
          for (final s in w11HonestBadPriceV1)
            if (!s.isNew) '${kind(s)}:${s.label}',
        ],
        [
          'authoredTrail:CO raises 2.5 BB',
          'authoredTrailSizedLabel:BTN calls 2.5 BB',
          'authoredTrail:Flop: CO bets 2 BB',
          'authoredTrail:BTN calls 2 BB',
          'authoredTrail:Turn: CO bets 12 BB',
        ],
      );
      expect(
        [
          for (final s in w11HonestBadPriceV1)
            if (s.isNew) '${kind(s)}:${s.label}',
        ],
        [
          'authoredCaption:Antes 0.25 BB x 6 players',
          'forcedByAuthoredFacts:SB blind 0.5 BB',
          'forcedByAuthoredFacts:BB blind 1 BB',
          'forcedByAuthoredFacts:UTG folds',
          'forcedByAuthoredFacts:HJ folds',
          'forcedByAuthoredFacts:SB folds',
          'forcedByAuthoredFacts:BB folds',
        ],
      );
      for (final s in w11HonestBadPriceV1.where((s) => s.because.isEmpty)) {
        expect(s.provenance, W11ProvenanceV1.authoredTrail, reason: s.label);
      }
      // No new check, call, bet or raise exists.
      expect(
        w11HonestBadPriceV1.where(
          (s) =>
              s.isNew &&
              const {
                W11VerbV1.check,
                W11VerbV1.call,
                W11VerbV1.bet,
                W11VerbV1.raiseTo,
              }.contains(s.verb),
        ),
        isEmpty,
      );
    });

    test('caption facts used are written by the author', () {
      expect(small.caption, contains('Six-handed, 0.25 BB ante each.'));
      expect(small.caption, contains('CO opens to 2.5 BB, BTN calls'));
      expect(small.caption, contains('CO bets 2 BB into 8 BB'));
      expect(small.caption, contains('with 35 BB behind each'));
      expect(bad.caption, contains('pot is 12 BB'));
      expect(bad.caption, contains('both started this street with 33 BB'));
    });

    test('seats: four recorded folds; only CO/BTN stacks, from captions', () {
      for (final (runner, stacks) in [
        (small, w11HonestStacksAtSmallDecisionV1),
        (bad, w11HonestStacksAtBadDecisionV1),
      ]) {
        final t = runner.table;
        expect(t.activeSeatId, 'btn');
        for (final s in t.seats) {
          final folded = const {'UTG', 'HJ', 'SB', 'BB'}.contains(s.seatLabel);
          expect(s.isInHand, !folded, reason: s.seatLabel);
          expect(s.isFolded, folded, reason: s.seatLabel);
          expect(
            s.stackLabel,
            folded ? isNull : '${stacks[s.seatLabel]!.toInt()} BB',
            reason: s.seatLabel,
          );
        }
      }
    });
  });

  group('order, closure, stacks and end (ledger)', () {
    test('both decisions: BTN next, heads-up, label = pot with the bet', () {
      for (final (runner, steps, street) in [
        (small, w11HonestSmallPriceV1, 'Flop'),
        (bad, w11HonestBadPriceV1, 'Turn'),
      ]) {
        final l = _Ledger.run(steps);
        expect(l.street, street);
        expect(l.next(), 'BTN');
        expect(l.live, {'CO', 'BTN'});
        // Catalog convention: the table pot counts the faced bet. The
        // captions keep the pre-bet wording ('into 8 BB', 'pot is 12 BB').
        expect(l.pot, _bb(runner.table.potLabel));
        final preBet = RegExp(
          r'(?:into|pot is) (\d+) BB',
        ).firstMatch(runner.caption)!.group(1)!;
        expect(l.potBeforeStreet, double.parse(preBet));
        expect(l.price - l.c('BTN'), _bb(runner.table.toCallLabel));
      }
    });

    test('one starting stack explains both captions', () {
      final flop = _Ledger.run(w11HonestPrefixV1.take(9));
      final turn = _Ledger.run(w11HonestBadPriceV1.take(11));
      for (final seat in ['CO', 'BTN']) {
        expect(35 + flop.total[seat]!, 33 + turn.total[seat]!);
      }
      expect(w11HonestStacksAtSmallDecisionV1['CO'], 35 - 2);
      expect(w11HonestStacksAtBadDecisionV1['CO'], 33 - 12);
    });

    test('the four folds are the only reading of the authored pot', () {
      final solutions = <String>[];
      for (final utg in [0.0, 1.0, 2.5]) {
        for (final hj in [0.0, 1.0, 2.5]) {
          for (final sb in [0.5, 2.5]) {
            for (final bb in [1.0, 2.5]) {
              if (1.5 + 5 + utg + hj + sb + bb == 8) {
                solutions.add('UTG=$utg HJ=$hj SB=$sb BB=$bb');
              }
            }
          }
        }
      }
      expect(solutions, ['UTG=0.0 HJ=0.0 SB=0.5 BB=1.0']);
    });

    test('end of hand per answer; raise size stays unauthored', () {
      W11StepV1 btn(String street, W11VerbV1 v, [double? to]) =>
          _step(street, 'BTN', v, to: to);
      expect(
        _Ledger.run([
          ...w11HonestSmallPriceV1,
          btn('Flop', W11VerbV1.fold),
        ]).handOver,
        isTrue,
      );
      final call = _Ledger.run([
        ...w11HonestSmallPriceV1,
        btn('Flop', W11VerbV1.call, 2),
      ]);
      expect(call.next(), isNull);
      expect(
        call.pot,
        _Ledger.run(w11HonestBadPriceV1).potBeforeStreet,
        reason: 'turn scene starts',
      );
      expect(
        _Ledger.run([
          ...w11HonestSmallPriceV1,
          btn('Flop', W11VerbV1.raiseTo),
        ]).next(),
        'CO',
      );
      expect(
        _Ledger.run([
          ...w11HonestBadPriceV1,
          btn('Turn', W11VerbV1.fold),
        ]).handOver,
        isTrue,
      );
      expect(
        _Ledger.run([
          ...w11HonestBadPriceV1,
          btn('Turn', W11VerbV1.call, 12),
        ]).next(),
        isNull,
      );
      final jam = _Ledger.run([
        ...w11HonestBadPriceV1,
        btn('Turn', W11VerbV1.raiseTo, 33),
      ]);
      expect(jam.next(), 'CO');
      expect(jam.price - jam.c('CO'), w11HonestStacksAtBadDecisionV1['CO']);
    });
  });

  group('pot at every step: Runner calculator = independent ledger', () {
    test('every index of both State trails agrees, ante counted once', () {
      for (final runner in [small, bad]) {
        final trail = runner.table.actionTrail;
        final steps = runner == small
            ? w11HonestSmallPriceV1
            : w11HonestBadPriceV1;
        for (var i = 0; i < trail.length; i++) {
          final shown = act0CalcTableTrailPotV1(runner.table, i).potBb;
          final ledger = _Ledger.run(steps.take(i + 1)).pot;
          expect(
            shown,
            ledger,
            reason: '${runner.lessonId} @ ${trail[i].label}',
          );
        }
      }
    });

    test('anchors: 8 before the flop bet, 10, 12, 24 and 36 after', () {
      final trail = bad.table.actionTrail;
      int at(String label) => trail.indexWhere((t) => t.label == label);
      final withCall = [
        ...trail,
        const Act0ActionTrailItemV1(label: 'BTN calls 12 BB'),
      ];
      final computed = [
        _shown(trail, at('BB folds')),
        _shown(trail, at('Flop: CO bets 2 BB')),
        _shown(trail, at('BTN calls 2 BB')),
        _shown(trail, at('Turn: CO bets 12 BB')),
        _shown(withCall, withCall.length - 1),
      ];
      final ledger = [
        _Ledger.run(w11HonestPrefixV1.take(9)).pot,
        _Ledger.run(w11HonestPrefixV1).pot,
        _Ledger.run(w11HonestBadPriceV1.take(11)).pot,
        _Ledger.run(w11HonestBadPriceV1).pot,
        _Ledger.run([
          ...w11HonestBadPriceV1,
          _step('Turn', 'BTN', W11VerbV1.call, to: 12),
        ]).pot,
      ];
      expect(computed, ledger);
      expect(computed, [8, 10, 12, 24, 36]);
      // The decision-step playback pot equals the static table label, so
      // one moment never shows two pot numbers.
      expect(computed[1], _bb(small.table.potLabel));
      expect(computed[3], _bb(bad.table.potLabel));
    });

    test('double counting fails closed or is impossible', () {
      final trail = small.table.actionTrail;
      final last = trail.length - 1;
      const ante = Act0ActionTrailItemV1.note(
        label: 'Antes 0.25 BB x 6 players',
      );
      // A second ante note or an ante after an action is malformed.
      expect(_shown([ante, ...trail], last + 1), -1);
      expect(_shown([...trail.take(3), ante, ...trail.skip(3)], last + 1), -1);
      // An ante written as an action is not a blind start: no computed pot.
      expect(
        _shown([
          const Act0ActionTrailItemV1(label: 'Antes 0.25 BB x 6 players'),
          ...trail.skip(1),
        ], last),
        -1,
      );
      // Without the ante note the pot is exactly the ante short, not more.
      expect(
        _shown(trail.skip(1).toList(), last - 1),
        _shown(trail, last) - 1.5,
      );
      // A blind that later calls counts its total once (max, not sum).
      expect(
        _shown([
          ante,
          const Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
          const Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
          const Act0ActionTrailItemV1(label: 'SB calls 1 BB'),
        ], 3),
        1.5 + 1 + 1,
      );
      // Other notes never add chips.
      expect(
        _shown([
          ...trail.take(1),
          const Act0ActionTrailItemV1.note(label: 'Table is six-handed'),
          ...trail.skip(1),
        ], last + 1),
        _shown(trail, last),
      );
    });
  });

  group('animation chips (choreography) match the ledger', () {
    String fmt(double v) => v == v.truncateToDouble() ? '${v.toInt()}' : '$v';
    List<String> dedupe(Iterable<String> xs) {
      final out = <String>[];
      for (final x in xs) {
        if (x.isNotEmpty && (out.isEmpty || out.last != x)) out.add(x);
      }
      return out;
    }

    test('street chips per frame = ledger commitments; no chip twice', () {
      for (final (runner, steps) in [
        (small, w11HonestSmallPriceV1),
        (bad, w11HonestBadPriceV1),
      ]) {
        final plan = act0TableChoreographyPlanForTableV1(runner.table)!;
        final frames = [
          for (var i = 0; i < plan.beats.length; i++)
            act0TableChoreographyFrameAfterBeatV1(plan, i),
        ];
        expect(frames.last.heroDecisionReady, isTrue);
        final shown = dedupe(
          frames.map(
            (f) =>
                (f.commitments.entries.toList()
                      ..sort((a, b) => a.key.compareTo(b.key)))
                    .map((e) => '${e.key}:${e.value.amountLabel}')
                    .join(','),
          ),
        );
        final ledger = dedupe([
          for (var i = 1; i <= steps.length; i++)
            if (!steps[i - 1].isNote)
              (_Ledger.run(steps.take(i)).commit.entries.toList()
                    ..sort((a, b) => a.key.compareTo(b.key)))
                  .map((e) => '${e.key.toLowerCase()}:${fmt(e.value)} BB')
                  .join(','),
        ]);
        expect(shown, ledger, reason: runner.lessonId);
      }
    });
  });

  group('animation never shows a decision-time stack as history', () {
    test('earlier frames carry no stack; the decision frame does', () {
      for (final runner in [small, bad]) {
        final plan = act0TableChoreographyPlanForTableV1(runner.table)!;
        for (var i = 0; i < plan.beats.length; i++) {
          final frame = act0TableChoreographyFrameAfterBeatV1(plan, i);
          final shown = act0TableForChoreographyFrameV1(runner.table, frame);
          final stacks = {
            for (final s in shown.seats)
              if (s.stackLabel != null) s.seatLabel: s.stackLabel,
          };
          if (frame.heroDecisionReady) {
            expect(stacks, {
              for (final s in runner.table.seats)
                if (s.stackLabel != null) s.seatLabel: s.stackLabel,
            });
          } else {
            expect(stacks, isEmpty, reason: '${runner.lessonId} beat $i');
          }
        }
      }
    });
  });

  group('negative controls (ledger fails closed)', () {
    List<W11StepV1> without(String label) => [
      for (final s in w11HonestBadPriceV1)
        if (s.label != label) s,
    ];

    test('missing blinds, missing replies, double ante', () {
      expect(
        _failure([
          for (final s in w11HonestBadPriceV1)
            if (!s.isNew) s,
        ]),
        'no_blinds',
      );
      expect(_failure(without('BB folds')), 'round_not_closed:BB');
      expect(_failure(without('SB folds')), 'out_of_turn:BB!=SB');
      expect(
        _failure([w11HonestPrefixV1.first, ...w11HonestBadPriceV1]),
        'ante_not_once_first',
      );
    });

    test('wrong street, out of turn, after closure or end, folded seat', () {
      expect(
        _failure([
          for (final s in w11HonestBadPriceV1)
            s.label == 'Turn: CO bets 12 BB'
                ? _step('River', 'CO', W11VerbV1.bet, to: 12)
                : s,
        ]),
        'street_skipped_or_backwards',
      );
      expect(
        _failure([
          ...w11HonestPrefixV1.take(9),
          _step('Flop', 'BTN', W11VerbV1.bet, to: 2),
        ]),
        'out_of_turn:BTN!=CO',
      );
      expect(
        _failure([
          ...w11HonestBadPriceV1,
          _step('Turn', 'BTN', W11VerbV1.call, to: 12),
          _step('Turn', 'CO', W11VerbV1.check),
        ]),
        'round_closed',
      );
      expect(
        _failure([
          ...w11HonestBadPriceV1,
          _step('Turn', 'BTN', W11VerbV1.fold),
          _step('Turn', 'CO', W11VerbV1.check),
        ]),
        'action_after_hand_over',
      );
      expect(
        _failure([
          ...w11HonestPrefixV1.take(9),
          _step('Flop', 'SB', W11VerbV1.check),
        ]),
        'out_of_turn:SB!=CO',
      );
    });
  });

  group('public contracts on the State scenes', () {
    test('order is never a contradiction; replay stays consumer-safe', () {
      for (final r in [small, bad]) {
        final truth = act0BettingRoundOrderTruthForTableV1(r.table);
        expect(truth, isNot(Act0BettingRoundOrderTruthV1.contradiction));
        // ignore: avoid_print
        print('PKR03_W11_B_ORDER ${r.lessonId} $truth');
        expect(act0StreetReplayFromTableV1(r.table)?.isConsumerSafe, isTrue);
      }
    });
  });

  test('still unauthored (never filled in here)', () {
    expect(w11StillUnauthoredV1, [
      'UTG, HJ, SB and BB stacks (they only need chips for their ante/blind)',
      'raise size of "Raise for protection now" (small price option)',
    ]);
  });
}

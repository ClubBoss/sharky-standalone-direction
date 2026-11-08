// PKR-03: honest event sequence for the two W11 trigger hands (PROPOSAL).
//
// Test-only. Reads authored State and public contracts; changes nothing.
// See act0_pkr03_w11_honest_sequence_proposal_v1.dart for provenance.
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_street_replay_contract_v1.dart';

import 'act0_pkr03_w11_honest_sequence_proposal_v1.dart';

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

/// Independent hold'em ledger: order, price, closure, pot and stacks.
/// Any rule break throws a [_LedgerError] with an exact reason.
class _LedgerError implements Exception {
  _LedgerError(this.reason);
  final String reason;
  @override
  String toString() => reason;
}

class _Ledger {
  String street = 'Preflop';
  double potBeforeStreet = 0;
  final commit = <String, double>{};
  final total = <String, double>{};
  final live = {..._preflopOrder};
  final allIn = <String>{};
  final acted = <String>{};
  double price = 0;
  String? last;
  int posts = 0;
  bool handOver = false;

  List<String> get order =>
      street == 'Preflop' ? _preflopOrder : _postflopOrder;
  double c(String s) => commit[s] ?? 0;

  void _put(String seat, double to) {
    total[seat] = (total[seat] ?? 0) + to - c(seat);
    commit[seat] = to;
  }

  /// Next seat that still owes an action, or null when the round is closed.
  String? next() {
    if (live.length - allIn.length < 1 || live.length < 2) return null;
    final o = order;
    final start = last == null
        ? (street == 'Preflop' ? o.indexOf('BB') : o.length - 1)
        : o.indexOf(last!);
    for (var k = 1; k <= o.length; k++) {
      final s = o[(start + k) % o.length];
      if (!live.contains(s) || allIn.contains(s)) continue;
      if (!acted.contains(s) || c(s) < price) return s;
    }
    return null;
  }

  void apply(W11StepV1 step) {
    if (handOver) throw _LedgerError('action_after_hand_over');
    if (step.street != street) {
      final from = _streets.indexOf(street);
      if (_streets.indexOf(step.street) != from + 1) {
        throw _LedgerError('street_skipped_or_backwards');
      }
      if (next() != null) throw _LedgerError('round_not_closed:${next()}');
      potBeforeStreet += commit.values.fold(0.0, (a, b) => a + b);
      commit.clear();
      acted.clear();
      price = 0;
      last = null;
      street = step.street;
    }
    switch (step.verb) {
      case W11VerbV1.ante:
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
        // A null size is an unauthored raise: legal-order only, no amount.
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

  static _Ledger run(List<W11StepV1> steps) {
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

/// The authored table with the proposed trail, folded seats and stacks.
Act0TableStateV1 _proposedTable(
  Act0TableStateV1 authored,
  List<W11StepV1> steps,
  Map<String, double> stacks,
) {
  final folded = {
    for (final s in steps)
      if (s.verb == W11VerbV1.fold) s.seat,
  };
  return authored.copyWith(
    actionTrail: [
      for (final s in steps)
        s.isNote
            ? Act0ActionTrailItemV1.note(label: s.label)
            : Act0ActionTrailItemV1(label: s.label),
    ],
    seats: [
      for (final seat in authored.seats)
        Act0SeatStateV1(
          seatId: seat.seatId,
          seatLabel: seat.seatLabel,
          displayName: seat.displayName,
          isHero: seat.isHero,
          isDealerButton: seat.isDealerButton,
          isSmallBlind: seat.isSmallBlind,
          isBigBlind: seat.isBigBlind,
          blindAmountLabel: seat.blindAmountLabel,
          isActive: seat.isActive,
          isTarget: seat.isTarget,
          isInHand: !folded.contains(seat.seatLabel),
          isFolded: folded.contains(seat.seatLabel),
          hasActed: seat.hasActed || folded.contains(seat.seatLabel),
          isLastAggressor: seat.isLastAggressor,
          isOccupied: seat.isOccupied,
          stackLabel: stacks.containsKey(seat.seatLabel)
              ? '${_fmt(stacks[seat.seatLabel]!)} BB'
              : seat.stackLabel,
          holeCards: seat.holeCards,
          cardsVisibleMode: folded.contains(seat.seatLabel)
              ? Act0CardsVisibleModeV1.none
              : seat.cardsVisibleMode,
          currentBetLabel: seat.currentBetLabel,
          bet: seat.bet,
        ),
    ],
  );
}

String _fmt(double v) => v == v.truncateToDouble() ? '${v.toInt()}' : '$v';

void main() {
  final small = _runner(_small);
  final bad = _runner(_bad);

  group('authored facts (main, read-only)', () {
    test('the authored trail is exactly the authoredTrail steps, in order', () {
      for (final (runner, steps) in [
        (small, w11HonestSmallPriceV1),
        (bad, w11HonestBadPriceV1),
      ]) {
        expect(
          [for (final i in runner.table.actionTrail) i.label],
          [
            for (final s in steps)
              if (s.provenance == W11ProvenanceV1.authoredTrail) s.label,
          ],
        );
      }
    });

    test('caption facts used by the proposal are written by the author', () {
      expect(small.caption, contains('Six-handed, 0.25 BB ante each.'));
      expect(small.caption, contains('CO opens to 2.5 BB, BTN calls'));
      expect(small.caption, contains('CO bets 2 BB into 8 BB'));
      expect(small.caption, contains('with 35 BB behind each'));
      expect(bad.caption, contains('BTN called 2 BB on J-7-4'));
      expect(bad.caption, contains('pot is 12 BB'));
      expect(bad.caption, contains('both started this street with 33 BB'));
      expect(bad.caption, contains('now bets 12 BB'));
    });

    test('authored table labels: pot before the bet, price, actor', () {
      expect(small.table.potLabel, 'Pot 8 BB');
      expect(small.table.toCallLabel, 'To call 2 BB');
      expect(bad.table.potLabel, 'Pot 12 BB');
      expect(bad.table.toCallLabel, 'To call 12 BB');
      for (final r in [small, bad]) {
        expect(r.table.activeSeatId, 'btn');
        final byLabel = {for (final s in r.table.seats) s.seatLabel: s};
        expect(byLabel['BTN']!.isDealerButton, isTrue);
        expect(byLabel['BTN']!.isHero, isTrue);
        expect(byLabel['SB']!.isSmallBlind, isTrue);
        expect(byLabel['BB']!.isBigBlind, isTrue);
        // Today every seat is drawn in hand and no stack is authored: the
        // gap this proposal documents.
        expect(r.table.seats.where((s) => s.isInHand), hasLength(6));
        expect(r.table.seats.where((s) => s.stackLabel != null), isEmpty);
      }
    });

    test('every new item is marked and explained', () {
      final news = w11HonestBadPriceV1.where((s) => s.isNew).toList();
      expect(
        [for (final s in news) s.label],
        [
          'Antes 0.25 BB each',
          'SB blind 0.5 BB',
          'BB blind 1 BB',
          'UTG folds',
          'HJ folds',
          'SB folds',
          'BB folds',
        ],
      );
      for (final s in news) {
        expect(s.because, isNotEmpty, reason: s.label);
      }
      // No new check, call, bet or raise is proposed.
      expect(
        news.where(
          (s) => const {
            W11VerbV1.check,
            W11VerbV1.call,
            W11VerbV1.bet,
            W11VerbV1.raiseTo,
          }.contains(s.verb),
        ),
        isEmpty,
      );
    });
  });

  group('ledger: order, pot, stacks, end', () {
    test('small price: BTN is next, heads-up, pot 8 before the 2 BB bet', () {
      final l = _Ledger.run(w11HonestSmallPriceV1);
      expect(l.street, 'Flop');
      expect(l.next(), 'BTN');
      expect(l.live, {'CO', 'BTN'});
      expect(l.potBeforeStreet, _bb(small.table.potLabel));
      expect(l.price - l.c('BTN'), _bb(small.table.toCallLabel));
      expect(l.c('CO'), 2);
    });

    test('bad price: BTN is next, heads-up, pot 12 before the 12 BB bet', () {
      final l = _Ledger.run(w11HonestBadPriceV1);
      expect(l.street, 'Turn');
      expect(l.next(), 'BTN');
      expect(l.live, {'CO', 'BTN'});
      expect(l.potBeforeStreet, _bb(bad.table.potLabel));
      expect(l.price - l.c('BTN'), _bb(bad.table.toCallLabel));
    });

    test('caption stacks agree: 35 at flop start and 33 at turn start', () {
      // Paid before the flop: ante 0.25 + 2.5; before the turn: + 2.
      final flop = _Ledger.run(w11HonestPrefixV1.take(9).toList());
      final turn = _Ledger.run(w11HonestBadPriceV1.take(11).toList());
      for (final seat in ['CO', 'BTN']) {
        expect(flop.total[seat], 2.75);
        expect(turn.total[seat], 4.75);
        // One starting stack explains both captions: 35 + 2.75 = 33 + 4.75.
        expect(35 + flop.total[seat]!, 33 + turn.total[seat]!);
      }
      expect(w11HonestStacksAtSmallDecisionV1, {'CO': 35 - 2, 'BTN': 35});
      expect(w11HonestStacksAtBadDecisionV1, {'CO': 33 - 12, 'BTN': 33});
    });

    test('the folds are the only reading the authored pot allows', () {
      // Unrecorded seats may only fold, limp/call; any unrecorded raise
      // would need more unrecorded actions from CO and BTN. Antes 1.5 and
      // CO + BTN 5 are authored, so the four others must add 8 - 6.5 = 1.5.
      final solutions = <String>[];
      for (final utg in [0.0, 1.0, 2.5]) {
        for (final hj in [0.0, 1.0, 2.5]) {
          for (final sb in [0.5, 2.5]) {
            for (final bbSeat in [1.0, 2.5]) {
              if (1.5 + 5 + utg + hj + sb + bbSeat == 8) {
                solutions.add('UTG=$utg HJ=$hj SB=$sb BB=$bbSeat');
              }
            }
          }
        }
      }
      expect(solutions, ['UTG=0.0 HJ=0.0 SB=0.5 BB=1.0']);
    });

    test(
      'small price end: fold ends the hand, call reaches the turn scene',
      () {
        final fold = _Ledger.run([
          ...w11HonestSmallPriceV1,
          _step('Flop', 'BTN', W11VerbV1.fold),
        ]);
        expect(fold.handOver, isTrue);
        expect(fold.live, {'CO'});

        final call = _Ledger.run([
          ...w11HonestSmallPriceV1,
          _step('Flop', 'BTN', W11VerbV1.call, to: 2),
        ]);
        expect(call.next(), isNull, reason: 'flop closes');
        // Continuity: the turn starts exactly as the bad-price scene says.
        expect(call.potBeforeStreet + call.c('CO') + call.c('BTN'), 12);

        // The raise size is not authored: only the order consequence is shown.
        final raise = _Ledger.run([
          ...w11HonestSmallPriceV1,
          _step('Flop', 'BTN', W11VerbV1.raiseTo),
        ]);
        expect(raise.next(), 'CO');
      },
    );

    test('bad price end: fold ends, call goes to the river, jam to CO', () {
      final fold = _Ledger.run([
        ...w11HonestBadPriceV1,
        _step('Turn', 'BTN', W11VerbV1.fold),
      ]);
      expect(fold.handOver, isTrue);

      final call = _Ledger.run([
        ...w11HonestBadPriceV1,
        _step('Turn', 'BTN', W11VerbV1.call, to: 12),
      ]);
      expect(call.next(), isNull);
      expect(call.potBeforeStreet + 24, 36);

      // Jam = BTN's 33 behind; CO then faces 21 more with exactly 21 behind.
      final jam = _Ledger.run([
        ...w11HonestBadPriceV1,
        _step('Turn', 'BTN', W11VerbV1.raiseTo, to: 33),
      ]);
      expect(jam.next(), 'CO');
      expect(jam.price - jam.c('CO'), w11HonestStacksAtBadDecisionV1['CO']);
    });
  });

  group('negative controls (ledger fails closed)', () {
    List<W11StepV1> without(String label) => [
      for (final s in w11HonestBadPriceV1)
        if (s.label != label) s,
    ];

    test('the authored trail alone skips the blinds and the folds', () {
      expect(
        _failure([
          for (final s in w11HonestBadPriceV1)
            if (s.provenance == W11ProvenanceV1.authoredTrail) s,
        ]),
        'no_blinds',
      );
    });

    test('a missing reply leaves the round open', () {
      expect(_failure(without('BB folds')), 'round_not_closed:BB');
      expect(_failure(without('SB folds')), 'out_of_turn:BB!=SB');
    });

    test('a wrong street or out-of-turn player is refused', () {
      final skipped = [
        for (final s in w11HonestBadPriceV1)
          s.label == 'Turn: CO bets 12 BB'
              ? _step('River', 'CO', W11VerbV1.bet, to: 12)
              : s,
      ];
      expect(_failure(skipped), 'street_skipped_or_backwards');
      expect(
        _failure([
          ...w11HonestPrefixV1.take(9),
          _step('Flop', 'BTN', W11VerbV1.bet, to: 2),
        ]),
        'out_of_turn:BTN!=CO',
      );
    });

    test('an extra action after the closure or the end is refused', () {
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
    });

    test('a folded player cannot act; a blind call breaks the pot', () {
      expect(
        _failure([
          ...w11HonestPrefixV1.take(9),
          _step('Flop', 'SB', W11VerbV1.check),
        ]),
        'out_of_turn:SB!=CO',
      );
      final bbCalls = [
        for (final s in w11HonestSmallPriceV1)
          s.label == 'BB folds' ? _step('Preflop', 'BB', W11VerbV1.call) : s,
      ];
      // Stop before the flop bet: on the flop BB would now act before CO.
      final l = _Ledger.run(bbCalls.take(9).toList());
      expect(_failure(bbCalls), 'out_of_turn:CO!=BB');
      expect(l.potBeforeStreet, isNot(_bb(small.table.potLabel)));
      expect(l.live, contains('BB'));
    });
  });

  group('public contracts on the proposed scene (read-only)', () {
    final proposedSmall = _proposedTable(
      small.table,
      w11HonestSmallPriceV1,
      w11HonestStacksAtSmallDecisionV1,
    );
    final proposedBad = _proposedTable(
      bad.table,
      w11HonestBadPriceV1,
      w11HonestStacksAtBadDecisionV1,
    );

    test('the order contract never finds a contradiction', () {
      for (final t in [proposedSmall, proposedBad]) {
        final truth = act0BettingRoundOrderTruthForTableV1(t);
        expect(truth, isNot(Act0BettingRoundOrderTruthV1.contradiction));
        // ignore: avoid_print
        print('PKR03_W11_PROPOSED_ORDER ${t.streetLabel} $truth');
      }
    });

    test('the replay stays consumer-safe with the full sequence', () {
      for (final t in [proposedSmall, proposedBad]) {
        expect(act0StreetReplayFromTableV1(t)?.isConsumerSafe, isTrue);
      }
    });

    test('RISK: playback pot would drop antes and the unsized call', () {
      // Once the trail starts with the SB blind, Runner playback replaces the
      // authored pot with its own sum. It skips the ante note, adds nothing
      // for the unsized authored 'BTN calls' and includes the current bet:
      // flop 0.5 + 1 + 2.5 + 2 = 6; turn 0.5 + 1 + 2.5 + 2 + 2 + 12 = 20.
      double shown(Act0TableStateV1 t) =>
          act0CalcTableTrailPotV1(t, t.actionTrail.length - 1).potBb;
      expect(shown(proposedSmall), 6);
      expect(shown(proposedBad), 20);
      expect(_bb(small.table.potLabel), 8);
      expect(_bb(bad.table.potLabel), 12);
      // Today's authored trail has no blind start, so playback keeps the
      // authored label (no wrong pot is shown now).
      expect(act0CalcTableTrailPotV1(small.table, 2).potBb, -1);
    });
  });

  group('optional variant: sized BTN call label', () {
    final steps = w11WithSizedCallV1(w11HonestBadPriceV1);

    test('changes exactly one authored label and no fact', () {
      final changed = [
        for (var i = 0; i < steps.length; i++)
          if (steps[i].label != w11HonestBadPriceV1[i].label)
            '${w11HonestBadPriceV1[i].label} -> ${steps[i].label}',
      ];
      expect(changed, ['BTN calls -> BTN calls 2.5 BB']);
      final a = _Ledger.run(w11HonestBadPriceV1);
      final b = _Ledger.run(steps);
      expect(b.potBeforeStreet, a.potBeforeStreet);
      expect(b.total, a.total);
      expect(b.next(), 'BTN');
    });

    test('order is never a contradiction; playback still lacks antes', () {
      final t = _proposedTable(
        bad.table,
        steps,
        w11HonestStacksAtBadDecisionV1,
      );
      final truth = act0BettingRoundOrderTruthForTableV1(t);
      expect(truth, isNot(Act0BettingRoundOrderTruthV1.contradiction));
      // ignore: avoid_print
      print('PKR03_W11_SIZED_CALL_ORDER $truth');
      expect(act0StreetReplayFromTableV1(t)?.isConsumerSafe, isTrue);
      // 0.5 + 1 + 2.5 + 2.5 + 2 + 2 + 12: no antes, current bet included.
      expect(act0CalcTableTrailPotV1(t, t.actionTrail.length - 1).potBb, 22.5);
      final ts = _proposedTable(
        small.table,
        w11WithSizedCallV1(w11HonestSmallPriceV1),
        w11HonestStacksAtSmallDecisionV1,
      );
      expect(act0BettingRoundOrderTruthForTableV1(ts), truth);
      // 0.5 + 1 + 2.5 + 2.5 + 2 against the authored 8 before the bet.
      expect(act0CalcTableTrailPotV1(ts, ts.actionTrail.length - 1).potBb, 8.5);
    });
  });

  test('still unauthored after this proposal', () {
    expect(w11StillUnauthoredV1, hasLength(4));
  });
}

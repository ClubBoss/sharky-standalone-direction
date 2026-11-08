// PKR-03: W7 "same hand, different depth" scenes (25 BB / 100 BB effective).
//
// Test-only package for the integrator. Reads authored State and public
// contracts; changes no State, Runner or contract. It separates what the
// author wrote from the history items those facts force, and records what
// stays unauthored (per-seat stacks).
//
// Authored (main):
// - captions: 'Real table. CO opens 2.5 BB. Hero is BTN with A-J suited at
//   25 BB effective.' and 'Same spot again. CO opens 2.5 BB. Hero is BTN with
//   A-J suited at 100 BB effective.'
// - table: Preflop, 'Pot 4 BB', 'To call 2.5 BB', CO raise chip 2.5 BB,
//   trail 'CO opens 2.5 BB', 'BTN acts'; BTN is Hero and button.
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_street_replay_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_table_choreography_contract_v1.dart';

const _ids = ['w7_ajs_btn_25bb_transfer', 'w7_ajs_btn_100bb_transfer'];
const _order = ['UTG', 'HJ', 'CO', 'BTN', 'SB', 'BB'];

enum _Source {
  /// Verbatim authored trail item.
  authoredTrail,

  /// Not written, but forced by an authored fact named in [_Item.because].
  forced,

  /// Forced in total by the authored pot; the 0.5/1 split is the project
  /// blind profile (price contract header), not stated in the scene.
  forcedTotalProfileSplit,
}

class _Item {
  const _Item(this.seat, this.verb, this.source, this.label, {this.to = 0});
  final String seat;
  final String verb; // post, fold, raise, marker
  final _Source source;
  final String label;
  final double to;
  bool get isNew => source != _Source.authoredTrail;
}

const _history = <_Item>[
  _Item(
    'SB',
    'post',
    _Source.forcedTotalProfileSplit,
    'SB blind 0.5 BB',
    to: .5,
  ),
  _Item('BB', 'post', _Source.forcedTotalProfileSplit, 'BB blind 1 BB', to: 1),
  _Item('UTG', 'fold', _Source.forced, 'UTG folds'),
  _Item('HJ', 'fold', _Source.forced, 'HJ folds'),
  _Item('CO', 'raise', _Source.authoredTrail, 'CO opens 2.5 BB', to: 2.5),
  _Item('BTN', 'marker', _Source.authoredTrail, 'BTN acts'),
];

/// Why each new item is forced (authored fact -> item).
const _because = <String, String>{
  'SB blind 0.5 BB':
      "'Pot 4 BB' minus CO's 2.5 BB leaves exactly 1.5 BB of blinds and no "
      'ante; 0.5/1 is the project blind profile',
  'BB blind 1 BB': 'same as SB blind',
  'UTG folds': "caption 'CO opens': an open is the first voluntary entry",
  'HJ folds': "caption 'CO opens': an open is the first voluntary entry",
};

/// Stays unauthored: never filled in by this package.
const _unauthored = <String>[
  'per-seat stacks: "25/100 BB effective" is the smaller of the stacks in '
      'play, not the stack of a named seat, so no stackLabel is set',
];

Act0RunnerStateV1 _runner(String id) {
  for (final w in Act0ShellStateV1.sample.worlds) {
    for (final l in w.lessons) {
      for (final t in l.taskList) {
        if (t.taskId == id) return t.runner;
      }
    }
  }
  throw StateError(id);
}

double _bb(String label) =>
    double.parse(RegExp(r'(\d+(?:\.\d+)?)\s*BB').firstMatch(label)!.group(1)!);

/// Minimal preflop ledger: order after the blinds, price and pot.
({String? next, double pot, double price, Set<String> live, String? error})
_run(List<_Item> items) {
  final commit = <String, double>{};
  final live = {..._order};
  final acted = <String>{};
  var price = 0.0;
  var posts = 0;
  String? last;
  String? nextActor() {
    final start = last == null ? _order.indexOf('BB') : _order.indexOf(last);
    for (var k = 1; k <= _order.length; k++) {
      final s = _order[(start + k) % _order.length];
      if (!live.contains(s)) continue;
      if (!acted.contains(s) || (commit[s] ?? 0) < price) return s;
    }
    return null;
  }

  double pot() => commit.values.fold(0.0, (a, b) => a + b);
  for (final it in items) {
    if (it.verb == 'post') {
      if (it.seat != (posts == 0 ? 'SB' : 'BB')) {
        return (
          next: null,
          pot: pot(),
          price: price,
          live: live,
          error: 'blind_out_of_order',
        );
      }
      posts++;
      commit[it.seat] = it.to;
      if (it.to > price) price = it.to;
      continue;
    }
    if (posts < 2) {
      return (
        next: null,
        pot: pot(),
        price: price,
        live: live,
        error: 'no_blinds',
      );
    }
    final expected = nextActor();
    if (it.seat != expected) {
      return (
        next: expected,
        pot: pot(),
        price: price,
        live: live,
        error: 'out_of_turn:${it.seat}!=$expected',
      );
    }
    if (it.verb == 'marker') continue; // the decision itself, not an action
    if (it.verb == 'fold') live.remove(it.seat);
    if (it.verb == 'raise') {
      if (it.to <= price) {
        return (
          next: expected,
          pot: pot(),
          price: price,
          live: live,
          error: 'raise_not_above_price',
        );
      }
      commit[it.seat] = it.to;
      price = it.to;
      acted.clear();
    }
    acted.add(it.seat);
    last = it.seat;
  }
  return (next: nextActor(), pot: pot(), price: price, live: live, error: null);
}

Act0TableStateV1 _proposed(Act0TableStateV1 authored) {
  const folded = {'UTG', 'HJ'};
  return authored.copyWith(
    actionTrail: [
      for (final i in _history) Act0ActionTrailItemV1(label: i.label),
    ],
    seats: [
      for (final s in authored.seats)
        Act0SeatStateV1(
          seatId: s.seatId,
          seatLabel: s.seatLabel,
          displayName: s.displayName,
          isHero: s.isHero,
          isDealerButton: s.isDealerButton,
          isSmallBlind: s.isSmallBlind,
          isBigBlind: s.isBigBlind,
          blindAmountLabel: s.blindAmountLabel,
          isActive: s.isActive,
          isTarget: s.isTarget,
          isInHand: !folded.contains(s.seatLabel),
          isFolded: folded.contains(s.seatLabel),
          hasActed: s.hasActed || folded.contains(s.seatLabel),
          isLastAggressor: s.isLastAggressor,
          isOccupied: s.isOccupied,
          stackLabel: s.stackLabel,
          holeCards: s.holeCards,
          cardsVisibleMode: folded.contains(s.seatLabel)
              ? Act0CardsVisibleModeV1.none
              : s.cardsVisibleMode,
          currentBetLabel: s.currentBetLabel,
          bet: s.bet,
        ),
    ],
  );
}

void main() {
  group('authored facts (main, read-only)', () {
    test('captions, labels, chips and trail are as recorded', () {
      final depth = {
        'w7_ajs_btn_25bb_transfer': 25,
        'w7_ajs_btn_100bb_transfer': 100,
      };
      for (final id in _ids) {
        final r = _runner(id);
        final t = r.table;
        expect(r.caption, contains('CO opens 2.5 BB.'));
        expect(r.caption, contains('Hero is BTN with A-J suited'));
        expect(r.caption, contains('at ${depth[id]} BB effective.'));
        expect(r.caption, isNot(contains('ante')));
        expect(t.streetLabel, 'Preflop');
        expect(t.potLabel, 'Pot 4 BB');
        expect(t.toCallLabel, 'To call 2.5 BB');
        expect(t.centerLabel, '${depth[id]} BB effective');
        expect(t.activeSeatId, 'btn');
        expect(
          [for (final a in t.actionTrail) a.label],
          [
            for (final i in _history)
              if (!i.isNew) i.label,
          ],
        );
        final by = {for (final s in t.seats) s.seatLabel: s};
        expect(by['BTN']!.isHero && by['BTN']!.isDealerButton, isTrue);
        expect(by['SB']!.isSmallBlind && by['BB']!.isBigBlind, isTrue);
        expect(by['CO']!.bet?.amountLabel, '2.5 BB');
        // The authored gap: seats that the open proves out are drawn in
        // hand, and no per-seat stack is written.
        expect(by['UTG']!.isInHand && by['HJ']!.isInHand, isTrue);
        expect(t.seats.where((s) => s.stackLabel != null), isEmpty);
      }
    });

    test('the two scenes differ only in the stated depth', () {
      final a = _runner(_ids[0]).table;
      final b = _runner(_ids[1]).table;
      expect(
        [for (final i in a.actionTrail) i.label],
        [for (final i in b.actionTrail) i.label],
      );
      expect(a.potLabel, b.potLabel);
      expect(a.toCallLabel, b.toCallLabel);
    });
  });

  group('provenance of new items', () {
    test('every new item is a forced fold or a blind; nothing else', () {
      final news = _history.where((i) => i.isNew).toList();
      expect(
        [for (final i in news) i.label],
        ['SB blind 0.5 BB', 'BB blind 1 BB', 'UTG folds', 'HJ folds'],
      );
      for (final i in news) {
        expect(_because[i.label], isNotNull, reason: i.label);
      }
      expect(
        news.where((i) => i.source == _Source.forcedTotalProfileSplit),
        hasLength(2),
        reason: 'the blind split is the project profile, said so',
      );
    });

    test('the authored pot leaves no room for limps or antes', () {
      // UTG/HJ may fold (0) or limp (1); antes 0 or 0.25 x 6.
      final fits = <String>[];
      for (final utg in [0.0, 1.0]) {
        for (final hj in [0.0, 1.0]) {
          for (final ante in [0.0, 1.5]) {
            if (1.5 + 2.5 + utg + hj + ante == _bb('Pot 4 BB')) {
              fits.add('UTG=$utg HJ=$hj ante=$ante');
            }
          }
        }
      }
      expect(fits, ['UTG=0.0 HJ=0.0 ante=0.0']);
    });
  });

  group('ledger: order, price, pot, live players', () {
    test('BTN is next; SB and BB still to act; pot 4 incl. the open', () {
      final r = _run(_history);
      expect(r.error, isNull);
      expect(r.next, 'BTN');
      expect(r.live, {'CO', 'BTN', 'SB', 'BB'});
      expect(r.price, 2.5);
      // W7 pot label includes the current-street chips (blinds + open).
      expect(r.pot, _bb(_runner(_ids[0]).table.potLabel));
    });

    test('without the forced folds the open is out of turn', () {
      expect(
        _run(_history.where((i) => i.verb != 'fold').toList()).error,
        'out_of_turn:CO!=UTG',
      );
      expect(
        _run(_history.where((i) => i.verb != 'post').toList()).error,
        'no_blinds',
      );
    });

    test('stacks: only a lower bound follows; nothing is written', () {
      // BTN has put no chip in, so its stack is at least the effective
      // depth; CO's exact stack is unknown. Neither is a seat value.
      expect(_unauthored, hasLength(1));
      for (final id in _ids) {
        final p = _proposed(_runner(id).table);
        expect(p.seats.where((s) => s.stackLabel != null), isEmpty);
      }
    });
  });

  group('public contracts on the proposed scene (read-only)', () {
    for (final id in _ids) {
      final p = _proposed(_runner(id).table);

      test('$id: order never contradicts; playback pot ends at 4', () {
        final truth = act0BettingRoundOrderTruthForTableV1(p);
        expect(truth, isNot(Act0BettingRoundOrderTruthV1.contradiction));
        // ignore: avoid_print
        print('PKR03_W7_ORDER $id $truth');
        final pots = [
          for (var i = 0; i < p.actionTrail.length; i++)
            act0CalcTableTrailPotV1(p, i).potBb,
        ];
        // Ledger after each item, independently computed.
        final ledger = [
          for (var i = 1; i <= _history.length; i++)
            _run(_history.take(i).toList()).pot,
        ];
        expect(pots, ledger);
        expect(pots.last, _bb(p.potLabel));
      });

      test('$id: what the learner would see is recorded, not assumed', () {
        // Diagnostic only: whether the full history animates or replays is
        // decided by the choreography/replay contracts on the integrator's
        // base; this package does not claim either.
        // ignore: avoid_print
        print(
          'PKR03_W7_VIEW $id '
          'animation=${act0TableChoreographyPlanForTableV1(p) != null} '
          'replay=${act0StreetReplayFromTableV1(p)?.isConsumerSafe}',
        );
        expect(_runner(id).table.actionTrail, hasLength(2));
      });
    }
  });
}

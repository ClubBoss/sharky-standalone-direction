// Independent Texas Hold'em rule fixtures for the vendored poker_solver
// (issue #334). Every expectation below is written from the published hand
// rankings (straight flush > four of a kind > full house > flush > straight >
// three of a kind > two pair > one pair > high card) and was hand-checked;
// none is derived from the library under test. Against upstream
// poker_solver 1.0.0 the cross-category and best-five cases fail.
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_solver/poker_solver.dart';

enum _Winner { a, b, tie }

class _Category {
  const _Category(this.label, this.cards, this.expectedName);

  final String label;
  final List<String> cards;
  final String expectedName;
}

class _Showdown {
  const _Showdown(this.label, this.board, this.a, this.b, this.winner);

  final String label;
  final List<String> board;
  final List<String> a;
  final List<String> b;
  final _Winner winner;
}

const _categories = <_Category>[
  _Category('straight flush, nine high', [
    '9h', '8h', '7h', '6h', '5h', '2c', '3d', //
  ], 'Straight Flush'),
  _Category('royal flush is a straight flush', [
    'Ah', 'Kh', 'Qh', 'Jh', 'Th', '2c', '3d', //
  ], 'Straight Flush'),
  _Category('steel wheel is a straight flush', [
    'Ah', '2h', '3h', '4h', '5h', 'Kc', 'Kd', //
  ], 'Straight Flush'),
  _Category('four of a kind', [
    '9c', '9d', '9h', '9s', 'Kd', '2c', '3d', //
  ], 'Four of a Kind'),
  _Category('four of a kind beats the full house inside the same seven', [
    '2c', '2d', '2s', '2h', 'Kc', 'Kd', 'Kh', //
  ], 'Four of a Kind'),
  _Category('full house', [
    'Kc', 'Kd', 'Kh', '2s', '2h', '7c', '8d', //
  ], 'Full House'),
  _Category('two trips make a full house', [
    'Kc', 'Kd', 'Kh', '7s', '7h', '7c', '2d', //
  ], 'Full House'),
  _Category('flush', [
    'Ah', 'Jh', '8h', '4h', '2h', 'Kc', 'Qd', //
  ], 'Flush'),
  _Category('flush beats the straight inside the same seven', [
    '5h', '6h', '7h', '8h', '9c', 'Ah', '2h', //
  ], 'Flush'),
  _Category('straight', [
    '5h', '6d', '7c', '8s', '9h', '2c', 'Kd', //
  ], 'Straight'),
  _Category('wheel straight', [
    'Ah', '2d', '3c', '4s', '5h', 'Kd', 'Qc', //
  ], 'Straight'),
  _Category('straight beats trips inside the same seven', [
    '5c', '5d', '5h', '6s', '7d', '8c', '9h', //
  ], 'Straight'),
  _Category('three of a kind', [
    'Kc', 'Kd', 'Kh', '4s', '2h', '7c', '9d', //
  ], 'Three of a Kind'),
  _Category('two pair', [
    'Ah', 'Ad', '7c', '7s', '2h', '9d', 'Kc', //
  ], 'Two Pair'),
  _Category('three pairs still play as two pair', [
    'Ah', 'Ad', 'Kc', 'Ks', '7h', '7d', '2c', //
  ], 'Two Pair'),
  _Category('one pair', [
    'Qh', 'Qd', '2c', '5s', '8h', 'Jd', '3c', //
  ], 'Pair'),
  _Category('high card', [
    'Ah', 'Jd', '9c', '7s', '4h', '3c', '2d', //
  ], 'High Card'),
];

const _showdowns = <_Showdown>[
  // Cross-category: the upstream 1.0.0 defect.
  _Showdown(
    'full house beats straight',
    ['7c', '8d', '9s', '2d', '2s'],
    ['7h', '7s'],
    ['Th', '6h'],
    _Winner.a,
  ),
  _Showdown(
    'four of a kind beats flush',
    ['2h', '6h', '7h', 'Ac', 'Ad'],
    ['As', 'Ah'],
    ['9h', 'Jh'],
    _Winner.a,
  ),
  _Showdown(
    'four of a kind beats straight',
    ['7c', '8s', '9h', '9c', '9d'],
    ['9s', '2c'],
    ['5h', '6d'],
    _Winner.a,
  ),
  _Showdown(
    'four of a kind beats full house',
    ['Kc', '2s', '2h', '7c', '8d'],
    ['2c', '2d'],
    ['Kh', 'Kd'],
    _Winner.a,
  ),
  _Showdown(
    'full house beats flush',
    ['Ah', 'Ad', '7h', '2h', '2c'],
    ['As', '7s'],
    ['Kh', 'Qh'],
    _Winner.a,
  ),
  _Showdown(
    'straight flush beats four of a kind',
    ['5h', '6h', '7h', '7c', '7d'],
    ['8h', '9h'],
    ['7s', 'Ac'],
    _Winner.a,
  ),
  _Showdown(
    'flush beats straight',
    ['7h', '8h', '9c', 'Td', '2h'],
    ['Ah', '3h'],
    ['6s', 'Jc'],
    _Winner.a,
  ),
  _Showdown(
    'straight beats three of a kind',
    ['5c', '6d', '7h', 'Kc', 'Kd'],
    ['8s', '9h'],
    ['Kh', '2c'],
    _Winner.a,
  ),
  // Straights.
  _Showdown(
    'six-high straight beats the wheel',
    ['2d', '3c', '4s', '5h', 'Kd'],
    ['6h', 'Qc'],
    ['Ah', 'Qd'],
    _Winner.a,
  ),
  _Showdown(
    'ace-high straight beats the wheel',
    ['Ac', 'Kd', 'Qc', '3d', '4c'],
    ['Jh', 'Th'],
    ['5s', '2s'],
    _Winner.a,
  ),
  _Showdown(
    'six-high straight flush beats the steel wheel',
    ['2h', '3h', '4h', '5h', 'Kc'],
    ['6h', 'Kd'],
    ['Ah', 'Ks'],
    _Winner.a,
  ),
  // Kickers and best five.
  _Showdown(
    'pair of aces, king kicker beats queen kicker',
    ['Ac', '7c', '2d', 'Jc', '4s'],
    ['As', 'Kh'],
    ['Ad', 'Qd'],
    _Winner.a,
  ),
  _Showdown(
    'trips, queen kicker beats jack kicker',
    ['Kc', 'Ks', '7h', '4c', '2d'],
    ['Kh', 'Qd'],
    ['Kd', 'Js'],
    _Winner.a,
  ),
  _Showdown(
    'two pair: the fifth-card kicker decides',
    ['Ah', 'Ad', 'Kc', 'Ks', '2c'],
    ['Qc', '3d'],
    ['7h', '7d'],
    _Winner.a,
  ),
  _Showdown(
    'flush: second-highest card decides',
    ['Ah', '9h', '5h', '2c', '3d'],
    ['Kh', '4h'],
    ['Qh', 'Jh'],
    _Winner.a,
  ),
  _Showdown(
    'full house on a trips board: the higher pair decides',
    ['Ac', 'Ad', 'Ah', '7c', '2s'],
    ['Kc', 'Kd'],
    ['Qc', 'Qd'],
    _Winner.a,
  ),
  _Showdown(
    'four of a kind on board: the kicker decides',
    ['9c', '9d', '9h', '9s', '2d'],
    ['Ac', '3d'],
    ['Kc', 'Qd'],
    _Winner.a,
  ),
  _Showdown(
    'four of a kind on board with an ace kicker plays as a tie',
    ['9c', '9d', '9h', '9s', 'Ad'],
    ['Kc', '3d'],
    ['Qc', '4d'],
    _Winner.tie,
  ),
  // Paired boards and counterfeits.
  _Showdown(
    'counterfeited two pair loses to the higher board-paired two pair',
    ['4c', '3d', 'Kh', 'Ks', 'Qd'],
    ['4h', '3s'],
    ['Ac', 'Qh'],
    _Winner.b,
  ),
  _Showdown(
    'board pairs twice: the hand that fills up wins (W6 authored spot)',
    ['Jh', '8c', '8d', '2s', '2c'],
    ['As', 'Jd'],
    ['Kc', '8s'],
    _Winner.b,
  ),
  _Showdown(
    'both play the board straight: split',
    ['Ah', 'Kd', 'Qc', 'Js', 'Th'],
    ['2c', '3d'],
    ['4h', '5d'],
    _Winner.tie,
  ),
  _Showdown(
    'board trips and pair plays for both: split',
    ['Ac', 'Ad', 'Ah', 'Kc', 'Kd'],
    ['2c', '3d'],
    ['4h', '5s'],
    _Winner.tie,
  ),
  // Real authored Sharky cases.
  _Showdown(
    'authored hand_rankings_full_house_vs_flush_drill',
    ['Ah', 'Ad', '7h', '2h', '2c'],
    ['As', '7s'],
    ['Kh', 'Qh'],
    _Winner.a,
  ),
  _Showdown(
    'authored hand_rankings_quads_vs_full_house_drill',
    ['Qc', 'Qd', '7c', '7d', '2s'],
    ['Qh', 'Qs'],
    ['Ac', '7h'],
    _Winner.a,
  ),
  _Showdown(
    'authored hand_rankings_royal_vs_flush_drill',
    ['Ah', 'Jh', 'Th', '2c', '4d'],
    ['Kh', 'Qh'],
    ['9h', '3h'],
    _Winner.a,
  ),
];

_Winner _solverWinner(_Showdown s) {
  final a = Hand.solveHand(<String>[...s.board, ...s.a]);
  final b = Hand.solveHand(<String>[...s.board, ...s.b]);
  final winners = Hand.winners(<Hand>[a, b]);
  if (winners.length == 2) return _Winner.tie;
  return identical(winners.single, a) ? _Winner.a : _Winner.b;
}

void main() {
  group('standard hand categories (best five of seven)', () {
    for (final fixture in _categories) {
      test(fixture.label, () {
        expect(fixture.cards.toSet(), hasLength(fixture.cards.length));
        expect(Hand.solveHand(fixture.cards).name, fixture.expectedName);
      });
    }
  });

  test('category order is the standard Texas Hold\'em order', () {
    const ordered = <List<String>>[
      ['9h', '8h', '7h', '6h', '5h'],
      ['9c', '9d', '9h', '9s', 'Kd'],
      ['Kc', 'Kd', 'Kh', '2s', '2h'],
      ['Ah', 'Jh', '8h', '4h', '2h'],
      ['5h', '6d', '7c', '8s', '9h'],
      ['Kc', 'Kd', 'Kh', '4s', '2h'],
      ['Ah', 'Ad', '7c', '7s', '2h'],
      ['Qh', 'Qd', '2c', '5s', '8h'],
      ['Ah', 'Jd', '9c', '7s', '4h'],
    ];
    final hands = ordered.map(Hand.solveHand).toList();
    for (var i = 0; i + 1 < hands.length; i++) {
      expect(
        hands[i].rank,
        greaterThan(hands[i + 1].rank),
        reason: '${hands[i].name} must outrank ${hands[i + 1].name}',
      );
      expect(Hand.winners(<Hand>[hands[i], hands[i + 1]]).single, hands[i]);
    }
  });

  group('two-player showdowns', () {
    for (final s in _showdowns) {
      test(s.label, () {
        final all = <String>[...s.board, ...s.a, ...s.b];
        expect(all.toSet(), hasLength(all.length), reason: 'fixture deck');
        expect(_solverWinner(s), s.winner);
      });
    }
  });

  test('duplicate cards are rejected, not silently scored', () {
    expect(
      () => Hand.solveHand(<String>['Qc', 'Qd', 'Ah', 'Kd', 'Qc', 'Js', 'Th']),
      throwsA(anything),
    );
  });
}

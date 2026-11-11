// Scoped HLP-02 golden tests against the EXISTING vendored poker_solver from
// merged PR #349. The JSON supplies independent expectations; no new hand
// evaluator or scoring algorithm is introduced.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_solver/poker_solver.dart';

const _rankNames = <String, String>{
  'rank.high_card': 'High Card',
  'rank.one_pair': 'Pair',
  'rank.two_pair': 'Two Pair',
  'rank.three_of_a_kind': 'Three of a Kind',
  'rank.straight': 'Straight',
  'rank.flush': 'Flush',
  'rank.full_house': 'Full House',
  'rank.four_of_a_kind': 'Four of a Kind',
  'rank.straight_flush': 'Straight Flush',
};

List<String> _cards(Object? cards) =>
    (cards as List<dynamic>).cast<String>();

void _expectBestFive(
  Hand actual,
  List<String> availableCards,
  List<String> expectedCards,
) {
  expect(expectedCards, hasLength(5));
  expect(expectedCards.toSet(), hasLength(5));
  expect(availableCards, containsAll(expectedCards));

  // The solver can retain more than five cards for two triplets. Its
  // comparator uses the first five. Compare ranks, not arbitrary equivalent
  // suits, and normalize the solver's low-ace representation for a wheel.
  final actualRanks = actual.cards.take(5).map(
        (card) => card.value == '1' ? 'A' : card.value,
      );
  final expectedRanks = expectedCards.map((card) => card.substring(0, 1));
  expect(actualRanks, unorderedEquals(expectedRanks));
  expect(
    Hand.winners(<Hand>[actual, Hand.solveHand(expectedCards)]),
    hasLength(2),
    reason: 'Expected best five must tie the existing solver result',
  );
}

bool _validFullRiver(Object? board, Object? hero, Object? villain) {
  if (board is! List || hero is! List || villain is! List ||
      board.length != 5 || hero.length != 2 || villain.length != 2) {
    return false;
  }
  final allCards = <dynamic>[...board, ...hero, ...villain];
  return allCards.every((c) =>
          c is String && RegExp(r'^[2-9TJQKA][shdc]$').hasMatch(c)) &&
      allCards.toSet().length == 9;
}

void main() {
  final data = jsonDecode(File(
    'test/poker/fixtures/hlp02_reference_golden_en_v1.json',
  ).readAsStringSync()) as Map<String, dynamic>;
  final five = (data['five_card_cases'] as List<dynamic>).cast<Map<String, dynamic>>();
  final showdowns =
      (data['showdown_cases'] as List<dynamic>).cast<Map<String, dynamic>>();
  final invalid = (data['invalid_or_incomplete_cases'] as List<dynamic>)
      .cast<Map<String, dynamic>>();

  group('HLP-02 five card source expectations', () {
    for (final spot in five) {
      test(spot['id'] as String, () {
        final cards = _cards(spot['cards']);
        expect(cards, hasLength(5));
        expect(cards.toSet(), hasLength(5));
        final expected = _rankNames[spot['expected_rank_id'] as String];
        expect(expected, isNotNull);
        final solved = Hand.solveHand(cards);
        expect(solved.name, expected);
        if (spot.containsKey('expected_straight_high')) {
          // In the existing solver, a straight's first card is its high
          // card. A wheel and steel wheel must therefore begin with five.
          expect(solved.cards.first.value, spot['expected_straight_high']);
        }
      });
    }
  });

  group('HLP-02 river winner, category, board plays', () {
    for (final spot in showdowns) {
      test(spot['id'] as String, () {
        final board = _cards(spot['board']);
        final heroCards = _cards(spot['hero_hole']);
        final villainCards = _cards(spot['villain_hole']);
        expect(_validFullRiver(board, heroCards, villainCards), isTrue);

        final hero = Hand.solveHand(<String>[...board, ...heroCards]);
        final villain = Hand.solveHand(<String>[...board, ...villainCards]);
        final expected = spot['expected'] as Map<String, dynamic>;
        expect(hero.name, _rankNames[expected['hero_best_category'] as String]);
        expect(villain.name,
            _rankNames[expected['villain_best_category'] as String]);

        final winners = Hand.winners(<Hand>[hero, villain]);
        final winner = winners.length == 2
            ? 'tie'
            : identical(winners.single, hero)
                ? 'hero'
                : 'villain';
        expect(winner, expected['winner'], reason: spot['id'] as String);

        // A shared best-five *rank* need not mean board plays: two players
        // can tie using different private cards. Use the same solver for the
        // five-card board comparison without a second evaluator.
        final boardHand = Hand.solveHand(board);
        final bothBoardPlay =
            Hand.winners(<Hand>[boardHand, hero]).length == 2 &&
            Hand.winners(<Hand>[boardHand, villain]).length == 2;
        expect(bothBoardPlay, expected['board_plays'],
            reason: spot['id'] as String);

        if (spot['id'] == 'showdown.quads_over_full_house') {
          expect(spot['legacy_fixture_id'], 'SD_QUADS_OVER_FULL_HOUSE_V1');
          expect(spot['expected_villain_full_house'], 'nines full of sevens');
          expect(hero.name, 'Four of a Kind');
          expect(villain.name, 'Full House');
          _expectBestFive(
            hero,
            <String>[...board, ...heroCards],
            _cards(spot['expected_hero_best_five']),
          );
          _expectBestFive(
            villain,
            <String>[...board, ...villainCards],
            _cards(spot['expected_villain_best_five']),
          );
        }
      });
    }
  });

  group('HLP-02 invalid or incomplete card input fail-closed', () {
    for (final spot in invalid) {
      test(spot['id'] as String, () {
        // The app has no authorization to infer missing cards; the fixture
        // is intentionally rejected before calling the hand evaluator.
        expect(_validFullRiver(
          spot['board'],
          spot['hero_hole'],
          spot['villain_hole'],
        ), isFalse);
        expect((spot['expected'] as Map<String, dynamic>)['winner'], isNull);
      });
    }
  });
}

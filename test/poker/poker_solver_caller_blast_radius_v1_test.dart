// Caller-level proof for the vendored poker_solver ranking fix (issue #334).
// Each test drives an existing production entry point with a hand whose
// outcome is fixed by the published hand rankings, so a caller only passes
// when it actually reports the correct winner.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/helpers/showdown_evaluator.dart';
import 'package:poker_analyzer/models/card_model.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/hand_evaluator.dart';
import 'package:poker_analyzer/services/world2_showdown_truth_validator_v1.dart';

const _suits = <String, String>{'s': '♠', 'h': '♥', 'd': '♦', 'c': '♣'};

List<CardModel> _cards(List<String> codes) => [
  for (final code in codes)
    CardModel(rank: code.substring(0, 1), suit: _suits[code.substring(1)]!),
];

// Board A♥ A♦ 7♥ 2♥ 2♣ from hand_rankings_full_house_vs_flush_drill.
final _board = _cards(['Ah', 'Ad', '7h', '2h', '2c']);
final _flushKq = _cards(['Kh', 'Qh']); // ace-high flush
final _fullHouse = _cards(['As', '7s']); // aces full of sevens
final _flush93 = _cards(['9h', '3h']); // lower ace-high flush

DrillSpecV1 _w2Spec({
  required List<String> hero,
  required List<String> villain,
  required List<String> board,
  required String expectedActionId,
}) {
  final raw = File(
    'content/worlds/world2/v1/sessions/w2.s01/drills/'
    'd.choose_hero_top_pair_showdown.json',
  ).readAsStringSync();
  final json = (jsonDecode(raw) as Map<String, dynamic>)
    ..['hero_hole_cards_v1'] = hero
    ..['villain_hole_cards_v1'] = villain
    ..['board_cards_v1'] = board
    ..['expected'] = <String, Object?>{'actionId': expectedActionId};
  return DrillSpecV1.fromJson(json);
}

bool _hasWinnerIssue(List<String> issues) =>
    issues.any((issue) => issue.contains('expected winner'));

void main() {
  group('HandEvaluator (hand editor showdown + side pots)', () {
    test('full house beats both flushes at showdown', () {
      expect(
        HandEvaluator.evaluateShowdown([
          _flushKq,
          _fullHouse,
          _flush93,
        ], _board),
        [1],
      );
    });

    test('main and side pot both go to the full house', () {
      final hands = HandEvaluator.buildHands([
        _flushKq,
        _fullHouse,
        _flush93,
      ], _board);
      // Seat 0 is all-in for 20; seats 1 and 2 put in 50 each.
      final split = HandEvaluator.splitWithSidePots(
        showdownHands: hands,
        bets: const [20, 50, 50],
        allInAt: const [20, double.infinity, double.infinity],
        mainPot: 120,
      );
      expect(split, {1: 120.0});
    });
  });

  test('determineWinners picks quads over a straight', () {
    final board = _cards(['7c', '8s', '9h', '9c', '9d']);
    expect(
      determineWinners(board, {
        0: _cards(['5h', '6d']), // nine-high straight
        1: _cards(['9s', '2c']), // four nines
      }),
      [1],
    );
  });

  group('World 2 showdown truth validator', () {
    test('accepts a correctly keyed full house over flush', () {
      final spec = _w2Spec(
        hero: const ['As', '7s'],
        villain: const ['Kh', 'Qh'],
        board: const ['Ah', 'Ad', '7h', '2h', '2c'],
        expectedActionId: 'hero',
      );
      expect(
        deriveWorld2ShowdownTruthV1(spec).winner,
        World2ShowdownWinnerTruthV1.hero,
      );
      expect(
        _hasWinnerIssue(
          validateWorld2ShowdownTruthSpecV1(spec: spec, source: 'fh_vs_flush'),
        ),
        isFalse,
      );
    });

    test('accepts a correctly keyed quads over straight', () {
      final spec = _w2Spec(
        hero: const ['5h', '6d'],
        villain: const ['2c', '2d'],
        board: const ['7c', '8s', '9h', '2s', '2h'],
        expectedActionId: 'villain',
      );
      expect(
        deriveWorld2ShowdownTruthV1(spec).winner,
        World2ShowdownWinnerTruthV1.villain,
      );
      expect(
        _hasWinnerIssue(
          validateWorld2ShowdownTruthSpecV1(
            spec: spec,
            source: 'straight_vs_quads',
          ),
        ),
        isFalse,
      );
    });

    test('still rejects a wrongly keyed full house over flush', () {
      final spec = _w2Spec(
        hero: const ['As', '7s'],
        villain: const ['Kh', 'Qh'],
        board: const ['Ah', 'Ad', '7h', '2h', '2c'],
        expectedActionId: 'villain',
      );
      expect(
        _hasWinnerIssue(
          validateWorld2ShowdownTruthSpecV1(spec: spec, source: 'wrong_key'),
        ),
        isTrue,
      );
    });
  });
}

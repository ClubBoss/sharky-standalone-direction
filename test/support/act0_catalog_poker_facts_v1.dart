import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_solver/poker_solver.dart';

import 'act0_pot_showdown_truth_v1.dart';

const pokerRanks = 'AKQJT98765432';

List<String> physicalCards(Iterable<Act0CardStateV1> cards) =>
    cards.map(potTruthSolverCardV1).nonNulls.toList();

String? startingHandCode(Iterable<String> cards) {
  final hand = cards.toList();
  if (hand.length != 2) return null;
  hand.sort(
    (a, b) => pokerRanks.indexOf(a[0]).compareTo(pokerRanks.indexOf(b[0])),
  );
  final ranks = hand.map((c) => c[0]).join();
  return ranks[0] == ranks[1]
      ? ranks
      : ranks + (hand[0][1] == hand[1][1] ? 's' : 'o');
}

Map<String, int> _counts(Iterable<String> values) {
  final counts = <String, int>{};
  for (final value in values) {
    counts.update(value, (count) => count + 1, ifAbsent: () => 1);
  }
  return counts;
}

class CatalogPokerFacts {
  CatalogPokerFacts(Act0TableStateV1 table)
    : hero = physicalCards(table.heroCards),
      board = physicalCards(table.boardCards),
      exposed = {
        ...physicalCards(table.heroCards),
        ...physicalCards(table.boardCards),
        for (final seat in table.seats)
          if (!seat.isHero &&
              seat.cardsVisibleMode == Act0CardsVisibleModeV1.faceUp)
            ...physicalCards(seat.holeCards),
      };

  final List<String> hero;
  final List<String> board;
  final Set<String> exposed;

  String? get code => startingHandCode(hero);
  bool get complete =>
      hero.length == 2 &&
      board.length >= 3 &&
      board.length <= 5 &&
      {...hero, ...board}.length == hero.length + board.length;

  late final Hand? hand = complete ? Hand.solveHand([...hero, ...board]) : null;
  late final boardRanks = _counts(board.map((card) => card[0]));
  late final boardSuits = _counts(board.map((card) => card[1]));

  String? get rank {
    final name = hand?.name.toLowerCase();
    if (name == 'three of a kind') {
      if (pocketPair && boardRanks[hero.first[0]] == 1) return 'set';
      if (hero.any((card) => boardRanks[card[0]] == 2)) return 'trips';
    }
    return name == 'pair' ? 'one pair' : name;
  }

  bool get pocketPair => hero.length == 2 && hero[0][0] == hero[1][0];

  String? get pairType {
    if (rank != 'one pair') return null;
    final ranks = pokerRanks.split('').where(boardRanks.containsKey).toList();
    if (pocketPair) {
      final index = pokerRanks.indexOf(hero.first[0]);
      if (index < pokerRanks.indexOf(ranks.first)) return 'overpair';
      if (index > pokerRanks.indexOf(ranks.last)) return 'underpair';
      return 'pocket pair';
    }
    for (final card in hero) {
      final match = ranks.indexOf(card[0]);
      if (match == 0) return 'top pair';
      if (match == ranks.length - 1) return 'bottom pair';
      if (match > 0) return 'middle pair';
    }
    return null;
  }

  String? get boardTone {
    if (board.length != 3) return null;
    return switch (boardSuits.length) {
      1 => 'monotone',
      2 => 'two-tone',
      3 => 'rainbow',
      _ => null,
    };
  }

  bool get pairedBoard => boardRanks.values.any((count) => count > 1);

  // The ace is low only in A-2-3-4-5.
  static final _windows = [
    for (var i = 0; i <= pokerRanks.length - 5; i++)
      pokerRanks.substring(i, i + 5).split('').toSet(),
    '5432A'.split('').toSet(),
  ];
  late final _known = [...hero, ...board];
  late final _knownRanks = _known.map((card) => card[0]).toSet();
  late final _privateRanks = hero.map((card) => card[0]).toSet()
    ..removeAll(boardRanks.keys);
  late final _heroWindows = _windows
      .where((window) => window.intersection(_privateRanks).isNotEmpty)
      .toList();

  bool get consecutiveBoard =>
      board.length >= 3 &&
      boardRanks.length == board.length &&
      (_windows.any((window) {
        final positions = window
            .toList()
            .asMap()
            .entries
            .where((entry) => boardRanks.containsKey(entry.value))
            .map((entry) => entry.key)
            .toList();
        return positions.length == board.length &&
            positions.last - positions.first == positions.length - 1;
      }));

  bool get _canDraw => complete && board.length < 5;
  bool get _hasStraight => _windows.any(_knownRanks.containsAll);

  late final straightRanks = {
    if (_canDraw && !_hasStraight)
      for (final window in _heroWindows)
        if (window.difference(_knownRanks).length == 1)
          ...window.difference(_knownRanks),
  };

  bool get openEnded {
    if (!_canDraw || _hasStraight) return false;
    const extended = 'AKQJT98765432A';
    for (var i = 1; i + 4 < extended.length; i++) {
      final four = extended.substring(i, i + 4).split('').toSet();
      if (_knownRanks.containsAll(four) &&
          four.intersection(_privateRanks).isNotEmpty &&
          straightRanks.containsAll([extended[i - 1], extended[i + 4]])) {
        return true;
      }
    }
    return false;
  }

  bool get gutshot =>
      _canDraw &&
      !_hasStraight &&
      _heroWindows.any((window) {
        final missing = window.difference(_knownRanks);
        final ordered = window.toList();
        return missing.length == 1 &&
            ordered.indexOf(missing.single) > 0 &&
            ordered.indexOf(missing.single) < ordered.length - 1;
      });

  late final _suitCounts = _counts(_known.map((card) => card[1]));
  late final flushSuits = {
    if (_canDraw && !_suitCounts.values.any((count) => count >= 5))
      for (final card in hero)
        if (_suitCounts[card[1]] == 4) card[1],
  };
  bool get backdoorFlush =>
      board.length == 3 &&
      complete &&
      flushSuits.isEmpty &&
      hero.any((card) => _suitCounts[card[1]] == 3);
  bool get backdoorStraight =>
      board.length == 3 &&
      complete &&
      !_hasStraight &&
      straightRanks.isEmpty &&
      _heroWindows.any((window) => window.difference(_knownRanks).length == 2);

  // Completion cards, not an equity model. Shared outs are counted once.
  late final Set<String> completionCards = {
    for (final rank in pokerRanks.split(''))
      for (final suit in 'shdc'.split(''))
        if ((straightRanks.contains(rank) || flushSuits.contains(suit)) &&
            !exposed.contains('$rank$suit'))
          '$rank$suit',
  };

  String get description {
    final bits = [
      if (rank case final name?) name,
      if (pairType case final kind?) kind,
      if (pocketPair && pairType != 'pocket pair') 'pocket pair',
      if (boardTone case final tone?) tone,
      if (pairedBoard) 'paired board',
      if (consecutiveBoard) 'consecutive board',
      if (flushSuits.isNotEmpty) 'flush draw',
      if (openEnded) 'open-ended',
      if (gutshot) 'gutshot',
      if (backdoorFlush) 'backdoor flush',
      if (backdoorStraight) 'backdoor straight',
      if (completionCards.isNotEmpty)
        'completion cards ' + completionCards.length.toString(),
    ];
    return bits.isEmpty ? 'no applicable hand facts' : bits.join(', ');
  }
}

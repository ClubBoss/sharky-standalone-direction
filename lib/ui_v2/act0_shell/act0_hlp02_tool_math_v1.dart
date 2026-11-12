/// HLP-02 teaching arithmetic only: no hand evaluator, decision grading,
/// range recommendation, inferred outs, or calculated showdown equity.
library;

enum Hlp02OutsStreetV1 { flop, turn, river }

final class Hlp02OutsChanceV1 {
  const Hlp02OutsChanceV1._({
    required this.outs,
    required this.dirtyOuts,
    required this.unseenCards,
    required this.cardsToCome,
    required this.probability,
  });

  final int outs;
  final int dirtyOuts;
  final int unseenCards;
  final int cardsToCome;

  int get cleanOuts => outs - dirtyOuts;

  /// Chance of hitting at least one member of the stated clean-out set.
  /// It is NOT the chance of winning the hand or a share of the pot.
  final double probability;

  double get percent => probability * 100;

  /// Misses : hits. Null means no chance to hit, not zero odds against.
  double? get oddsAgainst =>
      probability == 0 ? null : (1 - probability) / probability;
}

/// Exact sampling-without-replacement chance for a fixed set of clean outs.
///
/// Hero's two cards and the board are the only known cards: 47 unseen on
/// the flop, 46 on the turn. [outs] is a supplied count of DISTINCT improving
/// cards; [dirtyOuts] is a supplied subset to exclude, not an equity estimate.
/// No card identities, opponent range, or dirty-out judgement are inferred.
///
/// P(hit) = 1 - C(unseen - cleanOuts, cardsToCome) / C(unseen, cardsToCome).
/// The fixed set must stay valid for the entire draw window. This model does
/// not cover runner-runner draws, later redraws, changing outs, or known
/// opponent/dead cards. A two-card flop result assumes BOTH remaining board
/// cards will be seen; it does not pay for a later bet or promise a win.
///
/// Flop accepts one or two cards; turn accepts one. River accepts zero and
/// returns null because no improvement calculation is available there.
/// Impossible counts/windows are rejected instead of clamped.
Hlp02OutsChanceV1? hlp02OutsChanceV1({
  required Hlp02OutsStreetV1 street,
  required int outs,
  int dirtyOuts = 0,
  required int cardsToCome,
}) {
  final unseen = switch (street) {
    Hlp02OutsStreetV1.flop => 47,
    Hlp02OutsStreetV1.turn => 46,
    Hlp02OutsStreetV1.river => 45,
  };
  if (outs < 0 || outs > unseen) {
    throw ArgumentError.value(outs, 'outs', 'must be within 0..$unseen');
  }
  if (dirtyOuts < 0 || dirtyOuts > outs) {
    throw ArgumentError.value(
      dirtyOuts,
      'dirtyOuts',
      'must be a subset of the supplied outs',
    );
  }
  final validWindow = switch (street) {
    Hlp02OutsStreetV1.flop => cardsToCome == 1 || cardsToCome == 2,
    Hlp02OutsStreetV1.turn => cardsToCome == 1,
    Hlp02OutsStreetV1.river => cardsToCome == 0,
  };
  if (!validWindow) {
    throw ArgumentError.value(
      cardsToCome,
      'cardsToCome',
      'invalid street window',
    );
  }
  if (street == Hlp02OutsStreetV1.river) return null;

  final clean = outs - dirtyOuts;
  final misses = unseen - clean;
  var missProbability = 1.0;
  for (var draw = 0; draw < cardsToCome; draw++) {
    if (misses <= draw) {
      missProbability = 0;
      break;
    }
    missProbability *= (misses - draw) / (unseen - draw);
  }
  return Hlp02OutsChanceV1._(
    outs: outs,
    dirtyOuts: dirtyOuts,
    unseenCards: unseen,
    cardsToCome: cardsToCome,
    probability: 1 - missProbability,
  );
}

/// Existing Act0/DrillSpec card convention: [AKQJT98765432][shdc].
/// The grid follows the existing HeroRangeGridWidget/RangeMatrixPicker order.
const hlp02RangeRanksV1 = <String>[
  'A',
  'K',
  'Q',
  'J',
  'T',
  '9',
  '8',
  '7',
  '6',
  '5',
  '4',
  '3',
  '2',
];
const _suits = <String>['c', 'd', 'h', 's'];
final _cardPattern = RegExp(r'^[AKQJT98765432][shdc]$');

/// Pair on the diagonal, suited above, offsuit below. Each class occurs once.
String hlp02RangeClassAtV1({required int row, required int column}) {
  RangeError.checkValueInInterval(row, 0, 12, 'row');
  RangeError.checkValueInInterval(column, 0, 12, 'column');
  final a = hlp02RangeRanksV1[row];
  final b = hlp02RangeRanksV1[column];
  if (row == column) return '$a$b';
  return row < column ? '$a${b}s' : '$b${a}o';
}

final class Hlp02RangeSummaryV1 {
  Hlp02RangeSummaryV1._({
    required Map<String, int> combosByClass,
    required Set<String> combinations,
    required this.knownCardCount,
    required this.availableCombos,
  }) : combosByClass = Map<String, int>.unmodifiable(combosByClass),
       combinations = Set<String>.unmodifiable(combinations);

  /// Counts include selected classes with zero combinations after blockers.
  final Map<String, int> combosByClass;

  /// Canonical unordered physical pairs, e.g. 'Ac Ad' or 'As Ks'.
  final Set<String> combinations;
  final int knownCardCount;

  /// All possible two-card hands after removing the supplied known cards.
  final int availableCombos;

  int get classCount => combosByClass.length;
  int get availableClassCount =>
      combosByClass.values.where((count) => count > 0).length;
  int get comboCount => combinations.length;

  /// Share of the remaining physical combinations, not share of 169 cells.
  /// Null if fewer than two unknown cards remain, so no hand can be formed.
  double? get fraction =>
      availableCombos == 0 ? null : comboCount / availableCombos;
}

/// Expands selected 13x13 classes to unique physical hands, then removes
/// hands containing known cards. Without blockers: pair=6, suited=4,
/// offsuit=12, all 169 classes=1326 physical combinations.
///
/// Inputs use canonical high-rank-first classes (AA, AKs, AKo) and exact
/// DrillSpec card codes (As, Td). Repeated classes/cards are deduplicated;
/// malformed/ambiguous labels are rejected. No frequency, strategy or
/// opponent distribution is inferred. Denominator is C(52-known, 2).
Hlp02RangeSummaryV1 hlp02RangeSummaryV1({
  required Iterable<String> classes,
  Iterable<String> knownCards = const <String>[],
}) {
  final known = <String>{};
  for (final card in knownCards) {
    if (!_cardPattern.hasMatch(card)) {
      throw ArgumentError.value(card, 'knownCards', 'invalid canonical card');
    }
    known.add(card);
  }
  final selected = <String>{};
  for (final hand in classes) {
    _validateClass(hand);
    selected.add(hand);
  }
  final combinations = <String>{};
  final counts = <String, int>{};
  for (final hand in selected) {
    var count = 0;
    for (var first = 0; first < _suits.length; first++) {
      for (var second = 0; second < _suits.length; second++) {
        if (hand.length == 2 && first >= second) continue;
        if (hand.length == 3 && ((hand[2] == 's') != (first == second))) {
          continue;
        }
        final a = '${hand[0]}${_suits[first]}';
        final b = '${hand[1]}${_suits[second]}';
        if (known.contains(a) || known.contains(b)) continue;
        if (combinations.add('$a $b')) count++;
      }
    }
    counts[hand] = count;
  }
  final remaining = 52 - known.length;
  return Hlp02RangeSummaryV1._(
    combosByClass: counts,
    combinations: combinations,
    knownCardCount: known.length,
    availableCombos: remaining * (remaining - 1) ~/ 2,
  );
}

void _validateClass(String hand) {
  if (hand.length != 2 && hand.length != 3) {
    throw ArgumentError.value(hand, 'classes', 'expected AA, AKs or AKo');
  }
  final first = hlp02RangeRanksV1.indexOf(hand[0]);
  final second = hlp02RangeRanksV1.indexOf(hand[1]);
  final valid =
      first >= 0 &&
      second >= 0 &&
      (hand.length == 2
          ? first == second
          : first < second && (hand[2] == 's' || hand[2] == 'o'));
  if (!valid) {
    throw ArgumentError.value(hand, 'classes', 'invalid canonical hand class');
  }
}

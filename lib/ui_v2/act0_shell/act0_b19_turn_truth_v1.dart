import 'package:poker_analyzer/models/poker_street.dart';
import 'act0_hand_contributions_v1.dart';
import 'act0_poker_reference_math_v1.dart';
import 'package:poker_solver/poker_solver.dart' as solver;

final act0B19DeckV1 = List<String>.unmodifiable([
  for (final rank in '23456789TJQKA'.split(''))
    for (final suit in 'cdhs'.split('')) '$rank$suit',
]);

/// Equal weight per legal opponent combination; ties count as half a win.
/// A possible range holding is not a known hand: a turn can remove that
/// combination, but it cannot remove a card in Hero's hand or the flop.
({int wins, int ties, int total}) act0B19ShowdownV1({
  required List<String> hero,
  required List<String> board,
  required List<List<String>> range,
}) {
  final visible = [...hero, ...board];
  if (hero.length != 2 ||
      board.length < 3 ||
      board.length > 4 ||
      visible.toSet().length != visible.length ||
      !visible.every(act0B19DeckV1.contains)) {
    throw ArgumentError('Illegal visible cards');
  }
  var wins = 0, ties = 0, total = 0;
  for (final hand in range) {
    if (hand.length != 2 ||
        hand.toSet().length != 2 ||
        !hand.every(act0B19DeckV1.contains)) {
      throw ArgumentError('Illegal opponent combination');
    }
    if (hand.any(visible.contains)) continue;
    final unseen = act0B19DeckV1
        .where((card) => !visible.contains(card) && !hand.contains(card))
        .toList();
    void count(List<String> runout) {
      final h = solver.Hand.solveHand([...hero, ...board, ...runout]);
      final v = solver.Hand.solveHand([...hand, ...board, ...runout]);
      final winners = solver.Hand.winners([h, v]);
      total++;
      if (winners.length == 2) {
        ties++;
      } else if (winners.single == h) {
        wins++;
      }
    }

    for (var i = 0; i < unseen.length; i++) {
      if (board.length == 4) {
        count([unseen[i]]);
      } else {
        for (var j = i + 1; j < unseen.length; j++) {
          count([unseen[i], unseen[j]]);
        }
      }
    }
  }
  if (total == 0) throw ArgumentError('No legal opponent combinations');
  return (wins: wins, ties: ties, total: total);
}

double act0B19ShareV1(({int wins, int ties, int total}) result) =>
    (result.wins + result.ties / 2) / result.total;

/// A pot-sized hypothetical turn lead, not an action in the actual flop replay.
/// The caller's cost and contestable pot come from the same C1 ledger as the
/// table, including the starting-stack caps.
({double bet, double pot, double due, double price}) act0B92TurnPriceV1(
  Act0HandContributionsV1 ledger, {
  required Set<String> seats,
  required String hero,
  required String opponent,
}) {
  final current = ledger.amounts(seatIds: seats, actorSeatId: hero);
  final bet = current.potBb;
  if (ledger.throughStreet != PokerStreet.flop || current.toCallBb != 0) {
    throw ArgumentError('Turn comparison requires a matched flop');
  }
  final turn = Act0HandContributionsV1(
    throughStreet: PokerStreet.turn,
    startingStackBbBySeat: ledger.startingStackBbBySeat,
    entries: [
      ...ledger.entries,
      Act0ContributionV1(
        PokerStreet.turn,
        opponent,
        Act0ContributionKindV1.wager,
        bet,
      ),
    ],
  ).amounts(seatIds: seats, actorSeatId: hero);
  if (turn.toCallBb != bet) throw ArgumentError('Turn bet must be matchable');
  final price = act0CallPriceV1(turn.potBb, turn.toCallBb!)!;
  return (bet: bet, pot: turn.potBb, due: turn.toCallBb!, price: price.equity);
}

/// Nullable candidate denotes 'none of these'. Every actual candidate is a
/// fresh card, and must leave at least one legal opponent combination.
({double referenceShare, Map<String, double> shares, Set<String> changingIds})
act0B92TurnChoicesV1({
  required List<String> hero,
  required List<String> flop,
  required List<List<String>> range,
  required String reference,
  required Map<String, String?> candidates,
  required double price,
}) {
  final cards = [reference, ...candidates.values.whereType<String>()];
  if (flop.length != 3 ||
      cards.toSet().length != cards.length ||
      cards.any(
        (card) =>
            !act0B19DeckV1.contains(card) ||
            hero.contains(card) ||
            flop.contains(card),
      ) ||
      !price.isFinite ||
      price <= 0 ||
      price >= 1) {
    throw ArgumentError('Invalid turn comparison');
  }
  double share(String card) => act0B19ShareV1(
    act0B19ShowdownV1(hero: hero, board: [...flop, card], range: range),
  );
  final ref = share(reference);
  // Break-even is a fold here, since a call must earn strictly positive EV.
  final shares = {
    for (final entry in candidates.entries)
      if (entry.value != null) entry.key: share(entry.value!),
  };
  final changing = shares.entries
      .where((entry) => (entry.value > price) != (ref > price))
      .map((entry) => entry.key)
      .toSet();
  if (changing.isEmpty) {
    changing.addAll(
      candidates.entries
          .where((entry) => entry.value == null)
          .map((entry) => entry.key),
    );
  }
  return (referenceShare: ref, shares: shares, changingIds: changing);
}

import 'hand_evaluator.dart';
import 'side_pot_engine.dart';
import 'stack_state_engine.dart';

class ShowdownResult {
  const ShowdownResult(this.winners);

  final List<int> winners;
}

class ShowdownEngine {
  const ShowdownEngine(this.evaluator, this.stacks);

  final HandEvaluator evaluator;
  final StackStateEngine stacks;

  ShowdownResult computeWinners(List<List<Object>> hands) {
    var bestRank = -1;
    final winners = <int>[];
    for (var i = 0; i < hands.length; i++) {
      final rank = evaluator.evaluate(hands[i]).rank;
      if (rank > bestRank) {
        bestRank = rank;
        winners
          ..clear()
          ..add(i);
      } else if (rank == bestRank) {
        winners.add(i);
      }
    }
    return ShowdownResult(winners);
  }

  List<int> computeWinnersForEligible(
    List<List<Object>> hands,
    List<int> eligible,
  ) {
    final ranks = <int, int>{};
    for (final seat in eligible) {
      if (seat < 0 || seat >= hands.length) {
        continue;
      }
      ranks[seat] = evaluator.evaluateHand(hands[seat]);
    }
    if (ranks.isEmpty) {
      return const [];
    }
    final best = ranks.values.reduce((a, b) => a > b ? a : b);
    return ranks.entries
        .where((entry) => entry.value == best)
        .map((entry) => entry.key)
        .toList();
  }

  void distributePot(double pot, List<int> winners) {
    if (winners.isEmpty) {
      return;
    }
    final share = pot / winners.length;
    for (final seat in winners) {
      stacks.stacks[seat] += share;
    }
  }

  void distributeSidePots(List<SidePot> pots, List<List<Object>> hands) {
    for (final pot in pots) {
      final eligibleWinners = computeWinnersForEligible(
        hands,
        pot.eligibleSeats,
      );
      distributePot(pot.amount, eligibleWinners);
    }
  }
}

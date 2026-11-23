import 'dart:math' as math;

import 'act0_hand_contributions_v1.dart';

typedef Act0DecisionPotV1 = ({double amountBb, Set<String> eligibleSeatIds});

/// Computes the stacks at the start of the decision street, including chips
/// already committed on that street. Unknown exact budgets stay unknown.
Map<String, double> act0EffectiveStacksV1(
  Act0HandContributionsV1 ledger, {
  required String heroSeatId,
  required Set<String> activeSeatIds,
}) {
  final stacks = Map.of(ledger.startingStackBbBySeat);
  for (final entry in ledger.entries) {
    if (entry.street == ledger.throughStreet) break;
    final stack = stacks[entry.seatId];
    if (stack == null) continue;
    stacks[entry.seatId] = stack - entry.netAmountBb;
  }
  final hero = stacks[heroSeatId];
  return {
    for (final seat in activeSeatIds)
      if (seat != heroSeatId && hero != null && stacks[seat] != null)
        seat: math.min(hero, stacks[seat]!),
  };
}

/// Derives contestable pots from committed money in a complete hand ledger.
/// Include folded contributions in pot values but exclude folded seats from
/// eligibility. A single player's excess is not yet a contestable side pot.
/// Returns null when the ledger omits earlier streets or no pot can be assigned.
List<Act0DecisionPotV1>? act0PotEligibilityV1(
  Act0HandContributionsV1 ledger, {
  required Set<String> activeSeatIds,
}) {
  return ledger.contestablePots(activeSeatIds: activeSeatIds);
}

import 'dart:math' as math;

import 'package:poker_analyzer/models/poker_street.dart';

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
    stacks[entry.seatId] = stack - _net(entry);
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
  if (ledger.fromStreet != PokerStreet.preflop) return null;
  final committed = <String, double>{};
  var antes = 0.0;
  for (final entry in ledger.entries) {
    if (entry.kind == Act0ContributionKindV1.ante) {
      antes += entry.amountBb;
      continue;
    }
    committed.update(
      entry.seatId,
      (amount) => amount + _net(entry),
      ifAbsent: () => _net(entry),
    );
  }

  const tolerance = 1e-9;
  final levels = committed.values.toSet().toList()..sort();
  final pots = <Act0DecisionPotV1>[];
  var previous = 0.0;
  for (final level in levels) {
    if (level <= previous + tolerance) continue;
    final contributors = committed.keys.where(
      (seat) => committed[seat]! >= level - tolerance,
    );
    if (contributors.length == 1 &&
        activeSeatIds.contains(contributors.single)) {
      break;
    }
    final eligible = contributors.where(activeSeatIds.contains).toSet();
    final amount =
        (level - previous) * contributors.length + (pots.isEmpty ? antes : 0);
    if (eligible.isEmpty) {
      if (pots.isEmpty) return null;
      final prior = pots.removeLast();
      pots.add((
        amountBb: prior.amountBb + amount,
        eligibleSeatIds: prior.eligibleSeatIds,
      ));
    } else if (pots.isNotEmpty &&
        pots.last.eligibleSeatIds.length == eligible.length &&
        pots.last.eligibleSeatIds.containsAll(eligible)) {
      final prior = pots.removeLast();
      pots.add((
        amountBb: prior.amountBb + amount,
        eligibleSeatIds: prior.eligibleSeatIds,
      ));
    } else {
      pots.add((amountBb: amount, eligibleSeatIds: eligible));
    }
    previous = level;
  }
  return pots;
}

double _net(Act0ContributionV1 entry) =>
    entry.kind == Act0ContributionKindV1.uncalledReturn
    ? -entry.amountBb
    : entry.amountBb;
